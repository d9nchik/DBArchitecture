-- 1. Створити базу даних підприємства «LazyStudent», що займається допомогою студентам ВУЗів з пошуком репетиторів,
-- проходженням практики та розмовними курсами за кордоном.
CREATE DATABASE LazyStudent;
-- 2. Самостійно спроектувати структуру бази в залежності від наступних завдань.
-- 3. База даних повинна передбачати реєстрацію клієнтів через сайт компанії та збереження їх основної інформації.
-- Збереженої інформації повинно бути достатньо для контактів та проведення поштових розсилок.
create table "Clients"
(
    "ClientID"     serial       not null,
    "LastName"     varchar(20)  not null,
    "FirstName"    varchar(10)  not null,
    "PhoneNumber"  varchar(24)  not null,
    "Email"        varchar(255) not null,
    "RegisteredAt" timestamp    not null,
    "Notes"        text
);
create unique index clients_email_uindex
    on "Clients" ("Email");

create unique index clients_phonenumber_uindex
    on "Clients" ("PhoneNumber");

alter table "Clients"
    add constraint clients_pk
        primary key ("ClientID");
-- 4. Через сайт компанії може також зареєструватися репетитор, що надає освітні послуги через посередника «LazyStudent».
-- Репетитор має профільні дисципліни (довільна кількість) та рейтинг, що визначається клієнтами, що з ним уже працювали.
create table "Couch"
(
    "CouchID"   serial        not null,
    "LastName"  varchar(20)   not null,
    "FirstName" varchar(10)   not null,
    "Rating"    int default 0 not null,
    "Phone"     varchar(24)   not null,
    "Email"     varchar(255)  not null
);

create unique index couch_email_uindex
    on "Couch" ("Email");

create unique index couch_phone_uindex
    on "Couch" ("Phone");

alter table "Couch"
    add constraint couch_pk
        primary key ("CouchID");

create table "Disciplines"
(
    "DisciplineID"   serial      not null,
    "DisciplineName" varchar(25) not null,
    "Description"    text
);

create unique index disciplines_disciplinename_uindex
    on "Disciplines" ("DisciplineName");

alter table "Disciplines"
    add constraint disciplines_pk
        primary key ("DisciplineID");

create table "CouchDisciplines"
(
    "CouchID"      int not null
        constraint couchdisciplines_couch_couchid_fk
            references "Couch"
            on update cascade on delete restrict,
    "DisciplineID" int not null
        constraint couchdisciplines_disciplines_disciplineid_fk
            references "Disciplines"
            on update cascade on delete restrict,
    primary key ("CouchID", "DisciplineID")
);
-- 5. Компанії, з якими співпрацює підприємство, також мають зберігатися в БД.
create table "Companies"
(
    "CompanyID"   serial      not null,
    "Name"        varchar(30) not null,
    "TaxNumber"   varchar(8)  not null,
    "Address"     varchar(40) not null,
    "PhoneNumber" varchar(25) not null,
    "ContactName" varchar(20) not null,
    "BankNumber"  varchar(29) not null
);

create unique index companies_address_uindex
    on "Companies" ("Address");

create unique index companies_banknumber_uindex
    on "Companies" ("BankNumber");

create unique index companies_name_uindex
    on "Companies" ("Name");

create unique index companies_phonenumber_uindex
    on "Companies" ("PhoneNumber");

create unique index companies_taxnumber_uindex
    on "Companies" ("TaxNumber");

alter table "Companies"
    add constraint companies_pk
        primary key ("CompanyID");
-- 6. Співробітники підприємства повинні мати можливість відстежувати замовлення клієнтів та їх поточний статус.
-- Передбачити можливість побудови звітності (в тому числі і фінансової) в розрізі періоду, клієнту, репетитора/компанії.
create table "Employees"
(
    "EmployeeID"           serial      not null,
    "LastName"             varchar(20) not null,
    "FirstName"            varchar(10) not null,
    "BirthDate"            date        not null,
    "PassportRecordNumber" varchar(9)  not null,
    "Title"                varchar(30) not null,
    "Address"              varchar(60),
    "PhoneNumber"          varchar(24) not null,
    "Notes"                text
);

