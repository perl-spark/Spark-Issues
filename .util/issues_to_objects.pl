#!/usr/bin/env perl

use strict;
use warnings;
use 5.14.1;
# FILENAME: issues_to_objects.pl
# CREATED: 18/08/11 08:18:13 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: Convert split Issues to combined ones.

use Path::Class::File;

use lib Path::Class::File->new( __FILE__ )->parent->parent->subdir('.lib')->stringify;

use Issue;
use Issue::Dir;

my $root = Path::Class::File->new( __FILE__)->parent->parent;

my $id = Issue::Dir->new(
  root_dir => $root
);

my $issues = $root->subdir('issues');
my $issue_objects = $root->subdir('issue_objects');

foreach my $issue (@{ $id->issues }){
  my $fname = $issue->id . ".json";
  my $fh = $issue_objects->file( $fname )->openw;
  $fh->print($issue->encode_json);
  $fh->close;
}




