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

# Encrypting the password
my $pass = $input{'txtLoginPass'};
$md5->add($pass);
my $loginPass = $md5->hexdigest;

#Execute query on the database using procedures
my $email = qq($input{'txtLoginEmail'});
my $sth = $dbh->prepare("select * from tbUsers where loginEmail=? and loginPass=?");
my $rv = $sth->execute($email, $loginPass) or die $DBI::errstr;

#Handling result set returned by sqlite and taking appropriate actions
while(my @row = $sth->fetchrow_array()){
    if($row[3] == $email){
        my $url = "http://localhost/caffeine-administrator/user-new-coffee-view.pl?email=$email&id=".$row[0];
        print "Location: $url\n\n";
        $dbh->disconnect();
    }else{
        my $url = "http://localhost/caffeine-administrator/login.html?error=Invalid Credentials";
        print "Location: $url\n\n";
        $dbh->disconnect();
    }
}
