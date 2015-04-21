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

    my $index_key = $self->key . "_" . $key;
    for my $k (keys %{$opt}) {
        my $set_key = $self->key . '_' . $k . '_' . $opt->{$k};
        $self->redis->sadd($set_key, $key);

        # for remove
        $self->redis->rpush($index_key, $set_key);
    }
}

sub get_member {
    my ($self, $opt) = @_;

    my @keys;
    for my $k (keys %{$opt}) {
        my $get_key = $self->key . '_' . $k . '_' . $opt->{$k};
        push @keys, $get_key;
    }
    my @members = $self->redis->sinter(@keys);

    return @members;
}

sub remove_member {
    my ($self, $key) = @_;

    my $index_key = $self->key . "_" . $key;
    my @keys = $self->redis->lrange($index_key, 0, -1);

    for my $k (@keys) {
        my $delete_key = $k;
        $self->redis->srem($delete_key, $key);
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

Redis::Grouping - grouping using Redis

=head1 SYNOPSIS

    use Redis;
    use Redis::Grouping;

    my $redis = Redis->new;

    my $group = Redis::Grouping->new(
        redis => $redis,
        key   => 'sample-group',
    );

    $group->set_member('some-key', {
        rank    => 8,
        version => '1.1.0',
    });

    $group->set_member('some-key2', {
        rank    => 6,
        version => '1.1.0',
    });

    my @list = $group->get_member({rank => 8});
    # ('some-key')

    @list = $group->get_member({version => '1.1.0'});
    # ('some-key', 'some-key2')

    $group->remove_member('some-key2');
    @list = $group->get_member({version => '1.1.0'});
    # ('some-key')


=head1 DESCRIPTION

Redis::Grouping is providing grouping list by using Redis's sorted set.

__THIS IS A ALPHA QUALITY RELEASE. API MAY CHANGE WITHOUT NOTICE__.

#### `my $group = Redis::Grouping->new(%options)`

Create a new leader board object. Options should be set in `%options`.

- `redis: Redis`

    Redis object. Redis.pm or Redis::hiredis.

- `key: Str`

    Required.


=head1 LICENSE

Copyright (C) Konboi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Konboi E<lt>ryosuke.yabuki@gmail.comE<gt>

=cut
