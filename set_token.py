import re
import sys

def update_token(token):
    file_path = "bot.py"
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        # 使用更稳健的正则替换 Token
        new_content, count = re.subn(r'TOKEN\s*=\s*["\'].*?["\']', f'TOKEN = "{token}"', content)
        
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(new_content)
        
        print(f"Token 注入成功，替换次数: {count}")
    except Exception as e:
        print(f"Token 注入失败: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        update_token(sys.argv[1])
    else:
        print("未提供 Token 参数")
        sys.exit(1)
