#!/usr/bin/perl

use strict;

#Used for encrypting the password 
use Digest::MD5;
my $md5_email = Digest::MD5->new;
my $md5_pass = Digest::MD5->new;

#Used to fetch the data submitted from the form.
use CGI;
my $cgi = new CGI;

#Declaring an associative array to store the form values
my %input = ();
for my $key ( $cgi->param() ) {
	$input{$key} = $cgi->param($key);
}

# Encrypting the data received from the user input and encrypting it so that it can be compared with the encrypted data stored in the file admin.dat
my $pass = $input{'txtLoginPass'};
$md5_pass->add($pass);
my $loginPass = $md5_pass->hexdigest;

my $email = qq($input{'txtLoginEmail'});
$md5_email->add($email);
my $loginEmail = $md5_email->hexdigest;

# Fetching the data from the file where the login credentials of the admin are stored
open(FILE, "<admin.dat") or die "Couldn't open file file.txt, $!";
my @data = ();
while(<FILE>){
   push(@data, "$_");
}
close(FILE);

# Cheking the login credentials and taking appropriate actions.
if($loginEmail == $data[0] && $loginPass == $data[1]){
    my $url = "http://localhost/caffeine-administrator/admin-register-machine.html?email=$email";
    print "Location: $url\n\n";
}else{
    my $url = "http://localhost/caffeine-administrator/admin.html?error=Invalid Credentials";
    print "Location: $url\n\n";
}