
--WELCOME TO SHRESTHA S BHARADWAJ's DATA EXPLORATION OF ZOMATO USER PROJECT.

--Dataset creation:-

drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017'),
(4,'01-22-2021');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014'),
(4,'01-22-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3),
(4,'01-22-2016',3),
(4,'04-22-2020',2),
(4,'10-22-2021',1);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

--**************SHRESTHA S BHARADWAJ's DATA EXPLORATION OF ZOMATO USER PROJECT.******************************************

--Data Analysis:

--1] Total Amount Spent by each user on zomato:

select a.userid, sum( b.price) TotalAmt from sales a,product b where a.product_id=b.product_id group by a.userid;


--2] How many days has each customer/user visited zomato?
SELECT userid, COUNT(distinct created_date) Distinct_days FROM sales GROUP BY userid;


--3]what was the first product purchased by each customer/user?
select * from sales where created_date=ANY(select min(created_date) from sales group by userid);
--or
select * from( select *, RANK() over (partition by userid order by created_date)rnk from sales) a where rnk=1;


--4]Count of prod purch by each user 
select userid, count(product_id) cnt_of_prod from sales group by userid order by count(product_id) desc

--and Most purchased Item 
select top 1 product_id from sales group by product_id  order by count(product_id) desc

--and number of times Most purchased Item is purchased by all user:-
select userid, count(product_id) cnt_of_Most_purc_prod from sales where product_id=(select top 1 product_id from sales group by product_id  order by count(product_id) desc)group by userid;


--**************SHRESTHA S BHARADWAJ's DATA EXPLORATION OF ZOMATO USER PROJECT.******************************************


--5]Most purch item by each user:-
select * from
( select *, RANK() over (partition by userid order by cnt_of_prod desc )rnk from
(select userid, product_id, count(product_id) cnt_of_prod from sales group by userid,product_id)a)b
where rnk=1

--Rank of each product purchased by each customer
select *, RANK() over (partition by userid order by cnt_of_prod desc )rnk from
(select userid, product_id, count(product_id) cnt_of_prod from sales group by userid,product_id)a
 order by userid,rnk

 --or
 select userid, product_id, RANK() over (partition by userid order by cnt_of_prod desc )rnk from
(select userid, product_id, count(product_id) cnt_of_prod from sales group by userid,product_id)a
 order by userid,rnk 

 --6] first item bought after becoming gold member
select * from( select c.*, RANK() over (partition by userid order by created_date )rnk from
 (select a.userid, a.product_id,a.created_date, b.gold_signup_date from sales a inner join goldusers_signup b 
 on a.userid=b.userid and created_date>=gold_signup_date)c )d where rnk=1


--**************SHRESTHA S BHARADWAJ's DATA EXPLORATION OF ZOMATO USER PROJECT.******************************************


 --7]item purch just before becoming gold member
select * from( select c.*, RANK() over (partition by userid order by created_date desc )rnk from
 (select a.userid, a.product_id,a.created_date, b.gold_signup_date from sales a inner join goldusers_signup b 
 on a.userid=b.userid and created_date<gold_signup_date)c )d where rnk=1


 --8] total orders and amount spent by user before becoming gold member
select userid, count(created_date),sum(price) from
(select c.*,d.price from 
(select a.userid, a.product_id,a.created_date, b.gold_signup_date
from sales a inner join goldusers_signup b 
 on a.userid=b.userid and created_date<gold_signup_date)c inner join product d 
 on c.product_id=d.product_id)e group by userid;

 --or 

 select userid, count(created_date),sum(d.price) from
(select a.userid, a.product_id,a.created_date, b.gold_signup_date from 
sales a inner join goldusers_signup b on a.userid=b.userid and created_date<gold_signup_date
)c inner join product d 
 on c.product_id=d.product_id  group by userid;

 --9]if buying each prod generates points for eg., 2.5rs=1zp and each prod has diff 
 --purchasing points for eg,.for p1 5rups- 1 zomato point,p2 10rs=5zp, p3 5rs=1zp....
 --CALCULATE points collected by each user 
  select userid,sum(Totalpoints)*2.5 TP from
  ( select e.*,amt/points Totalpoints from
 (select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
 (select userid,b.product_id,sum(price) amt from sales a  inner join  product b  
 on a.product_id=b.product_id group by userid,b.product_id)d)e)h group  by userid;
 --or
  select userid,sum(amt/points)*2.5  TP from
 (select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
 (select userid,b.product_id,sum(price) amt from sales a  inner join  product b  
 on a.product_id=b.product_id group by userid,b.product_id)d)e group  by userid;

  --wh prod has been given most points till now.
   select TOP 1 product_id,sum(TP)*2.5 TP  from
   (select e.*,amt/points TP from
 (select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
 (select userid,b.product_id,sum(price) amt from sales a  inner join  product b  
 on a.product_id=b.product_id group by userid,b.product_id)d)e)h group  by  product_id order by TP desc ;


 --CALCULATE points collected by each product
  select  product_id,sum(TP)*2.5  TP from
   (select e.*,amt/points TP from
 (select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
 (select userid,b.product_id,sum(price) amt from sales a  inner join  product b  
 on a.product_id=b.product_id group by userid,b.product_id)d)e)h group  by  product_id ;

  --wh prod has been given LEAST points till now.
 select top 1 product_id, sum(TP)*2.5 TP from
   (select e.*,amt/points TP from
 (select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
 (select userid,b.product_id,sum(price) amt from sales a  inner join  product b  
 on a.product_id=b.product_id group by userid,b.product_id)d)e)h group  by  product_id order by TP asc 

 
--**************SHRESTHA S BHARADWAJ's DATA EXPLORATION OF ZOMATO USER PROJECT.******************************************


 --10]In the first yr of gold program irrespective of what gold memeber has 
 --purchased he gets 5 zp for every 10rs spent. What was their points
 --earned in their first yr?

 select c.*,d.price*.5 tp from 
(select a.userid, a.product_id,a.created_date, b.gold_signup_date
from sales a inner join goldusers_signup b 
 on a.userid=b.userid and created_date>=gold_signup_date and created_date<=Dateadd(year,1,gold_signup_date))c inner join product d 
 on c.product_id=d.product_id

--Who earned more? 
 select top 1  c.*,d.price*.5 tp from 
(select a.userid, a.product_id,a.created_date, b.gold_signup_date
from sales a inner join goldusers_signup b 
 on a.userid=b.userid and created_date>=gold_signup_date and created_date<=Dateadd(year,1,gold_signup_date))c inner join product d 
 on c.product_id=d.product_id order by tp desc

 --11] rnk all transaction of all users.

 select * ,rank() over(partition by userid order by created_date) rnk from sales

 --12]rank all transaction of only gold memebers and na for non gold ones
  select e.*, case when rnk=0 then 'NA' else rnk end as rnkk from
  (select c.*,cast((case when gold_signup_date is null then 0 else rank() over(partition by userid order by created_date desc) end) as varchar) as rnk from
 (select a.userid, a.product_id,a.created_date, b.gold_signup_date
from sales a left join goldusers_signup b 
 on a.userid=b.userid and created_date>=gold_signup_date)c)e;

 
--**************SHRESTHA S BHARADWAJ's DATA EXPLORATION OF ZOMATO USER PROJECT.******************************************