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

Opts::parse();
Opts::validate();
my $server = Opts::get_option("server");
my $username = Opts::get_option("username");
my $password = Opts::get_option("password");


my $vim = vEasy::Connect->new($server, $username, $password);

# Connection OK?
if( $vim )
{
	print "Connected to server: $server\n";
	
	my $sc = $vim->getServiceContent();
	
	my $vim2 = $vim->getConnectionObject();
	
	if( $vim->checkIfConnectedToVcenter() )
	{
		print "Connected to vCenter Server.\n";
	}
	else
	{
		print "Not connected to vCenter Server.\n";	
	}
	if( $vim->checkIfConnectedToHost() )
	{
		print "Connected to ESX(i) Host.\n";
	}	
	else
	{
		print "Not connected to ESX(i) Host.\n";
	}
	print "RootFolder Name is: ".$vim->getRootFolder()->name."\n";
}
else
{
	print "ERROR: Connection failed to server: $server\n";
}


exit;
