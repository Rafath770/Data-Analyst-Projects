## Q1. SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)
## (a). Fetch the employee number, first name and last name of those employees who are working as Sales Rep reporting to employee with employeenumber 1102 (Refer employee table)
Use Classicmodels;
 select employeenumber,Firstname,Lastname 
 from employees
 where jobTitle = "Sales Rep" and reportsTo = 1102;

## (b). Show the unique productline values containing the word cars at the end from the products table.

Select productLine from productlines
where productLine like "%cars";

## Q2) CASE STATEMENTS for Segmentation

Select CustomerNumber,customerName,
CASE
	when country in ("USA" , "Canada") then "North America"
	when country in ("UK" , "France", "Germany") then "Europe"
	else "other"
	end as customerSegment
from Customers;

## Q3. Group By with Aggregation functions and Having clause, Date and Time functions
## (a).Using the OrderDetails table, identify the top 10 products (by productCode) with the highest total order quantity across all orders.

Select * from orderdetails;
Select distinct productCode, sum(quantityOrdered) as Total_Order from orderdetails
group by productCode 
order by Total_Order desc limit 10;

## (b).	Company wants to analyse payment frequency by month. Extract the month name from the payment date to count the total number of payments for each month and include only those months with a payment count exceeding 20. Sort the results by total number of payments in descending order.  (Refer Payments table). 

Select monthname(paymentDate) as Payment_Month,count(*) as Num_Payments  from payments
group by Payment_Month 
having count(*) >20
order by Num_Payments desc;

## Q4).CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default
## (a).Create a table named Customers to store customer information. Include the following columns:
Create database Customers_Orders;
Use Customers_Orders;
create table Customers( Customer_id int auto_increment primary key ,
						first_Name   varchar(50) not null,
						last_Name    varchar(50) not null,
                        Email        varchar(225) unique,
                        phone_Number varchar(20));
                        
create table Orders( Order_id int auto_increment primary key ,
					 Customer_id  int,
					 Order_date   date,
					 Total_amount Decimal(10,2) Check (Total_amount > 0),
					 foreign key(Customer_id) references Customers(Customer_id));

## JOINS
## (a). List the top 5 countries (by order count) that Classic Models ships to. (Use the Customers and Orders tables)
use Classicmodels;
Select country, count(orderNumber) as Order_Count 
from Customers join orders
on Customers.customerNumber = Orders.CustomerNumber
group by country
order by Order_Count desc limit 5;

Select * from Customers;
Select * from Orders;

## Q6. SELF JOIN
## (a). Create a table project with below fields.
Create table Project(EmployeeID int auto_increment primary key,
					 FullName varchar(50),
                     Gender enum ('Male','Female') not null,
                     ManagerID int);
insert into Project (FullName,Gender,ManagerID)
			  Values("Pranaya","Male",3),
					("Priyanka","Female",1),
                    ("Preety","Female",null),
                    ("Anurag","Male",1),
                    ("Sambit","Male",1),
                    ("Rajesh","Male",3),
                    ("Hina","Female",3);

Select * from project;

Select e.FullName as Manager_Name, m.FullName as EMP_Name
from Project as e join project as m
on e.EmployeeID= m.ManagerID
order by 1;

## Q7. DDL Commands: Create, Alter, Rename
## (a). Create table facility. Add the below fields into it.
Create table Facility(Facility_ID int,
					  Name        varchar(100),
                      State		  varchar(100),
                      Country	  varchar(100));
                      
## i) Alter the table by adding the primary key and auto increment to Facility_ID column.
Alter table facility modify Facility_ID int not null auto_increment,
Add primary key (Facility_ID);

describe facility;

## ii) Add a new column city after name with data type as varchar which should not accept any null values.
ALTER TABLE facility ADD COLUMN city VARCHAR(100) NOT NULL AFTER Name;

describe facility;

## Q8. Views in SQL
## (a). Create a view named product_category_sales that provides insights into sales performance by product category. This view should include the following information:

