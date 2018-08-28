-- COMP9311 17s2 Assignment 1
-- 
--
-- Date: 22/08/2017
-- 	
-- 
--

-- Some useful domains; you can define more if needed.

CREATE domain URLType as
	varchar(100) check (value like 'http://%');

CREATE domain EmailType as
	varchar(100) check (value like '%@%.%');

CREATE domain PhoneType as
	char(10) check (value ~ '[0-9]{10}');
	
CREATE domain MonetaryType as
		DECIMAL(8,2) check (value >0);

-- car

CREATE TABLE Employee (
	eid          serial, 
    firstName   varchar(50) not NULL,
    familyName  varchar(50) not NULL,
    tfn         char(9) not NULL
	            constraint ValidTFN
		    check (tfn ~ '[0-9]{3}-[0-9]{3}-[0-9]{3}'), 
    salary       integer not NULL check (salary > 0),
	
	primary key (eid)
);

CREATE TABLE salesman (
	eid         integer references Employee (eid),
	commrate	MonetaryType  
			check (commrate > 0 and commrate BETWEEN 5 and 20),
	primary key (eid)
); 

CREATE TABLE mechanic (
	eid         integer references Employee (eid),
	licence		char(8) not NULL
				constraint Validlicence check (licence ~ '[a-zA-Z0-9]{8}'),
	primary key (eid)
);

CREATE TABLE "admin" (  
	eid          integer references Employee (eid),
	primary key (eid)
);
-- CLIENT

create table client (
	cid          serial,
	name 		varchar(100) not NULL,
	address 	varchar(200) not NULL,
	phone		PhoneType,
	email		EmailType,	
	primary key (cid)
);

CREATE TABLE company (
	cid			integer references client (cid),
	abn 		char(8) not NULL
			check (abn ~ '[0-9]{3}'),
	url			URLType,	
	primary key (cid)	
);



-- car

create domain carLicenseType as
        varchar(6) check (value ~ '[0-9A-Za-z]{1,6}');

create domain OptionType as varchar(12)
	check (value in ('sunroof','moonroof','GPS','alloy wheels','leather'));

create domain VINType as char(17) check (value ~'[^((?![IOQ])[A-Z0-9]){17}$]');

CREATE TABLE car (
	VIN  		VINType,
	options		OptionType,
	"YEAR"		integer not NULL check ("YEAR" BETWEEN 1970 and 2099),
	modle		varchar(40) not NULL,
	carLicence	carLicenseType,
	manufacturer varchar(40) not NULL,
	primary key (VIN)
);


CREATE TABLE usedcar (
	VIN				VINType references car(VIN),
	plateNumber		carLicenseType,
	primary key(VIN)
);


CREATE TABLE newcar (
	VIN				VINType references car(VIN),
	plateNumber		carLicenseType,
	charges			MonetaryType not NULL,
	"COST"			MonetaryType not NULL,
	primary key(VIN)
);


-- REPAIRJOB		

CREATE TABLE repairjob (
	cid 			integer not NULL references client(cid),
	VIN				VINType references car(VIN),
	description		varchar(250),
	"NUMBER"		integer UNIQUE
		    check ("NUMBER" BETWEEN 1 and 999),
	costforwork		MonetaryType,
	costforparts	MonetaryType,
	"DATE"			date,
	primary key(cid, VIN, "NUMBER")
);

CREATE TABLE buys(
	VIN  			VINType references usedcar(VIN),
	eid  			integer references salesman(eid),
	cid  			integer references client(cid),
	price			MonetaryType,
	"DATE"			date not NULL,
	commission  	MonetaryType,
	primary key(VIN, eid, cid)	
);





CREATE TABLE does (
	eid			integer references mechanic(eid)unique,
	cid 		integer references client(cid)unique,
	"NUMBER" 	integer references repairjob("NUMBER") unique,
	--VIN  		VINType references repairjob(VIN) unique,

	primary key(eid, "NUMBER", cid)
);


CREATE TABLE sells(
	eid			integer references mechanic(eid),
	cid  		integer references client(cid),
	VIN  		VINType references usedcar(VIN),
	"DATE"		date not NULL,
	price 		MonetaryType not NULL,
	commission 	MonetaryType not NULL,
	primary key(eid,cid,VIN)
);


CREATE TABLE sellsnew(
	eid  		integer references salesman(eid),
	cid  		integer references client(cid),
	VIN  		VINType references newcar(VIN),
	"date" 		date not NULL,
	price 		MonetaryType not NULL,
	commission 	MonetaryType not NULL,
	plateNumber carLicenseType not NULL,
	primary key(eid,cid,VIN)
);






