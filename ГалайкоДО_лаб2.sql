-- Задача №1
-- 1.1 Необхідно знайти кількість рядків в таблиці, що містить більше ніж 2147483647 записів. Напишіть код для
-- MS SQL Server та ще однієї СУБД (на власний вибір)
-- MS SQL Server
SELECT COUNT_BIG(*)
FROM yourBD;
-- Postgresql - count returns bigInt https://postgrespro.ru/docs/postgresql/12/functions-aggregate
SELECT count(*)
FROM employees;
-- 1.2 Підрахувати довжину свого прізвища, імені та по-батькові за допомогою SQL. Результат вивести в три колонки.
SELECT length('Галайко'), length('Данило'), length('Олександрович');
-- 1.3 Взявши рядок з виконавцем та назвою пісні, яку ви слухали останньою, замінити пробіли на знаки нижнього
-- підкреслювання.
SELECT replace('Rammstein Du hast', ' ', '_');
-- 1.4 Створити генератор імені електронної поштової скриньки, що шляхом конкатенації об’єднував би дві перші літери з
-- колонки імені, та чотири перші літери з колонки прізвища користувача, що зберігаються в базі даних, а також домену з
-- вашим прізвищем.
SELECT concat(substr("FirstName", 1, 2), '.', substr("LastName", 1, 4), '@halaiko.com')
FROM employees;
-- 1.5 За допомогою SQL визначити, в який день тижня ви народилися.
SELECT to_char(TIMESTAMP '2002-06-26', 'DAY');

-- Задача №2:
-- 2.1 Вивести усі данні по продуктам, їх категоріям, та постачальникам, навіть якщо останні з певних причин відсутні.
SELECT *
FROM products
         JOIN categories c on products."CategoryID" = c."CategoryID"
         JOIN suppliers s on products."SupplierID" = s."SupplierID";
-- 2.2 Показати усі замовлення, що були зроблені в квітні 1998 року та не були відправлені.
SELECT *
FROM orders
WHERE ("OrderDate" BETWEEN '1998-04-01' AND '1998-04-30')
  AND "ShippedDate" IS NULL;
-- 2.3 Відібрати усіх працівників, що відповідають за південний регіон.
SELECT *
FROM employees
WHERE "EmployeeID" IN (SELECT DISTINCT "EmployeeID"
                       FROM employeeterritories
                       WHERE "TerritoryID" IN (SELECT territories."TerritoryID"
                                               FROM territories
                                               WHERE "RegionID" =
                                                     (SELECT "RegionID" FROM region WHERE "RegionDescription" = 'Southern')));
-- 2.4 Вирахувати загальну вартість з урахуванням знижки усіх замовлень, що були здійснені на непарну дату.
SELECT sum(("UnitPrice" * (1 - "Discount") * "Quantity")) AS TotalPrice
FROM orders
         JOIN order_details od on orders."OrderID" = od."OrderID"
WHERE (CAST(EXTRACT(DAY FROM "OrderDate") AS INT) % 2) = 1;
-- 2.5 Знайти адресу відправлення замовлення з найбільшою ціною позиції (враховуючи вартість товару, його кількість та
-- наявність знижки). Якщо таких замовлень декілька – повернути найновіше.
SELECT "ShipAddress"
FROM orders
ORDER BY (SELECT sum("UnitPrice" * (1 - "Discount") * "Quantity")
          FROM order_details
          WHERE orders."OrderID" = order_details."OrderID") DESC, "OrderDate" DESC
LIMIT 1;
