#!/usr/bin/perl -w
use CGI;
use CGI::Carp 'fatalsToBrowser';
use CGI::Cookie;
use CGI::Session;
use DBI;
use Template; 
use XML::Simple;
use Data::Dumper; #debug
use Switch;
use Date::Parse;

my $cgi = new CGI;
my $template = Template->new();
my $html = "src/template.html";

require 'src/parser.pm';
require 'src/db.pm';
require 'src/map.pm';

our $vars = {
    'open'  => -1,
    'wep'     => -1,
    'wpa' => -1,
    'total'      => -1,
    'content'       => "Ich habe keinen Content auf Main.",
};

sub getoverview () {
	$vars->{'open'}= &Database::count("1");
	$vars->{'wep'}=&Database::count("2");
	$vars->{'wpa'}=&Database::count("3");
	$vars->{'total'}=&Database::count();
}

if ($upload = $cgi->upload('file')) { &Parser::work($upload);}

if ($cgi->param('action')) {
	switch ($cgi->param('action')) {
		case "import" { $vars->{'content'}='Import Daten, derzeit nur Kismet-Newcore-Files (.netxml)</p>
    <form id="form1" name="form1" enctype="multipart/form-data" method="post" action="index.pl">
      <label for="file"></label>
      <input type="file" name="file" id="file" />
      <br />
      <input type="submit" name="button" id="button" value="Send" />
    </form>';}
		case "list" { $vars->{'content'} = $cgi->param('typ') ? &Database::list($cgi->param('typ')) : &Database::list("-1");}
		case "search" {	if ($cgi->param('string')) { $vars->{'content'} = &Database::search($cgi->param('string')); } 
				else { $vars->{'content'}= 'Suche in essid, bssid.</p>
    <form id="form1" name="form1" enctype="multipart/form-data" method="post" action="index.pl">
      <input type="text" name="string" id="string" />
      <input type="hidden" name="action" id="hiddenField" value="search"/>
<br />
      <input type="submit" name="button" id="button" value="Send" />
    </form></p>
    <form id="form2" name="form2" method="post" action="index.pl">
      <input type="submit" name="action" id="speedpwn" value="speedpwn" />
    </form>
    <p>';} }
		case "speedpwn" { $vars->{'content'} = &Database::speedpwn(); }
		case "map" { $vars->{'content'} = &Map::all();} 
	}
}


&getoverview;
print "Content-type: text/html\n\n";
$template->process($html, $vars) || die $template->error();
