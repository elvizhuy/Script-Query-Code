#!/bin/bash

log_directory="/tmp/rsynclog/"
days_threshold=5

# Di chuyển đến thư mục chứa log
cd "$log_directory" || exit

# Lấy danh sách các file log và xóa các file cũ hơn ngày được thiết lập
find . -name "rsync_his_*.log" -mtime +"$days_threshold" -exec rm -f {} \;

echo "Đã xóa các file log cũ hơn $days_threshold ngày trong thư mục $log_directory"