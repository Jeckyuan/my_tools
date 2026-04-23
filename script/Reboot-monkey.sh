#!/bin/bash

# ============================================
# Android Monkey + 自动重启 + Yocto ADB重连 循环脚本
# ============================================
Scripts_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# other_script="${Scripts_dir}/get-hyper-memory.sh"
# $other_script
# 配置
MONKEY_EVENTS=1500           # 每次monkey事件数
MONKEY_THROTTLE=200          # 事件间隔(ms) monkey运行时间=总的事件数*每个事件间隔 eg:1500*200=300 000ms=300s=5min
MAX_REBOOT_COUNT=0           # 最大重启次数(0=无限循环)

# 计数器
alps_REBOOT_INTERVAL=100          # 安卓重启后等待时间(秒)
yocto_REBOOT_INTERVAL=200         # YOCTO重启后等待时间(秒)
alps_REBOOT_COUNT=0
yocto_REBOOT_COUNT=0
mokey_COUNT=0                     # monkey 运行次数

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

yocto_device='127.0.0.1:7665'
tbox_device='127.0.0.1:7667'

TimeStamp=$(date +"%Y%m%d_%H%M%S")
memory_log="./Memory_${TimeStamp}.txt"

# ============================================
# 函数：连接Yocto ADB
# ============================================
connect_yocto() {
    echo -e "${YELLOW}[Yocto] 正在连接Yocto ADB...${NC}"

    adb disconnect 
    # 等待安卓设备
    echo "[Android] 等待安卓设备就绪..."
    adb -d wait-for-device
    adb -d root
    sleep 2
    adb -d forward tcp:7665 tcp:6665
    adb -d connect 127.0.0.1:7665

    # 等待Yocto连接就绪（最多20秒）
    echo "[Yocto] 等待Yocto连接就绪..."
    for i in {1..20}; do
        if adb -s ${yocto_device} shell echo "ok" > /dev/null 2>&1; then
            echo -e "${GREEN}[Yocto] 连接成功！${NC}"
            return 0
        fi
        sleep 1
    done
    
    echo -e "${RED}[Yocto] 连接失败！${NC}"
    return 1
}

connect_tbox() {
    echo -e "${YELLOW}[Yocto] 正在连接Yocto ADB...${NC}"

    adb disconnect 
    # 等待安卓设备
    echo "[Android] 等待安卓设备就绪..."
    adb -d wait-for-device
    adb -d root
    sleep 2
    adb -d forward tcp:7665 tcp:6665
    adb -d connect 127.0.0.1:7665

    adb -d forward tcp:7667 tcp:6667
    sleep 10
    adb -d connect 127.0.0.1:7667
    # 等待Yocto连接就绪（最多20秒）
    echo "[Tbox] 等待Tbox连接就绪..."
    for i in {1..20}; do
        if adb -s ${tbox_device} shell echo "ok" > /dev/null 2>&1; then
            echo -e "${GREEN}[Tbox] 连接成功！${NC}"
            return 0
        fi
        sleep 1
    done
    
    echo -e "${RED}[Tbox] 连接失败！${NC}"
    return 1
}

# ============================================
# 函数：运行Monkey测试
# ============================================
run_monkey() {
    echo -e "${YELLOW}[Android] 开始第 $((mokey_COUNT)) 次Monkey测试...${NC}"
    
    # 等待安卓设备
    adb -d wait-for-device
    
    # 运行monkey
    adb -d shell monkey \
        --throttle $MONKEY_THROTTLE \
        --ignore-crashes \
        --ignore-timeouts \
        --ignore-security-exceptions \
        --kill-process-after-error \
        -v -v $MONKEY_EVENTS
    
    MONKEY_EXIT_CODE=$?
    echo "[Android] Monkey测试完成，退出码: $MONKEY_EXIT_CODE"
    
    # 增加重启计数
    ((mokey_COUNT++))

    return $MONKEY_EXIT_CODE
}

# ============================================
# 函数：重启安卓并等待
# ============================================
reboot_android() {
    echo -e "${YELLOW}[Android] 正在重启安卓...${NC}"
    
    # 重启安卓
    adb -d wait-for-device
    adb -d shell "reboot"
    
    # 增加重启计数
    ((alps_REBOOT_COUNT++))
    
    echo -e "${GREEN}[统计] 安卓已重启 ${alps_REBOOT_COUNT} 次${NC}"
    echo "[Android] 等待 ${alps_REBOOT_INTERVAL} 秒后重新连接..."
    
    # 等待指定时间
    sleep $alps_REBOOT_INTERVAL
}

# ============================================
# 函数：重启YOCTO并等待
# ============================================
reboot_yocto() {

    # 重新连接Yocto
    connect_yocto

    echo -e "${YELLOW}[YOCTO] 正在重启YOCTO...${NC}"
    
    # 重启
    adb -s ${yocto_device} shell "reboot"
    
    # 增加重启计数
    ((yocto_REBOOT_COUNT++))
    
    echo -e "${GREEN}[统计] YOCTO已重启 ${yocto_REBOOT_COUNT} 次${NC}"
    echo "[YOCTO] 等待 ${yocto_REBOOT_INTERVAL} 秒后重新连接..."
    
    # 等待指定时间
    sleep $yocto_REBOOT_INTERVAL
    
}

hyper_memory(){
adb disconnect
adb -d wait-for-device
adb -d root
sleep 3
adb -d remount
adb -d forward tcp:7665 tcp:6665
adb connect 127.0.0.1:7665

# 等待连接就绪（最多 20 秒）
echo "Waiting for ADB over WiFi..."
for i in {1..20}; do
    if adb -e shell echo "ok" > /dev/null 2>&1; then
        echo "Connected"
        break
    fi
    sleep 1
done

adb -e shell "mount -o remount,rw /"

    if adb -e shell echo "test" > /dev/null 2>&1; then
        # 设备在线，执行监控，输出同时显示在终端并保存到本地文件
        {
            echo "========================================"
            echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
            echo "========================================"
            echo "【kstats 统计信息】"
            adb -e shell "nblruncmd -t 'kstats -m -n 1'" 2>&1
            echo ""
            echo "【进程信息】"
            adb -e shell "nblruncmd -t ps" 2>&1
            echo ""
        } | tee -a "$memory_log"
        
        # sleep 20m
    else
        # 设备离线，尝试重连
        echo "$(date) - 设备离线，尝试重新连接..." | tee -a "$memory_log"
        sleep 3
    fi

}

# ============================================
# 主循环
# ============================================

echo "=========================================="
echo "  Android Monkey + Reboot 循环测试脚本"
echo "=========================================="
echo ""

# 无限循环（或达到最大次数）
while true; do
    # 检查是否达到最大重启次数
    if [ $MAX_REBOOT_COUNT -gt 0 ] && [ $REBOOT_COUNT -ge $MAX_REBOOT_COUNT ]; then
        echo -e "${GREEN}已达到最大重启次数(${MAX_REBOOT_COUNT})，测试完成！${NC}"
        break
    fi
    
    # 重启安卓
    reboot_android
    hyper_memory
    # # ========== 新增：每10次重启执行自定义操作 ==========
    # if [ $((alps_REBOOT_COUNT % 10)) -eq 0 ]; then
    #     echo -e "${GREEN}>>> 安卓已重启 ${alps_REBOOT_COUNT} 次，执行自定义操作...${NC}"
    #     # 在这里写你的操作，或者调用函数
    #     $other_script
    # fi
    # ===================================================

    # 运行Monkey测试
    run_monkey
    
    # # 重启YOCTO
    # reboot_yocto
    
    echo "------------------------------------------"
done
