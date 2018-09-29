#!/usr/bin/perl

use DBI;
use strict;

#Used for encrypting the password 
use Digest::MD5;
my $md5 = Digest::MD5->new;

#Used to fetch the data submitted from the form.
use CGI;
my $cgi = new CGI;

#Declaring an associative array to store the form values
my %input = ();
for my $key ( $cgi->param() ) {
	$input{$key} = $cgi->param($key);
}

#Configuring the database properties
my $driverName = "SQLite";
my $databaseName = "dbCoffee.db";    
my $dataSource = "DBI:$driverName:$databaseName";
my $username = "";
my $password = "";
my $dbh = DBI->connect($dataSource, $username, $password, { RaiseError => 1 }) or die $DBI::errstr;

#Check existence of email in the database using procedures
my $sth = $dbh->prepare("select count(1) from tbUsers where loginEmail=?");
my $rv = $sth->execute($input{'txtLoginEmail'}) or die $DBI::errstr;
my $numRows = $sth->fetch()->[0];

if($numRows == 0){
    #Execute query on the database using procedures
    my $email = qq($input{'txtLoginEmail'});
    my $firstName = $input{'txtFirstName'};
    my $lastName = $input{'txtLastName'};

    # Encrypting the password
    my $pass = $input{'txtLoginPass'};
    $md5->add($pass);
    my $loginPass = $md5->hexdigest;
    my $query = qq(insert into tbUsers(firstName, lastName, loginEmail, loginPass) values('$firstName', '$lastName', '$email', '$loginPass'));
    my $numRows1 = $dbh->do($query);
    
    #Handling result set returned by sqlite and taking appropriate actions
    if($numRows1 == 0){
        my $url = "http://localhost/caffeine-administrator/register.html?error=Something Went Wrong. Please Try Again.";
        print "Location: $url\n\n";
        $dbh->disconnect();
    }elsif($numRows1 == 1){
        my $url = "http://localhost/caffeine-administrator/register.html?success=User Successfully Registered. Redirecting to Login Page";
        print "Location: $url\n\n";
        $dbh->disconnect();
    }

}elsif($numRows == 1){
    $dbh->disconnect();
    my $url = "http://localhost/caffeine-administrator/register.html?error=Email Already Exists";
    print "Location: $url\n\n";
}