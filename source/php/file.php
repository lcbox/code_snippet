<?php
$file_name = '';

//写入覆盖文件 , w 覆盖, a 追加
fopen($file_name, "w");

//读取文件
file($file_name);

//删除文件
unlink($file_name);