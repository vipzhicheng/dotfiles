# Dotfiles

我的 macOS 开发环境配置和自动化设置系统。

## 🚀 快速开始

### 新机器初始化

```bash
# 克隆仓库
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

# 预览会做什么（推荐）
./bootstrap.sh --dry-run

# 执行完整安装
./bootstrap.sh
```

### 日常使用

```bash
# 最常用：更新软件包
./run-plugin.sh brewfile

# 更新配置文件链接
./run-plugin.sh dotfiles --only

# 查看所有插件
./bootstrap.sh --list
```

## 📚 文档

- **[TEST_BOOTSTRAP.md](TEST_BOOTSTRAP.md)** - Bootstrap 系统完整说明
- **[PLUGIN_USAGE.md](PLUGIN_USAGE.md)** - 单独执行插件指南（日常使用）
- **[bootstrap.d/README.md](bootstrap.d/README.md)** - 插件系统架构和创建新插件

## 📦 包含内容

### Bootstrap 系统

模块化的 macOS 初始化系统，基于插件架构：

- ✅ **自动依赖管理** - 插件按依赖顺序执行
- ✅ **幂等性设计** - 安全地多次运行
- ✅ **Dry-run 模式** - 预览不执行
- ✅ **单独执行插件** - 日常维护和调试
- ✅ **优雅的错误处理** - 清晰的日志和错误信息

### 核心插件

1. **xcode** - Xcode Command Line Tools
2. **homebrew** - Homebrew 包管理器  
3. **zsh** - Zsh shell（确保最新版本）
4. **ohmyzsh** - Oh My Zsh + 常用插件
5. **brewfile** - 从 Brewfile 安装 90+ 个工具
6. **dotfiles** - 配置文件符号链接

### Zsh 配置

- 模块化配置系统（`zsh/rc.d/`）
- `dot` 命令用于加载配置片段
- 支持 `.zshrc.local` 本地定制
- 包含各种开发工具配置

## 🎯 常用命令

### Bootstrap 命令

```bash
# 完整安装（新机器）
./bootstrap.sh

# 预览执行计划
./bootstrap.sh --dry-run

# 列出所有插件
./bootstrap.sh --list

# 运行特定插件（含依赖）
./bootstrap.sh --plugin brewfile

# 只运行插件本身（跳过依赖）
./bootstrap.sh --plugin-only dotfiles

# 查看帮助
./bootstrap.sh --help
```

### 快捷命令（推荐日常使用）

```bash
# 更新软件包（最常用）
./run-plugin.sh brewfile

# 预览会安装什么
./run-plugin.sh brewfile --dry-run

# 更新配置链接
./run-plugin.sh dotfiles --only

# 查看帮助
./run-plugin.sh --help
```

## 🛠️ 自定义

### 添加新软件

编辑 `Brewfile`，然后运行：

```bash
./run-plugin.sh brewfile
```

### 添加自定义插件

1. 创建插件文件：`bootstrap.d/plugins/07-myapp.sh`
2. 定义元数据和主函数（参考现有插件）
3. 测试：`./bootstrap.sh --plugin myapp --dry-run`

详见 [bootstrap.d/README.md](bootstrap.d/README.md)

### 本地配置

创建 `~/.zshrc.local` 添加个人定制（不会提交到 Git）。

## 📋 项目结构

```
dotfiles/
├── bootstrap.sh              # 主入口
├── run-plugin.sh             # 快捷执行插件
├── Brewfile                  # Homebrew 包列表
├── bootstrap.d/
│   ├── lib/                  # 核心库
│   │   ├── utils.sh          # 工具函数
│   │   └── plugin_system.sh  # 插件系统
│   └── plugins/              # 插件目录
│       ├── 01-xcode.sh
│       ├── 02-homebrew.sh
│       ├── 03-zsh.sh
│       ├── 04-ohmyzsh.sh
│       ├── 05-brewfile.sh
│       └── 06-dotfiles.sh
└── zsh/
    ├── .zshrc                # 主配置
    └── rc.d/                 # 模块化配置
        ├── dot.zsh           # dot 命令
        ├── homebrew.sh
        ├── nvm.zsh
        └── ...
```

## 🔧 要求

- macOS (测试版本: 26.2+)
- 网络连接
- 至少 10GB 磁盘空间
- 30-60 分钟安装时间（首次）

## 💡 使用技巧

1. **先 dry-run**：任何操作前先用 `--dry-run` 预览
2. **日常用 run-plugin.sh**：比完整 bootstrap 更快
3. **调试用 --debug**：`BOOTSTRAP_DEBUG=true ./bootstrap.sh --list`
4. **本地定制用 .zshrc.local**：不影响主配置文件

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 License

MIT

---

**快速参考**：

```bash
# 新机器
./bootstrap.sh --dry-run && ./bootstrap.sh

# 更新软件
./run-plugin.sh brewfile

# 更新配置
./run-plugin.sh dotfiles --only
```
