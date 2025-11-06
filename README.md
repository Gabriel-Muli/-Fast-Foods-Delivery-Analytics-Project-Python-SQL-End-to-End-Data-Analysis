# 🍔 Fast Foods Delivery Analytics Project — Python & SQL End-to-End Data Analysis

### 🧠 Overview
This project simulates a **food delivery business** (similar to UberEats or Glovo) using **Python for data generation** and **MySQL for business analytics**.  
It demonstrates skills in **data engineering, SQL analytics, and business intelligence**.

---

### 🧰 Tech Stack
- **Programming:** Python (Pandas, Faker, Faker-Food, Random, Datetime)
- **Database:** MySQL 8.0
- **Tools:**  Pycharm / MySQL Workbench

---

### 📊 Project Workflow

#### **1️⃣ Data Generation (Python)**
Synthetic datasets are created using the `faker` library:
| File | Description | Records |
|------|--------------|----------|
| `customers.csv` | Customer names & registration dates | 3,000 |
| `riders.csv` | Rider names & registration dates | 70 |
| `restaurants.csv` | Restaurant details & opening hours | 30 |
| `orders.csv` | Customer orders (with items, dates, times, and totals) | 9,000 |
| `deliveries.csv` | Delivery data linked to orders & riders | 8,500 |

💡 Each dataset is saved as a CSV file and later imported into MySQL for querying.

---

#### **2️⃣ Database Setup (SQL)**
A normalized MySQL database called `fast_foods_db` is created with five related tables:
- `customers`
- `riders`
- `restaurants`
- `orders`
- `deliveries`

Tables includes **primary** and **foreign keys** to maintain referential integrity.  
Data is loaded into MySQL using the `LOAD DATA INFILE` command.

