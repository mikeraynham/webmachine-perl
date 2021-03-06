package O18d;
use strict;
use warnings;

use parent 'Web::Machine::Resource';

sub allowed_methods        { [qw[ GET HEAD PUT ]] }
sub content_types_provided { [ { 'text/plain' => sub {} } ] }
sub languages_provided     { [qw[ en ]] }
sub charsets_provided      { [ { 'utf-8' => sub {} } ] }
sub resource_exists        { 0 }

sub content_types_accepted { [ { 'text/plain' => 'accept_plain_text' } ] }

sub accept_plain_text {
    my $self = shift;
    $self->response->body('HELLO WORLD');
    1;
}

1;