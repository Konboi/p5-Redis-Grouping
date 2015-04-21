# NAME

Redis::Grouping - It's new $module

# SYNOPSIS
    use Redis;
    use Redis::Grouping;

    my $redis = Redis->new;

    my $group = Redis::Grouping->new(
        redis => $redis,
        key   => 'sample-group',
    );

    $group->set_group('some-key', {
        rank    => 8,
        version => '1.1.0',
    });

    $group->set_group('some-key2', {
        rank    => 6,
        version => '1.1.0',
    });

    my @list = $group->get_gorup({rank => 8});
    # ('some-key')

    @list = $group->get_group({version => '1.1.0'});
    # ('some-key', 'some-key2')

    $group->remove_group('some-key2');
    @list = $group->get_group({version => '1.1.0'});
    # ('some-key')

# DESCRIPTION

Redis::Grouping is providing grouping list by using Redis's sorted set.

__THIS IS A ALPHA QUALITY RELEASE. API MAY CHANGE WITHOUT NOTICE__.

### `my $group = Redis::Grouping->new(%options)`

Create a new leader board object. Options should be set in `%options`.

- `redis: Redis`

    Redis object. Redis.pm or Redis::hiredis.

- `key: Str`

    Required.

# LICENSE

Copyright (C) Konboi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Konboi <ryosuke.yabuki@gmail.com>
