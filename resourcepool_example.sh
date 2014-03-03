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
