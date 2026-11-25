#!/data/data/com.termux/files/usr/bin/env bash
# ============================================================
#  گیت‌بازکن v2.0 — انتشار هوشمند پوشه روی گیت‌هاب
#  استفاده:
#    گیت‌بازکن [مسیر]                انتشار پوشه (پیش‌فرض: پوشهٔ جاری)
#    گیت‌بازکن -نام my-repo [مسیر]   مخزن جدید با نام دلخواه
#    گیت‌بازکن -خصوصی                مخزن خصوصی بسازد
#    گیت‌بازکن -پیام "متن"           پیام کامیت دلخواه
# ============================================================

set -euo pipefail

repo_name=""
target="."
privat=false
msg=""

# ---- خروجی رنگی ----
س()    { printf '\033[1;36m▸ %s\033[0m\n' "$*"; }
موفق() { printf '\033[1;32m✓ %s\033[0m\n' "$*"; }
خطا()  { printf '\033[1;31m✗ %s\033[0m\n' "$*" >&2; exit 1; }

# ---- تجزیهٔ آرگومان‌ها ----
while [ $# -gt 0 ]; do
  case "$1" in
    -نام|-n|--name)     repo_name="$2"; shift 2 ;;
    -خصوصی|-p|--private) privat=true; shift ;;
    -پیام|-m|--message) msg="$2"; shift 2 ;;
    -h|--help)          sed -n '2,12p' "$0" | sed 's/^#//;s/^ //'; exit 0 ;;
    *)                  target="$1"; shift ;;
  esac
done

# ---- پیش‌نیازها ----
command -v gh >/dev/null || خطا "ابزار gh نصب نیست. اجرا کنید: پک نصب gh"
command -v git >/dev/null || خطا "گیت نصب نیست. اجرا کنید: پک نصب git"
gh auth status >/dev/null 2>&1 || خطا "وارد گیت‌هاب نشده‌اید. اجرا کنید: gh auth login"
[ -d "$target" ] || خطا "پوشهٔ «$target» وجود ندارد."

cd "$target"

# ---- هویت گیت (از gh گرفته می‌شود) ----
if ! git config user.name >/dev/null 2>&1; then
  git config user.name  "$(gh api user -q .login 2>/dev/null || echo arani2020)"
  git config user.email "$(gh api user -q .email 2>/dev/null || echo arani2020@users.noreply.github.com)"
fi

# ---- کامیت تغییرات (اگر هست) ----
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null \
   || [ -n "$(git ls-files --others --exclude-standard)" ]; then
  س "ثبت تغییرات..."
  git add -A
  git -c commit.gpgsign=false commit -q -m "${msg:-به‌روزرسانی خودکار — $(date +'%Y-%m-%d %H:%M')}" || true
fi

# ---- انتشار ----
if git remote get-url origin >/dev/null 2>&1; then
  س "ارسال به گیت‌هاب..."
  branch="$(git branch --show-current 2>/dev/null || echo master)"
  git push -u origin "$branch" 2>&1 | tail -3
else
  [ -n "$repo_name" ] || repo_name="$(basename "$(pwd)")"
  vis="$([ "$privat" = true ] && echo --private || echo --public)"
  س "ساخت مخزن «$repo_name» روی گیت‌هاب..."
  gh repo create "$repo_name" $vis --source=. --remote=origin --push
fi

# ---- باز کردن صفحه ----
url="$(gh repo view --json url -q .url 2>/dev/null || echo "")"
[ -n "$url" ] && {
  موفق "منتشر شد: $url"
  س "باز کردن در مرورگر..."
  termux-open-url "$url" 2>/dev/null || xdg-open "$url" 2>/dev/null \
    || am start -a android.intent.action.VIEW -d "$url" >/dev/null 2>&1 || echo "لینک: $url"
}
