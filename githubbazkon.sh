#!/data/data/com.termux/files/usr/bin/bash
# گیت‌بازکن — خروجی را روی گیت‌هاب منتشر و صفحه را در مرورگر باز می‌کند
# استفاده:  گیت‌بازکن [مسیر]        (پیش‌فرض: پوشهٔ جاری)
#           گیت‌بازکن -نام مخزن [مسیر]
set -e
مسیر="."
نام_مخزن=""
while [ $# -gt 0 ]; do
  case "$1" in
    -نام|--name) نام_مخزن="$2"; shift 2 ;;
    *) مسیر="$1"; shift ;;
  esac
done
cd "$مسیر"
س() { printf '\033[1;36m▸ %s\033[0m\n' "$*"; }
موفق() { printf '\033[1;32m✓ %s\033[0m\n' "$*"; }
خطا() { printf '\033[1;31m✗ %s\033[0m\n' "$*" >&2; exit 1; }

command -v gh >/dev/null || خطا "ابزار gh نصب نیست. اجرا کنید: پک نصب gh"
gh auth status >/dev/null 2>&1 || خطا "وارد گیت‌هاب نشده‌اید. اجرا کنید: gh auth login"

[ -d .git ] || { س "ساخت مخزن محلی..."; git init -q; }
git config user.name  >/dev/null 2>&1 || git config user.name  "arani2020"
git config user.email >/dev/null 2>&1 || git config user.email "arani2020@gmail.com"

# ثبت تغییرات
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null || [ -n "$(git ls-files --others --exclude-standard)" ]; then
  git add -A
  git -c commit.gpgsign=false commit -q -m "به‌روزرسانی خودکار — $(date +'%Y-%m-%d %H:%M')" || true
fi

اگر_ریموت_نیست() { ! git remote get-url origin >/dev/null 2>&1; }

if اگر_ریموت_نیست; then
  [ -n "$نام_مخزن" ] || نام_مخزن="$(basename "$(pwd)")"
  س "ساخت مخزن گیت‌هاب با نام «$نام_مخزن»..."
  gh repo create "$نام_مخزن" --public --source=. --remote=origin --push
else
  س "ارسال به گیت‌هاب..."
  شاخه="$(git branch --show-current 2>/dev/null)"
  [ -z "$شاخه" ] && شاخه=master
  git push -u origin "$شاخه" 2>&1 | tail -5
fi

آدرس="$(gh repo view --json url -q .url 2>/dev/null)"
[ -z "$آدرس" ] && خطا "نشانی مخزن پیدا نشد."
موفق "منتشر شد: $آدرس"

س "باز کردن صفحه در مرورگر..."
termux-open-url "$آدرس" 2>/dev/null || xdg-open "$آدرس" 2>/dev/null || am start -a android.intent.action.VIEW -d "$آدرس" >/dev/null 2>&1 || echo "لینک: $آدرس"
