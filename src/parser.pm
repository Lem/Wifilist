package Parser;

sub work ($) {
	$fh = shift;
	$cnone = $cwep = $cwpa = $cnew = $cup = 0;
	$xml = &main::XMLin($fh, KeyAttr=>[]);
	foreach my $network (@{$xml->{'wireless-network'}}) {
		next if ($network->{'type'} !~ /infrastructure/);
                $SSID = $network->{'SSID'}->{'essid'}->{'content'} ? $network->{'SSID'}->{'essid'}->{'content'} : '<img src="/img/ghost.png"></img>';
                $BSSID = $network->{'BSSID'};
		if ($network->{'SSID'}->{'encryption'}->[0]) {
			$enc = $network->{'SSID'}->{'encryption'}->[0];
		} elsif ($network->{'SSID'}->{'encryption'}) {
			$enc = $network->{'SSID'}->{'encryption'};
		} else { $enc = "None";}
                $lasttime = $network->{'last-time'};
                $hersteller = $network->{'manuf'};
                $gps = "$network->{'gps-info'}->{'peak-lat'},$network->{'gps-info'}->{'peak-lon'}";

		if ($enc eq "None") {
			$enc = "1";
			$cnone++;
		} elsif ($enc eq "WEP") {
			$enc = "2";
			$cwep++;
		} elsif ($enc =~ /WPA.*/) {
			$enc = "3";
			$cwpa++;
		}	
		$lasttime=~ m/\w+\s(\w+)\s+([0-9]+)\s+([0-9:]+)\s+([0-9]+)/;
		$lasttime = "$2/".lc($1)."/$4 $3";
		$lasttime = &main::str2time("$lasttime");
		if (!&Database::apexist($BSSID)) {
			&Database::insertap($SSID,$BSSID,$enc,$lasttime,$hersteller,$gps);
			$cnew++;
		} elsif (&Database::oldap($BSSID,$lasttime)) {
			&Database::updateap($BSSID,$enc,$lasttime,$gps);
			$cup++;
		} else {
			#what now?
		}

	}
	$main::vars->{'content'} = $cnone+$cwep+$cwpa.' imported ('.$cnone.' Unencrypted, '.$cwep.' WEP, '.$cwpa.' WPA). <br />
    '.$cnew.' new APs.<br />
    '.$cup.' updateds APs.';	
}

sub enc2pic ($) {
	$typ = shift;
	if ($typ == "1") { return '/img/open.png';}
	elsif ($typ == "2") { return '/img/wep.png';}
	elsif ($typ == "3") { return '/img/wpa.png';}
	else { return '/img/unknown.png'; }
}


sub man2pic ($) {
	$man = shift;
	if ($man =~ /Avm/) { return '/img/avm.png';}
	elsif ($man =~ /Apple/) { return '/img/apple.png';}
	elsif ($man =~ /Arcadyan.*/) { return '/img/arcadyan.png';}
	elsif ($man =~ /D-Link/) { return '/img/dlink.png';}
	elsif ($man =~ /Cisco/) { return '/img/cisco.png';}
	elsif ($man =~ /Tecom/) { return '/img/tecom.png';}
	elsif ($man =~ /Belkin.*/) { return '/img/belkin.png';}
	elsif ($man =~ /Tp-Link.*/) { return '/img/tplink.png';}
	elsif ($man =~ /Wistron.*/) { return '/img/wistron.png';}
	elsif ($man =~ /Wistron.*/) { return '/img/zyxel.png';}
	else { return 0;}

}	


return 1;
