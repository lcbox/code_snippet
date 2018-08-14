@echo Off
::FTP地址
echo open ftp.baidu.com>ftp.up
echo username>>ftp.up
echo password>>ftp.up
::上传文件(覆盖)
echo put D:\web\jquery.js >> ftp.up
echo bye>>ftp.up

FTP -s:ftp.up
del ftp.up /q

::pause