#!/usr/bin/perl

use DBI;
use strict;

#Used to fetch the data submitted from the form.
use CGI;
my $cgi = new CGI;

#Declaring an associative array to store the form values
my $id = $cgi->param('id');

#Configuring the database properties
my $driverName = "SQLite";
my $databaseName = "dbCoffee.db";    
my $dataSource = "DBI:$driverName:$databaseName";
my $username = "";
my $password = "";
my $dbh = DBI->connect($dataSource, $username, $password, { RaiseError => 1 }) or die $DBI::errstr;

#Execute query on the database using procedures
my $query = qq(update tbMachines set status=1 where ID=$id);
$dbh->do($query) or die $DBI::errstr;

my $url = "http://localhost/caffeine-administrator/admin-fetch-machine-view.pl?deleted=Machine Successfully Deleted";
print "Location: $url\n\n";
$dbh->disconnect();