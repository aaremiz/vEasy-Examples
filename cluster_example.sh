#!/usr/bin/perl

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.


# Include directory to @INC-array that contains the paths where Packages are located
sub BEGIN{
	push @INC, "../..";
}

use strict;
use warnings;
use Data::Dumper;
use vEasy::Connect;

Opts::parse();
Opts::validate();
my $server = Opts::get_option("server");
my $username = Opts::get_option("username");
my $password = Opts::get_option("password");

my $vim = vEasy::Connect->new($server, $username, $password);

# Connection OK?
if( $vim )
{
	# Get existing cluster
	my $cluster = $vim->getCluster("ExampleCluster");
	if( $cluster )
	{
		# Create resource pool to cluster
		my $rp = $cluster->createChildResourcePool("ExampleResourcePool");
		if( $rp )
		{
			print $rp->name."\n";
			$rp->remove();
			
		}
		else
		{
			print $cluster->getLatestFault()->getType()." ".$cluster->getLatestFaultMessage()."\n";
		}

		# Add host
		my $host1 = $cluster->addHost("myhost1.demo.local", "root", "mypasswd");
		if( $host1 )
		{
			print "Host added to cluster: ".$host1->name()."\n";
			
			# Add host
			my $host2 = $cluster->addHost("myhost2.demo.local", "root", "mypasswd");		
			if( $host2 )
			{
				print "Host added to cluster: ".$host2->name()."\n";
				$cluster->refresh();
				
				# Print the names of cluster hosts,networks,datastores and VMs
				print "HOSTS:\n";
				my $hosts = $cluster->getHosts();
				for( my $i = 0; $i < @$hosts; ++$i )
				{
					print $hosts->[$i]->name()."\n";
				}
				print "NETWORKS:\n";				
				my $networks = $cluster->getNetworks();
				for( my $i = 0; $i < @$networks; ++$i )
				{
					print $networks->[$i]->name()."\n";
				}
				print "DATASTORES:\n";				
				my $datastores = $cluster->getDatastores();
				for( my $i = 0; $i < @$datastores; ++$i )
				{
					print $datastores->[$i]->name()."\n";
				}
				print "VIRTUALMACHINES:\n";				
				my $vms = $cluster->getVirtualMachines();
				for( my $i = 0; $i < @$vms; ++$i )
				{
					print $vms->[$i]->name()."\n";
				}
				# Exit Maintenance Mode on other host to get more interesting figures below:
				#$host2->exitMaintenanceMode()->waitToComplete();
				$cluster->refresh;
				print "Name: ".$cluster->name()."\n";
				print "HA status: ".$cluster->isHaEnabled()."\n";
				print "DRS status: ".$cluster->isDrsEnabled()."\n";
				print "Total allocated mem: ".$cluster->getTotalAllocatedMemory()."\n";
				print "Total Running memory: ".$cluster->getTotalRuntimeMemoryUsage()."\n";
				print "Effective mem capacity: ".$cluster->getEffectiveMemoryCapacity()."\n";
				print "Total mem capacity: ".$cluster->getTotalMemory()."\n";
				print "CPU Usage: ".$cluster->getTotalRuntimeCpuUsage()."\n";
				print "Effective cpu capacity: ".$cluster->getEffectiveCpuCapacity()."\n";
				print "Total cpu capacity: ".$cluster->getTotalCpuCapacity()."\n";
				print "Core amount: ".$cluster->getTotalCpuCoreAmount()."\n";
				print "Thread amount: ".$cluster->getTotalCpuThreadAmount()."\n";
				print "Effective hosts: ".$cluster->getEffectiveHostAmount()."\n";
				print "Number of hosts: ".$cluster->getHostAmount()."\n";
				
				# Go back to Maintenance Mode
				#$host2->enterMaintenanceMode()->waitToComplete();
				
				# Configure DRS/HA
				$cluster->enableDrs();
				$cluster->setDrsMigrationRate(2);
				$cluster->setDrsModeToFullyAutomated();
				$cluster->enableHa(1,1);
				$cluster->setAdmissionControlFailOverResources(12,12);
				
				# Rescan for new devices/datastores
				$cluster->rescanStorageDevices();
				$cluster->rescanVmfsDatastores();
				
			}

			# print $host1->getLatestFault()->getType()." ".$host1->getLatestFaultMessage()."\n";
		}
		else
		{
			print $cluster->getLatestFault()->getType()." ".$cluster->getLatestFaultMessage()."\n";
		}
	}
	else
	{
		print $vim->getLatestFaultMessage()."\n";
	}
}


exit;
