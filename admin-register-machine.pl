#!/usr/bin/perl

use DBI;
use strict;
use CGI;

my $cgi = new CGI;

#Declaring an associative array to store the form values
my %input = ();
my $type = -2;
for my $key ( $cgi->param() ) {
	$input{$key} = $cgi->param($key);
    $type++;
}

#Configuring the database properties
my $driverName = "SQLite";
my $databaseName = "dbCoffee.db";
my $dataSource = "DBI:$driverName:$databaseName";
my $username = "";
my $password = "";
my $dbh = DBI->connect($dataSource, $username, $password, { RaiseError => 1 }) or die $DBI::errstr;

my $machineName = $input{'machineName'};

# Check the existence of Machine Name in the database using procedures
my $sth = $dbh->prepare("select count(1) from tbMachines where machineName=?");
my $rv = $sth->execute($machineName) or die $DBI::errstr;
my $numRows = $sth->fetch()->[0];


if($numRows == 0){
    #If the Machine Name doesn't exists, it will insert a new record in the database.
    my $query = qq(insert into tbMachines(machineName, status) values('$machineName', 0));
    my $numRows1 = $dbh->do($query) or die $DBI::errstr;
    if($numRows1 == 0){
        $dbh->disconnect();
        my $url = "http://localhost/caffeine-administrator/admin-register-machine.html?error=Something went wrong. Please try again";
        print "Location: $url\n\n";
    }elsif($numRows1 == 1){
        # If the record for machine is successfully inserted, it will insert the records for its types

        # Creating 2 array variablesfor storing the inputs received from the user
        my @coffeeType = ();
        my @coffeeMg = ();
        my $counter=0;
        while($type >= 0){
            if(exists($input{qq(coffeeName$counter)})){
                push(@coffeeType, $input{qq(coffeeName$counter)});
                push(@coffeeMg, $input{qq(coffeeMg$counter)});
                $type-=2;
            }
            $counter++;
        }

        # Fetching the ID for the machine currently added for adding link with the machine table
        my $query = qq(select * from tbMachines where machineName='$machineName');
        my $sth = $dbh->prepare( $query );
        my $rv = $sth->execute() or die $DBI::errstr;
        my @row = $sth->fetchrow_array();
        my $machineID = $row[0];

        for (my $i=0; $i < $counter; $i++) {
            $query = "insert into tbTypes(machineID, coffeeType, coffeeMg) values($machineID,'$coffeeType[$i]', $coffeeMg[$i])";
            $dbh->do($query);
        }

        my $url = "http://localhost/caffeine-administrator/admin-register-machine.html?success=Machine Successfully Registered.";
        print "Location: $url\n\n";
        $dbh->disconnect();
    }

}elsif($numRows == 1){
    # If the coffee machine with same name already exists
    $dbh->disconnect();
    my $url = "http://localhost/caffeine-administrator/admin-register-machine.html?error=Coffee Machine Already Exists";
    print "Location: $url\n\n";
}
