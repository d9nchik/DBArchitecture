-- 1. Створити збережену процедуру, що при виклику буде повертати ваше прізвище, ім’я та по-батькові.
CREATE FUNCTION my_credentials(out Name text, out Surname text, out Patronymic text)
AS
$$
SELECT 'Danylo' AS Name, 'Halaiko' AS Surname, 'Oleksandrovich' AS Patronymic;
$$
    LANGUAGE sql;
-- Procedures doesn't return a value, so we should use function
-- https://stackoverflow.com/questions/50894269/how-to-return-result-set-from-postgresql-stored-procedure

-- 2. В контексті бази Northwind створити збережену процедуру, що приймає текстовий параметр мінімальної довжини.
-- У разі виклику процедури з параметром ‘F’ на екран виводяться усі співробітники-жінки,
-- у разі використання параметру ‘M’ – чоловікі. У протилежному випадку вивести на екран повідомлення про те,
-- що параметр не розпізнано.

CREATE OR REPLACE FUNCTION get_by_sex(in sex char(1))
    returns TABLE
            (
                "EmployeeID"      smallint,

                "LastName"        varchar(20),
                "FirstName"       varchar(10),
                "Title"           varchar(30),
                "TitleOfCourtesy" varchar(25),
                "BirthDate"       date,
                "HireDate"        date,
                "Address"         varchar(60),
                "City"            varchar(15),
                "Region"          varchar(15),
                "PostalCode"      varchar(10),
                "Country"         varchar(15),
                "HomePhone"       varchar(24),
                "Extension"       varchar(4),
                "Photo"           bytea,
                "Notes"           text,
                "ReportsTo"       smallint,
                "PhotoPath"       varchar(255)
            )
    LANGUAGE plpgsql
AS
$$
begin
    if sex LIKE 'F' THEN
        return query (SELECT *
                      FROM employees
                      WHERE employees."TitleOfCourtesy" LIKE 'Ms.'
                         or employees."TitleOfCourtesy" LIKE 'Mrs.');
    elsif sex LIKE 'M' THEN
        return query (SELECT *
                      FROM employees
                      WHERE employees."TitleOfCourtesy" LIKE 'Mr.'
                         or employees."TitleOfCourtesy" LIKE 'Dr.');
    else
        return query SELECT 'Error';
    end if;
end;
$$;

-- 3. В контексті бази Northwind створити збережену процедуру, що виводить усі замовлення за заданий період.
-- В тому разі, якщо період не задано – вивести замовлення за поточний день.
CREATE OR REPLACE FUNCTION get_current_orders(in d1 date, in d2 date)
    RETURNS TABLE
            (
                "OrderID"        smallint,
                "CustomerID"     bpchar,
                "EmployeeID"     smallint,
                "OrderDate"      date,
                "RequiredDate"   date,
                "ShippedDate"    date,
                "ShipVia"        smallint,
                "Freight"        real,
                "ShipName"       varchar(40),
                "ShipAddress"    varchar(60),
                "ShipCity"       varchar(15),
                "ShipRegion"     varchar(15),
                "ShipPostalCode" varchar(10),
                "ShipCountry"    varchar(15)
            )
    LANGUAGE plpgsql
AS
$$
begin
    if d1 is not null and d2 is not null THEN
        return query SELECT * FROM Orders WHERE orders."OrderDate" BETWEEN d1 and d2;
    else
        return query SELECT * FROM Orders WHERE orders."OrderDate" = CURRENT_DATE;
    end if;
end;
$$;

-- 4. В контексті бази Northwind створити збережену процедуру,
-- що в залежності від переданого параметру категорії виводить категорію та перелік усіх продуктів за цією категорією.
-- Дозволити можливість використати від однієї до п’яти категорій.
CREATE FUNCTION get_products(VARIADIC arr text[])
    RETURNS TABLE
            (
                "ProductName"  varchar(40),
                "UnitPrice"    real,
                "CategoryName" varchar(15)
            )
AS
$$
BEGIN
    RETURN QUERY SELECT products."ProductName", products."UnitPrice", categories."CategoryName"
                 FROM products
                          JOIN categories USING ("CategoryID")
                 WHERE categories."CategoryName" IS NOT NULL AND categories."CategoryName" = arr[0]
                    OR categories."CategoryName" = arr[1]
                    OR categories."CategoryName" = arr[2]
                    OR categories."CategoryName" = arr[3]
                    OR categories."CategoryName" = arr[4];
    RETURN;
END
$$
    LANGUAGE plpgsql;
