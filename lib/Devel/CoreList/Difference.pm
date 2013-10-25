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

use Class::Tiny { perl_version => sub { $] }, };

sub dmap_2 {
  my ( $self, $hook ) = @_;
  my @modules;
  my %seen;
  for my $version ( sort keys %Module::CoreList::version ) {
    for my $module ( sort keys %{ $Module::CoreList::version{$version} } ) {
      next if $seen{$module};
      $seen{$module} = 1;
      require Devel::CoreList::Difference::Module;
      my $module = Devel::CoreList::Difference::Module->new( module_name => $module, perl_version => $self->perl_version );
      push @modules, $module;
      $hook->($module) if $hook;
    }
  }
  return @modules;

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
