package Database;

$dbh = DBI->connect( "dbi:SQLite:src/database.db" ) || die "Cannot connect: $DBI::errstr";

sub insertap ($$$$$$) {
	$SSID = shift;
	$BSSID = shift;
	$enc = shift;
	$lasttime = shift;
	$hersteller = shift;
	$gps = shift;

	$q = $dbh->prepare("INSERT INTO ap (bssid, essid, enc, lasttime, hersteller, gps) VALUES (?, ?, ?, ?, ?, ?)");
	$q->bind_param(1,$BSSID);
	$q->bind_param(2,$SSID);
	$q->bind_param(3,$enc);
	$q->bind_param(4,$lasttime);
	$q->bind_param(5,$hersteller);
	$q->bind_param(6,$gps);
	        $q->execute();
}


sub apexist ($) {
	$bssid = shift;
	$q = $dbh->prepare("SELECT bssid FROM ap WHERE bssid = ?");
	$q->bind_param(1,$bssid);
	$q->execute();
	@result = $q->fetchrow_array;
	
	if (!$result[0]){
		return 0; # AP doesn't exist
	}

	return 1;
}

sub updateap ($$$$) {
	$bssid = shift;
	$enc = shift;
	$time = shift;
	$gps = shift;

	$q = $dbh->prepare("UPDATE ap SET lasttime = ?, enc = ?, gps = ? WHERE bssid = ?");
	$q->bind_param(1,$time);
	$q->bind_param(2,$enc);
	$q->bind_param(3,$gps);
	$q->bind_param(4,$bssid);
	$q->execute();
	@result = $q->fetchrow_array;

}

sub oldap ($$) {
	$bssid = shift;
	$newtime = shift;
	
	$q = $dbh->prepare("SELECT lasttime FROM ap WHERE bssid = ?");
	$q->bind_param(1,$bssid);
	$q->execute();
	@result = $q->fetchrow_array;
	
	if ($result[0] < $newtime) {
		return 1;
	}
	return 0;

}

sub count ($) {
	$a = shift;
	if ($a) {
		$q = $dbh->prepare("select count(*) from ap where enc = ?");

		$q->bind_param(1,$a);
	} else {
		$sql = "select count(*) from ap";
		$q = $dbh->prepare($sql);
	}
	$q->execute();
	@result = $q->fetchrow_array;
	
	return $result[0];
}


#### search

sub speedpwn () {
	$q = $dbh->prepare("select essid, bssid, enc, hersteller, gps, lasttime from ap where essid like 'WLAN-%' and substr(bssid,10,2) = substr(essid,6,2) and substr(bssid,13,2) = substr(essid,8,2)");
	$q->execute();

	$table = 'Possible vuln to <a href="http://www.wardriving-forum.de/forum/showthread.php?68609-Speedpwn-PoC-for-Telekom-Arcadayan-Router-Active-Bruteforce">Speedpwn</a>
     <table width="850" border="0" cellspacing="3">
      <tr>
        <th scope="col" width="20%:">ESSID</th>
        <th scope="col">BSSID</th>
        <th scope="col">ENC</th>
        <th scope="col">MANU</th>
        <th scope="col">GPS</th>
        <th scope="col">Last Seen</th>
      </tr>';
        while ($sql = $q->fetchrow_hashref()) {
                $sql->{'hersteller'} = &Parser::man2pic($sql->{'hersteller'})  ? '<img src="'.&Parser::man2pic($sql->{'hersteller'}).'"></img>' : "Unknown";
                $sql->{'lasttime'} = scalar localtime($sql->{'lasttime'});
                $sql->{'lasttime'} =~ s/\w+ (\w+) (\d+) ([0-9:]+) (\d+)/$2. $1 $4 - $3/;
                $table .= '<tr>
        <td><div align="left"><font size="-1">'.$sql->{'essid'}.'</font></div></td>
        <td><div align="center"><font size="-1">'.$sql->{'bssid'}.'</font></font></div></td>
        <td><div align="center"><font size="-1"><img src="'.&Parser::enc2pic($sql->{'enc'}).'"></img></font></div></td>
        <td><div align="center"><font size="-1">'.$sql->{'hersteller'}.'</font></div></td>
        <td><div align="center"><font size="-1">'.$sql->{'gps'}.'</font></div></td>
        <td><div align="center"><font size="-1">'.$sql->{'lasttime'}.'</font></div></td>
      </tr>';
        }
        $table .= '</table>';
        return  $table;


}

