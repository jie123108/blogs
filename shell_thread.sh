#!/bin/sh


tmp_fifofile="/tmp/$$.fifo"
mkfifo $tmp_fifofile      # 新建一个fifo类型的文件
exec 6<>$tmp_fifofile      # 将fd6指向fifo类型
rm $tmp_fifofile


thread=4 # 此处定义线程数
for ((i=0;i<$thread;i++));do 
echo
done >&6 # 事实上就是在fd6中放置了$thread个回车符


# 外部循环，可以改成读取文件，或读取参数进行循环等。
for ((i=0;i<20;i++));do 
read -u6 
# 一个read -u6命令执行一次，就从fd6中减去一个回车符，然后向下执行，
# fd6中没有回车符的时候，就停在这了，从而实现了线程数量控制

{ # 此处子进程开始执行，被放到后台
    ############# 这里是要执行的命令... #############
    echo " task-$i start ..."
    sleep 10
    echo " task-$i end ..."
    ###########  执行的命令到这儿结束了。############
    echo >&6 # 当进程结束以后，再向fd6中加上一个回车符，即补上了read -u6减去的那个
} &

done

wait # 等待所有的后台子进程结束
exec 6>&- # 关闭df6

exit 0