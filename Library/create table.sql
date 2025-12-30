--create db
CREATE DATABASE library_management;

--create branch table
CREATE TABLE branch(
		branch_id VARCHAR(20) PRIMARY KEY,
		manager_id VARCHAR(50),	
		branch_address VARCHAR(50),	
		contact_no VARCHAR(50)
);

--create branch table
CREATE TABLE employees(
		emp_id VARCHAR(10) PRIMARY KEY,	
		emp_name VARCHAR(25),	
		position VARCHAR(25),	
		salary	INT,
		branch_id VARCHAR(20)
);

--create table books
CREATE TABLE books(
		isbn VARCHAR(25) PRIMARY KEY,	
		book_title VARCHAR(100),	
		category VARCHAR(25),	
		rental_price FLOAT,	
		status	VARCHAR(10),
		author VARCHAR(50),	
		publisher VARCHAR(50)
);

--create table members
CREATE TABLE members(
member_id VARCHAR(30) PRIMARY KEY,	
member_name VARCHAR(30),	
member_address VARCHAR(30),	
reg_date DATE
);

--create table issued_status
CREATE TABLE issued_status(
		issued_id VARCHAR(10) PRIMARY KEY,	
		issued_member_id VARCHAR(10),	--fk
		issued_book_name VARCHAR(70),	
		issued_date	DATE,
		issued_book_isbn VARCHAR(50),	--fk
		issued_emp_id VARCHAR(10)		--fk
);

--create table return_status
CREATE TABLE return_status(
		return_id VARCHAR(30) PRIMARY KEY,
		issued_id VARCHAR(30),	
		return_book_name VARCHAR(70),	
		return_date	DATE,
		return_book_isbn VARCHAR(20)
);

--FOREIGN KEY CONSTANT
ALTER TABLE issued_status
ADD CONSTRAINT fk_members 
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books 
FOREIGN KEY (issued_book_isbn)
REFERENCES books(is);





