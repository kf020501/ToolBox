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

Start-Sleep 1

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
