package Perinci::Sub::Util::DepModule;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(
                       get_required_dep_modules
               );

sub _find {
    my ($deps, $res) = @_;

    return unless $deps;
    $res->{"Perinci::Sub::DepChecker"} = 0;
    for my $k (keys %$deps) {
        if ($k =~ /\A(any|all|none)\z/) {
            my $v = $deps->{$k};
            _find($_, $res) for @$v;
        } elsif ($k =~ /\A(env|code|prog|pkg|func|exec|tmp_dir|trash_dir|undo_trash_dir)\z/) {
            # skip builtin deps supported by Perinci::Sub::DepChecker
        } else {
            $res->{"Perinci::Sub::Dep::$k"} = 0;
        }
    }
}

sub get_required_dep_modules {
    my $meta = shift;

    my %res;
    _find($meta->{deps}, \%res);
    \%res;
}

1;
# ABSTRACT: Given a Rinci function metadata, find what dep modules are required

=head1 SYNOPSIS

 use Perinci::Sub::Util::DepModule qw(get_required_dep_modules);

 my $meta = {
     v => 1.1,
     deps => {
         prog => 'git',
         any => [
             {pm => 'Foo::Bar'},
             {pm => 'Foo::Baz'},
         ],
     },
     ...
 };
 my $mods = get_required_dep_modules($meta);

Result:

 {
     'Perinci::Sub::DepChecker' => 0,
     'Perinci::Sub::Dep::pm' => 0,
 }


=head1 FUNCTIONS

=head2 get_required_dep_modules($meta) => array

Dpendencies are checked by L<Perinci::Sub::DepChecker> as well as other
C<Perinci::Sub::Dep::*> modules for custom types of dependencies.

This function can detect which modules are used.

This function can be used during distribution building to automatically add
those modules as prerequisites.
