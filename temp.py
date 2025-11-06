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
