drop database if exists fast_foods_db;
create database fast_foods_db;
use fast_foods_db;

drop table if exists riders;
create table riders(
rider_id INT AUTO_INCREMENT PRIMARY KEY,
rider_name VARCHAR(20),
reg_date DATE
);

drop table if exists restaurants;
create table restaurants(
restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
restaurant_name	VARCHAR(30),
restaurant_city	VARCHAR(30),
opening_hours VARCHAR(40)
);

drop table if exists customers;
create table customers(
customer_id INT AUTO_INCREMENT PRIMARY KEY,
customer_name VARCHAR(30),
reg_date DATE
);

drop table if exists orders;
create table orders(
order_id INT PRIMARY KEY,
customer_id INT,
CONSTRAINT customer_fok FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
restaurant_id INT,
CONSTRAINT restaurant_fok FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
order_item	VARCHAR(150),
order_date DATE,
order_time TIME,
order_status VARCHAR(10),
total_amount FLOAT
);

drop table if exists deliveries;
create table deliveries(
delivery_id INT AUTO_INCREMENT PRIMARY KEY,
order_id INT,
CONSTRAINT order_fok FOREIGN KEY (order_id) REFERENCES orders(order_id),
delivery_status	VARCHAR(10),
delivery_time TIME,
rider_id INT,
CONSTRAINT rider_fok FOREIGN KEY (rider_id) REFERENCES riders(rider_id)
);

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/deliveries.csv'
into table deliveries
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines
(order_id,delivery_status,@delivery_time,rider_id)
set delivery_time=nullif(@delivery_time,'');

select*from riders;
select*from restaurants;
select*from customers;
select*from orders;
select*from deliveries;

-- solving business problems

-- 1)find the top 4 foods ordered by 'Samuel Gallegos' between 2020-2025
select
	c.customer_id,
    c.customer_name,
    order_item_new,
    count(*) as no_of_orders
from  customers as c 
join
orders as o
on c.customer_id=o.customer_id
join json_table(
	concat('["',replace(order_item,',','","'),'"]'),
    '$[*]' columns(order_item_new VARCHAR(50) PATH '$')
)as jt
where c.customer_name='Samuel Gallegos'
and order_date between '2020-01-01' and '2025-12-31'
group by 1,2,3
order by no_of_orders desc
limit 4;

-- 2)identify the time slots during which most orders are placed based on 2hr intervals
select
	floor(hour(order_time)/2)*2 as start_time,
	floor(hour(order_time)/2)*2+2 as end_time,
    count(*) as no_of_orders
from orders
group by 1,2
order by 3 desc;

-- 3)what is the average order value per customer for customers with more than $30 order value 
select
	c.customer_id,
    c.customer_name,
    count(order_id) as no_of_orders,
	round(avg(total_amount),2) as AOV
from orders as o
join customers as c
on o.customer_id=c.customer_id
group by customer_id
having AOV>30
order by AOV desc;

-- --4) which customers have used more than $100 
select
	c.customer_id,
    c.customer_name,
    count(order_id) as no_of_orders,
    round(sum(total_amount),2)as total_amount_used
from customers as c
join orders as o
on c.customer_id=o.customer_id
group by 1,2
having total_amount_used>100
order by total_amount_used desc;

-- 5)Which orders have been placed and not delivered(find their restaurant name,city and no of undelivered orders per restaurant)
select
    o.restaurant_id,
    r.restaurant_name,
    r.restaurant_city,
    count(*) as total_undelivered
from orders as o 
join
deliveries as d
on o.order_id=d.order_id
join restaurants as r
on o.restaurant_id=r.restaurant_id
where delivery_time is null
group by 1,2,3
order by 4 desc;

-- 6)rank restaurants by their total revenue from last year to date per city
select
	o.restaurant_id,
    restaurant_name,
    restaurant_city,
    round(sum(o.total_amount),2) as total_revenue,
    rank() over(partition by restaurant_city order by sum(o.total_amount) desc) as rank_per_city
from restaurants as r
join
orders as o
on r.restaurant_id=o.restaurant_id
where order_date between '2024-01-01' and '2025-12-31'
group by 1,2,3;

-- 7)What is the most popular dish in each city
select*from
(
    select
		o.restaurant_id,
		r.restaurant_name,
		r.restaurant_city,
		order_item_new,
		count(order_item_new) as no_of_orders,
		rank() over(partition by restaurant_city order by count(order_item_new) desc) as rank_per_city
	from orders as o
	join
	restaurants as r
	on o.restaurant_id=r.restaurant_id
	join json_table(
	concat('["',replace(o.order_item,',','","'),'"]'),
	'$[*]' columns(order_item_new varchar(50) path '$')
	) as jt
	group by 1,2,3,4
) as temp
where rank_per_city=1;