create unique index employees_passportrecordnumber_uindex
    on "Employees" ("PassportRecordNumber");

create unique index employees_phonenumber_uindex
    on "Employees" ("PhoneNumber");

alter table "Employees"
    add constraint employees_pk
        primary key ("EmployeeID");

create table "OrderStatus"
(
    "OrderStatusID" serial      not null,
    "Name"          varchar(25) not null,
    "Description"   text
);

create unique index orderstatus_name_uindex
    on "OrderStatus" ("Name");

alter table "OrderStatus"
    add constraint orderstatus_pk
        primary key ("OrderStatusID");
create table "Orders"
(
    "OrderID"    serial not null,
    "OrderDate"  date   not null,
    "DoneDate"   date,
    "StatusID"   int    not null
        constraint orders_status_statusid_fk
            references "OrderStatus"
            on update cascade on delete restrict,
    "EmployeeID" int    not null
        constraint orders_employees_employeeis_fk
            references "Employees"
            on update cascade on delete restrict,
    "CouchID"    int    not null
        constraint orders_couch_couchid_fk
            references "Couch"
            on update cascade on delete restrict,
    "CustomerID" int    not null
        constraint orders_client_customerid_fk
            references "Clients"
            on update cascade on delete restrict,
    "Total"      money  not null,
    "Discount"   real   not null
);

create unique index orders_orderid_uindex
    on "Orders" ("OrderID");

alter table "Orders"
    add constraint orders_pk
        primary key ("OrderID");


create table "Discounts"
(
    "DiscountID" serial not null,
    "CompanyID"  int    not null
        constraint discounts_companies_companyid_fk
            references "Companies"
            on update cascade on delete restrict,
    "StartDate"  date   not null,
    "FinishDate" date   not null
);

create unique index discounts_discountid_uindex
    on "Discounts" ("DiscountID");

alter table "Discounts"
    add constraint discounts_pk
        primary key ("DiscountID");

CREATE OR REPLACE FUNCTION get_orders_by_period("DateStart" date, "DateEnd" date)
    RETURNS SETOF "Orders" AS
$$
BEGIN
    RETURN QUERY
        SELECT *
        FROM "Orders"
        WHERE "OrderDate" BETWEEN "DateStart" AND "DateEnd";

END
$$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_orders_by_customer("Customer_number" int)
    RETURNS SETOF "Orders" AS
$$
BEGIN
    RETURN QUERY
        SELECT *
        FROM "Orders"
        WHERE "Orders"."CustomerID" = "Customer_number";
END
$$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_orders_by_teacher(teacher_number int)
    RETURNS SETOF "Orders" AS
$$
BEGIN
    RETURN QUERY
        SELECT *
        FROM "Orders"
        WHERE "CouchID" = teacher_number;
END
$$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_order_status(order_number int)
    RETURNS varchar(25)
AS
$$
BEGIN
    RETURN QUERY SELECT "Name"
                 FROM "OrderStatus"
                 WHERE "OrderStatusID" = (
                     SELECT "StatusID"
                     FROM "Orders"
                     WHERE "OrderID" = order_number
                 );
END;
$$
    LANGUAGE plpgsql;

-- Отримання деталей замовлення
CREATE OR REPLACE FUNCTION get_order_details(order_number int)
    RETURNS SETOF "Orders" AS
$$
BEGIN
    SELECT *
    FROM "Orders"
    WHERE "OrderID" = order_number;
END;
$$
    LANGUAGE plpgsql;
