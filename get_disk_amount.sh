#!/bin/bash

# Lấy thông tin các phân vùng ổ cứng
partitions=($(df -h | awk '{if (NR>1) print}'))

# Duyệt qua từng phần tử trong mảng partitions
for partition in "${partitions[@]}"; do
  # In thông tin phân vùng
  echo "$partition"
  # Hoặc bạn có thể lưu thông tin vào biến riêng
  # partition_name=$(echo "$partition" | awk '{print $1}')
  # partition_size=$(echo "$partition" | awk '{print $2}')
  # ...
done