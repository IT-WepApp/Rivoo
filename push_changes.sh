#!/bin/bash

# التأكد من أننا على فرع main
git checkout main

# إضافة جميع الملفات المعدلة والجديدة
git add .

# الالتزام بالتغييرات مع رسالة وصفية
git commit -m "إضافة دعم اللغات والوضع الليلي

تم إضافة:
- دعم للغات العربية والإنجليزية والفرنسية والتركية والأردية
- نظام ترجمة باستخدام flutter_localizations وملفات .arb
- الوضع الليلي الذي يتبع إعدادات النظام
- إمكانية التبديل اليدوي بين الوضع الفاتح والداكن
- صفحة إعدادات لتغيير اللغة والسمة"

# تكوين Git لاستخدام الـ token
git config --local credential.helper store
echo "https://x-access-token:$1@github.com" > ~/.git-credentials

# دفع التغييرات إلى المستودع مباشرة على فرع main
git push origin main

# حذف بيانات الاعتماد بعد الانتهاء
rm ~/.git-credentials