-- 8) Find customers who placed orders in 2024 but not in 2025
select
	distinct customer_id
from orders
where year(order_date)=2024
and
customer_id not in
	(select distinct customer_id from orders
    where year(order_date)=2025);
    
-- 9) Calculate zand compare the order cancellation rate for each restaurant between the current and the previous year

with cancellation_2024 as 
(
select 
	restaurant_name,
    o.restaurant_id,
    count(order_id) as total_orders,
    count(case when order_status='cancelled' then 0 end) as cancelled_orders
from orders as o
join 
restaurants as r
on o.restaurant_id=r.restaurant_id
where year(order_date)=2024 
group by restaurant_name,restaurant_id
),

cancellation_2025 as
(
select 
	restaurant_name,
    o.restaurant_id,
    count(order_id) as total_orders,
    count(case when order_status='cancelled' then 0 end) as cancelled_orders
from orders as o
join 
restaurants as r
on o.restaurant_id=r.restaurant_id
where year(order_date)=2025
group by restaurant_name,restaurant_id
),

cancellation_rate_2024 as
(
select
	restaurant_id,
    restaurant_name,
    total_orders,
    cancelled_orders,
    (cancelled_orders/total_orders)*100 as cancellation_percentage_2024
from cancellation_2024),

cancellation_rate_2025 as
(
select
	restaurant_id,
    restaurant_name,
    total_orders,
    cancelled_orders,
    (cancelled_orders/total_orders)*100 as cancellation_percentage_2025
from cancellation_2025)

select
	q.restaurant_id,
	q.restaurant_name,
	round(cancellation_percentage_2024,2) as cancellation_percentage_2024 ,
    round(cancellation_percentage_2025,2) as cancellation_percentage_2025
from 
cancellation_rate_2024 as q
join 
cancellation_rate_2025 as w
on q.restaurant_id=w.restaurant_id;

-- 10)What is the average delivery time for each rider
select
	rider_id,
    avg(time_hr_diff) as avg_time_taken
from 
(
    select
		d.rider_id,
		o.order_time,
		d.delivery_time,
		case
			when delivery_time>order_time then 
				time_to_sec(timediff(delivery_time,order_time))/(60*60)
			else
				time_to_sec(timediff(addtime(delivery_time,'24:00:00'),order_time))/(60*60)
		end as time_hr_diff
	from orders as o
	join deliveries as d
	on o.order_id=d.order_id
	where delivery_status='delivered'
) as temp
group by rider_id
order by avg_time_taken;

-- 11) calculate each restaurants monthly growth ratio based on the total number of delivered orders
with lag_table as (
select*,
	lag(current_month_orders) over(partition by restaurant_id ) as previous_month_orders
from
(
    select
		o.restaurant_id,
		date_format(min(order_date),'%m-%Y') as mnth,
		count(o.order_id) as current_month_orders
	from orders as o
	join deliveries as d
	on o.order_id=d.order_id
	where delivery_status='delivered'
	group by restaurant_id,year(order_date),month(order_date)
	order by restaurant_id,year(order_date),month(order_date)
) as temp
)
select
	restaurant_id,
    mnth,
    previous_month_orders,
    current_month_orders,
    round(((current_month_orders-previous_month_orders)/previous_month_orders)*100,1) as growth_percentage
from lag_table;

/* 12) Segment customers as either 'gold' or 'silver'. If a customers total spending exceeds average order value(AOV) label them as 'gold'
    otherwise 'silver'
    Find each segment total number of orders and revenue*/
    
select
	segmentation,
    sum(total_orders) total_orders,
    round(sum(revenue),2) as revenue
from
(
		select
			c.customer_name,
			c.customer_id,
			count(o.order_id) total_orders,
			sum(o.total_amount) revenue,
			case
				when sum(o.total_amount)>(select avg(total_amount) from orders) then 'gold' else 'silver' 
			end as segmentation
		from orders as o
		join 
		customers as c
		on o.customer_id=c.customer_id
		group by customer_name,customer_id
) as temp
group by segmentation;
	
-- 13)Calculate each riders total monthly earning given they get 10% of the total amount

select
	d.rider_id,
    r.rider_name,
    any_value(date_format(o.order_date,'%m-%Y')) as month_year,
    round(sum(o.total_amount),2) as total_amount,
    round(sum(o.total_amount)*0.1,2) as rider_pay
