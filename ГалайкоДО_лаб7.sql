-- 1. Вивести на екран перший рядок з усіх таблиць без прив'язки до конкретної бази даних.
CREATE OR REPLACE FUNCTION showFirstRowFromAllTables() Returns void AS
$$
DECLARE
    Query   text;
    Row     record;
    "Table" record;
BEGIN
    For "Table" In Select * From pg_catalog.pg_tables Where schemaname = 'public'
        LOOP
            Query = 'select * from "' || "Table".tablename || '" LIMIT 1;';
            For Row In Execute Query
                LOOP
                    Raise Notice '%', Row;
                END LOOP;
        END LOOP;
END;
$$
    language plpgsql;

SELECT *
FROM showFirstRowFromAllTables();

-- 2. Видати дозвіл на читання бази даних Northwind усім користувачам вашої СУБД.
-- Користувачі, що будуть створені після виконання запиту, доступ на читання отримати не повинні.

GRANT SELECT on all Tables In SCHEMA public to public;

-- 3. За допомогою курсору заборонити користувачеві TestUser доступ до всіх таблиць поточної бази даних,
-- імена котрих починаються на префікс ‘prod_’.

CREATE OR REPLACE FUNCTION forbidTestUserOnCurrentDB() returns void AS
$$
DECLARE
    CurrTableS cursor For Select tablename
                          from pg_catalog."pg_tables"
                          WHERE schemaname = 'public'
                            AND tablename LIKE 'prod\_%';
    "Table" RECORD;
BEGIN
    FOR "Table" in CurrTableS
        loop
            execute 'Revoke all on table ' || "Table"."tablename" || ' From TestUser';
        END loop;
END;
$$
    language plpgsql;
Select forbidTestUserOnCurrentDB();

-- 4. В контексті бази Northwind створити збережену процедуру (або функцію), що приймає в якості параметра номер
-- замовлення та виводить імена продуктів, їх кількість, та загальну суму по кожній позиції в залежності від вартості,
-- кількості та наявності знижки. Запустити виконання збереженої процедури для всіх наявних замовлень.

CREATE FUNCTION "InfoAboutProduct"(IdOfOrder smallint)
    RETURNS VOID AS
$$
DECLARE
    Product         RECORD;
    ProductForOrder RECORD;
BEGIN
    Raise notice 'IdOfOrder: %', IdOfOrder;
    FOR ProductForOrder IN Select * From order_details Where "OrderID" = IdOfOrder
        LOOP
            Select * into Product from products where "ProductID" = ProductForOrder."ProductID";
            Raise notice 'Name of product: %', Product."ProductName";
            Raise notice 'Price: %', (1 - ProductForOrder."Discount") * ProductForOrder."Quantity" *
                                     ProductForOrder."UnitPrice";
            Raise notice 'Quantity: %', ProductForOrder."Quantity";
        END LOOP;
END;
$$
    language plpgsql;
SELECT "InfoAboutProduct"(CAST(10249 as smallint));

-- 5. Видаліть дані з усіх таблиць в усіх базах даних наявної СУБД.
-- Код повинен бути незалежним від наявних імен об'єктів.
CREATE OR REPLACE FUNCTION DeleteDataTables() Returns void AS
$$
DECLARE
    CURS CURSOR For Select tablename
                    From pg_tables
                    Where schemaname = 'public';

BEGIN
    For sth In CURS
        Loop
            Execute 'TRUNCATE TABLE ' || quote_ident(sth.tablename) || ' CASCADE;';
        END Loop;
END;
$$
    language plpgsql;
BEGIN;
SELECT DeleteDataTables();
COMMIT;
ROLLBACK;

-- 6. Створити тригер на таблиці Customers, що при вставці нового телефонного номеру буде видаляти усі символи крім цифр.

CREATE OR REPLACE FUNCTION customers_insert_trigger_fnc()
    RETURNS trigger AS
$$
BEGIN
    new."Phone" = regexp_replace(new."Phone", '\D+', '', 'g');
    RETURN NEW;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER customer_insert_trigger
    BEFORE INSERT
    ON customers

    FOR EACH ROW

EXECUTE PROCEDURE customers_insert_trigger_fnc();

INSERT INTO customers ("CustomerID", "CompanyName", "Phone")
VALUES (96, 'saske', '87653kfjdkd4253`');

