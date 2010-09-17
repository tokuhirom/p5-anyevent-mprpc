use strict;
use warnings;
use AE;
use AnyEvent::MessagePack;
use AnyEvent::Handle;
use File::Temp qw(tempfile);
use Test::More;

my ($fh, $fname) = tempfile(UNLINK => 0);
my @data = ( [ 1, 2, 3 ], [ 4, 5, 6 ] );

my $cv = AE::cv;

{
    my $hdl = AnyEvent::Handle->new(fh => $fh, on_error  => sub { die 'wtf' });
    for my $d (@data) {
        $hdl->push_write(msgpack => $d);
    }
    close $fh;
}

my $hdl = do {
    open my $fh, '<', $fname or die $!;
    my $hdl = AnyEvent::Handle->new(fh => $fh, on_error  => sub { die 'wtf' });
    $hdl->push_read(msgpack => sub {
        my ($hdl, $data) = @_;

        my $e = shift @data;
        is_deeply $data, $e;
        $cv->send() unless @data;
    });
    $hdl;
};

$cv->recv();
unlink $fname;

done_testing;

