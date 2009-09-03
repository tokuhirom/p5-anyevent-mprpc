use warnings;
use strict;
package AnyEvent::MessagePack;

use AnyEvent::Handle;

{
    package # hide from pause
        AnyEvent::Handle;

    use Data::MessagePack;
    register_write_type(msgpack => sub {
        my ($self, $data) = @_;
        Data::MessagePack->pack($data);
    });
    register_read_type(msgpack => sub {
        my ($self, $cb) = @_;
        my $unpacker = Data::MessagePack::Unpacker->new();
        my $nread = 0;

        sub {
            my $succeeded = 0;
            my $buffer = $_[0]{rbuf} or return;
            while (1) {
                $nread = $unpacker->execute($buffer, $nread);
                if ($unpacker->is_finished) {
                    my $ret = $unpacker->data;
                    $cb->( $_[0], $ret );
                    $unpacker->reset;

                    $buffer = substr($buffer, $nread);
                    $succeeded++;
                    next if length($buffer) != 0;
                }
                last;
            }
            return $succeeded;
        }
    });
}

1;
__END__

    use AnyEvent::MessagePack;
    use AnyEvent::Handle;

    my $hdl = AnyEvent::Handle->new(
        # settings...
    );
    $hdl->push_write(msgpack => [ 1,2,3 ]);
    $hdl->push_read(msgpack => sub {
        my ($hdl, $data) = @_;
        # your code here
    });

