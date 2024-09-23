# User32.dllから関数を読み込む
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class WinAPI {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr GetForegroundWindow();

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

        public struct RECT {
            public int Left;
            public int Top;
            public int Right;
            public int Bottom;
        }
    }
"@

# 仮想キーコードの定義
$VK_MENU = 0x12  # Altキー
$VK_TAB = 0x09   # Tabキー
$KEYEVENTF_KEYDOWN = 0x0000
$KEYEVENTF_KEYUP = 0x0002

# user32.dllのkeybd_event関数をインポート
Add-Type -Namespace Win32 -Name Keyboard -MemberDefinition @"
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, uint dwExtraInfo);
"@

# Altキーを押す
[Win32.Keyboard]::keybd_event($VK_MENU, 0, $KEYEVENTF_KEYDOWN, 0)
Start-Sleep -Milliseconds 50  # 少し待機

# Tabキーを押す
[Win32.Keyboard]::keybd_event($VK_TAB, 0, $KEYEVENTF_KEYDOWN, 0)
Start-Sleep -Milliseconds 50  # 少し待機

# Tabキーを離す
[Win32.Keyboard]::keybd_event($VK_TAB, 0, $KEYEVENTF_KEYUP, 0)
Start-Sleep -Milliseconds 50  # 少し待機

# Altキーを離す
[Win32.Keyboard]::keybd_event($VK_MENU, 0, $KEYEVENTF_KEYUP, 0)
Start-Sleep -Milliseconds 50

# アクティブウィンドウを取得
$hwnd = [WinAPI]::GetForegroundWindow()

# 現在のウィンドウの位置とサイズを取得
$rect = New-Object WinAPI+RECT
[WinAPI]::GetWindowRect($hwnd, [ref]$rect) | Out-Null

# 現在の位置を保持し、サイズだけを1440x900に変更
$left = $rect.Left
$top = $rect.Top
$width = $rect.Right - $rect.Left
$height = $rect.Bottom - $rect.Top

# ウィンドウ位置とサイズのデバッグ出力
Write-Host "Current Position: X=$left, Y=$top, Width=$width, Height=$height"

# サイズのみを変更（1440x900）
[WinAPI]::MoveWindow($hwnd, $left, $top, 1440, 900, $true)
