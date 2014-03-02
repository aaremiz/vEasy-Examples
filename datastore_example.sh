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
	dsname => { type => "=s", required => 1 },
);
Opts::add_options(%opts);

Opts::parse();
Opts::validate();
my $server = Opts::get_option("server");
my $username = Opts::get_option("username");
my $password = Opts::get_option("password");

my $dsname = Opts::get_option("dsname");


my $vim = vEasy::Connect->new($server, $username, $password);

# Connection OK?
if( $vim )
{
	print "Connected to server: $server\n";
	
	# Datastore
	my $ds = vEasy::Datastore->new($vim, $dsname);
	if( $ds )
	{
		# Print the names of HostSystems, VMs related to this Datastore
		print "HOSTS:\n";
		my $hosts = $ds->getHosts();
		for( my $i = 0; $i < @$hosts; ++$i )
		{
			print $hosts->[$i]->name()."\n";
		}

		print "VIRTUALMACHINES:\n";				
		my $vms = $ds->getVirtualMachines();
		for( my $i = 0; $i < @$vms; ++$i )
		{
			print $vms->[$i]->name()."\n";
		}

		$ds->refreshStorageInfo();
		
		# Print specs related to Datastore
		print "Total capacity: ".$ds->getTotalCapacity()."\n";
		print "Free capacity: ".$ds->getFreeCapacity()."\n";
		print "Used capacity: ".$ds->getUsedCapacity()."\n";
		print "Allocated capacity: ".$ds->getAllocatedCapacity()."\n";
		print "Filesystem type: ".$ds->getFilesystemType()."\n";
		print "VMFS version: ".$ds->getVmfsVersion()."\n";
		print "UUID: ".$ds->getVmfsUuid()."\n";
		
		# Disk identifiers:
		print "DISKNAMES (naa etc):\n";
		my $disknames = $ds->getDiskNames();
		for( my $i = 0; $i < @$disknames; ++$i )
		{
			print $disknames->[$i]."\n";
		}
		
		# Try to expand datastore if there free capacity in the LUN
		if( $ds->expand() )
		{
			print "Datastore ".$ds->name()." expanded.\n";
		}
		else
		{
			print $ds->getLatestFault()->getType()." ".$ds->getLatestFault()->getMessage()."\n";
		}
	}
	
	# NAS DATASTORE
	my $nas_ds = vEasy::Datastore->new($vim, "MY_NFS_DS");
	if( $nas_ds )
	{
		print "NFS Address: ".$ds->getNfsAddress()."\n";
		print "NFS Path: ".$ds->getNfsPath()."\n";
		print "NFS User: ".$ds->getNfsUser()."\n";

		$nas_ds->refreshStorageInfo();	
		
		print "Total capacity: ".$ds->getTotalCapacity()."\n";
		print "Free capacity: ".$ds->getFreeCapacity()."\n";
		print "Used capacity: ".$ds->getUsedCapacity()."\n";
		print "Allocated capacity: ".$ds->getAllocatedCapacity()."\n";
		print "Filesystem type: ".$ds->getFilesystemType()."\n";
		print "VMFS version: ".$ds->getVmfsVersion()."\n";
		print "UUID: ".$ds->getVmfsUuid()."\n";
		
	}
}
else
{
	print "ERROR: Connection failed to server: $server\n";
}


exit;
