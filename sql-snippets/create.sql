use [tmp];

CREATE SCHEMA fc_rw;
CREATE SCHEMA fc_master;
CREATE SCHEMA fc_facts;
CREATE SCHEMA QA;
create schema suraj;
create schema fc_raw;

--q2
CREATE TABLE fc_rw.fc_account_master (
	account_number varchar(25),
	customer_code varchar(15),
	branch int,
	product varchar(5),
	product_category varchar(5),
	acc_open_date date,
	active_flag varchar(8),
	created_by varchar(25) default 'suraj',
	created_on datetime default current_timestamp
	);


CREATE TABLE fc_rw.fc_balance_summary (
	tran_date date,
	account_number varchar(25),
	lcy_amount numeric(11,2),
	created_by varchar(25) default 'suraj',
	created_on datetime default current_timestamp
	);


CREATE TABLE fc_rw.fc_transaction_base (
	tran_date date,
	account_number varchar(25),
	transaction_code varchar(5),
	description1 varchar(150),
	dc_indicator varchar(8),
	is_salary int,
	lcy_amount numeric(11,2),
	created_by varchar(25) default 'suraj',
	created_on datetime default current_timestamp
	);


--q3  --- to store avg_monthy_balance, std_monthly_balance.
CREATE TABLE fc_facts.fc_balance_facts (
	account_number varchar(25),
	avg_monthly_balance float,
	std_monthly_balance float,
	created_by varchar(25) default 'suraj',
	created_on datetime default current_timestamp
	);


--q4  -- to store avg_monthy_deposit, std_monthly_deposit, avg_monthly_withdraw, std_monthly_withdraw.
CREATE TABLE fc_facts.fc_dc (
	account_number varchar(25),
	avg_monthly_deposit float,
	std_monthly_deposit float,
	avg_monthly_withdraw float,
	std_monthly_withdraw float,
	created_by varchar(25) default 'suraj',
	created_on datetime default current_timestamp
	);


--q5  -- to dump result of pentaho transformation that generates balance of today and last three days.
CREATE TABLE fc_facts.fc_balance_last_3_days (
	account_number varchar(25),
	tran_date date,
	balance numeric(11,2),
	balance_before_1_day numeric(11,2),
	balance_before_2_days numeric(11,2),
	balance_before_3_days numeric(11,2),
	created_by varchar(25) default 'suraj',
	created_on datetime default current_timestamp
	);


--q11
CREATE TABLE fc_master.fc_clients (
	id int identity(1,1) not null,
	customer_code varchar(15),
	active_flag varchar(8),
	created_by varchar(25) default 'suraj',
	created_on datetime default current_timestamp,
	modified_by varchar(25),
	modified_on datetime
	);

GO

-- adding trigger to fc_master.fc_clients to add modified_on and modified_by
CREATE TRIGGER update_fcclients_trigger
ON fc_master.fc_clients
AFTER UPDATE
AS
BEGIN
	UPDATE fc_master.fc_clients
	SET modified_by=SUSER_NAME(), modified_on=CURRENT_TIMESTAMP
	FROM INSERTED as i
	WHERE fc_master.fc_clients.id=i.id;
END

GO

--q14 
-- In fc_rw, we have created three tables.
-- Create same tables in fc_raw with some of the column names changed (only table structure)
CREATE TABLE fc_raw.fc_account_master (
	acc_num varchar(25),
	cust_code varchar(15),
	branch int,
	prod varchar(5),
	prod_category varchar(5),
	acc_opening_date date,
	active varchar(8),
	created_by varchar(25) default 'suraj',
	created_on datetime default current_timestamp
	);


CREATE TABLE fc_raw.fc_balance_summary (
	transaction_date date,
	acc_num varchar(25),
	lcy_amt numeric(11,2),
	created_by varchar(25) default 'suraj',
	created_on datetime default current_timestamp
	);


CREATE TABLE fc_raw.fc_transaction_base (
	transaction_date date,
	acc_num varchar(25),
	transaction_code varchar(5),
	description2 varchar(150),
	dc varchar(8),
	is_salary int,
	lcy_amt numeric(11,2),
	created_by varchar(25) default 'suraj',
	created_on datetime default current_timestamp
	);


--q15
-- Create two tables in fc_master as:
-- fc_master.fc_tables with data
-- fc_master.fc_fields_mapping with data
CREATE TABLE fc_master.fc_tables (
	id int unique not null,
	source_schema varchar(25),
	source_table varchar(50),
	destination_schema varchar(25),
	destination_table varchar(50)
	);

INSERT INTO fc_master.fc_tables
VALUES (1,'fc_rw','fc_account_master','fc_raw','fc_account_master'),
	(2,'fc_rw','fc_transaction_base','fc_raw','fc_transaction_base'),
	(3,'fc_rw','fc_balance_summary','fc_raw','fc_balance_summary')


CREATE TABLE fc_master.fc_fields_mapping (
	id int identity(1,1),
	table_id int not null,
	source_field varchar(50),
	destination_field varchar(50),
	CONSTRAINT FK_fieldsmapping_fctables FOREIGN KEY (table_id)
        REFERENCES fc_master.fc_tables (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
	);

INSERT INTO fc_master.fc_fields_mapping (table_id, source_field, destination_field)
VALUES (1,'account_number','acc_num'),
	(1,'customer_code','cust_code'),
	(1,'branch','branch'),
	(1,'product','prod'),
	(1,'product_category','prod_category'),
	(1,'acc_open_date','acc_opening_date'),
	(1,'active_flag','active'),
	(2,'tran_date','transaction_date'),
	(2,'account_number','acc_num'),
	(2,'transaction_code','transaction_code'),
	(2,'description1','description2'),
	(2,'dc_indicator','dc'),
	(2,'is_salary','is_salary'),
	(2,'lcy_amount','lcy_amt'),
	(3,'tran_date','transaction_date'),
	(3,'account_number','acc_num'),
	(3,'lcy_amount','lcy_amt')