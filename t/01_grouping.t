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

    $g->set_member('sample1', {
        rank    => 1,
        version => 'version',
    });

    $g->set_member('sample2', {
        rank    => 1,
        version => 'version2',
    });

    $g->set_member('sample3', {
        rank    => 2,
        version => 'version',
    });

    $g->set_member('sample4', {
        rank    => 1,
        version => 'version2',
    });

    my @members = $g->get_member({rank => 1});
    is scalar @members, 3;
    ok cmp_deeply(\@members, bag('sample1', 'sample2', 'sample4'));

    @members = $g->get_member({version => 'version'});
    is scalar @members, 2;
    ok cmp_deeply(\@members, bag('sample1', 'sample3'));

    @members = $g->get_member({
        version => 'version2',
        rank    => 1
    });
    is scalar @members, 2;
    ok cmp_deeply(\@members, bag('sample2', 'sample4'));

    @members = $g->get_member({
        rank    => 2,
        version => 'version'
    });
    is scalar @members, 1;
    ok cmp_deeply(\@members, bag('sample3'));

    $g->remove_member('sample3');
    @members = $g->get_member({version => 'version'});
    is scalar @members, 1;
    ok cmp_deeply(\@members, bag('sample1'));

};

done_testing;
