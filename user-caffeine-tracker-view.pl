#!/usr/bin/perl

use DBI;
use strict;

# Creating HTML table from the data received from the database
print "Content-Type:text/html\n\n";

#Configuring the database properties
my $driverName = "SQLite";
my $databaseName = "dbCoffee.db";
my $dataSource = "DBI:$driverName:$databaseName";
my $username = "";
my $password = "";
my $dbh = DBI->connect($dataSource, $username, $password, { RaiseError => 1 }) or die $DBI::errstr;

# Fetching all the details of the machines registered and the types of coffee they serve with.
print "<script>localStorage.getItem('id')</script>";
my $id = 1;
my $today = substr(localtime(),0,11);       #To store current date where only records of current date are displayed.
my $query = qq(select t.coffeeType, t.coffeeMg, c.orderedAt from tbCaffeine as c, tbUsers as u, tbMachines as m, tbTypes as t where u.ID = c.userID and m.ID = c.machineID and t.ID = c.typeID and c.orderedAt like '$today%' and u.ID=$id order by u.ID);
my $sth = $dbh->prepare( $query );
my $rv = $sth->execute() or die $DBI::errstr;

#Setting HTML content for the page.
print "

<html>

<head>
	<title>Login Page</title>
	<script>
		chkUser();
		function setId(){
			document.getElementById('userID').value = localStorage.getItem('id');
		}
		//Checking that user has selected some value or not
		function validate(){
			var machine = document.getElementById('coffeeMachines').value;
			var type = document.getElementById('coffeeTypes').value;
			if(machine!='' && type!='')
				return true;
			else{
				alert('Invalid Selections');				
				return false;
			}
		}
		//AJAX function to fill the types of coffee on changing the coffee machine
		function fillTypes(value){
			var xhttp = new XMLHttpRequest();
			xhttp.onreadystatechange = function() {
				if (this.readyState == 4 && this.status == 200) {
					document.getElementById('coffeeTypes').innerHTML = xhttp.responseText;
				}
			};
			xhttp.open('GET', 'fetchTypes.pl?id=' + value, true);
			xhttp.send();
		}
		//Prevent direct running of he page without logging in
		function chkUser() {
			if (localStorage.getItem('id') == null)
				window.location = 'login.html';
		}
		var params = (new URL(document.location)).searchParams;
		if (params.get('email') != null) {
			localStorage.setItem('email', params.get('email'));
			var url = document.location.toString();
			var index = url.indexOf('?');
			window.location = url.substr(0, index);
		}
        if (params.get('success') != null) {
            alert(params.get('success'));
            var url = document.location.toString();
            var index = url.lastIndexOf('/');
			window.location = url.substr(0, index) + '/user-new-coffee-view.pl';
        }
	</script>
	<link rel='stylesheet' href='assets/css/user.css' />
	<link rel='stylesheet' href='assets/css/bootstrap.min.css' />
</head>

<body onload='setId()'>
	<span class='bckg'></span>
	<header>
		<h1 class='dashboard'>Dashboard</h1>
		<nav>
			<ul>
				<li>
					<a href='user-new-coffee-view.pl' data-title='New Coffee'>New Coffee</a>
				</li>
				<li>
					<a href='user-caffeine-tracker-view.pl' data-title='Track Caffeine Intake'>Caffeine Intake</a>
				</li>
			</ul>
		</nav>
	</header>
	<main>
		<div class='title'>
			<h2 class='title'>New Coffee</h2>
			<a href='#' onclick='localStorage.clear(); window.location=\"login.html\"';>Logout
				<script>
					document.write(localStorage.getItem('email'));
				</script>
			</a>
		</div>";
        print "
        <div class='container'>
            <div class='col-xs-9'>
                <div class='table-responsive'>
                    <table summary='This table shows how to create responsive tables using Bootstrap's default functionality' class='table table-bordered table-hover'>
                    <thead>
                        <tr>
                            <th>Coffee Type</th>
                            <th>Coffee mg</th>
                            <th>Timestamp</th>
                        </tr>
                    </thead>
                    <tbody>";
                        while(my @row = $sth->fetchrow_array()){
                            print "
                            <tr>
                                <td>$row[0]</td>
                                <td>$row[1]</td>
                                <td>$row[2]</td>
                            </tr>";
                        }
                        
                    print "</tbody>
                    </table>
                </div><!--end of .table-responsive-->
            </div>
        </div>
	</main>
	<script src='assets/js/jquery.min.js'></script>
	<script src='assets/js/user.js'></script>
</body>

</html>";