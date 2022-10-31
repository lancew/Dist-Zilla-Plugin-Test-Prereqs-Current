use strict;
use warnings;
package Dist::Zilla::Plugin::Test::Prereqs::Current;

 # ABSTRACT: Tests your module has up to date dependencies

use 5.008;
our $VERSION = '0.01';


use Moose;
extends 'Dist::Zilla::Plugin::InlineFiles';
with 'Dist::Zilla::Role::FilePruner';

# Make sure we've included a META.json:

sub prune_files
{
  my $self = shift;

  my $files = $self->zilla->files;

  unless (grep { $_->name eq 'dist.ini' } @$files) {
    $self->log("WARNING: dist.ini not found, removing t/00-all_prereqs_current.t");
    @$files = grep { $_->name ne 't/00-all_prereqs_current.t' } @$files;
  } # end unless META.json

  return;
} # end prune_files

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__DATA__
___[ t/00-all_prereqs_current.t ]___
#!perl

use strict;
use warnings;

use App::UpdateCPANfile::PackageDetails;
use Dist::Zilla::Util::ParsePrereqsFromDistIni qw(parse_prereqs_from_dist_ini);
use Test::More;

my $prereqs = parse_prereqs_from_dist_ini(path => 'dist.ini');
my $checker = App::UpdateCPANfile::PackageDetails->new;

for my $key (sort keys %$prereqs) {
    for my $req (sort keys %{$prereqs->{$key}->{requires}}) {
        my $current_version = $prereqs->{$key}->{requires}->{$req};
        $current_version =~ s/v//g;
        my $latest_version = $checker->latest_version_for_package($req) || '0';
        my $out_of_date = ($latest_version <= $current_version);

        ok( $out_of_date,"$req: Current:$current_version, Latest:$latest_version");
    }
}
done_testing();
__END__
