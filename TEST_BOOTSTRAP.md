# Bootstrap System - 使用指南

## ✅ 系统完成并测试通过！

你的 macOS bootstrap 系统已经成功创建并完全可用。

## 🚀 快速开始

### 1. 查看所有插件

```bash
./bootstrap.sh --list
```

### 2. 预览执行计划（推荐先运行）

```bash
./bootstrap.sh --dry-run
```

### 3. 实际执行安装

```bash
./bootstrap.sh
```

### 4. 查看帮助

```bash
./bootstrap.sh --help
```

## 📋 可用选项

```
./bootstrap.sh [options]

Options:
  --dry-run              显示执行计划，不实际执行
  --list                 列出所有插件及依赖关系
  --debug                显示详细调试信息
  --continue-on-error    出错时继续执行（不停止）
  --skip-confirmation    跳过所有确认提示（自动yes）
  --help                 显示帮助信息
```

## 📦 已安装的插件

1. **xcode** (无依赖)
   - 安装 Xcode Command Line Tools
   
2. **homebrew** (依赖: xcode)
   - 安装 Homebrew 包管理器
   
3. **zsh** (依赖: homebrew)
   - 安装/更新 Zsh shell（确保最新版本）
   
4. **ohmyzsh** (依赖: zsh)
   - 安装 Oh My Zsh 框架
   - 自动安装 zsh-autosuggestions 和 zsh-syntax-highlighting 插件
   
5. **brewfile** (依赖: homebrew)
   - 从 Brewfile 安装所有包（90+ 个工具）
   
6. **dotfiles** (依赖: ohmyzsh)
   - 创建 .zshrc 符号链接
   - 创建 .zshrc.local 和 .zshrc.temp

## 🔄 执行顺序

系统会自动解析依赖并按以下顺序执行：

```
xcode → homebrew → zsh → ohmyzsh → dotfiles
                 ↘ brewfile
```

## 💡 功能特性

- ✅ **模块化插件系统** - 每个任务独立，易于维护
- ✅ **自动依赖管理** - 拓扑排序确保正确执行顺序
- ✅ **循环依赖检测** - 自动检测并报错
- ✅ **幂等性设计** - 安全地多次运行
- ✅ **--dry-run 模式** - 预览而不实际执行
- ✅ **优雅的错误处理** - 清晰的错误信息
- ✅ **彩色输出** - 友好的用户界面
- ✅ **调试模式** - 详细的执行日志
- ✅ **备份机制** - 修改前自动备份

## 📖 使用示例

### 在新 Mac 上初始化

```bash
# 1. 克隆仓库
git clone <your-repo> ~/dotfiles
cd ~/dotfiles

# 2. 先预览（推荐）
./bootstrap.sh --dry-run

# 3. 确认无误后执行
./bootstrap.sh
```

### 调试模式

```bash
# 显示详细的执行日志
./bootstrap.sh --debug --dry-run
```

### 完全自动化

```bash
# 跳过所有确认提示
./bootstrap.sh --skip-confirmation
```

### 出错后继续

```bash
# 即使某个插件失败也继续执行
./bootstrap.sh --continue-on-error
```

## 🔧 创建自定义插件

创建新插件非常简单：

### 1. 创建插件文件

```bash
touch bootstrap.d/plugins/07-myapp.sh
chmod +x bootstrap.d/plugins/07-myapp.sh
```

### 2. 编写插件内容

```bash
#!/usr/bin/env bash

PLUGIN_NAME="myapp"
PLUGIN_DEPENDS="homebrew"  # 声明依赖
PLUGIN_DESCRIPTION="Install my custom application"

plugin_myapp_main() {
    log_step "Installing My App"
    
    # 检查是否已安装（幂等性）
    if command_exists myapp; then
        log_success "My App already installed"
        return 0
    fi
    
    # 执行安装
    log_info "Installing My App..."
    brew install myapp
    
    log_success "My App installed"
    return 0
}
```

### 3. 测试新插件

```bash
./bootstrap.sh --list | grep -A 3 myapp
./bootstrap.sh --dry-run
```

## 📚 可用的工具函数

在插件中可以使用以下函数（来自 `bootstrap.d/lib/utils.sh`）：

