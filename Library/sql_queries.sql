SELECT * FROM books;
SELECT * FROM employees;
SELECT * FROM branch;
SELECT * FROM members;
SELECT * FROM issued_status;
SELECT * FROM return_status;

-- Project Task

-- Task 1. Create a New Book Record 
-- "('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101'


-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT issued_emp_id, issued_book_name FROM issued_status
WHERE issued_emp_id = 'E101'

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT issued_emp_id, COUNT(issued_id) AS tot_issued_books FROM issued_status
Group by issued_emp_id
HAVING COUNT(issued_id) > 1
ORDER BY tot_issued_books

-- CTAS [create table as a select stm]
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE book_cnt
AS
SELECT isbn, b.book_title, 
		COUNT(b.book_title)
FROM books b
JOIN issued_status ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1,2;

SELECT * FROM book_cnt;

-- Task 7. Retrieve All Books in a Specific Category:
SELECT category, book_title FROM books
WHERE category = 'Classic'

-- Task 8: Find Total Rental Income by Category:
SELECT category, 
		SUM(rental_price) AS tot_rental, 
		COUNT(*) AS count
FROM books
GROUP BY category
ORDER BY tot_rental DESC;

-- Task 9: List Members Who Registered in the Last 180 Days:
-- right now ther is no data is added in last 180 days so it will not show output
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 DAYS';

-- task 10 List Employees with Their Branch Manager's Name and their branch details:
SELECT b.branch_id, e.emp_id, e.emp_name, 
	   b.manager_id, 
	   e1.emp_name AS manager_name 
FROM employees e
JOIN branch b
ON b.branch_id = e.branch_id
JOIN employees e1
ON e1.emp_id  = b.manager_id

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:
CREATE TABLE books_price_more_than_7usd
AS
SELECT * FROM books
WHERE rental_price > 7

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT DISTINCT ist.issued_book_name FROM issued_status ist
LEFT JOIN return_status rst
ON ist.issued_id = rst.issued_id
WHERE rst.return_id IS NULL

--ADVANCED QUERIES
SELECT * FROM books;
SELECT * FROM employees;
SELECT * FROM branch;
SELECT * FROM members;
SELECT * FROM issued_status;
SELECT * FROM return_status;

/*
Task 13: 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

-- issued_status == members == books == return_status
-- filter books which is return
-- overdue > 30 

SELECT m.member_id, m.member_name,
	   ist.issued_date,
	   b.book_title,
	   CURRENT_DATE - ist.issued_date AS overdue_days
	FROM 
	issued_status ist
JOIN members m 
ON m.member_id = ist.issued_member_id
JOIN books b
ON b.isbn = ist.issued_book_isbn
left JOIN return_status rst
ON rst.issued_id = ist.issued_id
WHERE 
	rst.return_date IS  NULL
	AND
	(CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1

/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-451-52994-2';

SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-451-52994-2';

-- 1. Manually updating record
SELECT * FROM return_status
WHERE issued_id = 'IS130'; -- NOT RETURNED YET

INSERT INTO return_status (return_id, issued_id, return_date)
VALUES ('RS125', 'IS130', CURRENT_DATE) --UPDATE STATUS AS RETURNED

UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-451-52994-2';

-- 2. Stored procedures
CREATE OR REPLACE PROCEDURE add_return_record(p_return_id VARCHAR(30), p_issued_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
	v_isbn VARCHAR(50);
	v_book_name VARCHAR(80);

BEGIN
	-- logic
	-- inserting into return based on users input
	INSERT INTO return_status (return_id , issued_id, return_date)
	VALUES 
	(p_return_id, p_issued_id, CURRENT_DATE);

	SELECT 
		issued_book_isbn,
		issued_book_name
		INTO 
		v_isbn,
		v_book_name
	FROM issued_status
	WHERE issued_id = p_issued_id;

	UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn;

	--PRINT MESSAGE
	RAISE NOTICE 'Thank you so much for returning the book: %', v_book_name;
END;
$$

-- issued_id = IS135
-- ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

CALL add_return_record('RS120', 'IS135');

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/
SELECT * FROM books;
SELECT * FROM employees;
SELECT * FROM branch;
SELECT * FROM issued_status;
SELECT * FROM return_status;

CREATE TABLE branch_report
AS
	SELECT b.branch_id,
		   b.manager_id,
		   COUNT(ist.issued_id) AS isuued_books,
		   COUNT(rst.return_id) AS returned_books,
		   SUM(bk.rental_price) AS tot_revenue
	FROM issued_status as ist
	JOIN employees as e
	ON ist.issued_emp_id = e.emp_id
	JOIN branch as b
	ON b.branch_id = e.branch_id
	JOIN books as bk
	ON bk.isbn = ist.issued_book_isbn
	LEFT JOIN return_status as rst
	ON rst.issued_id = ist.issued_id
	GROUP BY 1,2
	ORDER BY tot_revenue DESC;

SELECT * FROM branch_report

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

CREATE TABLE active_members
AS
	SELECT * FROM members
	WHERE member_id IN(
						SELECT issued_member_id
						FROM issued_status
						WHERE issued_date >= CURRENT_DATE - INTERVAL '2 MONTH'
					   )
	;

SELECT * FROM active_members

SELECT CURRENT_DATE - INTERVAL '1 YEAR'

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, and their branch.

SELECT emp_name, 
	b.*,
	COUNT(ist.issued_id) AS tot_books_issued
	FROM issued_status AS ist
JOIN employees AS e
ON e.emp_id = ist.issued_emp_id
JOIN branch AS b
ON b.branch_id = e.branch_id
GROUP BY 1,2
ORDER BY tot_books_issued DESC LIMIT 3

/*Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.*/


/*
Task 19: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 

The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/

SELECT * FROM books;

SELECT * FROM issued_status;

CREATE OR REPLACE PROCEDURE issued_book(p_issued_id VARCHAR(30), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(30))
LANGUAGE plpgsql
AS $$

DECLARE
v_status VARCHAR(30);
BEGIN
		SELECT status 
		FROM books
			INTO
			v_status
		WHERE isbn = p_issued_book_isbn;

		IF v_status = 'yes' THEN
			INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
			VALUES(p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);
			
			UPDATE books
			SET status = 'no'
			WHERE isbn = p_issued_book_isbn;

			RAISE NOTICE 'Book records added successfully with isbn %', p_issued_book_isbn;

		ELSE

			RAISE NOTICE 'Sorry ! the book you have requested is unavailable book_isbn %', p_issued_book_isbn;

		END IF;
END;
$$

CALL issued_book('IS159', 'C108', '978-0-14-118776-1', 'E104');
CALL issued_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-14-118776-1'

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'