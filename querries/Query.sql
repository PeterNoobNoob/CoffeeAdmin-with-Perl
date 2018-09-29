create table tbUsers
(
    ID          INTEGER PRIMARY KEY,
    firstName   VARCHAR(50),
    lastName    VARCHAR(50),
    loginEmail  VARCHAR(50),
    loginPass   VARCHAR(50)
);

create table tbMachines(
    ID          INTEGER PRIMARY KEY,
    machineName varchar(50) not null
);

create table tbTypes(
    ID          INTEGER PRIMARY KEY,
    machineID   int REFERENCES tbMachines(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    coffeeType  varchar(50),
    coffeeMg    int
);

create table tbCaffeine(
    ID          INTEGER PRIMARY KEY,
    machineID   int REFERENCES tbMachines(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    typeID      int REFERENCES tbTypes(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    userID      int REFERENCES tbUsers(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    orderedAt   DATETIME
);
