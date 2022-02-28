create type OrderedFood as table
(
    OrderedFoodID  int,
    MenuPositionID int,
    Quantity       int
)
go

create type People as table
(
    PeopleID  int,
    firstName nvarchar(50),
    lastName  nvarchar(50)
)
go

create type ReservationsDetIDtoTableID as table
(
    TableResId int,
    ResIdTable int
)
go

create table Administrators
(
    AdminID   int         not null,
    FirstName varchar(50) not null,
    LastName  varchar(50) not null,
    Email     varchar(50) not null,
    constraint Administrators_pk
        primary key (AdminID)
)
go

alter table Administrators
    add constraint CK_Administrators_Email
        check ([Email] like '%@%')
go

grant delete, insert, select, update on Administrators to Administrator
go

create table Categories
(
    CategoryID   int         not null,
    CategoryName varchar(50) not null,
    constraint Categories_pk
        primary key (CategoryID),
    unique (CategoryName)
)
go

grant delete, insert, select, update on Categories to Administrator
go

grant delete, insert, select, update on Categories to Manager
go

create table Countries
(
    CountryID   int         not null,
    CountryName varchar(50) not null,
    constraint Countries_pk
        primary key (CountryID),
    unique (CountryName)
)
go

create table Cities
(
    CityID    int         not null,
    CityName  varchar(50) not null,
    CountryID int         not null,
    constraint Cities_pk
        primary key (CityID),
    unique (CityName),
    constraint Cities_Countries
        foreign key (CountryID) references Countries
)
go

grant delete, insert, select, update on Cities to Administrator
go

grant delete, insert, select, update on Countries to Administrator
go

create table Customers
(
    CustomerID int not null,
    CityID     int not null,
    constraint Customers_pk
        primary key (CustomerID),
    constraint Customer_Cities
        foreign key (CityID) references Cities
)
go

create table Company
(
    CustomerID  int          not null,
    CompanyName nvarchar(50) not null,
    NIP         nvarchar(50) not null,
    constraint Company_pk
        primary key (CustomerID),
    unique (CompanyName),
    unique (NIP),
    constraint Company_Customer
        foreign key (CustomerID) references Customers
)
go

alter table Company
    add constraint CK_Company_NIP
        check (isnumeric([NIP]) = 1)
go

grant delete, insert, select, update on Company to Administrator
go

grant delete, insert, select, update on Company to Manager
go

grant delete, insert, select, update on Customers to Administrator
go

grant delete, insert, select, update on Customers to Manager
go

create table DiscountDict
(
    DiscountParamID   int          not null,
    DiscountParamName nvarchar(50) not null,
    constraint DiscountDict_pk
        primary key (DiscountParamID)
)
go

grant delete, insert, select, update on DiscountDict to Administrator
go

create table DiscountParamsHist
(
    DiscountHistID int      not null,
    ParamID        int      not null,
    ParamValue     real     not null,
    ValidFrom      datetime not null,
    ValidTo        datetime,
    constraint DiscountParamsHist_pk
        primary key (DiscountHistID),
    constraint DiscountDict_DiscountParamsHist
        foreign key (ParamID) references DiscountDict
)
go

alter table DiscountParamsHist
    add constraint CK_DiscPH_ParamValue
        check ([ParamValue] > 0 AND [ParamValue] < 1)
go

alter table DiscountParamsHist
    add constraint CK_DiscPH_ValidTo
        check ([ValidTo] IS NULL OR [ValidTo] > [ValidFrom])
go

grant delete, insert, select, update on DiscountParamsHist to Administrator
go

create table Dishes
(
    DishID     int         not null,
    DishName   varchar(50) not null,
    CategoryID int         not null,
    DishPrice  money       not null,
    constraint Dishes_pk
        primary key (DishID),
    unique (DishName),
    constraint Products_Categories
        foreign key (CategoryID) references Categories
)
go

alter table Dishes
    add constraint CK_Dishes_Price
        check ([DishPrice] > 0)
go

grant delete, insert, select, update on Dishes to Administrator
go

grant delete, insert, select, update on Dishes to Manager
go

create table MenuPositions
(
    MenuPositionID int      not null,
    DishID         int      not null,
    DishPrice      money    not null,
    InDate         datetime not null,
    OutDate        datetime,
    constraint MenuPositions_pk
        primary key (MenuPositionID),
    constraint Menu_Products
        foreign key (DishID) references Dishes
)
go

alter table MenuPositions
    add constraint CK_MenuPos_DPrice
        check ([DishPrice] > 0)
go

alter table MenuPositions
    add constraint CK_MenuPos_OutDate
        check ([OutDate] IS NULL OR [OutDate] > [InDate])
go

alter trigger CheckMenuPositions
    on MenuPositions
    after insert, update
    as
    begin
        set nocount on;
        EXECUTE uspCheckMenu
    end
go

grant delete, insert, select, update on MenuPositions to Administrator
go

grant delete, insert, select, update on MenuPositions to Manager
go

create table PaymentStatus
(
    PaymentStatusID   int          not null,
    PaymentStatusName nvarchar(50) not null,
    constraint PaymentStatus_pk
        primary key (PaymentStatusID),
    unique (PaymentStatusName)
)
go

grant delete, insert, select, update on PaymentStatus to Administrator
go

create table Person
(
    PersonID  int          not null,
    LastName  nvarchar(50) not null,
    FirstName nvarchar(50) not null,
    Phone     nvarchar(50) not null,
    constraint Person_pk
        primary key (PersonID)
)
go

create table Employees
(
    EmployeeID int not null,
    PersonID   int not null,
    ReportsTo  int,
    constraint Employees_pk
        primary key (EmployeeID),
    constraint Employees_Employees
        foreign key (ReportsTo) references Employees,
    constraint Employees_Person
        foreign key (PersonID) references Person
)
go

alter table Employees
    add constraint CK_Employees_ReportsTo
        check ([ReportsTo] <> [EmployeeID] OR [ReportsTo] IS NULL)
go

grant delete, insert, select, update on Employees to Administrator
go

create table IndividualCustomers
(
    CustomerID int not null,
    PersonID   int not null,
    constraint IndividualCustomers_pk
        primary key (CustomerID),
    constraint IndividualCustomer_Customer
        foreign key (CustomerID) references Customers,
    constraint Person_IndividualCustomer
        foreign key (PersonID) references Person
)
go

create table ConstantDiscount
(
    ConstantDiscountID int      not null,
    CustomerID         int      not null,
    ValidFrom          datetime not null,
    DiscountValue      real     not null,
    constraint ConstantDiscount_pk
        primary key (ConstantDiscountID),
    constraint IndividualCustomer_ConstantDiscount
        foreign key (CustomerID) references IndividualCustomers
)
go

alter table ConstantDiscount
    add constraint CK_CD_DiscValue
        check ([DiscountValue] > 0 AND [DiscountValue] < 1)
go

alter table ConstantDiscount
    add constraint CK_CD_ValidFrom
        check ([ValidFrom] >= getdate())
go

grant delete, insert, select, update on ConstantDiscount to Administrator
go

grant delete, insert, select, update on ConstantDiscount to Manager
go

grant delete, insert, select, update on IndividualCustomers to Administrator
go

grant delete, insert, select, update on IndividualCustomers to Manager
go

create unique index Person_Ind
    on Person (LastName, FirstName, Phone)
go

alter table Person
    add constraint CK_Person_Phone
        check (isnumeric([Phone]) = 1)
go

grant delete, insert, select, update on Person to Administrator
go

create table ReservationsConditions
(
    ReservationConditionID   int          not null,
    ReservationConditionName nvarchar(50) not null,
    ConditionValue           int          not null,
    constraint ReservationsConditions_pk
        primary key (ReservationConditionID),
    unique (ReservationConditionName)
)
go

alter table ReservationsConditions
    add constraint CK_ResConditions_ConditionValue
        check ([ConditionValue] >= 0)
go

grant delete, insert, select, update on ReservationsConditions to Administrator
go

grant delete, insert, select, update on ReservationsConditions to Manager
go

create table ReservationsStatus
(
    ReservationStatusID   int          not null,
    ReservationStatusName nvarchar(50) not null,
    constraint ReservationsStatus_pk
        primary key (ReservationStatusID),
    unique (ReservationStatusName)
)
go

create table Reservations
(
    ReservationID     int      not null,
    CustomerID        int      not null,
    StartDate         datetime not null,
    EndDate           datetime not null,
    ReservationDate   datetime not null,
    ReservationStatus int      not null,
    constraint Reservations_pk
        primary key (ReservationID),
    constraint Reservation_ReservationStatus
        foreign key (ReservationStatus) references ReservationsStatus
)
go

create table CompanyReservations
(
    ReservationID  int not null,
    CustomerID     int not null,
    numberOfPeople int not null,
    constraint CompanyReservations_pk
        primary key (ReservationID),
    constraint CompanyReservation_Company
        foreign key (CustomerID) references Company,
    constraint Reservation_CompanyReservation
        foreign key (ReservationID) references Reservations
)
go

alter table CompanyReservations
    add constraint CK_CP_nOfPeople
        check ([numberOfPeople] > 0)
go

grant delete, insert, select, update on CompanyReservations to Administrator
go

grant delete, insert, select, update on CompanyReservations to Manager
go

alter table Reservations
    add constraint CK_Reservations_EndDate
        check ([EndDate] > [StartDate] AND datepart(year, [EndDate]) = datepart(year, [StartDate]) AND
               datepart(month, [EndDate]) = datepart(month, [StartDate]) AND
               datepart(day, [EndDate]) = datepart(day, [StartDate]))
go

alter table Reservations
    add constraint CK_Reservations_StartDate
        check ([StartDate] >= [ReservationDate])
go

alter trigger DeclineOrCompleteReservation
    on Reservations
    after insert, update
as
begin
    set nocount on;
    update Reservations
    SET ReservationStatus = 4
    where ReservationStatus = 1 and EndDate < GETDATE()

    update Reservations
    SET ReservationStatus = 2
    where ReservationStatus = 3 and EndDate < GETDATE()
end
go

