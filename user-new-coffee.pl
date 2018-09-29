#!/usr/bin/perl

use DBI;
use strict;

#Used to fetch the data submitted from the form.
use CGI;
my $cgi = new CGI;
my $machineID = $cgi->param('coffeeMachines');
my $typeID = $cgi->param('coffeeTypes');
my $userID = $cgi->param('userID');

#Create a timestamp to insert in the table
my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my @days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);

my $timeStamp = localtime();

#Configuring the database properties
my $driverName = "SQLite";
my $databaseName = "dbCoffee.db";    
my $dataSource = "DBI:$driverName:$databaseName";
my $username = "";
my $password = "";
my $dbh = DBI->connect($dataSource, $username, $password, { RaiseError => 1 }) or die $DBI::errstr;

#Check existence of email in the database using procedures
my $query = qq(insert into tbCaffeine(machineID, typeID, userID, orderedAt) values($machineID, $typeID, $userID, '$timeStamp'););
my $numRows = $dbh->do($query);

#Handling result set returned by sqlite and taking appropriate actions
if($numRows == 0){
    my $url = "http://localhost/caffeine-administrator/user-new-coffee-view.pl?error=Something Went Wrong. Please Try Again.";
    print "Location: $url\n\n";
    $dbh->disconnect();
}elsif($numRows == 1){
    my $url = "http://localhost/caffeine-administrator/user-new-coffee-view.pl?success=Coffee Successfully ordered.";
    print "Location: $url\n\n";
    $dbh->disconnect();
}