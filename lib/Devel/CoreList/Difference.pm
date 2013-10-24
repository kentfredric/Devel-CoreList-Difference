use strict;
use warnings;

package Devel::CoreList::Difference;
BEGIN {
  $Devel::CoreList::Difference::AUTHORITY = 'cpan:KENTNL';
}
{
  $Devel::CoreList::Difference::VERSION = '0.001000';
}

# ABSTRACT: Report how the *current* Perl differs from corelist

use Module::CoreList;
use Module::Metadata;
use Module::Runtime qw( module_notional_filename );
use Path::Tiny qw(path);
use Config;


sub _cfg_to_path {
  my ($regexp) = @_;
  my @out;

  for ( keys %Config ) {
    next unless $_ =~ $regexp;
    next unless defined $_;
    next unless defined $Config{$_};
    next unless length $Config{$_};
    push @out, path( $Config{$_} );
  }
  return \@out;
}

use Class::Tiny {
  perl_version   => sub { $] },
  site_paths     => sub { _cfg_to_path(qr/site(arch|lib)exp$/) },
  all_paths      => sub { _cfg_to_path(qr/(arch|lib)exp$/) },
  metadata_cache => sub {
    my ($self) = @_;
    return $Module::CoreList::version{ $self->perl_version };
  },
  all_modules_ever_core => sub {
    my ($self) = @_;
    my %cache;
    for my $version ( keys %Module::CoreList::version ) {
      for my $module ( keys %{ $Module::CoreList::version{$version} } ) {
        $cache{$module} = 1;
      }
    }
    return [ sort keys %cache ];
  },
};

sub find_module {
  my ( $self, $module_name ) = @_;
  my $name = module_notional_filename($module_name);
  return grep { -e $_ and -f $_ } map { $_->child($name) } @{ $self->all_paths };
}

sub module_vmap {
  my ( $self, $module_name ) = @_;
  my (@files) = $self->find_module($module_name);
  my $mesh = { module => $module_name };
  $mesh->{corelist}->{exists}  = $self->has_pristine_version($module_name);
  $mesh->{corelist}->{version} = $self->pristine_version($module_name) if $mesh->{corelist}->{exists};
  $mesh->{installed}           = {};

  for my $file (@files) {
    my $info = Module::Metadata->new_from_file("$file");
    my $v    = $info->version;
    $mesh->{installed}->{"$file"} = $v;
  }
  return $mesh;
}

sub has_pristine_version {
  my ( $self, $module ) = @_;
  return exists $self->metadata_cache->{$module};
}

sub pristine_version {
  my ( $self, $module ) = @_;
  return $self->metadata_cache->{$module};
}

sub whole_map {
  my ($self) = @_;
  my @out;

  for my $module ( @{ $self->all_modules_ever_core } ) {
    push @out, $self->module_vmap($module);
  }
  return \@out;
}

sub diff_map {
  my ($self) = @_;
  my $all = $self->whole_map;
  for my $item ( @{$all} ) {
    if ( $item->{corelist}->{exists} and not keys %{ $item->{installed} } ) {
      printf "\e[31m[corelist.exists system.!exists]\e[0m %s\n", $item->{module};
      next;
    }
    if ( not $item->{corelist}->{exists} and keys %{ $item->{installed} } ) {
      printf "\e[32m[corelist.!exists system.exists]\e[0m %s\n", $item->{module};
      next;
    }
    next unless $item->{corelist}->{exists};
    for my $file ( keys %{ $item->{installed} } ) {
      my $version = $item->{corelist}->{version};
      my $iv      = $item->{installed}->{$file};
      next if not defined $iv and not defined $version;
      next if defined $iv and defined $version and $version == $iv;
      $version = 'undef' unless defined $version;
      $iv      = 'undef' unless defined $iv;
      printf "\e[33m[!=corelist version]\e[0m %s (\e[31mcore=%s\e[0m vs \e[32msystem=%s\e[0m)\n", $file, $version, $iv;
      next;
    }
  }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Devel::CoreList::Difference - Report how the *current* Perl differs from corelist

=head1 VERSION

version 0.001000

=head1 SYNOPSIS

This module intends to give feedback on how Config{*} paths contain
modules at versions other than the ones that shipped with your factory perl.

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
