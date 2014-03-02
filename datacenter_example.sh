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
	dcname => { type => "=s", required => 1 },
);
Opts::add_options(%opts);

Opts::parse();
Opts::validate();
my $server = Opts::get_option("server");
my $username = Opts::get_option("username");
my $password = Opts::get_option("password");

my $dcname = Opts::get_option("dcname");

my $vim = vEasy::Connect->new($server, $username, $password);

# Connection OK?
if( $vim )
{
	# Get host/vCenter root folder
	my $rootfolder = $vim->getRootFolder();
	
	print $rootfolder->name()."\n";
	
	print "Trying to create new datacenter...\n";
	# Create Datacenter
	my $dc = $rootfolder->createDatacenter($dcname);
	if( not $dc )
	{
		print $rootfolder->getLatestFault->getType().": ".$rootfolder->getLatestFaultMessage()."\n";

		if( $rootfolder->getLatestFault->getType() eq "DuplicateNameFault")
		{
			$dc = vEasy::Datacenter->new($vim, "EXAMPLE_DC");
		}
		print $dc->name()."\n";
	}

	print "Trying to create new Folder under Hosts and Clusters...\n";
	# Create Folder under the datacenter in Hosts and Cluster
	my $hostfolder = $dc->createHostFolder("HostFolder");
	if( not $hostfolder )
	{
		print $dc->getLatestFault->getType().": ".$dc->getLatestFaultMessage()."\n";

		if( $dc->getLatestFault->getType() eq "DuplicateNameFault")
		{
			$hostfolder = vEasy::Folder->new($vim, "HostFolder");
		}
		print $hostfolder->name()."\n";
	}

	print "Trying to create new Folder under VMs and Templates...\n";
	# Create Folder under the datacenter in VMs and Templates
	my $vmfolder = $dc->createVmFolder("VirtualMachineFolder");
	if( not $vmfolder )
	{
		print $dc->getLatestFault->getType().": ".$dc->getLatestFaultMessage()."\n";

		if( $dc->getLatestFault->getType() eq "DuplicateNameFault")
		{
			$vmfolder = vEasy::Folder->new($vim, "VirtualMachineFolder");
		}
		print $vmfolder->name()."\n";
	}

	print "Trying to create new Folder under Networking...\n";	
	# Create Folder under the datacenter in Networking
	my $nwfolder = $dc->createNetworkFolder("NetworkFolder");
	if( not $nwfolder )
	{
		print $dc->getLatestFault->getType().": ".$dc->getLatestFaultMessage()."\n";

		if( $dc->getLatestFault->getType() eq "DuplicateNameFault")
		{
			$nwfolder = vEasy::Folder->new($vim, "NetworkFolder");
		}
		print $nwfolder->name()."\n";
	}

	print "Trying to create new Folder under Datastores and Datastore Clusters...\n";	
	# Create Folder under the datacenter in Datastores and Datastore Clusters
	my $dsfolder = $dc->createDatastoreFolder("DatastoreFolder");
	if( not $dsfolder )
	{
		print $dc->getLatestFault->getType().": ".$dc->getLatestFaultMessage()."\n";

		if( $dc->getLatestFault->getType() eq "DuplicateNameFault")
		{
			$dsfolder = vEasy::Folder->new($vim, "DatastoreFolder");
		}
		print $dsfolder->name()."\n";
	}
	
	# Create Folder under the datacenter in Datastores and Datastore Clusters
	my $cluster = $dc->createCluster("ExampleCluster");
	if( not $cluster )
	{
		print $dc->getLatestFault->getType().": ".$dc->getLatestFaultMessage()."\n";

		if( $dc->getLatestFault->getType() eq "DuplicateNameFault")
		{
			$cluster = vEasy::Cluster->new($vim, "ExampleCluster");
		}
		print $cluster->name()."\n";
	}
}


exit;