-- 8. Передбачити історію видалень інформації з БД. Відповідна інформація не повинна відображатися на боці сайту,
-- але керівник та адміністратор мусять мати можливість переглянути хто, коли і яку інформацію видалив.
create table "ClientsArchive"
(
    "ClientID"         int          not null,
    "LastName"         varchar(20)  not null,
    "FirstName"        varchar(10)  not null,
    "PhoneNumber"      varchar(24)  not null,
    "Email"            varchar(255) not null,
    "Notes"            text,
    "DeletionDateTime" timestamp,
    "DeleteBy"         varchar(30)
);
CREATE OR REPLACE FUNCTION clients_delete_trigger_fnc()
    RETURNS trigger AS
$$
BEGIN
    INSERT INTO "ClientsArchive" ("ClientID", "LastName", "FirstName", "PhoneNumber", "Email", "Notes",
                                  "DeletionDateTime", "DeleteBy")
    VALUES (old."ClientID", old."LastName", old."FirstName", old."PhoneNumber", old."Email", old."Notes",
            current_timestamp, session_user);
    RETURN NEW;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER clients_delete_trigger
    AFTER DELETE
    ON "Clients"
    FOR EACH ROW
EXECUTE PROCEDURE clients_delete_trigger_fnc();

create table "CompaniesArchive"
(
    "CompanyID"        int         not null,
    "Name"             varchar(30) not null,
    "TaxNumber"        varchar(8)  not null,
    "Address"          varchar(40) not null,
    "PhoneNumber"      varchar(25) not null,
    "ContactName"      varchar(20) not null,
    "BankNumber"       varchar(29) not null,
    "DeletionDateTime" timestamp,
    "DeleteBy"         varchar(30)
);
CREATE OR REPLACE FUNCTION companies_delete_trigger_fnc()
    RETURNS trigger AS
$$
BEGIN
    INSERT INTO "CompaniesArchive" ("CompanyID", "Name", "TaxNumber", "Address", "PhoneNumber", "ContactName",
                                    "BankNumber", "DeletionDateTime", "DeleteBy")
    VALUES (old."CompanyID", old."Name", old."TaxNumber", old."Address", old."PhoneNumber", old."ContactName",
            old."BankNumber", current_timestamp, session_user);
    RETURN NEW;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER companies_delete_trigger
    AFTER DELETE
    ON "Companies"
    FOR EACH ROW
EXECUTE PROCEDURE companies_delete_trigger_fnc();

create table "CouchArchive"
(
    "CouchID"          serial        not null,
    "LastName"         varchar(20)   not null,
    "FirstName"        varchar(10)   not null,
    "Rating"           int default 0 not null,
    "Phone"            varchar(24)   not null,
    "Email"            varchar(255)  not null,
    "DeletionDateTime" timestamp,
    "DeleteBy"         varchar(30)
);
CREATE OR REPLACE FUNCTION couch_delete_trigger_fnc()
    RETURNS trigger AS
$$
BEGIN
    INSERT INTO "CouchArchive" ("LastName", "FirstName", "Phone", "Email", "DeletionDateTime", "DeleteBy")
    VALUES (old."LastName", old."FirstName", old."Phone", old."Email", current_timestamp, session_user);
    RETURN NEW;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER couch_delete_trigger
    AFTER DELETE
    ON "Couch"
    FOR EACH ROW
EXECUTE PROCEDURE couch_delete_trigger_fnc();

create table "CouchDisciplinesArchive"
(
    "CouchID"          int not null,
    "DisciplineID"     int not null,
    "DeletionDateTime" timestamp,
    "DeleteBy"         varchar(30)
);

CREATE OR REPLACE FUNCTION couch_disciplines_delete_trigger_fnc()
    RETURNS trigger AS
$$
BEGIN
    INSERT INTO "CouchDisciplinesArchive" ("CouchID", "DisciplineID", "DeletionDateTime", "DeleteBy")
    VALUES (old."CouchID", old."DisciplineID", current_timestamp, session_user);
    RETURN NEW;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER couch_disciplines_delete_trigger
    AFTER DELETE
    ON "CouchDisciplines"
    FOR EACH ROW
