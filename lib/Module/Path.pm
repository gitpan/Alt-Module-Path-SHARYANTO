package Module::Path;

use 5.010001;
use strict;
use warnings;

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(module_path pod_path);

our $VERSION = '0.13.2'; # VERSION
our $DATE = '2014-06-22'; # DATE

our $ALT = 'SHARYANTO';

my $SEPARATOR;

BEGIN {
    if ($^O =~ /^(dos|os2)/i) {
        $SEPARATOR = '\\';
    } elsif ($^O =~ /^MacOS/i) {
        $SEPARATOR = ':';
    } else {
        $SEPARATOR = '/';
    }
}

sub module_path {
    my ($module, $opts) = @_;
    $opts //= {};
    $opts->{abs}      //= 0;
    $opts->{find_pm}  //= 1;
    $opts->{find_pmc} //= 1;
    $opts->{find_pod} //= 0;
    $opts->{find_prefix} //= 0;

    require Cwd if $opts->{abs};

    my @res;
    my $add = sub { push @res, $opts->{abs} ? Cwd::abs_path($_[0]) : $_[0] };

    my $relpath;

    ($relpath = $module) =~ s/::/$SEPARATOR/g;
    $relpath =~ s/\.(pm|pmc|pod)\z//i;

    foreach my $dir (@INC) {
        next if not defined($dir);
        next if ref($dir);

        my $prefix = $dir . $SEPARATOR . $relpath;
        if ($opts->{find_prefix}) {
            if (-d $prefix) {
                $add->($prefix);
                last unless $opts->{all};
            }
        }
        if ($opts->{find_pmc}) {
            my $file = $prefix . ".pmc";
            if (-f $file) {
                $add->($file);
                last unless $opts->{all};
            }
        }
        if ($opts->{find_pm}) {
            my $file = $prefix . ".pm";
            if (-f $file) {
                $add->($file);
                last unless $opts->{all};
            }
        }
        if ($opts->{find_pod}) {
            my $file = $prefix . ".pod";
            if (-f $file) {
                $add->($file);
                last unless $opts->{all};
            }
        }
    }

    if ($opts->{all}) {
        return @res;
    } else {
        return @res ? $res[0] : undef;
    }
}

sub pod_path {
    my ($module, $opts) = @_;
    module_path($module, {find_pm=>0, find_pod=>1, %$opts});
}

1;
# ABSTRACT: Get the path to a locally installed module

__END__

=pod

=encoding UTF-8

=head1 NAME

Module::Path - Get the path to a locally installed module

=head1 VERSION

This document describes version 0.13.2 of Module::Path (from Perl distribution Alt-Module-Path-SHARYANTO), released on 2014-06-22.

=head1 SYNOPSIS

 use Module::Path 'module_path', 'pod_path';

 $path = module_path('Test::More');
 if (defined($path)) {
   print "Test::More found at $path\n";
 } else {
   print "Danger Will Robinson!\n";
 }

 # can also find module in the form that 'require' uses
 $path = module_path();

 # find all found modules, as well as .pmc and .pod files
 @path = module_path('Foo::Bar', {all=>1, find_pmc=>1, find_pod=>1});

 # just an alias for module_path('Foo', {find_pm=>0, find_pod=>1});
 $path = pod_path('Foo');

=head1 DESCRIPTION

This module is an experimental, alternate implementation of L<Module::Path>,
started when Module::Path is at version 0.13. It provides more options (find all
instead of only the first found path, find C<.pmc> and C<.pod> files) and has
some differences in behavior: it does not do abs_path() by default because I
don't think that's the appropriate default.

=head1 FUNCTIONS

=head2 module_path($mod[, \%opts]) => $path (or ($path1, ...))

Find path of module named C<$mod> in C<@INC>, like C<require()> would (except
that it skips references in C<@INC>). C<$mod> can be in the form of
C<Package::SubPkg> or C<Package/SubPkg.pm>.

Options:

=over

=item * abs => BOOL (default: 0)

Perform L<Cwd>'s C<abs_path()> on the found path(s). Unlike Module::Path, will
die if the absolutization fails, because I don't think it's C<module_path()>'s
responsibility to trap weirdness of path.

=item * all => BOOL (default: 0)

Instead of returning the first found path, find all.

=item * find_pm => BOOL (default: 1)

=item * find_pmc => BOOL (default: 1)

Whether to find C<.pmc> files. Like C<require()>, C<.pmc> files are searched
first before C<.pm>.

=item * find_pod => BOOL (default: 0)

=back

=head2 pod_path($mod[, \%opts]) => $path (or ($path1, ...))

Equivalent to:

 module_path($mod, {find_pm=>0, find_pod=>1});

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Alt-Module-Path-SHARYANTO>.

=head1 SOURCE

Source repository is at L<https://github.com/sharyanto/perl-Alt-Module-Path-SHARYANTO>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Alt-Module-Path-SHARYANTO>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
