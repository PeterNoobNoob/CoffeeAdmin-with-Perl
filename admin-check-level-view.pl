#!/usr/bin/perl

use DBI;
use strict;

#Used to calculate the difference between 2 timestamps
use 5.010;
use Time::Piece;

#Used to calculate floor of a number
use POSIX qw/floor/;

#Configuring the database properties
my $driverName = "SQLite";
my $databaseName = "dbCoffee.db";
my $dataSource = "DBI:$driverName:$databaseName";
my $username = "";
my $password = "";
my $dbh = DBI->connect($dataSource, $username, $password, { RaiseError => 1 }) or die $DBI::errstr;

# Fetching all the details of the machines registered and the types of coffee they are served with.
my $today = substr(localtime(),0,11);       #To store current date where only records of current date are displayed.
my $query = qq(select u.ID, u.firstName, u.lastName, t.coffeeType, t.coffeeMg, c.orderedAt from tbCaffeine as c, 
tbUsers as u, tbMachines as m, tbTypes as t where u.ID = c.userID and m.ID = c.machineID and t.ID = c.typeID and c.orderedAt like '$today%' order by u.ID);
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
            chkUser();
            function chkUser() {
                if (localStorage.getItem('email') == null)
                    window.location = 'admin.html';
            }
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
        
            my $uId = -1;       #Further use of seperation of different sticky notes
            my $hasRows = 0;    #Further use to check whether rows for today exists or not

            #Below variables are used to calculate average caffeine level
            my $total = 0;      #Further use of sum of coffee level calculation for each coffee ordered
            my $ctr = 0;        #Further use of count of total numbers of cups ordered
            while(my @row = $sth->fetchrow_array()){
                
            my @orderTime = split / /, $row[5];             #Used to seperate the date time from the database timestamp
                $hasRows = 1;
                my $flag = 0;

                my $date1 = localtime();
                my $date2 = $row[5];
                my $format = '%a %b %d %H:%M:%S %Y';

                my $diff = Time::Piece->strptime($date1, $format) - Time::Piece->strptime($date2, $format);
                my $mins = floor($diff/60);
                my $hours = floor($mins/60); 
                do{
                    ($mins>59)?$mins -= 60 : "";
                }while($mins>=60);
                my $secs = $diff%60;
                $hours = ($hours<10)?"0" . $hours : $hours;
                $mins = ($mins<10)?"0" . $mins : $mins;
                $secs = ($secs<10)?"0" . $secs : $secs;
                my $difference =  "$hours:$mins:$secs";
                my $percent = 0.00;
                if($diff/3600 <= 1){
                    $percent = sprintf("%.2f", $diff * 0.0278);
                }else{
                    $percent = 100;
                    my $tmpDiff = $diff - 3600;
                    $percent = 100 - sprintf("%.2f", $tmpDiff * 0.00278);
                    if($percent < 0){
                        $percent = 0;
                    }
                }

                if($uId<0){
                    $uId = $row[0];
                    if($flag == 0){
                        print "
                <div class='stickyNote'>
                    <div class='stickyTitle'>
                        $row[1] $row[2]
                    </div>
                    <div class='stickyContent'>
                        <div class='notes-body-scroll enable-scroll'>";
                print "
                            <div class='notes-head align-level'>
                                <span>Order Time</span>
                                <span>Time Elapsed</span>
                                <span>Caffeine Level</span>
                            </div>";
                    }
                    $flag = 1;
                }
                if($uId < $row[0]){
                    $uId = $row[0];
                    if($ctr !=0){
                    print " 
                        <div class='notes-body align-level average'>
                            <span>Average Level</span>
                            <span>" . sprintf("%.2f", $total/$ctr) . "%</span>
                        </div>";
                        }
                        print"
                    </div>
                </div>
            </div>";
            $total = 0;
            $ctr = 0;
            print "
            <div class='stickyNote'>
                <div class='stickyTitle'>
                    $row[1] $row[2]
                </div>
                <div class='stickyContent'>
                    <div class='notes-body-scroll enable-scroll'>";
                        print "
                        <div class='notes-head align-level'>
                            <span>Order Time</span>
                            <span>Time Elapsed</span>
                            <span>Caffeine Level</span>
                        </div>";
                    }
                    print " 
                        <div class='notes-body align-level'>
                            <span>$orderTime[3]</span>
                            <span>$difference</span>
                            <span>$percent%</span>
                        </div>";
                    $total += $percent;
                    $ctr++;
            }
                if($ctr !=0){
                print " 
                        <div class='notes-body align-level average'>
                            <span>Average Level</span>
                            <span>" . sprintf("%.2f", $total/$ctr) . "%</span>
                        </div>";
                }
                        print "
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>";