package AnyEvent::MessagePack;
use strict;
use warnings;

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

        sub {
            my $buffer = delete $_[0]{rbuf} or return;

            my $complete = 0;
            my $nread    = 0;
            while(1) {
                unless (eval { $nread = $unpacker->execute($buffer, $nread); 1 }) {
                    $self->_error(Errno::EBADMSG);
                    return;
                }
                if ($unpacker->is_finished) {
                    my $ret = $unpacker->data;
                    $cb->( $_[0], $ret );
                    $unpacker->reset;
                    $complete++;

                    if( $nread >= length($buffer) ) {
                        last;
                    }
                }
                else {
                    last;
                }

            }
            return $complete;
        }
    });
}

1;
__END__

=head1 NAME

AnyEvent::MessagePack - MessagePack stream serializer/deserializer for AnyEvent

=head1 SYNOPSIS

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

=head1 DESCRIPTION

AE::MessagePack is MessagePack stream serializer/deserializer for AnyEvent.

=head1 THANKS TO

kazeburo++

=head1 SEE ALSO

L<AnyEvent::Handle>, L<AnyEvent::MPRPC>