alter TRIGGER DeleteDeclinedOrderDetails
ON Reservations
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM OrderDetails
    WHERE OrderID in (
        select IndividualReservations.OrderID from IndividualReservations
        inner join dbo.Reservations R2 on R2.ReservationID = IndividualReservations.ReservationID
        where R2.ReservationStatus = 2
        )
end
go

grant delete, insert, select, update on Reservations to Administrator
go

grant delete, insert, select, update on Reservations to Manager
go

grant delete, insert, select, update on ReservationsStatus to Administrator
go

grant delete, insert, select, update on ReservationsStatus to Manager
go

create table SingleDiscount
(
    DiscountID int      not null,
    CustomerID int      not null,
    ValidFrom  datetime not null,
    constraint SingleDiscount_pk
        primary key (DiscountID),
    constraint SingleDiscount_IndividualCustomer
        foreign key (CustomerID) references IndividualCustomers
)
go

grant delete, insert, select, update on SingleDiscount to Administrator
go

grant delete, insert, select, update on SingleDiscount to Manager
go

create table SingleDiscountParams
(
    DiscountHistID         int not null,
    DiscountID             int not null,
    SingleDiscountParamsID int identity,
    constraint SingleDiscountParams_pk_2
        primary key (SingleDiscountParamsID),
    constraint DiscountParams_DiscountParamsHist
        foreign key (DiscountHistID) references DiscountParamsHist,
    constraint DiscountParams_SingleDiscount
        foreign key (DiscountID) references SingleDiscount
)
go

create unique index SingleDiscountParams_SingleDiscountParamsID_uindex
    on SingleDiscountParams (SingleDiscountParamsID)
go

grant delete, insert, select, update on SingleDiscountParams to Administrator
go

create table Tables
(
    TableID  int not null,
    Quantity int not null,
    constraint Tables_pk
        primary key (TableID)
)
go

create table ReservationsDetails
(
    ReservationID         int          not null,
    TableID               int,
    LastName              nvarchar(50) not null,
    FirstName             nvarchar(50) not null,
    ReservationsDetailsID int identity,
    constraint ReservationsDetails_pk
        primary key (ReservationsDetailsID),
    constraint ReservationsDetails_CompanyReservations
        foreign key (ReservationID) references CompanyReservations,
    constraint Tables_ReservationsDetails
        foreign key (TableID) references Tables
)
go

create unique index ReservationsDetails_ReservationsDetailsID_uindex
    on ReservationsDetails (ReservationsDetailsID)
go

alter TRIGGER ConfirmReservationIfTableToRes
ON ReservationsDetails
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Reservations
    SET ReservationStatus = 1
    WHERE ReservationID in(select ReservationID FROM ReservationsDetails
    WHERE TableID is not null)
end
go

grant delete, insert, select, update on ReservationsDetails to Administrator
go

grant delete, insert, select, update on ReservationsDetails to Manager
go

create table TableReservations
(
    TableReservationID    int      not null,
    TableID               int      not null,
    TableReservationStart datetime not null,
    TableReservationEnd   datetime not null,
    constraint TableReservations_pk
        primary key (TableReservationID),
    constraint TableReservation_Tables
        foreign key (TableID) references Tables
)
go

alter table TableReservations
    add constraint CK_TableRes_TableResEnd
        check ([TableReservationEnd] > [TableReservationStart] AND
               datepart(year, [TableReservationEnd]) = datepart(year, [TableReservationStart]) AND
               datepart(month, [TableReservationEnd]) = datepart(month, [TableReservationStart]) AND
               datepart(day, [TableReservationEnd]) = datepart(day, [TableReservationStart]))
go

grant delete, insert, select, update on TableReservations to Administrator
go

grant delete, insert, select, update on TableReservations to Manager
go

alter table Tables
    add constraint CK_Tables_Quantity
        check ([Quantity] > 0)
go

alter trigger DeleteTableFromTableResIfModified
    on Tables
    for delete
    as
begin
    set nocount on
    delete
    from TableReservations
    where TableID = (select TableID from deleted)
end
go

grant delete, insert, select, update on Tables to Administrator
go

grant delete, insert, select, update on Tables to Manager
go

create table TakeawayStatus
(
    TakeawayStatusID   int          not null,
    TakeawayStatusName nvarchar(50) not null,
    constraint TakeawayStatus_pk
        primary key (TakeawayStatusID),
    unique (TakeawayStatusName)
)
go

create table Orders
(
    OrderID        int      not null,
    EmployeeID     int      not null,
    CustomerID     int      not null,
    OrderDate      datetime not null,
    OutDate        datetime,
    PaidDate       datetime,
    TakeawayStatus int      not null,
    PaymentStatus  int      not null,
    constraint Orders_pk
        primary key (OrderID),
    constraint Orders_Customer
        foreign key (CustomerID) references Customers,
    constraint Orders_Employees
        foreign key (EmployeeID) references Employees,
    constraint Orders_PaymentStatus
        foreign key (PaymentStatus) references PaymentStatus,
    constraint Orders_TakeawayStatus
        foreign key (TakeawayStatus) references TakeawayStatus
)
go

create table IndividualReservations
(
    ReservationID  int not null,
    CustomerID     int not null,
    OrderID        int not null,
    numberOfPeople int not null,
    TableID        int,
    constraint IndividualReservations_pk
        primary key (ReservationID),
    constraint IndividualReservation_IndividualCustomer
        foreign key (CustomerID) references IndividualCustomers,
    constraint IndividualReservation_Orders
        foreign key (OrderID) references Orders,
    constraint Reservation_IndividualReservation
        foreign key (ReservationID) references Reservations,
    constraint Tables_IndividualReservations
        foreign key (TableID) references Tables
)
go

alter table IndividualReservations
    add constraint CK_IndiRes_nOfPeople
        check ([numberOfPeople] > 0)
go

alter TRIGGER ConfirmIRReservationAfterAddingTableToRes
ON IndividualReservations
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Reservations SET ReservationStatus = 1
    WHERE ReservationID in (
        select ReservationID from IndividualReservations
        where tableID is not null
        )
end

exec uspDeclineReservation 38
go

grant delete, insert, select, update on IndividualReservations to Administrator
go

grant delete, insert, select, update on IndividualReservations to Manager
go

create table OrderDetails
(
    OrderID        int not null,
    DishID         int not null,
    MenuPositionID int not null,
    Quantity       int not null,
    OrderDetailsID int identity,
    constraint OrderDetails_pk
        primary key (OrderDetailsID),
    constraint OrderDetails_MenuPosition
        foreign key (MenuPositionID) references MenuPositions,
    constraint OrderDetails_Orders
        foreign key (OrderID) references Orders
)
go

create unique index OrderDetails_OrderDetailsID_uindex
    on OrderDetails (OrderDetailsID)
go

alter table OrderDetails
    add constraint CK_OrderDet_Quantity
        check ([Quantity] > 0)
go

grant delete, insert, select, update on OrderDetails to Administrator
go

grant delete, insert, select, update on OrderDetails to Manager
go

alter table Orders
    add constraint CK_Orders_OutDate
        check ([OutDate] IS NULL OR [OutDate] > [OrderDate])
go

alter table Orders
    add constraint CK_Orders_PaidDate
        check ([PaidDate] IS NULL OR [PaidDate] >= [OrderDate])
go

alter TRIGGER SetPaidStatusIfOrderOut
ON Orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Orders
    SET PaidDate = GETDATE()
    WHERE PaymentStatus = 2 and OutDate < GETDATE()
    UPDATE Orders
    SET PaymentStatus = 1
    WHERE PaymentStatus = 2 and OutDate < GETDATE()
end
go

grant delete, insert, select, update on Orders to Administrator
go

grant delete, insert, select, update on Orders to Manager
go

grant delete, insert, select, update on TakeawayStatus to Administrator
go

create table sysdiagrams
(
    name         sysname not null,
    principal_id int     not null,
    diagram_id   int identity,
    version      int,
    definition   varbinary(max),
    primary key (diagram_id),
    constraint UK_principal_name
        unique (principal_id, name)
)
go

alter VIEW AverageOrderPricesForCustomers AS
Select COS.CustomerID,
       P.LastName + ' ' + P.FirstName as Customer,
       Round(AVG(COS.sum),2)                  as AVG,
       'Person' as [Company/Person]
FROM CustomersOrdersSum COS
         INNER JOIN IndividualCustomers IC on COS.CustomerID = IC.CustomerID
         INNER JOIN Person P on P.PersonID = IC.PersonID
GROUP BY COS.CustomerID, P.LastName, P.FirstName
UNION
Select COS.CustomerID,
       C.CompanyName as Customer,
       Round(AVG(COS.sum),2)                 as AVG,
       'Company' as [Company/Person]
FROM CustomersOrdersSum COS
INNER JOIN Company C on COS.CustomerID = C.CustomerID
GROUP BY COS.CustomerID, C.CompanyName
go

grant delete, insert, select, update on AverageOrderPricesForCustomers to Employee
go

alter VIEW CustomersNumbersOfOrders AS
select C.CustomerID,
       P.LastName + ' ' + P.FirstName as Customer,
       count(O.OrderID)               as [Number of Orders],
       'Person' as [Company/Person]
FROM Customers C
         INNER JOIN Orders O on C.CustomerID = O.CustomerID
         INNER JOIN IndividualCustomers IC on C.CustomerID = IC.CustomerID
         INNER JOIN Person P on P.PersonID = IC.PersonID
GROUP BY C.CustomerID, P.LastName + ' ' + P.FirstName
UNION
SELECT C.CustomerID,
       C2.CompanyName as Customer,
       count(O.OrderID)               as [Number of Orders],
       'Company' as [Company/Person]
FROM Customers C
         INNER JOIN Orders O on C.CustomerID = O.CustomerID
         INNER JOIN Company C2 on C.CustomerID = C2.CustomerID
GROUP BY C.CustomerID, C2.CompanyName
go

alter VIEW CustomersOrders AS
SELECT O.OrderID,
       IC.CustomerID,
       P.LastName + ' ' + P.FirstName                                                                           AS [Customer],
       ROUND(SUM(MP.DishPrice * OD.Quantity * (1 - isnull(dbo.udfGetDiscount(O.OrderID, C.CustomerID), 0))),
             2)                                                                                                 AS [Order price],
       O.OrderDate,
       'Person'                                                                                                 as [Company/Person],
       YEAR(O.OrderDate) as Year,
       MONTH(O.OrderDate) as Month
