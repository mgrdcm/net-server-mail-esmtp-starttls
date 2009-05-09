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

    $self->reply( 220, '2.0.0 Ready to start TLS' );

    IO::Socket::SSL->start_SSL(
        $self->{out},
        SSL_server         => 1,
        Timeout            => 30,
        SSL_startHandshake => 1
      )
      || die "Encountered an SSL handshake problem: "
      . IO::Socket::SSL::errstr();


  	my $ref = $self->{callback}->{STARTTLS};
  	if (ref $ref eq 'ARRAY' && ref $ref->[0] eq 'CODE') {
  		my $code = $ref->[0];

  		my $ok = &$code($self);
  	}

    # should remove STARTTLS from registered extensions
  	
    return ();
}

*Net::Server::Mail::ESMTP::starttls = \&starttls;

=head1 AUTHOR

Dan Moore, C<< <dan at moore.cx> >>

=head1 BUGS

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


=head1 COPYRIGHT & LICENSE

Copyright 2009 Dan Moore, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;    # End of Net::Server::Mail::ESMTP::STARTTLS
