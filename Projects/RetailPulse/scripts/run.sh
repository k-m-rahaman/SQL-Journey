#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
mode="${1:-all}"
case "$mode" in
  all) files=(01_schema 02_seed 03_views 05_procedures 06_tests 04_analytics 07_performance) ;;
  test) files=(06_tests) ;;
  analytics) files=(04_analytics) ;;
  performance) files=(07_performance) ;;
  *) printf 'Usage: bash scripts/run.sh [all|test|analytics|performance]\n' >&2; exit 2 ;;
esac

compose=(docker compose --project-directory "$project_root" -f "$project_root/compose.yaml")
"${compose[@]}" up -d --wait --wait-timeout 120

for file in "${files[@]}"; do
  printf '\n>>> %s.sql\n' "$file"
  "${compose[@]}" exec -T db sh -c \
    'MYSQL_PWD=$MYSQL_ROOT_PASSWORD exec mysql --user=root --default-character-set=utf8mb4 --show-warnings' \
    < "$project_root/sql/$file.sql"
done

printf '\nRetailPulse %s completed successfully.\n' "$mode"
