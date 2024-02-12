USE film_rental;
/*1.What is the total revenue generated from all rentals in the database? */
SELECT * FROM payment;
SELECT sum(amount) AS Total_Revenue FROM payment;
/*(Total_revenue is 67406.56)*/

/*2.How many rentals were made in each month_name?*/
SELECT * FROM rental;
SELECT DATE_FORMAT(rental_date, '%M') AS month_name,COUNT(*) AS rental_count FROM rental
GROUP BY  month_name ;
/* output Total rows are 5* and the highest rental in the month of july*/

/*3.What is the rental rate of the film with the longest title in the database? */
SELECT * FROM film;
SELECT rental_rate,title,(length(title)) AS Longest_title_length FROM film GROUP BY 1,2 ORDER BY 3 DESC LIMIT 1 ;
/* rental rate is 2.99 and name is ARACHNOPHOBIA ROLLERCOASTER length is 27*/


-- 4. What is the average rental rate for films that were taken from the last 30 days from the date("2005-05-05 22:04:30")?
SELECT avg(a.rental_rate) Avg_rental_rate FROM film a 
JOIN inventory b ON b.film_id = a.film_id 
JOIN rental c ON c.inventory_id = b.inventory_id
JOIN payment d ON d.rental_id = c.rental_id WHERE c.rental_date BETWEEN DATE_SUB("2005-05-05 22:04:30",INTERVAL 30 DAY) AND ("2005-06-05 22:04:30");
/* Avg rental is 2.931176*/

/*5. What is the most popular category of films in terms of the number of rentals?*/
SELECT c.name AS Category_name,count(p.rental_id) AS number_of_rentals FROM inventory i JOIN film f ON f.film_id = i.film_id 
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN film_category fc ON fc.film_id = f.film_id 
JOIN category c ON c.category_id = fc.category_id  
JOIN payment p ON p.rental_id = r.rental_id GROUP BY 1 ORDER BY 2 DESC;
/* most popular category is sports with 1179*/

/*6. Find the longest movie duration from the list of films that have not been rented by any customer*/
SELECT f.title AS Movie_title,max(f.length) AS Movie_length FROM film f LEFT JOIN inventory i ON i.film_id = f.film_id 
LEFT JOIN rental r ON r.inventory_id = i.inventory_id 
LEFT JOIN customer c ON c.customer_id = r.customer_id WHERE c.customer_id IS NULL GROUP BY 1 ORDER BY 2 DESC;
/* longest movie is 'CRYSTAL BREAKING' with duration of  '184'*/


/*7. What is the average rental rate for films, broken down by category?*/
SELECT c.name, avg(rental_rate) AS average_rate FROM film f JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON fc.category_id = c.category_id GROUP BY 1 ORDER BY 2 DESC;
/* Games is the  more avg Rate with 3.23*/

/*8. What is the total revenue generated from rentals for each actor in the database?*/
SELECT concat_ws('  ',a.first_name,a.last_name) AS Actor_name,sum(p.amount) AS Total_revenue FROM actor a JOIN film_actor fc ON fc.actor_id = a.actor_id
JOIN inventory i ON i.film_id = fc.film_id  
JOIN rental r ON r.inventory_id = i.inventory_id 
JOIN payment p ON p.rental_id = r.rental_id GROUP BY 1 ;
/* output rows are 199 and the highest actor is 'PENELOPE  GUINESS' with revenue '1230.94'*/

/*9. Show all the actresses who worked in a film having a "Wrestler" in the description*/
SELECT  DISTINCT concat_ws('  ',a.first_name,a.last_name) AS Name from film f JOIN film_actor fa ON fa.film_id = f.film_id 
JOIN actor a ON a.actor_id = fa.actor_id WHERE f.description LIKE "%Wrestler%" GROUP BY 1;
/* output rows are 183*/

/*10. Which customers have rented the same film more than once*/
SELECT concat(c.first_name,"  ",c.last_name) AS cust_name,f.film_id,count(*) AS Count FROM customer c JOIN rental r ON r.customer_id = c.customer_id
JOIN payment p on p.rental_id = r.rental_id JOIN inventory i ON i.inventory_id = r.inventory_id  JOIN film f ON f.film_id = i.film_id 
GROUP BY 1,2 HAVING count>1  ORDER BY 2 DESC;
/*output rows are 212 */

