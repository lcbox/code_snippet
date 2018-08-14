@echo Off
::FTP地址
echo open ftp.baidu.com>ftp.up
echo username>>ftp.up
echo password>>ftp.up
::本地存储目录
echo lcd E:\ftp>>ftp.up
::下载文件目录和名字
echo get "appd\back%date:~0,4%%date:~5,2%%date:~8,2%.rar">>ftp.up
echo bye>>ftp.up

FTP -s:ftp.up
del ftp.up /q

::pause
