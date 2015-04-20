use strict;
use warnings;
use utf8;

use Test::More;
use Test::Deep;
use Test::RedisServer;
use Redis;
use Redis::Grouping;

my $redis_server = eval { Test::RedisServer->new }
    or plan skip_all => 'redis-server is required in PATH to run this test';
my $redis = Redis->new($redis_server->connect_info);


subtest 'grouping' => sub {
    my $g = Redis::Grouping->new(
        redis => $redis,
        key   => 'test_group',
    );

    $g->set_group('sample1', {
        rank    => 1,
        version => 'version',
    });

    $g->set_group('sample2', {
        rank    => 1,
        version => 'version2',
    });

    $g->set_group('sample3', {
        rank    => 2,
        version => 'version',
    });

    my @group = $g->get_group({rank => 1});
    is scalar @group, 2;
    ok cmp_deeply(\@group, bag('sample1', 'sample2'));

    @group = $g->get_group({version => 'version'});
    is scalar @group, 2;
    ok cmp_deeply(\@group, bag('sample1', 'sample3'));

    @group = $g->get_group({
        rank    => 2,
        version => 'version'
    });
    is scalar @group, 1;
    ok cmp_deeply(\@group, bag('sample3'));

    $g->remove_group('sample3');
    @group = $g->get_group({version => 'version'});
    is scalar @group, 2;
    ok cmp_deeply(\@group, bag('sample1'));

};

done_testing;
