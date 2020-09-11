SELECT 'Галайко', 'Данило', 'Олександрович', 'ІП-92';
-- Вивести за допомогою команди SELECT своє прізвище, ім’я, по-батькові та групу на екран. Українською мовою.
SELECT * FROM orders;
-- Вибрати всі дані з таблиці Orders.
SELECT "ProductName" FROM products WHERE "UnitsInStock" > 0;
-- Обрати всі назви товарів з таблиці Products, продаж яких не припинено.
SELECT DISTINCT "City" FROM customers;
-- Вивести всі міста клієнтів уникаючи дублікатів.
SELECT "CompanyName" FROM suppliers ORDER BY "CompanyName" DESC;
-- Вибрати всі назви компаній-постачальників в порядку зворотному алфавітному.
SELECT "OrderID" AS "OrderNumber", "ProductID" AS "ProductNumber", * FROM order_details;
-- Отримати всі деталі замовлень, замінивши назви в назвах стовпчиків ID на Number.
SELECT "CompanyName", "Address", "Phone" FROM "suppliers" WHERE "Country"='USA' LIMIT 3;
-- Знайти трьох постачальників з США. Вивести назву, адресу та телефон. 
SELECT "ContactName" FROM customers WHERE "ContactName" LIKE 'H%' or "ContactName" LIKE 'D%' or "ContactName" LIKE 'O%';
-- Вивести всі контактні імена клієнтів, що починаються з першої літери вашого прізвища, імені, по-батькові. Врахувати чутливість до регістру. 
SELECT * FROM orders WHERE NOT "ShipAddress" LIKE '%.%';
-- Показати усі замовлення, в адресах доставки яких немає крапок.
SELECT * FROM products WHERE "ProductName" SIMILAR TO '[%_]%o';
-- Вивести назви тих продуктів, що починаються на знак % або _, а закінчуються на останню літеру вашого імені. Навіть якщо такі відсутні. 
