# Android SDK Reference CHM无法显示解决
>&nbsp;&nbsp;&nbsp;&nbsp;网上(http://pan.baidu.com/s/1sjNiqh3)下载的Android 4.4 SDK reference.chm文件，显示都是空白的。
原因是：由于国家放火墙的存在，很多页面要很长时间才能显示。只需要将下面这些地址都解析到本地就可以快速访问了。
解析办是将以下内容都添加到：C:\Windows\System32\drivers\etc\hosts
```
127.0.0.1 android-developers.blogspot.com
127.0.0.1 business.ftc.gov
127.0.0.1 cldr.unicode.org
127.0.0.1 davenport.sourceforge.net
127.0.0.1 developer.android.com
127.0.0.1 fonts.googleapis.com
127.0.0.1 geronimo.apache.org
127.0.0.1 getinstantbuy.withgoogle.com
127.0.0.1 jclark.com
127.0.0.1 kovio.com
127.0.0.1 openssl.org
127.0.0.1 relaxng.org
127.0.0.1 sax.sourceforge.net
127.0.0.1 source.android.com
127.0.0.1 sqlite.org
127.0.0.1 technotes.googlecode.com
127.0.0.1 tomcat.apache.org
127.0.0.1 tools.ietf.org
127.0.0.1 unicode.org
127.0.0.1 wiki.apache.org
127.0.0.1 wp.netscape.com
127.0.0.1 www.apache.org
127.0.0.1 www.aw.com
127.0.0.1 www.bouncycastle.org
127.0.0.1 www.cs.rochester.edu
127.0.0.1 www.faqs.org
127.0.0.1 www.gs1.org
127.0.0.1 www.gzip.org
127.0.0.1 www.hackersdelight.org
127.0.0.1 www.icu-project.org
127.0.0.1 www.ietf.org
127.0.0.1 www.khronos.org
127.0.0.1 www.netlib.org
127.0.0.1 www.ngdc.noaa.gov
127.0.0.1 www.opengroup.org
127.0.0.1 www.openssl.org
127.0.0.1 www.relaxng.org
127.0.0.1 www.rsa.com
127.0.0.1 www.saxproject.org
127.0.0.1 www.sqlite.org
127.0.0.1 www.unicode.org
127.0.0.1 www.upnp.org
127.0.0.1 www.w3.org
127.0.0.1 www.xmlpull.org
127.0.0.1 xmlpull.org
```