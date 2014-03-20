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
	hostname => { type => "=s", required => 1 },

);
Opts::add_options(%opts);

Opts::parse();
Opts::validate();
my $server = Opts::get_option("server");
my $username = Opts::get_option("username");
my $password = Opts::get_option("password");
my $hostname = Opts::get_option("hostname");



my $vim = vEasy::Connect->new($server, $username, $password);

# Connection OK?
if( $vim )
{
	print "Connected to server: $server\n";
	
	# Get Entity
	my $host = $vim->getHostSystem($hostname);
	if( $host )
	{
		print "NETWORKS:\n";				
		my $networks = $host->getNetworks();
		for( my $i = 0; $i < @$networks; ++$i )
		{
			print $networks->[$i]->name()."\n";
		}
		print "DATASTORES:\n";				
		my $datastores = $host->getDatastores();
		for( my $i = 0; $i < @$datastores; ++$i )
		{
			print $datastores->[$i]->name()."\n";
		}
		print "VIRTUALMACHINES:\n";				
		my $vms = $host->getVirtualMachines();
		for( my $i = 0; $i < @$vms; ++$i )
		{
			print $vms->[$i]->name()."\n";
		}
		if( $host->getCluster() )
		{
			print "Cluster name: ".$host->getCluster()->name()."\n";
		}
		print "RootResourcePool Name: ".$host->getRootResourcePool()->name()."\n";
		print "Host boot time: ".$host->getBootTime()."\n";
		print "Connection state: ".$host->getConnectionState()."\n";
		print "Power state: ".$host->getPowerState()."\n";
		print "Host in maintenance mode?: ".$host->getMaintenanceModeStatus()."\n";
		print "Uptime: ".$host->getUptime()." secs\n";
		print "Total memory capacity: ".$host->getTotalMemoryCapacity()." MB\n";
		print "Memory usage: ".$host->getMemoryUsage()." MB\n";
		print "CPU Capacity: ".$host->getTotalCpuCapacity()." Mhz\n";
		print "CPU Usage: ".$host->getCpuUsageMhz()." Mhz\n";
		print "vCenter address: ".$host->getVcenterAddress()."\n";
		print "DNS Servers:\n".Dumper($host->getDnsServers());
		print "Hostname: ".$host->getHostName()."\n";
		print "Domain: ".$host->getDomainName()."\n";
		print "DGW: ".$host->getDefaultGateway()."\n";
		print "vmk0 IP: ".$host->getStandardVirtualSwitch("vSwitch0")->getVmkInterfaceIpAddress("vmk0")."\n";
		print "vmk0 netmak: ".$host->getStandardVirtualSwitch("vSwitch0")->getVmkInterfaceNetmask("vmk0")."\n";
		
		my $task1 = $host->enterMaintenanceMode();
		if( $task1->completedOk() )
		{
			print "Host put to maintenance mode.\n";
			my $task2 = $host->exitMaintenanceMode();
			if( $task2->completedOk() )
			{
				print "Host exited from maintenance mode.\n";
			}
		}

		
		my $task3 = $host->disconnect();
		if( $task3->completedOk() )
		{
			print "Host disconnected.\n";
			my $task4 = $host->reconnect();
			if( $task4->completedOk() )
			{
				print "Host reconnected.\n";
			}
		}
		
		$host->reconfigureHighAvailability()->waitToComplete();
		
		$host->rescanStorageDevices();
		$host->rescanVmfsDatastores();
		
		my $vswitch = $host->createStandardVirtualSwitch("vSwitch23");
		
		print "Adding vmnic to vSwitch...\n";
		if( not $vswitch->addPhysicalNic("vmnic1") )
		{
			print $host->getLatestFault->getType().": ".$host->getLatestFaultMessage()."\n";
		}

		print "Setting vmnic to active in vSwitch...\n";		
		if( not $vswitch->setPhysicalNicToActive("vmnic1") )
		{
			print $host->getLatestFault->getType().": ".$host->getLatestFaultMessage()."\n";
		}
		print "Setting vmnic to standby in vSwitch...\n";	
		if( not $vswitch->setPhysicalNicToStandby("vmnic1") )
		{
			print $host->getLatestFault->getType().": ".$host->getLatestFaultMessage()."\n";
		}
		print "Setting vmnic to unused in vSwitch...\n";	
		if( not $vswitch->setPhysicalNicToUnused("vmnic1") )
		{
			print $host->getLatestFault->getType().": ".$host->getLatestFaultMessage()."\n";
		}
		print "Removing vmnic from vSwitch...\n";
		if( not $vswitch->removePhysicalNic("vmnic1") )
		{
			print $host->getLatestFault->getType().": ".$host->getLatestFaultMessage()."\n";
		}
		print "Adding portgroup to vSwitch...\n";
		if( not $vswitch->addPortGroup("DemoPG", 300) )
		{
			print $host->getLatestFault->getType().": ".$host->getLatestFaultMessage()."\n";
		}		
		print "Adding VMKernel Port to vSwitch...\n";
		my $vmk = $vswitch->addVmkInterface("DemoVMK", 1300); #DHCP enabled
		if( $vmk )
		{
			print "$vmk added. Setting IP address...\n";
			$vswitch->setVmkInterfaceIpAddress($vmk, "172.16.0.2", "255.255.255.192");
			$host->refresh();
			print "$vmk IP specs ".$vswitch->getVmkInterfaceIpAddress($vmk)." ".$vswitch->getVmkInterfaceNetmask($vmk)."\n";
			print "Enabling vmk for vMotion...\n";
			$vswitch->enableVmkInterfaceForVmotion($vmk);
		}
		else
		{
			print $host->getLatestFault->getType().": ".$host->getLatestFaultMessage()."\n";
		}		
		
		print "Setting port number in vSwitch...\n";
		if( not $vswitch->setNumberOfPorts(512) )
		{
			print $host->getLatestFault->getType().": ".$host->getLatestFaultMessage()."\n";
		}

		print "Setting MTU Value...\n";
		if( not $vswitch->setMtuValue(9000) )
		{
			print $host->getLatestFault->getType().": ".$host->getLatestFaultMessage()."\n";
		}
		
		print "Disabling promiscuous mode...\n";
		if( not $vswitch->disablePromiscuousMode() )
		{
			print $host->getLatestFault->getType().": ".$host->getLatestFaultMessage()."\n";
		}
		print "Disabling mac address changes...\n";
		if( not $vswitch->disableMacAddressChanges() )
		{
			print $host->getLatestFault->getType().": ".$host->getLatestFaultMessage()."\n";
		}
		print "Disabling forged transmits...\n";
		if( not $vswitch->disableForgedTransmits() )
		{
			print $host->getLatestFault->getType().": ".$host->getLatestFaultMessage()."\n";
		}
		print "Enabling notify switches...\n";
		if( not $vswitch->enableNotifySwitches() )
		{
			print $host->getLatestFault->getType().": ".$host->getLatestFaultMessage()."\n";
		}
		print "Enabling failback...\n";
		if( not $vswitch->enableFailback() )
		{
			print $host->getLatestFault->getType().": ".$host->getLatestFaultMessage()."\n";
		}
		print "Setting vmnic load balancing to route based on ip hash..\n";
		if( not $vswitch->setPhysicalNicLoadBalacingToRouteBasedOnIpHash() )
		{
			print $host->getLatestFault->getType().": ".$host->getLatestFaultMessage()."\n";
		}
		
		$vswitch->removePortGroup("DemoPG");
		$vswitch->removeVmkInterface($vmk);
		$vswitch->remove();

	}
	else
	{
		print $vim->getLatestFaultMessage()."\n";
	}
}
else
{
	print "ERROR: Connection failed to server: $server\n";
}


exit;
