#!/bin/bash

online=$(
curl -sSL "https://gw.buaa.edu.cn/cgi-bin/rad_user_info" \
-c cookie.jar \
--header "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36" \
)

echo "Gateway: $online"
if grep -q "not_online_error" <<< $online; then
  bash ./login-v2.sh login
else
  echo online: $(cut -d, -f1 <<< $online)
fi
