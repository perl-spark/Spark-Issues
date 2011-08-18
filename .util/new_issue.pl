#!/usr/bin/env perl 

use strict;
use warnings;
use 5.14.1;

# FILENAME: new_issue.pl
# CREATED: 18/08/11 12:38:56 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: Interactive script to make it easier to create issues

use Path::Class::File;

use lib Path::Class::File->new( __FILE__ )->parent->parent->subdir('.lib')->stringify;

use Issue;
use Issue::Dir;

my $root = Path::Class::File->new( __FILE__)->parent->parent;

my @tags = qw( *none* description_is_vauge rfc todo tests internals );
my @milestones = ( '*none*', 'v2.000' );
my @statuses = qw( open closed );

my $issuedir = Issue::Dir->new(
  root_dir => $root
);

use Term::UI;
use Term::ReadLine;

my $term = Term::ReadLine->new('new_issue');

my $id = $issuedir->seq->inc_id;

say "Writing Issue # $id";

my $title = $term->get_reply( print_me => "Please enter the Title for this issue", prompt => "title: ");

my @chosen_tags = $term->get_reply(
    print_me => 'Please Select tags you want, multiples allowed',
    multi => 1,
    prompt => 'tags: ',
    choices => \@tags,
    default => '*none*',
);

my @chosen_milestones = $term->get_reply(
    print_me => 'Please Select milestones you want, multiples allowed',
    multi => 1,
    prompt => 'milestones: ',
    choices => \@milestones,
    default => '*none*',
);

my @chosen_status = $term->get_reply(
    print_me => 'Please Select initial status',
    multi => 1,
    prompt => 'status: ',
    choices => \@statuses,
    default => 'open',
);

my $out = $term->OUT;

print $out "Please enter your message.\n ^D or a . on a line of its own when done.\n";

my $line = 0;
my @lines;

while( defined ( my $text = $term->readline("$line > ") ) ) {
  $line++;
  last if $text =~ /^\s*\.\s*$/;
  push @lines, $text;
  $term->addhistory( $text ) if $text =~ /\S/;
}

for ( @lines ){ 
  print $out ("* " . $_ . "\n");
}

my $issue = Issue->new(
  id => $id,
  tags => [ grep { defined and $_ !~ /^\*none\*/ } @chosen_tags ],
  milestone => [ grep { defined and $_ !~ /^\*none\*/ } @chosen_milestones ],
  status => [ grep { defined and $_ !~ /^\*none\*/ } @chosen_status ],
  title => $title,
  description => join qq{\n}, @lines,
);

say $issue->encode_json;
$issue->write_dir( $issuedir->issue_dir->subdir( sprintf "%05d", $id) );
$issuedir->seq->commit;
