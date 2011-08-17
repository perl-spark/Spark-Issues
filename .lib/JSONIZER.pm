use strict;
use warnings;
package JSONIZER;
# FILENAME: JSONIZER.pm
# CREATED: 18/08/11 10:27:10 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: A role to bolt a few convenience functions for JSON encoding into a class.

use Moose::Role;

requires '_jsonifier';
requires 'encode_hash';
requires 'decode_hash';

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


no Moose::Role;

1;


