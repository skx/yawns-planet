#!/usr/bin/perl -I..


use Test::More qw( no_plan );


BEGIN { use_ok( 'conf::SiteConfig' ); }
require_ok( 'conf::SiteConfig' );

BEGIN { use_ok( 'Singleton::DBI' ); }
require_ok( 'Singleton::DBI' );


#
#  Connect to Database
#
my $dbh = Singleton::DBI->instance();

#
# Is this the right object type?
#
isa_ok( $dbh, "DBI::db" );

#
# Did we really connect to the database?
#
ok( $dbh->ping(), "Database connection made" );

$dbh->disconnect();