EXECUTE PROCEDURE couch_disciplines_delete_trigger_fnc();

create table "DisciplinesArchive"
(
    "DisciplineID"     int         not null,
    "DisciplineName"   varchar(25) not null,
    "Description"      text,
    "DeletionDateTime" timestamp,
    "DeleteBy"         varchar(30)
);
CREATE OR REPLACE FUNCTION disciplines_delete_trigger_fnc()
    RETURNS trigger AS
$$
BEGIN
    INSERT INTO "DisciplinesArchive" ("DisciplineID", "DisciplineName", "Description", "DeletionDateTime", "DeleteBy")
    VALUES (old."DisciplineID", old."DisciplineName", old."Description", current_timestamp, session_user);
    RETURN NEW;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER disciplines_delete_trigger
    AFTER DELETE
    ON "Disciplines"
    FOR EACH ROW
EXECUTE PROCEDURE disciplines_delete_trigger_fnc();

create table "EmployeesArchive"
(
    "EmployeeID"           int         not null,
    "LastName"             varchar(20) not null,
    "FirstName"            varchar(10) not null,
    "BirthDate"            date        not null,
    "PassportRecordNumber" varchar(9)  not null,
    "Title"                varchar(30) not null,
    "Address"              varchar(60),
    "PhoneNumber"          varchar(24) not null,
    "Notes"                text,
    "DeletionDateTime"     timestamp,
    "DeleteBy"             varchar(30)
);

CREATE OR REPLACE FUNCTION employees_delete_trigger_fnc()
    RETURNS trigger AS
$$
BEGIN
    INSERT INTO "EmployeesArchive" ("EmployeeID", "LastName", "FirstName", "BirthDate", "PassportRecordNumber", "Title",
                                    "Address", "PhoneNumber", "Notes", "DeletionDateTime", "DeleteBy")
    VALUES (old."EmployeeID", old."LastName", old."FirstName", old."BirthDate", old."PassportRecordNumber", old."Title",
            old."Address", old."PhoneNumber", old."Notes", current_timestamp, session_user);
    RETURN NEW;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER employees_delete_trigger
    AFTER DELETE
    ON "Employees"
    FOR EACH ROW
EXECUTE PROCEDURE employees_delete_trigger_fnc();


create table "OrdersArchive"
(
    "OrderID"          int   not null,
    "OrderDate"        date  not null,
    "DoneDate"         date,
    "StatusID"         int   not null,
    "EmployeeID"       int   not null,
    "CouchID"          int   not null,
    "CustomerID"       int   not null,
    "Total"            money not null,
    "Discount"         real  not null,
    "DeletionDateTime" timestamp,
    "DeleteBy"         varchar(30)
);

CREATE OR REPLACE FUNCTION orders_delete_trigger_fnc()
    RETURNS trigger AS
$$
BEGIN
    INSERT INTO "OrdersArchive" ("OrderID", "OrderDate", "DoneDate", "StatusID", "EmployeeID", "CouchID", "CustomerID",
                                 "Total", "Discount", "DeletionDateTime", "DeleteBy")
    VALUES (old."OrderID", old."OrderDate", old."DoneDate", old."StatusID", old."EmployeeID", old."CouchID",
            old."CustomerID", old."Total", old."Discount", current_timestamp, session_user);
    RETURN NEW;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER orders_delete_trigger
    AFTER DELETE
    ON "Orders"
    FOR EACH ROW
EXECUTE PROCEDURE orders_delete_trigger_fnc();


create table "OrderStatusArchive"
(
    "OrderStatusID"    int         not null,
    "Name"             varchar(25) not null,
    "Description"      text,
    "DeletionDateTime" timestamp,
    "DeleteBy"         varchar(30)
);

CREATE OR REPLACE FUNCTION order_status_delete_trigger_fnc()
    RETURNS trigger AS
