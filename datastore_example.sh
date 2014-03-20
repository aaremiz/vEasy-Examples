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
