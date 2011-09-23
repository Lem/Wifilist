package Map;

sub all() {
	unlink('src/all.txt');
	open OUT, ">> src/all.txt";
	print OUT "lat\tlon\ttitle\tdescription\ticonSize\ticonOffset\ticon\n";
	$array = &Database::getall();
	
	for ($i = 0; $array->[$i]; $i++) {
		($lat,$lon) = split(",", $array->[$i]['3']);
		$lastseen = scalar localtime($array->[$i]['4']);
		if ($array->[$i]['2'] =~ "1") {
			$img = "/img/map_open.png";
		} elsif ($array->[$i]['2'] =~ "2") {
			$img = "/img/map_wep.png";
		} elsif ($array->[$i]['3'] =~ "3") {
			$img = "/img/map_wpa.png";
		}
                $lastseen =~ s/\w+ (\w+) (\d+) ([0-9:]+) (\d+)/$2. $1 $4 - $3/;
		print OUT "$lat\t$lon\t$array->[$i]['0']\tBSSID: $array->[$i]['1']<br><br>Last Seen: $lastseen\t32,32\t0,0\t$img\n";
	}
	return '<div id="map"></div>
  <script src="/OpenLayers.js"></script>
  <script>
    map = new OpenLayers.Map("map");
    map.addLayer(new OpenLayers.Layer.OSM());
 
    var pois = new OpenLayers.Layer.Text( "WLAN",
                    { location:"./src/all.txt",
                      projection: map.displayProjection
                    });
    map.addLayer(pois);
 
    //Set start centrepoint and zoom    
    var lonLat = new OpenLayers.LonLat( 48.0, 7.0 )
          .transform(
            new OpenLayers.Projection("EPSG:4326"), // transform from WGS 1984
            map.getProjectionObject() // to Spherical Mercator Projection
          );
    var zoom=2;
    map.setCenter (lonLat, zoom);  
 
  </script>';
}



return 1;

