#!/usr/bin/perl -w

#  Tests for basedata save and reload.
#  Assures us that the data can be serialised, saved out and then reloaded
#  without throwing an exception.

use 5.010;
use strict;
use warnings;
use English qw { -no_match_vars };

use Scalar::Util qw /blessed/;

use rlib;

local $| = 1;

use Test::More;
use Test::Exception;

use Biodiverse::BaseData;
use Biodiverse::ElementProperties;
use Biodiverse::TestHelpers qw /:basedata/;

exit main( @ARGV );

sub main {
    my @args = @_;

    
    #  generate one basedata for all tests
    my @cell_sizes = (10, 10);
    my $args = {
        CELL_SIZES => [@cell_sizes],
        name       => 'Test save, reload and clone',
        x_spacing => 1,
        y_spacing => 1,
        x_max     => 50,
        y_max     => 50,
        x_min     => 1,
        y_min     => 1,
        count     => 1,
    };
    my $bd = eval {
        get_basedata_object ( %$args, );
    };
    my $error = $EVAL_ERROR;

    $bd->build_spatial_index (resolutions => [@cell_sizes]);
    #$bd->save_to (filename => 'xx.bdy');

    my $cond = ['sp_circle (radius => 10)', 'sp_circle (radius => 20)'];
    my $defq = '$y > 25';

    my $sp = $bd->add_spatial_output (
        name => 'Spatial',
    );
    $sp->run_analysis(
        spatial_conditions => $cond,
        definition_query   => $defq,
        calculations       => ['calc_richness'],
    );
    
    my $cl = $bd->add_cluster_output (
        name => 'Cluster',
    );
    $cl->run_analysis(
        definition_query => $defq,
    );
    
    #$bd->save_to (filename => 'xx2.bdy');
    
    if (@args) {
        for my $name (@args) {
            die "No test method test_$name\n"
                if not my $func = (__PACKAGE__->can( 'test_' . $name ) || __PACKAGE__->can( $name ));
            $func->();
        }
        done_testing;
        return 0;
    }

    #  do we get a consistent clone/saved version?
    test_save_and_reload($bd);
    test_clone($bd);

    done_testing;
    return 0;
}

## only testing for errors at the moment (2013-06-10).
## need to develop more stringent tests, e.g. has same outputs, same groups etc

sub test_save_and_reload {
    my $bd = shift;

    my $class = blessed $bd;

    #  need a temp file name
    my $tmp_obj = File::Temp->new (SUFFIX => '.bds');
    my $fname = $tmp_obj->filename;
    $tmp_obj->close;

    lives_ok { $bd->save_to (filename => $fname) } 'Saved to file';

    lives_ok { my $new_bd = eval {$class->new (file => $fname)} } 'Opened without exception thrown';

}

sub test_clone {
    my $bd = shift;

    #my $new_bd = eval {$bd->clone (no_elements => 1)};
    
    lives_ok { my $new_bd = eval {$bd->clone} } 'Cloned without exception thrown';
}



1;