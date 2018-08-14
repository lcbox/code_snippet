# 不知道什么原因utf8编码会出错，所以文件使用 GB2312
$nowTime = "Z1_"+(Get-Date -Format 'yyMMdd')
$str = '<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no, minimal-ui">'
$str += "<h1>$nowTime</h1><style>"
$str += "h1{color: #747fb7; width: 80%; margin: auto; padding-bottom: 20px;}";
$str += "table{margin: auto; margin-bottom: 35px; width: 80%; color: #525252; box-shadow: 0px 0px 1px #ffe5e5; padding: 10px; border-collapse: collapse; font-size: 14px;}"
$str += "td,th{ border: 1px solid #9ea2b6; padding: 9px 10px; }"
$str += ".title{margin-bottom:0px;background: #747fb7;color: white;position: relative;}.title th{border:0}"
$str += "</style>"
$str += "<table>"
$str += "<tr><td>操作系统:</td><td>{0}</td></tr>" -f (Get-WmiObject Win32_OperatingSystem).caption
$str += "<tr><td>报告时间:</td><td>{0}</td></tr>" -f (Get-Date -Format 'yyyy-MM-dd HH:mm')
$str += "<tr><td>当前CPU: </td><td>{0} %</td></tr>" -f (Get-WmiObject  win32_Processor ).LoadPercentage
$str += "<tr><td>总内存:  </td><td>{0} MB</td></tr>" -f [int]((Get-WmiObject -Class Win32_OperatingSystem).TotalVisibleMemorySize/1024)
$str += "<tr><td>可用内存:</td><td>{0} MB</td></tr>" -f [int]((Get-WmiObject -Class Win32_OperatingSystem).FreePhysicalMemory/1024)
$Uptime = Get-WmiObject -Class Win32_OperatingSystem;$Time = (Get-Date) - $Uptime.ConvertToDateTime($Uptime.LastBootUpTime)
$str += "<tr><td>系统运行时间:</td><td> {0:00} 天 {1:00} 小时 {2:00} 分钟 {3:00} 秒</td></tr>" -f $Time.Days, $Time.Hours, $Time.Minutes, $Time.Seconds
$str += "<tr><td>已停止(auto):</td><td>"
$Services = Get-WmiObject -Class Win32_Service| Where {($_.StartMode -eq "Auto") -and ($_.State -eq "Stopped")}
foreach ($Service in $Services) {$str += $Service.Name+" ,"}
$str += "</td></tr></table>"


#磁盘状态
$str+="<table class='title'><tr><th colspan=2>磁盘状态</th></tr></table>";
Function get_disk_info(){
   $fragments=@()
   #get the drive data
   $data=get-wmiobject -Class Win32_logicaldisk -filter "drivetype=3"
   #group data by computername
   $groups=$Data | Group-Object -Property SystemName
   #this is the graph character
   [string]$g=[char]9608 
   #iterate through each group object
   ForEach ($computer in $groups) {
       #define a collection of drives from the group object
       $Drives=$computer.group
       #create an html fragment
       $html=$drives | Select @{Name="分区";Expression={$_.DeviceID}},
	      @{Name="卷名";Expression={$_.VolumeName}},
       @{Name="容量 GB";Expression={$_.Size/1GB  -as [int]}},
       @{Name="已用 GB";Expression={"{0:N2}" -f (($_.Size - $_.Freespace)/1GB) }},
       @{Name="可用 GB";Expression={"{0:N2}" -f ($_.FreeSpace/1GB) }},
	      @{Name="可用 %";Expression={"{0:N2}" -f (($_.FreeSpace/$_.Size)*100)}},
        @{Name="使用状态";Expression={
          $UsedPer= (($_.Size - $_.Freespace)/$_.Size)*100
          $UsedGraph=$g * ($UsedPer/2)
          $FreeGraph=$g* ((100-$UsedPer)/2)
          #I'm using place holders for the < and > characters
          "xopenFont color=Redxclose{0}xopen/FontxclosexopenFont Color=Greenxclose{1}xopen/fontxclose" -f $usedGraph,$FreeGraph
        }} | ConvertTo-Html -Fragment 
        
        #replace the tag place holders. It is a hack but it works.
        $html=$html -replace "xopen","<"
        $html=$html -replace "xclose",">"
        
       $Fragments+=$html
    }
    return [string]$fragments | Out-String
}
$str  += get_disk_info

$str+="<table class='title'><tr><th colspan=2>内存占用(TOP 6)</th></tr></table>";
#内存占用排行
$str += Get-Process | Sort WS -Descending | `Select ProcessName, WS -First 6 | ConvertTo-Html -Fragment

$str+="<table class='title'><tr><th colspan=2>Windows事件-系统错误,警告(TOP 3)</th></tr></table>";
# Windows事件 - 系统(错误,警告)
$SystemEventsReport = @()
$SystemEvents = Get-EventLog -LogName System -EntryType Error,Warning -Newest 3
foreach ($event in $SystemEvents) {
   $SystemEventsReport += New-Object -Type PSObject -Property @{
      TimeGenerated = $event.TimeGenerated
      EntryType = $event.EntryType
      Source = $event.Source
      Message = $event.Message
   }
}
$str += ($SystemEventsReport | ConvertTo-Html -Fragment)


$str+="<table class='title'><tr><th colspan=2>Windows事件-应用程序错误,警告(TOP 3)</th></tr></table>";
# Windows事件 - 程序(错误,警告)
$ApplicationEventsReport = @()
$ApplicationEvents = Get-EventLog -LogName Application -EntryType Error,Warning -Newest 3
foreach ($event in $ApplicationEvents) {
    $ApplicationEventsReport += New-Object -Type PSObject -Property @{
      TimeGenerated = $event.TimeGenerated
      EntryType = $event.EntryType
      Source = $event.Source
      Message = $event.Message
   }
}
$str += $ApplicationEventsReport | ConvertTo-Html -Fragment

#开机启动程序
$str+="<table class='title'><tr><th colspan=2>开机启动程序</th></tr></table>";
$str += "<table><th>名称</th><th>路径</th></tr>"
$colItems = Get-WmiObject -Class Win32_StartupCommand
foreach ($objStartupCommand in $colItems) 
{$str += "<tr><td>"+$objStartupCommand.Name+"</td><td>"+$objStartupCommand.Command+"</td></tr>"}
$str += "</table>"


#结果输出到当前文件夹
$str | Out-File -Encoding utf8 "$nowTime.htm"
#如果服务器有安全组的话需要放行一些端口（大概是1023 - 6000?） 因为ftp.exe不支持指定本地端口，而是随机
#但是curl不设置都可以使用
#将结果文件上传至FTP
"open aicfb.com"| Out-File -Encoding ASCII ftp.up
"notice"| Out-File -Append  -Encoding ASCII ftp.up
"HjtTtarm7w"| Out-File -Append  -Encoding ASCII ftp.up
"put $nowTime.htm"| Out-File -Append  -Encoding ASCII ftp.up
"bye"| Out-File -Append  -Encoding ASCII ftp.up
FTP -s:ftp.up
del ftp.up 
#上传完成后删除结果
del "$nowTime.htm"