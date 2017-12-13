#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use IO::Handle;
use Time::Local;
use POSIX qw( strftime );
use MstAtom;

# read arg
if (@ARGV != 2) {
    print STDERR "Usage: $0 <atom feed url>\n";
    exit 2;
}
my ($url, $outfile) = @ARGV;

# output file
open my $OUT, '>', $outfile or die "Can't open $outfile, $!";
$OUT->autoflush;

# prepare fetcher
my $atom = MstAtom->new();

foreach my $page (1 .. 5000) {
    # fetch
    printf STDERR "FetchURL[%d]: %s\n", $page, $url; 
    my $r = $atom->get($url);
    my $ref = $r->{'ref'};

    # entries
    foreach my $entry (@{$ref->{'entry'}}) {

        # entry id
        my $id = $entry->{'id'};

        # to StausID
        my $status_id = $id =~ m{/(\d+)$} ? $1 : undef;
        if ($id =~ m{/(\d+)$}) {
            $status_id = $1;
        }
        elsif ($id =~ /objectId=(\d+)/) { # older
            $status_id = $1;
        }
        if (!$status_id) {
            die "Can't get StatusID. entry-id: $id";
        }

        # datetime
        my $published = $entry->{'published'};  # ISO8601 Z
        my $time;
        if ($published =~ /^(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)Z$/) {
            $time = timegm($6,$5,$4,$3,$2-1,$1);
        }
        if (!$time) {
            die "Can't get StatusID. entry-published: $published";
        }
        my $date_str = strftime('%Y/%m/%d %H:%M:%S', localtime($time));

        # output
        print {$OUT} "$time,$status_id,$published\n";
        print STDERR "UNIX=$time, ID=$status_id, ISO=$published, Local=$date_str\n";
    }

    # get next url
    my ($next_url) = map { $_->{'href'} }
        grep { $_->{'rel'} eq 'next' }
        @{ $ref->{'link'} };

    printf STDERR "NextURL: %s\n", $next_url; 

    if (!$next_url) {
        print STDERR "May EOF, exit.\n";
        last;
    }

    sleep 1;
    $url = $next_url;
}


