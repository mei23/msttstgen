package MstAtom;

use strict;
use LWP::UserAgent;
use HTTP::Request;
use Data::Dumper;
use URI::Escape;
use XML::Simple;

our $VERSION = '0.1';
our $DEBUG = 1;

# Constructor
sub new {
    my ($class, $opts) = @_;

    my $ua = LWP::UserAgent->new(
        agent => $opts->{'agent'} || "MstAtom/$VERSION",
        timeout => $opts->{'timeout'} || 30,
    );

    my $self = {
        ua => $ua,
    };

    return bless $self, $class;
}


sub get {
    my ($self, $url) = @_;

    my $ua = $self->{'ua'};

    my $req = HTTP::Request->new("GET", $url);
    #$req->header(
    #);
    my $res = $ua->request($req);

    if (!$res->is_success) {
        die $res->status_line;
    }
    
    my $xml = $res->decoded_content;
    my $ref = XMLin($xml, ForceArray => [ 'entry' ], KeyAttr => []);

    return {
        ref => $ref,
        content => $xml,
    };
}

1;

