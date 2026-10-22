#!/bin/bash

# 确保以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "❌ 请使用 root 权限运行此命令 (sudo tbot)"
  exit 1
fi

INSTALL_DIR="/root/my_pure_calc_bot"

while true; do
  clear
  echo "=================================================="
  echo " 🤖 Telegram 纯净计算机器人 - 管理面板"
  echo "=================================================="
  echo " 1) 查看运行状态 (status)"
  echo " 2) 查看实时日志 (logs)"
  echo " 3) 重启机器人 (restart)"
  echo " 4) 停止机器人 (stop)"
  echo " 5) 启动机器人 (start)"
  echo " 6) 修改 Bot Token (change token)"
  echo " 7) 一键卸载机器人 (uninstall)"
  echo " 0) 退出菜单 (exit)"
  echo "=================================================="
  read -p "请输入选项数字 [0-7]: " choice

  case $choice in
    1)
      echo "--------------------------------------------------"
      sudo systemctl status telegram-calc-bot
      echo "--------------------------------------------------"
      read -p "按回车键继续..."
      ;;
    2)
      echo "--------------------------------------------------"
      echo "正在查看实时日志 (按 Ctrl+C 退出日志)..."
      echo "--------------------------------------------------"
      sudo journalctl -u telegram-calc-bot -f
      ;;
    3)
      echo "正在重启机器人..."
      sudo systemctl restart telegram-calc-bot
      echo "✅ 重启完成！"
      sleep 1
      ;;
    4)
      echo "正在停止机器人..."
      sudo systemctl stop telegram-calc-bot
      echo "⏹️ 机器人已停止。"
      sleep 1
      ;;
    5)
      echo "正在启动机器人..."
      sudo systemctl start telegram-calc-bot
      echo "🚀 机器人已启动。"
      sleep 1
      ;;
    6)
      echo "--------------------------------------------------"
      read -p "请输入新的 Telegram Bot Token: " NEW_TOKEN
      if [ -z "$NEW_TOKEN" ] || [[ "$NEW_TOKEN" != *":"* ]]; then
        echo "❌ 错误：输入的 Token 格式不正确！"
      else
        if [ -d "$INSTALL_DIR" ] && [ -f "$INSTALL_DIR/bot.py" ]; then
          python3 -c "
with open('$INSTALL_DIR/bot.py', 'r', encoding='utf-8') as f:
    content = f.read()
import re
new_content = re.sub(r'TOKEN\s*=\s*[\"'].*?[\"']', f'TOKEN = \"{NEW_TOKEN}\"', content)
with open('$INSTALL_DIR/bot.py', 'w', encoding='utf-8') as f:
    f.write(new_content)
"
          echo "⚙️ Token 已更新，正在重启机器人..."
          sudo systemctl restart telegram-calc-bot
          echo "✅ Token 修改成功并已重新启动！"
        else
          echo "❌ 未检测到机器人安装目录 ($INSTALL_DIR)，请先安装！"
        fi
      fi
      echo "--------------------------------------------------"
      read -p "按回车键继续..."
      ;;
    7)
      read -p "⚠️ 确定要彻底卸载机器人吗？(y/N): " confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        bash <(curl -s https://raw.githubusercontent.com/jianweicai0505/telegram_bot/main/install.sh) --uninstall
        exit 0
      else
        echo "已取消卸载。"
        sleep 1
      fi
      ;;
    0)
      echo "再见！"
      exit 0
      ;;
    *)
      echo "❌ 无效的选项，请重新输入！"
      sleep 1
      ;;
  esac
done
