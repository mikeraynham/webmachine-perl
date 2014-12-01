#!perl

use strict;
use warnings;


use Web::Machine;

{
    package HelloWorld::Resource;
    use strict;
    use warnings;

    use HTTP::Status qw[ is_error status_message ];
    use JSON::XS qw[ encode_json ];
    use Plack::Util;
    use Web::Machine::Util qw[ pair_value bind_path ];
    use Web::Machine::Util::ContentNegotiation qw[ match_acceptable_media_type ];

    use parent 'Web::Machine::Resource';

    sub content_types_provided { [
        { 'application/json' => 'to_json' },
        { 'text/html'        => 'to_html' },
    ] }

    sub finish_request {
        my ($self, $metadata) = @_;

        return unless my $status = $self->response->status;
        return unless is_error($status);
        return unless my $content_type = $metadata->{'Content-Type'};
        return unless my $acceptable = match_acceptable_media_type(
            $content_type,
            $self->content_types_provided
        );

        return unless my $handler = $self->can(
            'error_' . pair_value( $acceptable )
        );

        my $content = $handler->($self, $status);
        return unless defined $content;

        $self->response->headers->content_type($content_type);
        $self->response->body([$content]);
        $self->response->content_length(
            Plack::Util::content_length($self->response->body)
        );

        return;
    }

    sub resource_exists {
        my ($self) = @_;

        return 0 unless my $id = bind_path( '/:id', $self->request->path_info );
        return 0 if $id > 100;
        return 1;
    }

    sub error_to_json {
        my ($self, $status) = @_;

        encode_json( {
            message => status_message($status),
            status  => $status,
        } );
    }

    sub to_json { encode_json( { message => 'Success' } ) }
    sub to_html { '<html><body><h1>Success</h1></body></html>' }
}

Web::Machine->new( resource => 'HelloWorld::Resource' )->to_app;