-- 7. В контексті бази Northwind створити тригер який при вставці даних в таблицю Order Details нових записів буде
-- перевіряти загальну вартість замовлення. Якщо загальна вартість перевищує 100 грошових одиниць – надати знижку в 3%,
-- якщо перевищує 500 – 5%, більш ніж 1000 – 8%.
CREATE OR REPLACE FUNCTION order_details_insert_trigger_fnc()
    RETURNS trigger AS
$$
DECLARE
    price    real = new."UnitPrice" * new."Quantity";
    discount real = 0;
BEGIN
    if price > 1000 then
        discount = 0.08;
    ELSIF price > 500 then
        discount = 0.05;
    ELSIF price > 100 then
        discount = 0.03;
    end if;
    new."Discount" = discount;
    RETURN NEW;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER order_details_insert_trigger
    BEFORE INSERT
    ON order_details

    FOR EACH ROW

EXECUTE PROCEDURE order_details_insert_trigger_fnc();
INSERT INTO order_details ("OrderID", "ProductID", "UnitPrice", "Quantity", "Discount")
VALUES (11080, 123, 501, 1, 0);
-- 8. Створити таблицю Contacts (ContactId, LastName, FirstName, PersonalPhone, WorkPhone, Email, PreferableNumber).
-- Створити тригер, що при вставці даних в таблицю Contacts вставить в якості PreferableNumber WorkPhone
-- якщо він присутній, або PersonalPhone, якщо робочий номер телефона не вказано.
create table "Contacts"
(
    "ContactId"        serial      not null,
    "LastName"         varchar(25) not null,
    "FirstName"        varchar(15) not null,
    "PersonalPhone"    varchar(15),
    "WorkPhone"        varchar(15),
    "Email"            varchar(30),
    "PreferableNumber" varchar(15)
);

create unique index contacts_contactid_uindex
    on "Contacts" ("ContactId");

alter table "Contacts"
    add constraint contacts_pk
        primary key ("ContactId");

CREATE OR REPLACE FUNCTION contacts_insert_trigger_fnc()
    RETURNS trigger AS
$$
BEGIN
    if new."WorkPhone" is not null then
        new."PreferableNumber" = new."WorkPhone";
    ELSE
        new."PreferableNumber" = new."PersonalPhone";
    end if;
    RETURN NEW;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER contacts_insert_trigger
    BEFORE INSERT
    ON "Contacts"

    FOR EACH ROW

EXECUTE PROCEDURE contacts_insert_trigger_fnc();
INSERT INTO "Contacts" ("LastName", "FirstName", "PersonalPhone", "WorkPhone", "Email", "PreferableNumber")
VALUES ('Danylo', 'Halaiko', '0965883521', '4300', 'naruto@gmail.com', null);
-- 9. Створити таблицю OrdersArchive що дублює таблицю Orders та має додаткові атрибути DeletionDateTime та DeletedBy.
-- Створити тригер, що при видаленні рядків з таблиці Orders буде додавати їх в таблицю OrdersArchive
-- та заповнювати відповідні колонки.
create table "OrdersArchive"
(
    "OrderID"          smallint not null
        constraint pk_orders_archive
            primary key,
    "CustomerID"       bpchar,
    "EmployeeID"       smallint,
    "OrderDate"        date,
    "RequiredDate"     date,
    "ShippedDate"      date,
    "ShipVia"          smallint,
    "Freight"          real,
    "ShipName"         varchar(40),
    "ShipAddress"      varchar(60),
    "ShipCity"         varchar(15),
    "ShipRegion"       varchar(15),
    "ShipPostalCode"   varchar(10),
    "ShipCountry"      varchar(15),
    "DeletionDateTime" timestamp,
    "DeleteBy"         varchar(30)
);

CREATE OR REPLACE FUNCTION orders_delete_trigger_fnc()
    RETURNS trigger AS
$$
BEGIN
    INSERT INTO "OrdersArchive" ("OrderID", "CustomerID", "EmployeeID", "OrderDate", "RequiredDate", "ShippedDate",
                                 "ShipVia", "Freight", "ShipName", "ShipAddress", "ShipCity", "ShipRegion",
                                 "ShipPostalCode", "ShipCountry", "DeletionDateTime", "DeleteBy")
    VALUES (old."OrderID", old."CustomerID", old."EmployeeID", old."OrderDate", old."RequiredDate", old."ShippedDate",
            old."ShipVia", old."Freight", old."ShipName", old."ShipAddress", old."ShipCity", old."ShipRegion",
            old."ShipPostalCode", old."ShipCountry", current_timestamp, session_user);
    RETURN NEW;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER orders_delete_trigger
    AFTER DELETE
    ON "orders"
    FOR EACH ROW
