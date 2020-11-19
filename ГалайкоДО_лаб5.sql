-- 1. Створити базу даних з ім’ям, що відповідає вашому прізвищу англійською мовою.
CREATE DATABASE "Halaiko";
-- 2. Створити в новій базі таблицю Student з атрибутами StudentId, SecondName, FirstName, Sex.
-- Обрати для них оптимальний тип даних в вашій СУБД
CREATE TABLE "Student"
(
    "StudentId"  INT,
    "SecondName" varchar(20),
    "FirstName"  varchar(10),
    "Sex"        char(1)
);
-- 3. Модифікувати таблицю Student. Атрибут StudentId має стати первинним ключем.
ALTER TABLE "Student"
    ADD PRIMARY KEY ("StudentId");
-- 4. Модифікувати таблицю Student. Атрибут StudentId повинен заповнюватися автоматично починаючи з 1 і кроком в 1.
CREATE SEQUENCE "student_seq";
ALTER TABLE "Student"
    ALTER COLUMN "StudentId" SET DEFAULT nextval('student_seq');
-- 5. Модифікувати таблицю Student. Додати необов’язковий атрибут BirthDate за відповідним типом даних.
ALTER TABLE "Student"
    ADD COLUMN "BirthDate" date;
-- 6.Модифікувати таблицю Student. Додати атрибут CurrentAge, що генерується автоматично на базі
-- існуючих в таблиці даних.
ALTER TABLE "Student"
    ADD COLUMN "CurrentAge" smallint GENERATED ALWAYS AS ( date_part('year',
                                                                     age('2020-11-03 00:00:01', ("BirthDate" + '00:00:01'::time))) ) STORED;

-- 7. Реалізувати перевірку вставлення даних. Значення атрибуту Sex може бути тільки ‘m’ та ‘f’.
ALTER TABLE "Student"
    ADD CHECK ( "Sex" LIKE 'm' OR "Sex" LIKE 'f');
-- 8. В таблицю Student додати себе та двох «сусідів» у списку групи.
INSERT INTO "Student" ("SecondName", "FirstName", "Sex", "BirthDate")
VALUES ('Halaiko', 'Danylo', 'm', '2002-06-26'),
       ('Волошин', 'Віталій', 'm', '07.04.2002'),
       ('Глечковський', 'Богдан', 'm', '02.12.2001');
-- 9. Створити  представлення vMaleStudent та vFemaleStudent, що надають відповідну інформацію.
CREATE VIEW vMaleStudent AS
SELECT *
FROM "Student"
WHERE "Sex" LIKE 'm';
CREATE VIEW vFemaleStudent AS
SELECT *
FROM "Student"
WHERE "Sex" LIKE 'f';
-- 10. Змінити тип даних первинного ключа на TinyInt (або SmallInt) не втрачаючи дані.
DROP VIEW vMaleStudent, vFemaleStudent;

SELECT *
INTO TempStudents
FROM "Student";
TRUNCATE "Student";
ALTER TABLE "Student"
    ALTER COLUMN "StudentId" type smallint;
INSERT INTO "Student" ("SecondName", "FirstName", "Sex")
SELECT "SecondName", "FirstName", "Sex"
FROM TempStudents;
DROP TABLE TempStudents;

CREATE VIEW vMaleStudent AS
SELECT *
FROM "Student"
WHERE "Sex" LIKE 'm';
CREATE VIEW vFemaleStudent AS
SELECT *
FROM "Student"
WHERE "Sex" LIKE 'f';

