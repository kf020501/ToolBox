#!/usr/bin/env python3
import sys
import random

# 各種文字列の定義
lower = "abcdefghijklmnopqrstuvwxyz"
upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
digits = "0123456789"
symbols =   "-!#$%&()*,./:;?@[]^_`{|}~+<=>"

def generate_password(length: int) -> str:
    if length < 4:
        raise ValueError("パスワードの長さは最低でも4文字必要です。")
    
    # 1. 最初の1文字は lower+upper から選択
    first_char = random.choice(lower + upper)
    
    # 2. もう一方の大文字/小文字を選択（必ず両方含むため）
    if first_char in lower:
        second_char = random.choice(upper)
    else:
        second_char = random.choice(lower)
    
    # 3. 数字と記号からそれぞれ1文字ずつ選択
    digit_char = random.choice(digits)
    symbol_char = random.choice(symbols)
        
    # 4. 残りの文字数分、全グループからランダムに選ぶ
    extra_count = length - 4
    extra_chars = [random.choice(lower + upper + digits + symbols) for _ in range(extra_count)]
    
    # 5. 最初の1文字以外の文字をリストにしてシャッフル
    pwd_list = [second_char, digit_char, symbol_char] + extra_chars
    random.shuffle(pwd_list)
    
    # 6. 最初の一文字とシャッフルされた文字列を結合
    pwd = first_char + ''.join(pwd_list)

    return pwd


def get_interactive_input():
    """対話式でパスワードの文字数と個数を取得する関数"""
    try:
        inp = input("パスワードの文字数を入力してください [default: 10]: ")
        length = int(inp) if inp.strip() != "" else 10
    except ValueError:
        print("整数を入力してください。")
        sys.exit(1)
    try:
        inp = input("作成するパスワードの個数を入力してください [default: 1]: ")
        count = int(inp) if inp.strip() != "" else 1
    except ValueError:
        print("整数を入力してください。")
        sys.exit(1)
    return length, count


def main():
    interactive_mode = False
    # コマンドライン引数がある場合
    if len(sys.argv) >= 2:
        try:
            length = int(sys.argv[1])
        except ValueError:
            print("エラー: 1番目の引数は整数(パスワードの文字数)で指定してください。")
            sys.exit(1)
        count = 1
        if len(sys.argv) >= 3:
            try:
                count = int(sys.argv[2])
            except ValueError:
                print("エラー: 2番目の引数は整数(作成するパスワードの個数)で指定してください。")
                sys.exit(1)
    else:
        # 対話式モード
        length, count = get_interactive_input()
        interactive_mode = True

    try:
        passwords = [generate_password(length) for _ in range(count)]
    except ValueError as e:
        print("エラー:", e)
        sys.exit(1)

    for pwd in passwords:
        print(pwd)
    
    # 対話式モードの場合、最後にEnterを待つ
    if interactive_mode:
        input("\nEnterキーを押すと終了します...")

if __name__ == "__main__":
    main()
