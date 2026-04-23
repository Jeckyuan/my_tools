#!/bin/bash
#./1.log tbox1.log
# 分析tbox1.log文件中相邻两行的时间差
analyze_time_diff() {
    local log_file="$1"
    
    # 检查文件是否存在
    if [[ ! -f "$log_file" ]]; then
        echo "错误: 文件 $log_file 不存在"
        return 1
    fi
    
    echo "分析结果:"
    echo "行号 | 时间戳 | 与上一行的时间差(秒)"
    echo "----------------------------------------"
    
    # 提取时间戳并计算时间差
    prev_timestamp=""
    prev_epoch=""
    line_number=0
    has_exceeded=0
    
    while IFS= read -r line; do
        ((line_number++))
        
        # 提取时间戳部分 (Nov 04 15:19:00)
        if [[ "$line" =~ ^([A-Za-z]{3} [0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}) ]]; then
            current_timestamp="${BASH_REMATCH[1]}"
            
            # 转换为时间戳
            current_epoch=$(date -d "$current_timestamp" +%s 2>/dev/null)
            
            if [[ -n "$prev_epoch" && -n "$current_epoch" ]]; then
                time_diff=$((current_epoch - prev_epoch))
                
                # 显示所有时间差
                printf "%-2s-%-2s | %s | %d秒" "$((line_number-1))" "$line_number" "$current_timestamp" "$time_diff"
                
                if [[ $time_diff -gt 60 ]]; then
                    echo " *** 超过60秒! ***"
                    has_exceeded=1
                    
                    echo "=== 异常时间差发现 ==="
                    echo "时间段: $prev_timestamp 到 $current_timestamp"
                    echo "时间差: ${time_diff} 秒"
                    echo ""
                else
                    echo ""
                fi
            else
                if [[ -n "$prev_epoch" ]]; then
                    echo "第 $line_number 行: 时间解析错误"
                else
                    echo "第 $line_number 行: $current_timestamp (首行)"
                fi
            fi
            
            prev_timestamp="$current_timestamp"
            prev_epoch="$current_epoch"
        else
            echo "第 $line_number 行: 格式不正确 - $line"
        fi
    done < "$log_file"
    
    if [[ $has_exceeded -eq 0 ]]; then
        echo ""
        echo "✅ 所有相邻行的时间差都在60秒以内"
    fi
    
    if [[ $line_number -lt 2 ]]; then
        echo "文件行数不足，无法进行时间差分析"
    fi
}

# 主程序
log_file="tbox1.log"

# 如果提供了参数，使用参数作为文件名
if [[ $# -gt 0 ]]; then
    log_file="$1"
fi

echo "正在分析文件: $log_file"
echo "======================================"

# 检查文件是否存在
if [[ ! -f "$log_file" ]]; then
    echo "错误: 文件 $log_file 不存在"
    echo "当前目录文件列表:"
    ls -la
    exit 1
fi

analyze_time_diff "$log_file"
