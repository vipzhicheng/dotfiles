# 单独执行插件 - 使用指南

## 快速开始

### 方法一：使用快捷脚本（推荐）

```bash
# 最常用：更新 Brewfile 包
./run-plugin.sh brewfile

# 预览会做什么
./run-plugin.sh brewfile --dry-run

# 只更新 dotfiles 符号链接（跳过依赖）
./run-plugin.sh dotfiles --only

# 查看帮助
./run-plugin.sh --help
```

### 方法二：使用 bootstrap.sh

```bash
# 运行单个插件（包含依赖）
./bootstrap.sh --plugin <plugin-name>

# 只运行插件本身（跳过依赖）
./bootstrap.sh --plugin-only <plugin-name>

# 预览模式
./bootstrap.sh --plugin <plugin-name> --dry-run
```

## 可用插件

| 插件名 | 描述 | 依赖 | 常见使用场景 |
|--------|------|------|--------------|
| `xcode` | 安装 Xcode CLI Tools | 无 | 首次设置、系统更新后 |
| `homebrew` | 安装/更新 Homebrew | xcode | 很少需要单独运行 |
| `zsh` | 安装/更新 Zsh | homebrew | 更新到最新版 Zsh |
| `ohmyzsh` | 安装/更新 Oh My Zsh | zsh | 更新 Oh My Zsh 和插件 |
| `brewfile` | 从 Brewfile 安装包 | homebrew | **最常用**：安装新软件 |
| `dotfiles` | 创建符号链接 | ohmyzsh | 修改配置文件后 |

## 常见使用场景

### 1. 日常：添加新软件到 Brewfile 后安装

```bash
# 1. 编辑 Brewfile，添加新包
vim Brewfile

# 2. 预览会安装什么
./run-plugin.sh brewfile --dry-run

# 3. 确认后安装
./run-plugin.sh brewfile
```

### 2. 更新 dotfiles 配置

```bash
# 修改配置文件后，重新创建符号链接
./run-plugin.sh dotfiles --only

# 或者带依赖（确保 Oh My Zsh 是最新的）
./run-plugin.sh dotfiles
```

### 3. 更新 Oh My Zsh

```bash
# 更新 Oh My Zsh 框架和插件
./run-plugin.sh ohmyzsh
```

### 4. 调试某个插件

```bash
# 使用 debug 模式查看详细日志
BOOTSTRAP_DEBUG=true ./bootstrap.sh --plugin brewfile --dry-run
```

### 5. 强制重新安装（即使已安装）

大多数插件会检查是否已安装，如果需要强制重新安装：

```bash
# 示例：重新安装 Homebrew（小心使用）
./bootstrap.sh --plugin-only homebrew
```

## 详细示例

### 示例 1：更新 Brewfile（最常用）

```bash
# 场景：你添加了新的工具到 Brewfile

# 步骤 1：编辑 Brewfile
echo 'brew "ripgrep"' >> Brewfile

# 步骤 2：预览（推荐）
./run-plugin.sh brewfile --dry-run

# 步骤 3：执行安装
./run-plugin.sh brewfile

# 这会自动：
# 1. 确保 Xcode CLI Tools 已安装
# 2. 确保 Homebrew 已安装
# 3. 运行 brew bundle install
```

### 示例 2：只更新 dotfiles 符号链接

```bash
# 场景：你修改了 .zshrc，想重新链接

# 使用 --only 跳过依赖检查（更快）
./run-plugin.sh dotfiles --only

# 或者用完整命令
./bootstrap.sh --plugin-only dotfiles
```

### 示例 3：重新安装 Oh My Zsh 插件

```bash
# 场景：Oh My Zsh 插件出问题了

# 运行 ohmyzsh 插件会重新安装插件
./run-plugin.sh ohmyzsh
```

## 与完整 bootstrap 的区别

### 完整 bootstrap（首次设置）

```bash
./bootstrap.sh
```

- 安装所有插件
- 按依赖顺序执行
- 用于新机器初始化

### 单独插件（日常维护）

```bash
./run-plugin.sh brewfile
```

- 只运行指定插件（和它的依赖）
- 更快、更精确
- 用于日常更新和调试

## 技巧和最佳实践

### 1. 先 dry-run，后执行

```bash
# 好习惯：先看看会做什么
./run-plugin.sh brewfile --dry-run

# 确认无误后再执行
./run-plugin.sh brewfile
```

### 2. 使用 --only 加速

如果你确定依赖已满足：

```bash
# 慢（检查所有依赖）
./bootstrap.sh --plugin dotfiles

# 快（直接运行）
./bootstrap.sh --plugin-only dotfiles
```

### 3. 结合 debug 模式

```bash
# 查看详细执行过程
BOOTSTRAP_DEBUG=true ./run-plugin.sh brewfile --dry-run
```

### 4. 批量操作

```bash
# 更新多个插件
./run-plugin.sh ohmyzsh && ./run-plugin.sh dotfiles
```

## 创建自定义插件后使用

假设你创建了新插件 `07-myapp.sh`：

```bash
# 列出所有插件（验证新插件已加载）
./bootstrap.sh --list

# 测试新插件
./run-plugin.sh myapp --dry-run

# 执行新插件
./run-plugin.sh myapp
```

## 快捷脚本参数

### run-plugin.sh 语法

```bash
./run-plugin.sh <plugin-name> [options]

Options:
  --dry-run, -d    预览不执行
  --only, -o       跳过依赖
  --help, -h       显示帮助
```

### 示例组合

```bash
# 预览 + 跳过依赖
./run-plugin.sh dotfiles -d -o

# 等价于
./bootstrap.sh --plugin-only dotfiles --dry-run
```

## 故障排除

### 问题：插件找不到

```bash
# 列出所有可用插件
./bootstrap.sh --list

# 或
./run-plugin.sh --help
```

### 问题：权限错误

```bash
# 某些操作需要 sudo（脚本会自动提示）
# 不要用 sudo 运行整个脚本！
./run-plugin.sh xcode  # 脚本会在需要时要求密码
```

### 问题：想看详细日志

```bash
# 启用调试模式
BOOTSTRAP_DEBUG=true ./run-plugin.sh brewfile
```

## 总结

**最常用命令**：

```bash
# 1. 更新软件包（90% 的使用场景）
./run-plugin.sh brewfile

# 2. 更新配置链接
./run-plugin.sh dotfiles --only

# 3. 预览任何操作
./run-plugin.sh <plugin> --dry-run
```

**记住**：
- 日常维护用 `./run-plugin.sh`
- 新机器设置用 `./bootstrap.sh`
- 不确定就先 `--dry-run`