![Entity Relationship Diagram](https://github.com/Gabriel-Muli/-Fast-Foods-Delivery-Analytics-Project-Python-SQL-End-to-End-Data-Analysis/blob/main/erd.png)

---

#### **3️⃣ Business Analysis (SQL Queries)**

20 business questions are answered using SQL — covering customer behavior, restaurant performance, and delivery analytics.

| # | Business Question | Insight Type |
|---|--------------------|--------------|
| 1 | Top 4 foods ordered by a specific customer | Customer Preferences |
| 2 | Time slots with most orders (2-hour intervals) | Peak Activity |
| 3 | Average Order Value (AOV) > $30 | High-Value Customers |
| 4 | Customers who spent > $100 | Loyalty Analysis |
| 5 | Undelivered orders per restaurant | Operational Efficiency |
| 6 | Rank restaurants by revenue per city | Market Share |
| 7 | Most popular dish in each city | Product Insights |
| 8 | Customers active in 2024 but not 2025 | Churn Detection |
| 9 | Compare cancellation rate (2024 vs 2025) | Service Quality |
| 10 | Average delivery time per rider | Rider Performance |
| 11 | Monthly delivery growth per restaurant | Growth Analytics |
| 12 | Customer segmentation (Gold vs Silver) | Customer Value Segmentation |
| 13 | Rider monthly earnings (10% commission) | Payroll Estimation |
| 14 | Rider star rating by delivery time | Performance Scoring |
| 15 | Peak order day of the week | Demand Planning |
| 16 | Customer lifetime value (CLV) | Retention Insight |
| 17 | Month-over-month sales trend | Financial Trend |
| 18 | Riders with fastest/slowest average delivery | Efficiency Benchmark |
| 19 | Seasonal food trends | Menu Seasonality |
| 20 | City revenue ranking for 2022 | Regional Performance |

---

### 📈 Example Insights
- 🕐 **Peak ordering time:** 6:00–8:00 AM  
- 🍕 **Most popular item:** chicken wings,Chicken Fajitas and Chicken milanese topped in multiple cities  
- 💰 **Top customers:** 'gold'(customers whose total spending exceeds average order value) customers have generated a revenue of $112,935.2. Also 90 customers have spent a total of over $100 each
- 🚴‍♂️ **Fastest rider:** Average delivery < 10 hours  
- 🌆 **Top city by revenue:** Varies yearly, showing changing market trends. Christinefort lead in 2022 with the highest overall 
- ⚠️ **Churn rate:** 806 customers from 2024 didn’t return in 2025  

---

## 🐍 Python Code — Data Generation

Below is the Python script I used to generate synthetic datasets for the analysis.  
It creates five cleaned CSV files: `customers.csv`, `riders.csv`, `restaurants.csv`, `orders.csv`, and `deliveries.csv`.

```python
#Creation of the customers.csv
import pandas as pd
import random
import datetime
from faker import Faker

start_date=datetime.date(2020,1,1)
end_date=datetime.date.today()
date_range=(end_date - start_date).days
origin=Faker('en_US')
data=[]
for i in range(1,3001):
    customers={
        'customer_name':origin.name(),
        'reg_date':(start_date+datetime.timedelta(days=random.randint(0,date_range))).strftime("%Y-%m-%d"),
    }
    data.append(customers)
df=pd.DataFrame(data)
df.to_csv('customers.csv',index=False)
print('The max length of characters in the customer name column is: ',df['customer_name'].map(len).max())

print('\n')
#Creation of the riders.csv

data_0=[]
for i in range(1,71):
    riders={
        'rider_name':origin.name(),
        'reg_date':(start_date+datetime.timedelta(days=random.randint(0,date_range))).strftime("%Y-%m-%d"),
    }
    data_0.append(riders)
df=pd.DataFrame(data_0)
df.to_csv('riders.csv',index=False)
print('The max length of characters in the rider name column is: ',df['rider_name'].map(len).max())

print('\n')
#Creation of the restaurants.csv

def random_time(start_hour,end_hour):
    hour=random.randint(start_hour,end_hour)
    minute=random.choice([0,30])
    return datetime.datetime(2020,1,1,hour,minute).strftime("%I:%M%p")

def opening_Hours():
    if random.random()<0.7:
        open_time=random_time(8,10)
        close_time=random_time(16,18)
        return f'{open_time}-{close_time}'
    else:
        open_time_1=random_time(8,10)
        close_time_1=random_time(16,18)
        open_time_2=random_time(18,20)
        close_time_2=random_time(22,23)
        return f'{open_time_1}-{close_time_1}, {open_time_2}-{close_time_2}'

data_1=[]
for i in range(1,31):
    restaurants={
        'restaurant_name': origin.name(),
        'restaurant_city': origin.city(),
        'opening_hours': opening_Hours()
    }
    data_1.append(restaurants)
df=pd.DataFrame(data_1)
df.to_csv('restaurants.csv',index=False)
print('The max length of characters in the restaurant_city column is: ',df['restaurant_name'].map(len).max())
print('The max length of characters in the restaurant_city column is: ',df['restaurant_city'].map(len).max())
print('The max length of characters in the opening_hours column is: ',df['opening_hours'].map(len).max())

print('\n')
#Creation of the orders.csv

from faker_food import FoodProvider
fake=Faker()
fake.add_provider(FoodProvider)

start_date_1=datetime.date(2020,1,1)
end_date_1=datetime.date.today()
date_range_1=(end_date_1 - start_date_1).days
data_2=[]

def food_pricing():
    number=random.choices(range(1,6),weights=[0.5,0.2,0.15,0.1,0.05])[0]
    food = [fake.dish() for i in range(number)]
    base_price=0

    for i in food:
        if any(i in i.lower() for i in  ['soup','salad']):
            base_price+=round(random.uniform(4,9),2)
        elif any(word in i.lower() for word in ['burger', 'sandwich', 'wrap']):
            base_price+=round(random.uniform(6, 12), 2)
        elif any(word in i.lower() for word in ['pizza', 'pasta', 'noodle']):
            base_price+=round(random.uniform(8, 15), 2)
        elif any(word in i.lower() for word in ['steak', 'chicken', 'beef', 'fish', 'shrimp']):
            base_price+=round(random.uniform(10, 25), 2)
        else:
            base_price +=round(random.uniform(5, 20), 2)
    return ','.join(food),round(base_price,2)

def ordering_time(start_hour=6,end_hour=23):
    start_time=datetime.datetime(2020,1,1,start_hour)
    end_time=datetime.datetime(2020,1,1,end_hour)
    diff=end_time-start_time
    random_sec=random.randint(0,int(diff.total_seconds()))
    order_time=(start_time+datetime.timedelta(seconds=random_sec)).strftime('%H:%M:%S')
    return order_time

for i in range(1,9001):
    Food,Price=food_pricing()
    orders={
    'order_id':i,
    'customer_id':random.randint(1,3000),
    'restaurant_id':random.choice(range(1,31)),
    'order_item':Food,
    'order_date':(start_date_1+datetime.timedelta(days=random.randint(0,date_range_1))).strftime("%Y-%m-%d"),
    'order_time':ordering_time(),
    'order_status':random.choices(['completed','pending','cancelled'],weights=[0.8,0.15,0.05])[0],
    'total_amount':Price
    }
    data_2.append(orders)
df=pd.DataFrame(data_2)
df.to_csv('orders.csv',index=False,encoding='utf-8')
print('The max length of characters in the order_item column is: ',df['order_item'].map(len).max())
print('The max length of characters in the order_status column is: ',df['order_status'].map(len).max())

print('\n')
#Creation of the deliveries.csv

orders=pd.read_csv('orders.csv')

def Delivery_time(order,status):
    order_time=datetime.datetime.strptime(order['order_time'],'%H:%M:%S')
    if status=='Delivered':
       delivery_time= order_time + datetime.timedelta(hours=random.randint(0, 5))
    else:
        return None
    return delivery_time.strftime('%H:%M:%S')

data_3=[]
for i in range(1,8500):
    order=orders.sample().iloc[0]
    status=random.choices(['Delivered','In transit','Failed'],weights=[0.8,0.15,0.05])[0]

    deliveries={
    'order_id':order['order_id'],
    'delivery_status':status,
    'delivery_time':Delivery_time(order,status),
    'rider_id':random.choice(range(1,71))
    }
    data_3.append(deliveries)
df=pd.DataFrame(data_3)
df.to_csv('deliveries.csv',index=False)
```

## 🧮 SQL Code — Database Setup and Business Analysis
Below is the SQL script I used to create the relational database, load the generated datasets, and perform analytical queries to extract key business insights on customers, restaurants, and riders.  
**Note:** All the cvs files were imported using MySQL workbench import wizard except the 'deliveries.csv' because of the null values it had.

```sql
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
		dense_rank() over(partition by restaurant_city order by count(order_item_new) desc) as rank_per_city
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
```
---

👩🏽‍💻 **Author:** Gabriel Mwema  
📧 **Email**: ianmuli5419@gmail.com  
🌐 [LinkedIn](https://www.linkedin.com/in/gabriel-mwema-7ab4b6262/)




