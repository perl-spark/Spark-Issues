use strict;
use warnings;
package Issue::Dir;
# FILENAME: Dir.pm
# CREATED: 18/08/11 09:14:24 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: Work with a collection of Issue dirs in a dir

use Moose;
use Issue;
use MooseX::Types::Moose qw( :all );
use MooseX::Types::Path::Class qw( :all );

has 'issue_dir' => ( isa => Dir, coerce => 1, is => 'rw', lazy => 1, default => sub { $_[0]->root_dir->subdir('issues') } );
has 'root_dir' => ( isa => Dir, is => 'rw', required => 1, coerce => 1 );

sub issues {
  my $object = shift;
  my @data;
  foreach my $directory ( $object->issue_dir->children() ){
    next unless $directory->is_dir;
    my $issue = Issue->load_dir( $directory );
    push @data, $issue;
  }
  return \@data;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;


