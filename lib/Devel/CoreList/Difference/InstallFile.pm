use strict;
use warnings;

package Devel::CoreList::Difference::InstallFile;
use Config;
use Path::Tiny;

use Class::Tiny qw(config_name module_name), {
  notional_name => sub {
    my ($self) = @_;
    require Module::Runtime;
    return Module::Runtime::module_notional_filename( $self->module_name );
  },
  config_root => sub {
    my ($self) = @_;
    return $Config{ $self->config_name };
  },
  exists => sub {
    my ($self) = @_;
    return unless defined $self->config_root;
    return unless length $self->config_root;
    my $root = path( $self->config_root );
    return unless -e $root;
    my $exp_path = $root->child( $self->notional_name );
    return -e $exp_path;
  },
  file => sub {
    my ($self) = @_;
    return unless $self->exists;
    return path( $self->config_root )->child( $self->notional_name );
  },
  version => sub {
    my ($self) = @_;
    return unless $self->exists;
    require Module::Metadata;
    my $meta = Module::Metadata->new_from_file( $self->file );
    return $meta->version;
  },
};

1;

