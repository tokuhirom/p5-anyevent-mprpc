use inc::Module::Install;
name 'AnyEvent-MPRPC';
all_from 'lib/AnyEvent/MPRPC.pm';

requires 'AnyEvent';
requires 'Data::MessagePack';

tests 't/*.t';
test_requires 'Test::More';
test_requires 'Test::TCP';
test_requires 'Test::SharedFork';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
