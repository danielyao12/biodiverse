#!/usr/bin/perl -w

use 5.010;
use strict;
use warnings;
use Carp;


use Test::Lib;
use Test::More;
use rlib;

use Test::More; # tests => 2;
use Test::Exception;

use Biodiverse::Remap;


use Devel::Symdump;
my $obj = Devel::Symdump->rnew(__PACKAGE__); 
my @test_subs = grep {$_ =~ 'main::test_'} $obj->functions();


exit main( @ARGV );

sub main {
    my @args  = @_;

    if (@args) {
        for my $name (@args) {
            die "No test method test_$name\n"
                if not my $func = (__PACKAGE__->can( 'test_' . $name ) || __PACKAGE__->can( $name ));
            $func->();
        }

        done_testing;
        return 0;
    }

    foreach my $sub (@test_subs) {
        no strict 'refs';
        $sub->();
    }

    done_testing;
    return 0;
}



# test basic functionality of adding a remap hash and getting it back
sub test_to_and_from_hash {
    my $remap = Biodiverse::Remap->new();

    my %remap_hash = (
        "label1" => "remappedlabel1",
        "label2" => "remappedlabel2",
        "label3" => "remappedlabel3",
        "label4" => "remappedlabel4",
        "label5" => "remappedlabel5",
        );

    $remap->import_from_hash(remap_hash => \%remap_hash);

    my $output_hash = $remap->to_hash();

    is_deeply($output_hash,
              \%remap_hash,
              "Got out the same hash we put in");
    
}
