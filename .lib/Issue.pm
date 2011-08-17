use strict;
use warnings;

package Issue;

# FILENAME: Issue.pm
# CREATED: 18/08/11 07:28:42 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: A basic Issue object abstraction

use Moose;
use MooseX::ClassAttribute;
use MooseX::Types::Moose qw( :all );

has id => ( isa => Int, is => 'rw', required => 1 );
has tags => ( isa => ArrayRef [Str], is => 'rw', default => sub { [] } );
has title       => ( isa => Str, is => 'rw', required => 1 );
has description => ( isa => Str, is => 'rw', required => 1 );
has status    => ( isa => ArrayRef [Str], is => 'rw', default => sub { [qw( open )] }, );
has milestone => ( isa => ArrayRef [Str], is => 'rw', default => sub { [] }, );

class_has _jsonifier => (
  isa     => Object,
  is      => 'ro',
  lazy    => 1,
  default => sub {
    require JSON;
    return JSON->new();
  }
);

sub _expand_filename {
  my ( $class, $dir, $filename ) = @_;
  require Path::Class::Dir;
  return Path::Class::Dir->new($dir)->file($filename)->absolute;
}

sub _unjson {
  my ( $class, $dir, $filename ) = @_;
  return $class->_jsonifier->decode( $class->_unraw( $dir, $filename ), );
}

sub _unraw {
  my ( $class, $dir, $filename ) = @_;
  return scalar $class->_expand_filename( $dir, $filename )->slurp;
}

sub _raw {
  my ( $class, $dir, $filename, $text ) = @_;
  my $file = $class->_expand_filename( $dir, $filename );
  $file->parent->mkpath();
  my $fh = $file->openw;
  $fh->print($text);
  $fh->close;
  return;
}

sub _json {
  my ( $class, $dir, $filename, @data ) = @_;
  $class->_raw( $dir, $filename, $class->_jsonifier->encode(@data) );
  return;
}

sub load_dir {
  my ( $class, $dir ) = @_;
  my %config = ();
  $config{id}   = $class->_unjson( $dir, 'id' )->[0];
  $config{tags} = $class->_unjson( $dir, 'tags' );
  chomp( $config{title}       = $class->_unraw( $dir, 'title' ) );
  chomp( $config{description} = $class->_unraw( $dir, 'description' ) );
  $config{status}    = $class->_unjson( $dir, 'status' );
  $config{milestone} = $class->_unjson( $dir, 'milestone' );
  return $class->new( \%config );
}

sub write_dir {
  my ( $object, $dir ) = @_;
  $object->_json( $dir, 'id', [ $object->id ] );
  $object->_json( $dir, 'tags',      $object->tags );
  $object->_json( $dir, 'status',    $object->status );
  $object->_json( $dir, 'milestone', $object->milestone );
  $object->_raw( $dir, 'title', $object->title );
  $object->_raw( $dir, 'description', $object->description );
}

if( not $Issue::VERSION ){ 
  $Issue::VERSION = '0.1.0.9999';
}


sub encode_hash {
  my ( $object) = shift;
  return {
    '#' => { class => 'Issue', version => $Issue::VERSION },
    id => $object->id, 
    tags => $object->tags,
    status => $object->status,
    milestone => $object->milestone,
    title => $object->title,
    description => $object->description,
  };
}
sub decode_hash {
  my ( $class, $hash ) = @_;

  my $options;

  for my $opt ( qw( id tags status milestone title description ) ) {
    if ( defined $hash->{$opt} ){
      $options->{$opt} = delete $hash->{$opt};
    }
  }  
  return $class->new( $options );
}

sub encode_json {
  my ( $object ) = shift;
  return $object->_jsonifier->encode( 
    $object->encode_hash()
  );
}

sub decode_json {
  my ( $class, $text ) = @_;
  return $class->decode_hash( 
    $class->_jsonifier->decode( $text )
  );
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

