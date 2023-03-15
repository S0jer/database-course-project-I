use northwind

--1.1
select orderid, sum(unitprice*quantity*(1-discount)) from [Order Details] group by orderid
order by 2 desc

--1.2
select top 10 orderid, sum(unitprice*quantity*(1-discount)) from [Order Details] group by orderid
order by 2 desc

--1.3
select distinct top 10 with ties orderid, sum(unitprice*quantity*(1-discount))  from [Order Details] group by orderid
order by 2 desc 

--2.1
select sum(quantity), productid from [Order Details] where productid<3 group by productid

--2.2
select sum(quantity), productid from [Order Details] group by productid

--2.3
select orderid, sum(unitprice*quantity*(1-discount)) as value 
from [Order Details] group by orderid having sum(quantity)>250

--3.1
select sum(quantity) as 'Quantity' , productid, orderid 
from [Order Details] group by productid, orderid with rollup

--3.2
select sum(quantity) as 'Quantity' , productid, orderid 
from [Order Details] group by productid, orderid with rollup having productid=50

--3.3
--¯e jest to suma dla wszystkich productid/orderid

--3.4
select sum(quantity) as 'Quantity' , productid, orderid 
from [Order Details] group by productid, orderid with cube

--3.5
--Wszystkie które zawieraj¹ wartoœæ null
--Te wed³ug produktu maj¹ null w orderid, a wed³ug zamówienia null w productid