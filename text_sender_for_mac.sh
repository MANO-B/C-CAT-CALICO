#!/bin/bash

# how to use
# FILE="main.py"
# xxd -p $FILE | tr '0-9' 'g-p' | split -b 1000 - p
# 
# bash send_all.sh
# 
# after copy
# 復元手順
# cat p?? > all_parts.txt
# cat all_parts.txt | tr 'g-p' '0-9' | xxd -r -p > main.py

DELAY=0.02

echo "=== 【最終確認版】マルチハッシュ照合転送 ==="
echo "Linux側での改行コードの変化（LF/CRLF）を考慮し、"
echo "あり得る『正解ハッシュ』のパターンを全て表示します。"
echo ""

for f in p??; do
    echo "------------------------------------------------"
    echo "ファイル [$f] を転送します。"
    echo "【正解ハッシュリスト】(どれかと一致すればOK)"
    
    # パターンA: そのまま (LF)
    CS_RAW=$(cksum "$f" | awk '{print $1, $2}')
    echo "  1. [そのままだと] : $CS_RAW"

    # パターンB: 末尾に改行が1つ増えた場合 (LF + \n) ※今回のヒアドキュメントでよくあるケース
    CS_LF=$( (cat "$f"; echo) | cksum | awk '{print $1, $2}')
    echo "  2. [末尾改行あり] : $CS_LF  (★推奨)"

    # パターンC: 改行がCRLFに変わった場合 (Windows/VDI変換)
    # perlを使って改行をCRLFに変換して計算
    CS_CRLF=$(perl -pe 's/\n/\r\n/' "$f" | cksum | awk '{print $1, $2}')
    echo "  3. [CRLFに変化 ] : $CS_CRLF"

    # パターンD: CRLF化 + 末尾改行
    CS_CRLF_ADD=$( (cat "$f"; echo) | perl -pe 's/\n/\r\n/' | cksum | awk '{print $1, $2}')
    echo "  4. [CRLF + 末尾] : $CS_CRLF_ADD"

    echo "------------------------------------------------"
    
    read -p "Enterで開始 (s=スキップ)... " choice
    if [ "$choice" = "s" ]; then continue; fi

    echo "3秒後に開始..."
    sleep 3

    CONTENT=$(cat "$f")

    osascript <<EOF
    tell application "System Events"
        -- 1. 開始前のEnter空打ち
        keystroke return
        delay 0.5
        
        -- 2. コマンド入力 (cat <<rrr > filename)
        set cmd to "cat <<rrr > $f"
        repeat with char in cmd
            keystroke char
            delay 0.1
        end repeat
        keystroke return
        delay 0.8

        -- 3. 中身を入力 (a-pのみ)
        set theString to "$CONTENT"
        repeat with char in theString
            keystroke char
            delay $DELAY
        end repeat
        delay 0.5
        
        -- 改行して終了合図
        keystroke return
        delay 0.2
        keystroke "rrr"
        keystroke return
        
        -- 保存完了待ち
        delay 1.0

        -- 4. 確認コマンド (cksum filename)
        -- 数字・記号を使わない一番安全な確認コマンド
        set checkCmd to "cksum $f"
        repeat with char in checkCmd
            keystroke char
            delay 0.1
        end repeat
        keystroke return
    end tell
EOF

    echo ""
    echo "★ Linux画面の cksum 結果が、上のリスト(1〜4)のどれかと一致しましたか？"
done