EXECUTE PROCEDURE orders_delete_trigger_fnc();
-- 10. Створити три таблиці: TriggerTable1, TriggerTable2 та TriggerTable3. Кожна з таблиць має наступну структуру:
-- TriggerId(int) – первинний ключ з автоінкрементом, TriggerDate(Date). Створити три тригера.
-- Перший тригер повинен при будь-якому записі в таблицю TriggerTable1 додати дату запису в таблицю TriggerTable2.
-- Другий тригер повинен при будь-якому записі в таблицю TriggerTable2 додати дату запису в таблицю TriggerTable3.
-- Третій тригер працює аналогічно за таблицями TriggerTable3 та TriggerTable1.
-- Вставте один рядок в таблицю TriggerTable1. Напишіть, що відбулось в коментарі до коду. Чому це сталося?
create table "TriggerTable1"
(
    "TriggerId"   serial not null,
    "TriggerDate" timestamp
);

create unique index triggertable1_triggerid_uindex
    on "TriggerTable1" ("TriggerId");

alter table "TriggerTable1"
    add constraint triggertable1_pk
        primary key ("TriggerId");

create table "TriggerTable2"
(
    "TriggerId"   serial not null,
    "TriggerDate" timestamp
);

create unique index triggertable2_triggerid_uindex
    on "TriggerTable2" ("TriggerId");

alter table "TriggerTable2"
    add constraint triggertable2_pk
        primary key ("TriggerId");

create table "TriggerTable3"
(
    "TriggerId"   serial not null,
    "TriggerDate" timestamp
);

create unique index triggertable3_triggerid_uindex
    on "TriggerTable3" ("TriggerId");

alter table "TriggerTable3"
    add constraint triggertable3_pk
        primary key ("TriggerId");
-- Creating triggers
CREATE OR REPLACE FUNCTION trigger_table_1_insert_trigger_fnc()
    RETURNS trigger AS
$$
BEGIN
    INSERT INTO "TriggerTable2" ("TriggerDate") VALUES (current_timestamp);
    RETURN NEW;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER trigger_table_1_insert_trigger
    BEFORE INSERT
    ON "TriggerTable1"

    FOR EACH ROW

EXECUTE PROCEDURE trigger_table_1_insert_trigger_fnc();

CREATE OR REPLACE FUNCTION trigger_table_2_insert_trigger_fnc()
    RETURNS trigger AS
$$
BEGIN
    INSERT INTO "TriggerTable3" ("TriggerDate") VALUES (current_timestamp);
    RETURN NEW;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER trigger_table_2_insert_trigger
    BEFORE INSERT
    ON "TriggerTable2"

    FOR EACH ROW

EXECUTE PROCEDURE trigger_table_2_insert_trigger_fnc();

CREATE OR REPLACE FUNCTION trigger_table_3_insert_trigger_fnc()
    RETURNS trigger AS
$$
BEGIN
    INSERT INTO "TriggerTable1" ("TriggerDate") VALUES (current_timestamp);
    RETURN NEW;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER trigger_table_3_insert_trigger
    BEFORE INSERT
    ON "TriggerTable3"

    FOR EACH ROW

EXECUTE PROCEDURE trigger_table_3_insert_trigger_fnc();
INSERT INTO "TriggerTable1" ("TriggerDate")
VALUES (current_timestamp);
-- Мій коментар: виникла помилка Stack overflow - переповнення глибини рекурсії(Циклічний виклик тригерів),
-- оскільки операція не змогла бути виконана, тому був відкат транзакції. БД не була модифікована.
--  ERROR: stack depth limit exceeded
--  Подсказка: Increase the configuration parameter "max_stack_depth" (currently 2048kB),
--  after ensuring the platform's stack depth limit is adequate. Где: SQL statement
--  "INSERT INTO "TriggerTable2" ("TriggerDate") VALUES (current_timestamp)" PL/pgSQL function t
--  rigger_table_1_insert_trigger_fnc() line 3 at SQL statement
