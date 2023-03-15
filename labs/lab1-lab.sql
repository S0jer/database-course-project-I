use Northwind
--1.1.1
select CompanyName, Address + ' ' + City + ' ' + PostalCode as Adres  from customers

--1.1.2
select Lastname, HomePhone from employees

--1.1.3
select productname, unitprice from products

--1.1.4
select categoryname, Description from categories

--1.1.5
select Homepage, Address + ' ' + City + ' ' + PostalCode as Adres from Suppliers

--1.1.6
select CompanyName, Address + ' ' + City + ' ' + PostalCode as Adres from customers
where City='London'

--1.1.7
select CompanyName, Address + ' ' + City + ' ' + PostalCode as Adres from customers
where Country='France' or Country='Spain'

--1.1.8
select productname, unitprice from products
where unitprice>20 and unitprice<30

--1.1.9
select productname, unitprice, categories.CategoryName from products
inner join categories on categories.categoryid=products.CategoryID
where Categories.categoryName like '%Meat%'

--1.1.10
select productname, unitsinstock, suppliers.companyname from products
inner join Suppliers on suppliers.SupplierID=products.SupplierID
where companyname= 'Tokyo Traders'

--1.1.11
select productname, unitsinstock from products where unitsinstock is null or unitsinstock =0

--1.1.12
select * from products where QuantityPerUnit like '%bottle%'

--1.1.13
select lastname, Title from employees where lastname like '[B-L]%'

--1.1.14
select lastname, Title from employees where lastname like '[BL]%'

--1.1.15
select categoryname, Description from categories where categories.description like '%,%'

--1.1.16
select * from customers where companyname like '%Store%'

--1.1.17
select * from products where unitprice not between 10 and 20
select * from products where unitprice<10 or unitprice>20

--1.1.18
select * from products where unitprice>=20 and unitprice<=30
select * from products where unitprice between 20 and 30

--1.1.19
select companyname, country from customers where country='japan' or country = 'italy'

--1.1.20
select orderid, orderdate, customers.CustomerID from orders inner join customers on orders.CustomerID=customers.CustomerID
where shippeddate is null and ShipCountry ='argentina'

--1.1.21
select companyname, country from customers order by 2,1

--1.1.22
select categoryid, productname, unitprice from products order by 1,3 desc

--1.1.23
select companyname, country from customers where country = 'UK' or country = 'Italy' order by 2,1