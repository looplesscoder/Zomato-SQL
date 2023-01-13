drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');
drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

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
(2,'09-10-2018',3);


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

--1) what is the total amount each customer spent on zomato
select s.userid ,sum(p.price) as total_amt_spent
from product p
join sales s on p.product_id = s.product_id
group by s.userid

--2) how many days each customer visited zomato ?
select userid ,count(distinct(created_date)) as no_of_times from sales 
group by userid

--3) which was the first product that was purchased by the customer 

select * from 
(select *,rank() over(partition by userid order by created_date )as rnk
from sales ) t1
where t1.rnk=1

--4)what is the most purchased item by the customer and how many times 
--was it purchased by the customer 
select product_id ,count(product_id)as cnt from sales group by product_id  
-- to find the product with most sales we use top 
select top 1 product_id from sales 
--here as we know that product_id(2) has highest count therefore above query will result in 2 

--to find the no.of times it was bought  
select userid,count(product_id) as cnt from sales where product_id in (
select top 1 product_id from sales )
group by(userid)

/*5) which item was most popular for each customer */
select * from sales
select * from
(select *, rank() over(partition by userid order by cnt desc) rnk from
(select userid ,product_id,count(product_id) cnt from sales group by userid, product_id)t1) t2
where rnk=1

--ADVANCED SQL CONCEPTS--
/*6) Which item was first purchased after they became a member?*/
select t2.* from (
select t1.*, rank() over(partition by userid order by created_date asc)rnk from (
select s.userid, s.created_date,s.product_id, gs.gold_signup_date 
from sales s
inner join goldusers_signup gs on gs.userid= s.userid and s.created_date> gs.gold_signup_date)t1)t2
where t2.rnk=1

/* 7) which item was purchased before it became a gold user member?*/
select t2.* from (
select t1.*, rank() over(partition by userid order by created_date desc)rnk from (
select s.userid, s.created_date,s.product_id, gs.gold_signup_date 
from sales s
inner join goldusers_signup gs on gs.userid= s.userid and s.created_date<=gs.gold_signup_date)t1)t2
where t2.rnk=1


/* 8) what is the total orders and the amount spent for each member before they became a member?*/
select userid,count(created_date) total_orders,sum(price)amt_spent from(
select t1.*, p.price from
(select s.userid, s.created_date,s.product_id, gs.gold_signup_date 
from sales s
inner join goldusers_signup gs on gs.userid= s.userid and s.created_date<=gs.gold_signup_date) t1
inner join product p on t1.product_id= p.product_id)t2
group by userid