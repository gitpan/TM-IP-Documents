package TM::IP::Documents::Controller::Root;

use strict;
use warnings;
use Switch;

use Data::Dumper;
use HTTP::Status qw(:constants);

use base 'Catalyst::Controller::REST';

=pod

=head1 NAME

TM::IP::Documents::Controller::Root - Root Controller for TM::IP::Documents

=head1 DESCRIPTION

TMIP is a suite of RESTful protocols to communicate with Topic Maps (TM) based servers. This
controller deals with the I<document subspace>, i.e. a part of a topic map which can hold documents
inside a repository.

=head2 Map Addressing

Like for all TMIP protocols, the topic map is addressed first using a URL structure like

  http://my.server/internet/web/

where C</> is the root map, C<internet> one submap and C<web> a submap under that. Underneath that
mount point the document repository resides, by selected with C<.docs/>:

  http://my.server/internet/web/.docs/

=cut

__PACKAGE__->config->{namespace} = '';

Catalyst::Controller::REST->config->{map}->{'text/html'} = [ 'View', 'Mason' ];
Catalyst::Controller::REST->config->{map}->{'*/*'} = 'YAML';

=pod

=head2 HTTP Methods

The operations offered by this subspace are pretty obvious:

=over

=item C<GET ..../.docs/index>

This returns a file listing of all documents in that repository. If the C<Accept> header is set to
C<application/json>, then a hash (dictionary) is generate in JSON, containing the file name as key
and as value a record with C<size>, C<mime> and C<modified> information.

B<TODO>: If the C<Accept> header is C<text/html>, then a HTML table is returned. @@@@@@@@@

All other C<Accept> headers with result in an error.

B<TODO> : POST ../index + document???,    POST   /      + docuemtn @@@@@@

=cut

sub index : Regex('(.+)\.docs/index$') : ActionClass('REST') { }

sub _find_mime {
    my $f = shift;
    my $m = `file -b -I $f | awk -F ';' 'BEGIN {ORS=""} {print \$1}'`;    # low-tech mime
    return $m || 'application/octet-stream';                              # default value if none could be found
}

sub index_GET {
    my ( $self, $c) = @_;

    my ($mappath) = @{ $c->req->snippets };
    my $dir = $c->config->{mapbase} . $mappath . '.docs/';
    $c->log->debug ( "GET index: dir= $dir" );

    opendir DIR, $dir or die "cannot open docs directory for $mappath";
    my %files = map { $_->[-1] => {                                            # build an info set for that file
	                             'mime'     => _find_mime ("$dir/".$_->[-1]),
				     'size'     => $_->[7],
				     'modified' => $_->[9]
		                   } }
                map  { [ stat ("$dir/$_"), $_ ]; }                             # call the stat on each of them, remember name as last
                grep { $_ !~ /^\./ && -f "$dir/$_" }                           # get rid of dot files and anything which is not a file
                readdir(DIR);                                                  # get all directory entries
    closedir DIR;

    $c->log->debug ( "GET index". Dumper \%files );
    
    switch ($c->req->headers->header ('Accept')) {
	case 'application/json'  { $self->status_ok ($c, entity => \%files) };
	case 'text/html'         { }
	else { die };
    }
}

=pod

=item C<GET  ...../.docs/>I<some_file_name>

This method does the obvious, it retrieves the named file from the document repository. Hereby all
relevant headers should be set properly:

=over

=item C<Content-Type>: guess from the file content

=item C<Content-Length>: size in bytes

=back

B<TODO>: Last mod

=cut

sub file  : Regex('(.+)\.docs/(.+)$')  : ActionClass('REST') { }

sub file_GET {
    my ( $self, $c) = @_;

    my ($mappath, $file) = @{ $c->req->snippets };
    $file = $c->config->{mapbase} . $mappath . '.docs/' . $file;         # produce the real path
    $c->log->debug ( "file: $file" );

    if (! -f $file) {
	$self->status_not_found ($c, message => "Cannot find object '$file'" );
    } elsif (! -r $file) {
	$self->status_bad_request($c, message => "Cannot do what you have asked!");
    } else {
	use File::Slurp;
	my $content = read_file( $file );
	$c->response->body           ($content);
	$c->response->content_length (length ($content) );
	$c->response->content_type   (_find_mime ($file));
    }
}

=pod

=item C<PUT  ...../.docs/>I<some_file_name>

This method takes the message body and tries to store that as the contents inside the repository for
the file named. If the file already exists, it will be overwritten.

TODO: size limit on request, size limit on repository

=cut

sub file_PUT {
    my ( $self, $c) = @_;
    my ($mappath, $file) = @{ $c->req->snippets };

    my $filepath = $c->config->{mapbase} . $mappath . '.docs/' . $file;         # produce the real path
    $c->log->debug ( "PUT file: $filepath" );
    $c->log->debug ( $c->request->content_type );
    $c->log->debug ( $c->request->body );
    if (rename $c->request->body, $filepath) {
	$self->status_created ($c, 
			       location => $c->req->uri->as_string,
			       entity   => undef);
    } else {
	$self->status_bad_request($c, message => "Cannot store file '$file'" );
    }
}

=pod

=item C<DELETE  ...../.docs/>I<some_file_name>

This method tries to delete the named file in the document repository. If the file did not exist,
then a NOT_FOUND otherwise a NO_CONTENT will be returned.

=cut

sub file_DELETE {
    my ( $self, $c) = @_;
    my ($mappath, $file) = @{ $c->req->snippets };

    my $filepath = $c->config->{mapbase} . $mappath . '.docs/' . $file;         # produce the real path
    $c->log->debug ( "DELETE file: $filepath" );

    if (! -f $filepath) {                                                       # if it is not there
	$c->response->status (HTTP_NOT_FOUND);
    } elsif (unlink $filepath) {                                                # if its there and we can remove it
	$c->response->status (HTTP_NO_CONTENT);
    } else {                                                                    # cannot remove it
	$self->status_bad_request($c, message => "Cannot delete file '$file'" );
    }

}

=pod

=cut

sub end   :                              ActionClass('Serialize') {}

=pod

=back

=head1 AUTHOR

Robert Barta, C<< <rho at devc.at> >>

=head1 SEE ALSO

L<TM::IP>

L<http://kill.devc.at/internet/semantic-web/topic-maps/tmip>

=head1 COPYRIGHT & LICENSE

Copyright 200[9] Robert Barta, all rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl
itself.

=cut

our $VERSION = '0.01';

1;
