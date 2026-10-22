import logging
import re
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import ApplicationBuilder, ContextTypes, CommandHandler, MessageHandler, CallbackQueryHandler, filters

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
    
    # 严格过滤：只允许数字、基本运算符、括号和小数点
    allowed_chars = set("0123456789+-*/(). ")
    if not all(c in allowed_chars for c in text):
        return  

    # 必须同时包含数字和至少一个运算符
    if not re.search(r"\d", text) or not any(op in text for op in ["+", "-", "*", "/"]):
        return  

    try:
        result = eval(text, {"__builtins__": None}, {})
        
        # 构造返回文本
        reply_text = f"✨ 计算结果：\n`{text} = {result}`"
        
        # 使用 callback_data，点击后直接由机器人发送结果文本供复制
        keyboard = [
            [InlineKeyboardButton(f"📋 获取结果文本: {result}", callback_data=f"copy_{result}")]
        ]
        reply_markup = InlineKeyboardMarkup(keyboard)

        await update.message.reply_text(
            reply_text, 
            parse_mode="Markdown",
            reply_markup=reply_markup,
            reply_to_message_id=update.message.message_id
        )
    except ZeroDivisionError:
        await update.message.reply_text("❌ 错误：除数不能为零！", reply_to_message_id=update.message.message_id)
    except Exception:
        pass

async def button_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer() # 确认收到点击事件，消除按钮转圈
    
    data = query.data
    if data.startswith("copy_"):
        val = data.split("_")[1]
        # 直接由机器人在对话中回复纯文本结果，方便长按复制
        await query.message.reply_text(f"📌 复制结果：`{val}`", parse_mode="Markdown")

if __name__ == "__main__":
    TOKEN = "YOUR_BOT_TOKEN_HERE"
    
    if TOKEN == "YOUR_BOT_TOKEN_HERE":
        print("❌ 错误：请先配置正确的 Bot Token！")
        exit(1)
        
    app = ApplicationBuilder().token(TOKEN).build()
    
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CallbackQueryHandler(button_callback))
    app.add_handler(MessageHandler(filters.TEXT & (~filters.COMMAND), calculate))
    
    print("🤖 纯净计算机器人已启动并正在运行...")
    app.run_polling()
