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

# Fetching all the details of the machines registered and the types of coffee they are served with.
my $query = qq(select * from tbMachines where status=0);
my $sth = $dbh->prepare( $query );
my $rv = $sth->execute() or die $DBI::errstr;

# Creating HTML table from the data received from the database
print "Content-Type:text/html";

#Setting HTML content for the page.
print "

<html>

<head>
	<title>Login Page</title>
	<script>
		
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
		if (params.get('email') != null && params.get('id') != null) {
			localStorage.setItem('email', params.get('email'));
			localStorage.setItem('id', params.get('id'));
			console.log(params.get('id'));
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
		chkUser();
	</script>
	<link rel='stylesheet' href='assets/css/user.css' />
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
		</div>

		<div id='form-main'>
			<div id='form-div'>
				<form class='form' id='form1' action='user-new-coffee.pl' onsubmit='return validate()'>
				
					<p class='text'>
						<div class='select'>
							<select name='coffeeMachines' id='coffeeMachines' onchange='fillTypes(this.value)'>
								<option value=''>Select Machine</option>";
							while(my @row = $sth->fetchrow_array()){
								print "<option value=" . $row[0] . ">" . $row[1] . "</option>"
							}
							print "
							</select>
							<div class='select__arrow'></div>
						</div>
					</p>
									
					<p class='text'>
						<div class='select'>
							<select name='coffeeTypes' id='coffeeTypes'>
								<option value=''>Select Type</option>
							</select>
							<div class='select__arrow'></div>
						</div>
					</p>

					<div class='submit'>
						<input type='submit' value='Order Now' id='button-blue' />
						<div class='ease'></div>
					</div>
					<input type='hidden' name='userID' id='userID' />
				</form>
			</div>
		</div>
	</main>
	<script src='assets/js/jquery.min.js'></script>
	<script src='assets/js/user.js'></script>
</body>

</html>";