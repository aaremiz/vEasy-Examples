#!/usr/bin/perl

# Copyright (c) 2014, Risto Mäntylä
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice, this
#   list of conditions and the following disclaimer in the documentation and/or
#   other materials provided with the distribution.
#
# * Neither the name of the author nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


# ====================================================================================
# Author:	Risto Mäntylä 
#			aaremiz@gmail.com
#
# Purpose:	Purpose of this example is only to demonstrate the usage of vEasy 
#			Automation Framework. The scripts does not do anything reasonable and 
#			should NOT be used in production systems. 
#
# ====================================================================================

sub BEGIN{
	push @INC, "../vEasy";
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
