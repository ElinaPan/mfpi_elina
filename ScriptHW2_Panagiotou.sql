create table customer_20240101 (
customer_id int
,first_name varchar(50)
,last_name varchar(50)
,gender varchar(30)
,DOB varchar(50)
,job_title varchar(50)
,job_industry_category varchar(50)
,wealth_segment varchar(50)
,deceased_indicator varchar(50)
,owns_car varchar(30)
,address varchar(50)
,postcode varchar(30)
,state varchar(50)
,country varchar(30)
,property_valuation int
)

create table transaction_20240101(
transaction_id int
,product_id int
,customer_id int
,transaction_date varchar(30)
,online_order varchar(30)
,order_status varchar(30)
,brand varchar(30)
,product_line varchar(30)
,product_class varchar(30)
,product_size varchar(30)
,list_price float
,standard_cost float 
)

--Запрос 1. Вывести все уникальные бренды, 
--у которых стандартная стоимость выше 1500 долларов.
select distinct brand
from transaction_20240101 t 
where t.standard_cost >1500

-- Запрос 2. Вывести все подтвержденные транзакции за период 
--'2017-04-01' по '2017-04-09' включительно.
select t.transaction_id , t.transaction_date,t.order_status 
from transaction_20240101 t 
where t.transaction_date::date between '2017-04-01' and '2017-04-09'
and t.order_status = 'Approved'
order by t.transaction_date 

--Запрос 3. Вывести все профессии у клиентов из сферы IT 
--или Financial Services, которые начинаются с фразы 'Senior'.
select 
    distinct job_title
    ,job_industry_category
from customer_20240101 c 
where (c.job_industry_category = 'IT' or 
    c.job_industry_category = 'Financial Services') and 
    c.job_title like 'Senior%'

--Запрос 4. Вывести все бренды, которые закупают клиенты, работающие в сфере Financial Services
select distinct brand
    , c.job_industry_category 
from transaction_20240101 t 
join customer_20240101 c on t.customer_id = c.customer_id 
where job_industry_category = 'Financial Services'

--Запрос 5. Вывести 10 клиентов, которые оформили онлайн-заказ продукции из брендов 
--'Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles'.
select distinct t.customer_id
from transaction_20240101 t 
join customer_20240101 c on t.customer_id = c.customer_id 
where t.brand in ('Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles')
limit 10

--Запрос 6. Вывести всех клиентов, у которых нет транзакций.
select c.customer_id, first_name, last_name, t.transaction_id
from customer_20240101 c 
left join transaction_20240101 t on c.customer_id = t.customer_id 
where t.transaction_id is null

--Запрос 7. Вывести всех клиентов из IT, у которых транзакции 
--с максимальной стандартной стоимостью.
select distinct c.customer_id
    , first_name
    , last_name 
    , t.standard_cost 
from customer_20240101 c 
join transaction_20240101 t on c.customer_id = t.customer_id
where c.job_industry_category = 'IT'
and t.standard_cost = (
select max(t2.standard_cost)
from transaction_20240101 t2)

--Запрос 8. Вывести всех клиентов из сферы IT и Health, у которых есть подтвержденные транзакции 
--за период '2017-07-07' по '2017-07-17'.
-- в задании нет слова "включительно", поэтому исключаем дату окончания периода 
select distinct c.customer_id
from customer_20240101 c 
join transaction_20240101 t on c.customer_id = t.customer_id 
where job_industry_category in ('IT', 'Health') 
    and t.order_status = 'Approved' 
    and t.transaction_date::date >= '2017-07-07' and t.transaction_date::date < '2017-07-17'