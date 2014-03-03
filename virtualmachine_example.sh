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
	push @INC, "..";
}

use strict;
use warnings;
use Data::Dumper;
use vEasy::Connect;

my %opts = (
	foldername => { type => "=s", required => 1 },
	clustername => { type => "=s", required => 1 },
	dsname => { type => "=s", required => 1 },
);
Opts::add_options(%opts);

Opts::parse();
Opts::validate();
my $server = Opts::get_option("server");
my $username = Opts::get_option("username");
my $password = Opts::get_option("password");
my $vmname = Opts::get_option("vmname");
my $foldername = Opts::get_option("foldername");
my $clustername = Opts::get_option("clustername");
my $dsname = Opts::get_option("dsname");

my $vim = vEasy::Connect->new($server, $username, $password);

# Connection OK?
if( $vim )
{
	print "Connected to server: $server\n";
	
	# Get Entity
	my $cluster = vEasy::Cluster->new($vim, $clustername);
	my $folder = vEasy::Folder->new($vim, $foldername);
	my $ds = vEasy::Datastore->new($vim, $dsname);
	
	my $vm = $cluster->createVirtualMachine("ExampleVM", $folder, $ds);

	if( $vm )
	{
		print "VM created\n";

		print "Upgrading VirtualMachine HW version\n";
		my $task = $vm->upgradeVirtualHardware();
		if( not $task or $task->completedFailed() )
		{
			print $vm->getLatestFaultMessage()."\n";
		}
		
		print "Setting vCPUs...\n";
		$vm->setCpusAndCores(2,2);
		print "Setting VM memory...\n";
		$vm->setMemory(256);
		print "Adding notes...\n";
		$vm->setNotes("Some Notes...");
		print "Setting Guest OS type...\n";
		$vm->setGuestOperatingSystemType("rhel5Guest");
		print "Adding some SCSI controllers...\n";
		$vm->addSasScsiController(0);
		$vm->addLsiLogicScsiController(1);
		$vm->addBusLogicScsiController(2);
		$vm->addParavirtualScsiController(3)->waitToComplete();

		$vm->refresh();
		print "Adding different types of vdisks...\n";
		$vm->addThinVirtualDisk("SCSI controller 0", 0, 2)->waitToComplete();
		$vm->addLazyZeroedVirtualDisk("SCSI controller 0", 1, 1)->waitToComplete();
		$vm->addEagerlyZeroedVirtualDisk("SCSI controller 0", 2, 1)->waitToComplete();
		$vm->refresh();
		
		print "Changing vdisk modes...\n";
		$vm->setVirtualDiskModeToPersistent("Hard disk 1");
		$vm->setVirtualDiskModeToIndependentPersistent("Hard disk 2");
		$vm->setVirtualDiskModeToIndependentNonPersistent("Hard disk 3");
		
		print "Changing vdisk modes...\n";
		$vm->setScsiControllerModeToNoSharing("SCSI controller 0");
		$vm->setScsiControllerModeToVirtualSharing("SCSI controller 1");
		$vm->setScsiControllerModeToPhysicalSharing("SCSI controller 2");
		
		print "Adding DVD,floppy drives and USB controller...\n";
		$vm->addFloppyDrive();
		$vm->addCdDvdDrive("IDE 1", 1);
		$vm->addUsbController()->waitToComplete();
		$vm->addUsbXhciController()->waitToComplete();
		
		print "Adding network adapters...\n";
		# my $network1 = vEasy::Network->new($vim, "VM Network");
		# my $network2 = vEasy::Network->new($vim, "VMNETWORK23");
		# my $network3 = vEasy::DistributedVirtualPortgroup->new($vim, "dvPortGroup");
		my $network = $cluster->getNetworks()->[0];
		$vm->addE1000NetworkAdapter($network)->waitToComplete();
		$vm->addE1000eNetworkAdapter($network)->waitToComplete();
		$vm->addFlexibleNetworkAdapter($network)->waitToComplete();
		$vm->addVmxnet3NetworkAdapter($network)->waitToComplete();
		
		print "NETWORKS:\n";				
		my $networks = $vm->getNetworks();
		for( my $i = 0; $i < @$networks; ++$i )
		{
			print $networks->[$i]->name()."\n";
		}
		print "DATASTORES:\n";				
		my $datastores = $vm->getDatastores();
		for( my $i = 0; $i < @$datastores; ++$i )
		{
			print $datastores->[$i]->name()."\n";
		}
		
		print "ResourcePool: ".$vm->getResourcePool()->name()."\n";
		print "Cluster: ".$vm->getCluster()->name()."\n";
		print "HosSystem: ".$vm->getHost()->name()."\n";
		print "Annotations: ".$vm->getNotes()."\n";
		print "Power state: ".$vm->getPowerState()."\n";
		print "Guest Hostname: ".$vm->getGuestHostname()."\n";
		print "Guest IP: ".$vm->getGuestIpAddress()."\n";
		print "PowerOn date: ".$vm->getPowerOnDate()."\n";
		print "Used Disk: ".$vm->getTotalUsedDiskSize()."\n";
		print "Allocated Disk: ".$vm->getTotalAllocatedDiskSize()."\n";
		print "Memory: ".$vm->getMemory()."\n";
		print "CPU sockets: ".$vm->getCpuSockets()."\n";
		print "CPU cores in socket: ".$vm->getCpuCores()."\n";
		print "HW version: ".$vm->getVirtualHardwareVersion()."\n";
		print "Guest type: ".$vm->getGuestOperatingSystemType()."\n";

		$task = $vm->powerOn();
		if( not $task->completedOk() )
		{
			print $vm->getLatestFault()->getMessage()."\n";
		}
		$vm->refresh();
		$task = $vm->reset();
		if( not $task->completedOk() )
		{
			print $vm->getLatestFault()->getMessage()."\n";
		}


		if( not $vm->reboot() )
		{
			print $vm->getLatestFault()->getMessage()."\n";
		}
		$vm->refresh();

		if( not $vm->shutdown() )
		{
			print $vm->getLatestFault()->getMessage()."\n";
		}

		if( not $vm->powerOff() )
		{
			print $vm->getLatestFault()->getMessage()."\n";
		}

		print "Creating a VM snapshot\n";
		$vm->takeSnapshot("My Snapshot", "Snapshot Desc", 0, 0)->waitToComplete();
		$vm->refresh();
		$vm->revertToCurrentSnapshot()->waitToComplete();

		print "Removing all snapshots\n";
		$task = $vm->removeSnapshots();
		if( not $task->completedOk() )
		{
			print $task->getFaultMessage()."\n";
		}

		
		$vm->remove();
	}
	else
	{
		print "ERROR: VirtualMachine not created.\n";
	}
}
else
{
	print "ERROR: Connection failed to server: $server\n";
}


exit;
