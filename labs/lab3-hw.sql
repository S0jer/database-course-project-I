use northwind

--1.1
select oo.orderid, companyname, sum(quantity) as sum from [Order Details] oo
inner join orders o on o.OrderID=oo.OrderID
inner join customers c on c.CustomerID=o.CustomerID
group by oo.orderid, companyname

--1.2
select oo.orderid, companyname, sum(quantity) as sum from [Order Details] oo
inner join orders o on o.OrderID=oo.OrderID
inner join customers c on c.CustomerID=o.CustomerID
group by oo.orderid, companyname having sum(quantity)>250

--1.3
select oo.orderid, companyname, sum(quantity*unitprice*(1-discount)) as 'value' from [Order Details] oo
inner join orders o on o.OrderID=oo.OrderID
inner join customers c on c.CustomerID=o.CustomerID
group by oo.orderid, companyname

--1.4
select oo.orderid, companyname, sum(quantity*unitprice*(1-discount)) as 'value' from [Order Details] oo
inner join orders o on o.OrderID=oo.OrderID
inner join customers c on c.CustomerID=o.CustomerID
group by oo.orderid, companyname having sum(quantity)>250
--1.5
select oo.orderid, companyname, sum(quantity*unitprice*(1-discount)) as 'value', e.FirstName, e.LastName from [Order Details] oo
inner join orders o on o.OrderID=oo.OrderID
inner join customers c on c.CustomerID=o.CustomerID
inner join Employees e on e.EmployeeID=o.EmployeeID
group by oo.orderid, companyname, e.FirstName, e.LastName having sum(quantity)>250


--2.1
select categoryname, sum(quantity) as sum from categories c
inner join products p on p.CategoryID=c.CategoryID
inner join [Order Details] oo on oo.ProductID=p.ProductID
group by c.categoryid, categoryname

--2.2
select categoryname, sum(quantity*oo.UnitPrice*(1-Discount)) as 'Sum of values' from categories c
inner join products p on p.CategoryID=c.CategoryID
inner join [Order Details] oo on oo.ProductID=p.ProductID
group by c.categoryid, categoryname

--2.3
select categoryname, sum(quantity*oo.UnitPrice*(1-Discount)) as 'Sum of values' from categories c
inner join products p on p.CategoryID=c.CategoryID
inner join [Order Details] oo on oo.ProductID=p.ProductID
group by c.categoryid, categoryname order by 2

select categoryname, sum(quantity*oo.UnitPrice*(1-Discount)) as 'Sum of values' from categories c
inner join products p on p.CategoryID=c.CategoryID
inner join [Order Details] oo on oo.ProductID=p.ProductID
group by c.categoryid, categoryname order by sum(Quantity)


--3.1
select s.CompanyName, count(o.orderid) as 'orders done in 1997' from shippers as s
inner join Orders o on o.ShipVia=s.ShipperID and year(o.shippeddate)=1997
group by s.ShipperID, s.CompanyName

--3.2
select top 1 s.CompanyName, count(o.orderid) as 'orders done in 1997' from shippers as s
inner join Orders o on o.ShipVia=s.ShipperID and year(o.shippeddate)=1997
group by s.ShipperID, s.CompanyName order by 2 desc

--3.3
select top 1 firstname, lastname from employees e
inner join orders o on o.EmployeeID=e.EmployeeID and year(o.ShippedDate)=1997
group by e.EmployeeID, firstname, lastname order by count(o.orderid) desc


--4.1
select firstname, lastname, sum(quantity*unitprice*(1-discount)) as sum from employees e
inner join orders o on o.EmployeeID=e.EmployeeID
inner join [Order Details] oo on oo.OrderID=o.OrderID
group by e.EmployeeID, firstname, lastname
order by sum desc

--4.2
select top 1 firstname, lastname, sum(quantity*unitprice*(1-discount)) as sum from employees e
inner join orders o on o.EmployeeID=e.EmployeeID and year(o.shippeddate)=1997
inner join [Order Details] oo on oo.OrderID=o.OrderID
group by e.EmployeeID, firstname, lastname order by 3 desc

--4.3
select e.firstname, e.lastname, sum(quantity*unitprice*(1-discount)) as sum from employees e
inner join employees ee on ee.reportsto=e.EmployeeID
inner join orders o on o.EmployeeID=e.EmployeeID
inner join [Order Details] oo on oo.OrderID=o.OrderID
group by e.EmployeeID, e.firstname, e.lastname

select e.firstname, e.lastname, sum(quantity*unitprice*(1-discount)) as sum from employees e
left join employees ee on ee.reportsto=e.EmployeeID
inner join orders o on o.EmployeeID=e.EmployeeID
inner join [Order Details] oo on oo.OrderID=o.OrderID
group by e.EmployeeID, e.firstname, e.lastname having count(ee.employeeid)=0