FROM Orders AS O
         INNER JOIN OrderDetails OD on O.OrderID = OD.OrderID
         INNER JOIN MenuPositions MP on MP.MenuPositionID = OD.MenuPositionID
         INNER JOIN Customers C on C.CustomerID = O.CustomerID
         INNER JOIN IndividualCustomers IC on C.CustomerID = IC.CustomerID
         INNER JOIN Person P on P.PersonID = IC.PersonID
GROUP BY O.OrderID, IC.CustomerID, P.LastName + ' ' + P.FirstName, O.OrderDate
UNION
SELECT O.OrderID,
       C.CustomerID,
       C2.CompanyName                            AS [Customer],
       ROUND(SUM(MP.DishPrice * OD.Quantity), 2) AS [Order price],
       O.OrderDate,
       'Company'                                 as [Company/Person],
       YEAR(O.OrderDate) as Year,
       MONTH(O.OrderDate) as Month
FROM Orders AS O
         INNER JOIN OrderDetails OD on O.OrderID = OD.OrderID
         INNER JOIN MenuPositions MP on MP.MenuPositionID = OD.MenuPositionID
         INNER JOIN Customers C on C.CustomerID = O.CustomerID
         INNER JOIN Company C2 on C.CustomerID = C2.CustomerID
GROUP BY O.OrderID, C.CustomerID, C2.CompanyName, O.OrderDate
go

grant delete, insert, select, update on CustomersOrders to Employee
go

alter VIEW CustomersOrdersSum AS
select C.CustomerID,
       O.OrderID,
       ROUND(SUM(MP.DishPrice * OD.Quantity * (1 - isnull(dbo.udfGetDiscount(O.OrderID, C.CustomerID), 0))), 2) as sum
FROM Customers C
         INNER JOIN IndividualCustomers IC on C.CustomerID = IC.CustomerID
         INNER JOIN Person P on P.PersonID = IC.PersonID
         INNER JOIN Orders O on C.CustomerID = O.CustomerID
         INNER JOIN OrderDetails OD on O.OrderID = OD.OrderID
         INNER JOIN MenuPositions MP on MP.MenuPositionID = OD.MenuPositionID
GROUP BY C.CustomerID, O.OrderID
UNION
select C.CustomerID,
       O.OrderID,
       ROUND(SUM(MP.DishPrice * OD.Quantity), 2) as sum
FROM Customers C
         INNER JOIN Company C2 on C.CustomerID = C2.CustomerID
         INNER JOIN Orders O on C.CustomerID = O.CustomerID
         INNER JOIN OrderDetails OD on O.OrderID = OD.OrderID
         INNER JOIN MenuPositions MP on MP.MenuPositionID = OD.MenuPositionID
GROUP BY C.CustomerID, O.OrderID
go

grant delete, insert, select, update on CustomersOrdersSum to Employee
go

-- STATYSTYKI
alter VIEW CustomersStatistics AS
SELECT C.CustomerID,
       cNOO.Customer,
       cNoo.[Company/Person],
       cNOO.[Number of Orders],
       aOPFC.AVG as [Average Order Price]
FROM Customers C
INNER JOIN averageOrderPricesForCustomers aOPFC on C.CustomerID = aOPFC.CustomerID
INNER JOIN customersNumbersOfOrders cNOO on C.CustomerID = cNOO.CustomerID
go

grant delete, insert, select, update on CustomersStatistics to Employee
go

alter VIEW DishesInMenuQuant as
SELECT D.DishName, (select count(*) from Dishes D2
    INNER JOIN MenuPositions MP on D2.DishID = MP.DishID
    where D.DishID = D2.DishID) as DishInMenu from Dishes D
go

grant delete, insert, select, update on DishesInMenuQuant to Employee
go

alter VIEW QuantityOfOrderedDishes as
SELECT D.DishName, (select count(*) from Dishes D2
    INNER JOIN MenuPositions MP on D2.DishID = MP.DishID
    INNER JOIN OrderDetails OD on MP.MenuPositionID = OD.MenuPositionID
    where D.DishID = D2.DishID) as DishQuant from Dishes D
go

alter VIEW allCompaniesReservations AS
SELECT R.ReservationID,
       R.CustomerID,
       C.CompanyName,
       RS.ReservationStatusName,
       R.StartDate,
       R.EndDate,
       YEAR(R.StartDate) as Year,
       MONTH(R.StartDate) as Month
FROM Reservations AS R
         INNER JOIN ReservationsStatus RS on RS.ReservationStatusID = R.ReservationStatus
         INNER JOIN CompanyReservations CR on R.ReservationID = CR.ReservationID
         INNER JOIN Company C on C.CustomerID = CR.CustomerID
go

grant delete, insert, select, update on allCompaniesReservations to Employee
go

alter VIEW allDishes AS
    SELECT DISTINCT D.DishID,
                    D.DishName,
                    C.CategoryName
    FROM Dishes D
    INNER JOIN Categories C on C.CategoryID = D.CategoryID
go

grant delete, insert, select, update on allDishes to Employee
go

alter VIEW allIndividualReservations AS
SELECT R.ReservationID,
       R.CustomerID,
       RS.ReservationStatusName,
       R.StartDate,
       R.EndDate,
       YEAR(R.StartDate) as Year,
       MONTH(R.StartDate) as Month
FROM Reservations AS R
         INNER JOIN IndividualReservations IR on R.ReservationID = IR.ReservationID
         INNER JOIN ReservationsStatus RS on RS.ReservationStatusID = R.ReservationStatus
go

grant delete, insert, select, update on allIndividualReservations to Employee
go

alter VIEW allMenuPositions AS
SELECT DISTINCT MP.MenuPositionID,
                MP.DishID,
                D.DishName,
                Mp.DishPrice,
                Mp.InDate,
                Mp.OutDate
FROM MenuPositions AS MP
         INNER JOIN Dishes D on D.DishID = MP.DishID
go

grant delete, insert, select, update on allMenuPositions to Employee
go

alter VIEW allReservations AS
SELECT R.ReservationID,
       R.CustomerID,
       RS.ReservationStatusName,
       R.StartDate,
       R.EndDate,
       'Individual'       AS Customer,
       Year(R.StartDate)  as Year,
       MONTH(R.StartDate) as Month
FROM Reservations AS R
         INNER JOIN IndividualReservations IR on R.ReservationID = IR.ReservationID
         INNER JOIN ReservationsStatus RS on RS.ReservationStatusID = R.ReservationStatus
UNION
SELECT R.ReservationID,
       R.CustomerID,
       RS.ReservationStatusName,
       R.StartDate,
       R.EndDate,
       'Company'          AS Customer,
       Year(R.StartDate)  as Year,
       MONTH(R.StartDate) as Month
FROM Reservations AS R
         INNER JOIN CompanyReservations CR on R.ReservationID = CR.ReservationID
         INNER JOIN ReservationsStatus RS on RS.ReservationStatusID = R.ReservationStatus
go

grant delete, insert, select, update on allReservations to Employee
go

-- Wyświetla wszystkich uczestników danych rezerwacji firmowych
alter VIEW allReservationsParticipants AS
SELECT CR.ReservationID,
       RD.TableID,
       RD.LastName + ' ' + RD.FirstName AS [Participant name]
FROM CompanyReservations AS CR
INNER JOIN ReservationsDetails RD on CR.ReservationID = RD.ReservationID
INNER JOIN Reservations R on R.ReservationID = CR.ReservationID
INNER JOIN ReservationsStatus RS on RS.ReservationStatusID = R.ReservationStatus
WHERE RS.ReservationStatusName = 'confirmed' OR RS.ReservationStatusName = 'completed'
go

alter view allTableStatistics as
select T.TableID, T.Quantity ,(select count(*) from TableReservations TR
    where T.TableID = TR.TableID) as Used from Tables T
group by T.TableID, T.Quantity
go

grant delete, insert, select, update on allTableStatistics to Employee
go

alter VIEW allUnpaidOrders AS
SELECT O.OrderID,
       O.OrderDate,
       O.CustomerID
FROM Orders AS O
         INNER JOIN PaymentStatus PS on PS.PaymentStatusID = O.PaymentStatus
WHERE PS.PaymentStatusName = 'unpaid'
go

grant delete, insert, select, update on allUnpaidOrders to Employee
go

alter VIEW allWaitingReservations AS
SELECT R.ReservationID,
       R.CustomerID,
       R.ReservationDate,
       R.StartDate,
       R.EndDate
FROM Reservations AS R
         INNER JOIN ReservationsStatus RS on RS.ReservationStatusID = R.ReservationStatus
WHERE ReservationStatusName = 'pending'
go

grant delete, insert, select, update on allWaitingReservations to Employee
go

alter VIEW currentMenu AS
SELECT MP.DishID,
       MP.MenuPositionID,
       D.DishName,
       MP.DishPrice,
       MP.InDate,
       C.CategoryName
FROM MenuPositions AS MP
         INNER JOIN Dishes D on D.DishID = MP.DishID
         INNER JOIN Categories C on C.CategoryID = D.CategoryID
WHERE MP.OutDate IS NULL
   OR MP.OutDate > GETDATE()
go

grant delete, insert, select, update on currentMenu to Employee
go

alter VIEW individualCustomersDiscounts AS
SELECT SD.CustomerID,
       P.LastName + ' ' + P.FirstName AS [Customer Name],
       DD.DiscountParamName,
       DPH.ParamValue,
       DPH.ValidFrom
FROM DiscountParamsHist AS DPH
INNER JOIN DiscountDict DD on DD.DiscountParamID = DPH.ParamID
INNER JOIN SingleDiscountParams SDP on DPH.DiscountHistID = SDP.DiscountHistID
INNER JOIN SingleDiscount SD on SD.DiscountID = SDP.DiscountID
INNER JOIN IndividualCustomers IC on IC.CustomerID = SD.CustomerID
INNER JOIN Person P on P.PersonID = IC.PersonID
UNION
SELECT I.CustomerID,
       P2.LastName + ' ' + P2.FirstName AS [Customer Name],
       'Constant Discount',
       CD.DiscountValue,
       CD.ValidFrom
