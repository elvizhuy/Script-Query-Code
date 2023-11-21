#!/bin/bash

VG_NAME=$(vgdisplay | awk '/VG Name/ {print $3}')
LV_PATHS=($(lvdisplay | awk '/LV Path/ {print $3}'))

function get_disk_info()
{
    echo "============================ Check thông tin ổ đĩa ==================================="
    df -hT
    echo "======================================================================================"
    lsblk
}
get_disk_info

function begin_resolve_with_fdisk ()
{
    echo "================================== Xử lý với Fdisk ====================================="
    read -p "Nhập tên ổ đĩa muốn xử lý : " nameOFdisk
    fdisk /dev/$nameOFdisk
    echo "n"
    echo "p"
    echo "========================================================================================"
}
begin_resolve_with_fdisk

function update_and_rescan_disk () {
     partprobe -s
}

read -p "Nhập tên phân vùng muốn tạo physical volume: " nameOfPartitionToCreatePhysicalVolume

function physical_volume_create(){
    pvcreate /dev/$nameOfPartitionToCreatePhysicalVolume
}

function display_VG_and_entend () {
    vgdisplay
    if [ -n "$VG_NAME" ]; then
    echo "Tên của Volume Group: $VG_NAME"
    vgextend $VG_NAME /dev/$nameOfPartitionToCreatePhysicalVolume
    else
        echo "Volume Group $VG_NAME không tồn tại."
    fi
}

function display_LV_and_check () {
    lvdisplay
    if ! lvdisplay /dev/"$VG_NAME"/"$LV_NAME" &> /dev/null; then
        echo "Logical Volume không tồn tại."
        exit 1
    else
        extend_lv
    fi
}

function extend_lv () {
    if [ -n "${LV_PATHS[@]}" ]; then
        echo "Danh sách LV Path:"
        for ((i=0; i<${#LV_PATHS[@]}; i++)); do
            echo "$((i+1)). ${LV_PATHS[i]}"
        done
        read -p "Chọn số tương ứng với LV Path cần mở rộng: " selectedIndex
        if [[ $selectedIndex =~ ^[0-9]+$ && $selectedIndex -ge 1 && $selectedIndex -le ${#LV_PATHS[@]} ]]; then
            selectedLV=${LV_PATHS[$((selectedIndex-1)]}
            echo "Bạn đã chọn LV Path: $selectedLV"
            echo "Nhập tên phân vùng cần mở rộng : "
            read nameOfPartitionToExtend
            read -p "Chọn % dung lượng muốn mở rộng: " freeVolumePercentage
            lvextend -l +$freeVolumePercentage%FREE /dev/"$VG_NAME"/"$selectedLV" /dev/"$nameOfPartitionToExtend"
        fi
    else
        echo "LV Path không tìm thấy!"
    fi
}

