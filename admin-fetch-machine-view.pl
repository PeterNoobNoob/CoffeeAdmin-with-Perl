#!/usr/bin/perl

use DBI;
use strict;

#Configuring the database properties
my $driverName = "SQLite";
my $databaseName = "dbCoffee.db";
my $dataSource = "DBI:$driverName:$databaseName";
my $username = "";
my $password = "";
my $dbh = DBI->connect($dataSource, $username, $password, { RaiseError => 1 }) or die $DBI::errstr;

# Fetching all the details of the machines registered and the types of coffee they serve with.
my $query = qq(select m.ID, m.machineName, t.coffeeType, t.coffeeMg from tbMachines as m, tbTypes as t where m.ID = t.machineID and m.status=0 order by m.ID);
my $sth = $dbh->prepare( $query );
my $rv = $sth->execute() or die $DBI::errstr;

# Creating HTML table from the data received from the database
print "Content-Type:text/html


<html>
    <head>
        <title>Different types of Coffee</title>
        <link rel='stylesheet' href='assets/css/machines.css' />
        <link rel='stylesheet' href='assets/css/nav.css' />
        <link rel='stylesheet' href='assets/css/admin.css' />
        <script>
            var params = (new URL(document.location)).searchParams;
            if (params.get('deleted') != null) {
                alert(params.get('deleted'));
                var url = document.location.toString();
                var index = url.indexOf('?');
                window.location = url.substr(0, index);
            }
            function confirmDelete(id, name){
                var res = confirm('Are you sure you want to permanently delete \"' + name + '\"?');
                if(res){
                    window.location= 'delete-machine.pl?id=' + id;
                }else{
                    alert('You cancelled the delete opertaion.');
                }
            }
        </script>
    </head>
    <body>
        <div class='navbar-default'>
        <span>
            <a href='admin-register-machine.html'>Register New Machine</a>
        </span>
        <span>
            <a href='admin-fetch-machine-view.pl'>Registered Machines</a>
        </span>
        <span>
            <a href='admin-check-level-view.pl'>Check Caffeine Level</a>
        </span>
        <span>
                <a href='#' onclick='localStorage.clear(); window.location=\"admin.html\";'>Logout</a>
        </span>
    </div>
    <div id='pageContainer'>
        <div class='note-container content'>";
        my $mId = -1;
        my $flag = 0;
        my $hasRows = 0;
        while(my @row = $sth->fetchrow_array()){
            $hasRows = 1;
            if($mId<0 || $mId < $row[0]){
                $mId = $row[0];
                if($flag == 1){
                    print "</div></div></div>";
                }
                $flag = 1;
                print "
                    <div class='stickyNote'>
                        <div class='stickyTitle'>
                            $row[1]
                            <span class='delete-machine'>
                                <a href='#' title='Delete $row[1]' onclick='confirmDelete($row[0], \"" . $row[1] . "\")'>X</a>
                            </span>
                        </div>
                        <div class='stickyContent'>
                            <div class='notes-head'>
                                <span>Coffee Type</span><span>MG</span>
                            </div>
                            <div class='notes-body-scroll enable-scroll'>";
            }
            print "
                    <div class='notes-body'>
                        <span>$row[2]</span>
                        <span>$row[3]</span>
                    </div>";
        }
        if($hasRows == 1){
            print "
                            </div>
                        </div>
                    </div>
            </div>";
        }else{
            print "</div>
            <H1>No Machines Registered.</H1>";
        }
    print "
    </body>
</html>";