FROM ConstantDiscount AS CD
INNER JOIN IndividualCustomers I on I.CustomerID = CD.CustomerID
INNER JOIN Person P2 on P2.PersonID = I.PersonID
go

alter view ordersInvoice as
select OD.OrderID,
       O.CustomerID,
       OD.MenuPositionID,
       MP.DishPrice,
       OD.Quantity,
       ROUND(dbo.udfGetDiscount(O.OrderID, O.CustomerID),2) as discount,
       CO.[Order price],
       O.OrderDate,
       year(O.OrderDate) as Year,
       Month(O.OrderDate) as Month
from orders as O
INNER JOIN OrderDetails OD on O.OrderID = OD.OrderID
INNER JOIN CustomersOrders CO on O.OrderID = CO.OrderID and OD.OrderID = CO.OrderID
INNER JOIN MenuPositions MP on MP.MenuPositionID = OD.MenuPositionID
go

alter view whereCustomersAreFrom as
    select C.CountryName, (select count(*) from Countries CS
inner join Cities C2 on CS.CountryID = C2.CountryID
inner join Customers C3 on C2.CityID = C3.CityID
        where CS.CountryID = C.CountryID
        ) as CustomersQuantity  from Countries C
go


	alter FUNCTION dbo.fn_diagramobjects()
	RETURNS int
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		declare @id_upgraddiagrams		int
		declare @id_sysdiagrams			int
		declare @id_helpdiagrams		int
		declare @id_helpdiagramdefinition	int
		declare @id_creatediagram	int
		declare @id_renamediagram	int
		declare @id_alterdiagram 	int
		declare @id_dropdiagram		int
		declare @InstalledObjects	int

		select @InstalledObjects = 0

		select 	@id_upgraddiagrams = object_id(N'dbo.sp_upgraddiagrams'),
			@id_sysdiagrams = object_id(N'dbo.sysdiagrams'),
			@id_helpdiagrams = object_id(N'dbo.sp_helpdiagrams'),
			@id_helpdiagramdefinition = object_id(N'dbo.sp_helpdiagramdefinition'),
			@id_creatediagram = object_id(N'dbo.sp_creatediagram'),
			@id_renamediagram = object_id(N'dbo.sp_renamediagram'),
			@id_alterdiagram = object_id(N'dbo.sp_alterdiagram'),
			@id_dropdiagram = object_id(N'dbo.sp_dropdiagram')

		if @id_upgraddiagrams is not null
			select @InstalledObjects = @InstalledObjects + 1
		if @id_sysdiagrams is not null
			select @InstalledObjects = @InstalledObjects + 2
		if @id_helpdiagrams is not null
			select @InstalledObjects = @InstalledObjects + 4
		if @id_helpdiagramdefinition is not null
			select @InstalledObjects = @InstalledObjects + 8
		if @id_creatediagram is not null
			select @InstalledObjects = @InstalledObjects + 16
		if @id_renamediagram is not null
			select @InstalledObjects = @InstalledObjects + 32
		if @id_alterdiagram  is not null
			select @InstalledObjects = @InstalledObjects + 64
		if @id_dropdiagram is not null
			select @InstalledObjects = @InstalledObjects + 128

		return @InstalledObjects
	END
go

deny execute on fn_diagramobjects to guest
go

grant execute on fn_diagramobjects to [public]
go


	alter PROCEDURE dbo.sp_alterdiagram
	(
		@diagramname 	sysname,
		@owner_id	int	= null,
		@version 	int,
		@definition 	varbinary(max)
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on

		declare @theId 			int
		declare @retval 		int
		declare @IsDbo 			int

		declare @UIDFound 		int
		declare @DiagId			int
		declare @ShouldChangeUID	int

		if(@diagramname is null)
		begin
			RAISERROR ('Invalid ARG', 16, 1)
			return -1
		end

		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner');
		if(@owner_id is null)
			select @owner_id = @theId;
		revert;

		select @ShouldChangeUID = 0
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname

		if(@DiagId IS NULL or (@IsDbo = 0 and @theId <> @UIDFound))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1);
			return -3
		end

		if(@IsDbo <> 0)
		begin
			if(@UIDFound is null or USER_NAME(@UIDFound) is null) -- invalid principal_id
			begin
				select @ShouldChangeUID = 1 ;
			end
		end

		-- update dds data
		update dbo.sysdiagrams set definition = @definition where diagram_id = @DiagId ;

		-- change owner
		if(@ShouldChangeUID = 1)
			update dbo.sysdiagrams set principal_id = @theId where diagram_id = @DiagId ;

		-- update dds version
		if(@version is not null)
			update dbo.sysdiagrams set version = @version where diagram_id = @DiagId ;

		return 0
	END
go

deny execute on sp_alterdiagram to guest
go

grant execute on sp_alterdiagram to [public]
go


	alter PROCEDURE dbo.sp_creatediagram
	(
		@diagramname 	sysname,
		@owner_id		int	= null,
		@version 		int,
		@definition 	varbinary(max)
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on

		declare @theId int
		declare @retval int
		declare @IsDbo	int
		declare @userName sysname
		if(@version is null or @diagramname is null)
		begin
			RAISERROR (N'E_INVALIDARG', 16, 1);
			return -1
		end

		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner');
		revert;

		if @owner_id is null
		begin
			select @owner_id = @theId;
		end
		else
		begin
			if @theId <> @owner_id
			begin
				if @IsDbo = 0
				begin
					RAISERROR (N'E_INVALIDARG', 16, 1);
					return -1
				end
				select @theId = @owner_id
			end
		end
		-- next 2 line only for test, will be removed after define name unique
		if EXISTS(select diagram_id from dbo.sysdiagrams where principal_id = @theId and name = @diagramname)
		begin
			RAISERROR ('The name is already used.', 16, 1);
			return -2
		end

		insert into dbo.sysdiagrams(name, principal_id , version, definition)
				VALUES(@diagramname, @theId, @version, @definition) ;

		select @retval = @@IDENTITY
		return @retval
	END
go

deny execute on sp_creatediagram to guest
go

grant execute on sp_creatediagram to [public]
go


	alter PROCEDURE dbo.sp_dropdiagram
	(
		@diagramname 	sysname,
		@owner_id	int	= null
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
		declare @theId 			int
		declare @IsDbo 			int

		declare @UIDFound 		int
		declare @DiagId			int

		if(@diagramname is null)
		begin
			RAISERROR ('Invalid value', 16, 1);
			return -1
		end

		EXECUTE AS CALLER;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner');
		if(@owner_id is null)
			select @owner_id = @theId;
		REVERT;

		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1)
			return -3
		end

		delete from dbo.sysdiagrams where diagram_id = @DiagId;

		return 0;
	END
go

deny execute on sp_dropdiagram to guest
go

grant execute on sp_dropdiagram to [public]
go


	alter PROCEDURE dbo.sp_helpdiagramdefinition
	(
		@diagramname 	sysname,
		@owner_id	int	= null
	)
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		set nocount on

		declare @theId 		int
		declare @IsDbo 		int
		declare @DiagId		int
		declare @UIDFound	int

		if(@diagramname is null)
		begin
			RAISERROR (N'E_INVALIDARG', 16, 1);
			return -1
		end

		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner');
		if(@owner_id is null)
			select @owner_id = @theId;
		revert;

		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname;
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId ))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1);
			return -3
		end

		select version, definition FROM dbo.sysdiagrams where diagram_id = @DiagId ;
		return 0
	END
go

deny execute on sp_helpdiagramdefinition to guest
go

grant execute on sp_helpdiagramdefinition to [public]
go


	alter PROCEDURE dbo.sp_helpdiagrams
	(
		@diagramname sysname = NULL,
		@owner_id int = NULL
	)
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		DECLARE @user sysname
		DECLARE @dboLogin bit
		EXECUTE AS CALLER;
			SET @user = USER_NAME();
			SET @dboLogin = CONVERT(bit,IS_MEMBER('db_owner'));
		REVERT;
		SELECT
			[Database] = DB_NAME(),
			[Name] = name,
			[ID] = diagram_id,
			[Owner] = USER_NAME(principal_id),
			[OwnerID] = principal_id
		FROM
			sysdiagrams
		WHERE
			(@dboLogin = 1 OR USER_NAME(principal_id) = @user) AND
			(@diagramname IS NULL OR name = @diagramname) AND
			(@owner_id IS NULL OR principal_id = @owner_id)
		ORDER BY
			4, 5, 1
	END
go

deny execute on sp_helpdiagrams to guest
go

grant execute on sp_helpdiagrams to [public]
go


	alter PROCEDURE dbo.sp_renamediagram
	(
		@diagramname 		sysname,
		@owner_id		int	= null,
		@new_diagramname	sysname

	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
		declare @theId 			int
		declare @IsDbo 			int

		declare @UIDFound 		int
		declare @DiagId			int
		declare @DiagIdTarg		int
		declare @u_name			sysname
		if((@diagramname is null) or (@new_diagramname is null))
		begin
			RAISERROR ('Invalid value', 16, 1);
			return -1
		end

		EXECUTE AS CALLER;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner');
		if(@owner_id is null)
			select @owner_id = @theId;
		REVERT;

		select @u_name = USER_NAME(@owner_id)

		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1)
			return -3
		end

		-- if((@u_name is not null) and (@new_diagramname = @diagramname))	-- nothing will change
		--	return 0;

		if(@u_name is null)
			select @DiagIdTarg = diagram_id from dbo.sysdiagrams where principal_id = @theId and name = @new_diagramname
		else
			select @DiagIdTarg = diagram_id from dbo.sysdiagrams where principal_id = @owner_id and name = @new_diagramname

		if((@DiagIdTarg is not null) and  @DiagId <> @DiagIdTarg)
		begin
			RAISERROR ('The name is already used.', 16, 1);
			return -2
		end

		if(@u_name is null)
			update dbo.sysdiagrams set [name] = @new_diagramname, principal_id = @theId where diagram_id = @DiagId
		else
			update dbo.sysdiagrams set [name] = @new_diagramname where diagram_id = @DiagId
		return 0
	END
go

deny execute on sp_renamediagram to guest
go

