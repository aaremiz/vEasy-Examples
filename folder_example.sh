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
	poolname => { type => "=s", required => 1 },
	dsname => { type => "=s", required => 1 },
);
Opts::add_options(%opts);

Opts::parse();
Opts::validate();
my $server = Opts::get_option("server");
my $username = Opts::get_option("username");
my $password = Opts::get_option("password");

my $foldername = Opts::get_option("foldername");
my $poolname = Opts::get_option("poolname");
my $dsname = Opts::get_option("dsname");


my $vim = vEasy::Connect->new($server, $username, $password);

# Connection OK?
if( $vim )
{
	print "Connected to server: $server\n";
	
	# Get Entity
	my $folder = vEasy::Folder->new($vim, $foldername);
	if( $folder )
	{
		print "Creating subfolder...\n";
		my $subfolder = $folder->createFolder("SubFolder");
		if( not $subfolder )
		{
			print $folder->getLatestFault()->getType()." ".$folder->getLatestFault()->getMessage()."\n";
		}
		print "Trying to create a datacenter...\n";
		my $dc = $folder->createDatacenter("DC");
		if( not $dc )
		{
			print $folder->getLatestFault()->getType()." ".$folder->getLatestFault()->getMessage()."\n";
		}
		print "Trying to create a cluster...\n";
		my $cluster = $folder->createCluster("Cluster2");
		if( not $cluster )
		{
			print $folder->getLatestFault()->getType()." ".$folder->getLatestFault()->getMessage()."\n";
		}
		
		my $rp = vEasy::ResourcePool->new($vim, $poolname);
		my $ds = vEasy::Datastore->new($vim, $dsname);
		
		print "Trying to create a VirtualMachine...\n";
		my $vm = $folder->createVirtualMachine("vm", $rp, $ds);
		if( not $vm )
		{
			print $folder->getLatestFault()->getType()." ".$folder->getLatestFault()->getMessage()."\n";
		}
		
		print "Trying to move cluster to subfolder...\n";
		$subfolder->moveEntityToFolder($cluster);
		
		$folder->refresh();
		
		print "CHILD ENTITIES\n";
		my $childs = $folder->getChildEntities();
		
		for(my $i = 0; $i < @$childs; ++$i)
		{
			print $childs->[$i]->getType()." ".$childs->[$i]->name()."\n";
		}
		$subfolder->remove();
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
