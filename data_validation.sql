
CREATE TABLE customer (
  customer_id SERIAL,
  username VARCHAR(50),
  first_name varchar(255),
  last_name VARCHAR(50),
  country varchar(255),
  town VARCHAR(255),
  is_active boolean,
  PRIMARY KEY (customer_id)
);

CREATE TABLE product (
  product_id SERIAL,
  product_name VARCHAR(50),
  description varchar(255),
  price float,
  mrp float,
  pieces_per_case int,
  weight_per_piece float,
  uom VARCHAR(50),
  brand varchar(255),
  category VARCHAR(50),
  tax_percent int,
  active boolean,
  created_by varchar(255),
  created_date timestamp,
  updated_by varchar(255),
  updated_date timestamp,
  PRIMARY KEY (product_id)
);
id	transaction_id	bill_no	bill_date	bill_location	customer_id	product_id	qty	uom	price	gross_price	tax_pc	tax_amt	discount_pc	discount_amt	net_bill_amt	created_by	created_date	updated_by	updated_date
CREATE TABLE sales (
  id SERIAL,
  transaction_id int,
  bill_no int,
  bill_date timestamp,
  bill_location VARCHAR(50),
  customer_id int,
  product_id int,
  qty int,
  uom varchar(255),
  price float,
  gross_price float,
  tax_pc int,
  tax_amt float,
  discount_pc int,
  discount_amt int,
  net_bill_amt float,
  created_by varchar(255),
  created_date timestamp,
  updated_by varchar(255),
  updated_date timestamp,
  PRIMARY KEY (id)
);
												
CREATE TABLE employee_raw (
  employee_id SERIAL,
  first_name VARCHAR(50),
  last_name varchar(255),
  department_id int,
  department_name varchar(255),
  manager_employee_id int,
  employee_role VARCHAR(50),
  salary int,
  hire_date date,
  terminated_date date,
  terminated_reason varchar(255),
  dob date,
  fte float,
  location varchar(255),
  PRIMARY KEY (employee_id)
);

client_employee_id	department_id	first_name	last_name	manager_employee_id	salary	hire_date	term_date	term_reason	dob	fte	fte_status	weekly_hours	role	is_active											
CREATE TABLE employee (
  client_employee_id SERIAL,
  department_id int,
  first_name VARCHAR(50),
  last_name varchar(255),
  manager_employee_id int,
  salary int,
  hire_date date,
  term_date date,
  term_reason varchar(255),
  dob date,
  fte float,
  fte_status varchar(255),
  weekly_hours int,
  role varchar(255),
  is_active boolean,
  PRIMARY KEY (client_employee_id)
);

CREATE TABLE timesheet_raw (
  employee_id int,
  cost_center int,
  punch_in_time timestamp,
  punch_out_time timestamp,
  punch_apply_date date,
  hours_worked float,
  paycode varchar(255)
);

CREATE TABLE timesheet (
  employee_id int,
  department_id int,
  shift_start_time time,
  shift_end_time time,
  shift_date date,
  shift_type varchar(255),
  hours_worked float,
  attendance boolean,
  has_taken_break boolean,
  break_hour float,
  was_charge boolean,
  charge_hour int,
  was_on_call boolean,
  on_call_hour int,
  num_teammates_absent int
);

COPY customer(customer_id,username,first_name,last_name,country,town,is_active)
FROM 'D:\customer.csv'
DELIMITER ','
CSV HEADER;

COPY product
FROM 'D:\product.csv'
DELIMITER ','
CSV HEADER;

COPY sales
FROM 'D:\sales.csv'
DELIMITER ','
CSV HEADER;

COPY employee_raw
FROM 'D:\employee_raw.csv'
DELIMITER ','
CSV HEADER;

COPY employee
FROM 'D:\employee.csv'
DELIMITER ','
CSV HEADER;

COPY timesheet_raw
FROM 'D:\timesheet_raw.csv'
DELIMITER ','
CSV HEADER;

