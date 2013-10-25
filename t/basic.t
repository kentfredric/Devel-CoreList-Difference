
use strict;
use warnings;

use Test::More;

use Devel::CoreList::Difference;
use Data::Dump qw(pp);
my $cl = Devel::CoreList::Difference->new();

sub badlibexp {
  my ($lib) = @_;
  if ( $lib !~ /^site/ ) {
    return "\e[35m$lib\e[0m";
  }
  return $lib;
}
if ( ( $ENV{AUTOMATED_TESTING} or $ENV{NONINTERACTIVE_TESTING} ) and not( $ENV{CORELIST_DIFFERENCE} ) ) {
  diag("Automated display of differences deemed unwanted for non-end-users.");
  diag("Set CORELIST_DIFFERENCE=1 to run this test with terminal output");
  pass();
  done_testing();
  exit 0;
}
$cl->dmap_2(
  sub {
    my $module = shift;
    if ( $module->installed_in_corelist and not $module->installed ) {
      printf STDERR "\e[31m[<corelist only]\e[0m %s (\e[31mwanted %s\e[0m)\n", $module->module_name, $module->corelist_version;
      return;
    }

    if ( not $module->installed_in_corelist and $module->installed ) {
      for my $installed ( @{ $module->installed } ) {
        my $v = $installed->version;
        $v = 'undef' if not defined $v;
        printf STDERR "\e[32m[>system only]\e[0m %s/%s @ %s\n", badlibexp( $installed->config_name ), $installed->module_name, $v;
      }
      return;

    }
    require version;
    if ( $module->has_installed_missmatches ) {
      for my $missmatch ( @{ $module->installed_missmatching } ) {
        my $clv   = $module->corelist_version;
        my $iv    = $missmatch->version;
        my $class = "";
        if ( defined $clv and not defined $iv ) {
          $class = "\e[31mdowngraded: defined -> undef\e[0m";
        }
        elsif ( not defined $clv and defined $iv ) {
          $class = "\e[32mupgraded: undef -> defined\e[0m";
        }
        elsif ( version->parse($clv) > version->parse($iv) ) {
          $class = "\e[31mdowngraded: $clv < $iv\e[0m";
        }
        else {
          $class = "\e[32mupgraded: $clv > $iv\e[0m";
        }

        for ( $clv, $iv ) {
          $_ = 'undef' unless defined $_;
        }
        printf STDERR "\e[33m[!=corelist version]\e[0m %s/%s @ %s (\e[31mcore=%s\e[0m)[%s]\n",
          badlibexp( $missmatch->config_name ), $missmatch->module_name, $iv, $clv, $class;
      }
    }
  }
);

pass();
done_testing;
1;
