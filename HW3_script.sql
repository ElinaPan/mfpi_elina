--Задание 1. Вывести распределение (количество) клиентов по сферам деятельности,
-- отсортировав результат по убыванию количества. — (1 балл)
select job_industry_category
    , count (customer_id) as client_count
from customer_20240101 c 
group by c.job_industry_category 
order by client_count desc

--Задание 2. Найти сумму транзакций за каждый месяц по сферам деятельности, 
--отсортировав по месяцам и по сфере деятельности. — (1 балл)

select date_trunc('month', t.transaction_date::date) as transaction_month
    , c.job_industry_category
    , sum(t.list_price) as transaction_sum
from transaction_20240101 t 
join customer_20240101 c on c.customer_id = t.customer_id
group by transaction_month, c.job_industry_category
order by transaction_month asc
    , transaction_sum  desc

--Задание 3. Вывести количество онлайн-заказов для всех брендов в рамках подтвержденных заказов
-- клиентов из сферы IT. — (1 балл)

select 
    t.brand
    , count(t.transaction_id) as online_order_count
from transaction_20240101 t 
join customer_20240101 c on c.customer_id = t.customer_id 
where t.order_status = 'Approved' and t.online_order = 'True' 
    and c.job_industry_category = 'IT' and t.brand <> ''
group by t.brand
order by online_order_count desc

-- Задание 4. Найти по всем клиентам сумму всех транзакций (list_price), максимум, минимум и количество транзакций, 
--отсортировав результат по убыванию суммы транзакций и количества клиентов. 
--Выполните двумя способами: используя только group by и используя только оконные функции. 
Сравните результат. — (2 балла)
-- КОММЕНТАРИЙ. Не очень понятно в задании как сортировать по количеству клиентов, если у нас группировка по клиентам
-- предполагаю, что это надо понимать как количество транзакций
-- только group by
select
    customer_id
    , sum(list_price) as total_transaction
    , count (*) as transaction_count
    , min (list_price) as min_transaction
    , max (list_price) as max_transaction
from transaction_20240101
group by customer_id
order by total_transaction desc,
     transaction_count desc

-- только оконные функции
select customer_id
   , sum(list_price) over (partition by customer_id) as total_transaction
   , count(*) over (partition by customer_id) as transaction_count
   , max(list_price) over (partition by customer_id) as max_transaction
   , min(list_price) over (partition by customer_id) as min_transaction
from transaction_20240101
order by total_transaction desc,
     transaction_count desc   

--Сравнение результатов. GROUP BY возвращает одну строку для каждого клиента. Данные агрегируются, 
--и исходные строки не сохраняются. Оконные функций возвращает все строки, но с добавленными агрегатными значениями.
--Необходим DISTINCT, чтобы убрать дубликаты, чтобы был результат, аналогичный GROUP BY. В данном случае DISTINCT 
-- не добавляю, чтобы была наглядно видна разница в работе двух подходов.

--Задание 5. Найти имена и фамилии клиентов с минимальной/максимальной суммой транзакций за весь период
-- (сумма транзакций не может быть null). Напишите отдельные запросы для минимальной и максимальной суммы. — (2 балла)
--КОММЕНТАРИЙ. В данном задании составим запрос через подзапрос
-- Запрос для макисмальной суммы 
select c.customer_id
    , c. first_name
    , c. last_name
    , total_transaction
from customer_20240101 c 
join 
    (select t.customer_id
        , sum(t.list_price) as total_transaction
     from transaction_20240101 t 
     where t.list_price is not NULL
     group by t.customer_id  
    ) ct on c.customer_id = ct.customer_id
where ct.total_transaction = (select max(total_transaction) 
							  from (select sum(t.list_price) as total_transaction
                              from transaction_20240101 t 
                              where t.list_price is not NULL
                              group by t.customer_id  )) 
                              
-- Запрос для минимальной суммы                             
select c.customer_id
    , first_name
    , last_name
    , total_transaction 
from customer_20240101 c 
join (select t.customer_id,
              sum(list_price) as total_transaction
          from transaction_20240101 t
          where t.list_price is not NULL
          group by customer_id) ct
on c.customer_id = ct.customer_id 
where ct.total_transaction = (select min(total_transaction)
                              from (select sum(t.list_price) as total_transaction
                              from transaction_20240101 t 
                              where t.list_price is not NULL
                              group by t.customer_id))

                         
-- Задание 6. Вывести только самые первые транзакции клиентов. Решить с помощью оконных функций. — (1 балл)

 with ranked_transaction as (
     select customer_id
         , transaction_id
         , transaction_date
         , list_price
         , row_number() over (partition by customer_id order by transaction_date) as transaction_rank
     from transaction_20240101 t)
 select customer_id
     , transaction_id
     , transaction_date
     , list_price
 from ranked_transaction 
where transaction_rank = 1

--Задание 7. Вывести имена, фамилии и профессии клиентов, между транзакциями которых был максимальный интервал
-- (интервал вычисляется в днях) — (2 балла).

with transaction_date as (
    select customer_id
    , transaction_date::date as transaction_date
    , lag(transaction_date::date) over (partition by customer_id order by transaction_date::date) as previous_transaction_date
    from transaction_20240101 t),

transaction_intervals as (
    select customer_id
    , transaction_date
    , previous_transaction_date 
    , (transaction_date - previous_transaction_date) as interval
    from transaction_date
    where previous_transaction_date is not null),
    
maximum_interval as(
    select customer_id
        , max(interval) as max_interval 
    from transaction_intervals
    group by customer_id
    order by max_interval desc), 
    
global_max_interval as (
   select MAX(max_interval) AS global_max_interval
    FROM maximum_interval
)

select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.job_title,
    mi.max_interval
from customer_20240101 c
join maximum_interval mi on c.customer_id = mi.customer_id
cross join global_max_interval gmi
where mi.max_interval = gmi.global_max_interval
order by mi.max_interval desc;

    
   