#!/usr/bin/perl

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.


sub BEGIN{
	push @INC, "../../";
}

use strict;
use warnings;
use Data::Dumper;
use vEasy::Connect;

my %opts = (
	vmname => { type => "=s", required => 1 },
	clustername => { type => "=s", required => 1 },
	poolname => { type => "=s", required => 1 },
);
Opts::add_options(%opts);

Opts::parse();
Opts::validate();
my $server = Opts::get_option("server");
my $username = Opts::get_option("username");
my $password = Opts::get_option("password");
my $clustername = Opts::get_option("clustername");
my $poolname = Opts::get_option("poolname");

my $vim = vEasy::Connect->new($server, $username, $password);

# Connection OK?
if( $vim )
{
	print "Connected to server: $server\n";
	
	# Get Entity
	my $cluster = vEasy::Cluster->new($vim, $clustername);
	my $rp = $cluster->createChildResourcePool($poolname);
	
	if( $rp )
	{
		print "Child Resource Pools:\n";				
		my $pools = $cluster->getRootResourcePool()->getChildResourcePools();
		for( my $i = 0; $i < @$pools; ++$i )
		{
			print $pools->[$i]->name()."\n";
		}
		
		print "MOVING VIRTUALMACHINES:\n";				
		my $vms = $cluster->getRootResourcePool()->getVirtualMachines();
		for( my $i = 0; $i < @$vms; ++$i )
		{
			if( $rp->moveEntityToResourcePool($vms->[$i]) )
			{
				print "VM ".$vms->[$i]->name()." moved to ResourcePool\n";
			}
		}

		print "Setting memory limit...\n";
		if( not $rp->setMemoryLimit(100) ) 
		{
			print $rp->getLatestFault()->getMessage()."\n";
		}
		print "Setting cpu limit...\n";
		if( not $rp->setCpuLimit(1000) )
		{
			print $rp->getLatestFault()->getMessage()."\n";
		}
		print "Setting memory resevation...\n";
		if( not $rp->setMemoryReservation(10) )
		{
			print $rp->getLatestFault()->getMessage()."\n";
		}
		print "Setting cpu resevation...\n";
		if( not $rp->setCpuReservation(100) )
		{
			print $rp->getLatestFault()->getMessage()."\n";
		}
		print "Enabling expandable cpu reservation...\n";
		if( not $rp->enableExpandableCpuReservation() )
		{
			print $rp->getLatestFault()->getMessage()."\n";
		}
		print "Enabling expandable memory reservation...\n";
		if( not $rp->enableExpandableMemoryReservation() )
		{
			print $rp->getLatestFault()->getMessage()."\n";
		}
		print "Enabling cpu shares to high...\n";
		if( not $rp->setCpuShares("high") )
		{
			print $rp->getLatestFault()->getMessage()."\n";
		}
		print "Enabling memory shares to custom...\n";
		if( not $rp->setMemoryShares("custom", 11400) )
		{
			print $rp->getLatestFault()->getMessage()."\n";
		}
		
		my $owner = $rp->getOwner();
		print "Owner type: ".$owner->getType()."\n";
		print "Owner name: ".$owner->name()."\n";

		$rp->refresh();
		print "memLimit ".$rp->getMemoryLimit()."\n";
		print "memReserv ".$rp->getMemoryReservation()."\n";
		print "memShares ".$rp->getMemoryShares()."\n";
		print "memSharesLevel ".$rp->getMemorySharesLevel()."\n";
		print "cpuLimit ".$rp->getCpuLimit()."\n";
		print "cpuReserv ".$rp->getCpuReservation()."\n";
		print "cpuShares ".$rp->getCpuShares()."\n";
		print "cpuSharesLevel ".$rp->getCpuSharesLevel()."\n";
		print "memExpResv ".$rp->isExpandableMemoryReservationEnabled()."\n";
		print "cpuExpResv ".$rp->isExpandableCpuReservationEnabled()."\n";
		print "memRuntime ".$rp->getTotalRuntimeMemoryUsage()."\n";
		print "cpuRuntime ".$rp->getTotalRuntimeCpuUsage()."\n";
		
		print "Disabling chagnges to resourcepool settings...\n";
		$rp->removeMemoryLimit();
		$rp->removeCpuLimit();
		$rp->removeMemoryReservation();
		$rp->removeCpuReservation();
		$rp->disableExpandableCpuReservation();
		$rp->disableExpandableMemoryReservation();

		$rp->setCpuShares("normal");
		$rp->setMemoryShares("normal");

		print "Deleting resourcepool...\n";
		$rp->remove();
	}
	else
	{
		print "ERROR: ResourcePool not created.\n";
	}
}
else
{
	print "ERROR: Connection failed to server: $server\n";
}


exit;
