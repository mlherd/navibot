function rval = send2esp8266(url);
fullurl = ['C:\Users\inti\Desktop\curl-7.46.0\AMD64\curl.exe "' url '" -H "Accept-Encoding: gzip, deflate, sdch" -H "Accept-Language: en-US,en;q=0.8" -H "Upgrade-Insecure-Requests: 1" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.86 Safari/537.36" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Connection: keep-alive" --compressed'];
[a,b] = system(fullurl);
rval = 0;