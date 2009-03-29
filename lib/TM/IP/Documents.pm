package TM::IP::Documents;

use strict;
use warnings;

use Catalyst::Runtime '5.70';

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use parent qw/Catalyst/;
use Catalyst qw/
                -Log=INFO
                ConfigLoader
                Static::Simple/;

our $VERSION = '0.01';

__PACKAGE__->config( name => 'TM::IP::Documents' );
__PACKAGE__->log(Catalyst::Log->new( 'warn', 'error' ));
__PACKAGE__->setup();

=pod

=head1 NAME

TM::IP::Documents - REST service for Topic Maps document subspaces

=head1 ABSTRACT

This Catalyst controller offers RESTful services to interact with a
Topic Maps based document repository.

=head1 SYNOPSIS

    script/tm_ip_documents_server.pl

=head1 SEE ALSO

L<TM::IP::Documents::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Robert Barta, C<< <rho at devc.at> >>

=head1 COPYRIGHT & LICENSE

Copyright 200[9] Robert Barta, all rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl
itself.

=cut

1;
