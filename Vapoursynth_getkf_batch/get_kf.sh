#!/bin/bash
# macOS 版关键帧批量生成脚本
# 用法: ./get_kf.sh 视频文件1 视频文件2 ...
# 或: ./get_kf.sh *.mp4

# ========== vspipe 路径设置 ==========
# 请将下方路径改为你系统中 vspipe 的实际路径
# 常见路径:
#   Apple Silicon (M1/M2/M3/M4): /opt/homebrew/bin/vspipe
#   Intel Mac:                   /usr/local/bin/vspipe
#   vsrepo 安装:                 ~/.local/bin/vspipe
# 可在终端运行 "which vspipe" 查找实际路径

vspipe="/opt/homebrew/bin/vspipe"

# 如果上面预设路径不存在，尝试其他常见路径
if [ ! -f "$vspipe" ]; then
    if [ -f "/usr/local/bin/vspipe" ]; then
        vspipe="/usr/local/bin/vspipe"
    elif [ -f "$HOME/.local/bin/vspipe" ]; then
        vspipe="$HOME/.local/bin/vspipe"
    elif command -v vspipe &> /dev/null; then
        vspipe="$(command -v vspipe)"
    else
        echo "错误: 找不到 vspipe，请确认已安装 Vapoursynth"
        echo "安装方法: brew install vapoursynth"
        exit 1
    fi
fi

export VSPIPE_LOG_LEVEL=2

# 获取脚本所在目录
script_dir="$(cd "$(dirname "$0")" && pwd)"

# 检查是否有参数
if [ $# -eq 0 ]; then
    echo "用法: $0 视频文件1 [视频文件2 ...]"
    echo "示例: $0 video.mp4"
    echo "      $0 *.mp4"
    echo "      $0 video1.mkv video2.mp4"
    exit 1
fi

# 逐文件处理
for filepath in "$@"; do
    if [ ! -f "$filepath" ]; then
        echo "警告: 文件不存在，跳过: $filepath"
        continue
    fi

    echo "正在处理: $filepath"

    # 运行 vspipe 生成关键帧（-- 表示处理所有帧但不输出视频数据，-p 显示进度）
    "$vspipe" -p -a "name=$filepath" "$script_dir/get_kf.vpy" --

    # 清理 .lwi 索引文件
    lwi_file="${filepath}.lwi"
    if [ -f "$lwi_file" ]; then
        rm -f "$lwi_file"
        echo "已清理: $lwi_file"
    fi

    echo "完成: $filepath"
    echo "---"
done

echo "全部处理完毕"
