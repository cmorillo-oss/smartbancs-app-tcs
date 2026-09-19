#!/usr/bin/env bash
# Prueba de carga completa: prepara 5000 cuentas, mide CPU de los contenedores, ejecuta Locust y VERIFICA
# que bajo carga no se perdió ni se creó dinero. Uso: bash scripts/load_test.sh   (o: make load)
# SIN `-e` a propósito: la prueba sube hasta SATURAR, así que Locust termina con código != 0 y algún comando de
# consulta puede fallar cuando el sistema está al límite. Con `-e` el script moría ANTES de la verificación de
# dinero (que es lo más importante) y no quedaba `verification.txt`. Ahora cada paso es tolerante, se registra
# el código de salida de Locust y la verificación se escribe SIEMPRE.
set -uo pipefail
# En Git Bash de Windows, las rutas que empiezan por / (p. ej. /evidence/...) se "traducen" a C:/Program Files/Git/...
# y Locust escribía su informe en una carpeta basura dentro de tests/. Esto desactiva esa conversión.
export MSYS_NO_PATHCONV=1
cd "$(dirname "$0")/.."
OUT=evidence/load-test-results
mkdir -p "$OUT"
PSQL="docker compose exec -T postgres psql -U smartbancs -d smartbancs -tA"

docker compose up -d --build >/dev/null || { echo "ERROR: no se pudo levantar docker compose (¿Docker Desktop está corriendo?)"; exit 1; }
for _ in $(seq 1 40); do curl -sf localhost:8000/ready >/dev/null && break; sleep 2; done

# Sistema en reposo antes de medir: el backlog de eventos (IA/Bancs) de pruebas anteriores compite por la BD.
echo "Esperando a que el outbox esté vacío..."
for _ in $(seq 1 60); do
  p=$($PSQL -c "select count(*) from outbox_events where status in ('PENDING','PROCESSING')")
  [ "$p" = "0" ] && break; sleep 5
done

echo "Preparando 5000 cuentas de prueba (saldo 1.000.000 cada una)..."
$PSQL -c "INSERT INTO accounts (account_number, customer_id, balance, currency)
          SELECT 'LT-' || lpad(g::text, 5, '0'), 'CUST-LT-' || lpad(g::text, 5, '0'), 1000000, 'USD' FROM generate_series(1, 5000) g
          ON CONFLICT (account_number) DO UPDATE SET balance = 1000000, status = 'ACTIVE'" >/dev/null
BEFORE=$($PSQL -c "select sum(balance) from accounts where account_number like 'LT-%'")
TX_BEFORE=$($PSQL -c "select count(*) from transactions")
DL_BEFORE=$($PSQL -c "select deadlocks from pg_stat_database where datname='smartbancs'")

# Muestreo de CPU/memoria de los contenedores cada 2 s (100% = 1 núcleo): dice QUÉ se satura.
: > "$OUT/docker_stats.csv"
( while true; do docker stats --no-stream --format '{{.Name}},{{.CPUPerc}},{{.MemUsage}}' 2>/dev/null | sed "s/^/$(date +%s),/" >> "$OUT/docker_stats.csv"; sleep 1; done ) &
SAMPLER=$!
trap 'kill $SAMPLER 2>/dev/null || true' EXIT

echo "Ejecutando la rampa de carga (8 escalones x 25 s = ~3.5 min)..."
docker compose --profile test run --rm -T tests locust -f load/locustfile.py --headless --host http://transaction-api:8000 \
  --csv /evidence/load-test-results/locust --html /evidence/load-test-results/locust_report.html --only-summary 2>&1 \
  | grep -v "^ Container\|^#" | tee "$OUT/locust_console.txt" | sed -n '/PRUEBA DE CARGA/,$p'
LOCUST_RC=${PIPESTATUS[0]}   # código de Locust (distinto de 0 = hubo peticiones fallidas: ESPERADO al saturar)
# Locust termina con código != 0 cuando hubo peticiones fallidas; al SATURAR es lo esperado. Por eso el script no usa `-e`
# y este código solo se registra (en verification.txt); no aborta nada.
kill $SAMPLER 2>/dev/null || true

sleep 3
AFTER=$($PSQL -c "select sum(balance) from accounts where account_number like 'LT-%'")
TX_AFTER=$($PSQL -c "select count(*) from transactions")
DL_AFTER=$($PSQL -c "select deadlocks from pg_stat_database where datname='smartbancs'")
DEBIT=$($PSQL -c "select coalesce(sum(amount),0) from ledger_entries where entry_type='DEBIT'")
CREDIT=$($PSQL -c "select coalesce(sum(amount),0) from ledger_entries where entry_type='CREDIT'")

{
  echo
  echo "VERIFICACIÓN DE CORRECCIÓN BAJO CARGA"
  echo "====================================="
  echo "Dinero total en las 5000 cuentas:  antes $BEFORE  |  después $AFTER   ->  $([ "$BEFORE" = "$AFTER" ] && echo 'CONSERVADO (ni un centavo perdido ni creado)' || echo 'DESCUADRADO')"
  echo "Código de salida de Locust: ${LOCUST_RC:-?} (distinto de 0 es normal: hubo peticiones fallidas al saturar)"
  echo "Transferencias registradas en la carga: $((TX_AFTER - TX_BEFORE))"
  echo "Libro mayor: suma DEBIT = $DEBIT  |  suma CREDIT = $CREDIT   ->  $([ "$DEBIT" = "$CREDIT" ] && echo 'CUADRA' || echo 'DESCUADRADO')"
  echo "Deadlocks de PostgreSQL durante la carga: $((DL_AFTER - DL_BEFORE))"
  echo
  echo "USO DE CPU DURANTE LA CARGA (100% = un núcleo completo) — pico y media de cada contenedor:"
  (python scripts/cpu_summary.py "$OUT/docker_stats.csv" || python3 scripts/cpu_summary.py "$OUT/docker_stats.csv" || echo "  (no se pudo resumir la CPU: ver docker_stats.csv)")
} | tee "$OUT/verification.txt"