grant execute on sp_renamediagram to [public]
go


	alter PROCEDURE dbo.sp_upgraddiagrams
	AS
	BEGIN
		IF OBJECT_ID(N'dbo.sysdiagrams') IS NOT NULL
			return 0;

		CREATE TABLE dbo.sysdiagrams
		(
			name sysname NOT NULL,
			principal_id int NOT NULL,	-- we may change it to varbinary(85)
			diagram_id int PRIMARY KEY IDENTITY,
			version int,

			definition varbinary(max)
			CONSTRAINT UK_principal_name UNIQUE
			(
				principal_id,
				name
			)
		);


		/* Add this if we need to have some form of extended properties for diagrams */
		/*
		IF OBJECT_ID(N'dbo.sysdiagram_properties') IS NULL
		BEGIN
			CREATE TABLE dbo.sysdiagram_properties
			(
				diagram_id int,
				name sysname,
				value varbinary(max) NOT NULL
			)
		END
		*/

		IF OBJECT_ID(N'dbo.dtproperties') IS NOT NULL
		begin
			insert into dbo.sysdiagrams
			(
				[name],
				[principal_id],
				[version],
				[definition]
			)
			select
				convert(sysname, dgnm.[uvalue]),
				DATABASE_PRINCIPAL_ID(N'dbo'),			-- will change to the sid of sa
				0,							-- zero for old format, dgdef.[version],
				dgdef.[lvalue]
			from dbo.[dtproperties] dgnm
				inner join dbo.[dtproperties] dggd on dggd.[property] = 'DtgSchemaGUID' and dggd.[objectid] = dgnm.[objectid]
				inner join dbo.[dtproperties] dgdef on dgdef.[property] = 'DtgSchemaDATA' and dgdef.[objectid] = dgnm.[objectid]

			where dgnm.[property] = 'DtgSchemaNAME' and dggd.[uvalue] like N'_EA3E6268-D998-11CE-9454-00AA00A3F36E_'
			return 2;
		end
		return 1;
	END
go

alter function udfGetBestSellingDishes(@x int)
    RETURNS table AS RETURN
    select TOP (@x) * from QuantityOfOrderedDishes
    order by DishQuant desc
go

alter FUNCTION udfGetCompaniesStatistics()
   RETURNS table AS
       RETURN
       SELECT CustomerID, Customer, [Company/Person], [Number of Orders], [Average Order Price]
       FROM CustomersStatistics CS
       WHERE CS.[Company/Person] = 'Company'
go

alter FUNCTION udfGetCustomerStatisticsById(@id int)
   RETURNS table AS
       RETURN
       select customerid, customer, [company/person], [number of orders], [average order price]
        from CustomersStatistics CS
        where CS.CustomerID = @id
go

alter FUNCTION udfGetDiscount(@order_id int, @customer_id int)
RETURNS FLOAT AS
   BEGIN
       DECLARE @val1 float;
       DECLARE @val2 float;
       DECLARE @maxval float;
       SET @val1 = ISNULL((
           select DiscountValue
           from ConstantDiscount CD
           INNER JOIN Orders O on @order_id = O.OrderID
           where (CD.CustomerID = @customer_id and O.OrderDate >= CD.ValidFrom)
           ),0)
       SET @val2 = ISNULL((
           select DPH.ParamValue
           from SingleDiscount SD
           INNER JOIN SingleDiscountParams SDP on SD.DiscountID = SDP.DiscountID
           INNER JOIN DiscountParamsHist DPH on SDP.DiscountHistID = DPH.DiscountHistID
           INNER JOIN Orders O on @order_id = O.OrderID
           where (SD.CustomerID = @customer_id and O.OrderDate >= DPH.ValidFrom and O.OrderDate <= ISNULL((DPH.ValidTo),getdate()))
           ),0)
       if(@val1 >= @val2)
           set @maxval = @val1
       else
           set @maxval = @val2

       RETURN @maxval
   END
go

alter FUNCTION udfGetDiscountsFrom(@input int)
   RETURNS table AS
       RETURN
       SELECT customerid, [customer name], discountparamname, paramvalue, validfrom
       FROM individualCustomersDiscounts ICD
       WHERE ValidFrom >= DATEADD(day,-@input, GETDATE())
go

alter FUNCTION udfGetDishesByCategory(@cat varchar(50))
      RETURNS table AS
       RETURN
       SELECT dishid, dishname, categoryname from allDishes
        where CategoryName = (@cat)
go

alter FUNCTION udfGetDishesFrom(@input int)
   RETURNS table AS
       RETURN
       SELECT menupositionid, dishid, dishname, dishprice, indate, outdate
       FROM allMenuPositions MP
       WHERE MP.InDate >= DATEADD(day,-@input, GETDATE())
go

alter FUNCTION udfGetIndividualCustomerStatistics()
      RETURNS table AS
       RETURN
       SELECT CustomerID, Customer, [Company/Person], [Number of Orders], [Average Order Price]
       FROM CustomersStatistics CS
       WHERE CS.[Company/Person] = 'Person'
go

alter FUNCTION udfGetInvoiceByCustomerIDandMonth(@customerID int, @month int)
   RETURNS table AS
       RETURN
       select OrderID,
              CustomerID,
              MenuPositionID,
              DishPrice,
              Quantity,
              discount,
              [Order price],
              OrderDate,
              Year,
              Month
       from ordersInvoice OI
        where OI.CustomerID = @customerID and @month = Month
go

alter FUNCTION udfGetInvoiceByOrderID(@id int)
   RETURNS table AS
       RETURN
       select OrderID,
              CustomerID,
              MenuPositionID,
              DishPrice,
              Quantity,
              discount,
              [Order price],
              OrderDate,
              Year,
              Month
       from ordersInvoice OI
        where OI.OrderID = @id
go

alter FUNCTION udfGetMenuPositionsWithPrice(@price money)
      RETURNS table AS
       RETURN
       select menupositionid, dishid, dishname, dishprice, indate, outdate from allMenuPositions aMP
        where aMP.DishPrice = @price
go

alter FUNCTION udfGetMenuPositionsWithPriceHigherThan(@price money)
      RETURNS table AS
       RETURN
       select menupositionid, dishid, dishname, dishprice, indate, outdate from allMenuPositions aMP
        where aMP.DishPrice > @price
go

alter FUNCTION udfGetMenuPositionsWithPriceLowerThan(@price money)
      RETURNS table AS
       RETURN
       select menupositionid, dishid, dishname, dishprice, indate, outdate from allMenuPositions aMP
        where aMP.DishPrice < @price
go

alter FUNCTION udfGetOrderPrice(@order_id int)
RETURNS FLOAT AS
   BEGIN
       DECLARE @sum float;

       set @sum = (
           select [Order price]
           from CustomersOrders
           where OrderID = @order_id
           )

       RETURN @sum
   END
go

alter FUNCTION udfGetOrdersDone(@customer_id int)
RETURNS FLOAT AS
   BEGIN
       DECLARE @sum float;

       set @sum = (
           select [number of orders]
           from CustomersNumbersOfOrders
           where CustomerID = @customer_id
           )

       RETURN @sum
   END
go

alter FUNCTION udfGetOrdersInYear(@year int)
   RETURNS table AS
       RETURN
       SELECT ORDERID, CUSTOMERID, CUSTOMER, [ORDER PRICE], ORDERDATE, [COMPANY/PERSON], YEAR, MONTH
       FROM CustomersOrders CO
       WHERE CO.Year = @year
go

alter FUNCTION udfGetOrdersInYearAndMonth(@year int,@month int)
   RETURNS table AS
       RETURN
       SELECT ORDERID, CUSTOMERID, CUSTOMER, [ORDER PRICE], ORDERDATE, [COMPANY/PERSON], YEAR, MONTH
       FROM CustomersOrders CO
       WHERE CO.Year = @year and CO.Month = @month
go

alter FUNCTION udfGetReservationsFrom(@input int)
   RETURNS table AS
       RETURN
       SELECT R.ReservationID, CustomerID, ReservationStatusName, StartDate, Customer
       FROM allReservations R
       WHERE R.StartDate >= DATEADD(day,-@input, GETDATE())
go

alter FUNCTION udfGetReservationsInYear(@year int)
   RETURNS table AS
       RETURN
       SELECT R.ReservationID, CustomerID, ReservationStatusName, StartDate, Customer
       FROM allReservations R
       WHERE R.Year = @year
go

alter FUNCTION udfGetReservationsInYearAndMonth(@year int,@month int)
   RETURNS table AS
       RETURN
       SELECT R.ReservationID, CustomerID, ReservationStatusName, StartDate, Customer
       FROM allReservations R
       WHERE R.Year = @year and R.Month = @month
go

alter procedure uspCheckMenu
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN
            IF EXISTS(
                select * from MenuPositions
                WHERE DATEDIFF(day, InDate, GETDATE()) >= 14
                and(OutDate is null or OutDate > GETDATE())
                )
            BEGIN
                UPDATE MenuPositions
                SET OutDate = GETDATE()
                WHERE DATEDIFF(day, InDate, GETDATE()) >= 14
                and(OutDate is null or OutDate >= GETDATE())
            end
        END
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)
            =N'Błąd usuwania dań: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1
    END CATCH
END
go

alter PROCEDURE uspClearMenu
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN
            UPDATE MenuPositions
            SET OutDate = DATEADD(DAY, 1, GETDATE())
            WHERE OutDate is null
               or OutDate >= GETDATE()
        END
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)
            =N'Błąd usuwania dań: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1
    END CATCH
END
go

alter PROCEDURE uspCompleteReservation @ReservationID int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(
                SELECT *
                FROM Reservations
                WHERE ReservationID = @ReservationID
            )
            BEGIN
                ;
                THROW 52000, 'Nie ma takiej rezerwacji', 1
            END
        BEGIN
            UPDATE Reservations
            SET ReservationStatus = 4
            WHERE Reservations.ReservationID = @ReservationID
        end
    end try
    begin catch
        declare @msg nvarchar(2048) = 'Error: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1
    end catch
end
go

alter PROCEDURE uspConfirmReservation @ReservationID int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(
                SELECT *
                FROM Reservations
                WHERE ReservationID = @ReservationID
            )
            BEGIN
                ;
                THROW 52000, 'Nie ma takiej rezerwacji', 1
            END
        BEGIN
            UPDATE Reservations
            SET ReservationStatus = 1
            WHERE Reservations.ReservationID = @ReservationID
        end
    end try
    begin catch
        declare @msg nvarchar(2048) = 'Error: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1
    end catch
