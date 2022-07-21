-- Write a SQL script that generate balance of today and last 3 days for which entry is present.

Select account_number, tran_date, lcy_amount as balance, 
	LAG(lcy_amount,1) over(partition by account_number order by tran_date) as balance_before_1_day,
	LAG(lcy_amount,2) over(partition by account_number order by tran_date) as balance_before_2_days,
	LAG(lcy_amount,3) over(partition by account_number order by tran_date) as balance_before_3_days,
	created_by, created_on
from fc_rw.fc_balance_summary
order by account_number,tran_date;


-- Write a SQL script to compare result generated from point 5 and 6 using column name status for 
-- balance of each day.

Select b3.account_number,
    b3.tran_date,
    a.customer_code,
    i.balance as balance_qa,
    b3.balance as balance,
    i.balance_before_1_day as balance_before_1_day_qa,
    b3.balance_before_1_day as balance_before_1_day,
    IIF(i.balance_before_1_day=b3.balance_before_1_day,'EQUAL','NOT EQUAL') as balance_before_1_day_status,
    i.balance_before_2_days as balance_before_2_days_qa,
    b3.balance_before_2_days balance_before_2_days,
    IIF(i.balance_before_2_days=b3.balance_before_2_days,'EQUAL','NOT EQUAL') as balance_before_2_days_status,
    i.balance_before_3_days as balance_before_3_days_qa,
    b3.balance_before_3_days balance_before_3_days,
    IIF(i.balance_before_3_days=b3.balance_before_3_days,'EQUAL','NOT EQUAL') as balance_before_3_days_status
into QA.qa_fc_balance_last_3_days
from fc_facts.fc_balance_last_3_days as b3
inner join (Select account_number, tran_date, lcy_amount as balance, 
            LAG(lcy_amount,1) over(partition by account_number order by tran_date) as balance_before_1_day,
            LAG(lcy_amount,2) over(partition by account_number order by tran_date) as balance_before_2_days,
            LAG(lcy_amount,3) over(partition by account_number order by tran_date) as balance_before_3_days,
            created_by, created_on
        from fc_rw.fc_balance_summary
        ) as i
    on b3.account_number=i.account_number and b3.tran_date=i.tran_date
inner join fc_rw.fc_account_master as a
    on b3.account_number=a.account_number
order by b3.account_number,b3.tran_date;


-- Result generated from point 7 should be dumped into table named 
-- QA.qa_fc_balance_last_3_days. Write a stored procedure.

create or alter proc suraj.sp_balanceLast3DaysStatus
AS
BEGIN
	Select b3.account_number,
		b3.tran_date,
		a.customer_code,
		i.balance as balance_qa,
		b3.balance as balance,
		i.balance_before_1_day as balance_before_1_day_qa,
		b3.balance_before_1_day as balance_before_1_day,
		IIF(i.balance_before_1_day=b3.balance_before_1_day,'EQUAL','NOT EQUAL') as balance_before_1_day_status,
		i.balance_before_2_days as balance_before_2_days_qa,
		b3.balance_before_2_days balance_before_2_days,
		IIF(i.balance_before_2_days=b3.balance_before_2_days,'EQUAL','NOT EQUAL') as balance_before_2_days_status,
		i.balance_before_3_days as balance_before_3_days_qa,
		b3.balance_before_3_days balance_before_3_days,
		IIF(i.balance_before_3_days=b3.balance_before_3_days,'EQUAL','NOT EQUAL') as balance_before_3_days_status
	into QA.qa_fc_balance_last_3_days
	from fc_facts.fc_balance_last_3_days as b3
	inner join (Select account_number, tran_date, lcy_amount as balance, 
				LAG(lcy_amount,1) over(partition by account_number order by tran_date) as balance_before_1_day,
				LAG(lcy_amount,2) over(partition by account_number order by tran_date) as balance_before_2_days,
				LAG(lcy_amount,3) over(partition by account_number order by tran_date) as balance_before_3_days,
				created_by, created_on
			from fc_rw.fc_balance_summary
			) as i
		on b3.account_number=i.account_number and b3.tran_date=i.tran_date
	inner join fc_rw.fc_account_master as a
		on b3.account_number=a.account_number
	order by b3.account_number,b3.tran_date;

	Alter table QA.qa_fc_balance_last_3_days
	add created_by varchar(25) default 'suraj' with values,
		created_on datetime default current_timestamp with values;
END

GO

-- execute
Exec suraj.sp_balanceLast3DaysStatus;

-- check
select * from QA.qa_fc_balance_last_3_days_test order by account_number, tran_date;
