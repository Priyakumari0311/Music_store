				SET - 1(EASY)
1. Who is the senior most employee based on job title

SELECT *FROM employee
ORDER BY levels DESC
limit 1;

2. Which countries have the most invoices

SELECT count(total) AS TOTAL , billing_country 
FROM invoice
GROUP BY billing_country 
ORDER BY total DESC
LIMIT 1

3. What are the top 3 values of total invoice

SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3

4. Which city has the best customers? 
We would like to throw a promotional music festival
in the city we made the most money.
Write a query that returns one city that 
has the highest sum of invoice totals.
Return both the city name and sum of all invoice totals

SELECT billing_city , sum(total) invoice_total
from invoice
group by billing_city
order by invoice_total desc

5. Who is the best customer?
The customer who has spent the most money
will be declared the best customer.
Write a query that returns the person 
who has spent the most money.

select t1.customer_id , t1.first_name , t1.last_name , sum(t2.total) as invoice_total
from customer as t1
join invoice as t2
on t1.customer_id = t2.customer_id
group by t1.customer_id
order by invoice_total desc
limit 1

			SET-2(MEDIUM)
			
1. Write query to return the email , first name , last name,
and genre of all rock music listeners.
Return your list ordered alphabetically 
by email starting with A.

SELECT DISTINCT email , t1.first_name , t1.last_name  
from customer as t1
join invoice as t2
on t1.customer_id = t2.customer_id
join invoice_line as t3
on t2.invoice_id = t3.invoice_id
join Track as t4
on t3.Track_id = t4.Track_id
join Genre as t5
on t4.genre_id = t5.genre_id
where t5.name like 'Rock'
order by email

2.Lets invite the artists who have written the
most rock music in our dataset .
Write a query that return that artist name 
and total track count of the top 10 rock bands.

SELECT T3.name ,T3.artist_id, count(T3.artist_id) AS number_of_songs
FROM track as T1
JOIN album as T2
on T1.album_id = T2.album_id
JOIN artist as T3
ON T3.artist_id = T2.artist_id
JOIN genre as T4
ON T4.genre_id = T1.genre_id
WHERE T4.name = 'Rock'
GROUP BY T3.artist_id
ORDER BY number_of_songs DESC
limit 10

3. Return all the track names that have a song
length longer than the avergae song length.
Return the Name and Miliseconds for each track
Order by the song length with the longest song liste first

select name , AVG(milliseconds) as avg_length
FROM track
WHERE milliseconds >(
SELECT AVG(milliseconds) from track)
GROUP BY name
ORDER BY avg_length DESC

			Set-3(Advance)
			
1. Find how much amount spent by each customer on artist?
Write a query to return customer name ,
artist name and total spent.

WITH best_selling_artist AS (
    SELECT 
        t6.artist_id, 
        t6.name,
        SUM(t3.unit_price * t3.quantity) AS total_sales
    FROM invoice_line AS t3
    JOIN track AS t4 ON t4.track_id = t3.track_id
    JOIN album AS t5 ON t5.album_id = t4.album_id
    JOIN artist AS t6 ON t6.artist_id = t5.artist_id
    GROUP BY 1
    ORDER BY total_sales DESC
    LIMIT 1
)

SELECT 
	t1.customer_id,
    t1.first_name, 
    t1.last_name, 
    bsa.name AS artist_name,
    SUM(t3.unit_price * t3.quantity) AS total_spent
FROM customer AS t1
JOIN invoice AS t2 
ON t1.customer_id = t2.customer_id
JOIN invoice_line AS t3
ON t3.invoice_id = t2.invoice_id
JOIN track AS t4 
ON t4.track_id = t3.track_id
JOIN album AS t5 
ON t5.album_id = t4.album_id
JOIN best_selling_artist AS bsa 
ON bsa.artist_id = t5.artist_id
GROUP BY 
    t1.customer_id,
    t1.first_name, 
    t1.last_name, 
    bsa.name
    
ORDER BY total_spent DESC;

2. We want to find out the most popular
music genre for each country.
We determine the most popular genre as the genre
with the highest amount of purchase.
Write a query that returns each country
along with the top genre.
For countries where the maximum number
of purchase is shared return all genres.


with popular_genre AS(
  SELECT
  	c.country,
	gen.name,
	gen.genre_id,
	sum(il.quantity) as purchase_quantity,
	RANK() OVER (partition by c.country order by sum(il.quantity)desc) as genre_rank
	from invoice_line as il
	join invoice as i
	on il.invoice_id = i.invoice_id
	join customer as c
	on c.customer_id = i.customer_id
	join track as t
	on t.track_id = il.track_id
	join genre as gen
	on gen.genre_id = t.genre_id
	group by c.country , gen.name , gen.genre_id
	order by 4 desc
	
	
)

select * from popular_genre
	where genre_rank =1
	order by country, name;
 
3.Write a query that determines the customer that
has spent the most on music for each country.
Write a query that returns the country along with the top
customer and how much they spent.
For countries where the top amount spent is shared ,
provide all customers who spent this amount.

with customer_with_country as(
	select c.customer_id , c.first_name, c.last_name , i.billing_country , 
	sum(total) as total_spending , 
	row_number() over(partition by i.billing_country order by sum(i.total) desc) as RowNo
	from invoice as i
	join customer as c
	on c.customer_id = i.customer_id
	group by 1,2,3,4
	order by 4 asc ,5 desc
)
select *from customer_with_country
where RowNo <=1;
	









