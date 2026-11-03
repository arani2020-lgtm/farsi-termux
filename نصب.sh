#!/data/data/com.termux/files/usr/bin/bash
# نصب سریع محیط فارسی ترموکس
set -e
echo "▸ نصب پک..."
cp pak.sh   "$PREFIX/bin/پک"        && chmod 755 "$PREFIX/bin/پک"
cp fars.sh  "$PREFIX/bin/فارس"      && chmod 755 "$PREFIX/bin/فارس"
cp githubbazkon.sh "$PREFIX/bin/گیت‌بازکن" && chmod 755 "$PREFIX/bin/گیت‌بازکن"
[ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" "$HOME/.bashrc.bak"
echo "▸ نصب محیط فارسی..."
cp bashrc.sh "$HOME/.bashrc"        && chmod 755 "$HOME/.bashrc"
echo "✓ نصب کامل شد. ترمینال را ببندید و دوباره باز کنید، یا اجرا کنید: source ~/.bashrc"
