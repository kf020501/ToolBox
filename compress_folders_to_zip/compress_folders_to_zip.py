import os
import sys
import zipfile
from datetime import datetime

# ZIPが対応可能な最も古い日時
ZIP_MIN_TIMESTAMP = datetime(1980, 1, 1).timestamp()

def compress_folder(folder_path):
    # フォルダの絶対パスを取得
    folder_path = os.path.abspath(folder_path)
    
    # フォルダ名を取得
    folder_name = os.path.basename(folder_path)
    
    # zipファイルの保存先パス
    zip_path = os.path.join(os.path.dirname(folder_path), f"{folder_name}.zip")
    
    # 圧縮処理
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(folder_path):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, folder_path)
                try:
                    zipf.write(file_path, arcname)
                except ValueError:
                    # タイムスタンプを1980年1月1日に設定
                    os.utime(file_path, (ZIP_MIN_TIMESTAMP, ZIP_MIN_TIMESTAMP))
                    zipf.write(file_path, arcname)
    print(f"Compressed '{folder_path}' to '{zip_path}'")

if __name__ == "__main__":
    # コマンドライン引数でフォルダパスを受け取る
    if len(sys.argv) < 2:
        print("Usage: python script.py <folder_path1> <folder_path2> ...")
        sys.exit(1)
    
    folder_paths = sys.argv[1:]
    
    for folder_path in folder_paths:
        if os.path.isdir(folder_path):
            compress_folder(folder_path)
        else:
            print(f"'{folder_path}' is not a valid directory.")