Create View Product_Category_Sales as
select PL.productline, sum(OD.quantityOrdered*OD.PriceEach) as Total_Sales , Count( distinct OD.OrderNumber) as Number_Orders
from productlines as PL
join Products as P on PL.productline = P.productline
join Orderdetails as OD on OD.ProductCode = P.ProductCode
Group by 1;

Select * from product_category_Sales;

Select * from Orderdetails;
Select * from Products;
Select * from Productlines;
 

## Q9. Stored Procedures in SQL with parameters
## (a). Create a stored procedure Get_country_payments which takes in year and country as inputs and gives year wise, country wise total amount as an output. Format the total amount to nearest thousand unit (K)
## Tables: Customers, Payments
 
## Stored Procedure Syntax
/*CREATE DEFINER=`root`@`localhost` PROCEDURE `new_procedure`(P_Year int,P_Country varchar(50))
BEGIN
 SELECT 
        YEAR(paymentDate) AS "Year", country,
        CONCAT(ROUND(SUM(amount) / 1000, 0), 'K') AS Total_amount
    FROM
        Payments AS p
        JOIN Customers AS c 
            ON p.customerNumber = c.customerNumber
    WHERE
        YEAR(paymentDate) = p_Year
        AND c.country = P_Country
    GROUP BY
        YEAR(paymentDate),
        country;
END*/
call classicmodels.get_country_payments(2003, 'France');

## Q10. Window functions - Rank, dense_rank, lead and lag
## a) Using customers and orders tables, rank the customers based on their order frequency

Select c.CustomerName, Count(*) as order_count, DENSE_RANK() Over (order by count(*) Desc) As Order_Rank
from customers as c
Join Orders as o on c.customerNumber = o.customerNumber
group by 1
order by 3,1;

## b) Calculate year wise, month name wise count of orders and year over year (YoY) percentage change. Format the YoY values in no decimals and show in % sign.

Select Year(OrderDate)as Year, Monthname(OrderDate)as Month,count(*) as Total_Order, 
concat(round(((count(*)-lag(count(*)) over  (order by Year(OrderDate)))
/	
lag(count(*)) over  (order by Year(OrderDate)))*100,0),'%') as YOY_Change
from Orders
Group by 1,2;

Select * from Orders;



## Q11.Subqueries and their applications
## (a). Find out how many product lines are there for which the buy price value is greater than the average of buy price value. Show the output as product line and its count.

Select Productline, count(*) as Total
from Products
where BuyPrice > ( select avg(BuyPrice) from Products)
group by 1
Order by 2 desc;
      
Select * from Products;  

## Q12. ERROR HANDLING in SQL

Create table Emp_EH(EmpID int primary key,
					EmpName Varchar(50),
                    EmailAddress varchar(50));
   
## Stored Procedure Syntax   
/* -- Flag for error
 DECLARE v_has_error TINYINT DEFAULT 0;
 -- Error handling
 DECLARE continue handler for sqlexception
 begin
 set v_has_error = 1;
 set v_has_error = 2;
 end;
 insert into Emp_EH(EmpID,EmpName,EmailAddress)
 values(E_ID,E_Name,EmailAdd);
 -- If condition
 IF v_has_error = 1 THEN
 Select 'Error occurred' AS Message;
 elseif v_has_error = 2 THEN
 Select 'Another Error occurred' AS Message;
 ELSE
 Select 'Row inserted successfully' AS Message;
 END IF;  */
 
 ## Q13. TRIGGERS
 
 Create table Emp_BIT(Name Varchar(50),
					  Occupation Varchar(50),
                      Working_date Date,
                      Working_Hrs int);
                      
## Trigger Before Insert
/*  If New.Working_Hrs <0 then
Set New.Working_Hrs = -New.Working_Hrs;
End If;  */

Select * from Emp_Bit;

## As per the question there is no Negitive values in Working_Hrs So its refelct same as the inputs
INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);  

Truncate table Emp_bit;