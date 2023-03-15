use northwind

--1.1
select companyname, phone from customers
where exists (select * from orders where orders.CustomerID=customers.CustomerID and year(orders.ShippedDate)=1997
and orders.ShipVia=(select shipperid from shippers where CompanyName='United Package'))

select distinct c.companyname, c.phone from customers c
inner join orders o on o.CustomerID=c.CustomerID and year(o.shippeddate)=1997
inner join Shippers s on s.ShipperID=o.ShipVia and s.CompanyName='United Package'

--1.2
select companyname, phone from customers c
where exists 
(select * from orders o where o.CustomerID=c.CustomerID and exists
	(select * from [Order Details] oo where oo.OrderID=o.OrderID and exists
		(select * from products p where p.ProductID=oo.ProductID and exists
			(select * from categories cc where cc.CategoryID=p.CategoryID and categoryname='Confections'))))

select distinct c.companyname, c.phone from customers c
inner join orders o on o.CustomerID=c.CustomerID
inner join [Order Details] oo on oo.OrderID=o.OrderID
inner join Products p on p.ProductID=oo.ProductID
inner join categories cc on cc.CategoryID=p.CategoryID
where categoryname='Confections'

--1.3
select companyname, phone from customers c
where not exists 
(select * from orders o where o.CustomerID=c.CustomerID and exists
	(select * from [Order Details] oo where oo.OrderID=o.OrderID and exists
		(select * from products p where p.ProductID=oo.ProductID and exists
			(select * from categories cc where cc.CategoryID=p.CategoryID and categoryname='Confections'))))

select distinct c.companyname, c.phone from customers c
left join orders o on o.CustomerID=c.CustomerID
left join [Order Details] oo on oo.OrderID=o.OrderID
left join Products p on p.ProductID=oo.ProductID
left join categories cc on cc.CategoryID=p.CategoryID and categoryname='Confections' 
group by c.CustomerID, c.CompanyName, c.Phone having count(cc.categoryid)=0

--2.1
select productid, productname, 
(select max(quantity) from [Order Details] oo where oo.ProductID=p.ProductID group by ProductID ) 
from products p 

select p.productid, productname, max(quantity) from products p
inner join [Order Details] oo on oo.ProductID=p.ProductID
group by p.ProductID, p.ProductName order by 1 

--2.2
select productid, productname from products p
where unitprice<(select avg(unitprice) from products)

select p.productid, p.productname from products p
cross join products pp
group by p.productid, p.productname, p.UnitPrice
having p.unitprice<avg(pp.unitprice)

--2.3
select productid, productname from products p
where unitprice<(select avg(unitprice) from products where CategoryID=p.CategoryID)

select p.productid, p.productname from products p
inner join products pp on pp.CategoryID=p.CategoryID
group by p.productid, p.productname, p.UnitPrice
having p.unitprice<avg(pp.unitprice)


--3.1
select productid, productname, unitprice, 
(select avg(unitprice) from products) as 'AVG', 
unitprice -(select avg(unitprice) from products) as diff
from products p

select p.productid, p.productname, p.unitprice, avg(pp.unitprice) as 'AVG', 
p.unitprice-avg(pp.unitprice) as diff 
from products p
cross join products pp
group by p.productid, p.productname, p.UnitPrice
having p.unitprice<avg(pp.unitprice)

--3.2
select productid, productname, 
(select c.categoryname from Categories c where c.CategoryID=p.CategoryID) as 'Category name',
unitprice, 
(select avg(unitprice) from products where categoryid=p.CategoryID) as 'AVG', 
unitprice -(select avg(unitprice) from products where categoryid=p.CategoryID) as diff
from products p

select p.productid, p.productname, c.CategoryName, p.unitprice, avg(pp.unitprice) as 'AVG', 
p.unitprice-avg(pp.unitprice) as diff 
from products p
inner join products pp on pp.CategoryID=p.CategoryID
inner join categories c on c.CategoryID=p.CategoryID
group by p.productid, p.productname, p.UnitPrice, c.CategoryName