COPY timesheet
FROM 'D:\timesheet.csv'
DELIMITER ','
CSV HEADER;

select * from customer;
select * from product;
select * from sales;
select * from employee_raw;
select * from employee;
select * from timesheet_raw;
select * from timesheet;

--Check if a single employee is listed twice with multiple ids.
select count(*) as rec_count,
  case
  	when count(*) > 0 then 'failed'
  	else 'passed '
  end as test_status
from (
select * from employee
group by client_employee_id
having count(client_employee_id)>1
) res;


--Check if part time employees are assigned other fte_status.
select count(*) as rec_count,
  case
  	when count(*) > 0 then 'failed'
  	else 'passed '
  end as test_status
from (
select * from employee
where weekly_hours < 40 and fte_status != 'part time'
) res;

--Check if termed employees are marked as active.
select count(*) as rec_count,
  case
  	when count(*) > 0 then 'failed'
  	else 'passed '
  end as test_status
from (
select * from employee
where term_date is not null and is_active= 'true'
) res;

--Check if the same product is listed more than once in a single bill.
select count(*) as rec_count,
  case
  	when count(*) > 0 then 'failed'
  	else 'passed '
  end as test_status
from (
select count(*),bill_no,s.product_id from sales s
inner join product p
on p.product_id=s.product_id
group by bill_no,s.product_id
having count(*) >1
) res;

--Check if the customer_id in the sales table does not exist in the customer table.
select count(*) as rec_count,
  case
  	when count(*) > 0 then 'failed'
  	else 'passed '
  end as test_status
from (
select s.customer_id,c.customer_id from sales s
left join customer c
on c.customer_id=s.customer_id
where c.customer_id is null
) res;

--Check if there are any records where updated_by is not empty but updated_date is empty.
select count(*) as rec_count,
  case
  	when count(*) > 0 then 'failed'
  	else 'passed '
  end as test_status
from (
select * from sales s
where updated_by is not null and updated_date is null
) res;

--Check if there are any hours worked that are greater than 24 hours in a day.
select count(*) as rec_count,
  case
  	when count(*) > 0 then 'failed'
  	else 'passed '
  end as test_status
from (
select * from timesheet s
where hours_worked > 24
) res;

--Check if non on-call employees are set as on-call.
select count(*) as rec_count,
  case
  	when count(*) > 0 then 'failed'
  	else 'passed '
  end as test_status
from (
select * from timesheet 
where was_on_call is false and on_call_hour > 0
) res;

--Check if the break is true for employees who have not taken a break at all.
select count(*) as rec_count,
  case
  	when count(*) > 0 then 'failed'
  	else 'passed '
  end as test_status
from (
select * from timesheet 
where has_taken_break is true and break_hour = 0
) res;

-----new test cases and scripts ---assignment 2

--Q check if employee not having termination date are assigned terminatioin reason

select count(*) as rec_count,
  case
  	when count(*) > 0 then 'failed'
  	else 'passed '
  end as test_status
from (
select * from employee 
where term_date is null and term_reason is not null
) res;

--Q timesheet--check if someone is absent but has hours_worked greater than 0

select count(*) as rec_count,
  case
  	when count(*) > 0 then 'failed'
  	else 'passed '
  end as test_status
from (
select * from timesheet 
where attendance is false and hours_worked > 0
) res;

--Q product--check if product_name and description of that product have same value
 
select count(*) as rec_count,
  case 
  	when count(*) > 0 then 'failed'
  	else 'passed'
  end as test_status
  from(
  select * from product p 
  where product_name = description
  )res;
 
 --Q sales--check if every customer has buy atleast one item 
  
select count(*) as rec_count,
  case 
  	when count(*) > 0 then 'failed'
  	else 'passed'
  end as test_status
  from(
  select c.customer_id from customer c
  left join sales s 
  on s.customer_id=c.customer_id
  where s.customer_id is null
  )res;



