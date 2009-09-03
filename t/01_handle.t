use strict;
use warnings;
use AE;
use AnyEvent::MessagePack;
use AnyEvent::Handle;
use File::Temp qw(tempfile);
use Test::More;

my ($fh, $fname) = tempfile(UNLINK => 0);
my $cv = AnyEvent->condvar;
{
    my $hdl = AnyEvent::Handle->new(fh => $fh, on_error  => sub { die 'wtf' });
    $hdl->push_write(msgpack => [1,2,3]);
    close $fh;
}

my $hdl = do {
    open my $fh, '<', $fname or die $!;
    my $hdl = AnyEvent::Handle->new(fh => $fh, on_error  => sub { die 'wtf' });
    $hdl->push_read(msgpack => sub {
        my ($hdl, $data) = @_;
        $cv->send($data);
    });
    $hdl;
};

my $data = $cv->recv;
is_deeply($data, [1,2,3]);

unlink $fname;

done_testing;