--4.1
select orderid, sum(unitprice*quantity*(1-discount)) + 
(select freight from orders o where o.OrderID=oo.OrderID)  
from [Order Details] oo group by orderid having orderid=10250

select o.orderid, sum(unitprice*quantity*(1-discount)) + freight from orders o
inner join [Order Details] oo on oo.OrderID=o.OrderID and o.OrderID=10250
group by o.OrderID,freight

--4.2
select orderid, sum(unitprice*quantity*(1-discount)) + 
(select freight from orders o where o.OrderID=oo.OrderID)  
from [Order Details] oo group by orderid

select o.orderid, sum(unitprice*quantity*(1-discount)) + freight from orders o
inner join [Order Details] oo on oo.OrderID=o.OrderID
group by o.OrderID,freight

--4.3
select address from customers c
where not exists(select * from orders o where o.CustomerID=c.CustomerID and year(o.orderdate)=1997)

select address from customers c
left join orders o on o.CustomerID=c.CustomerID and year(o.OrderDate)=1997
group by c.customerid, address having count(o.customerID)=0

--4.4
select p.productid from products p
where (select count(distinct customerid) from orders o
		inner join [Order Details] oo on oo.ProductID=p.ProductID and o.OrderID=oo.OrderID
		group by productid)>20

select oo.productid from [Order Details] oo
inner join Orders o on o.OrderID=oo.OrderID
group by oo.productid having count(distinct customerid)>20


--5.1
select firstname, lastname, (select sum(quantity*unitprice*(1-discount)) from [Order Details] oo 
	inner join orders o on o.orderid=oo.orderid and o.EmployeeID=e.employeeid) +
	(select sum(freight) from orders o where o.EmployeeID=e.EmployeeID) from Employees e
	 
--5.2
select top 1 firstname, lastname from employees e
order by (select sum(quantity*unitprice*(1-discount)) from [Order Details] oo 
	inner join orders o on o.orderid=oo.orderid and year(o.ShippedDate)=1997 and o.EmployeeID=e.employeeid) +
	(select sum(freight) from orders o where o.EmployeeID=e.EmployeeID) desc

--5.3
select firstname, lastname, (select sum(quantity*unitprice*(1-discount)) from [Order Details] oo 
	inner join orders o on o.orderid=oo.orderid and o.EmployeeID=e.employeeid) +
	(select sum(freight) from orders o where o.EmployeeID=e.EmployeeID) from Employees e
	where exists (select * from employees ee where ee.ReportsTo=e.EmployeeID)

select firstname, lastname, (select sum(quantity*unitprice*(1-discount)) from [Order Details] oo 
	inner join orders o on o.orderid=oo.orderid and o.EmployeeID=e.employeeid) +
	(select sum(freight) from orders o where o.EmployeeID=e.EmployeeID) from Employees e
	where not exists (select * from employees ee where ee.ReportsTo=e.EmployeeID)

--5.4
select firstname, lastname, (select sum(quantity*unitprice*(1-discount)) from [Order Details] oo 
	inner join orders o on o.orderid=oo.orderid and o.EmployeeID=e.employeeid) +
	(select sum(freight) from orders o where o.EmployeeID=e.EmployeeID),
	(select top 1 shippeddate from orders o where o.EmployeeID=e.EmployeeID order by ShippedDate desc) 
	from Employees e
	where exists (select * from employees ee where ee.ReportsTo=e.EmployeeID)

select firstname, lastname, (select sum(quantity*unitprice*(1-discount)) from [Order Details] oo 
	inner join orders o on o.orderid=oo.orderid and o.EmployeeID=e.employeeid) +
	(select sum(freight) from orders o where o.EmployeeID=e.EmployeeID),
	(select top 1 shippeddate from orders o where o.EmployeeID=e.EmployeeID order by ShippedDate desc) 
	from Employees e
	where not exists (select * from employees ee where ee.ReportsTo=e.EmployeeID)