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
	dscname => { type => "=s", required => 1 },
	foldername => { type => "=s", required => 1 },
	ds1name => { type => "=s", required => 1 },
	ds2name => { type => "=s", required => 1 },
);
Opts::add_options(%opts);

Opts::parse();
Opts::validate();
my $server = Opts::get_option("server");
my $username = Opts::get_option("username");
my $password = Opts::get_option("password");

my $dscname = Opts::get_option("dscname");
my $foldername = Opts::get_option("foldername");
my $ds1name = Opts::get_option("ds1name");
my $ds2name = Opts::get_option("ds2name");

my $vim = vEasy::Connect->new($server, $username, $password);

# Connection OK?
if( $vim )
{
	print "Connected to server: $server\n";
	
	# Get Entity
	my $folder = vEasy::Folder->new($vim, $foldername);
	my $dsc = $folder->createDatastoreCluster($dscname);
	if( $dsc )
	{
		print "NAME: ".$dsc->name."\n";
		print "Total capacity: ".$dsc->getTotalCapacity()." MB\n";
		print "Free capacity: ".$dsc->getFreeCapacity()." MB\n";
		print "Used capacity: ".$dsc->getUsedCapacity()." MB\n";
		print "SpaceUtilizationThreshold: ".$dsc->getSpaceUtilizationThreshold()."\n";
		print "MinimumSpaceUtilizationDifference: ".$dsc->getMinimumSpaceUtilizationDifference()."\n";
		print "IoLatencyThreshold: ".$dsc->getIoLatencyThreshold()."\n";
		print "IoLoadImbalanceThreshold: ".$dsc->getIoLoadImbalanceThreshold()."\n";
		print "StoragDRS enabled?: ".$dsc->isStorageDrsEnabled()."\n";
		print "IO load balancing enabled?: ".$dsc->isIoLoadBalancingEnabled()."\n";
		print "StorageDrsAutomationLevel: ".$dsc->getStorageDrsAutomationLevel()."\n";

		my $ds1 = vEasy::Datastore->new($vim, $ds1name);
		if( $ds1 )
		{
			$dsc->moveEntityToFolder($ds1);
		}
		my $ds2 = vEasy::Datastore->new($vim, $ds2name);
		if( $ds2 )
		{
			$dsc->moveEntityToFolder($ds2);
		}
		my $task = $dsc->enableStorageDrs();
		if( not $task )
		{
			print $dsc->getLatestFaultMessage()."\n";
		}
		print "\n\nChanging settings: ...";
		$dsc->enableIoLoadBalancing();
		$dsc->setStorageDrsAutomationLevelToAutomated();
		$dsc->keepVirtualMachineDisksOnSameDatastore();
		$dsc->setLoadBalanceInterval(9000);
		$dsc->setMinimumSpaceUtilizationDifference(10);
		$dsc->setSpaceUtilizationThreshold(80);
		$dsc->setIoLatencyThreshold(100);
		$dsc->setIoLoadImbalanceThreshold(24);
		$dsc->refresh();
		print "done\n\n";
		
		print "NAME: ".$dsc->name."\n";
		print "Total capacity: ".$dsc->getTotalCapacity()." MB\n";
		print "Free capacity: ".$dsc->getFreeCapacity()." MB\n";
		print "Used capacity: ".$dsc->getUsedCapacity()." MB\n";
		print "SpaceUtilizationThreshold: ".$dsc->getSpaceUtilizationThreshold()."\n";
		print "MinimumSpaceUtilizationDifference: ".$dsc->getMinimumSpaceUtilizationDifference()."\n";
		print "IoLatencyThreshold: ".$dsc->getIoLatencyThreshold()."\n";
		print "IoLoadImbalanceThreshold: ".$dsc->getIoLoadImbalanceThreshold()."\n";
		print "StoragDRS enabled?: ".$dsc->isStorageDrsEnabled()."\n";
		print "IO load balancing enabled?: ".$dsc->isIoLoadBalancingEnabled()."\n";
		print "StorageDrsAutomationLevel: ".$dsc->getStorageDrsAutomationLevel()."\n";
		
		#$dsc->remove();
	}
	else
	{
		print "Folder not found.\n";
	}
}
else
{
	print "ERROR: Connection failed to server: $server\n";
}


exit;
