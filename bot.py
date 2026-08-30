import logging
import os
import re
from telegram import Update
from telegram.ext import ApplicationBuilder, ContextTypes, CommandHandler, MessageHandler, filters

logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    level=logging.INFO
)

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(
        "你好！我是你的专属纯净计算机器人 🧮\n"
        "直接发送数学表达式（例如：`20+34*2`），我就会自动计算并回复你！"
    )

async def calculate(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not update.message or not update.message.text:
        return
        
    text = update.message.text.strip()
    
    allowed_chars = set("0123456789+-*/(). ")
    if not all(c in allowed_chars for c in text):
        return  

    if not re.search(r"\d", text) or not any(op in text for op in ["+", "-", "*", "/"]):
        return  

    try:
        result = eval(text, {"__builtins__": None}, {})
        await update.message.reply_text(
            f"✨ 计算结果：\n`{text} = {result}`", 
            parse_mode="Markdown",
            reply_to_message_id=update.message.message_id
        )
    except ZeroDivisionError:
        await update.message.reply_text("❌ 错误：除数不能为零！", reply_to_message_id=update.message.message_id)
    except Exception:
        pass

if __name__ == "__main__":
    # 填入占位符，由安装脚本在部署时自动替换
    TOKEN = "YOUR_BOT_TOKEN_HERE"
    
    if TOKEN == "YOUR_BOT_TOKEN_HERE":
        print("❌ 错误：请先配置正确的 Bot Token！")
        exit(1)
        
    app = ApplicationBuilder().token(TOKEN).build()
    
    app.add_handler(CommandHandler("start", start))
    app.add_handler(MessageHandler(filters.TEXT & (~filters.COMMAND), calculate))
    
    print("🤖 纯净计算机器人已启动并正在运行...")
    app.run_polling()