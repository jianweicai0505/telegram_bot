#!/bin/bash

# 确保以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "❌ 请使用 root 权限运行此脚本 (sudo bash install.sh)"
  exit 1
fi

INSTALL_DIR="/root/my_pure_calc_bot"
SERVICE_FILE="/etc/systemd/system/telegram-calc-bot.service"

# ==========================================
# 卸载逻辑：如果传入了 --uninstall 参数
# ==========================================
if [ "$1" == "--uninstall" ]; then
  echo "=================================================="
  echo " 🗑️ 正在卸载 Telegram 纯净计算机器人..."
  echo "=================================================="

  # 1. 停止并禁用服务
  if systemctl is-active --quiet telegram-calc-bot; then
    echo "⏹️ 正在停止后台服务..."
    systemctl stop telegram-calc-bot
  fi

  if systemctl is-enabled --quiet telegram-calc-bot; then
    echo "🔌 正在取消开机自启..."
    systemctl disable telegram-calc-bot
  fi

  # 2. 删除 systemd 服务文件并重载
  if [ -f "$SERVICE_FILE" ]; then
    echo "🧹 正在清理系统服务配置..."
    rm -f "$SERVICE_FILE"
    systemctl daemon-reload
  fi

  # 3. 删除项目工作目录
  if [ -d "$INSTALL_DIR" ]; then
    echo "🗑️ 正在删除项目文件夹 ($INSTALL_DIR)..."
    rm -rf "$INSTALL_DIR"
  fi

  echo "=================================================="
  echo " ✅ 机器人已彻底卸载干净！"
  echo "=================================================="
  exit 0
fi

# ==========================================
# 安装逻辑：正常执行部署
# ==========================================
echo "=================================================="
echo " 🤖 纯净计算机器人 - 全自动交互式部署脚本 "
echo "=================================================="

# 1. 交互式输入 Token
read -p "请输入你的 Telegram Bot Token: " BOT_TOKEN
if [ -z "$BOT_TOKEN" ] || [[ "$BOT_TOKEN" != *":"* ]]; then
  echo "❌ 错误：输入的 Token 格式不正确！"
  exit 1
fi

# 创建或进入项目目录
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# 如果当前目录下没有 bot.py，从 GitHub 克隆
if [ ! -f "bot.py" ]; then
  echo "📥 正在从 GitHub 克隆项目代码..."
  git clone https://github.com/jianweicai0505/telegram_bot.git .
else
  echo "🔄 正在从 GitHub 同步最新代码..."
  git pull origin main
fi

# 2. 动态将用户输入的 Token 注入到 bot.py 中
echo "⚙️ 正在安全注入 Bot Token 配置..."
python3 -c "
with open('bot.py', 'r', encoding='utf-8') as f:
    content = f.read()

import re
new_content = re.sub(r'TOKEN\s*=\s*[\"'].*?[\"']', f'TOKEN = \"{BOT_TOKEN}\"', content)

with open('bot.py', 'w', encoding='utf-8') as f:
    f.write(new_content)
"

# 3. 安装系统依赖与虚拟环境
echo "📦 正在检查并安装系统依赖..."
apt update && apt install python3-pip python3-venv git -y

if [ ! -d "venv" ]; then
  echo "🔨 正在创建 Python 虚拟环境..."
  python3 -m venv venv
fi

echo "📚 正在安装 Python 依赖库..."
./venv/bin/pip install python-telegram-bot

# 4. 配置 Systemd 后台常驻与开机自启
echo "⚙️ 正在配置系统守护进程 (Systemd)..."
cat << EOF > "$SERVICE_FILE"
[Unit]
Description=Telegram Pure Calculation Bot
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/venv/bin/python $INSTALL_DIR/bot.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable telegram-calc-bot
systemctl restart telegram-calc-bot

echo "=================================================="
echo " 🎉 部署大功告成！纯净计算机器人已在后台稳定运行！"
echo "=================================================="
echo "常用管理命令："
echo "  • 查看运行状态: sudo systemctl status telegram-calc-bot"
echo "  • 查看实时日志: sudo journalctl -u telegram-calc-bot -f"
echo "  • 重启机器人:   sudo systemctl restart telegram-calc-bot"
echo "  • 一键卸载:     bash <(curl -s ...) --uninstall"
echo "=================================================="