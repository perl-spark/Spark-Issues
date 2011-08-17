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
use Issue::Dir;

my $root = Path::Class::File->new( __FILE__)->parent->parent;

my $id = Issue::Dir->new(
  root_dir => $root
);

my @data = map { $_->encode_hash } @{ $id->issues  };

my $fh = $root->file('issues.json')->openw;
require JSON;
$fh->print( JSON->new()->pretty->encode( \@data ) );
$fh->close;
