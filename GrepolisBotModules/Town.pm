package GrepolisBotModules::Town;

use strict;
use warnings;

use GrepolisBotModules::Request;
use GrepolisBotModules::Farm;

use JSON;
use Data::Dumper;

sub get_town_data {
    my( $self ) = @_;
    my $resp = JSON->new->allow_nonref->decode(
        GrepolisBotModules::Request::request(
                'data',
                'get',
                $self->{'id'},
                '{"types":[{"type":"backbone"},{"type":"map","param":{"x":0,"y":0}}]}',
                1
            )
        );
    foreach my $data (@{$resp->{'json'}->{'map'}->{'data'}->{'data'}->{'data'}} ) {
        foreach my $key (keys %{$data->{'towns'}}) {
            if(
                defined $data->{'towns'}->{$key}->{'relation_status'} &&
                $data->{'towns'}->{$key}->{'relation_status'} == 1
            ){
               push($self->{'villages'}, new GrepolisBotModules::Farm($data->{'towns'}->{$key}->{'id'}));
            }
        }
    }

    foreach my $arg (@{$resp->{'json'}->{'backbone'}->{'collections'}}) {
        if(
            defined $arg->{'model_class_name'} &&
            $arg->{'model_class_name'} eq 'Town'
        ){
            my $town = pop($arg->{'data'});
            $self->{'iron'} = $town->{'last_iron'};
            $self->{'wood'} = $town->{'last_wood'};
            $self->{'stone'} = $town->{'last_stone'};
        }
    }

    $resp = JSON->new->allow_nonref->decode(
        GrepolisBotModules::Request::request(
                'town_info',
                'go_to_town',
                $self->{'id'},
                undef,
                0
            )
        );

    $self->{'max_storage'} = $resp->{'json'}->{'max_storage'};
}

sub new {
    my $class = shift;
    my $self = {
        id => shift,
        villages => [],
        max_storage => undef,
        iron => undef,
        wood => undef,
        stone => undef
     };

    bless $self, $class;
    
    $self->get_town_data();

    print Dumper($self);

    return $self;
}

1;