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
	pgname => { type => "=s", required => 1 },
);
Opts::add_options(%opts);

Opts::parse();
Opts::validate();
my $server = Opts::get_option("server");
my $username = Opts::get_option("username");
my $password = Opts::get_option("password");
my $pgname = Opts::get_option("pgname");

my $vim = vEasy::Connect->new($server, $username, $password);

# Connection OK?
if( $vim )
{
	print "Connected to server: $server\n";
	
	# Get Entity

	my $pg = $vim->getDistributedVirtualPortgroup($pgname);
	
	if( $pg )
	{
		print "Portgroup Name: ".$pg->name()."\n";
		print "DVS: ".$pg->getDistributedVirtualSwitch()->name()."\n";
		print "Portgroup Key: ".$pg->getKey()."\n";
		# print Dumper($pg->getView()->config);

		print "Setting portgroup description\n";
		$pg->setDescription("This is desc from vEasy.")->waitToComplete();
		print "Enabling auto expand:\n";
		$pg->enableAutoExpand()->waitToComplete();
		print "Setting port amount\n";
		$pg->setPortAmount(256)->waitToComplete();
		print "Setting port binding type:\n";
		$pg->setPortBindingTypeToStaticBinding()->waitToComplete();
		# print "Setting portgroup description\n";
		# $pg->setDescription("This is desc from vEasy.")->waitToComplete();
		
		$pg->refresh();
		print "AutoExpand: ".$pg->getAutoExpandStatus()."\n";
		print "Config version: ".$pg->getConfigVersion()."\n";
		print "description: ".$pg->getDescription()."\n";
		print "Port amount: ".$pg->getPortAmount()."\n";
		print "Port name format: ".$pg->getPortNameFormat()."\n";
		print "Port binding type: ".$pg->getPortBindingType()."\n";

		$pg->enablePromiscuousMode()->waitToComplete();
		$pg->enableMacAddressChanges()->waitToComplete();
		$pg->enableForgedTransmits()->waitToComplete();
		$pg->disablePromiscuousMode()->waitToComplete();
		$pg->disableMacAddressChanges()->waitToComplete();
		$pg->disableForgedTransmits()->waitToComplete();
		
		
		$pg->setVlanTypeToNone()->waitToComplete();
		$pg->setVlanId(2049)->waitToComplete();
		$pg->setVlanId(2049)->waitToComplete();
		$pg->setVlanTypeToTrunk(["1","2-3","4","10-120"])->waitToComplete();
		$pg->setVlanTypeToPrivateVlan(300)->waitToComplete();

		$pg->blockTrafficOnAllPorts()->waitToComplete();
		$pg->unblockTrafficOnAllPorts()->waitToComplete();

		$pg->addToNetworkResourcePool("POOLIO")->waitToComplete();
		$pg->removeFromNetworkResourcePool("POOLIO")->waitToComplete();
		
		$pg->setPhysicalNicToUnused("uplink1")->waitToComplete();
		$pg->setPhysicalNicToUnused("uplink2")->waitToComplete();
		$pg->setPhysicalNicToUnused("uplink3")->waitToComplete();
		$pg->setPhysicalNicToUnused("uplink4")->waitToComplete();
		
		$pg->setUplinkPortToStandby("uplink1")->waitToComplete();
		$pg->setUplinkPortToStandby("uplink2")->waitToComplete();
		$pg->setUplinkPortToStandby("uplink3")->waitToComplete();
		$pg->setUplinkPortToStandby("uplink4")->waitToComplete();
		
		$pg->setUplinkPortToActive("uplink1")->waitToComplete();
		$pg->setUplinkPortToActive("uplink2")->waitToComplete();
		$pg->setUplinkPortToActive("uplink3")->waitToComplete();
		$pg->setUplinkPortToActive("uplink4")->waitToComplete();
	
		$pg->enableNotifySwitches()->waitToComplete();
		$pg->disableNotifySwitches()->waitToComplete();
		
		$pg->enableUplinkPortFailback()->waitToComplete();
		$pg->disableUplinkPortFailback()->waitToComplete();
		
		$pg->setUplinkPortLoadBalacingToRouteBasedOnIpHash()->waitToComplete();
		$pg->setUplinkPortLoadBalacingToRouteBasedOnSourceMacHash()->waitToComplete();
		$pg->setUplinkPortLoadBalacingToRouteBasedOnSourcePortId()->waitToComplete();
		$pg->setUplinkPortLoadBalacingToUseRouteBasedOnPhysicalNicLoad()->waitToComplete();
		$pg->setUplinkPortLoadBalacingToUseExplicitFailoverOrder()->waitToComplete();
		
		print $pg->getLatestFaultMessage();
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