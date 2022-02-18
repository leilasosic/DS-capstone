--------------- SQL DDL -----------------
----- creating the 8 tables from the ER diagram -----
CREATE TABLE manager (
	manager_id INTEGER NOT NULL,
	manager_name VARCHAR(100) NOT NULL,
	CONSTRAINT manager_pkey PRIMARY KEY (manager_id)
	);
	
CREATE TABLE ratings (
	rating_id INTEGER NOT NULL,
	career_mobility_rating INTEGER NOT NULL,
	mgr_involve_rating INTEGER NOT NULL,
	communication_rating INTEGER NOT NULL,
	satisfaction_rating INTEGER NOT NULL,
	dei_rating INTEGER NOT NULL,
	CONSTRAINT ratings_pkey PRIMARY KEY (rating_id)
	);
	
CREATE TABLE users (
	user_id INTEGER NOT NULL,
	CONSTRAINT users_pkey PRIMARY KEY (user_id)
	);
	
CREATE TABLE jobTitle (
	job_id INTEGER NOT NULL,
	job_title VARCHAR(100) NOT NULL,
	CONSTRAINT jobTitle_pkey PRIMARY KEY (job_id)
	);
	
CREATE TABLE department (
	dept_id INTEGER NOT NULL,
	dept_name VARCHAR(100) NOT NULL,
	CONSTRAINT department_pkey PRIMARY KEY (dept_id)
	);
	
CREATE TABLE sector (
	sector_id INTEGER NOT NULL,
	sector_name VARCHAR(100) NOT NULL,
	CONSTRAINT sector_pkey PRIMARY KEY (sector_id)
	);
	
CREATE TABLE company (
	company_id INTEGER NOT NULL,
	company_name VARCHAR(100) NOT NULL,
	CONSTRAINT company_pkey PRIMARY KEY (company_id)
	);
	
CREATE TABLE reviews (
	review_id INTEGER NOT NULL,
	review VARCHAR(1000),
	CONSTRAINT reviews_pkey PRIMARY KEY (review_id)
	);
	
	
						----- foreign keys -----
ALTER TABLE manager ADD CONSTRAINT manager_ratings
	FOREIGN KEY (manager_id) REFERENCES ratings (rating_id);
	
ALTER TABLE manager ADD COLUMN rating_id  INT;

UPDATE manager SET rating_id = 234  WHERE manager_id = 1;
UPDATE manager SET rating_id = 456  WHERE manager_id = 4;
UPDATE manager SET rating_id = 567 WHERE manager_id = 5;
UPDATE manager SET rating_id = 123  WHERE manager_id = 7;

------------------------------	
	
ALTER TABLE manager ADD CONSTRAINT manager_reviews
	FOREIGN KEY (manager_id) REFERENCES reviews (review_id);
	
ALTER TABLE manager ADD COLUMN review_id  INT;

UPDATE manager SET review_id = 99  WHERE manager_id = 5;
UPDATE manager SET review_id = 88  WHERE manager_id = 6;
	
------------------------------		

ALTER TABLE manager ADD CONSTRAINT manager_company
	FOREIGN KEY (manager_id) REFERENCES company (company_id);
	
ALTER TABLE manager ADD COLUMN company_id INT;

UPDATE manager SET company_id = 186  WHERE manager_id = 3;
UPDATE manager SET company_id = 940  WHERE manager_id = 1;
UPDATE manager SET company_id = 824  WHERE manager_id = 4;
UPDATE manager SET company_id = 824  WHERE manager_id = 7;
UPDATE manager SET company_id = 824  WHERE manager_id = 6;
UPDATE manager SET company_id = 186  WHERE manager_id = 5;

------------------------------	
	
ALTER TABLE users ADD CONSTRAINT users_ratings
	FOREIGN KEY (user_id) REFERENCES ratings (rating_id);
	
ALTER TABLE users ADD CONSTRAINT users_reviews
	FOREIGN KEY (user_id) REFERENCES reviews (review_id);
	
ALTER TABLE users ADD COLUMN ratings_id INT;
ALTER TABLE users ADD COLUMN reviews_id INT;

UPDATE users SET review_id = 99  WHERE user_id = 10;
UPDATE users SET review_id = 88  WHERE user_id = 20;
UPDATE users SET review_id = 77  WHERE user_id = 40;

UPDATE users SET ratings_id = 234  WHERE user_id = 10;
UPDATE users SET ratings_id = 456  WHERE user_id = 20;
UPDATE users SET ratings_id = 567  WHERE user_id = 40;
UPDATE users SET ratings_id = 123  WHERE user_id = 70;

	
------------------------------	
		
