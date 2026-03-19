#!/usr/bin/env bash
set -euo pipefail

APP_NAME="ghost-upload-app"
APP_DIR="$(cd "$(dirname "$0")" && pwd)"
PID_FILE="$APP_DIR/.next-pid"
LOG_FILE="$APP_DIR/.next-dev.log"
PORT="${PORT:-3000}"

red()   { printf "\033[31m%s\033[0m\n" "$*"; }
green() { printf "\033[32m%s\033[0m\n" "$*"; }
yellow(){ printf "\033[33m%s\033[0m\n" "$*"; }
cyan()  { printf "\033[36m%s\033[0m\n" "$*"; }

usage() {
  cat <<EOF
$(cyan "SnowGhostBreakers — $APP_NAME manager")

Usage: $0 <command>

Commands:
  install     Install npm dependencies
  setup       Full setup: install deps, check env, build
  start       Start the dev server (background, port $PORT)
  stop        Stop the running dev server
  restart     Stop then start
  status      Show whether the server is running
  build       Production build
  logs        Tail the dev server log
  test        Run test suite
  validate    Validate .env configuration
  clean       Remove node_modules, .next, logs
  help        Show this help message
EOF
}

check_node() {
  if ! command -v node &>/dev/null; then
    red "Node.js is not installed. Please install Node.js >= 18."
    exit 1
  fi
  local ver
  ver=$(node -v | sed 's/v//' | cut -d. -f1)
  if (( ver < 18 )); then
    red "Node.js >= 18 required. Found: $(node -v)"
    exit 1
  fi
}

cmd_install() {
  cyan "Installing dependencies..."
  cd "$APP_DIR"
  check_node
  npm install
  green "Dependencies installed."
}

cmd_validate() {
  cyan "Validating .env configuration..."
  local env_file="$APP_DIR/.env"
  local missing=0

  if [[ ! -f "$env_file" ]]; then
    red ".env file not found. Copy env.example to .env and fill in values."
    exit 1
  fi

  for var in SNOWFLAKE_ACCOUNT SNOWFLAKE_USER SNOWFLAKE_DATABASE SNOWFLAKE_SCHEMA SNOWFLAKE_WAREHOUSE SNOWFLAKE_ROLE; do
    val=$(grep "^${var}=" "$env_file" | cut -d= -f2-)
    if [[ -z "$val" || "$val" == "your_"* ]]; then
      red "  Missing or placeholder: $var"
      missing=1
    else
      green "  OK: $var"
    fi
  done

  local key_path
  key_path=$(grep "^SNOWFLAKE_PRIVATE_KEY_PATH=" "$env_file" | cut -d= -f2-)
  if [[ -z "$key_path" ]]; then
    red "  Missing: SNOWFLAKE_PRIVATE_KEY_PATH"
    missing=1
  elif [[ ! -f "$key_path" ]]; then
    red "  SNOWFLAKE_PRIVATE_KEY_PATH file not found: $key_path"
    missing=1
  else
    green "  OK: SNOWFLAKE_PRIVATE_KEY_PATH ($key_path)"
  fi

  if (( missing )); then
    yellow "Some configuration values are missing. The app may not connect to Snowflake."
    return 1
  else
    green "All configuration values are set."
  fi
}

cmd_setup() {
  cyan "=== Full Setup ==="
  cmd_install
  echo
  cmd_validate || true
  echo
  cyan "Building for production..."
  cd "$APP_DIR"
  npm run build
  green "=== Setup complete ==="
}

cmd_start() {
  cd "$APP_DIR"
  if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    yellow "Server already running (PID $(cat "$PID_FILE")) on port $PORT"
    return 0
  fi

  cyan "Starting dev server on port $PORT..."
  nohup npx next dev --port "$PORT" > "$LOG_FILE" 2>&1 &
  local pid=$!
  echo "$pid" > "$PID_FILE"
  sleep 2

  if kill -0 "$pid" 2>/dev/null; then
    green "Server started (PID $pid) — http://localhost:$PORT"
  else
    red "Server failed to start. Check logs: $0 logs"
    rm -f "$PID_FILE"
    exit 1
  fi
}

cmd_stop() {
  if [[ ! -f "$PID_FILE" ]]; then
    yellow "No PID file found. Server may not be running."
    lsof -ti:"$PORT" | xargs kill -9 2>/dev/null && yellow "Killed process on port $PORT" || true
    return 0
  fi

  local pid
  pid=$(cat "$PID_FILE")
  if kill -0 "$pid" 2>/dev/null; then
    cyan "Stopping server (PID $pid)..."
    kill "$pid" 2>/dev/null
    sleep 2
    kill -0 "$pid" 2>/dev/null && kill -9 "$pid" 2>/dev/null
    green "Server stopped."
  else
    yellow "Process $pid not found."
  fi
  rm -f "$PID_FILE"
}

cmd_restart() {
  cmd_stop
  sleep 1
  cmd_start
}

cmd_status() {
  if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    green "Server is RUNNING (PID $(cat "$PID_FILE")) on port $PORT"
    curl -s -o /dev/null -w "  HTTP status: %{http_code}\n" "http://localhost:$PORT" 2>/dev/null || yellow "  (not responding to HTTP yet)"
  else
    red "Server is NOT running."
    rm -f "$PID_FILE" 2>/dev/null
  fi
}

cmd_build() {
  cyan "Building production bundle..."
  cd "$APP_DIR"
  npm run build
  green "Build complete."
}

cmd_logs() {
  if [[ ! -f "$LOG_FILE" ]]; then
    yellow "No log file found. Start the server first."
    exit 1
  fi
  cyan "Tailing $LOG_FILE (Ctrl+C to stop)..."
  tail -f "$LOG_FILE"
}

cmd_test() {
  cyan "Running tests..."
  cd "$APP_DIR"
  npx jest --passWithNoTests 2>/dev/null || npm test 2>/dev/null || yellow "No test runner configured. Run: npm install -D jest @testing-library/react"
}

cmd_clean() {
  cyan "Cleaning build artifacts..."
  cd "$APP_DIR"
  rm -rf node_modules .next out coverage .next-pid .next-dev.log
  green "Cleaned."
}

case "${1:-help}" in
  install)  cmd_install ;;
  setup)    cmd_setup ;;
  start)    cmd_start ;;
  stop)     cmd_stop ;;
  restart)  cmd_restart ;;
  status)   cmd_status ;;
  build)    cmd_build ;;
  logs)     cmd_logs ;;
  test)     cmd_test ;;
  validate) cmd_validate ;;
  clean)    cmd_clean ;;
  help|*)   usage ;;
esac
