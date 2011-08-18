#!/usr/bin/env perl

use strict;
use warnings;
use 5.14.1;

# FILENAME: mk_symlinks.pl
# CREATED: 18/08/11 08:18:13 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: generate meta-entries in the respective dirs.

use Path::Class::File;

use lib Path::Class::File->new(__FILE__)->parent->parent->subdir('.lib')->stringify;

use Issue;
use Issue::Dir;

my $root = Path::Class::File->new(__FILE__)->parent->parent;

my $issues        = $root->subdir('issues');
my $issue_objects = $root->subdir('issue_objects');
my $statuses      = $root->subdir('statuses');
my $tags          = $root->subdir('tags');
my $milestones    = $root->subdir('milestones');

my @data;

foreach my $directory ( $issues->children() ) {
  next unless $directory->is_dir;
  my $issue = Issue->load_dir($directory);

  my $link_target = $directory->relative($root);

  my $title = $issue->title;
  $title =~ s/^\s*$//msg;          # delete blank lines.
  $title =~ s/\n.*\z//s;           #nuke lines other than first.
  $title =~ s/^\s*//;              # nuke leading whitespace.
  $title =~ s/\s*$//;              # nuke trailing whitespace.
  $title =~ s/[^[:print:]]/-/g;    # replace non-printable.

  $title = sprintf "%05d - %s", $issue->id, $title;

  push @data, { title => $title, link_target => $directory, issue => $issue };
}

sub setup_links {
  my ( $root, $data, $tag_getter ) = @_;
  foreach my $label ( $root->children() ) {
    next unless $label->is_dir;
    foreach my $record ( $label->children() ) {
      next unless -l $record;
      unlink $record->stringify;
    }
    $label->remove();
  }
  foreach my $issue ( @{$data} ) {
    my @tags = $tag_getter->($issue);
    foreach my $label (@tags) {
      my $labeldir = $root->subdir($label);
      $labeldir->mkpath;
      my $newlink = $labeldir->file( $issue->{title} );
      symlink $issue->{link_target}->relative($labeldir)->stringify, $newlink->stringify;
    }
  }
}

setup_links(
  $statuses,
  \@data,
  sub {
    @{ $_[0]->{issue}->{status} };
  }
);

setup_links(
  $tags,
  \@data,
  sub {
    @{ $_[0]->{issue}->{tags} };
  }
);

setup_links(
  $milestones,
  \@data,
  sub {
    @{ $_[0]->{issue}->{milestone} };
  }
);