ALTER TABLE users ADD CONSTRAINT users_jobtitle
	FOREIGN KEY (user_id) REFERENCES jobTitle (job_id);

ALTER TABLE users ADD COLUMN job_id INT;
	
------------------------------
ALTER TABLE users ADD CONSTRAINT users_company
	FOREIGN KEY (user_id) REFERENCES company (company_id);

ALTER TABLE users ADD COLUMN company_id INT;

-------------------------------

ALTER TABLE users ADD CONSTRAINT users_manager
	FOREIGN KEY (user_id) REFERENCES manager (manager_id);
	
ALTER TABLE users ADD COLUMN manager_id INT;
select * from manager
-------------------------------
	
ALTER TABLE jobTitle ADD CONSTRAINT jobTitle_department
	FOREIGN KEY (job_id) REFERENCES department (dept_id);

ALTER TABLE jobTitle ADD COLUMN dept_id INT;

-------------------------------
	
ALTER TABLE department ADD CONSTRAINT department_sector
	FOREIGN KEY (dept_id) REFERENCES sector (sector_id);
	
ALTER TABLE department ADD COLUMN sector_id INT;

-------------------------------
ALTER TABLE company ADD CONSTRAINT company_sector
	FOREIGN KEY (company_id) REFERENCES sector (sector_id);
	
ALTER TABLE company ADD COLUMN sector_id INT;

UPDATE company SET sector_id = 43  WHERE company_id = 186;
UPDATE company SET sector_id = 43  WHERE company_id = 940;


----- DDL - needs to have two view definitions w/ who would use these views -----
 	---- View 1: Create a view consisting of all managers ----
CREATE VIEW allmanagers AS
	SELECT * FROM manager;
	
--calling on the view--
SELECT * FROM allmanagers;

  	---- View 2: Create a view consisting of all companies ----
	
CREATE VIEW allcompanies AS
 	SELECT * FROM company;
	
	--calling on the view--
SELECT * FROM allcompanies;
	
	
	
----- 2 SQL Functions ------

	---- Function 1: Create a function the counts the number of reviews ----
CREATE FUNCTION get_review_count()
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
	review_count integer;
BEGIN
	SELECT COUNT(*)
	INTO review_count
	FROM reviews;
	RETURN review_count;
END;
$$;

	-- calling Function 1 --
SELECT get_review_count();
	
	---- Function 2: Create a function that counts the number of ratings ----
	
CREATE FUNCTION get_ratings_count()
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
	ratings_count integer;
BEGIN
	SELECT COUNT(*)
	INTO ratings_count
	FROM ratings;
	RETURN ratings_count;
END;
$$;

	-- calling Function 2 --
SELECT get_ratings_count();

----- One Trigger -----
	---- create a trigger that updates a manager's name when it changes, we also want to log the changes in a separate table ----

-- create new table when a manager's name changes --
CREATE TABLE manager_newname (
   manager_id INT NOT NULL,
   manager_name VARCHAR(100) NOT NULL,
   changed_on TIMESTAMP(6) NOT NULL
);


--function code--
CREATE OR REPLACE FUNCTION log_managername_changes()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
	IF NEW.manager_name <> OLD.manager_name THEN
		 INSERT INTO manager_newname(manager_id,manager_name,changed_on)
		 VALUES(OLD.manager_id,OLD.manager_name,now());
	END IF;

	RETURN NEW;
END;
$$

--bind the trigger function to the manager table--
CREATE TRIGGER managername_changes
  BEFORE UPDATE
  ON manager
  FOR EACH ROW
  EXECUTE PROCEDURE log_managername_changes();
  
 --demonstrate by inserting some values--
INSERT INTO manager (manager_id, manager_name)
VALUES ('06', 'Maggie Rogers');

INSERT INTO manager (manager_id, manager_name)
VALUES ('07', 'Patricia Gordon');

select * from manager

--update Maggie - her name changed--
UPDATE manager
SET manager_name = 'Maggie Vaccaro'
WHERE manager_id = 6;


select * from manager_newname;

----- One Stored Procedure - describe the purpose and function -----
-- create a procedure that adds a new sector -- 

CREATE PROCEDURE insert_sector(sector_id int, sector_name varchar(100))
LANGUAGE plpgsql
AS 
$$
BEGIN
	INSERT INTO sector(sector_id, sector_name)
	VALUES(sector_id, sector_name);
END;
$$

-- call the procedure -- 
CALL insert_sector('15', 'Travel');
select * from users
	

--------------- SQL DML -----------------
----- insert data into the database - need 5 inserts per table ------
----- insert into users table -----
INSERT INTO users (user_id)
VALUES ('10');

