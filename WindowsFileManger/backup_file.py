import os
import sys
import shutil
from datetime import datetime

def backup_file(file_path):
    # ファイルの絶対パスを取得
    file_path = os.path.abspath(file_path)
    
    # ファイルが存在するかチェック
    if not os.path.isfile(file_path):
        print(f"'{file_path}' is not a valid file.")
        return
    
    # ファイルのディレクトリとファイル名を取得
    file_dir = os.path.dirname(file_path)
    file_name = os.path.basename(file_path)
    
    # ファイル名と拡張子を分離
    name, ext = os.path.splitext(file_name)
    
    # 現在の日付と時刻を取得
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # バックアップファイル名を作成
    backup_filename = f"{name}.{timestamp}bk{ext}"
    
    # bkディレクトリのパス
    backup_dir = os.path.join(file_dir, "bk")
    
    # bkディレクトリが存在しない場合は作成
    if not os.path.exists(backup_dir):
        os.makedirs(backup_dir)
    
    # バックアップファイルのフルパス
    backup_path = os.path.join(backup_dir, backup_filename)
    
    # ファイルをコピー
    try:
        shutil.copy2(file_path, backup_path)
        print(f"Backup created: '{backup_path}'")
    except Exception as e:
        print(f"Error creating backup: {e}")

if __name__ == "__main__":
    # コマンドライン引数でファイルパスを受け取る
    if len(sys.argv) < 2:
        print("Usage: python backup_file.py <file_path1> <file_path2> ...")
        sys.exit(1)
    
    file_paths = sys.argv[1:]
    
    for file_path in file_paths:
        backup_file(file_path)