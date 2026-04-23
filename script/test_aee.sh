#!/bin/bash
# 带进度条、错误重试和重试次数限制的版本

total=10
interval=30
retry_interval=5
max_retries=10  # 最大重试次数
device="DEAQY97HCAAYPVDEYOCTO"

echo "将执行 $total 次 sysrq 触发，间隔 $interval 秒"
echo "目标设备: $device"
echo "最大重试次数: $max_retries"
echo "进度: [----------] 0%"

# 检查设备连接函数
check_device_connection() {
    if adb -s $device shell "echo '设备连接测试'" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# 等待设备恢复连接
wait_for_device() {
    local max_wait=60
    local wait_count=0
    
    echo -n "等待设备恢复连接"
    while [ $wait_count -lt $max_wait ]; do
        if check_device_connection; then
            echo -e "\n设备已重新连接"
            return 0
        fi
        echo -n "."
        sleep 1
        wait_count=$((wait_count + 1))
    done
    
    echo -e "\n等待设备连接超时"
    return 1
}

for i in $(seq 1 $total); do
    retry_count=0
    success=false
    
    # 确保设备连接
    if ! check_device_connection; then
        echo -e "\n第 $i 次执行前设备未连接，尝试重新连接..."
        wait_for_device
    fi
    
    # 执行命令，如果失败则重试直到成功或达到最大重试次数
    while [ $retry_count -le $max_retries ]; do
        # 执行命令
        if adb -s $device shell "nbl_vm_ctl  aeedump --vmid 1"; then
            # 命令执行成功
            success=true
            break
        else
            # 命令执行失败
            retry_count=$((retry_count + 1))
            if [ $retry_count -le $max_retries ]; then
                echo -e "\n第 $i 次执行失败，${retry_interval}秒后重试... ($retry_count/$max_retries)"
                sleep $retry_interval
                
                # 检查设备连接
                if ! check_device_connection; then
                    echo "设备连接丢失，尝试重新连接..."
                    wait_for_device
                fi
            else
                echo -e "\n第 $i 次执行失败，已达到最大重试次数 ($max_retries)，跳过本次执行"
            fi
        fi
    done
    
    # 如果执行成功，更新进度条
    if [ "$success" = true ]; then
        # 计算进度百分比
        percent=$((i * 10))
        bars=$((i * 10 / 10))
        spaces=$((10 - bars))
        
        # 显示进度条
        printf "\r进度: ["
        for ((j=0; j<bars; j++)); do printf "#"; done
        for ((j=0; j<spaces; j++)); do printf "-"; done
        printf "] ${percent}%% (${i}/${total})"
        
        # 如果不是最后一次，等待
        if [ $i -lt $total ]; then
            echo -e "\n等待 ${interval} 秒后进行下一次执行..."
            
            # 在等待期间检查设备连接
            for ((wait_sec=interval; wait_sec>0; wait_sec--)); do
                printf "\r剩余等待时间: %2d 秒" $wait_sec
                sleep 1
                
                # 每10秒检查一次设备连接
                if [ $((wait_sec % 10)) -eq 0 ] && [ $wait_sec -ne $interval ]; then
                    if ! check_device_connection; then
                        echo -e "\n设备连接丢失，尝试重新连接..."
                        wait_for_device
                    fi
                fi
            done
            printf "\n"
        fi
    else
        # 如果执行失败且已达到最大重试次数，更新进度条但标记为失败
        percent=$((i * 10))
        bars=$((i * 10 / 10))
        spaces=$((10 - bars))
        
        # 显示进度条（带失败标记）
        printf "\r进度: ["
        for ((j=0; j<bars; j++)); do printf "#"; done
        for ((j=0; j<spaces; j++)); do printf "-"; done
        printf "] ${percent}%% (${i}/${total}) [失败]"
        
        # 如果不是最后一次，等待
        if [ $i -lt $total ]; then
            sleep $interval
        fi
    fi
done

# 完成所有执行后，等待设备恢复并执行最后的命令
echo -e "\n所有 sysrq 触发完成，等待设备恢复连接..."
if wait_for_device; then
    echo "执行最后的目录查看命令:"
    adb -s $device shell "ls -l /data/nb_share/aee_exp/*"
else
    echo "无法连接到设备，无法执行最后的目录查看命令"
fi

echo -e "\n脚本执行完成!"
