#!/data/data/com.termux/files/usr/bin/env bash
# ============================================================
#  فارس v2.0 — ورود به پوستهٔ فارسی ترموکس
#  استفاده:  فارس          ورود به پوستهٔ فارسی
#            فارس --نصب    نصب کامل محیط فارسی
# ============================================================

# نصب خودکار در اولین اجرا
اگر_نصب_نیست() {
  [ -f "$HOME/.farsi-shell-installed" ]
}

if [ "${1:-}" = "--نصب" ] || اگر_نصب_نیست; then
  DIR="$(cd "$(dirname "$0")" && pwd)"
  if [ "${1:-}" = "--نصب" ]; then
    echo "▸ نصب محیط فارسی..."
    cp pak.sh "$PREFIX/bin/پک" && chmod 755 "$PREFIX/bin/پک"
    cp githubbazkon.sh "$PREFIX/bin/گیت‌بازکن" && chmod 755 "$PREFIX/bin/گیت‌بازکن"
    cp bashrc.sh "$HOME/.farsi-bashrc"
    touch "$HOME/.farsi-shell-installed"
    echo "✓ نصب شد. از این پس با دستور «فارس» وارد پوستهٔ فارسی شوید."
    exit 0
  fi
fi

# اجرای پوستهٔ فارسی (bashrc اصلی دست‌نخورده می‌ماند)
exec bash --rcfile "$HOME/.farsi-bashrc" -i "$@"
