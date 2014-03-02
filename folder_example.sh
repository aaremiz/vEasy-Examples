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
	poolname => { type => "=s", required => 1 },
	dsname => { type => "=s", required => 1 },
);
Opts::add_options(%opts);

Opts::parse();
Opts::validate();
my $server = Opts::get_option("server");
my $username = Opts::get_option("username");
my $password = Opts::get_option("password");

my $foldername = Opts::get_option("foldername");
my $poolname = Opts::get_option("poolname");
my $dsname = Opts::get_option("dsname");


my $vim = vEasy::Connect->new($server, $username, $password);

# Connection OK?
if( $vim )
{
	print "Connected to server: $server\n";
	
	# Get Entity
	my $folder = vEasy::Folder->new($vim, $foldername);
	if( $folder )
	{
		print "Creating subfolder...\n";
		my $subfolder = $folder->createFolder("SubFolder");
		if( not $subfolder )
		{
			print $folder->getLatestFault()->getType()." ".$folder->getLatestFault()->getMessage()."\n";
		}
		print "Trying to create a datacenter...\n";
		my $dc = $folder->createDatacenter("DC");
		if( not $dc )
		{
			print $folder->getLatestFault()->getType()." ".$folder->getLatestFault()->getMessage()."\n";
		}
		print "Trying to create a cluster...\n";
		my $cluster = $folder->createCluster("Cluster2");
		if( not $cluster )
		{
			print $folder->getLatestFault()->getType()." ".$folder->getLatestFault()->getMessage()."\n";
		}
		
		my $rp = vEasy::ResourcePool->new($vim, $poolname);
		my $ds = vEasy::Datastore->new($vim, $dsname);
		
		print "Trying to create a VirtualMachine...\n";
		my $vm = $folder->createVirtualMachine("vm", $rp, $ds);
		if( not $vm )
		{
			print $folder->getLatestFault()->getType()." ".$folder->getLatestFault()->getMessage()."\n";
		}
		
		print "Trying to move cluster to subfolder...\n";
		$subfolder->moveEntityToFolder($cluster);
		
		$folder->refresh();
		
		print "CHILD ENTITIES\n";
		my $childs = $folder->getChildEntities();
		
		for(my $i = 0; $i < @$childs; ++$i)
		{
			print $childs->[$i]->getType()." ".$childs->[$i]->name()."\n";
		}
		$subfolder->remove();
	}
	else
	{
		print "Folder not found.\n";
	}
}
else
{
	print "ERROR: Connection failed to server: $server\n";
}


exit;
