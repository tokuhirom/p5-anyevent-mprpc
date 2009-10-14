use inc::Module::Install;
name 'AnyEvent-MPRPC';
all_from 'lib/AnyEvent/MPRPC.pm';

requires 'AnyEvent'          => 5.201;
requires 'Data::MessagePack' => 0.08;
requires 'Any::Moose'        => 0.10;

tests 't/*.t';
test_requires 'Test::More'       => 0.94;
test_requires 'Test::TCP'        => 0.11;
test_requires 'Test::SharedFork' => 0.05;
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
