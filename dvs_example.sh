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
	foldername => { type => "=s", required => 1 },
	dvsname => { type => "=s", required => 1 },
	hostname => { type => "=s", required => 1 },
);
Opts::add_options(%opts);

Opts::parse();
Opts::validate();
my $server = Opts::get_option("server");
my $username = Opts::get_option("username");
my $password = Opts::get_option("password");
my $foldername = Opts::get_option("foldername");
my $dvsname = Opts::get_option("dvsname");
my $hostname = Opts::get_option("hostname");

my $vim = vEasy::Connect->new($server, $username, $password);

# Connection OK?
if( $vim )
{
	print "Connected to server: $server\n";
	
	# Get Entity
	my $folder = $vim->getFolder($foldername);
	# my $dvs = $folder->createDistributedVirtualSwitch($dvsname);
	
	my $dvs = $vim->getDistributedVirtualSwitch($dvsname);
	
	if( $dvs )
	{
		print "HOSTS:\n";
		my $hosts = $dvs->getHosts();
		for( my $i = 0; $i < @$hosts; ++$i )
		{
			print $hosts->[$i]->name()."\n";
		}
		print "VIRTUALMACHINES:\n";				
		my $vms = $dvs->getVirtualMachines();
		for( my $i = 0; $i < @$vms; ++$i )
		{
			print $vms->[$i]->name()."\n";
		}
		print "DV PORTGROUPS:\n";				
		my $dvpg = $dvs->getDistributedVirtualPortgroups();
		
		for( my $i = 0; $i < @$dvpg; ++$i )
		{
			print $dvpg->[$i]->name()."\n";
		}

		print "ContactName: ".$dvs->getContactPersonName()."\n";
		print "ContactInfo: ".$dvs->getContactInformation()."\n";
		print "Notes: ".$dvs->getNotes()."\n";
		print "Port Amount: ".$dvs->getPortAmount()."\n";
		print "Port Max Amount: ".$dvs->getMaxPortAmount()."\n";
		print "Version: ".$dvs->getVersion()."\n";
		print "CreationDate: ".$dvs->getCreationDate()."\n";
		print "Network I/O Control enabled?: ".$dvs->isNetworkIoControlEnabled()."\n";
		
		print "USED VLANS:\n";				
		my $vlans = $dvs->getUsedVlans();
		for( my $i = 0; $i < @$vlans; ++$i )
		{
			print $vlans->[$i]."\n";
		}
		
		print "Creating DV Porgroup...\n";
		$dvs->createDistributedVirtualPortgroup("PortMyGroup");
		
		print "Creating Network ResourcePool...\n";
		if( not $dvs->createNetworkResourcePool("NRP") )
		{
			print $dvs->getLatestFaultMessage()."\n";
		}
		$dvs->refresh();
		print "Removing Network ResourcePool...\n";
		if( not $dvs->removeNetworkResourcePool("NRP") )
		{
			print $dvs->getLatestFaultMessage()."\n";
		}
		
		print "Enable and disable Network I/O Control...\n";
		$dvs->enableNetworkIoControl();
		$dvs->disableNetworkIoControl();
		
		print "Update DVS configs to all member hosts...\n";
		$dvs->updateDvsConfigsToHosts();
		
		print "Setting annotations notes....\n";
		$dvs->setNotes("This is a DVS from vEasy.")->waitToComplete();

		print "Setting contact person....\n";		
		$dvs->setContactPersonName("vEasyAutomaticContactPersonName")->waitToComplete();
		$dvs->refresh();
		print "Setting contact information....\n";		
		$dvs->setContactInformation("veasy\@mail.com")->waitToComplete();
		
		print "Setting amount of uplinks...\n";
		$dvs->setAmountOfUplinks(2, "Link")->waitToComplete();
		
		if( $dvs->addHostToDvs($vim->getHostSystem($hostname)) )
		{
			print $dvs->getLatestFaultMessage()."\n";
		}
		sleep 5;
		$dvs->refresh();
		
		if( not $dvs->addHostPhysicalNicToDvs($vim->getHostSystem($hostname), "vmnic2") )
		{
			print $dvs->getLatestFaultMessage()."\n";
		}
		sleep 15;
		$dvs->refresh();	
		if( not $dvs->removeHostPhysicalNicFromDvs($vim->getHostSystem($hostname), "vmnic2") )
		{
			print $dvs->getLatestFaultMessage()."\n";
		}
		
		if( $dvs->removeHostFromDvs($vim->getHostSystem($hostname)) )
		{
			print $dvs->getLatestFaultMessage()."\n";
		}
		#$dvs->remove();
	}
	else
	{
		print "ERROR: DVS not created.\n";
	}
}
else
{
	print "ERROR: Connection failed to server: $server\n";
}
exit;