sub search ($) {
	$string = shift;
	$q = $dbh->prepare("SELECT * FROM ap WHERE essid LIKE ? OR bssid LIKE ?");
	$q->bind_param(1, $string);
	$q->bind_param(2, $string);
	$q->execute();
	$table = '<table width="850" border="0" cellspacing="3">
      <tr>
        <th scope="col" width="20%:">ESSID</th>
        <th scope="col">BSSID</th>
        <th scope="col">ENC</th>
        <th scope="col">MANU</th>
        <th scope="col">GPS</th>
        <th scope="col">Last Seen</th>
      </tr>';
        while ($sql = $q->fetchrow_hashref()) {
                $sql->{'hersteller'} = &Parser::man2pic($sql->{'hersteller'})  ? '<img src="'.&Parser::man2pic($sql->{'hersteller'}).'"></img>' : "Unknown";
                $sql->{'lasttime'} = scalar localtime($sql->{'lasttime'});
                $sql->{'lasttime'} =~ s/\w+ (\w+) (\d+) ([0-9:]+) (\d+)/$2. $1 $4 - $3/;
                $table .= '<tr>
        <td><div align="left"><font size="-1">'.$sql->{'essid'}.'</font></div></td>
        <td><div align="center"><font size="-1">'.$sql->{'bssid'}.'</font></font></div></td>
        <td><div align="center"><font size="-1"><img src="'.&Parser::enc2pic($sql->{'enc'}).'"></img></font></div></td>
        <td><div align="center"><font size="-1">'.$sql->{'hersteller'}.'</font></div></td>
        <td><div align="center"><font size="-1">'.$sql->{'gps'}.'</font></div></td>
        <td><div align="center"><font size="-1">'.$sql->{'lasttime'}.'</font></div></td>
      </tr>';
        }
        $table .= '</table>';
        return  $table;
}




sub list ($) {
	$typ = shift;
	if ($typ =~ "(bssid|enc|lasttime|bssid|hersteller)") {
		$q = $dbh->prepare("select * from ap order by $typ ASC");
	} else {
		$q = $dbh->prepare("select * from ap order by lasttime DESC");
	}
	$q->execute();
	$table = '<table width="850" border="0" cellspacing="3">
      <tr>
        <th scope="col" width="20%:"><a href="index.pl?action=list&amp;typ=essid">ESSID</a></th>
        <th scope="col"><a href="index.pl?action=list&amp;typ=bssid">BSSID</a></th>
        <th scope="col"><a href="index.pl?action=list&amp;typ=enc">ENC</a></th>
        <th scope="col"><a href="index.pl?action=list&amp;typ=hersteller">MANU</a></th>
        <th scope="col"><a href="index.pl?action=list&amp;typ=gps">GPS</a></th>
        <th scope="col"><a href="index.pl?action=list&amp;typ=lasttime">Last Seen</a></th>
      </tr>';
	while ($sql = $q->fetchrow_hashref()) {
		$sql->{'hersteller'} = &Parser::man2pic($sql->{'hersteller'})  ? '<img src="'.&Parser::man2pic($sql->{'hersteller'}).'"></img>' : "Unknown";
		$sql->{'lasttime'} = scalar localtime($sql->{'lasttime'});
		$sql->{'lasttime'} =~ s/\w+ (\w+) (\d+) ([0-9:]+) (\d+)/$2. $1 $4 - $3/;
		$table .= '<tr>
        <td><div align="left"><font size="-1">'.$sql->{'essid'}.'</font></div></td>
        <td><div align="center"><font size="-1">'.$sql->{'bssid'}.'</font></font></div></td>
        <td><div align="center"><font size="-1"><img src="'.&Parser::enc2pic($sql->{'enc'}).'"</img></font></div></td>
        <td><div align="center"><font size="-1">'.$sql->{'hersteller'}.'</font></div></td>
        <td><div align="center"><font size="-1">'.$sql->{'gps'}.'</font></div></td>
        <td><div align="center"><font size="-1">'.$sql->{'lasttime'}.'</font></div></td>
      </tr>';
	}
	$table .= '</table>';
	return  $table;
}


### map

sub getall() {
	$q = $dbh->prepare("SELECT essid, bssid, enc, gps, lasttime FROM ap");
	$q->execute();
	$all = $q->fetchall_arrayref();
	return $all;
}

return 1;
