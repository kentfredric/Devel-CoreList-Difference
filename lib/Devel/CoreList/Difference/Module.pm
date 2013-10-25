use strict;
use warnings;

package Devel::CoreList::Difference::Module;

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
