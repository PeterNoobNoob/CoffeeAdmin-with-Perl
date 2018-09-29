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

# Fetching all the details of the machines selected and the types of coffee they are served with.
my $query = qq(select * from tbTypes as t, tbMachines as m where t.machineID = m.ID and t.machineID = $id);
my $sth = $dbh->prepare( $query );
my $rv = $sth->execute() or die $DBI::errstr;

print "Content-Type:text/html


<option value=''>Select Type</option>";
while(my @row = $sth->fetchrow_array()){
	print "<option value='" . $row[0] . "'>" . $row[2] . "</option>";
}