### 日志函数
- `log_info "message"` - 蓝色信息
- `log_success "message"` - 绿色成功
- `log_warning "message"` - 黄色警告
- `log_error "message"` - 红色错误
- `log_debug "message"` - 紫色调试（需要 --debug）
- `log_step "message"` - 青色步骤标题

### 检查函数
- `command_exists <command>` - 检查命令是否存在
- `is_macos` - 检查是否为 macOS
- `is_root` - 检查是否为 root 用户
- `ensure_not_root` - 确保不是 root 运行

### 交互函数
- `ask_confirmation "prompt" [y/n]` - 询问用户确认

### 文件操作
- `backup_file <file>` - 备份文件（带时间戳）
- `safe_symlink <source> <target>` - 安全创建符号链接（自动备份）

## 🏗️ 系统架构

```
dotfiles/
├── bootstrap.sh                    # 主入口脚本 ✅
├── Brewfile                        # Homebrew 包列表
├── bootstrap.d/
│   ├── lib/
│   │   ├── utils.sh                # 工具函数
│   │   └── plugin_system.sh        # 插件系统核心
│   ├── plugins/
│   │   ├── 01-xcode.sh             # Xcode CLI Tools
│   │   ├── 02-homebrew.sh          # Homebrew
│   │   ├── 03-zsh.sh               # Zsh shell
│   │   ├── 04-ohmyzsh.sh           # Oh My Zsh
│   │   ├── 05-brewfile.sh          # Brewfile 安装
│   │   └── 06-dotfiles.sh          # Dotfiles 符号链接
│   └── README.md
└── zsh/
    ├── .zshrc                       # 主配置文件
    └── rc.d/                        # 模块化配置
        ├── dot.zsh                  # dot 命令
        ├── homebrew.sh
        ├── nvm.zsh
        └── ...
```

## 🎯 典型工作流程

### 首次在新 Mac 上运行

```bash
# 步骤 1: 预览
./bootstrap.sh --dry-run

# 步骤 2: 执行（会有确认提示）
./bootstrap.sh

# 步骤 3: 重新加载 shell
source ~/.zshrc
```

### 更新现有系统

```bash
# 更新 Brewfile
./bootstrap.sh --dry-run  # 查看会安装什么

# 只运行特定插件（手动方式）
bash -c '
source bootstrap.d/lib/utils.sh
source bootstrap.d/lib/plugin_system.sh
load_plugins bootstrap.d/plugins
source bootstrap.d/plugins/05-brewfile.sh
plugin_brewfile_main
'
```

## 🐛 故障排除

### 问题：插件加载失败

```bash
# 使用调试模式查看详情
./bootstrap.sh --debug --list
```

### 问题：某个插件失败

```bash
# 继续执行其他插件
./bootstrap.sh --continue-on-error
```

### 问题：Brewfile 安装时间太长

这是正常的，Brewfile 包含 90+ 个包，可能需要 30-60 分钟。
可以编辑 `Brewfile` 移除不需要的包。

## 📝 注意事项

1. **首次运行前备份** - 虽然脚本会自动备份，但建议先备份重要配置
2. **网络连接** - 确保网络稳定，安装过程需要下载大量软件
3. **磁盘空间** - 确保至少有 10GB 可用空间
4. **执行时间** - 完整安装可能需要 30-60 分钟
5. **sudo 密码** - 某些操作需要输入密码（Xcode、zsh shell 切换）

## ✨ 下一步

1. ✅ 在虚拟机或测试 Mac 上运行 dry-run
2. ✅ 根据需要编辑 Brewfile
3. ✅ 添加自定义插件
4. ✅ 在新 Mac 上实际运行
5. ✅ 提交到 Git 仓库

## 🎉 总结

你的 bootstrap 系统已经完全可用！所有功能都经过测试：

- ✅ `./bootstrap.sh --list` - 列出插件
- ✅ `./bootstrap.sh --dry-run` - 预览执行
- ✅ `./bootstrap.sh --help` - 显示帮助
- ✅ `./bootstrap.sh --debug` - 调试模式
- ✅ 插件依赖自动解析
- ✅ 循环依赖检测
- ✅ 幂等性保证
- ✅ 友好的用户界面

享受你的自动化 macOS 设置体验！🚀
