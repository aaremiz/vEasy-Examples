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
	vappname => { type => "=s", required => 1 },
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
my $vappname = Opts::get_option("vappname");
my $foldername = Opts::get_option("foldername");
my $clustername = Opts::get_option("clustername");
my $dsname = Opts::get_option("dsname");

my $vim = vEasy::Connect->new($server, $username, $password);

# Connection OK?
if( $vim )
{
	print "Connected to server: $server\n";
	

	
	# Get Entity
	my $cluster = $vim->getCluster($clustername);
	my $folder = vEasy::Folder->new($vim, $foldername);
	my $ds = vEasy::Datastore->new($vim, $dsname);
	my $vapp = $cluster->createVirtualApp("appp", $folder);
	
	if( $vapp )
	{
		print "NETWORKS:\n";				
		my $networks = $vapp->getNetworks();
		for( my $i = 0; $i < @$networks; ++$i )
		{
			print $networks->[$i]->name()."\n";
		}
		print "DATASTORES:\n";				
		my $datastores = $vapp->getDatastores();
		for( my $i = 0; $i < @$datastores; ++$i )
		{
			print $datastores->[$i]->name()."\n";
		}
		my $parentapp = $vapp->getParentVirtualApp();
		if( $parentapp )
		{
			print "PARENT VAPP: ". $parentapp->name()."\n";
		}
		my $parentfolder = $vapp->getParentFolder();
		if( $parentfolder )
		{
			print "PARENT FOLDER: ". $parentfolder->name()."\n";
		}
		print "Setting annotation notes...\n";
		$vapp->setNotes("Application Notes"); $vapp->refresh();
		print "Notes: ".$vapp->getNotes()."\n";

		print "Setting product name..\n";
		if( not $vapp->setProductName("MyProduct") )
		{
			print $vapp->getLatestFault()->getType()." ".$vapp->getLatestFaultMessage()."\n";
		}
		print "Setting product full version..\n";
		if( not $vapp->setProductFullVersion("v1.2 build 2010") )
		{
			print $vapp->getLatestFault()->getType()." ".$vapp->getLatestFaultMessage()."\n";
		}
		print "Setting product major version..\n";
		if( not $vapp->setProductVersion("v1.2") )
		{
			print $vapp->getLatestFault()->getType()." ".$vapp->getLatestFaultMessage()."\n";
		}
		print "Setting product url..\n";
		if( not $vapp->setProductUrl("http://product.url.com") )
		{
			print $vapp->getLatestFault()->getType()." ".$vapp->getLatestFaultMessage()."\n";
		}
		print "Setting vendor url..\n";
		if( not $vapp->setProductVendorUrl("http://vendor.url.com") )
		{
			print $vapp->getLatestFault()->getType()." ".$vapp->getLatestFaultMessage()."\n";
		}
		print "Setting product vendor..\n";
		if( not $vapp->setProductVendor("aaremiz solutions") )
		{
			print $vapp->getLatestFault()->getType()." ".$vapp->getLatestFaultMessage()."\n";
		}
		print "Setting application url..\n";
		if( not $vapp->setProductApplicationUrl("http://application.url.com") )
		{
			print $vapp->getLatestFault()->getType()." ".$vapp->getLatestFaultMessage()."\n";
		}

		$vapp->refresh();
		
		print "AppUrl: ".$vapp->getProductApplicationUrl()."\n";
		print "FullVersion: ".$vapp->getProductFullVersion()."\n";
		print "Version: ".$vapp->getProductVersion()."\n";
		print "VendorUrl: ".$vapp->getProductVendorUrl()."\n";
		print "Vendor: ".$vapp->getProductVendor()."\n";
		print "ProductUrl: ".$vapp->getProductUrl()."\n";
		# print "Name: ".$vapp->getProductName()."\n";
		
		print "Creating child VMs...\n";
		my $vm1 = $vapp->createVirtualMachine("vm1", $ds);
		my $vm2 = $vapp->createVirtualMachine("vm2", $ds);
		my $vm3 = $vapp->createVirtualMachine("vm3", $ds);
		if( $vm3 and $vm2 and $vm1 )
		{
			print "Setting Child VM parameters...\n";
		
			$vapp->refresh();

			$vapp->setChildStartActionToPowerOn($vm1);
			$vapp->setChildStartActionToNone($vm2);
			$vapp->setChildStartActionToPowerOn($vm3);
			$vapp->setChildStartupOrder($vm1,3);
			$vapp->setChildStartupOrder($vm2,2);
			$vapp->setChildStartupOrder($vm3,1);
			$vapp->setChildStopActionToShutdown($vm1);
			$vapp->setChildStopActionToSuspend($vm2);
			$vapp->setChildStopActionToShutdown($vm3);
			$vapp->setChildStartupDelay($vm1, 20);
			$vapp->setChildStartupDelay($vm2, 30);
			$vapp->setChildStartupDelay($vm3, 40);
			$vapp->setChildShutdownDelay($vm1, 60);
			$vapp->setChildShutdownDelay($vm2, 70);
			$vapp->setChildShutdownDelay($vm3, 80);
			$vapp->enableWaitForToolsRunning($vm1);
			$vapp->enableWaitForToolsRunning($vm2);
			$vapp->enableWaitForToolsRunning($vm3);
		}
		$vapp->remove();
	}
	else
	{
		print "ERROR: VirtualApp not created.\n";
	}
}
else
{
	print "ERROR: Connection failed to server: $server\n";
}


exit;
