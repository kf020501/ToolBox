#!/usr/bin/env python3

import os           # Main
import sys          # Main,正規表現で置換
import string       # MakeRandomFile
import random       # MakeRandomFile
import re           # MakeRandomFile

# ----------------------------------------
#  変数初期化 ---> 対話型 or 非対話型
# ----------------------------------------

def Main():

    # ---------- 変数初期値 ----------

    num = int(10)                  # ファイル作成個数
    size = int(10 * 1024 ** 2)      # ファイル容量
    dir = str(os.getcwd())          # 出力先ディレクトリ
    info = False                    # 進捗度を通知するか

    # ---------- 引数の処理 ----------
    # 受け取った引数(sys.argv)がないなら対話処理、あるなら対話なし処理 

    args_len = len(sys.argv)    # 配列の個数を取得

    if args_len == 1:           # 引数(sys.argv)がないので対話処理
        InteractiveMenu(num, size, dir, info) 
    # else:
    #     def foo(num, size, dir, info):  # 非対話処理を開始


#----------------------------------------
# 対話式メインメニュー 
#----------------------------------------

def InteractiveMenu(num, size, dir, info):

    while True:

        # ---------- メニューの表示 ----------

        print('\n----------------------------------------' + \
            '\n1) ファイル作成個数:    ' + "{:,}".format(num) + \
            '\n2) ファイルサイズ:      ' +"{:,}".format(size) + \
            '\n3) 出力ディレクトリ:    ' + str(dir) + \
            '\n\n0) ファイル作成'
            '\nq) 終了'
            '\n----------------------------------------\n')

        input_number = input('番号を入力してください:')

        # ---------- 入力された値に応じて関数を実行 ----------

        if input_number == "1":
            num = Input_num(num)
        elif input_number == "2":
            size = Input_size(size)
        elif input_number == "3":
            dir =Input_dir(dir)
        elif input_number == "0":
            info = True
            MakeRandomFile(num, size, str(dir), info)
            input('\nPress Enter...')
            break
        elif input_number == "q":
            exit()
#----------------------------------------
# 対話式 変数入力処理   
#----------------------------------------

# ---------- ファイル作成個数 変更 ----------

def Input_num(num):
    
    while True: # ループ

        input_var = input('\nファイル作成個数を入力してください:')

        # ----- 入力がなければ、受け取った値をそのまま返す -----
        if input_var == '':
            return num

        # ----- エラーチェック -----
        # 問題なければ入力値を返す
        try:
            return int(input_var) 
        except ValueError:  # try で数値エラーが発生した場合
            print('ERROR: 数値を入力してください')
            continue
        else:
            break   # try でエラーがなければ(numが数値なら)ループを抜ける

# ---------- ファイルサイズ 変更 ----------

def Input_size(size):
    
    while True: # ループ

        print('\nファイルサイズを入力してください')
        print('例: 1024 (1KB) / 10 * 1024 (10KB)/ 10 * 1024 ** 3 (10GB)')
        input_var = input(':')

        # ----- 入力がなければ、受け取った値をそのまま返す -----
        if input_var == '':
            return size

        # ----- エラーチェック -----
        # 問題なければ入力値を返す
        try:
            return int(eval(input_var))     # eval で入力された値を計算できる
        except:  # try で数値エラーが発生した場合
            print('ERROR: 数値を入力してください')
            continue
        else:
            break   # try でエラーがなければ(sizeが数値なら)ループを抜ける

# ---------- ディレクトリ変更 ----------

def Input_dir(dir):
    
    while True: # ループ

        input_var = input('\n保存先ディレクトリを入力してください: ')

        # Windowsで「パスのコピー」すると「"」がついてしまうので、事前に削除して対応
        input_var = input_var.replace('"','')   
        
        # ----- 入力がなければ、受け取った値をそのまま返す -----
        if input_var == '':
            return dir

        if os.path.isdir(input_var) == True:
            return input_var
            print('指定したディレクトリは参照出来ます')
        else:
            print('ERROR: 指定したディレクトリが参照できません')


#----------------------------------------
# ランダムファイルの作成処理
#----------------------------------------

def MakeRandomFile(num, size, dir, info):

    # 半角英英字 + 半角数字 + 記号 (あとでここからランダムで拾う)
    chars = string.ascii_letters + string.digits + string.punctuation

    numlen = len(str(num))      # 作成するファイル数(num)の桁数を取得
    size_per = 1 * 1024 ** 2    # 1回の書き込みサイズ数を設定(1MB)

    # ---------- ファイル数(num)分繰り返し ----------

    for i in range(num):
        
        if info == True:                                        # infoがTrueなら、進捗状態を出力 処理個数/合計個数 - 書き込みサイズ
            print("\r" + "{:,}".format(i+1) + " / " + "{:,}".format(num), end="")

        filename = dir + '/random_' + str(i+1).zfill(numlen)    # ファイル名生成 「指定したDir/randam0000xx」(数字はゼロ埋め)
        remaining = size                                        # 残り書き込みサイズ(remaining)を生成

        # ----- 残り書き込みサイズが１MBより大きい場合、1Mずつ書き込み -----

        with open(filename, "w") as writtenfile:  # 書き込みモード(w)でファイル(filename)を開く ---> writtenfile

            while True: # ループ

                # 残り書き込みサイズが1回の書き込みサイズ(size_per)より大きい場合
                if remaining > size_per:
                    randomchars = ''.join(random.choices(chars, k=size_per))    # 1回の書き込みサイズ(size_per)分のランダム文字列(randomchars)を生成
                    writtenfile.write(randomchars)                              # ランダム文字列(randomchars)をファイル(writtenfile)に書き込み
                    remaining -= size_per                                       # 残り書き込みサイズ(remaining) から 1回の書き込みサイズ(size_per)を引く

                # 残り書き込みサイズが1回の書き込みサイズ(size_per)以下の場合
                else:
                    randomchars = ''.join(random.choices(chars, k=remaining))   # 残り書き込みサイズ(size_per)分のランダム文字列(randomchars)を生成
                    writtenfile.write(randomchars)                              # ランダム文字列(randomchars)をファイル(writtenfile)に書き込み
                    break

Main()

# x = input('作成するファイル個数を入力してください[100]:')
# num = int(x) 
# print(type(num))
# print(num)

# ----------