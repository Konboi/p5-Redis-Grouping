package Redis::Grouping;
use 5.008001;
use strict;
use warnings;
our $VERSION = "0.01";

use Mouse;
use Mouse::Util::TypeConstraints;

has key => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has redis => (
    is       =>'ro',
    isa      =>'Object',
    required =>1,
);

no Mouse;

sub set_member {
    my ($self, $key, $opt) = @_;

    my $doc_key = $self->key . "_" . $key;
    for my $k (keys %{$opt}) {
        my $set_key = $self->key . '_' . $k . '_' . $opt->{$k};
        $self->redis->sadd($set_key, $key);

        # for remove
        $self->redis->rpush($doc_key, $set_key);
    }
}

sub get_member {
    my ($self, $opt) = @_;

    my @members;
    my @keys;
    for my $k (keys %{$opt}) {
        my $get_key = $self->key . '_' . $k . '_' . $opt->{$k};
        push @keys, $get_key;
    }

    @members = $self->redis->sinter(@keys);

    return @members;
}

sub remove_member {
    my ($self, $key) = @_;


    my $doc_key = $self->key . "_" . $key;
    my @keys = $self->redis->lrange($doc_key, 0, -1);

    for my $k (@keys) {
        my $delete_key = $k;
        $self->redis->srem($delete_key, $key);
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

Redis::Grouping - It's new $module

=head1 SYNOPSIS

    use Redis::Grouping;

=head1 DESCRIPTION

Redis::Grouping is ...

=head1 LICENSE

Copyright (C) Konboi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Konboi E<lt>ryosuke.yabuki@gmail.comE<gt>

=cut
