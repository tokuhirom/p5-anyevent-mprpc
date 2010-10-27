use strict;
use Test::More tests => 1;

BEGIN { use_ok 'AnyEvent::MPRPC' }
diag "Data::MessagePack: $Data::MessagePack::VERSION";
