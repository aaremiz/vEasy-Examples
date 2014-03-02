#!/usr/bin/perl

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

sub BEGIN{
	push @INC, "../..";
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
