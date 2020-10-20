-- 1.1 Використовуючи SELECT без FROM, поверніть набір з п’яти рядків, що включають дві колонки з вашими улюбленими
-- виконавцями та піснями.
SELECT 'Rammstein' AS Singer, 'Du hast' AS Song
UNION
SELECT 'Meduza', 'Piece of your Heart'
UNION
SELECT 'Becky Hill', 'Lose Control'
UNION
SELECT 'Tones and I', 'Dance Monkey'
UNION
SELECT 'SAINT JHN', 'Roses (Imanbek Remix)';
-- 1.2 Порівнявши власний порядковий номер в групі з набором із всіх номерів в групі, вивести на екран ;-) якщо він
-- менший за усі з них, або :-D в протилежному випадку.
SELECT CASE
           WHEN 5 < ALL (SELECT generate_series(1, 27)) THEN ';-)'
           ELSE ':-D' END;
-- 1.3 Не використовуючи таблиці, вивести на екран прізвище та ім’я усіх дівчат своєї групи за винятком тих, хто має
-- спільне ім’я з студентками іншої групи.
SELECT *
FROM (SELECT 'Бераудо' "Lastname", 'Еліза' "Firstname"
      UNION
      SELECT 'Ткаченко', 'Вікторія'
      UNION
      SELECT 'Фрадиньска', 'Дарія'
      UNION
      SELECT 'Колбун', 'Ірина') AS Girls
WHERE "Firstname" NOT IN (SELECT 'Юлія'
                          UNION
                          SELECT 'Єлізавета'
                          UNION
                          SELECT 'Дар''я'
                          UNION
                          SELECT 'Дарія'
                          UNION
                          SELECT 'Дарина'
                          UNION
                          SELECT 'Софія'
                          UNION
                          SELECT 'Ольга'
                          UNION
                          SELECT 'Анастасія'
                          UNION
                          SELECT 'Валерія');
-- 1.4 Вивести усі рядки з таблиці Numbers (Number INT). Замінити цифру від 0 до 9 на її назву літерами. Якщо цифра
-- більше, або менша за названі, залишити її без змін.
SELECT CASE "Number"
           WHEN 0 THEN 'Нуль'
           WHEN 1 THEN 'Один'
           WHEN 2 THEN 'Два'
           WHEN 3 THEN 'Три'
           WHEN 4 THEN 'Чотири'
           WHEN 5 THEN 'П''ять'
           WHEN 6 THEN 'Шість'
           WHEN 7 THEN 'Сім'
           WHEN 8 THEN 'Вісім'
           WHEN 9 THEN 'Дев''ять'
           ELSE cast(num as varchar) END
FROM "Numbers";
-- 1.5 Навести приклад синтаксису декартового об’єднання для вашої СУБД.
SELECT *
FROM T1
         CROSS JOIN T2;
-- P.S. декартове обʼєднання - це CROSS JOIN
-- 2.6 Вивести усі замовлення та їх службу доставки. В результуючому наборі в залежності від ідентифікатора,
-- перейменувати одну із служб на таку, що відповідає вашому імені, прізвищу, або по-батькові.
SELECT "OrderID",
       CASE "ShipVia"
           WHEN 1 THEN 'Halaiko'
           ELSE (SELECT "CompanyName" FROM shippers WHERE "ShipperID" = "ShipVia")
           END
FROM orders;
-- 2.7 Вивести в алфавітному порядку усі країни, що фігурують в адресах клієнтів, працівників, та місцях доставки
-- замовлень.
WITH countries AS (
    SELECT "Country"
    FROM customers
    UNION ALL
    SELECT "Country"
    FROM employees
    UNION ALL
    SELECT "ShipCountry"
    FROM orders
)
SELECT Distinct "Country"
FROM countries
ORDER BY "Country";
-- 2.8 Вивести прізвище та ім’я працівника, а також кількість замовлень, що він обробив за перший квартал 1998 року.
SELECT "LastName",
       "FirstName",
       (SELECT count(*)
        FROM orders
        WHERE employees."EmployeeID" = orders."EmployeeID"
          AND "OrderDate" BETWEEN '1998-01-01' AND '1998-03-31') AS "NumberOfOrders"
FROM employees;
-- 2.9 Використовуючи СTE знайти усі замовлення, в які входять продукти, яких на складі більше 80 одиниць, проте по яким
-- немає максимальних знижок.
WITH bigger80 AS (SELECT Distinct "OrderID"
                  FROM order_details
                  WHERE "ProductID" IN (
                      SELECT "ProductID"
                      FROM products
                      WHERE "UnitsInStock" > 80)
                    AND "Discount" <> (SELECT max("Discount") FROM order_details))
SELECT *
FROM orders
WHERE "OrderID" IN (SELECT * FROM bigger80);
-- 2.10 Знайти назви усіх продуктів, що не продаються в південному регіоні.
SELECT "ProductName"
FROM products EXCEPT
SELECT "ProductName"
FROM Products
         JOIN order_details USING ("ProductID")
         JOIN orders USING ("OrderID")
         JOIN employeeterritories USING ("EmployeeID")
         JOIN territories USING ("TerritoryID")
         JOIN region USING ("RegionID")
WHERE "RegionDescription" = 'Southern';
