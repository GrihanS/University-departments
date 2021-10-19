CREATE DATABASE `db_department`;

USE `db_department`;

#STAGE 1. CREATING DATABASE.
#Data dictionaries below.
CREATE TABLE IF NOT EXISTS `tb_departments`(
`dep_id` INT PRIMARY KEY AUTO_INCREMENT,
`dep` VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS `tb_degree`(
`deg_id` INT PRIMARY KEY AUTO_INCREMENT,
`deg` VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS `tb_position`(
`pos_id` INT PRIMARY KEY AUTO_INCREMENT,
`pos` VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS `tb_academic_status`(
`stat_id` INT PRIMARY KEY AUTO_INCREMENT,
`stat` VARCHAR(20)
);

#Main table (staff or tutors, their attributes).
CREATE TABLE IF NOT EXISTS `tb_staff`(
`id` INT,
`dep` INT,
`1st name` VARCHAR(20),
`2nd name` VARCHAR(20),
`middle name` VARCHAR(20),
`birth_date` DATE,
`enrollment` DATE,
`position` INT,
`degree` INT,
`academ_status` INT,
`SOP_score` DECIMAL(5, 3),
`OPA_score` DECIMAL(5, 3),
 FOREIGN KEY (`dep`) REFERENCES `tb_departments`(`dep_id`), 
 FOREIGN KEY (`position`) REFERENCES `tb_position`(`pos_id`),
 FOREIGN KEY (`degree`) REFERENCES `tb_degree`(`deg_id`),
 FOREIGN KEY (`academ_status`) REFERENCES `tb_academic_status`(`stat_id`),
 PRIMARY KEY (`dep`, `id`)
);

#ADDING "position" as a third key.
ALTER TABLE `tb_staff`
DROP PRIMARY KEY, 
ADD PRIMARY KEY(`dep`, `id`, `position`);

#STAGE 2. 
#1) Filling database by hand.
INSERT INTO `tb_academic_status` (`stat`) #in Russian: звание.
VALUES ("Доцент"), ("Профессор");

# https://www.hse.ru/education/faculty#faculties
INSERT INTO `tb_departments` (`dep`)
VALUES ("ДПМ"), ("ДПЭ"), ("ДПИ"), ("ДЭИ"), ("ДКИ"), ("ДТЭ"), ("ДАДИИ"), 
("ДМ"), ("ДПП"), ("ДСАД"), ("ДБИ"), ("МИЭФ");

INSERT INTO `tb_degree` (`deg`)
VALUES ("Кандидат наук"), ("Доктор наук");

INSERT INTO `tb_position` (`pos`)
VALUES 
("Ассистент"), ("Декан"), ("Директор института"),
("Доцент"), ("ЗавКаф"), ("Профессор"), ("Преподаватель"),
("Ст. преподаватель");

INSERT INTO `tb_staff`
(`id`, `dep`,`1st name`,`2nd name`,
`middle name`,`birth_date`,`enrollment`,`position`,
`degree`, `academ_status`, `SOP_score`, `OPA_score`)
VALUES
(13, 4, 'Kirill', 'Cvinnikov', '-', '1979-07-22', '2013-01-01',
1, 2, 2, 1.5, 0);

#2) queries according to the task.
#Get list of tutors employed during the period.
SELECT `enrollment`, CONCAT(`2nd name`,'_', `1st name`, '_',`middle name`) AS `ФИО` 
FROM `tb_staff` WHERE `enrollment` > '2000-01-01' AND `enrollment` < '2020-01-01';

#Get list of tutors with the given degree.
SELECT `id`, CONCAT(`2nd name`, '_',`1st name`, '_',`middle name`) AS `ФИО`,
`deg_id`, `deg` FROM `tb_staff` 
INNER JOIN `tb_degree` ON `deg_id` = `degree` 
 WHERE `deg` = 'Кандидат наук' ORDER BY `id`;

#Get list of tutors took a degree during the given period.
ALTER TABLE `tb_staff` ADD `deg_date` DATE;

UPDATE `tb_staff` SET `deg_date` = DATE_ADD(`birth_date`, INTERVAL 25 YEAR);
SELECT * FROM `tb_staff`; #ex. of filling databse with SQL tools.

SELECT `id`,#query below.
CONCAT(`2nd name`,"_", `1st name`, "_", `middle name`) AS `ФИО` 
FROM `tb_staff` WHERE `deg_date` < '2020-01-01' AND `deg_date` > '1980-01-01'
AND `degree` = 1; #получили кандидата наук (took a degree == 1).

#Get top 10 tutors according to the SOP_score during the given period.
SELECT `id`,`enrollment`, `SOP_score`,
CONCAT(`2nd name`,"_", `1st name`, "_", `middle name`) AS `ФИО` 
FROM `tb_staff`
WHERE `enrollment` > '2000-01-01'
ORDER BY `SOP_score` DESC LIMIT 10;

#Make a report as a table: "position-volume" according to the department.

# https://stackoverflow.com/questions/41887460/select-list-is-not-in-group-by-clause-and-contains-nonaggregated-column-inc/41887524
SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
#Query -> Reconnect to Server.

SELECT `dep`, `pos` AS 'Должность', `pos_id`, COUNT(`position`) 
AS 'Количество' FROM `tb_staff`
INNER JOIN `tb_position` ON `pos_id` = `position` GROUP BY `pos_id`;
 
#Make a report as a table: First name + Last name + Middle name, SOP_score: tutors OPA_score defined with SOP_score <= 3.5 and OPA_score = 0.
SELECT `SOP_score`, CONCAT(`2nd name`, '_', `1st name`, '_', `middle name`) AS `ФИО`
FROM `tb_staff` WHERE `SOP_score` <= 3.5 AND `OPA_score` = 0;

#STAGE 3. Import / export.
SELECT * FROM `tb_staff` ORDER BY `id`;
USE `qwerty`;
SELECT * FROM `qqq1`; #Check the data from the console import.

#STAGE 4.
#Create Login, User & Assign Permissions.
CREATE USER 'AntonS' @`localhost` IDENTIFIED BY 'qwerty';
CREATE USER 'ANONIMYS' @`localhost` IDENTIFIED BY 'APCHI';
CREATE USER 'ADMIN_ADMINA' @`localhost` IDENTIFIED BY '12345';
CREATE USER 'cvix' @`localhost` IDENTIFIED BY '11111';

GRANT SELECT ON `tb_staff` TO 'AntonS' @`localhost`;
GRANT UPDATE ON `tb_degree` TO 'ADMIN_ADMINA' @`localhost`;
GRANT DELETE ON `tb_position` TO 'ANONIMYS' @`localhost`;
GRANT SELECT ON `tb_staff` TO 'cvix' @`localhost`;

SHOW GRANTS FOR 'AntonS';

REVOKE DELETE ON `tb_position` FROM 'ANONIMYS';
SHOW GRANTS FOR 'ANONIMYS';