INSERT INTO users (user_id)
VALUES ('20');

INSERT INTO users (user_id)
VALUES ('30');

INSERT INTO users (user_id)
VALUES ('40');

INSERT INTO users (user_id)
VALUES ('50');

INSERT INTO users (user_id, company_id, company_name)
VALUES ('70', '940', 'Google');


----- insert into ratings table -----
INSERT INTO ratings (rating_id, career_mobility_rating, mgr_involve_rating, communication_rating, satisfaction_rating, dei_rating)
VALUES ('123', '5', '8', '9', '2', '6');

INSERT INTO ratings (rating_id, career_mobility_rating, mgr_involve_rating, communication_rating, satisfaction_rating, dei_rating)
VALUES ('234', '7', '7', '10', '8', '6');

INSERT INTO ratings (rating_id, career_mobility_rating, mgr_involve_rating, communication_rating, satisfaction_rating, dei_rating)
VALUES ('345', '5', '6', '6', '3', '4');

INSERT INTO ratings (rating_id, career_mobility_rating, mgr_involve_rating, communication_rating, satisfaction_rating, dei_rating)
VALUES ('456', '10', '9', '9', '10', '7');

INSERT INTO ratings (rating_id, career_mobility_rating, mgr_involve_rating, communication_rating, satisfaction_rating, dei_rating)
VALUES ('567', '4', '5', '6', '4', '6');

----- insert into reviews table -----
INSERT INTO reviews (review_id, review)
VALUES ('99', 'Great boss');

INSERT INTO reviews (review_id, review)
VALUES ('88', 'Tough boss');

INSERT INTO reviews (review_id, review)
VALUES ('77', 'Cares about career mobility');

INSERT INTO reviews (review_id, review)
VALUES ('66', 'Good mentor');

INSERT INTO reviews (review_id, review)
VALUES ('55', 'Easy work');

----- insert into manager table -----
INSERT INTO manager (manager_id, manager_name)
VALUES ('01', 'Tim Smith');

INSERT INTO manager (manager_id, manager_name)
VALUES ('02', 'Jackie Anne');

INSERT INTO manager (manager_id, manager_name)
VALUES ('03', 'Bobby Andrews');

INSERT INTO manager (manager_id, manager_name)
VALUES ('04', 'Pooja Thianagaran');

INSERT INTO manager (manager_id, manager_name)
VALUES ('05', 'Matt Connors');

----- insert into jobTitle table -----
INSERT INTO jobTitle (job_id, job_title)
VALUES ('444', 'Accountant');

INSERT INTO jobTitle (job_id, job_title)
VALUES ('333', 'IT Consultant');

INSERT INTO jobTitle (job_id, job_title)
VALUES ('222', 'Software Engineer');

INSERT INTO jobTitle (job_id, job_title)
VALUES ('111', 'Data Architect');

INSERT INTO jobTitle (job_id, job_title)
VALUES ('555', 'Data Analyst');

----- insert into department table -----
INSERT INTO department (dept_id, dept_name)
VALUES ('12345', 'Tax Accounting');

INSERT INTO department (dept_id, dept_name)
VALUES ('54312', 'IT Consulting');

INSERT INTO department (dept_id, dept_name)
VALUES ('56789', 'HR Technology');

INSERT INTO department (dept_id, dept_name)
VALUES ('98765', 'Data and Analytics');

INSERT INTO department (dept_id, dept_name)
VALUES ('14235', 'Data and Analytics');

----- insert into sector table -----
INSERT INTO sector (sector_id, sector_name)
VALUES ('87', 'Accounting');

INSERT INTO sector (sector_id, sector_name)
VALUES ('38', 'Consulting');

INSERT INTO sector (sector_id, sector_name)
VALUES ('43', 'Technology');

INSERT INTO sector (sector_id, sector_name)
VALUES ('95', 'Automative');

INSERT INTO sector (sector_id, sector_name)
VALUES ('14', 'Medicine');

----- insert into company table -----
INSERT INTO company (company_id, company_name)
VALUES ('468', 'EY');

INSERT INTO company (company_id, company_name)
VALUES ('186', 'Accenture');

INSERT INTO company (company_id, company_name)
VALUES ('940', 'Google');

INSERT INTO company (company_id, company_name)
VALUES ('824', 'Ford');

INSERT INTO company (company_id, company_name)
VALUES ('101', 'St Judes');

----- demonstrate update operations - 1 each per table -----

----- update ratings table -----
UPDATE ratings SET satisfaction_rating = '10' WHERE rating_id = 123;

----- update company table -----
UPDATE company SET company_name = 'PwC' WHERE company_id = 468;

