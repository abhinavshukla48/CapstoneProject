-- creating virtual table

create view OrdersView AS select OrderID, Quantity, TotalCost from Orders WHERE Quantity > 2;

-- using joins

select customers.CustomerID, customers.Name, orders.OrderID, orders.TotalCost AS Cost, menus.Name, menuitems.Course, menuitems.Starters, menuitems.Desserts from orders INNER JOIN customers using (CustomerID) INNER JOIN menus USING (MenusID) INNER JOIN menuitems USING (menuitemsID) WHERE Cost>150 order by COST ASC;

-- subqueries

select Name from Menus WHERE MenuID = ANY(select MenuID from orders WHERE Quantity > 2);

-- procedure for getting max quantity

create PROCEDURE GetMaxQuantity() select max(Quantity) from orders;
call GetMaxQuantity();

-- prepare statement

prepare GetOrderDetail from 'select OrderID, Quantity, TotalCost AS Cost from orders WHERE CustomerID = ?';
set @customer_id = 1;
execute GetOrderDetail using @customer_id;
create procedure CancelOrder(orderid int) delete from orders where OrderID = orderid;
call CancelOrder(5);

-- Example data to insert into the Bookings table

INSERT INTO bookings (BookingID, Date, TableNumber, CustomerID) VALUES
(1, '2022-10-10', 5, 1),
(2, '2022-11-12', 3, 3),
(3, '2022-10-11', 1, 2),
(4, '2022-10-28', 13, 1);

-- renaming column

ALTER TABLE bookings
CHANGE COLUMN Date BookingDate DATE;

-- changing delimiter

DELIMITER // 

-- stored procedure for checking that the table is already booked or not

create procedure CheckBooking(in bookingdate date, in tableno int)
begin
declare isbooked int;
select COUNT(TableNumber) INTO isbooked WHERE BookingDate = bookingdate AND TableNumber = tableno;
if isbooked > 0 THEN select "'Table is already booked on the specified date.' AS Status;";
else SELECT 'Table is available on the specified date.' AS Status;
END if;
END //
DELIMITER ;
call CheckBooking("2022-11-12", 3);

-- changing delimiter

DELIMITER //

-- procedure to insert in booking if there no booking on table using transaction

CREATE PROCEDURE AddValidBooking(IN bookingDate DATE, IN tableNumber INT)
BEGIN
    declare isBooked int;
    START transaction;
    INSERT INTO Bookings (BookingID, TableNumber, CostomerID) VALUES(bookingDate, tableNumber, CustomerID);
    select COUNT(TableNumber) INTO isBooked from Bookings WHERE BookingDate = bookingDate AND TableNumber = tableNumber;
    if isbooked>1 THEN rollback;
	   SELECT tableNumber, 'Booking declined. The table is already booked on the given date.' AS Status;
    else commit;
       select 'Booking success' AS Status;
    END if;
END //
DELIMITER ;
call AddValidBooking("2022-12-17", 6);

-- inserting booking

create procedure AddBooking(in bookingid int, in customerid int, in bookingdate date, in tablenumber int)
insert into bookings (BookingID, CustomerID, BookingDate, TableNumber) VALUES (bookingid, customerid, bookingdate, tablenumber);
call AddBooking(9, 3, "2022-12-30", 4);
 
-- procedure for update booking

 create procedure UpdateBooking(in bookingid int, bookingdate int)
 update bookings set BookingDate = bookingdate where BookingID = bookingid;
 call UpdateBooking(9, "2022-12-17");

-- procedure for deleting records when someone calcel booking

 create procedure CancelBooking(in bookingid int) delete from bookings WHERE BookingID = bookingid;
 call CancelBooking(9);
