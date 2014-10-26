#��װ
```shell
#�Ȱ�װcpan
yum install cpan
cpan
cpan[1]> install Test::Simple
```

#�ֶ���װperlģ��
```shell
# makefile.PL��ʽ
perl makefile.PL
make
make install
# Build.PL
cpan install Module::Build
perl Build.PL
perl Build
perl Build install
```

#���в���
```shell
#�Զ�ִ�е�ǰĿ¼�µ�*.t ����Ŀ¼t�����*.t
prove 
# ִ�в��ֲ�������
prove t/test.t
# ������Ϣ���
prove -v t/test.t
```

#Test::Simple ʹ��
### testsָ�����Լ�������
```perl
use Test::Simple tests => 1;
```
### ��ָ������
```perl
use Test::Simple 'no_plan';
ok (hello_world() eq "Hello, world!");
ok (hello_world() eq "Hello, world!", "��ʾ������Ϣ");
```

#Test::More
```perl
use Test::More tests => 5;
```
###װ��ģ��
```perl
use_ok ( 'ģ��', qw(func1 func2));
#require_ok
```
###�ж�ʵ������
```perl
isa_ok($obj, 'Type') or exit;
```
###�ж�ֵ(��,��)
```perl
is($obj->value(), $value, 'value() not equlas $value');
isnt
```
###�ַ�������
```perl
like($value, qr/RegEx/, 'error info');
unlike
```
###��������
```perl
eval('use xxx');
skip('����ԭ��', �����Ĳ��Ը���)  if $@;
```
### �������в���
```perl
plan(skip_all => '����ԭ��');
```
### Ƕ�׵��б�Ƚ�
```perl
use Test::More tests => 1;
use Test::Differences;

my $list1 = [[[48,12],[32,10],],[[03,28]]];
my $list2 = [[[48,12],[32,11],],[[05,28]]];
is_deeply($list1, $list2, 'existential equivalence');
eq_or_diff($list1, $list2, 'a tale of two references');
```
### �����ַ����Ƚ�
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
### ���������ݱȽ�
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