----- update users table -----
UPDATE users SET user_id = 65 WHERE user_id = 50;

----- update department table -----
UPDATE department SET dept_name = 'HR Tech Systems' WHERE dept_id = 56789;

----- update jobtitle table -----
UPDATE jobtitle SET job_title = 'Developer' WHERE job_id = 222;

----- update manager table -----
UPDATE manager SET manager_name = 'Bobbi Andrews' WHERE manager_id = 3;

----- update reviews table -----
UPDATE reviews SET review = 'Best mentor I ever had' WHERE review_id = 66;

----- update sector table -----
UPDATE sector SET sector_name = 'Automotive' WHERE sector_id = 95;


----- demonstrate delete operations - 1 each per table-----
----- delete from company table -----
DELETE FROM company WHERE company_id = 468;

----- delete from department table -----
DELETE FROM department WHERE dept_id = 14235;

----- delete from jobtitle table -----
DELETE FROM jobtitle WHERE job_id = 111;

----- delete from manager table -----
DELETE FROM manager WHERE manager_id = 2;

----- delete from ratings table -----
DELETE FROM ratings WHERE rating_id = 345;

----- delete from reviews table -----
DELETE FROM reviews WHERE review_id = 55;

----- delete from sector table -----
DELETE FROM sector WHERE sector_id = 14;

----- delete from users table -----
DELETE FROM users WHERE user_id = 30;



----- Construct at least 8 SQL queries that incorporate SQL DML statements (ex: "show all items purchase by") in English + business value -----
SELECT company.company_id, company.company_name, users.user_id
FROM company
INNER JOIN
	users ON company.company_name = users.company_name;


-- Query 1: join manager and ratings table to find managers that have a career mobility rating higher than 5--
SELECT ratings.rating_id, ratings.career_mobility_rating, manager.manager_id, manager.manager_name
FROM ratings
INNER JOIN
	manager ON ratings.rating_id = manager.rating_id

WHERE ratings.career_mobility_rating > 5;


-- Query 2: Find the average rating of all managers - join managers and rating --
SELECT
	ratings.rating_id,
	manager.manager_name,
	AVG ((ratings.career_mobility_rating + ratings.dei_rating + ratings.mgr_involve_rating + 
		 ratings.communication_rating + ratings.satisfaction_rating) / 5)::INTEGER
FROM
	ratings
INNER JOIN manager USING(rating_id)
GROUP BY
	ratings.rating_id, manager.manager_name
ORDER BY
	manager.manager_name;


-- Query 3: display cases in which users have completed a rating but not a review --
SELECT DISTINCT users.user_id, users.review_id, users.ratings_id
FROM users, reviews, ratings
WHERE users.ratings_id IS NOT NULL AND users.review_id IS NULL;


-- Query 4: Count how many reviews we have for company id 940 --
SELECT COUNT(reviews.review_id)
FROM users, reviews
WHERE users.company_id = 940
AND users.review_id IS NOT NULL;


-- Query 5: Find all managers that have the lowest dei rating --
SELECT ratings.rating_id, ratings.dei_rating, manager.manager_id, manager.manager_name
FROM ratings
INNER JOIN
	manager ON ratings.rating_id = manager.rating_id

WHERE ratings.dei_rating = (SELECT MIN(ratings.dei_rating) FROM ratings);



-- Query 6 - Show the manager with the lowest average overall rating -- 
SELECT
	ratings.rating_id,
	manager.manager_name,
	AVG ((ratings.career_mobility_rating + ratings.dei_rating + ratings.mgr_involve_rating + 
		 ratings.communication_rating + ratings.satisfaction_rating) / 5)::INTEGER
FROM
	ratings
INNER JOIN manager USING(rating_id)
GROUP BY
	ratings.rating_id, manager.manager_name
ORDER BY AVG ASC LIMIT 1;

-- Query 7 - list the company names we have ratings for in the Technology Sector -- 
SELECT company.company_name, sector.sector_name,
  manager.company_id,
  manager.rating_id,
  company.sector_id,
  ratings.rating_id  
FROM manager
JOIN ratings
  ON manager.rating_id = ratings.rating_id
JOIN company
  ON manager.company_id = company.company_id
JOIN sector
	ON company.sector_id = sector.sector_id
WHERE sector.sector_id = 43;

-- Query 8 - finding positive or negative reviews based on key words -- 
SELECT reviews.review, reviews.review_id, manager.manager_name
FROM reviews
INNER JOIN manager ON reviews.review = manager.review
WHERE lower(reviews.review) like '%great%';
  

select * from users
























----- demonstrate query examples in plain English and SQL statements -----