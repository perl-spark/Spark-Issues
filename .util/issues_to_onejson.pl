#!/usr/bin/env perl 

use strict;
use warnings;
use 5.14.1;
# FILENAME: issues_to_onejson.pl
# CREATED: 18/08/11 09:06:37 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: Combine all issues into one big JSON file

use Path::Class::File;

use lib Path::Class::File->new( __FILE__ )->parent->parent->subdir('.lib')->stringify;

use Issue;

my $root = Path::Class::File->new( __FILE__)->parent->parent;

my $issues = $root->subdir('issues');

my @data = ();

foreach my $directory ( $issues->children() ){ 
  next unless $directory->is_dir;
  my $issue = Issue->load_dir( $directory );
  push @data, $issue->encode_hash;
}

my $fh = $root->file('issues.json')->openw;
require JSON;
$fh->print( JSON->new()->pretty->encode( \@data ) );
$fh->close;
