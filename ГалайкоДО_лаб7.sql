-- 1. Вивести на екран перший рядок з усіх таблиць без прив’язки до конкретної бази даних.
-- FIXME
CREATE OR REPLACE FUNCTION get_all_tables_names(ref refcursor) returns refcursor
    language plpgsql as

$$
begin
    OPEN ref FOR SELECT table_schema || '.' || table_name
                 FROM information_schema.tables
                 WHERE table_type = 'BASE TABLE'
                   AND table_schema NOT IN ('pg_catalog', 'information_schema');
    return ref;
end;
$$;
ROLLBACK;
BEGIN;
SELECT get_all_tables_names('funccursor');
FETCH funccursor INTO rowvar;

COMMIT;

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
