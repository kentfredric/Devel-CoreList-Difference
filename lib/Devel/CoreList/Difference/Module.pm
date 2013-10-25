use strict;
use warnings;

package Devel::CoreList::Difference::Module;
BEGIN {
  $Devel::CoreList::Difference::Module::AUTHORITY = 'cpan:KENTNL';
}
{
  $Devel::CoreList::Difference::Module::VERSION = '0.001000';
}

# ABSTRACT: Metadata of a single module difference

use Config;
my (@path_keys) = grep { $_ =~ /(lib|arch)exp$/ } keys %Config;

use Class::Tiny qw(module_name), {
  perl_version          => sub { $] },
  installed_in_corelist => sub {
    my ($self) = @_;
    require Module::CoreList;
    return exists $Module::CoreList::version{ $self->perl_version }{ $self->module_name };
  },
  corelist_version => sub {
    my ($self) = @_;
    require Module::CoreList;
    return $Module::CoreList::version{ $self->perl_version }{ $self->module_name };
  },
  notional_name => sub {
    my ($self) = @_;
    require Module::Runtime;
    return Module::Runtime::module_notional_filename( $self->module_name );
  },
  installed => sub {
    my ($self) = @_;
    require Devel::CoreList::Difference::InstallFile;
    return [
      grep { $_->exists }
      map { Devel::CoreList::Difference::InstallFile->new( config_name => $_, module_name => $self->module_name, ) } @path_keys
    ];
  },
  is_installed => sub {
    my ($self) = @_;
    return scalar @{ $self->installed };
  },
  installed_missmatching => sub {
    my ($self) = @_;
    my @out;
    for my $installed ( @{ $self->installed } ) {
      if ( not defined $self->corelist_version and not defined $installed->version ) {
        next;
      }
      if ( not defined $self->corelist_version and defined $installed->version ) {
        push @out, $installed;
        next;
      }
      if ( defined $self->corelist_version and not defined $installed->version ) {
        push @out, $installed;
        next;
      }
      if ( $self->corelist_version != $installed->version ) {
        push @out, $installed;
        next;
      }
    }
    return \@out;
  },
  has_installed_missmatches => sub {
    my ($self) = @_;
    return scalar @{ $self->installed_missmatching };
  },
};

__END__

=pod

=encoding UTF-8

=head1 NAME

Devel::CoreList::Difference::Module - Metadata of a single module difference

=head1 VERSION

version 0.001000

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
