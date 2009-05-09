package Net::Server::Mail::ESMTP::STARTTLS;

use warnings;
use strict;

use base qw(Net::Server::Mail::ESMTP::Extension);

use IO::Socket::SSL;

=head1 NAME

Net::Server::Mail::ESMTP::STARTTLS - The great new Net::Server::Mail::ESMTP::STARTTLS!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Simple implementation of RFC2487 for Net::Server::Mail::ESMTP.

    use Net::Server::Mail::ESMTP;
    my $server = new IO::Socket::INET Listen => 1, LocalPort => 25;

    my $conn;
    while($conn = $server->accept)
    {
      my $esmtp = new Net::Server::Mail::ESMTP socket => $conn;

      # activate STARTTLS extension
      $esmtp->register('Net::Server::Mail::ESMTP::STARTTLS');

      # adding STARTTLS handler
      $esmtp->set_callback(STARTTLS => \&tls_started);
      $esmtp->process;
    }

    sub tls_started
    {
      my ($session) = @_;

      # now allow authentication
      $session->register('Net::Server::Mail::ESMTP::AUTH');
    }


=head1 FUNCTIONS

=cut

sub verb {
    return [ 'STARTTLS' => 'starttls' ];
}

sub keyword {
    return 'STARTTLS';
}

sub reply {
    return ( [ 'STARTTLS', ] );
}

=head2 starttls

=cut

sub starttls {
    my $self = shift;
    my ($args) = @_;

    if ( defined($args) && $args ne '' ) {
        $self->reply( 501, 'Syntax error (no parameters allowed)' );
        return;
    }

    $self->reply( 220, 'Ready to start TLS' );

    my $sslret = IO::Socket::SSL->start_SSL(
        $self->{out},
        SSL_server         => 1,
        Timeout            => 30,
        SSL_startHandshake => 1
    );

    unless ($sslret) {
        ## This is wrong.  Need to actually recover the connection, which is probably broken at this point.
        $self->reply( 454,
                'TLS not available due to temporary reason' . '['
              . IO::Socket::SSL::errstr()
              . ']' );
    }

    my $ref = $self->{callback}->{STARTTLS};
    if ( ref $ref eq 'ARRAY' && ref $ref->[0] eq 'CODE' ) {
        my $code = $ref->[0];

        my $ok = &$code($self);
    }

    return ();
}

*Net::Server::Mail::ESMTP::starttls = \&starttls;

=head1 AUTHOR

Dan Moore, C<< <dan at moore.cx> >>

=head1 TODO

=head2 RFC Compliance

=over

=item Reset state after success

Quoth RFC2487:  "Upon completion of the TLS handshake, the SMTP protocol is reset to
   the initial state (the state in SMTP after a server issues a 220
   service ready greeting). The server MUST discard any knowledge
   obtained from the client, such as the argument to the EHLO command,
   which was not obtained from the TLS negotiation itself."

=item Remove STARTTLS from list of commands after success

Quoth RFC2487:  "A server MUST NOT return the TLS extension
   in response to an EHLO command received after a TLS handshake has
   completed."

=back

Note, though, that both of the above can be done outside the library.

=head1 BUGS

=over

=item Failed handshaking breaks things badly

When the start_SSL call fails, the connection is probably broken, and the server usually dies.  Need to fix that.

=back

Please report any bugs or feature requests to C<bug-net-server-mail-esmtp-starttls at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-Server-Mail-ESMTP-STARTTLS>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::Server::Mail::ESMTP::STARTTLS


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-Server-Mail-ESMTP-STARTTLS>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-Server-Mail-ESMTP-STARTTLS>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-Server-Mail-ESMTP-STARTTLS>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-Server-Mail-ESMTP-STARTTLS/>

=back


=head1 ACKNOWLEDGEMENTS

Net::Server::Mail rules, but I had to rely on Net::Server::Mail::ESMTP::AUTH as an example for how to write an ESMTP::Extension.  Thanks to the authors of both!

=head1 COPYRIGHT & LICENSE

Copyright 2009 Dan Moore, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;    # End of Net::Server::Mail::ESMTP::STARTTLS