end
go

alter PROCEDURE uspDeclineReservation @ReservationID int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(
                SELECT *
                FROM Reservations
                WHERE ReservationID = @ReservationID
            )
            BEGIN
                ;
                THROW 52000, 'Nie ma takiej rezerwacji', 1
            END
        BEGIN
            UPDATE Reservations
            SET ReservationStatus = 2
            WHERE Reservations.ReservationID = @ReservationID
        END
    END TRY
    begin catch
        declare @msg nvarchar(2048) = 'Error: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1
    end catch
end
go

alter PROCEDURE uspFindTableToReservation @ReservationID int, @Quantity int, @TableID int,
                                           @ResIdTable ReservationsDetIDtoTableID READONLY
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS( SELECT * FROM Reservations
                WHERE ReservationID = @ReservationID )
            BEGIN;
                THROW 52000, N'Nie ma takiej rezerwacji', 1
            END

        DECLARE @StartDate datetime
        DECLARE @EndDate datetime
        SELECT @StartDate = StartDate
        FROM Reservations
        where ReservationID = @ReservationID
        SELECT @EndDate = EndDate
        FROM Reservations
        where ReservationID = @ReservationID

        IF EXISTS( SELECT * FROM TableReservations TR
                WHERE TR.TableID = @TableID
                  and (@StartDate between TR.TableReservationStart and TR.TableReservationEnd
                    or @EndDate between TR.TableReservationStart and TR.TableReservationEnd))
            BEGIN;
                THROW 52000, N'Stół niedostępny w danym terminie.', 1
            end

        DECLARE @TableQuantity int
        SELECT @TableQuantity = Quantity
        from Tables
        where TableID = @TableID
        IF (@Quantity > @TableQuantity)
            BEGIN;
                THROW 52000, N'Za mała ilość miejsc przy stole', 1
            end


        IF EXISTS( SELECT * FROM IndividualReservations
                WHERE ReservationID = @ReservationID )
            BEGIN
                DECLARE @CheckTableNull int
                SELECT @CheckTableNull = TableID FROM IndividualReservations
                WHERE ReservationID = @ReservationID
                IF ( @CheckTableNull is not null )
            BEGIN;
                THROW 52000, N'Rezerwacja ma przydzielony stolik', 1
            END
                UPDATE IndividualReservations
                SET TableID = @TableID
                WHERE ReservationID = @ReservationID
                EXEC uspInsertTableToTableRes @TableID, @StartDate, @EndDate
                --EXEC uspConfirmReservation @ReservationID
            END
        ELSE
            BEGIN
                DECLARE @RowCnt int
                SELECT @RowCnt = COUNT(0) FROM @ResIdTable;
                DECLARE @RowNumber int
                SET @RowNumber = 1
                WHILE @RowNumber <= @RowCnt
                    BEGIN
                        DECLARE @ResId int
                        SELECT @ResId = ResIdTable
                        from @ResIdTable
                        where TableResId = @RowNumber
                        update ReservationsDetails
                        set TableID = @TableID
                        where ReservationID = @ReservationID
                        and ReservationsDetailsID = @ResId
                        SET @RowNumber = @RowNumber + 1
                    END
                EXEC uspInsertTableToTableRes @TableID, @StartDate, @EndDate
                --EXEC uspConfirmReservation @ReservationID
            end
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)
            =N'error: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1
    END CATCH
END
go

alter PROCEDURE uspInsertCategory @categoryName varchar(50)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF EXISTS(
                SELECT *
                FROM Categories
                WHERE CategoryName = @categoryName
            )
            BEGIN
                ;
                THROW 52000, N'category already exist', 1
            END
        DECLARE @CategoryID INT
        SELECT @CategoryID = ISNULL(MAX(CategoryID), 0) + 1
        FROM Categories
        INSERT INTO Categories(CategoryID, CategoryName)
        VALUES (@CategoryID, @categoryName);
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)
            =N'error: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1;
    END CATCH
end
go

alter PROCEDURE [dbo].[uspInsertCity] @cityName nvarchar(50), @CountryID int
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @CityID INT
        SELECT @CityID = ISNULL(MAX(CityID), 0) + 1 from Cities
        INSERT INTO Cities(CityID, CityName, CountryID)
        VALUES (@CityID, @cityName, @CountryID)
    END TRY
    BEGIN CATCH
        DECLARE @msg NVARCHAR(2048) =
        'Bład przy dodawaniu miasta:' + CHAR(13) + CHAR(10) +
ERROR_MESSAGE();
        THROW 52000,@msg, 1;
    END CATCH
END
go

alter PROCEDURE [dbo].[uspInsertCompany] @companyName nvarchar(50), @NIP nvarchar(50), @CityID int
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @CustomerID INT
        SELECT @CustomerID = ISNULL(MAX(CustomerID), 0) + 1 from Customers
        INSERT INTO Customers(CustomerID, CityID)
        VALUES (@CustomerID, @CityID)
        INSERT INTO Company(CustomerID, CompanyName, NIP)
        VALUES (@CustomerID, @companyName, @NIP)
    SET @CustomerID = @@IDENTITY
    END TRY
    BEGIN CATCH
        DECLARE @msg NVARCHAR(2048) =
        'Bład przy dodawaniu firmy:' + CHAR(13) + CHAR(10) +
ERROR_MESSAGE();
        THROW 52000,@msg, 1;
    END CATCH
END
go

alter PROCEDURE [dbo].[uspInsertCountry] @countryName nvarchar(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @CountryID INT
        SELECT @CountryID = ISNULL(MAX(CountryID), 0) + 1 from Countries
        INSERT INTO Countries(CountryID, CountryName)
        VALUES (@CountryID, @countryName)
    SET @CountryID = @@IDENTITY
    END TRY
    BEGIN CATCH
        DECLARE @msg NVARCHAR(2048) =
        'Bład przy dodawaniu państwa:' + CHAR(13) + CHAR(10) +
ERROR_MESSAGE();
        THROW 52000,@msg, 1;
    END CATCH
END
go

alter PROCEDURE uspInsertDish @dishName varchar(50), @catName varchar(50), @dishPrice money
AS
BEGIN
    SET NOCOUNT ON
   BEGIN TRY
       IF EXISTS(
               SELECT *
               FROM Dishes
               WHERE DishName = @dishName
           )
           BEGIN
               ;
               THROW 52000, N'dish already exist', 1
           END
       IF NOT EXISTS(
               SELECT *
               FROM Categories
               WHERE CategoryName = @catName
           )
           BEGIN
               ;
               THROW 52000, 'no such category', 1
           END
       DECLARE @CategoryID INT
       SELECT @CategoryID = CategoryID
       FROM Categories
       WHERE CategoryName = @catName
       DECLARE @ProductID INT
       SELECT @ProductID = ISNULL(MAX(DishID), 0) + 1
       FROM Dishes
       INSERT INTO Dishes(DishID, DishName, CategoryID, DishPrice)
       VALUES (@ProductID, @dishName, @CategoryID, @dishPrice);
   END TRY
   BEGIN CATCH
       DECLARE @msg nvarchar(2048)
           =N'error: ' + ERROR_MESSAGE();
       THROW 52000, @msg, 1;
   END CATCH
end
go

alter PROCEDURE [dbo].[uspInsertEmployee] @firstname nvarchar(50), @lastname nvarchar(50), @phone nvarchar(50), @reportsto int
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @EmployeeID INT
        SELECT @EmployeeID = ISNULL(MAX(EmployeeID), 0) + 1 from Employees
        DECLARE @PersonID INT
        SELECT @PersonID = ISNULL(MAX(PersonID), 0) + 1 from Person
        EXEC uspInsertPerson @firstname, @lastname, @phone, @PersonID
        INSERT INTO Employees(EmployeeID, PersonID, ReportsTo)
        VALUES (@EmployeeID, @PersonID, @reportsto)
    SET @EmployeeID = @@IDENTITY
    END TRY
    BEGIN CATCH
        DECLARE @msg NVARCHAR(2048) =
        'Bład przy dodawaniu pracownika:' + CHAR(13) + CHAR(10) +
ERROR_MESSAGE();
        THROW 52000,@msg, 1;
    END CATCH
END
go

alter PROCEDURE [dbo].[uspInsertIndividualCustomer] @firstname nvarchar(50), @lastname nvarchar(50), @phone nvarchar(50), @CityID int
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @CustomerID INT
        SELECT @CustomerID = ISNULL(MAX(CustomerID), 0) + 1 from Customers
        DECLARE @PersonID INT
        SELECT @PersonID = ISNULL(MAX(PersonID), 0) + 1 from Person
        EXEC uspInsertPerson @firstname, @lastname, @phone, @PersonID
		INSERT INTO Customers(CustomerID, CityID)
        VALUES (@CustomerID, @CityID)
        INSERT INTO IndividualCustomers(CustomerID, PersonID)
        VALUES (@CustomerID, @PersonID)

    SET @CustomerID = @@IDENTITY
    END TRY
    BEGIN CATCH
        DECLARE @msg NVARCHAR(2048) =
        'Bład przy dodawaniu klienta indywidualnego:' + CHAR(13) + CHAR(10) +
ERROR_MESSAGE();
        THROW 52000,@msg, 1;
    END CATCH
END
go

alter PROCEDURE uspInsertMenuPosition @DishID int, @OutDate datetime
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(
                SELECT *
                FROM Dishes
                WHERE DishID = @DishID
            )
            BEGIN
                ;
                THROW 52000, 'Nie ma takiej potrawy', 1
            END
        DECLARE @DishPrice money
        SELECT @DishPrice = DishPrice
        FROM Dishes
        WHERE DishID = @DishID
        DECLARE @MenuPosID int
        SELECT @MenuPosID = ISNULL(MAX(MenuPositionID), 0) + 1
        from MenuPositions
        IF EXISTS(
                SELECT *
                FROM MenuPositions
                WHERE DishID = @DishID
                  and (OutDate is null or OutDate > GETDATE())
            )
            BEGIN
                ;
                THROW 52000, 'Taka potrawa jest już w Menu', 1
            END
        INSERT INTO MenuPositions(MenuPositionID, DishID, DishPrice, InDate, OutDate)
        VALUES (@MenuPosID, @DishID, @DishPrice, GETDATE(), @OutDate);
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)
            =N'Błąd dodania potrawy do menu: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1
    END CATCH
