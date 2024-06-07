/*Eassy
Q1: Who is the senior most employee based on job title? */


SELECT 
    first_name, 
    title, 
    levels 
FROM 
    employee 
ORDER BY 
    levels DESC 
LIMIT 1;

/* Q2: Which countries have the most Invoices? */

SELECT 
    COUNT(invoice_id) AS num_invoices, 
    billing_country 
FROM 
    invoice 
GROUP BY 
    billing_country 
ORDER BY 
    num_invoices DESC;


/* Q3: What are top 3 values of total invoice? */
SELECT 
    total, 
    customer_id 
FROM 
    invoice 
ORDER BY 
    total DESC 
LIMIT 3;


/*Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT 
    SUM(total) AS t, 
    billing_city 
FROM 
    invoice
GROUP BY 
    billing_city
ORDER BY 
    t DESC;



/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT 
    c.first_name, 
    c.last_name, 
    SUM(i.total) AS t, 
    c.customer_id 
FROM 
    customer AS c
JOIN 
    invoice AS i ON c.customer_id = i.customer_id 
GROUP BY 
    c.customer_id, c.first_name, c.last_name
ORDER BY 
    t DESC;




/*moderate
Q6 Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT 
    customer.email, 
    customer.first_name, 
    customer.last_name, 
    genre.name AS genre_name 
FROM 
    customer
JOIN 
    invoice ON invoice.customer_id = customer.customer_id
JOIN 
    invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN 
    track ON track.track_id = invoice_line.track_id
JOIN 
    genre ON track.genre_id = genre.genre_id
WHERE 
    genre.name LIKE 'Rock'
ORDER BY 
    customer.email;



/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT 
    artist.name, 
    artist.artist_id, 
    COUNT(track.track_id) AS t 
FROM 
    artist
JOIN 
    album ON artist.artist_id = album.artist_id
JOIN 
    track ON album.album_id = track.album_id
JOIN 
    genre ON genre.genre_id = track.genre_id
WHERE 
    genre.name LIKE 'Rock'
GROUP BY 
    artist.artist_id, artist.name
ORDER BY 
    t DESC
LIMIT 10;

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
	
select track.name, milliseconds from track
	where milliseconds >( select avg(milliseconds) from track) 
	order by milliseconds desc
	
	;
	
	
	
	
/*Hard 
Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

-- Find the amount spent by each customer on the best-selling artist
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    best_selling.artist_name, 
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM 
    customer AS c
JOIN 
    invoice AS i ON c.customer_id = i.customer_id
JOIN 
    invoice_line AS il ON i.invoice_id = il.invoice_id
JOIN 
    track AS t ON il.track_id = t.track_id
JOIN 
    album AS alb ON t.album_id = alb.album_id
JOIN 
    artist AS a ON alb.artist_id = a.artist_id
JOIN (
    -- Subquery to find the best-selling artist
    SELECT 
        artist.artist_id, 
        artist.name AS artist_name, 
        SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM 
        invoice_line
    JOIN 
        track ON track.track_id = invoice_line.track_id
    JOIN 
        album ON album.album_id = track.album_id
    JOIN 
        artist ON artist.artist_id = album.artist_id
    GROUP BY 
        artist.artist_id, artist.name
    ORDER BY 
        total_sales DESC
    LIMIT 1
) AS best_selling ON best_selling.artist_id = a.artist_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name, best_selling.artist_name
ORDER BY 
    amount_spent DESC;

/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS 
(
    SELECT 
        COUNT(invoice_line.quantity) AS purchases, 
        customer.country, 
        genre.name AS genre_name, 
        genre.genre_id, 
        ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM 
        invoice_line 
    JOIN 
        invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN 
        customer ON customer.customer_id = invoice.customer_id
    JOIN 
        track ON track.track_id = invoice_line.track_id
    JOIN 
        genre ON genre.genre_id = track.genre_id
    GROUP BY 
        customer.country, genre.name, genre.genre_id
)
SELECT 
    country, 
    genre_name, 
    purchases 
FROM 
    popular_genre 
WHERE 
    RowNo = 1;


/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH Customer_with_country AS (
    SELECT 
        customer.customer_id,
	first_name,last_name,
	invoice.billing_country,
	SUM(total) AS total_spending,
        SUM(invoice.total) AS total_spend,
        ROW_NUMBER() OVER(PARTITION BY invoice.billing_country ORDER BY SUM(invoice.total) DESC) AS RowNo 
    FROM 
        invoice
    JOIN 
        customer ON customer.customer_id = invoice.customer_id
    GROUP BY 
        customer.customer_id,
        customer.first_name,
        customer.last_name,
        invoice.billing_country
)
SELECT 
    customer_id,
    first_name,
    last_name,
    billing_country,
    total_spend
FROM 
    Customer_with_country 
WHERE 
    RowNo = 1;




















































