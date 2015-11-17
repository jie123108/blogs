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
