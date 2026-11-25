#!/data/data/com.termux/files/usr/bin/env bash
# ============================================================
#  نصب سریع محیط فارسی ترموکس v2.0
#  استفاده: bash نصب.sh
# ============================================================
set -e

RED='\033[1;31m'; GREEN='\033[1;32m'; CYAN='\033[1;36m'; NC='\033[0m'
س()    { printf "${CYAN}▸ %s${NC}\n" "$*"; }
موفق() { printf "${GREEN}✓ %s${NC}\n" "$*"; }
خطا()  { printf "${RED}✗ %s${NC}\n" "$*"; exit 1; }

[ -n "${TERMUX_VERSION:-}" ] || خطا "این اسکریپت فقط داخل ترموکس اجرا می‌شود."

س "نصب دستور «پک» (مدیر بسته)..."
install -m 755 pak.sh "$PREFIX/bin/پک"

س "نصب دستور «گیت‌بازکن» (انتشار روی گیت‌هاب)..."
install -m 755 githubbazkon.sh "$PREFIX/bin/گیت‌بازکن"

س "نصب دستور «فارس» (پوستهٔ فارسی)..."
install -m 755 fars.sh "$PREFIX/bin/فارس"

س "نصب محیط فارسی..."
install -m 755 bashrc.sh "$HOME/.farsi-bashrc"

# bashrc اصلی دست‌نخورده می‌ماند؛ فقط یک خط اضافه می‌شود
if ! grep -q "farsi-bashrc" "$HOME/.bashrc" 2>/dev/null; then
  echo '[ -f "$HOME/.farsi-bashrc" ] && source "$HOME/.farsi-bashrc"' >> "$HOME/.bashrc"
  موفق "محیط فارسی به .bashrc اضافه شد (خودکار با هر ترمینال لود می‌شود)."
else
  echo "! از قبل اضافه شده."
fi

echo
موفق "نصب کامل شد!"
echo "  دستورات جدید:  پک | فارس | گیت‌بازکن"
echo "  شروع سریع:    پک راهنما   یا   راهنمای_فارسی"
echo "  ترمینال را ببندید و دوباره باز کنید (یا: source ~/.bashrc)"
