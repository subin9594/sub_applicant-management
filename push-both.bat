@echo off
cd /d %~dp0

echo [1] 새 레포(origin)로 push 중...
git push origin main

echo [2] 기존 레포(origin-app)로 push 중...
git push origin-app main

echo ✅ 두 레포 모두 push 완료!
pause