/*11. How many films in the comedy category have a rental rate higher than the average rental rate? */
SELECT c.name,count(*) AS Films_with_comedy_category FROM film f JOIN film_category fc ON fc.film_id = f.film_id 
JOIN category c ON c.category_id = fc.category_id 
WHERE c.name = "Comedy" AND f.rental_rate > (select avg(rental_rate) FROM film) GROUP BY 1;
/* Total rental rate of comedy is 42*/

/* 12. Which films have been rented the most by customers living in each city? */
SELECT ci.city, f.title, count(r.rental_id) AS rental_count FROM rental r JOIN inventory i ON r.inventory_id = i.inventory_id 
JOIN film f ON i.film_id = f.film_id JOIN customer c ON r.customer_id = c.customer_id 
JOIN address a ON c.address_id = a.address_id 
JOIN city ci ON a.city_id = ci.city_id GROUP BY 1,2 ORDER BY 3 DESC;

/*13. What is the total amount spent by customers whose rental payments exceed $200? (3 Marks)*/
SELECT concat(c.first_name," ",c.last_name) AS customer_name,p.customer_id,sum(p.amount) AS Total FROM payment p 
JOIN customer c ON c.customer_id = p.customer_id GROUP BY 1,2 HAVING Total>200;
/*  2 customers spent above $200 for rental 'KARL SEAL' and 'ELEANOR HUNT'*/


-- 14. Display the fields which are having foreign key constraints related to the "rental" table. [Hint: using Information_schema] (2 Marks)
select * from rental;
SELECT column_name,constraint_name,referenced_table_name,referenced_column_name FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE table_name = 'rental' AND constraint_name <> 'PRIMARY';

 /*15. Create a View for the total revenue generated by each staff member, broken down by store city with the country name. (4 Marks)*/
CREATE VIEW staff_revenue AS 
(SELECT a.staff_id,concat(b.first_name," ",b.last_name) AS staff_name,d.city,e.country,sum(a.amount) AS Total_revenue FROM payment a 
JOIN staff b ON b.staff_id = a.staff_id 
JOIN address c ON c.address_id = b.address_id 
JOIN city d ON d.city_id = c.city_id 
JOIN country e ON e.country_id = d.country_id GROUP BY  1,2,3);

SELECT * FROM staff_revenue;

/*16. Create a view based on rental information consisting of visiting_day, customer_name, the title of the film, 
no_of_rental_days, the amount paid by the customer along with the percentage of customer spending. (4 Marks)*/
CREATE VIEW rental_information AS
(SELECT day(a.rental_date) AS day,dayname(a.rental_date) AS Dayname,concat(b.first_name," ",b.last_name) AS Name_of_Customer,d.title AS Film_title,
datediff(a.return_date,a.rental_date) AS no_of_rental_days,
e.amount,(e.amount/(SELECT sum(amount) FROM payment WHERE customer_id = b.customer_id))*100 AS percentage_customer_spending FROM rental a
JOIN customer b ON b.customer_id = a.customer_id
JOIN inventory c ON c.inventory_id = a.inventory_id
JOIN film d ON d.film_id = c.film_id
JOIN payment e ON e.rental_id = a.rental_id);

SELECT * FROM rental_information;

/*17. Display the customers who paid 50% of their total rental costs within one day.*/
SELECT concat(a.first_name," ",a.last_name) AS customer_name FROM customer a 
JOIN rental b ON b.customer_id = a.customer_id
JOIN (SELECT c.rental_id,sum(c.amount) AS Total_rental_amount FROM payment c GROUP BY c.rental_id) c ON c.rental_id = b.rental_id
JOIN inventory d ON d.inventory_id = b.inventory_id
JOIN film e ON e.film_id = d.film_id
JOIN payment f ON f.rental_id = c.rental_id
WHERE (c.Total_rental_amount)>=(e.rental_rate)/2 AND datediff(f.payment_date,b.rental_date)<=1 GROUP BY 1;






   




