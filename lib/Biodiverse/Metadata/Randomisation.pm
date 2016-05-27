package Biodiverse::Metadata::Randomisation;
use strict;
use warnings;
use 5.016;
use Carp;
use Readonly;
use Scalar::Util qw /reftype/;

use parent qw /Biodiverse::Metadata/;

our $VERSION = '1.99_002';


my %methods_and_defaults = (
    description  => 'no_description',
    parameters   => [],
);

sub _get_method_default_hash {
    return wantarray ? %methods_and_defaults : {%methods_and_defaults};
}


__PACKAGE__->_make_access_methods (\%methods_and_defaults);


1;