-- 5. В контексті бази Northwind модифікувати збережену процедуру Ten Most Expensive Products
-- для виводу всієї інформації з таблиці продуктів, а також імен постачальників та назви категорій.
-- Дана ф-ція не існує в таблиці бд postgresql
CREATE OR REPLACE FUNCTION ten_most_expensive_products()
    RETURNS TABLE
            (
                "ProductID"       smallint,
                "ProductName"     varchar(40),
                "SupplierID"      smallint,
                "CategoryID"      smallint,
                "QuantityPerUnit" varchar(20),
                "UnitPrice"       real,
                "UnitsInStock"    smallint,
                "UnitsOnOrder"    smallint,
                "ReorderLevel"    smallint,
                "Discontinued"    integer,
                "CompanyName"     varchar(40),
                "CategoryName"    varchar(15)
            )
    LANGUAGE plpgsql
AS
$$
begin
    return query SELECT products.*,
                        suppliers."CompanyName"   AS "CompanyName",
                        categories."CategoryName" AS "CategoryName"
                 FROM products
                          JOIN suppliers ON suppliers."SupplierID" = products."SupplierID"
                          JOIN categories ON categories."CategoryID" = products."CategoryID"
                 ORDER BY "UnitPrice" DESC
                 LIMIT 10;
end;
$$;

-- 6. В контексті бази Northwind створити функцію, що приймає три параметри (TitleOfCourtesy, FirstName, LastName)
--     та виводить їх єдиним текстом.
-- Приклад: ‘Dr.’, ‘Yevhen’, ‘Nedashkivskyi’ –> ‘Dr. Yevhen Nedashkivskyi’
CREATE OR REPLACE FUNCTION generate_full_person_name("TitleOfCourtesy" text, "FirstName" text, "LastName" text) RETURNS text
    LANGUAGE plpgsql AS
$$
BEGIN
    RETURN CONCAT("TitleOfCourtesy", ' ', "FirstName", ' ', "LastName");
END
$$;
SELECT generate_full_person_name('Dr.', 'Yevhen', 'Nedashkivskyi');

-- 7. В контексті бази Northwind створити функцію, що приймає три параметри (UnitPrice, Quantity, Discount)
-- та виводить кінцеву ціну.
CREATE OR REPLACE FUNCTION get_total_price("UnitPrice" FLOAT, "Quantity" INT, "Discount" FLOAT) RETURNS FLOAT
    LANGUAGE plpgsql AS
$$
BEGIN
    RETURN ("UnitPrice" * "Quantity" * (1 - "Discount"));
END
$$;

-- 8. Створити функцію, що приймає параметр текстового типу і приводить його до Pascal Case.
-- Приклад: Мій маленький поні –> МійМаленькийПоні
CREATE FUNCTION to_pascal_case(Text text) returns text
    LANGUAGE plpgsql AS
$$
BEGIN
    RETURN replace(initcap(Text), ' ', '');
END;
$$;
SELECT to_pascal_case('Мій маленький поні');
-- 9. В контексті бази Northwind створити функцію, що в залежності від вказаної країни
-- повертає усі дані про співробітника у вигляді таблиці.
CREATE OR REPLACE FUNCTION get_country_worker(country text)
    RETURNS TABLE
            (
                "EmployeeID"      smallint,
                "LastName"        varchar(20),
                "FirstName"       varchar(10),
                "Title"           varchar(30),
                "TitleOfCourtesy" varchar(25),
                "BirthDate"       date,
                "HireDate"        date,
                "Address"         varchar(60),
                "City"            varchar(15),
                "Region"          varchar(15),
                "PostalCode"      varchar(10),
                "Country"         varchar(15),
                "HomePhone"       varchar(24),
                "Extension"       varchar(4),
                "Photo"           bytea,
                "Notes"           text,
                "ReportsTo"       smallint,
                "PhotoPath"       varchar(255)
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN query select *
                 from employees
                 WHERE employees."Country" = country;
END
$$;
SELECT *
FROM get_country_worker('USA');
-- 10. В контексті бази Northwind створити функцію, що в залежності від імені транспортної компанії
-- повертає список клієнтів, якою вони обслуговуються.
CREATE OR REPLACE FUNCTION get_client(transport_company_name text)
    RETURNS TABLE
            (
                "CustomerID"   bpchar,
                "CompanyName"  varchar(40),
                "ContactName"  varchar(30),
                "ContactTitle" varchar(30),
                "Address"      varchar(60),
                "City"         varchar(15),
                "Region"       varchar(15),
                "PostalCode"   varchar(10),
                "Country"      varchar(15),
                "Phone"        varchar(24),
                "Fax"          varchar(24)
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN query select customers.*
                 from customers
                          JOIN orders USING ("CustomerID")
                          JOIN shippers ON orders."ShipVia" = shippers."ShipperID"
                 WHERE shippers."CompanyName" = transport_company_name;
END
$$;
SELECT *
FROM get_client('United Package');
