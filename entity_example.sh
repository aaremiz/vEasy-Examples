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
	entity => {
		type => "=s",
		help => "ManagedEntity name.",
		required => 1,
	},
	type => {
		type => "=s",
		help => "ManagedEntity type: HostSystem, etc",
		required => 1,
	},
);
Opts::add_options(%opts);
Opts::parse();
Opts::validate();
my $server = Opts::get_option("server");
my $username = Opts::get_option("username");
my $password = Opts::get_option("password");
my $entityname = Opts::get_option("entity");
my $type = Opts::get_option("type");

my $vim = vEasy::Connect->new($server, $username, $password);

# Connection OK?
if( $vim )
{
	print "Connected to server: $server\n";
	
	# Get Entity
	my $entity = vEasy::Entity->new($vim, $entityname, $type);
	if( $entity )
	{
		# Get Entity properties
		print "Name: ".$entity->name()."\n";
		print "Type: ".$entity->getType()."\n";
		print "Inventory Path: ".$entity->getInventoryPath()."\n";
		print "MoRef: \n";
		print Dumper($entity->getManagedObjectReference());
		print "Managed Object ID: ".$entity->getManagedObjectId()."\n";
		print "Overall status: ".$entity->getStatus()."\n";
		
		# Print entity parent name and type
		my $parent = $entity->getParent();
		if( $parent )
		{
			print "Parent Name: ".$parent->name()."\n";
			print "Parent Type: ".$parent->getType()."\n";
		}
		else
		{
			print $entity->getLatestFault()->getType()." ".$entity->getLatestFault()->getMessage()."\n";
		}
		
		# Renaming exercise
		if( $entity->rename("TempName") )
		{
			print "Entity renamed.\n";
			$entity->rename($entityname);
			print "Entity renamed again.\n";
		}
		else
		{
			print $entity->getLatestFault()->getType()." ".$entity->getLatestFault()->getMessage()."\n";
		}
		
		# Reload entity info from source
		$entity->reload();
		
		print "Trying to add vCenter custom values..\n";
		# add vcenter custom value and print the value
		$entity->setCustomValue("FIELD2", "VALUE1");
		$entity->refresh();
		print $entity->getCustomValue("FIELD2")."\n";
		
		# Print all faults that have happened to this object.
		my $faults = $entity->getAllFaults();
		for( my $i = 0; $i < @$faults; ++$i )
		{
			print $faults->[$i]->getType()." ".$faults->[$i]->getMessage()."\n";
		}
	}
	else
	{
		print "Entity not found.\n";
	}
}
else
{
	print "ERROR: Connection failed to server: $server\n";
}


exit;
