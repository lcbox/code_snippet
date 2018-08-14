#FTP地址
"open aicfb.com"| Out-File -Encoding ASCII ftp.up
"username"| Out-File -Append  -Encoding ASCII ftp.up
"password"| Out-File -Append  -Encoding ASCII ftp.up
#上传文件(覆盖)
"put D:\web\jquery.js"| Out-File -Append  -Encoding ASCII ftp.up
"bye"| Out-File -Append  -Encoding ASCII ftp.up
FTP -s:ftp.up
del ftp.up 

# 创建临时文件ftp.up -> 使用ftp-s读取参数 -> 成功后删除ftp.up
# powershell 编码是真的烦, -Encoding UTF8 是带BOM的 , 还好有ASCII 
# ftp下载也差不多, 参照 ftp_down.cmd
