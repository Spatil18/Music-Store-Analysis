select * from album
select * from artist
select * from customer
select * from employee
select * from genre
select * from invoice
select * from invoice_line
select * from media_type
select * from playlist
select * from playlist_track
select * from track



-- senior most employee based on job title
select *  from employee
order by levels desc
limit 1



-- countries have the most Invoices
select count(*), billing_country 
from invoice 
group by billing_country
order by count desc
limit 1



-- Top 3 values of invoices
select total from invoice
order by total desc
limit 3



-- city that has the best customers?
select count(*), city from customer 
group by city 
order by count(*) desc



-- One city that has the highest sum of invoice totals.
select sum(total) as total, billing_city from invoice 
group by billing_city
order by total desc
limit 1



-- Best customer 
-- The customer who has spent the most money will be will be declare the best customer.
-- A query that returns the person who has spent the most money.
select * from invoice
select * from customer

select customer.customer_id, first_name, last_name, sum(total)
from customer join invoice 
on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by sum(total) desc
limit 1



-- A query to return the email, first name, last name, & genre of all Rock Music listeners. 
-- Ordered alphabetically by email starting with A.
select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id IN(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
	)
order by email;



-- Let's invite the artists who have written the most rock music in our dataset.
-- A query that returns the Artist name and total track count of the top 10 rock bands.
select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track 
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10



-- All the track names that have a song length longer than the average song length. 
-- The name and milliseconds for each track. 
-- Order by the song length with the longest songs listed first
select name, milliseconds from track
where milliseconds > (select avg(milliseconds) as avg_track_length from track)
order by milliseconds desc;



-- Find how much amount spent by customer on artist? 
-- A query to return customer name, artist name and total spent
with best_selling_artist as (
	select artist.artist_id As artist_id, artist.name as artist_name,
	sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id= invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 1
	)
	
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;



-- Most popular music genre for each country. 
-- we determine the most popular genre as the genre with the highest amount of purchases.
-- A query that returns each country along with the top genre. 
-- For countries where the maximum number of purchases is shared return all Genres.
with popular_genre as
(
	select count(invoice_line.quantity) as purchase, customer.country, genre.name, genre.genre_id,
	row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as RowNo
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where RowNo <= 1



-- A query that determines the customer that has spent the most on music for each country.
-- A query that returns  the country along with the top customer and how much they spent.
-- for countries where the top amount spent is shared, provide all customers who spent this amount.
with recursive
	customer_with_country as (
		select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending
		from invoice
		join customer on customer.customer_id = invoice.customer_id
		group by 1, 2, 3, 4
		order by 1, 5 desc),
		
	country_max_spending as(
		select billing_country, max(total_spending) as max_spending
		from customer_with_country
		group by billing_country)
	
select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1;