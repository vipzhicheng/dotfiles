
# Semo Related
## alias mm="semo mm"
 eval "$(semo completion)"

export PATH="$HOME/.local/bin:$PATH"

# Custom cli command
# 自动识别当前目录下的 cli 脚本
cli() {
  if [[ -f "./cli" && -x "./cli" ]]; then
    ./cli "$@"
  else
    # 如果当前目录没有 cli，尝试调用系统已有的 cli 命令（如果有的话）
    if command -v cli >/dev/null 2>&1; then
      command cli "$@"
    else
      echo "zsh: command not found: cli (当前目录下未找到可执行的 ./cli 脚本)"
      return 1
    fi
  fi
}
alias platform="cli platform"