from orders as o
join deliveries as d
on o.order_id=d.order_id
join riders as r
on d.rider_id=r.rider_id
group by rider_id,rider_name,year(order_date),month(order_date)
order by rider_id,year(order_date),month(order_date);

/* 14)Find the number of stars each rider has given that stars are awarded according to delivery time. If delivery is done within 6hrs,
6-8 hrs,8-10hrs,10-12hrs,>12hrs then 5,4,3,2,1 stars respectively */

with starring as
(
select*,	
	case
		when hrs_to_delivery <6 then '5 stars'
		when hrs_to_delivery >6 and hrs_to_delivery <8 then '4 stars'
		when hrs_to_delivery >8 and hrs_to_delivery <10 then '3 stars'
		when hrs_to_delivery>10 and hrs_to_delivery <12 then '2 stars'
		else '1 star'
    end as stars
from 
	(
		select
			d.rider_id,
			o.order_time,
			d.delivery_time,
			case
				when order_time>delivery_time then time_to_sec(timediff(addtime(delivery_time,'24:00:00'),order_time))/3600
				else time_to_sec(timediff(delivery_time,order_time))/3600
			end as hrs_to_delivery
		from orders as o
		join 
		deliveries as d
		on o.order_id=d.order_id
		where delivery_time is not null
	) as temp
)    
select
	rider_id,
    stars,
    count(*) as frequency
from starring
group by rider_id,stars
order by rider_id,stars;

-- 15) Find the order frequecy each day of the week and find the peak day for each restaurant 
select*from
	(
		select 
			o.restaurant_id,
			r.restaurant_name,
			date_format(order_date,'%W') weekday,
			count(order_id) no_of_orders,
			rank() over(partition by restaurant_id order by count(order_id) desc) ranking
			
		from orders as o 
		join 
		restaurants as r
		on o.restaurant_id=r.restaurant_id
		group by 1,2,3
	) as temp
where ranking=1;

-- 16) Find each customers lifetime value(total value generated)

select
	customer_id,
    round(sum(total_amount),2) as clv
from orders
group by 1
order by 2 desc;

-- 17) Identify sales trends for each restaurant by comparing each month total sales by the previous month
	
Select*,
	lag(current_month_sales) over(partition by restaurant_id) as previous_month_sales 
from (
    Select 
		restaurant_id,
		max(date_format(order_date,'%m-%Y')) as mnth,
		round(sum(total_amount),2) as current_month_sales
	from orders
	group by restaurant_id,year(order_date),month(order_date)
	order by restaurant_id, year(order_date),month(order_date)
	) as temp;
    
-- 18) Determine the average riders delivery time and determine riders with lowest and highest averages
with average_table as
(
Select
		d.rider_id,
		o.order_time,
		d.delivery_time,
		case
			when delivery_time> order_time then time_to_sec(timediff(delivery_time,order_time))/3600
			else time_to_sec(timediff(addtime(delivery_time,'24:00:00'),order_time))/3600
		end as time_taken
	from orders as o
	join 
	deliveries as d
	on o.order_id=d.order_id
	where delivery_status='delivered'
),

rider_table as
(
	select
		rider_id,
		avg(time_taken) as average_delivery_time
	from average_table
	group by rider_id
),

min_max_table as
(
	select*
	from rider_table
    where average_delivery_time=(select min(average_delivery_time) from rider_table)
    or average_delivery_time=(select max(average_delivery_time) from rider_table)
)
select*from min_max_table;

-- 19) Track the popularity of specific order items during yearly seasons and identify seasonal demand spikes
with month_table as
(
	select
		order_item,
		month(order_date) as mnth
	from orders
),

season_table as
(
	select*,
    case
		when mnth between 3 and 5 then 'spring'
        when mnth between 6 and 8 then 'summer'
        when mnth between 9 and 11 then 'fall'
        else 'winter'
	end as season
    from month_table
),

peak_table as
(
	select
		order_item,
        season,
        count(order_item) as frequency,
        dense_rank() over(partition by season order by  count(order_item) desc) as ranking
	from season_table
    group by 1,2
)
select *from peak_table
where ranking=1;

-- 20)rank each city based on the total revenue for 2022
select 	
	restaurant_city,
    count(order_id) as total_orders,
    round(sum(total_amount),2) as revenue,
    rank() over(order by sum(total_amount) desc) as ranking
from orders as o
join 
restaurants as r
on o.restaurant_id=r.restaurant_id
where year(order_date)=2022
group by restaurant_city;