END
go

alter PROCEDURE uspInsertOrder @EmployeeID int,
                                @CustomerID int,
                                @OutDate datetime,
                                @PaidDate datetime,
                                @TakeawayStatus int,
                                @PaymentStatus int,
                                @OrderedFood OrderedFood READONLY
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF EXISTS(SELECT *
                FROM @OrderedFood O
                         inner join MenuPositions M on O.MenuPositionID = M.MenuPositionID
                         inner join Dishes D on M.DishID = D.DishID
                where D.CategoryID = 10)
        BEGIN
        IF NOT EXISTS(
                SELECT *
                FROM @OrderedFood O
                         inner join MenuPositions M on O.MenuPositionID = M.MenuPositionID
                         inner join Dishes D on M.DishID = D.DishID
                where D.CategoryID = 10
                  and (DATENAME(WEEKDAY, @OutDate) = 'Thursday' or DATENAME(WEEKDAY, @OutDate) = 'Friday' or
                       DATENAME(WEEKDAY, @OutDate) = 'Saturday')
                  and ((3 <= DATEDIFF(day, GETDATE(), @OutDate) and
                        DATEDIFF(day, GETDATE(), @OutDate) <= 5 and
                        DATENAME(WEEKDAY, GETDATE()) != 'Tuesday' and
                        DATENAME(WEEKDAY, GETDATE()) != 'Wednesday') or (DATEDIFF(day, GETDATE(), @OutDate) > 5))
            )
            BEGIN
                ;
                THROW 52000, N'Zamówienie złożone za późno', 1
            END
        END
        DECLARE @OrderID INT
        SELECT @OrderID = ISNULL(MAX(OrderID), 0) + 1
        FROM Orders
        INSERT INTO Orders(OrderID, EmployeeID, CustomerID, OrderDate, OutDate, PaidDate, TakeawayStatus, PaymentStatus)
        VALUES (@OrderID, @EmployeeID, @CustomerID, GETDATE(), @OutDate, @PaidDate, @TakeawayStatus, @PaymentStatus)

        DECLARE @RowCnt int
        SELECT @RowCnt = COUNT(0) FROM @OrderedFood;
        DECLARE @RowNumber int
        SET @RowNumber = 1

        WHILE @RowNumber <= @RowCnt
            BEGIN
                DECLARE @MenuPosID int
                SELECT @MenuPosID = MenuPositionID
                from @OrderedFood
                WHERE OrderedFoodID = @RowNumber
                DECLARE @Quant int
                SELECT @Quant = Quantity
                from @OrderedFood
                WHERE OrderedFoodID = @RowNumber
                EXEC uspInsertOrderDetailsToOrder @OrderID, @MenuPosID, @Quant
                SET @RowNumber = @RowNumber + 1
            END
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)
            =N'Błąd dodawania zamówienia: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1
    END CATCH
END
go

alter PROCEDURE uspInsertOrderDetailsToOrder @OrderID int,
                                              @MenuPositionID int,
                                              @Quantity int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(
                SELECT *
                FROM MenuPositions
                WHERE MenuPositionID = @MenuPositionID
            )
            BEGIN
                ;
                THROW 52000, 'Nie ma takiej potrawy', 1
            END
        IF NOT EXISTS(
                SELECT *
                FROM Orders
                WHERE OrderID = @OrderID
            )
            BEGIN
                ;
                THROW 52000, 'Nie ma takiego zamowienia', 1
            END

            DECLARE @DishID INT
            SELECT @DishID = DishID
            FROM MenuPositions
            WHERE MenuPositionID = @MenuPositionID
            INSERT INTO OrderDetails(OrderID, DishID, MenuPositionID, Quantity)
            VALUES (@OrderID, @DishID, @MenuPositionID, @Quantity)
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048)
                =N'Błąd dodawania szczegółów zamówienia: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
END
go

alter PROCEDURE uspInsertPerson @firstname nvarchar(50), @lastname nvarchar(50), @phone nvarchar(50), @PersonID int
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF (
            len(@phone) != 9
            )
            BEGIN
                ;
                THROW 52000, 'Zła długość numeru telefonu', 1
            END
        INSERT INTO Person(PersonID, LastName, FirstName, Phone)
        VALUES (@PersonID, @lastname, @firstname, @phone);
        SET @PersonID = @@IDENTITY
    END TRY
    BEGIN CATCH
        DECLARE @msg NVARCHAR(2048) = 'Bład przy dodawaniu osoby:' +
                                      CHAR(13) + CHAR(10) + ERROR_MESSAGE();
        THROW 52000,@msg, 1;
    END CATCH
END
go

alter PROCEDURE uspInsertPersonToTable @TableID int,
                                        @ResDetID int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(
                SELECT *
                FROM ReservationsDetails
                WHERE ReservationsDetailsID = @ResDetID
            )
            BEGIN
                ;
                THROW 52000, 'Nie ma takiej rezerwacji', 1
            END
        IF NOT EXISTS(
                SELECT *
                FROM Tables
                WHERE TableID = @TableID
            )
            BEGIN
                ;
                THROW 52000, 'Nie ma takiego stolika', 1
            END
        BEGIN
            update ReservationsDetails
            set TableID = @TableID
            where ReservationsDetailsID = @ResDetID
        end
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)
            =N'error: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1
    END CATCH
END
go

alter PROCEDURE uspInsertReservation @EmployeeID int,
                                      @CustomerID int,
                                      @StartDate datetime,
                                      @EndDate datetime,
                                      @numberOfPeople int,
                                      @People People READONLY,
                                      @OrderedFood OrderedFood READONLY
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(
                SELECT *
                FROM Customers
                WHERE CustomerID = @CustomerID
            )
            BEGIN
                ;
                THROW 52000, 'Nie ma takiego klienta', 1
            end

        DECLARE @peopleCond int
        SELECT @peopleCond = ConditionValue
        from ReservationsConditions
        WHERE ReservationConditionID = 1
        IF (@numberOfPeople < @peopleCond)
            BEGIN
                ;
                THROW 52000, 'Za malo osob', 1
            end

        DECLARE @ReservationID INT
        SELECT @ReservationID = ISNULL(MAX(ReservationID), 0) + 1
        FROM Reservations

        DECLARE @OrderID INT
        SELECT @OrderID = ISNULL(MAX(OrderID), 0) + 1
        FROM Orders

        IF EXISTS(
                SELECT *
                FROM IndividualCustomers

                WHERE CustomerID = @CustomerID
            )
            BEGIN
                ;

                DECLARE @OrdersDone int
                SET @OrdersDone = dbo.udfGetOrdersDone(@CustomerID)
                DECLARE @conditionOrdersDone int
                select @conditionOrdersDone = ConditionValue
                from ReservationsConditions
                where ReservationConditionID = 3

                IF (@conditionOrdersDone > @OrdersDone)
                    BEGIN
                        ;
                        THROW 52000, 'Za malo zlozonych zamowien', 1
                    END

                IF EXISTS(SELECT *
                          FROM @OrderedFood O
                                   inner join MenuPositions M on O.MenuPositionID = M.MenuPositionID
                                   inner join Dishes D on M.DishID = D.DishID
                          where D.CategoryID = 10)
                    BEGIN
                        IF NOT EXISTS(
                                SELECT *
                                FROM @OrderedFood O
                                         inner join MenuPositions M on O.MenuPositionID = M.MenuPositionID
                                         inner join Dishes D on M.DishID = D.DishID
                                where D.CategoryID = 10
                                  and (DATENAME(WEEKDAY, @StartDate) = 'Thursday' or
                                       DATENAME(WEEKDAY, @StartDate) = 'Friday' or
                                       DATENAME(WEEKDAY, @StartDate) = 'Saturday')
                                  and ((3 <= DATEDIFF(day, GETDATE(), @StartDate) and
                                        DATEDIFF(day, GETDATE(), @StartDate) < 5 and
                                        DATENAME(WEEKDAY, @StartDate) != 'Tuesday' and
                                        DATENAME(WEEKDAY, @StartDate) != 'Wednesday') or
                                       (DATEDIFF(day, GETDATE(), @StartDate) >= 5))
                            )
                            BEGIN
                                ;
                                THROW 52000, N'Rezerwacja złożona za późno', 1
                            END
                    END
                DECLARE @Disc1 float
                SELECT @Disc1 = isnull(DiscountValue, 0)
                from ConstantDiscount
                WHERE CustomerID = @CustomerID
                  and ValidFrom <= GETDATE()
                DECLARE @Disc2 float
                SELECT @Disc2 = isnull(ParamValue, 0)
                from DiscountParamsHist DPH
                         inner join SingleDiscountParams SDP on DPH.DiscountHistID = SDP.DiscountHistID
                         inner join SingleDiscount SD on SDP.DiscountID = SD.DiscountID
                WHERE CustomerID = @CustomerID
                DECLARE @Disc float
                SET @Disc1 = isnull(@Disc1, 0)
                SET @Disc2 = isnull(@Disc2, 0)

                if (@Disc1 >= @Disc2)
                    set @Disc = @Disc1
                else
                    set @Disc = @Disc2

                DECLARE @RowC int
                SELECT @RowC = COUNT(0) FROM @OrderedFood;
                DECLARE @RowN int
                SET @RowN = 1
                DECLARE @Sum money
                SET @Sum = 0

                WHILE @RowN <= @RowC
                    BEGIN
                        DECLARE @MenuPosID int
                        SELECT @MenuPosID = MenuPositionID
                        from @OrderedFood
                        WHERE OrderedFoodID = @RowN

                        DECLARE @Price money
                        SELECT @Price = DishPrice
                        FROM MenuPositions
                        WHERE MenuPositionID = @MenuPosID

                        DECLARE @Quant int
                        SELECT @Quant = Quantity
                        from @OrderedFood
                        WHERE OrderedFoodID = @RowN
                        SET @Sum = @Sum + isnull(@Price * (1 - @Disc) * @Quant, 0)
                        SET @RowN = @RowN + 1
                    END

                DECLARE @MinPrice money
                SELECT @MinPrice = ConditionValue
                FROM ReservationsConditions
                WHERE ReservationConditionID = 2

                IF (@MinPrice > @Sum)
                    BEGIN
                        ;
                        THROW 52000, N'Za mała wartość zamówienia', 1
                    END


                INSERT INTO Reservations(ReservationID, CustomerID, StartDate, EndDate, ReservationDate,
                                         ReservationStatus)
                VALUES (@ReservationID, @CustomerID, @StartDate, @EndDate, GETDATE(), 3)
                EXEC uspInsertOrder @EmployeeID, @CustomerID, @StartDate, null, 2, 2, @OrderedFood
                INSERT INTO IndividualReservations(ReservationID, CustomerID, OrderID, numberOfPeople, TableID)
                VALUES (@ReservationID, @CustomerID, @OrderID, @numberOfPeople, null)

            end
        ELSE
            BEGIN
                INSERT INTO Reservations(ReservationID, CustomerID, StartDate, EndDate, ReservationDate,
                                         ReservationStatus)
                VALUES (@ReservationID, @CustomerID, @StartDate, @EndDate, GETDATE(), 3)
                INSERT INTO CompanyReservations(ReservationID, CustomerID, numberOfPeople)
                VALUES (@ReservationID, @CustomerID, @numberOfPeople)

                DECLARE @RowCnt int
                SELECT @RowCnt = COUNT(0) FROM @People;
                DECLARE @RowNumber int
                SET @RowNumber = 1
                WHILE @RowNumber <= @RowCnt
                    BEGIN
                        DECLARE @firstname nvarchar(50)
                        SELECT @firstName = firstName
                        from @People
                        where PeopleID = @RowNumber
                        DECLARE @lastname nvarchar(50)
                        SELECT @lastName = lastName
                        from @People
                        where PeopleID = @RowNumber
                        INSERT INTO ReservationsDetails(ReservationID, TableID, LastName, FirstName)
                        VALUES (@ReservationID, null, @lastname, @firstname)
                        SET @RowNumber = @RowNumber + 1
                    END
            end
    END TRY
    BEGIN CATCH
        DECLARE @errorMsg nvarchar(2048)
            =N'Błąd dodania rezerwacji: ' + ERROR_MESSAGE();
        THROW 52000, @errorMsg, 1
    END CATCH
