-- 1. Створити базу даних підприємства «LazyStudent», що займається допомогою студентам ВУЗів з пошуком репетиторів,
-- проходженням практики та розмовними курсами за кордоном.
CREATE DATABASE LazyStudent;
-- 2. Самостійно спроектувати структуру бази в залежності від наступних завдань.
-- 3. База даних повинна передбачати реєстрацію клієнтів через сайт компанії та збереження їх основної інформації.
-- Збереженої інформації повинно бути достатньо для контактів та проведення поштових розсилок.
create table "Clients"
(
    "ClientID"    serial       not null,
    "LastName"    varchar(20)  not null,
    "FirstName"   varchar(10)  not null,
    "PhoneNumber" varchar(24)  not null,
    "Email"       varchar(255) not null,
    "Notes"       text
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
    "StatusID"   int    not null,
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
	"CompanyID" int not null
		constraint discounts_companies_companyid_fk
			references "Companies"
				on update cascade on delete restrict,
	"StartDate" date not null,
	"FinishDate" date not null
);

create unique index discounts_discountid_uindex
	on "Discounts" ("DiscountID");

alter table "Discounts"
	add constraint discounts_pk
		primary key ("DiscountID");