$$
BEGIN
    INSERT INTO "OrderStatusArchive" ("OrderStatusID", "Name", "Description", "DeletionDateTime", "DeleteBy")
    VALUES (old."OrderStatusID", old."Name", old."Description", current_timestamp, session_user);
    RETURN NEW;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER order_status_delete_trigger
    AFTER DELETE
    ON "OrderStatus"
    FOR EACH ROW
EXECUTE PROCEDURE order_status_delete_trigger_fnc();

-- 7. Передбачити ролі адміністратора, рядового працівника та керівника. Відповідним чином розподілити права доступу.
CREATE ROLE ruler;
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES, TRIGGER ON
    "Clients", "ClientsArchive", "Companies", "CompaniesArchive", "Couch", "CouchArchive", "CouchDisciplines", "CouchDisciplinesArchive",
    "Disciplines", "DisciplinesArchive", "Employees", "EmployeesArchive", "Orders", "OrdersArchive", "OrderStatus", "OrderStatusArchive"
    TO ruler;

CREATE USER "Boss" WITH IN ROLE ruler;

CREATE ROLE system_administrator;
GRANT ALL PRIVILEGES ON DATABASE lazystudent
    TO system_administrator;

CREATE USER "SystemAdministrator" WITH IN ROLE system_administrator;

CREATE ROLE employee;
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON
    "Clients", "Companies", "Couch", "CouchDisciplines", "Disciplines", "Employees", "Orders", "OrderStatus"
    TO employee;

CREATE USER "Employee" WITH IN ROLE employee;

-- 9. Передбачити систему знижок в залежності від дати реєстрації клієнта.
-- 1 рік – 5%, 2 роки – 8%, 3 роки – 11%, 4 роки – 15%.
-- 10. Передбачити можливість проведення акцій зі знижками на послуги компаній-партнерів в залежності від компанії
-- та дати проведення акції.

CREATE TABLE "Promotions"
(
    "PromotionID" serial PRIMARY KEY,
    "CompanyID"   int NOT NULL
        constraint company_id_fk references "Companies" ON UPDATE CASCADE ON DELETE restrict,
    "Discount"    real,
    "StartDate"   date,
    "EndDate"     date
);
CREATE OR REPLACE FUNCTION calculate_discount()
    RETURNS TRIGGER AS
$$
DECLARE
    "DateDifference"    int  = (
        SELECT CAST(
                       date_part('day', current_date::timestamp - (
                           SELECT "RegisteredAt"
                           FROM "Clients"
                           WHERE "ClientID" = new."CustomerID"
                       )::timestamp) AS int
                   )
    );
    "PromotionDiscount" real = (
        SELECT "Discount"
        FROM "Promotions"
        WHERE "CompanyID" IN (
            SELECT "CouchID"
            FROM "Orders"
            WHERE "OrderID" IN (
                SELECT NEW."OrderID"
            )
        )
    );
    "FinalDiscount"     real;
BEGIN
    IF ("DateDifference" > 365) THEN
        "FinalDiscount" = 0.05;
    END IF;
    IF ("DateDifference" > 2 * 365) THEN
        "FinalDiscount" = 0.08;
    END IF;
    IF ("DateDifference" > 3 * 365) THEN
        "FinalDiscount" = 0.11;
    END IF;
    IF ("DateDifference" > 4 * 365) THEN
        "FinalDiscount" = 0.15;
    END IF;
    IF ("PromotionDiscount" > "FinalDiscount") THEN
        "FinalDiscount" = "PromotionDiscount";
    END IF;

    UPDATE "Orders"
    SET "Total" = "Total" * (1 - "FinalDiscount")
    WHERE "OrderID" = NEW."OrderID";

    UPDATE "Orders"
    SET "Discount" = "FinalDiscount"
    WHERE "OrderID" = NEW."OrderID";
END
$$
    LANGUAGE plpgsql;

CREATE TRIGGER "CalculateDiscountTrigger"
    AFTER INSERT
    ON "Orders"
    FOR EACH ROW
EXECUTE PROCEDURE calculate_discount();
