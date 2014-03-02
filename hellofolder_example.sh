#!/usr/bin/perl

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.


sub BEGIN{
	push @INC, "../..";
}

use strict;
use warnings;
use Data::Dumper;
use vEasy::Connect;

my %opts = (
	foldername => { type => "=s", required => 1 },
);
Opts::add_options(%opts);

Opts::parse();
Opts::validate();
my $server = Opts::get_option("server");
my $username = Opts::get_option("username");
my $password = Opts::get_option("password");
my $foldername = Opts::get_option("foldername");

my $vim = vEasy::Connect->new($server, $username, $password);

if( $vim )
{
	print "Connected to server: $server\n";
	
	my $folder = vEasy::Folder->new($vim, $foldername);
	if( $folder )
	{
		print "Hello folder: ".$folder->name()."\n";
		
		my $cluster = $folder->createCluster("Cluster2");
		if( $cluster )
		{
			print "CLuster created and now deleted...\n";
			$cluster->remove();
		}
		else
		{
			print $folder->getLatestFault()->getMessage()."\n";
		}
	}
	else
	{
		print $vim->getLatestFault()->getType().": ".$vim->getLatestFault()->getMessage()."\n";
	}
}
else
{
	print "ERROR: Connection failed to server: $server\n";
}

exit;
