#!/bin/sh
set -eu

# 用法示例:
#   ./start_stress_online.sh              # 默认只启动 cpu worker
#   ./start_stress_online.sh timer        # 启动 cpu + timer worker
#   STRESS_BIN=/data/stress-ng-64 ./start_stress_online.sh timer
#
# 参数:
#   $1           "timer" 时同时启动 timer worker，否则仅启动 cpu worker，默认: 无
#
# 可选环境变量:
#   STRESS_BIN   stress-ng 可执行文件路径，默认: /data/stress-ng-64
#   TEMP_PATH    stress-ng 临时目录，默认: /data/.stress-ng-tmp
#   EXTRA_ARGS   额外传给 stress-ng 的参数（例如: "--metrics-brief"）

STRESS_BIN="${STRESS_BIN:-/data/stress-ng-64}"
TEMP_PATH="${TEMP_PATH:-/data/.stress-ng-tmp}"
EXTRA_ARGS="${EXTRA_ARGS:-}"
ENABLE_TIMER="${1:-}"

if [ ! -x "$STRESS_BIN" ]; then
  echo "[ERROR] stress-ng 不存在或不可执行: $STRESS_BIN"
  echo "        你可以这样指定: STRESS_BIN=/path/to/stress-ng ./start_stress_online.sh"
  exit 1
fi

if [ ! -r /sys/devices/system/cpu/online ]; then
  echo "[ERROR] 无法读取 /sys/devices/system/cpu/online"
  exit 1
fi

mkdir -p "$TEMP_PATH"
if [ ! -w "$TEMP_PATH" ]; then
  echo "[ERROR] TEMP_PATH 不可写: $TEMP_PATH"
  echo "        你可以这样指定: TEMP_PATH=/data/tmp ./start_stress_online.sh"
  exit 1
fi

if ! command -v taskset >/dev/null 2>&1; then
  echo "[ERROR] 未找到 taskset，无法进行绑核"
  exit 1
fi

cpu_to_mask() {
  cpu="$1"
  mask=$((1 << cpu))
  printf '%x' "$mask"
}

expand_cpulist() {
  list="$1"
  echo "$list" | tr ',' '\n' | while IFS='-' read -r start end; do
    if [ -z "$end" ]; then
      echo "$start"
    else
      i="$start"
      while [ "$i" -le "$end" ]; do
        echo "$i"
        i=$((i + 1))
      done
    fi
  done
}

online_raw="$(cat /sys/devices/system/cpu/online)"
pids=""

cleanup() {
  echo
  echo "[INFO] 收到中断信号，准备停止 stress-ng 进程..."
  if [ -n "$pids" ]; then
    kill $pids 2>/dev/null || true
    wait $pids 2>/dev/null || true
  fi
  echo "[INFO] 已停止。"
}
trap cleanup INT TERM

echo "[INFO] online cpu: $online_raw"
echo "[INFO] stress bin: $STRESS_BIN"
echo "[INFO] temp path: $TEMP_PATH"
echo "[INFO] taskset 模式: cpumask"

cd "$TEMP_PATH"
echo "[INFO] cwd 已切换到: $(pwd)"

if [ "$ENABLE_TIMER" = "timer" ]; then
  echo "[INFO] 模式: cpu + timer worker"
  TIMER_ARG="--timer 1"
else
  echo "[INFO] 模式: cpu worker only"
  TIMER_ARG=""
fi

# 逐个 cpu 启动 worker
for c in $(expand_cpulist "$online_raw"); do
  # 每个核启动: 1 个 cpu worker + (可选) 1 个 timer worker
  # 不加 --timeout，持续运行直到手动停止
  mask="$(cpu_to_mask "$c")"
  taskset "$mask" "$STRESS_BIN" --quiet --temp-path "$TEMP_PATH" --cpu 1 --cpu-load 100 $TIMER_ARG $EXTRA_ARGS &
  pid=$!
  pids="$pids $pid"
  echo "[INFO] 已在 cpu$c 上启动 stress-ng (mask=0x$mask, pid=$pid)"
done

echo "[INFO] 已启动所有 stress-ng 进程，按 Ctrl+C 停止。"
if [ -n "$pids" ]; then
  wait $pids
fi
