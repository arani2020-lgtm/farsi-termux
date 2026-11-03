#!/data/data/com.termux/files/usr/bin/bash
# گیت‌بازکن — خروجی را روی گیت‌هاب منتشر و صفحه را در مرورگر باز می‌کند
# استفاده:  گیت‌بازکن [مسیر]        (پیش‌فرض: پوشهٔ جاری)
#           گیت‌بازکن -نام مخزن [مسیر]
set -e
target="."
repo_name=""
while [ $# -gt 0 ]; do
  case "$1" in
    -نام|--name) repo_name="$2"; shift 2 ;;
    *) target="$1"; shift ;;
  esac
done
cd "$target"
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

if ! git remote get-url origin >/dev/null 2>&1; then
  [ -n "$repo_name" ] || repo_name="$(basename "$(pwd)")"
  س "ساخت مخزن گیت‌هاب با نام «$repo_name»..."
  gh repo create "$repo_name" --public --source=. --remote=origin --push
else
  س "ارسال به گیت‌هاب..."
  branch="$(git branch --show-current 2>/dev/null)"
  [ -z "$branch" ] && branch=master
  git push -u origin "$branch" 2>&1 | tail -5
fi

url="$(gh repo view --json url -q .url 2>/dev/null)"
[ -z "$url" ] && خطا "نشانی مخزن پیدا نشد."
موفق "منتشر شد: $url"

س "باز کردن صفحه در مرورگر..."
termux-open-url "$url" 2>/dev/null || xdg-open "$url" 2>/dev/null || am start -a android.intent.action.VIEW -d "$url" >/dev/null 2>&1 || echo "لینک: $url"
