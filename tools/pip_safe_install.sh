#!/bin/bash

use_legacy_resolver=false  # 初始化变量为false，表示默认不使用legacy resolver

# 定义一个函数来处理命令执行
do_cmd(){
    local cmd="$@"
    echo "do_cmd $cmd"
    eval "$cmd"
    if [[ $? -ne 0 ]]; then
        echo "do_cmd failed"
        if ! $use_legacy_resolver; then
            echo "Try running the script with --use-legacy to use the legacy resolver."
        fi
        continue
    fi
}

# 检查命令行参数中是否包含 --use-legacy
for arg in "$@"; do
    if [[ $arg == "--use-legacy" ]]; then
        use_legacy_resolver=true
        break
    fi
done

# 移除已经处理的 --use-legacy 参数
shift_count=0
for arg in "$@"; do
    if [[ $arg == "--use-legacy" ]]; then
        ((shift_count++))
        shift
    fi
done

# 遍历剩余的命令行参数
for arg in "${@:$shift_count}"; do
    # 检查参数是否以 .txt 结尾
    if [[ $arg == *.txt ]]; then
        echo "Installing packages from $arg..."

        # 使用 sed 和 grep 过滤 requirements.txt 文件内容
        prgs="$(cat "$arg" | sed '/^#/d;/\#$/d;/^$/d;/#.*$/d;/\;.*$/d;/<.*$/d;/>.*$/d;/\~.*$/d;' | grep -Ev 'torch|xformers'| cut -d= -f1|paste -sd ' ')"

        if [[ -z "$prgs" ]]; then
            echo "No packages found in $arg"
            continue
        fi

        # 根据use_legacy_resolver的值构建pip install命令
        pip_cmd="pip install -U"
        if $use_legacy_resolver; then
            pip_cmd="$pip_cmd --prefer-binary --use-deprecated=legacy-resolver"
        fi

        # 执行pip install命令
        do_cmd "$pip_cmd $prgs"
    else
        echo "Skipping non-.txt file: $arg"
    fi
done
