# 安装
直接执行 sh install.sh 将安装到/usr/local/systemtap-2.6目录下。


# install.sh内容
```shell
DIR=$(cd "$(dirname "$0")"; pwd)
INSTDIR="/usr/local/systemtap-2.6"
cd $DIR
tar -xf elfutils-0.160.tar.bz2 
tar -xf systemtap-2.6.tar.gz 
cd systemtap-2.6
./configure  --with-elfutils=../elfutils-0.160 --prefix=${INSTDIR}
make -j 4 && make install
mv /usr/bin/stap{,-pre}
ln -s ${INSTDIR}/bin/stap /usr/bin/stap
cd ${INSTDIR}
unzip ${DIR}/FlameGraph-master.zip
mv FlameGraph-master FlameGraph
unzip ${DIR}/nginx-systemtap-toolkit.zip
mv nginx-systemtap-toolkit-master ngx-stap
echo "systemtap install to $INSTDIR"
echo "FlameGraph install to $INSTDIR/FlameGraph"
echo "nginx-system-toolkit install to $INSTDIR/ngx-stap"
echo "install success"
```

usermod -G stapusr slide

# sample-bt
```shell
cd /usr/local/systemtap-2.6/ngx-stap
PID=XX
./sample-bt -t 15 -u -p $PID | ../FlameGraph/stackcollapse-stap.pl | ../FlameGraph/flamegraph.pl > sample-bt_`date +'%Y-%m-%d_%H%M%S'`.svg
```



# sample-lua-bt
cd /usr/local/systemtap-2.6/ngx-stap
PID=XX
./ngx-sample-lua-bt -luajit20 -t 10 -p $PID | ../FlameGraph/stackcollapse-stap.pl | ../FlameGraph/flamegraph.pl > /root/work/sample-lua-bt_`date +'%Y-%m-%d_%H%M%S'`.svg


#可能遇到的出错信息
```shell
semantic error: while resolving probe point: identifier 'scheduler' at <input>:28:7
        source: probe scheduler.cpu_on {
                      ^

semantic error: no match
Pass 2: analysis failed.  [man error::pass2]
```
### 解决办法：
应该是缺少 Linux 内核的调试符号，请尝试命令： 
    yum install kernel-devel yum-utils 
    debuginfo-install kernel 

### 如果上面的debuginfo-install命令无法执行成功，请自行下载安装。
* 查看自己的系统版本

```
uname -a
Linux tw06141s1 2.6.32-431.el6.x86_64 #1 SMP Fri Nov 22 03:15:09 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux
```
* 进入http://debuginfo.centos.org/找到对应的版本。

```
kernel-debuginfo-2.6.32-431.el6.x86_64.rpm
kernel-debuginfo-common-x86_64-2.6.32-431.el6.x86_64.rpm
```
