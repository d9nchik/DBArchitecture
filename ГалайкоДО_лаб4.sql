-- 1 Додати себе як співробітника компанії на позицію Intern.
INSERT INTO employees ("EmployeeID", "LastName", "FirstName", "Title", "TitleOfCourtesy", "BirthDate", "HireDate",
                       "Address", "City", "Region", "PostalCode", "Country", "HomePhone", "Extension", "Photo", "Notes",
                       "ReportsTo", "PhotoPath")
VALUES (10, 'Halaiko', 'Danylo', 'Intern', 'Mr.', '2002-06-26', '2020-10-21', 'Schuljavka, 30', 'Kiev', 'KY', '43007',
        'Ukraine', '(096) 698-81-525', '454', null, 'Very educated person, especially in IT', null, null);
-- 2 Змінити свою посаду на Director.
UPDATE employees
SET "Title"='Director'
WHERE "LastName" = 'Halaiko';
-- 3 Скопіювати таблицю Orders в таблицю OrdersArchive.
SELECT *
INTO "OrdersArchive"
FROM orders;
-- 4 Очистити таблицю OrdersArchive
TRUNCATE "OrdersArchive";
-- 5 Не видаляючи таблицю OrdersArchive, наповнити її інформацією повторно.
INSERT INTO "OrdersArchive"
SELECT *
FROM orders;
-- 6 З таблиці OrdersArchive видалити десять замовлень, що були зроблені замовниками із Берліну.
DELETE
FROM "OrdersArchive"
WHERE "OrderID" IN (SELECT "OrderID" FROM "OrdersArchive" WHERE "ShipCity" = 'Berlin' LIMIT 10);
-- 7 Внести в базу два продукти з власним іменем та іменем групи.
INSERT INTO products ("ProductID", "ProductName", "SupplierID", "CategoryID", "QuantityPerUnit", "UnitPrice",
                      "UnitsInStock", "UnitsOnOrder", "ReorderLevel", "Discontinued")
VALUES (78, 'Данило', 18, 1, 'i''m not sold', 0, 1, 0, 5, 0),
       (79, 'ІП-92', 12, 3, 'Per man)', 1000, 1, 1, 0, 0);
-- 8 Помітити продукти, що не фігурують в замовленнях, як такі, що більше не виробляються.
UPDATE products
SET "Discontinued"=1
WHERE "ProductID" NOT IN (
    SELECT "ProductID"
    FROM order_details);
-- 9 Видалити таблицю OrdersArchive.
DROP TABLE "OrdersArchive";
-- 10 Видалити базу Northwind.
DROP DATABASE "Northwind";
