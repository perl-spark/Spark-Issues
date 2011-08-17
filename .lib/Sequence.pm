use strict;
use warnings;
package Sequence;
# FILENAME: Sequence.pm
# CREATED: 18/08/11 10:25:11 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: Return a sequential unique ID backed by some file

use Moose;
use MooseX::ClassAttribute;
use MooseX::Types::Moose qw( :all );
use MooseX::Types::Path::Class qw(:all);
use Try::Tiny;

has 'root_dir' => ( isa => Dir, is => 'rw' , required => 1 );
has 'sequence_dir' => ( isa => Dir, is => 'rw', lazy => 1, default => sub { $_[0]->root_dir->subdir('sequences') } );
has 'sequence_name' => ( isa => Str, is => 'rw', required => 1 );

class_has _jsonifier => (
  isa     => Object,
  is      => 'ro',
  lazy    => 1,
  default => sub {
    require JSON;
    return JSON->new()->pretty;
  }
);

has 'last_id' => (
  isa => Int, 
  is => 'rw',
  lazy => 1, 
  default => sub {
    my $self = shift;
    my $x;
    try {
      $x = $self->_unjson( $self->sequence_dir , $self->sequence_name )->[0];
    } catch {
      warn $_;
      $x = 0;
    };
    return $x;
  },
  traits => [qw( Counter )],
  handles => {
    'inc_id' => ['inc',1],
    'set_id' => 'set',
  }
);

with 'JSONIZER';

if( not $Sequence::VERSION ){
  $Sequence::VERSION = '0.1.0.9999';
}

sub decode_hash {
  my ( $class, $hash ) = @_;
  my $options;
  for my $opt ( qw( last_id sequence_name ) ) {
    if ( defined $hash->{$opt} ){
      $options->{$opt} = delete $hash->{$opt};
    }
  }
  return $class->new( $options );
}

sub encode_hash {
  my ( $object ) = shift;
  return {
    '#' => { class => 'Sequence', version => $Sequence::VERSION },
    last_id => $object->last_id,
    sequence_name => $object->sequence_name,
  };
}

sub generate_id {
  my ( $object ) = shift;
  my $id = $object->inc_id;
  $object->commit;
  return $id;
}

sub commit {
  my ( $object ) = shift;
  $object->_json(  $object->sequence_dir , $object->sequence_name, [ $object->last_id ] );
  return $object;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;


