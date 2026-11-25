# ============================================
#  محیط فارسی ترموکس v2.0
#  تجربهٔ ترمینال کاملاً فارسی + حفظ دستورات انگلیسی
# ============================================

# ---- پرامپت فارسی رنگی (نام کاربر و مسیر) ----
PS1='\[\e[1;32m\]کاربر@فارس\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '

# ---- تاریخچهٔ هوشمندتر ----
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend                # تاریخچه بازشدن‌های جدید بازنویسی نشود
shopt -s checkwinsize              # اندازهٔ پنجره بعد از هر دستور به‌روز شود
shopt -s cdspell                   # غلط تایپی کوچک در cd خودکار اصلاح شود

# ---- میان‌برهای فایل و پوشه ----
alias پوشه‌ها='ls -lah --color=auto'
alias پوشه='cd'
alias عقب='cd ..'
alias خانه='cd ~'
alias کپی='cp -i'
alias انتقال='mv -i'
alias ساخت='mkdir -pv'
alias بساز='mkcd'                  # پوشه بساز و واردش شو
alias حذف‌فایل='rm -i'
alias حذف‌پوشه='rm -ri'
alias خواندن='cat'
alias سرصفحه='head'
alias دنباله='tail'
alias ویرایش='nano'
alias جستجوفایل='find . -name'
alias یافتن='find . -name'
alias اندازه='du -sh'
alias استفاده='du -sh * | sort -rh | head -20'
alias فایل‌ها='ls -lah'
alias درخت='tree -C'

# ---- سیستم ----
alias پاک‌کن='clear'
alias خروج='exit'
alias من='whoami'
alias کجا='pwd'
alias تاریخ='date'
alias امروز='date +"%A %d %B %Y"'
alias ساعت='date +"%H:%M:%S"'
alias فضا='df -h'
alias حافظه='free -h'
alias روند='ps aux'
alias بالادهنده='htop 2>/dev/null || top'
alias ری‌استارت_گفتگو='exec bash'
alias باتری='termux-battery-status 2>/dev/null | head -5'

# ---- شبکه ----
alias شبکه='ip a'
alias آی‌پی='ip a show wlan0 2>/dev/null | grep "inet "'
alias وب='curl -O -J -L'
alias تست‌وب='curl -s -o /dev/null -w "%{http_code} %{time_total}s"'
alias پینگ='ping -c 4'
alias پورت‌ها='ss -tlnp 2>/dev/null || netstat -tlnp'

# ---- بسته‌ها (از پک) ----
alias راهنما='پک راهنما'
alias نصب='پک نصب'
alias حذف='پک حذف'
alias جستجو='پک جستجو'
alias فهرست='پک فهرست'
alias اطلاعات='پک اطلاعات'
alias به‌روزرسانی='پک به‌روزرسانی'
alias ارتقا='پک ارتقا'
alias پاکسازی='پک پاکسازی'
alias نگهداری='پک نگهداری'

# ---- گیت ----
alias وضعیت='git status -sb'
alias تازه‌سازی='git pull'
alias ثبت='git add -A && git commit -m'
alias انتشار='git push'

# ---- توابع کاربردی ----

# پوشه بساز و واردش شو
mkcd() {
  [ -z "$1" ] && { echo "استفاده: بساز <نام‌پوشه>"; return 1; }
  mkdir -p "$1" && cd "$1" && echo "✓ پوشهٔ «$1» ساخته شد."
}

# فشرده‌سازی — تشخیص خودکار فرمت
فشرده() {
  [ -z "$1" ] && { echo "استفاده: فشرده <خروجی> [فایل‌ها...]"; return 1; }
  case "$1" in
    *.tar.gz) tar -czf "$1" "${@:2}" ;;
    *.tar.bz2) tar -cjf "$1" "${@:2}" ;;
    *.tar.xz) tar -cJf "$1" "${@:2}" ;;
    *.zip) zip -r "$1" "${@:2}" ;;
    *) tar -czf "$1.tar.gz" "${@:2}" ;;
  esac
  echo "✓ $1 ساخته شد."
}

# استخراج — تشخیص خودکار فرمت
بازکن_بسته() {
  [ -z "$1" ] && { echo "استفاده: بازکن_بسته <فایل>"; return 1; }
  case "$1" in
    *.tar.gz|*.tgz) tar -xzf "$1" ;;
    *.tar.bz2) tar -xjf "$1" ;;
    *.tar.xz) tar -xJf "$1" ;;
    *.zip) unzip "$1" ;;
    *.gz) gunzip "$1" ;;
    *) echo "! فرمت پشتیبانی نمی‌شود: $1"; return 1 ;;
  esac
  echo "✓ $1 باز شد."
}

# دانلود با ادامه‌ی خودکار
دانلود() {
  [ -z "$1" ] && { echo "استفاده: دانلود <نشانی>"; return 1; }
  wget -c "$1" && echo "✓ دانلود کامل شد."
}

# جستجو در تاریخچهٔ دستورات
تاریخچه() {
  history | grep -i "${1:-}" | tail -20
}

# بکاپ سریع از یک فایل
بکاپ() {
  [ -z "$1" ] && { echo "استفاده: بکاپ <فایل>"; return 1; }
  cp "$1" "$1.bak.$(date +%Y%m%d-%H%M%S)" && echo "✓ بکاپ ساخته شد: $1.bak.$(date +%Y%m%d-%H%M%S)"
}

# شمارش خطوط کد در پوشه
شمارش_خطوط() {
  find . -type f \( -name "*.py" -o -name "*.sh" -o -name "*.js" -o -name "*.html" -o -name "*.css" \) \
    -exec wc -l {} + | tail -1
}

# راهنمای فارسی دستورات
راهنمای_فارسی() {
  cat <<'EOF'
📚 راهنمای سریع محیط فارسی ترموکس

📁 فایل و پوشه:
  پوشه‌ها            لیست فایل‌ها          (ls -lah)
  پوشه <نام>         ورود به پوشه          (cd)
  بساز <نام>         پوشه بساز و وارد شو
  کپی/انتقال/حذف‌فایل cp / mv / rm ایمن
  خواندن <فایل>      نمایش فایل            (cat)
  ویرایش <فایل>      ویرایش با nano
  یافتن <نام>        جستجوی فایل
  استفاده            پرحجم‌ترین فایل‌ها
  فشرده/بازکن_بسته   zip و tar.gz خودکار

🖥 سیستم:
  فضا                فضای دیسک             (df -h)
  حافظه              رم                    (free -h)
  روند               پروسه‌های در حال اجرا
  باتری              وضعیت باتری (با Termux:API)
  من / کجا / امروز   whoami / pwd / تاریخ

🌐 شبکه:
  شبکه               کارت‌های شبکه
  آی‌پی              نشانی IP وای‌فای
  پینگ <نشانی>       تست اتصال
  وب <نشانی>         دانلود فایل از اینترنت

📦 بسته‌ها:
  نصب/حذف/جستجو/اطلاعات <بسته>
  به‌روزرسانی / ارتقا / پاکسازی / نگهداری

📝 گیت:
  وضعیت              وضعیت مخزن
  ثبت "پیام"         ثبت همهٔ تغییرات
  انتشار             ارسال به گیت‌هاب

⌨ ویرایشگر: Ctrl+O ذخیره | Ctrl+X خروج
EOF
}
