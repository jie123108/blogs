#!/bin/sh

#find . -type f |grep -v -e"\.git" -e"docs" -e"\/t\/" -e"config.lua" |sort |xargs md5sum

CHECK_LIST="checklist.txt"
CHECK_LIST_LOCAL="$CHECK_LIST.local"
md5all() {
    find . -type f |grep -v -e"\.git" -e"docs" -e"\/t\/" -e"config.lua" -e"checklist.txt" -e"md5_check.sh" |sort |xargs md5sum > $1
}

md5one() {
    md5=`md5sum $1 | awk '{print $1}'`
    echo $md5
}

gen(){
    md5all $CHECK_LIST
} 
check(){
    if [ ! -f "$CHECK_LIST" ]; then
        echo "ERR"
        echo "file '$CHECK_LIST' not exist!"
        exit 1
    fi
    md5all $CHECK_LIST_LOCAL
    md5_source=`md5one "$CHECK_LIST"`
    md5_local=`md5one $CHECK_LIST_LOCAL`
    if [ "$md5_source" == "$md5_local" ]; then
        echo "OK"
        exit 0
    else
        echo "ERR"
        diff $CHECK_LIST $CHECK_LIST_LOCAL
        exit 1
    fi
    echo $md5_source
    echo $md5_local
}

case "$1" in
"gen")
    gen
    exit 0
    ;; 
"check")
    check
    exit 0
    ;;
*)
    echo "用法：$0 gen|check"
    echo "在部署之前使用gen指令生成checklist.txt, 部署后，使用该checklist.txt检查节点上的文件。"
    ;; 
esac