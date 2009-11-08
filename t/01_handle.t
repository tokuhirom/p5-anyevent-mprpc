use strict;
use warnings;
use AE;
use AnyEvent::MessagePack;
use AnyEvent::Handle;
use File::Temp qw(tempfile);
use Test::More;

my ($fh, $fname) = tempfile(UNLINK => 0);
my @ret;

{
    my $hdl = AnyEvent::Handle->new(fh => $fh, on_error  => sub { die 'wtf' });
    $hdl->push_write(msgpack => [1,2,3]);
    $hdl->push_write(msgpack => [4,5,6]);
    close $fh;
}

my $hdl = do {
    open my $fh, '<', $fname or die $!;
    my $hdl = AnyEvent::Handle->new(fh => $fh, on_error  => sub { die 'wtf' });
    $hdl->push_read(msgpack => sub {
        my ($hdl, $data) = @_;
        push @ret, $data;
    });
    $hdl;
};

my $cv = AE::cv;
my $t; $t = AnyEvent->timer(
    after    => 0,
    interval => 1,
    cb       => sub {
        if ( @ret == 2 ){
            undef $t;
            $cv->send(\@ret);
        }
    }
);
is_deeply( $cv->recv, [[1,2,3],[4,5,6]] );
unlink $fname;

done_testing;