END
go

alter PROCEDURE uspInsertTable @Quantity int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF (
            @Quantity <= 1
            )
            BEGIN
                ;
                THROW 52000, 'Za mała ilość miejsc', 1
            END
        DECLARE @TableID INT
        SELECT @TableID = ISNULL(MAX(TableID), 0) + 1
        FROM Tables
        INSERT INTO Tables(TableID, Quantity)
        VALUES (@TableID, @Quantity);
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)
            =N'Błąd dodawania stolika: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1
    END CATCH
END
go

alter procedure uspInsertTableToTableRes @TableID int, @StartDate datetime, @EndDate datetime
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        DECLARE @TableReservationID int
        SELECT @TableReservationID = ISNULL(MAX(TableReservationID), 0) + 1
        FROM TableReservations
        INSERT INTO TableReservations(TableReservationID, TableID, TableReservationStart, TableReservationEnd)
        VALUES (@TableReservationID, @TableID, @StartDate, @EndDate);
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)
            =N'Błąd dodawania stolika do historii rezerwacji: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1
    END CATCH
END
go

alter PROCEDURE uspRemoveCategory @categoryName varchar(50)
AS
BEGIN
    SET NOCOUNT ON
   BEGIN TRY
       IF NOT EXISTS(
               SELECT *
               FROM Categories
               WHERE CategoryName = @categoryName
           )
           BEGIN
               ;
               THROW 52000, N'category doesnt exist', 1
           END
       DECLARE @CatId int
       SELECT @CatId = CategoryID from Categories
       where CategoryName = @categoryName
       IF EXISTS(
               SELECT *
               FROM Dishes
               WHERE CategoryID = @CatId
           )
           BEGIN
               ;
               THROW 52000, N'Kategoria posiada przypisane dania.', 1
           END
       DELETE FROM Categories
       WHERE CategoryName = @categoryName
   END TRY
   BEGIN CATCH
       DECLARE @msg nvarchar(2048)
           =N'error: ' + ERROR_MESSAGE();
       THROW 52000, @msg, 1;
   END CATCH
end
go

alter PROCEDURE uspRemoveCity @CityID int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(
                SELECT *
                FROM Cities
                WHERE CityID = @CityID
            )
            BEGIN
                ;
                THROW 52000, N'City doesnt exist', 1
            END
        IF EXISTS(
               SELECT *
               FROM Customers
               WHERE CityID = @CityID
           )
           BEGIN
               ;
               THROW 52000, N'Miasto w użyciu', 1
           END
        DELETE FROM Cities
        WHERE CityID = @CityID
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)
            =N'error: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1;
    END CATCH
end
go

alter PROCEDURE uspRemoveCompany @CustomerID int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(
                SELECT *
                FROM Company
                WHERE @CustomerID = CustomerID
            )
            BEGIN
                ;
                THROW 52000, N'Company doesnt exist', 1
            END
        IF EXISTS(
               SELECT *
               FROM CompanyReservations
               WHERE CustomerID = @CustomerID
           )
           BEGIN
               ;
               THROW 52000, N'Firma posiada historię rezerwacji', 1
           END
        DELETE FROM Company
        WHERE @CustomerID = CustomerID
        EXEC uspRemoveCustomer @CustomerID
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)
            =N'error: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1;
    END CATCH
end
go

alter PROCEDURE uspRemoveCountry @CountryID int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(
                SELECT *
                FROM Countries
                WHERE CountryID = @CountryID
            )
            BEGIN
                ;
                THROW 52000, N'Country doesnt exist', 1
            END

        DELETE from Cities
        where CountryID = @CountryID
        DELETE FROM Countries
        WHERE CountryID = @CountryID
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)
            =N'error: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1;
    END CATCH
end
go

alter PROCEDURE uspRemoveCustomer @CustomerID int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(
                SELECT *
                FROM Customers
                WHERE @CustomerID = CustomerID
            )
            BEGIN
                ;
                THROW 52000, N'Customer doesnt exist', 1
            END
        DELETE FROM Customers
        WHERE @CustomerID = CustomerID
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)
            =N'error: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1;
    END CATCH
end
go

alter PROCEDURE uspRemoveDish @dishName varchar(50)
AS
BEGIN
    SET NOCOUNT ON
   BEGIN TRY
       IF NOT EXISTS(
               SELECT *
               FROM Dishes
               WHERE DishName = @dishName
           )
           BEGIN
               ;
               THROW 52000, N'dish doesnt exist', 1
           END
       DECLARE @DisID int
       select @DisID = DishID from Dishes
       where DishName = @dishName

       IF EXISTS(
               SELECT *
               FROM MenuPositions
               WHERE DishID = @DisID
           )
           BEGIN
               ;
               THROW 52000, N'Danie w użyciu', 1
           END
       DELETE FROM Dishes
       WHERE DishName = @dishName
   END TRY
   BEGIN CATCH
       DECLARE @msg nvarchar(2048)
           =N'error: ' + ERROR_MESSAGE();
       THROW 52000, @msg, 1;
   END CATCH
end
go

alter PROCEDURE uspRemoveEmployee @EmployeeID int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(
                SELECT *
                FROM Employees
                WHERE EmployeeID = @EmployeeID
            )
            BEGIN
                ;
                THROW 52000, N'Employee doesnt exist', 1
            END
        IF EXISTS(
               SELECT *
               FROM Orders
               WHERE EmployeeID = @EmployeeID
           )
           BEGIN
               ;
               THROW 52000, N'Pracownik posiada historię zamówień', 1
           END
        DECLARE @PersonID int
        SET @PersonID = (SELECT PersonID
                FROM Employees
                WHERE EmployeeID = @EmployeeID
            )
        DELETE FROM Employees
        WHERE EmployeeID = @EmployeeID
        EXEC uspRemovePerson @PersonID
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)
            =N'error: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1;
    END CATCH
end
go

alter PROCEDURE uspRemoveIndividualCustomer @CustomerID int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(
                SELECT *
                FROM IndividualCustomers
                WHERE @CustomerID = CustomerID
            )
            BEGIN
                ;
                THROW 52000, N'Individual customer doesnt exist', 1
            END
        IF EXISTS(
               SELECT *
               FROM IndividualReservations
               WHERE CustomerID = @CustomerID
           )
           BEGIN
               ;
               THROW 52000, N'Użytkownik posiada historię rezerwacji', 1
           END
        DECLARE @PersonID int
        SET @PersonID = (SELECT PersonID
                FROM IndividualCustomers
                WHERE @CustomerID = CustomerID)
        DELETE FROM IndividualCustomers
        WHERE @CustomerID = CustomerID
        EXEC uspRemovePerson @PersonID
        EXEC uspRemoveCustomer @CustomerID
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)
            =N'error: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1;
    END CATCH
end
go

alter PROCEDURE uspRemovePerson  @PersonID int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(
                SELECT *
                FROM Person
                WHERE @PersonID = PersonID
            )
            BEGIN
                ;
                THROW 52000, N'Person doesnt exist', 1
            END
        DELETE FROM Person
        WHERE @PersonID = PersonID
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)
            =N'error: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1;
    END CATCH
end
go

alter PROCEDURE uspUpdateTable @TableID int,
                                @Quantity int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(
                SELECT *
                FROM Tables
                WHERE TableID = @TableID
            )
            BEGIN
                ;
                THROW 52000, 'Nie ma takiego stolika.', 1
            END
        IF @Quantity < 2
            BEGIN
                ;
                THROW 52000, N'Za mało miejsc.', 1
            END
        IF @Quantity IS NOT NULL
            BEGIN
                UPDATE Tables
                SET Quantity = @Quantity
                WHERE TableID = @TableID
            END
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)
            =N'Błąd edytowania stolika: ' +
             ERROR_MESSAGE();
        THROW 52000, @msg, 1
    END CATCH
END
go
