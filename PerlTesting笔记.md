#安装
```shell
#先安装cpan
yum install cpan
cpan
cpan[1]> install Test::Simple
```

#手动安装perl模块
```shell
# makefile.PL方式
perl makefile.PL
make
make install
# Build.PL
cpan install Module::Build
perl Build.PL
perl Build
perl Build install
```

#运行测试
```shell
#自动执行当前目录下的*.t 或者目录t下面的*.t
prove 
# 执行部分测试用例
prove t/test.t
# 调试信息输出
prove -v t/test.t
```

#Test::Simple 使用
### tests指定测试集数量。
```perl
use Test::Simple tests => 1;
```
### 不指定数量
```perl
use Test::Simple 'no_plan';
ok (hello_world() eq "Hello, world!");
ok (hello_world() eq "Hello, world!", "提示出错信息");
```

#Test::More
```perl
use Test::More tests => 5;
```
###装载模块
```perl
use_ok ( '模块', qw(func1 func2));
#require_ok
```
###判断实例类型
```perl
isa_ok($obj, 'Type') or exit;
```
###判断值(是,否)
```perl
is($obj->value(), $value, 'value() not equlas $value');
isnt
```
###字符串正则
```perl
like($value, qr/RegEx/, 'error info');
unlike
```
###跳过测试
```perl
eval('use xxx');
skip('跳过原因', 跳过的测试个数)  if $@;
```
### 跳过所有测试
```perl
plan(skip_all => '跳过原因');
```
### 嵌套的列表比较
```perl
use Test::More tests => 1;
use Test::Differences;

my $list1 = [[[48,12],[32,10],],[[03,28]]];
my $list2 = [[[48,12],[32,11],],[[05,28]]];
is_deeply($list1, $list2, 'existential equivalence');
eq_or_diff($list1, $list2, 'a tale of two references');
```
### 多行字符串比较
```perl
use Test::More tests => 1;
use Test::Differences;

my $string1 = <<"END1";
This is a test,
My Name is lxj.
the end line
END1

my $string2 = <<"END2";
This is a test,
My Name is jack.
the end line
END2

eq_or_diff($string1, $string2, 'are they the same?');
```
### 二进制数据比较
```perl
use Test::More tests => 1;
use Test::LongString;

my $string1 = <<"END1";
This is a test,
My Name is lxj.
the end line
END1

my $string2 = <<"END2";
This is a test,
My Name is jack.
the end line
END2

is_string($string1, $string2, 'are they the same?');
```
