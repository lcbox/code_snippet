
::网站备份文件 删除14天前的.rar文件
set DaysAgo1=14
forfiles /p D:\backup /s /m *.rar /d -%DaysAgo1% /c "cmd /c del /f /q /a @path"
::数据库备份文件
set DaysAgo3=14
forfiles /p E:\backup /s /m *.sql /d -%DaysAgo3% /c "cmd /c del /f /q /a @path"
::系统信息文件
set DaysAgo2=14
forfiles /p D:\backup\power_auto /s /m *.htm /d -%DaysAgo2% /c "cmd /c del /f /q /a @path"

::/p：指定目录
::/s：递归搜索子目录
::/m：搜索“*.zip”文件来删除，默认是“*.*”
::/d：-7表示7天前的文件
::/c：执行命令，后面双引号括起来的是删除文件命令