
--------------------------soft_toys_3_int--------------------------------

select top 5 * from orders
select top 5 * from order_items 
select top 5 * from order_item_refunds
select top 5 * from products
select top 5 * from website_pageviews
select top 5 * from website_sessions
select top 5 * from website_360
select top 5 * from channel_360
select top 5 * from Orders_360
select top 5 * from Customer_360

alter table order_items
alter column order_id bigint

alter table products
alter column product_id int

alter table orders
alter column primary_product_id int


---------------------------------------------------Orders-----------------------------------------------------
----- ranging from 2012 to 2015
select min(year(created_at)),max(year(created_at)) from Orders


select * from orders---- 32,313 rows 

select * from( ---------------------------------No dulpication
select count(*) as orders_count from orders
group by website_session_id,[user_id],primary_product_id,items_purchased,price_usd,cogs_usd
)
as a 
where orders_count>1

select * from orders  -------------------------------No nulls 
where created_at is null or
website_session_id is null or [user_id] is null
or primary_product_id is null 
or items_purchased is null or price_usd is null
or cogs_usd  is null

alter table orders
add order_date date

update orders
set order_date = DATEFROMPARTS(year(created_at),month(created_at),Day(created_at))

alter table orders
add order_time time

update orders 
set order_time = Cast(created_at as time)

------ Rounding off price_usd 
Update orders
set price_usd = round(price_usd,2)

----- Rounding off cogs_usd
Update orders
set cogs_usd = round(cogs_usd,2)

select order_id,created_at from orders
where items_purchased = 1

select order_id,created_at from orders
where items_purchased = 2

----
select * from orders where order_id in(select order_id from orders
where items_purchased = 2)


-----------------------------------------------------order_items -----------------------------
----- ranging from 2012 to 2015
select min(year(created_at)),max(year(created_at)) from order_items

-------Total rows  --- 40,025 rows
select * from order_items

---Rounding off cogs_usd 
update order_items
set cogs_usd = round(cogs_usd,2)

---- Rounding off price_usd 
update order_items
set price_usd = round(price_usd,2)

------------No mismatch in time of orders and order_items created_at 
select * from order_items
join orders
on order_items.order_id = orders.order_id
where order_items.created_at= orders.created_at


select * from order_items  -------------------------------No nulls 
where created_at is null or
order_id is null or product_id is null
or is_primary_item is null 
or price_usd is null
or cogs_usd  is null

select * from( ---------------------------------No dulpication
select count(*) as orders_items_count from order_items
group by created_at,order_id,product_id,is_primary_item,price_usd,cogs_usd
)
as a 
where orders_items_count>1


------ Created a column order_item_date and order_item_time
alter table order_items
add order_item_date date

update order_items
set order_item_date = DATEFROMPARTS( year(created_at),month(created_at),day(created_at))

alter table order_items
add order_item_time time

update order_items
set order_item_time = cast(created_at as time)


--------------------No mismatch between both table orders and order items in terms of cogs and price_usd
;with order_items_numeric as (
select order_id,sum(price_usd) as order_items_price_usd ,
sum(cogs_usd) as order_items_cogs_usd
from order_items
group by order_id)

select orders.price_usd,order_items_numeric.order_items_price_usd,
orders.cogs_usd,order_items_numeric.order_items_cogs_usd
from orders
join order_items_numeric
on orders.order_id = order_items_numeric.order_id
where round(orders.price_usd,2)<>round(order_items_numeric.order_items_price_usd,2)
or round(orders.cogs_usd,2)<>round(order_items_numeric.order_items_cogs_usd,2)


----------------------------------------order_item_refunds ---------------------------
----- ranging from 2012 to 2015
select min(year(created_at)),max(year(created_at)) from order_item_refunds 

--Total_records 
select * from order_item_refunds ----- 1,731 rows
 
---No Nulls 
select * from order_item_refunds  ------------------------------- No nulls 
where created_at is null or
order_item_id is null or order_id is null
or refund_amount_usd is null 

----- No duplicates 
select * from( ---------------------------------No dulpication
select count(*) as orders_items_refund_count from order_item_refunds
group by created_at,order_id, order_item_id, refund_amount_usd
)
as a 
where orders_items_refund_count>1

select * from order_item_refunds

alter table order_item_refunds
add order_item_refund_date date

update order_item_refunds
set order_item_refund_date = DATEFROMPARTS( year(created_at),month(created_at),day(created_at))

alter table order_items
add order_item_time time

update order_items
set order_item_time = cast(created_at as time)


-------- How the data is distributed btw repeated order and order once 
--------the proprtion of primary item 
                                                               ----1----> 32,313
select count(*) as item_counts,is_primary_item                  ----0----> 7,712 
from order_item_refunds  
right join order_items
on order_item_refunds.order_id = order_items.order_id
and order_item_refunds.order_item_id = order_items.order_item_id
--where order_item_refunds.order_item_id<> order_item_refunds.order_id
group by is_primary_item


---------- One order can have multiple order items
select * from( --------------------7,712 rows
select count(order_item_id) as order_item_counts from order_items
group by order_id) as a
where order_item_counts>1


------ The order id of those orders which are  repeating 
select * from order_items where order_id in(
select order_id from( --------------------15,424 rows
select count(order_item_id) as order_item_counts,order_id from order_items
group by order_id) as a
where order_item_counts>1)


---------------------------------------------website pageviews ---------------------------
----- ranging from 2012 to 2015
select min(year(created_at)),max(year(created_at)) from website_pageviews 

select distinct website_session_id from website_pageviews   -----------------No Nulls 

select distinct pageview_url from website_pageviews

select top 5 * from website_pageviews

select * from( ---------------------------------No dulpication
select count(*) as website_pageviews_counts from website_pageviews
group by created_at,website_session_id, pageview_url
)
as a 
where website_pageviews_counts>1

select distinct pageview_url from website_pageviews ----- 16 pageviews are there 

---------------------------------------website_sessions---------------------
----Year ranging from 2012 to 2015 

select min(year(created_at)), max(year(created_at)) from website_sessions


select * from website_sessions  -------------------------------No nulls 
where created_at is null or
[user_id] is null or is_repeat_session is null
or utm_source is null 
or utm_campaign is null
or utm_content  is null or device_type is null 
or http_referer is null


--Update website_sessions
--------------------------------NULLS are there in text 
select distinct [user_id] from website_sessions
select distinct is_repeat_session from website_sessions 
select distinct utm_source from website_sessions
select distinct utm_campaign from website_sessions
select distinct utm_content from website_sessions
select distinct device_type from website_sessions
select distinct http_referer from website_sessions

select * from website_sessions
where utm_source = 'NULL'

update website_sessions --------------83328 rows affected 
set utm_source = 'not available'
where utm_source = 'NULL'

update website_sessions --------------83328 rows affected 
set utm_campaign = 'not available'
where utm_campaign = 'NULL'

update website_sessions --------------83328 rows affected 
set utm_content = 'not available'
where utm_content = 'NULL'

update website_sessions --------------39917 rows affected 
set http_referer = 'not available'
where http_referer = 'NULL'


select * from( ----------------------------------no duplicates
select count([user_id])as count_users,website_session_id from orders
where website_session_id<>[user_id] 
group by website_session_id)
as a 
where count_users>1

---------------------------updated the refund_amount_usd---------
update order_item_refunds
set refund_amount_usd = round(refund_amount_usd,2)


--------------------------One user can have multiple session ids 
select * from( --------------------591 rows 
select count(website_session_id)as count_website,[user_id] from orders
where website_session_id<>[user_id] 
group by [user_id])
as a 
where count_website>1

---------------------------------------------
-------------------## checking if the there is any discripancies btw tables fact and dimension

select * from orders
left join products
on orders.primary_product_id = products.product_id
where products.product_id is null

SELECT * from orders
left join website_sessions
  ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.website_session_id IS NULL;


select * from orders
left join order_items
on orders.order_id = order_items.order_id
where order_items.order_id is null

select * from orders
left join order_item_refunds
on orders.order_id = order_item_refunds.order_id
where order_item_refunds.order_id is null

select * from website_sessions
left join website_pageviews
on website_sessions.website_session_id = website_pageviews.website_session_id
where website_pageviews.website_session_id is null



-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

select top 5 * from orders
select top 5 * from order_items
select top 5* from products
select top 5 * from website_pageviews
select top 5 * from website_sessions
select top 5 * from order_item_refunds

------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------Orders360 Table--------------------------------------------------------
with order_master as
( select order_id,
created_at as Order_time,
website_session_id as Website_Session_id,
user_id as customer_id,
primary_product_id as main_product,
items_purchased as Number_of_items_purchased,
price_usd as Price,
cogs_usd as Cost,
price_usd - cogs_usd as Markup,
(price_usd - cogs_usd) *100.00 / cogs_usd as Markup_pct
from Orders
),


item_details as 
(
select order_id, 
SUM(Case when product_name = 'The Original Mr. Fuzzy' then 1 else 0 end) as The_Original_Mr_Fuzzy,
SUM( Case when  product_name = 'The Forever Love Bear' then 1 else 0 end) as The_Forever_Love_Bear,
SUM( Case when product_name = 'The Birthday Sugar Panda' then 1 else 0 end) as The_Birthday_Sugar_Panda,
SUM( Case when  product_name = 'The Hudson River Mini bear' then 1 else 0 end) as The_Hudson_River_Mini_bear
from order_items as oi
left join products as p
on oi.product_id  = p.product_id
group by order_id
),

refunded_count as 
( 
select o.order_id, 
SUM(Case When order_item_refund_id is NULL then 0 else 1 end) as refunded_items_count,
SUM(Case When refund_amount_usd is NULL then 0 else refund_amount_usd end) as Amt_Refunded
from orders as o
left join order_item_refunds as otr
on o.order_id = otr.order_id
group by o.order_id
),

refunded_products as (
SELECT
    o.order_id,
    MAX(CASE WHEN rp.product_id = 1 THEN 1 ELSE 0 END) AS Refunded_The_Original_Mr_Fuzzy,
    MAX(CASE WHEN rp.product_id = 2 THEN 1 ELSE 0 END) AS Refunded_The_Forever_Love_Bear,
    MAX(CASE WHEN rp.product_id = 3 THEN 1 ELSE 0 END) AS Refunded_The_Birthday_Sugar_Panda,
    MAX(CASE WHEN rp.product_id = 4 THEN 1 ELSE 0 END) AS Refunded_The_Hudson_River_Mini_bear
    

FROM orders o
LEFT JOIN (
    SELECT
        oi.order_id,
        oi.product_id
    FROM order_items oi
    INNER JOIN order_item_refunds r
        ON oi.order_item_id = r.order_item_id
    GROUP BY oi.order_id, oi.product_id
) rp
    ON o.order_id = rp.order_id
GROUP BY o.order_id
),


Ordering_time as
(
select order_id, datediff( minute ,ws.created_at, o.created_at) as Time_to_order from orders as o
left join website_sessions as ws
on o.website_session_id = ws.website_session_id
),



order_occasion as 
( select order_id,
Case When rnk =1 then 1 else 0 end as First_Order,
Case when rnk =2 then 1 else 0 end as Second_Order,
Case when rnk =3 then 1 else 0 end as Third_Order
from
(
select *,
Dense_rank() over(partition by user_id order by created_at asc ) as rnk
from orders
) as x
),


order_channels as
( 
select order_id,
    CASE
        WHEN ws.utm_source IS NOT NULL THEN 'Paid'
        ELSE 'Free'
    END AS channel_type,

CASE WHEN ws.utm_source IN ('gsearch','bsearch') THEN 'Paid Search'
        WHEN ws.utm_source = 'socialbook' THEN 'Paid Social'
        WHEN ws.utm_source IS NULL AND ws.http_referer LIKE '%gsearch%' THEN 'Organic Search'
        WHEN ws.utm_source IS NULL AND ws.http_referer LIKE '%bsearch%' THEN 'Organic Search'
        WHEN ws.utm_source IS NULL AND ws.http_referer LIKE '%socialbook%' THEN 'Organic Social'
        ELSE 'Direct'
        END AS channel_name,
        utm_source, utm_campaign, utm_content, device_type, http_referer
from orders as o
left join website_sessions as ws
on o.website_session_id = ws.website_session_id
),


pageviews as 
(
select o.website_session_id, 
Sum(Case when pageview_url= '/home' then 1 else 0 end) as Home_page_flag,
Sum(Case when pageview_url= '/lander-1' then 1 else 0 end) as Lander_1_page_flag,
Sum(Case when pageview_url= '/lander-2' then 1 else 0 end) as Lander_2_page_flag,
Sum(Case when pageview_url= '/lander-3' then 1 else 0 end) as Lander_3_page_flag,
Sum(Case when pageview_url= '/lander-4' then 1 else 0 end) as Lander_4_page_flag,
Sum(Case when pageview_url= '/lander-5' then 1 else 0 end) as Lander_5_page_flag,
Sum(Case when pageview_url= '/products' then 1 else 0 end) as Products_page_flag,
Sum(Case when pageview_url= '/the-original-mr-fuzzy' then 1 else 0 end) as The_original_mr_fuzzy_flag,
Sum(Case when pageview_url= '/the-forever-love-bear' then 1 else 0 end) as The_forever_love_bear_flag,
Sum(Case when pageview_url= '/the-birthday-sugar-panda' then 1 else 0 end) as The_birthday_sugar_panda_flag,
Sum(Case when pageview_url= '/the-hudson-river-mini-bear' then 1 else 0 end) as The_hudson_river_mini_bear_flag,
Sum(Case when pageview_url= '/cart' then 1 else 0 end) as Cart_page_flag,
Sum(Case when pageview_url= '/shipping' then 1 else 0 end) as Shipping_page_flag,
Sum(Case when pageview_url= '/billing' then 1 else 0 end) as Billing_page_flag,
Sum(Case when pageview_url= '/billing-2' then 1 else 0 end) as Billing_2_page_flag,
Sum(Case when pageview_url= '/thank-you-for-your-order' then 1 else 0 end) as Thanking_page_flag
from orders as o 
left join website_pageviews as wp
on o.website_session_id = wp.website_session_id
group by o.website_session_id
)

select 
om.order_id as order_id,
om.Order_time as Order_time,
om.Website_Session_id as Website_Session_id,
om.customer_id as customer_id,
om.main_product as main_product,
om.Number_of_items_purchased as Number_of_items_purchased,
om.Price as Price,
om.Cost as Cost,
om.Markup as Markup,
om.Markup_pct as Markup_pct,
id.The_Original_Mr_Fuzzy as The_Original_Mr_Fuzzy,
id.The_Forever_Love_Bear as The_Forever_Love_Bear,
id.The_Birthday_Sugar_Panda as The_Birthday_Sugar_Panda,
id.The_Hudson_River_Mini_bear as The_Hudson_River_Mini_bear,
rc.refunded_items_count as Refunded_items_count,
rc.Amt_Refunded as Amount_Refunded,
rp.Refunded_The_Original_Mr_Fuzzy as Refunded_The_Original_Mr_Fuzzy,
rp.Refunded_The_Forever_Love_Bear as Refunded_The_Forever_Love_Bear,
rp.Refunded_The_Birthday_Sugar_Panda as Refunded_The_Birthday_Sugar_Panda,
rp.Refunded_The_Hudson_River_Mini_bear as Refunded_The_Hudson_River_Mini_bear,
ot. Time_to_order as  Time_to_order,
oo.First_Order as First_Order,
oo.Second_Order as Second_Order,
oo.Third_Order as Third_Order,
oc.Channel_type as Channel_type,
oc.Channel_name as Channel_name,
oc.utm_source as utm_source,
oc.utm_campaign as utm_campaign,
oc.utm_content as utm_content,
oc.device_type as Device_type,
oc.http_referer as http_referer,
pv.Home_page_flag as Home_page_flag,
pv.Lander_1_page_flag as Lander_1_page_flag,
pv.Lander_2_page_flag as Lander_2_page_flag,
pv.Lander_3_page_flag as Lander_3_page_flag,
pv.Lander_4_page_flag as Lander_4_page_flag,
pv.Lander_5_page_flag as Lander_5_page_flag,
pv.Products_page_flag as Products_page_flag,
pv.The_original_mr_fuzzy_flag as The_original_mr_fuzzy_flag,
pv.The_forever_love_bear_flag as The_forever_love_bear_flag,
pv.The_birthday_sugar_panda_flag as The_birthday_sugar_panda_flag,
pv.The_hudson_river_mini_bear_flag as The_hudson_river_mini_bear_flag,
pv.Cart_page_flag as Cart_page_flag,
pv.Shipping_page_flag as Shipping_page_flag,
pv.Billing_page_flag as Billing_page_flag,
pv.Billing_2_page_flag as Billing_2_page_flag,
pv.Thanking_page_flag as Thanking_page_flag
into Orders_360
from order_master as om
left join item_details as id on om.order_id = id.order_id
left join refunded_count as rc on om.order_id = rc.order_id
left join refunded_products as rp on om.order_id = rp.order_id
left join ordering_time as ot on om.order_id = ot.order_id
left join order_occasion as oo on om.order_id = oo.order_id
left join order_channels as oc on om.order_id = oc.order_id
left join pageviews as pv on om.Website_Session_id = pv.website_session_id


--------------------------------------------------------------------------------------------------
 ----------------------------------- Website_360---------------------------------------------------


WITH pageview_agg AS (
    SELECT
        website_session_id,
        COUNT(*) AS total_pageviews,
        MIN(created_at) AS first_pageview_time,
        MAX(created_at) AS last_pageview_time
    FROM website_pageviews
    GROUP BY website_session_id
),

session_rank AS (
    SELECT
        website_session_id,
        user_id,
        created_at AS session_created_at,

        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY created_at
        ) AS session_number,

        LAG(created_at) OVER (
            PARTITION BY user_id
            ORDER BY created_at
        ) AS previous_session_time
    FROM website_sessions
 ),

landing_exit AS (
    SELECT
        wp.website_session_id,
        MIN(CASE WHEN wp.created_at = p.first_pageview_time THEN wp.pageview_url END) AS landing_page,
        MIN(CASE WHEN wp.created_at = p.last_pageview_time THEN wp.pageview_url END) AS exit_page
    FROM website_pageviews wp
    JOIN pageview_agg p
        ON wp.website_session_id = p.website_session_id
    GROUP BY wp.website_session_id
),



funnel_flags AS (
    SELECT
        website_session_id,
        MAX(CASE WHEN pageview_url LIKE '%product%' THEN 1 ELSE 0 END) AS reached_product_page,
        MAX(CASE WHEN pageview_url LIKE '%cart%' THEN 1 ELSE 0 END) AS reached_cart_page,
        MAX(CASE WHEN pageview_url LIKE '%billing%' THEN 1 ELSE 0 END) AS reached_checkout_page,
        MAX(CASE WHEN pageview_url LIKE '%thankyou%' THEN 1 ELSE 0 END) AS reached_thankyou_page
    FROM website_pageviews
    GROUP BY website_session_id
),


orders_agg AS (
    SELECT
        website_session_id,
        COUNT(DISTINCT order_id) AS orders_count,
        SUM(price_usd) AS session_revenue,
        SUM(cogs_usd) AS session_cost
    FROM orders
    GROUP BY website_session_id
),


refunds_agg AS (
    SELECT
        o.website_session_id,
        1 AS refund_flag,
        SUM(r.refund_amount_usd) AS refund_amount
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN order_item_refunds r
        ON oi.order_item_id = r.order_item_id
    GROUP BY o.website_session_id
)


SELECT
    ws.website_session_id,
    ws.user_id,
    ws.created_at AS session_created_at,

    /* Traffic Attribution */
    ws.utm_source,
    ws.utm_campaign,
    ws.utm_content,
    ws.http_referer,

    CASE
        WHEN ws.utm_source IS NOT NULL THEN 'Paid'
        ELSE 'Free'
    END AS channel_type,

    CASE
        WHEN ws.utm_source IN ('gsearch','bsearch') THEN 'Paid Search'
        WHEN ws.utm_source = 'socialbook' THEN 'Paid Social'
        WHEN ws.utm_source IS NULL AND ws.http_referer LIKE '%gsearch%' THEN 'Organic Search'
        WHEN ws.utm_source IS NULL AND ws.http_referer LIKE '%bsearch%' THEN 'Organic Search'
        WHEN ws.utm_source IS NULL AND ws.http_referer LIKE '%socialbook%' THEN 'Organic Social'
        ELSE 'Direct'
    END AS channel_name,

    sr.session_number,
    CASE WHEN sr.session_number > 1 THEN 1 ELSE 0 END AS is_repeat_session,
    DATEDIFF(day,sr.previous_session_time, ws.created_at) AS days_since_last_session,



    p.total_pageviews,
    le.landing_page,
    le.exit_page,

    CASE WHEN p.total_pageviews = 1 THEN 1 ELSE 0 END AS is_bounce,
    DATEDIFF(second, p.first_pageview_time, p.last_pageview_time) AS session_duration_seconds,

   
    f.reached_product_page,
    f.reached_cart_page,
    f.reached_checkout_page,
    f.reached_thankyou_page,

    CASE WHEN o.orders_count > 0 THEN 1 ELSE 0 END AS converted_session,

 
    COALESCE(o.orders_count, 0) AS orders_count,
    COALESCE(o.session_revenue, 0) AS session_revenue,
    COALESCE(o.session_cost, 0) AS session_cost,
    COALESCE(o.session_revenue, 0) - COALESCE(o.session_cost, 0) AS session_profit,

    
    COALESCE(r.refund_flag, 0) AS refund_flag,
    COALESCE(r.refund_amount, 0) AS refund_amount

INTO website_360
FROM website_sessions ws
LEFT JOIN pageview_agg p ON ws.website_session_id = p.website_session_id
LEFT JOIN session_rank sr ON ws.website_session_id = sr.website_session_id
LEFT JOIN landing_exit le ON ws.website_session_id = le.website_session_id
LEFT JOIN funnel_flags f ON ws.website_session_id = f.website_session_id
LEFT JOIN orders_agg o ON ws.website_session_id = o.website_session_id
LEFT JOIN refunds_agg r ON ws.website_session_id = r.website_session_id;

select * from website_360;

update website_360
set days_since_last_session = 9999
where days_since_last_session is NULL


-----------
------------------------------------------------------- Channel_360 ------------------------------------------------------------------------

WITH channel_base AS (
    SELECT
        CASE
            WHEN utm_source IN ('gsearch','bsearch') THEN 'Paid Search'
            WHEN utm_source = 'socialbook' THEN 'Paid Social'
            WHEN utm_source IS NULL AND http_referer LIKE '%gsearch%' THEN 'Organic Search'
            WHEN utm_source IS NULL AND http_referer LIKE '%bsearch%' THEN 'Organic Search'
            WHEN utm_source IS NULL AND http_referer LIKE '%socialbook%' THEN 'Organic Social'
            ELSE 'Direct'
        END AS channel_name,

        website_session_id,
        user_id,
        converted_session,
        session_revenue,
        refund_flag,
        is_repeat_session
    FROM website_360
),

channel_agg AS (
    SELECT
        channel_name,

        COUNT(*) AS sessions,
        SUM(converted_session) AS orders,
        SUM(session_revenue) AS revenue,

        SUM(CASE WHEN is_repeat_session = 1 THEN 1 ELSE 0 END) AS repeat_sessions,
        SUM(refund_flag) AS refund_sessions
    FROM channel_base
    GROUP BY channel_name
),

totals AS (
    SELECT
        SUM(sessions) AS total_sessions,
        SUM(revenue) AS total_revenue
    FROM channel_agg
)

SELECT
    c.channel_name,

    c.sessions,
    c.orders,
    c.revenue,

    CAST(c.orders AS FLOAT) / NULLIF(c.sessions, 0) AS conversion_rate,
    c.revenue / NULLIF(c.sessions, 0) AS revenue_per_session,

    c.repeat_sessions,
    CAST(c.repeat_sessions AS FLOAT) / NULLIF(c.sessions, 0) AS repeat_sessions_rate,

    CAST(c.refund_sessions AS FLOAT) / NULLIF(c.orders, 0) AS refund_rate,

    CAST(c.sessions AS FLOAT) / t.total_sessions AS session_share,
    CAST(c.revenue AS FLOAT) / t.total_revenue AS revenue_share

INTO channel_360
FROM channel_agg c
CROSS JOIN totals t;

select * from Channel_360

select top 5 * from orders

-------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------Products_360-------------------------------------------------------------------------------

WITH product_sales AS (
    SELECT
        oi.product_id,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        SUM(oi.price_usd) AS total_revenue,
        SUM(oi.cogs_usd) AS total_cost,
		sum(items_purchased) as total_units_sold,
        SUM(CASE WHEN oi.is_primary_item = 1 THEN 1 ELSE 0 END) AS primary_product_orders,
        SUM(CASE WHEN oi.is_primary_item = 0 THEN 1 ELSE 0 END) AS cross_sell_orders,
        MIN(o.created_at) AS first_sale_date
    FROM order_items oi
    JOIN orders o
    ON oi.order_id = o.order_id
    GROUP BY oi.product_id

),

refunds_agg AS (
    SELECT
        oi.product_id,
        COUNT(DISTINCT oi.order_id) AS refund_orders,
        COUNT(*) AS refund_units
    FROM order_items oi
    JOIN order_item_refunds r
        ON oi.order_item_id = r.order_item_id
    GROUP BY oi.product_id
)

SELECT
    p.product_id,
    p.product_name,
    p.created_at AS product_created_at,

    -- Sales
    COALESCE(ps.total_orders, 0) AS total_orders,
    COALESCE(ps.total_revenue, 0) AS total_revenue,
    COALESCE(ps.total_cost, 0) AS total_cost,
    COALESCE(ps.total_revenue, 0) - COALESCE(ps.total_cost, 0) AS total_profit,

    -- Purchase role
    COALESCE(ps.primary_product_orders, 0) AS primary_product_orders,
    COALESCE(ps.cross_sell_orders, 0) AS cross_sell_orders,

    CAST(COALESCE(ps.cross_sell_orders, 0) AS FLOAT)
        / NULLIF(ps.total_units_sold, 0) AS cross_sell_rate,

    -- Portfolio growth
    ps.first_sale_date,
    DATEDIFF(day, p.created_at, ps.first_sale_date) AS days_to_first_sale,

    -- Quality
    COALESCE(r.refund_orders, 0) AS refund_orders,
    COALESCE(r.refund_units, 0) AS refund_units,

    CAST(COALESCE(r.refund_units, 0) AS FLOAT)
        / NULLIF(ps.total_units_sold, 0) AS refund_rate

INTO product_360
FROM products p
LEFT JOIN product_sales ps
    ON p.product_id = ps.product_id
LEFT JOIN refunds_agg r
    ON p.product_id = r.product_id;


---------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------Customer360------------------------------------------------------------------------
WITH session_agg AS
(
    SELECT
        customer_id,
        COUNT(DISTINCT Website_Session_id) AS total_sessions,
        COUNT(DISTINCT CASE WHEN First_Order = 1 THEN Website_Session_id END) AS first_order_sessions,
        MIN(Order_time) AS first_order_time,
        MAX(Order_time) AS last_order_time
    FROM Orders_360
    GROUP BY customer_id
),


order_agg AS
(
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders,
        --SUM(Revenue) AS total_revenue,
        SUM(Cost) AS total_cost,
        --SUM(Profit) AS total_profit,
        --AVG(Revenue) AS avg_order_value,
        SUM(First_Order) AS first_orders,
        SUM(Second_Order) AS second_orders,
        SUM(Third_Order) AS third_orders
    FROM Orders_360
    GROUP BY customer_id
),

refund_agg AS
(
    SELECT
        customer_id,
        SUM(Refunded_items_count) AS total_refunded_items,
        COUNT(DISTINCT CASE WHEN Refunded_items_count > 0 THEN order_id END) AS refund_orders
    FROM Orders_360
    GROUP BY customer_id
),

product_agg AS
(   SELECT
        customer_id,
        SUM(Number_of_items_purchased) AS total_items_purchased,
        SUM(CASE WHEN Number_of_items_purchased > 1 THEN 1 ELSE 0 END) AS cross_sell_orders
    FROM Orders_360
    GROUP BY customer_id
)

SELECT
    s.customer_id,
    s.total_sessions,
    o.total_orders,
    CAST(o.total_orders AS FLOAT)/ s.total_sessions
    AS session_to_order_rate,
    --o.total_revenue,
    o.total_cost,
    --o.total_profit,
    --CAST(o.total_profit AS FLOAT)/ NULLIF(o.total_cost, 0) AS customer_profit_pct,
    --o.avg_order_value,
    o.first_orders,
    o.second_orders,
    o.third_orders,
    CASE WHEN o.total_orders = 1 THEN 'One-time Customer'
         WHEN o.total_orders = 2 THEN 'Repeat Customer'
         WHEN o.total_orders >= 3 THEN 'Loyal Customer'
         ELSE 'Visitor'
         END AS customer_type,

    DATEDIFF(day, s.first_order_time, s.last_order_time) AS customer_lifetime_days,
    p.total_items_purchased,
    p.cross_sell_orders,

    CAST(p.cross_sell_orders AS FLOAT)/ NULLIF(o.total_orders, 0) AS cross_sell_order_rate,

    /* --------------------
       Quality / Refunds
       -------------------- */
    r.refund_orders,
    r.total_refunded_items,
    CAST(r.refund_orders AS FLOAT)/ NULLIF(o.total_orders, 0) AS refund_order_rate,
    CASE WHEN r.refund_orders > 0 THEN 1 ELSE 0 END AS refund_prone_customer
INTO Customer_360
FROM session_agg s 
LEFT JOIN order_agg o ON s.customer_id = o.customer_id
LEFT JOIN refund_agg r ON s.customer_id = r.customer_id
LEFT JOIN product_agg p ON s.customer_id = p.customer_id;





---- Is Profit , Revenue , Order volume showing consistent growth?

;with summary_year_month as(
select format(created_at,'yyyy-MM') as Year_months,round(sum(Profit),2) as profits,
round(sum(price_usd),2) as Revenue,round(count(distinct order_id),2)as order_counts from(
select order_items.order_id,order_items.order_item_id,order_items.created_at,order_items.price_usd,
case when order_item_refunds.order_item_id is null then price_usd - cogs_usd else 
0-cogs_usd end as Profit
from order_items
left join order_item_refunds
on 
order_items.order_item_id = order_item_refunds.order_item_id
)
as a 
group by format(created_at,'yyyy-MM'))

select Year_months,round((profits- lag(profits)over(order by Year_months))*100/
lag(profits)over(order by Year_months),2) as prct_profit_change
,
round((Revenue- lag(Revenue)over(order by Year_months))*100/
lag(Revenue)over(order by Year_months),2) as prct_Revenue_change,
round((order_counts- lag(order_counts)over(order by Year_months))*100/
lag(order_counts)over(order by Year_months),2) as prct_order_counts_change
from summary_year_month

----

---Avg_prct conversion rate across year and months 

with sales_seasonality as(
select Month(created_at) as Months,count(distinct[user_id]) as user_counts,
count(order_id) as order_counts,year(created_at) as years
from orders
group by Month(created_at),year(created_at)
),

prct_change as(
select Months,Years, Avg((order_counts*1.0)/user_counts) as change_prct from
sales_seasonality
group by Months,years
--order by change_prct desc
),

ranks as(
select *,dense_rank()over(partition by months order by change_prct desc) as r from prct_change)

select years
,
coalesce(sum(case when Months = 1 then change_prct end),0) as Jan,
coalesce(sum(case when Months = 2 then  change_prct end),0)as Feb,
coalesce(sum(case when Months = 3 then  change_prct end),0)as Mar,
coalesce(sum(case when Months = 4 then  change_prct end),0)as Apr,
coalesce(sum(case when Months = 5 then  change_prct end),0)as May,
coalesce(sum(case when Months = 6 then  change_prct end),0)as Jun,
coalesce(sum(case when Months = 7 then  change_prct end),0)as Jul,
coalesce(sum(case when Months = 8 then  change_prct end),0)as Aug,
coalesce(sum(case when Months = 9 then  change_prct end),0)as Sept,
coalesce(sum(case when Months = 10 then change_prct end),0) as Oct,
coalesce(sum(case when Months = 11 then change_prct end),0) as Nov,
coalesce(sum(case when Months = 12 then change_prct end),0) as [Dec]
from								    
ranks
---where r <=2
group by years

--------------------------------------- Business Overview ------------------------
--------------------------------------- Customer Insights ------------------------

---1)Business Kpis
--Financial Kpis
select * , (Profit/Total_Net_Revenue)*100 as Profit_Margin from(
select Total_orders,
Gross_Revenue,Total_Net_Revenue,
Total_Cost,Net_Cost,
Refunded_Items_Costs,
Total_Net_Revenue-Net_Cost as Profit 
from(
select 
sum(Total_orders) as Total_orders,
sum(Total_revenue) as Gross_Revenue,sum(Total_cost) as Total_Cost,
sum(refunded_items_costs) as Refunded_Items_Costs,
(sum(Total_cost) - sum(refunded_items_costs)) as Net_Cost,
(sum(Total_revenue) - sum(Total_refund)) as Total_Net_Revenue from(
select sum(cogs_usd)as refunded_items_costs,
sum(refund_amount_usd) as Total_refund,
(select sum(price_usd) from orders) as Total_revenue,
(select sum(cogs_usd) from orders) as Total_cost,
(select count(order_id) from orders) as Total_orders
from order_items 
right join order_item_refunds
on order_items.order_item_id = order_item_refunds.order_item_id) as a) as ab
) as c

----2) Advocacy_Distributions
--- Customer Advocacy On the Basis of its Behaviour
select count(*) as Advocacy_Distributions_Counts,
(case when potential_advocates_score<=4
then 'New_Unproven'
when potential_advocates_score>4 and potential_advocates_score<=8
then 'Normal_Customer'
when potential_advocates_score>8 and potential_advocates_score<=10
then 'Potential_Advocates'
when potential_advocates_score>10 then
'Strong_Advocates'
end) as Customer_Type
from(
select*,
refund_score + Customer_life_time_value + orders_score as potential_advocates_score from(
select *,(case when 
item_refunded_prct = 0.0 then 5
when item_refunded_prct >0.00 and item_refunded_prct <0.30 then 3
when item_refunded_prct >=0.30 and item_refunded_prct <=0.6 then 2
when item_refunded_prct>0.6 then 1
end) as refund_score 
,
(case when 
customer_lifetime_days >= 0 and customer_lifetime_days <=30  then 0
when customer_lifetime_days > 30 and customer_lifetime_days <=60 then 2
when customer_lifetime_days > 60 and customer_lifetime_days <=90 then 4
when customer_lifetime_days > 90  then 5
end) as Customer_life_time_value,

(case when 
total_orders=1 then 3
when total_orders=2 then 4
when total_orders=3 then 5
end) as orders_score 
from(
select 
total_refunded_items*1.0/total_items_purchased as item_refunded_prct,
customer_lifetime_days,total_orders
from customer_360)as a) as ab
) as abc
group by (case when potential_advocates_score<=4
then 'New_Unproven'
when potential_advocates_score>4 and potential_advocates_score<=8
then 'Normal_Customer'
when potential_advocates_score>8 and potential_advocates_score<=10
then 'Potential_Advocates'
when potential_advocates_score>10 then
'Strong_Advocates'
end)


---- Monthly Order Conversion Rate Analysis 
select Month(website_sessions.created_at) as Months,
(count(case when orders.order_id is not null then 1 end)*1.0
/ count(website_sessions.website_session_id)) as Order_Conversion_Rate
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
group by Month(website_sessions.created_at)
order by Months

--- WaterFall Analysis ------------------------------------------------------

;with waterfall_analysis as(
select sum(price_usd) as Total_Revenue,
sum(case when product_id = 1 then price_usd end ) as Total_revenue_first_product,
sum(case when product_id = 2 then price_usd end ) as Total_revenue_second_product,
sum(case when product_id = 3 then price_usd end ) as Total_revenue_third_product,
sum(case when product_id = 4 then price_usd end ) as Total_revenue_fourth_product,
sum(cogs_usd) as Total_cost,
sum(case when order_item_refunds.order_id is not null then refund_amount_usd
else 0 end) as Total_refunded_amt ,
sum(case when order_item_refunds.order_id is not null then cogs_usd
else 0 end) as Total_refund_cost_amt
from order_items
left join order_item_refunds
on order_items.order_id = order_item_refunds.order_id)

select 'Total_Revenue' as step_name ,Total_Revenue as amount 
from waterfall_analysis
union all
select 'First_Product_Revenue' as step_name ,Total_revenue_first_product as amount 
from waterfall_analysis
union all
select 'Second_Product_Revenue' as step_name ,Total_revenue_second_product as amount 
from waterfall_analysis
union all
select 'Third_Product_Revenue' as step_name ,Total_revenue_third_product as amount 
from waterfall_analysis
union all
select 'Fourth_Product_Revenue' as step_name ,Total_revenue_fourth_product as amount 
from waterfall_analysis
union all
select 'Total_Cost' as step_name ,-Total_cost as amount 
from waterfall_analysis
union all
select 'Total_Refunded_Amt' as step_name ,-Total_refunded_amt as amount 
from waterfall_analysis
union all
select 'Total_Refunded_cost_amt' as step_name ,Total_refund_cost_amt as amount 
from waterfall_analysis
union all
select 'Total_Profit' as step_name ,
((Total_Revenue - Total_refunded_amt)-(Total_cost-Total_refund_cost_amt))
as amount 
from waterfall_analysis


---- Time of Day /Week Purchase Behaviour 

select sum(count_orders) as Total_orders ,Day_name,
(case when order_time between 0 and 5 then 'Early_Morning'
when order_time  between 6 and 11 then 'Morning'
when order_time Between 12 and 16 then 'Afernoon'
when order_time  between 17 and 20 then 'Evening'
when order_time  between 21 and 23 then 'Night' end) as order_time_bin,
(case when Day_name = 'Saturday' or Day_name = 'Sunday' then 'Weekend'
else 'Weekday' end)as day_bin
from (
select count(order_id)as count_orders ,Datename(WEEKDAY,created_at)as Day_name,
(format(created_at,'HH')) as order_time from orders
group by Datename(WEEKDAY,created_at),
(format(created_at,'HH'))
) as a
group by 
Day_name,
(case when order_time between 0 and 5 then 'Early_Morning'
when order_time  between 6 and 11 then 'Morning'
when order_time Between 12 and 16 then 'Afernoon'
when order_time  between 17 and 20 then 'Evening'
when order_time  between 21 and 23 then 'Night' end),
(case when Day_name = 'Saturday' or Day_name = 'Sunday' then 'Weekend'
else 'Weekday' end)
order by Total_orders desc

---- Seasonality & Trend Analysis
---Is there is any seasonality patterns in traffic and sales?

;with year_months as (
select count(distinct [user_id]) as user_counts ,count(order_id) as order_counts
,Year(created_at)as Years,month(created_at) as Months
from orders
group by Year(created_at),month(created_at)
)
select years
,
coalesce(sum(case when Months = 1 then user_counts end),0) as Jan,
coalesce(sum(case when Months = 2 then user_counts end),0)as Feb,
coalesce(sum(case when Months = 3 then user_counts end),0)as Mar,
coalesce(sum(case when Months = 4 then user_counts end),0)as Apr,
coalesce(sum(case when Months = 5 then user_counts end),0)as May,
coalesce(sum(case when Months = 6 then user_counts end),0)as Jun,
coalesce(sum(case when Months = 7 then user_counts end),0)as Jul,
coalesce(sum(case when Months = 8 then user_counts end),0)as Aug,
coalesce(sum(case when Months = 9 then user_counts end),0)as Sept,
coalesce(sum(case when Months = 10 then user_counts end),0) as Oct,
coalesce(sum(case when Months = 11 then user_counts end),0) as Nov,
coalesce(sum(case when Months = 12 then user_counts end),0) as [Dec]
from
year_months
group by years

----Customer Segmentation by value(Decil Analysis)


;with order_levels as(
select [user_id], sum(items_purchased) as 
Total_items_purchased , 
sum(price_usd) as Total_revenue
,datediff(day,min(created_at),max(created_at)) as customer_lifetime
from orders 
group by [user_id]
)
,

orders_profit as(
select orders.order_id,[user_id],year(created_at) as years ,
month(created_at) as Months, 
price_usd as Total_revenue,
cogs_usd as Total_cost
from orders
---group by order_id
),

order_refunded as(
select 
order_item_refunds.order_id,sum(refund_amount_usd)as refunded_amt,
sum(cogs_usd) as refunded_cost,
count(order_item_id) as order_items_refunded
from order_item_refunds
left join orders
on order_item_refunds.order_id = orders.order_id
group by 
order_item_refunds.order_id),

user_levels as (
select order_levels.[user_id],years,months,
sum(case when order_refunded.order_id is not null
then (orders_profit.Total_revenue-refunded_amt)
-(orders_profit.Total_cost-refunded_cost)
else orders_profit.Total_revenue-orders_profit.Total_cost end) as profit,
max(order_levels.Total_revenue) as Total_revenue,
max(Total_items_purchased) as Total_items_purchased,
sum(case when order_items_refunded is null then 0 
else order_items_refunded end) as order_items_refunded,
max(customer_lifetime) as cust_lifetime_value
from orders_profit
left join order_refunded
on orders_profit.order_id = order_refunded.order_id
--left join orders
--on orders_profit.order_id = orders.order_id
left join order_levels
on orders_profit.[user_id] = order_levels.[user_id]
group by order_levels.[user_id],years,months
),

cust_scoring as(
select *,refund_score+profit_score+cust_lifetime_value_score + items_purchased_score as 
Cust_value from(
select *,(case when order_items_refunded =0 then 5 
when order_items_refunded = 1 then 3
when order_items_refunded = 2 then 1 end ) as refund_score,
(case when profit between 100 and 150  then 20 
when profit >=80 and  profit <=100 then 10
when profit between  40 and 80 then 4
when profit between 0 and 40 then 2 
when profit <0 then -5 end
) as profit_score,
(case when 
cust_lifetime_value>=0 and cust_lifetime_value<=30  then 0
when 
cust_lifetime_value>30 and cust_lifetime_value<=60  then 50
when cust_lifetime_value>60 and cust_lifetime_value<=90  then 100
when cust_lifetime_value>90 then 150 end) as cust_lifetime_value_score,
(case when Total_items_purchased between 1 and 2 then 1 
when Total_items_purchased between 3 and 4 then 4
when Total_items_purchased between 5 and 6 then 10 end) as items_purchased_score 
from user_levels
) as ab
),

decile_segment as(
select * ,ntile(10)over(order by cust_value desc)as deciles from cust_scoring
),

segmentation as(
select [user_id],years,months, (case when deciles between 1 and 3 then 'HIGH'
when deciles between 4 and 6  then 'MEDIUM'
when deciles>6  then 'LOW'
end )as cust_segmentation from decile_segment)


select count(*)as user_counts,cust_segmentation as customer_value ,
years 
from segmentation
group by cust_segmentation,years 
order by years



------First_Time Purchase V/S Repeat_Purchase 

with cust_repeat_orders as(
select * from(
select *,ROW_NUMBER()over(partition by user_id order by created_at)as row_num
from orders
)
as a
)
,
product_dist as(
select user_id,row_num,
sum(case when product_name = 'The Original Mr. Fuzzy' then 1 else 0 end) as The_Original_Mr_Fuzzy,
sum(case when product_name = 'The Forever Love Bear' then 1 else 0 end) as The_Forever_Love_Bear,
sum(case when product_name = 'The Birthday Sugar Panda' then 1 else 0 end) as The_Birthday_Sugar_Panda,
sum(case when product_name = 'The Hudson River Mini bear' then 1 else 0 end) as The_Hudson_River_Mini_bear
from products
right join cust_repeat_orders
on products.product_id = cust_repeat_orders.primary_product_id
group by user_id,row_num
)
select case when row_num>1 then 'Repeat_Purchase' else 'First_Time_Purchase' end as purchase_type,
sum(The_Original_Mr_Fuzzy)as The_Original_Mr_Fuzzy,sum(The_Forever_Love_Bear)
as The_Forever_Love_Bear ,
sum(The_Birthday_Sugar_Panda)as The_Birthday_Sugar_Panda ,sum(The_Hudson_River_Mini_bear)
as The_Hudson_River_Mini_bear
from product_dist
group by case when row_num>1 then 'Repeat_Purchase' else 'First_Time_Purchase' end

---Customer Journey Analysis 

;with orders_summ as(
select [user_id],sum(price_usd) as Total_Revenue , 
count(order_id) as Total_Orders,
sum(items_purchased) as Total_items_purchased,
datediff(day,min(created_at),max(created_at)) as customer_lifetime_value
from orders 
group by [user_id]),

previous_days as(
select *,
coalesce(lag(created_at)over(partition by [user_id] order by created_at),created_at) as previous_order
from orders
),

avg_days_btw_orders as(
select [user_id],avg(datediff(day,previous_order,created_at)) as
avg_days_btw_orders from previous_days
group by [user_id]),

purchase_type_date as(
select *,ROW_NUMBER()over(partition by user_id order by created_at)
as purchase_type
from orders 
),

days_btw_second_purchase as(
select p1.user_id , datediff(day,p1.created_at,p2.created_at) as days_btw_second_purchase
from purchase_type_date
as p1 join purchase_type_date
as p2 
on p1.user_id = p2.user_id
and p1.purchase_type=1 and p2.purchase_type =2
),

refunded as(
select user_id ,count(order_item_id)as count_item_refunded,
coalesce(sum(order_item_refunds.refund_amount_usd),0) as amount_refunded 
from orders
left join order_item_refunds
on orders.order_id = order_item_refunds.order_id
group by user_id)

select orders_summ.user_id,orders_summ.Total_items_purchased,
orders_summ.Total_Orders,orders_summ.Total_Revenue,avg_days_btw_orders.avg_days_btw_orders,
coalesce(days_btw_second_purchase.days_btw_second_purchase,0)as days_btw_second_orders,
refunded.count_item_refunded,refunded.amount_refunded,
orders_summ.customer_lifetime_value
from orders_summ
left join avg_days_btw_orders
on orders_summ.user_id = avg_days_btw_orders.user_id
left join days_btw_second_purchase
on orders_summ.user_id = days_btw_second_purchase.user_id
left join refunded
on orders_summ.user_id = refunded.user_id

----Lead Generation By Channels
select distinct utm_source from website_sessions

;with website_channel_dist as(
--select count([user_id])as users_count,channel_type,channel_name
--from(
select *,
 CASE
            WHEN utm_source IN ('gsearch','bsearch') THEN 'Paid Search'
            WHEN utm_source = 'socialbook' THEN 'Paid Social'
            WHEN utm_source ='not available' AND http_referer LIKE '%gsearch%' THEN 'Organic Search'
            WHEN utm_source ='not available' AND http_referer LIKE '%bsearch%' THEN 'Organic Search'
            WHEN utm_source ='not available' AND http_referer LIKE '%socialbook%' THEN 'Organic Social'
            ELSE 'Direct' end as channel_name ,
			case when utm_source = 'not available' then 'Free' else 'Paid' end as  channel_type			
from website_sessions),

orders_items_refunded as(
select order_items.order_id,
sum(order_items.cogs_usd) - sum(case when order_item_refund_id is not null then order_items.cogs_usd else 0 end) 
as Total_Net_Cost, 
((sum(order_items.price_usd) - sum(case when order_item_refund_id is not null then refund_amount_usd else 0 end) 
)  - (sum(order_items.cogs_usd) - sum(case when order_item_refund_id is not null then order_items.cogs_usd else 0 end))) as Profit,
sum(case when order_item_refund_id is null then 0 else 1 end) as items_refunded,
sum(price_usd) - sum(case when order_item_refund_id is not null then refund_amount_usd else 0 end) 
as Total_Net_Revenue
from order_items
left join order_item_refunds
on order_items.order_item_id= order_item_refunds.order_item_id
group by order_items.order_id)

---select sum(coversion_rate) from(
select channel_type,channel_name,
sum(items_purchased)as Total_Items_Purchased,sum(orders.cogs_usd) as Total_cost,
sum(orders.price_usd) as Total_Revenue,count(orders.order_id) as orders_count,
count(distinct orders.[user_id]) as customer_counts,count(distinct orders.order_id)*1.0/
count(distinct website_channel_dist.website_session_id)
as coversion_rate,
sum(items_purchased)*100.00/count(orders.order_id) as avg_order_items_purchased,
sum(Total_Net_Cost) as Total_Net_Cost,sum(Profit) as Total_Profit,
sum(items_refunded) as Total_items_refunded,
sum(items_refunded)*100.00/count(orders.order_id) as avg_item_refunded,
sum(items_refunded)*100.00/sum(items_purchased) as refund_rate,
sum(Total_Net_Revenue) as Total_Net_Revenue
from website_channel_dist
left join orders
on  website_channel_dist.website_session_id =orders.website_session_id 
left join orders_items_refunded
on orders.order_id = orders_items_refunded.order_id
group by channel_type,channel_name
---) as a

----Content Engagement Analysis 

select Month(website_sessions.created_at) as Months,Year(website_sessions.created_at) as Years ,
device_type,
count(website_pageview_id)as website_pageviews_counts 
from website_sessions
left join website_pageviews
on website_sessions.website_session_id = website_pageviews.website_session_id
group by Month(website_sessions.created_at),Year(website_sessions.created_at),
device_type

-----
;with cust_type as(
select *,case when row_no = 1 then 'New_Customer'
else 'Repeat_Customer' end as Customer_Type from(
select *,ROW_NUMBER()over(partition by user_id order by created_at) as row_no
from orders ) as a),

active_durations as(
select distinct user_id, datediff(Hour,min(created_at),max(created_at)) as Active_hours,count(distinct website_session_id) as 
website_session_id_counts 
from website_sessions
group by user_id)
,

sessions_dist as(
select user_id,count(website_pageview_id) as count_pages_visited,
Sum(Case when pageview_url= '/home' then 1 else 0 end) as Home_page_flag,
Sum(Case when pageview_url= '/lander-1' then 1 else 0 end) as Lander_1_page_flag,
Sum(Case when pageview_url= '/lander-2' then 1 else 0 end) as Lander_2_page_flag,
Sum(Case when pageview_url= '/lander-3' then 1 else 0 end) as Lander_3_page_flag,
Sum(Case when pageview_url= '/lander-4' then 1 else 0 end) as Lander_4_page_flag,
Sum(Case when pageview_url= '/lander-5' then 1 else 0 end) as Lander_5_page_flag,
Sum(Case when pageview_url= '/products' then 1 else 0 end) as Products_page_flag,
Sum(Case when pageview_url= '/the-original-mr-fuzzy' then 1 else 0 end) as The_original_mr_fuzzy_flag,
Sum(Case when pageview_url= '/the-forever-love-bear' then 1 else 0 end) as The_forever_love_bear_flag,
Sum(Case when pageview_url= '/the-birthday-sugar-panda' then 1 else 0 end) as The_birthday_sugar_panda_flag,
Sum(Case when pageview_url= '/the-hudson-river-mini-bear' then 1 else 0 end) as The_hudson_river_mini_bear_flag,
Sum(Case when pageview_url= '/cart' then 1 else 0 end) as Cart_page_flag,
Sum(Case when pageview_url= '/shipping' then 1 else 0 end) as Shipping_page_flag,
Sum(Case when pageview_url= '/billing' then 1 else 0 end) as Billing_page_flag,
Sum(Case when pageview_url= '/billing-2' then 1 else 0 end) as Billing_2_page_flag,
Sum(Case when pageview_url= '/thank-you-for-your-order' then 1 else 0 end) as Thanking_page_flag
from website_pageviews
left join orders 
on website_pageviews.website_session_id = 
orders.website_session_id
group by user_id)


select count(customer_type) as customer_counts
,max(active_hours) as active_hours ,sum(count_pages_visited) as count_pages_visited,
Customer_Type,sum(items_purchased) as Total_items_Purchased,sum(website_session_id_counts) as website_session_counts,
(count(distinct order_id)*100.0/sum(website_session_id_counts)) as conversion_rate
from cust_type
left join active_durations
on cust_type.user_id = active_durations.user_id
left join sessions_dist
on Cust_type.user_id = sessions_dist.user_id
group by Customer_Type

-----------RF Analaysis

;with rf_scoring as(
--**** calculating rf score by  calculating recency score and frequecy score 

select user_id,recency,Frequency,ntile(3)over(order by recency asc) as recency_score ,
ntile(3)over(order by frequency desc ) as frequency_score
from(
select user_id,datediff(day,max(created_at),(select max(created_at) from orders))as recency ,
count(order_id) as Frequency
from orders
group by 
user_id) as a
)

--***segmenting customer based on rf score 

select count(user_id) as count_cust,case when rf_score>=4 then 'Best_Active_cust'
 when rf_score=3 then 'Dormant'
 when rf_score<3 then 'Risk' end as Cust_type from(
select user_id,recency_score+frequency_score as rf_score 
from rf_scoring) as a
group by 
case when rf_score>=4 then 'Best_Active_cust'
 when rf_score=3 then 'Dormant'
 when rf_score<3 then 'Risk' end

 ----customer churn and retention analysis 
 ----- Consider loyalty and recency taken the max portion of customer_lifetime max is 100 and then the second priority given to 
 --- recency max of 80 
 -- so the range is like best customer has to be around 180 (customer is old as well as recently purchased)
 -- the range btw 40 to 80 has to be active  (customer is old and purchase recently )
 -- less than 40 then it is risky( the customer is recent and not purchased recently )
 
 ;with customer_churn_retention as(
 select user_id ,case when 
 cust_lifetime>=0 and cust_lifetime<=30 then 0 
 when 
 cust_lifetime>30 and cust_lifetime<=60  then 40
 when cust_lifetime>60 and cust_lifetime<=90  then 60
 when cust_lifetime>90 then 100 end as customer_life_time_value ,
 case when days_after_last_purchase>=0 and days_after_last_purchase<=365 then 80
 when days_after_last_purchase>=366 and days_after_last_purchase<=730 then 20
 when days_after_last_purchase>=731 then 0 end as days_since_last_purchase 
 from(
 select user_id ,datediff(day,min(created_at),max(created_at)) as cust_lifetime,
 datediff(day,max(created_at),(select max(created_at) from orders)) 
 as days_after_last_purchase
 from orders 
 group by user_id 
 ) as a)


 select 
 count(user_id) as user_counts ,
 case when customer_life_time_value+days_since_last_purchase  <=40 then 'Risk'
 when customer_life_time_value+days_since_last_purchase >40 and  customer_life_time_value+days_since_last_purchase <=80 then 'Active'
 when customer_life_time_value+days_since_last_purchase >80  then 'Best' end as cust_types 
 from customer_churn_retention
 group by 
 case when customer_life_time_value+days_since_last_purchase <=40 then 'Risk'
 when customer_life_time_value+days_since_last_purchase >40 and  customer_life_time_value+days_since_last_purchase <=80 then 'Active'
 when customer_life_time_value+days_since_last_purchase >80  then 'Best' end
 
 ----Conversion_Rate_Optimization 
 select month(website_sessions.created_at) as Months,count(distinct orders.order_id)*1.0/
 count(website_sessions.website_session_id)  as conversion_rate
 from orders
 right join website_sessions
 on orders.website_session_id = website_sessions.website_session_id
 group by month(website_sessions.created_at) 
 order by month(website_sessions.created_at) 
 

 -------------FM Analysis 
 ---fm_score between 5 and 6 then 'High customer' when it is 2 and 4 then 'Medium Customer' when it is less than equal to 2 then 'Low_value_cust'
 --- for fm calculation taken net revenue = Total_revenue - refund_amount_usd
;with fm_analysis_dist as (
select user_id ,count(orders.order_id) as no_of_times_order,
sum(price_usd) as Gross_revenue,
(sum(price_usd) - sum(case when order_item_refund_id is not null then refund_amount_usd else 0 end)) as Total_Net_Revenue 
from orders
left join order_item_refunds
on orders.order_id = order_item_refunds.order_id
group by user_id),

scoring as(
select *, 
ntile(3) over(order by Total_Net_Revenue desc) as Monetary_Score ,
ntile(3) over(order by no_of_times_order desc) as Frequency_Score 
from fm_analysis_dist )

select count(distinct user_id) as cust_counts,cust_types from(
select *,case when Monetary_Score + Frequency_Score>=5 and Monetary_Score + Frequency_Score<=6   then 'High_Value_Cust'
 when Monetary_Score + Frequency_Score>2 and Monetary_Score + Frequency_Score<=4 then 'Medium_Value_Cust'
 when Monetary_Score + Frequency_Score<=2 then 'Low_Value_Cust' end as cust_types from scoring
 ) as a
 group by cust_types


-----RFM Analysis 
----- if rfm_score is between 6 and 9 then 'High_Value_Customer',
-----if rm_score is between 3 and 6 then 'Medium_value_customer', else 'low_value_customer'
----- for monetary taken total_net_revenue 

;with fm_analysis_dist as (
select user_id ,count(orders.order_id) as no_of_times_order,
sum(price_usd) as Gross_revenue,
(sum(price_usd) - sum(case when order_item_refund_id is not null then refund_amount_usd else 0 end)) as Total_Net_Revenue,
datediff(day,max(orders.created_at),(select max(created_at) from orders)) as days_after_last_purchase
from orders
left join order_item_refunds
on orders.order_id = order_item_refunds.order_id
group by user_id),

scores as(
select *
, ntile(3)over(order by Total_Net_Revenue desc) as Monetary,
ntile(3)over(order by days_after_last_purchase asc) as Recency,
ntile(3)over(order by no_of_times_order desc) as Frequency
from fm_analysis_dist)
,

customer_dist_based_rfm as(
select *,case when Monetary+Recency+Frequency>=6 and Monetary+Recency+Frequency<=9 then 'High_Value_Cust'
when Monetary+Recency+Frequency >3 and Monetary+Recency+Frequency<=6 then 'Medium_Value_Cust'
when Monetary+Recency+Frequency <=3  then 'Low_Value_Cust' end as cust_types
from scores)

select count(distinct user_id)as customer_counts ,cust_types
from customer_dist_based_rfm
group by cust_types



------Customer Satisfaction & Feedback Analysis
---- if customer life time is less then it can't be said that customer is satisfied or not so there is another column of new and old customer is segmented
----the score is based on net_revenue,refund_rate,no_of_items_purchased 
---if the score is 9 then - highly satisfied
-- score is btw 7 and 8 then - satisfied
-- score is 6 then - Neutral 
--- score is less than or equal to 5 then unsatisfied 

;with fm_analysis_dist as (
select user_id ,sum(items_purchased) as Total_items_purchased,
sum(price_usd) as Gross_revenue,
(sum(price_usd) - sum(case when order_item_refund_id is not null then refund_amount_usd else 0 end)) as Total_Net_Revenue,
datediff(day,max(orders.created_at),(select max(created_at) from orders)) as days_after_last_purchase,
datediff(day,min(orders.created_at),max(orders.created_at)) as cust_lifetime_value,
count(orders.order_id) as count_of_orders,
sum(case when order_item_refunds.order_id is not null then 1 else 0 end)*100.0/sum(items_purchased) as refund_rate,
sum(case when order_item_refunds.order_id is not null then 1 else 0 end) as refund_items_count
from orders
left join order_item_refunds
on orders.order_id = order_item_refunds.order_id
group by user_id),

satisfaction_distribution as(
select *,case 
when
purchase_depth+Total_net_revenue_score+refund_rate_score =9 then 'Highly_Satisfied'

when 
purchase_depth+Total_net_revenue_score+refund_rate_score >=7 and 
purchase_depth+Total_net_revenue_score+refund_rate_score <=8 then 'Satisfied'

when
purchase_depth+Total_net_revenue_score+refund_rate_score =6
then 'Neutral'

when purchase_depth+Total_net_revenue_score+refund_rate_score <=5  then 'Unsatisfied' end as 
satisfaction_dist from(
select *,
case when cust_lifetime_value <=30 then 'New_customer' else 'Old_customer' end as cust_type,
ntile(3)over(order by Total_items_purchased desc) as purchase_depth,
ntile(3)over(order by Total_Net_Revenue desc) as Total_net_revenue_score,
ntile(3)over(order by refund_rate asc) as refund_rate_score
from fm_analysis_dist
) as a)

select count(user_id) as users_count , cust_type,satisfaction_dist from 
satisfaction_distribution
group by cust_type,satisfaction_dist

---- Customer Acquistion Cost Analysis 
-----*** as does not have marketing spend as such 


----Channel Performance Analysis 

;with website_channel_dist as(
select *,
 CASE
            WHEN utm_source IN ('gsearch','bsearch') THEN 'Paid Search'
            WHEN utm_source = 'socialbook' THEN 'Paid Social'
            WHEN utm_source ='not available' AND http_referer LIKE '%gsearch%' THEN 'Organic Search'
            WHEN utm_source ='not available' AND http_referer LIKE '%bsearch%' THEN 'Organic Search'
            WHEN utm_source ='not available' AND http_referer LIKE '%socialbook%' THEN 'Organic Social'
            ELSE 'Direct' end as channel_name ,
			case when utm_source = 'not available' then 'Free' else 'Paid' end as  channel_type			
from website_sessions),

orders_items_refunded as(
select order_items.order_id,
sum(order_items.cogs_usd) - sum(case when order_item_refund_id is not null then order_items.cogs_usd else 0 end) 
as Total_Net_Cost, 
((sum(order_items.price_usd) - sum(case when order_item_refund_id is not null then refund_amount_usd else 0 end) 
)  - (sum(order_items.cogs_usd) - sum(case when order_item_refund_id is not null then order_items.cogs_usd else 0 end))) as Profit,
sum(case when order_item_refund_id is null then 0 else 1 end) as items_refunded,
sum(price_usd) - sum(case when order_item_refund_id is not null then refund_amount_usd else 0 end) 
as Total_Net_Revenue
from order_items
left join order_item_refunds
on order_items.order_item_id= order_item_refunds.order_item_id
group by order_items.order_id),

channel_analysis as(
select Month(website_channel_dist.created_at) as Months ,channel_type,channel_name,
sum(items_purchased)as Total_Items_Purchased,sum(orders.cogs_usd) as Total_cost,
sum(orders.price_usd) as Total_Revenue,count(orders.order_id) as orders_count,
count(distinct orders.[user_id]) as customer_counts,count(distinct orders.order_id)*1.0/
count(distinct website_channel_dist.website_session_id)
as coversion_rate,
sum(items_purchased)*100.0/count(orders.order_id) as avg_order_items_purchased,
sum(Total_Net_Cost) as Total_Net_Cost,sum(Profit) as Total_Profit,
sum(items_refunded) as Total_items_refunded,
sum(items_refunded)*100.0/count(orders.order_id) as avg_item_refunded,
sum(items_refunded)*100.0/sum(items_purchased) as refund_rate,
sum(Total_Net_Revenue) as Total_Net_Revenue
from website_channel_dist
left join orders
on  website_channel_dist.website_session_id =orders.website_session_id 
left join orders_items_refunded
on orders.order_id = orders_items_refunded.order_id
group by channel_type,channel_name,Month(website_channel_dist.created_at)
)

select Months,
(coversion_rate - lag(coversion_rate)over(partition by channel_type,channel_name order by Months))*1.0/ lag(coversion_rate)over(
partition by channel_type,channel_name order by Months) as conversion_rate_change,

channel_type ,channel_name 
from channel_analysis

 
 ---- Time to conversion analysis
 ----time of website session and time or order of that user how much change is there 

;with website_session_date as(
select user_id,max(created_at) as last_website_sessions from website_sessions
group by user_id),

orders_date as (
select user_id,max(created_at) as last_order_date from orders
group by user_id)

select count(user_id) as users_counts, 
case when converted_days<10 then 'Fast_Converted'
when converted_days<=30 then 'Moderate_Converted'
when converted_days>30 and converted_days<99999 then 'Slow_Converted'
else 'Non_Converted' end as Converted_Type from(

select website_session_date.user_id,coalesce(datediff(day,last_order_date,last_website_sessions),99999) as converted_days
from website_session_date 
left join orders_date
on website_session_date.user_id = orders_date.user_id 
) as a 
group by case when converted_days<10 then 'Fast_Converted'
when converted_days<=30 then 'Moderate_Converted'
when converted_days>30 and converted_days<99999 then 'Slow_Converted'
else 'Non_Converted' end

----Cross sell & Upsell analysis 

----- Cross sell
--- based on orders like how many orders are there who have purchased complemenatry products 
--- else no_cross_sell and there orders_counts 

;with sell_type_summary as(
select count(distinct order_id) as orders_count,
case when cross_sell_products>0 then 'Cross_sell'
else 'No_cross_sell' end as sell_type  from (
select count(distinct order_items.product_id) as products_counts 
,order_items.order_id,
sum(case when is_primary_item =0 then 1 else 0 end) as cross_sell_products 
from order_items
---left join products
---on order_items.product_id = products.product_id
group by order_items.order_id
) as a
group by case when cross_sell_products>0 then 'Cross_sell'
else 'No_cross_sell' end )

select * from sell_type_summary
--left join products
--on sell_type_summary.order_id= products.product_id

-----Upsell 
---- The user counts on the basis of products whose previous price is less than the current 
---- purchase price so we can say those user that they have upsell else they 
--- on the based of user 

;with products_seg_price as(
select * from(
select user_id,lag(price_usd)over(partition by user_id order by created_at)
as previous_product_price,primary_product_id,price_usd as current_price_product 
from orders) as a
where previous_product_price is not null )

select count(distinct products_seg_price.user_id) as user_counts,
case when current_price_product>previous_product_price then 'Upsell' else 'No_upsell' end as sell_type
from products_seg_price
group by 
case when current_price_product>previous_product_price then 'Upsell' else 'No_upsell' end


-----Segment Migration 
--- in migration there is no change like that 
--- as rfm is based on lifetime so there is no such migration is there 
---- there is no migration of customer from low to high value customer or 
----high to low like this 

;with fm_analysis_dist as (
select user_id ,count(orders.order_id) as no_of_times_order,
sum(price_usd) as Gross_revenue,
(sum(price_usd) - sum(case when order_item_refund_id
is not null then refund_amount_usd else 0 end)) as Total_Net_Revenue,
datediff(day,max(orders.created_at),
(select max(created_at) from orders)) as days_after_last_purchase
from orders
left join order_item_refunds
on orders.order_id = order_item_refunds.order_id
group by user_id),

scores as(
select *
, ntile(3)over(order by Total_Net_Revenue desc) as Monetary,
ntile(3)over(order by days_after_last_purchase asc) as Recency,
ntile(3)over(order by no_of_times_order desc) as Frequency
from fm_analysis_dist)
,

customer_dist_based_rfm as(
select *,case when Monetary+Recency+Frequency>=6 and Monetary+Recency+Frequency<=9 then 'High_Value_Cust'
when Monetary+Recency+Frequency >3 and Monetary+Recency+Frequency<=6 then 'Medium_Value_Cust'
when Monetary+Recency+Frequency <=3  then 'Low_Value_Cust' end as cust_types
from scores
)

select count( distinct user_id) as users_count,
case when last_cust_type_score<current_cust_type_score then 'Downgraded'
when last_cust_type_score>current_cust_type_score then 'Upgraded'
when last_cust_type_score=current_cust_type_score then 'No change' end as migration_type
from (
select distinct customer_dist_based_rfm.user_id, lag(cust_types)over(partition by customer_dist_based_rfm.user_id
order by created_at) as last_cust_type,cust_types,
case when cust_types ='High_Value_Cust' then 1 
when cust_types ='Medium_Value_Cust' then 2
when cust_types ='Low_Value_Cust' then 3 end as current_cust_type_score 
,
case when lag(cust_types)over(partition by customer_dist_based_rfm.user_id order by created_at) = 'High_Value_Cust' then 1 
when lag(cust_types)over(partition by customer_dist_based_rfm.user_id order by created_at) ='Medium_Value_Cust' then 2
when lag(cust_types)over(partition by customer_dist_based_rfm.user_id order by created_at) ='Low_Value_Cust' then 3 end as last_cust_type_score
from customer_dist_based_rfm
left join orders 
on customer_dist_based_rfm.user_id = orders.user_id
) as ab
where last_cust_type is not null
group by case when last_cust_type_score<current_cust_type_score then 'Downgraded'
when last_cust_type_score>current_cust_type_score then 'Upgraded'
when last_cust_type_score=current_cust_type_score then 'No change' end

---- Website App usage analytics 

select month(session_created_at) as session_created_month,
year(session_created_at) as created_year,count(distinct user_id) as user_traffic,
count(website_session_id) as website_session_counts
from website_360
group by year(session_created_at),month(session_created_at)
order by year(session_created_at),month(session_created_at)

----Conversion funnel analysis

select
count(Distinct case when orders.website_session_id is not null then website_sessions.website_session_id end)*100.00/
count(distinct website_sessions.website_session_id) as conversion_rate,
pageview_url from website_sessions
left join website_pageviews
on website_sessions.website_session_id = website_pageviews.website_session_id
left join orders
on website_sessions.website_session_id = orders.website_session_id
group by pageview_url


----Customer-Win back analysis
select * from(
select *,coalesce(datediff(day,lag(created_at)over(partition by user_id order by order_nos),created_at),0)
as days_since_last_order from(
select user_id,created_at,
ROW_NUMBER()over(partition by user_id order by created_at) as order_nos
from orders) as a
) as ab
where days_since_last_order != 0 and days_since_last_order>=30

----Cross_Device Analysis
select website_sessions.user_id 
,count(distinct device_type) as device_types,
datediff(hour,min(website_sessions.created_at),
max(website_sessions.created_at)) as session_duration,
(count(orders.order_id)*100.00/count(website_sessions.website_session_id))
as conversion_rate
from website_sessions
left join orders
on website_sessions.website_session_id 
= orders.website_session_id
group by website_sessions.user_id
having count(distinct device_type)>1

-----channel attribution Analysis 

;with customer_traffic_path as(
select * ,case when utm_source  in ('gsearch','socialbook','bsearch') then 'Paid'
else 'Free' end as channel_type ,
CASE WHEN utm_source IN ('gsearch','bsearch') THEN 'Paid Search'
        WHEN utm_source = 'socialbook' THEN 'Paid Social'
        WHEN utm_source ='not available' AND http_referer LIKE '%gsearch%' THEN 'Organic Search'
        WHEN utm_source ='not available' AND http_referer LIKE '%bsearch%' THEN 'Organic Search'
        WHEN utm_source ='not available' AND http_referer LIKE '%socialbook%' THEN 'Organic Social'
        ELSE 'Direct' end as channel_name
		from website_sessions)

select channel_name,channel_type,
count(distinct website_sessions.user_id) as Total_customers,
(count(orders.order_id)*100.00/count(website_sessions.website_session_id))
as conversion_rate
from website_sessions
left join orders
on website_sessions.website_session_id 
= orders.website_session_id
left join customer_traffic_path
on website_sessions.website_session_id = 
customer_traffic_path.website_session_id
group by channel_name,channel_type

----Path Analysis
---- the users which are coming on website how they are changing the channels from one to another
---- and there counts 
;with website_summary as(
select *,case when utm_source  in ('gsearch','socialbook','bsearch') then 'Paid'
else 'Free' end as channel_type ,
CASE WHEN utm_source IN ('gsearch','bsearch') THEN 'Paid Search'
        WHEN utm_source = 'socialbook' THEN 'Paid Social'
        WHEN utm_source ='not available' AND http_referer LIKE '%gsearch%' THEN 'Organic Search'
        WHEN utm_source ='not available' AND http_referer LIKE '%bsearch%' THEN 'Organic Search'
        WHEN utm_source ='not available' AND http_referer LIKE '%socialbook%' THEN 'Organic Social'
        ELSE 'Direct' end as channel_name from website_sessions
		)
		,

users_more_than_one_channel as(
select user_id ,count(distinct channel_name) as channel_counts from 
website_summary
group by 
user_id
having count(distinct channel_name)>1
)
,

row_nos as(
select users_more_than_one_channel.user_id,channel_name
,ROW_NUMBER()over(partition by users_more_than_one_channel.
user_id order by 
created_at) as row_no_based_channel
from users_more_than_one_channel
left join website_summary
on users_more_than_one_channel.user_id 
= website_summary.user_id
)
,

channel_seg as(
select * from(
select a.user_id,a.channel_name as First_channel_name,b.channel_name as Second_channel_name
from row_nos as a
left join row_nos  as b
on a.user_id = b.user_id
and a.row_no_based_channel =1 and b.row_no_based_channel =2
and a.channel_name != b.channel_name
) as a
where Second_channel_name is not null
)

select count(distinct user_id) as user_counts
,(case when  First_channel_name = 'Paid Search'
and  Second_channel_name = 'Direct'
then 'Paid_Search_to_Direct' 
when First_channel_name = 'Direct'
and Second_channel_name = 'Paid Search'
then 'Direct_to_Paid_Search' 
when First_channel_name = 'Paid Social'
 and Second_channel_name = 'Paid Search'
then 'Paid_Social_to_Paid_Search' 
when First_channel_name = 'Paid Search'
and  Second_channel_name = 'Paid Social'
then 'Paid_Search_to_Paid_Social' 
when First_channel_name = 'Direct'
and Second_channel_name = 'Paid Social'
then 'Direct_to_Paid_Social'
when  First_channel_name ='Paid Social'
 and Second_channel_name = 'Direct'
then 'Paid_Social_to_Direct'

when  First_channel_name ='Direct'
 and Second_channel_name = 'Organic Search'
then 'Direct_to_Organic_Search'

when  First_channel_name ='Organic Search'
 and Second_channel_name = 'Direct'
then 'Organic_Search_to_Direct'

when  First_channel_name ='Organic Social'
 and Second_channel_name = 'Direct'
then 'Organic_Social_Direct'

when  First_channel_name ='Paid Search'
 and Second_channel_name = 'Organic Search'
then 'Paid Search_to_Organic Search'

end) as Channel_change from channel_seg
group by  
(case when  First_channel_name = 'Paid Search'
and  Second_channel_name = 'Direct'
then 'Paid_Search_to_Direct' 
when First_channel_name = 'Direct'
and Second_channel_name = 'Paid Search'
then 'Direct_to_Paid_Search' 
when First_channel_name = 'Paid Social'
 and Second_channel_name = 'Paid Search'
then 'Paid_Social_to_Paid_Search' 
when First_channel_name = 'Paid Search'
and  Second_channel_name = 'Paid Social'
then 'Paid_Search_to_Paid_Social' 
when First_channel_name = 'Direct'
and Second_channel_name = 'Paid Social'
then 'Direct_to_Paid_Social'
when  First_channel_name ='Paid Social'
 and Second_channel_name = 'Direct'
then 'Paid_Social_to_Direct'

when  First_channel_name ='Direct'
 and Second_channel_name = 'Organic Search'
then 'Direct_to_Organic_Search'

when  First_channel_name ='Organic Search'
 and Second_channel_name = 'Direct'
then 'Organic_Search_to_Direct'

when  First_channel_name ='Organic Social'
 and Second_channel_name = 'Direct'
then 'Organic_Social_Direct'

when  First_channel_name ='Paid Search'
 and Second_channel_name = 'Organic Search'
then 'Paid Search_to_Organic Search'

end)

------Customer Cohort Analysis 
;with first_orders as(
select min(created_at) as first_order_date,user_id from orders
group by user_id),

first_order as(
select 
---month(first_order_date) as cohort_month
DATEFROMPARTS(year(first_order_date),month(first_order_date),1)as cohort_month
,first_order_date,user_id 
from first_orders),

orders_with_cohorts as(
select orders.created_at as order_date,
first_order_date , cohort_month,orders.user_id,price_usd from first_order
left join orders  
on first_order.user_id = orders.user_id),

month_after_first_order as(
select user_id,cohort_month,DATEFROMPARTS(year(order_date),month(order_date),1) as order_month,
Datediff(month,cohort_month,order_date) as month_after_first_order,price_usd
from orders_with_cohorts)

select cohort_month,order_month,count(distinct user_id)
as customer_counts,sum(price_usd) as revenue
from month_after_first_order
group by cohort_month,order_month
order by cohort_month,order_month

----Traffic Drop Analysis 

;with website_analysis as(
select * ,CASE
            WHEN utm_source IN ('gsearch','bsearch') THEN 'Paid Search'
            WHEN utm_source = 'socialbook' THEN 'Paid Social'
            WHEN utm_source ='not available' AND http_referer LIKE '%gsearch%' THEN 'Organic Search'
            WHEN utm_source ='not available' AND http_referer LIKE '%bsearch%' THEN 'Organic Search'
            WHEN utm_source ='not available' AND http_referer LIKE '%socialbook%' THEN 'Organic Social'
            ELSE 'Direct' end as channel_name ,
			case when 
			utm_source IN ('gsearch','bsearch','socialbook') THEN 'Paid'
  ELSE 'Free'
END AS channel_type
			---utm_source = 'not available' then 'Free' else 'Paid' end as  channel_type			
from website_sessions),

visitors_segement as(
select count( distinct user_id) as user_counts ,
count(distinct website_session_id)as website_session_counts ,
Months,years,Type_of_visitor,channel_name,channel_type 
from(
select Month(created_at) as Months,
year(created_at) as years ,user_id,website_session_id,
---,
channel_name,channel_type
,case when is_repeat_session =1 then 'Repeat_visitor'
else 'One_time_visitor' end as 'Type_of_visitor' from website_analysis

---,channel_name,channel_type)
)as a
group by Months,years,Type_of_visitor,channel_name,channel_type)
--order by years,Months

select Years,Months,type_of_visitor,channel_name,channel_type, (user_counts-
lag(user_counts)over(partition by type_of_visitor,channel_name,channel_type order by Years,Months))*1.0
/lag(user_counts)over(partition by type_of_visitor,channel_name,channel_type  order by Years,Months)
as change_in_user_counts
from visitors_segement

-----Device platform specific diagnostic 
---Change_in traffic of user by device type on the basis of month and years .

select years,Months,
(user_counts-lag(user_counts)over(partition by device_type order by years,Months))*1.0/
lag(user_counts)over(partition by device_type order by years,Months) as change_in_traffic
from( 
select Month(created_at) as Months,
year(created_at) as years,count(distinct user_id) as user_counts ,device_type 
from website_sessions
group by device_type,Month(created_at),year(created_at)
) as a

-----User Enagagement Decline Analysis 
---Month & year wise decline 

;with cust_type as(
select *,case when row_no = 1 then 'New_Customer'
else 'Repeat_Customer' end as Customer_Type from(
select *,ROW_NUMBER()over(partition by user_id order by created_at) as row_no
from orders ) as a),

active_durations as(
select Month(created_at) as Months,year(created_at) as years,user_id
, datediff(Hour,min(created_at),max(created_at)) as Active_hours,
count(distinct website_session_id) as 
website_session_id_counts 
from website_sessions
group by user_id,Month(created_at),year(created_at))
,

sessions_dist as(
select user_id,count(website_pageview_id) as count_pages_visited,
Sum(Case when pageview_url= '/home' then 1 else 0 end) as Home_page_flag,
Sum(Case when pageview_url= '/lander-1' then 1 else 0 end) as Lander_1_page_flag,
Sum(Case when pageview_url= '/lander-2' then 1 else 0 end) as Lander_2_page_flag,
Sum(Case when pageview_url= '/lander-3' then 1 else 0 end) as Lander_3_page_flag,
Sum(Case when pageview_url= '/lander-4' then 1 else 0 end) as Lander_4_page_flag,
Sum(Case when pageview_url= '/lander-5' then 1 else 0 end) as Lander_5_page_flag,
Sum(Case when pageview_url= '/products' then 1 else 0 end) as Products_page_flag,
Sum(Case when pageview_url= '/the-original-mr-fuzzy' then 1 else 0 end) as The_original_mr_fuzzy_flag,
Sum(Case when pageview_url= '/the-forever-love-bear' then 1 else 0 end) as The_forever_love_bear_flag,
Sum(Case when pageview_url= '/the-birthday-sugar-panda' then 1 else 0 end) as The_birthday_sugar_panda_flag,
Sum(Case when pageview_url= '/the-hudson-river-mini-bear' then 1 else 0 end) as The_hudson_river_mini_bear_flag,
Sum(Case when pageview_url= '/cart' then 1 else 0 end) as Cart_page_flag,
Sum(Case when pageview_url= '/shipping' then 1 else 0 end) as Shipping_page_flag,
Sum(Case when pageview_url= '/billing' then 1 else 0 end) as Billing_page_flag,
Sum(Case when pageview_url= '/billing-2' then 1 else 0 end) as Billing_2_page_flag,
Sum(Case when pageview_url= '/thank-you-for-your-order' then 1 else 0 end) as Thanking_page_flag
from website_pageviews
left join orders 
on website_pageviews.website_session_id = 
orders.website_session_id
group by user_id),

cust_engagement_summary as(
select Years,Months,count(distinct cust_type.user_id) as customer_counts
,avg(active_hours) as avg_active_hours ,sum(count_pages_visited) as count_pages_visited,
Customer_Type,sum(items_purchased) as Total_items_Purchased,sum(website_session_id_counts) as website_session_counts,
(count(distinct order_id)*100.0/sum(website_session_id_counts)) as conversion_rate
from cust_type
left join active_durations
on cust_type.user_id = active_durations.user_id
left join sessions_dist
on Cust_type.user_id = sessions_dist.user_id
group by Customer_Type,years,Months
)

select Years,Months,Customer_Type,(customer_counts - lag(customer_counts)over(partition by Customer_Type order by Years,Months))*1.0
/lag(customer_counts)over(partition by Customer_Type order by Years,Months) as customer_counts_prct_change
,
(website_session_counts - lag(website_session_counts)over(partition by Customer_Type order by Years,Months))*1.0
/lag(website_session_counts)over(partition by Customer_Type order by Years,Months) as website_session_counts_prct_change,
(conversion_rate - lag(conversion_rate)over(partition by Customer_Type order by Years,Months))*1.0
/lag(conversion_rate)over(partition by Customer_Type order by Years,Months) as conversion_rate_prct_change
from cust_engagement_summary

----Vedio Engagement Decline Analysis.
----Not Possible 

----Conversion Rate Drop analysis 

select years,months,(conversion_rate - lag(conversion_rate)over(order by years,months))*1.0/
lag(conversion_rate)over(order by years,months) as coversion_rate_prct_change from(
select count(distinct order_id)*1.0/count(distinct website_sessions.website_session_id) as conversion_rate
,year(website_sessions.created_at) as years,month(website_sessions.created_at) as months
from website_sessions
left join orders 
on website_sessions.website_session_id = orders.website_session_id
group by year(website_sessions.created_at),month(website_sessions.created_at)
) as a 

---page_load speed analysis 
---Not possible

---Landing page performance diagnostic

;with website_page_sessions as(
select a.website_session_id,a.website_pageview_id,
pageview_url from(
select min(website_pageview_id) as website_pageview_id, 
website_session_id from website_pageviews
group by website_session_id) as a
join website_pageviews
on a.website_session_id = website_pageviews.website_session_id 
and a.website_pageview_id = website_pageviews.website_pageview_id
)

select pageview_url, count(distinct website_page_sessions.website_session_id) as count_sessions,
count(distinct order_id)*1.0/count(distinct website_page_sessions.website_session_id)
as conversion_rate
from website_sessions
left join website_page_sessions
on website_sessions.website_session_id = website_page_sessions.website_session_id
left join orders
on website_page_sessions.website_session_id = orders.website_session_id
where pageview_url is not null
group by pageview_url

----Bounce Rate analysis 

;with bouncing as(
select *,
case when no_times_page_viewed=1 then 1 else 0 end as is_bounce
from(
select website_session_id,
count(distinct website_pageview_id) as no_times_page_viewed
from website_pageviews
group by website_session_id ) as a),

bounce_rates as(
select b.website_session_id,page_view_id,pageview_url,is_bounce from(
select bouncing.website_session_id 
,is_bounce,min(website_pageviews.website_pageview_id)as page_view_id
from bouncing
left join website_pageviews
on bouncing.website_session_id = website_pageviews.website_session_id
group by bouncing.website_session_id 
,is_bounce)
as b
left join website_pageviews
on b.page_view_id = website_pageviews.website_pageview_id and 
b.website_session_id = website_pageviews.website_session_id)

select pageview_url,sum(is_bounce)*1.0/count(website_session_id) as bounce_rates from 
bounce_rates
group by pageview_url

----Content Abandonment Analysis 

select * 
,
case when Total_pages_viewed = 1 then 'Is_Bounced'
when Total_pages_viewed between 2 and 6 then 'Abandonment'
else 'Purchased' end as user_type 
from(
select month(created_at)as Months
,year(created_at) as years ,
website_session_id,count(website_pageview_id)as Total_pages_viewed,min(website_pageview_id)
as first_ladder
from website_pageviews
group by website_session_id,month(created_at)
,year(created_at)) as a
left join website_pageviews
on a.website_session_id = website_pageviews.website_session_id
and a.first_ladder = website_pageviews.website_pageview_id

------Content Relevance Analysis 

select *,
case 
when orders.website_session_id is not null then 'Purchased'
when no_times_page_viewed=1 then 'is_bounce'
when no_times_page_viewed between 2 and 6 then 'abandoned'
end as session_relevance
from(
select website_session_id,
count(distinct website_pageview_id) as no_times_page_viewed
from website_pageviews
group by website_session_id ) as a
left join orders
on a.website_session_id = orders.website_session_id
 
---Campaign Performance Analysis 

;with website_summary as(
select *,case when utm_source  in ('gsearch','socialbook','bsearch') then 'Paid'
else 'Free' end as channel_type ,
CASE WHEN utm_source IN ('gsearch','bsearch') THEN 'Paid Search'
        WHEN utm_source = 'socialbook' THEN 'Paid Social'
        WHEN utm_source ='not available' AND http_referer LIKE '%gsearch%' THEN 'Organic Search'
        WHEN utm_source ='not available' AND http_referer LIKE '%bsearch%' THEN 'Organic Search'
        WHEN utm_source ='not available' AND http_referer LIKE '%socialbook%' THEN 'Organic Social'
        ELSE 'Direct' end as channel_name
from website_sessions)

select channel_type,channel_name,count(distinct website_summary.user_id) as
total_count_users,count(distinct website_summary.website_session_id) as session_counts ,
utm_campaign,count(distinct orders.order_id)*100.0/count(distinct website_summary.website_session_id)
as conversion_rate
from website_summary
--left join website_pageviews
--on website_summary.website_session_id = website_pageviews.website_session_id
left join orders 
on website_summary.website_session_id = orders.website_session_id
group by channel_type,channel_name,utm_campaign

----Customer support analysis
----not possible

----Referral Traffic Analysis 

select customer_type,years,months,
(Advocacy_Distributions_Counts - lag(Advocacy_Distributions_Counts)over
(partition by customer_type order by years,months))*1.0/lag(Advocacy_Distributions_Counts)over
(partition by customer_type order by years,months)
as change_referal_traffic from(
select Months,Years,count(*) as Advocacy_Distributions_Counts,
(case when potential_advocates_score<=4
then 'New_Unproven'
when potential_advocates_score>4 and potential_advocates_score<=8
then 'Normal_Customer'
when potential_advocates_score>8 and potential_advocates_score<=10
then 'Potential_Advocates'
when potential_advocates_score>10 then
'Strong_Advocates'
end) as Customer_Type
from(
select*,
refund_score + Customer_life_time_value + orders_score as potential_advocates_score from(
select *,(case when 
item_refunded_prct = 0.0 then 5
when item_refunded_prct >0.00 and item_refunded_prct <0.30 then 3
when item_refunded_prct >=0.30 and item_refunded_prct <=0.6 then 2
when item_refunded_prct>0.6 then 1
end) as refund_score 
,
(case when 
customer_lifetime_days >= 0 and customer_lifetime_days <=30  then 0
when customer_lifetime_days > 30 and customer_lifetime_days <=60 then 2
when customer_lifetime_days > 60 and customer_lifetime_days <=90 then 4
when customer_lifetime_days > 90  then 5
end) as Customer_life_time_value,

(case when 
total_orders=1 then 3
when total_orders=2 then 4
when total_orders=3 then 5
end) as orders_score 
from(
select Month(created_at) as Months,Year(created_at)as years,
total_refunded_items*1.0/total_items_purchased as item_refunded_prct,
customer_lifetime_days,total_orders
from customer_360
left join orders 
on Customer_360.customer_id = orders.user_id
)as a) as ab
) as abc
group by (case when potential_advocates_score<=4
then 'New_Unproven'
when potential_advocates_score>4 and potential_advocates_score<=8
then 'Normal_Customer'
when potential_advocates_score>8 and potential_advocates_score<=10
then 'Potential_Advocates'
when potential_advocates_score>10 then
'Strong_Advocates'
end),
Months,Years) as a
order by Years,Months


-------Organic Traffic Analysis
---Not possible
select 
case WHEN utm_source ='not available' AND http_referer LIKE '%gsearch%' THEN 'Organic Search'
        WHEN utm_source ='not available' AND http_referer LIKE '%bsearch%' THEN 'Organic Search'
        WHEN utm_source ='not available' AND http_referer LIKE '%socialbook%' THEN 'Organic Social' end as k
from website_sessions
where 
case WHEN utm_source ='not available' AND http_referer LIKE '%gsearch%' THEN 'Organic Search'
        WHEN utm_source ='not available' AND http_referer LIKE '%bsearch%' THEN 'Organic Search'
        WHEN utm_source ='not available' AND http_referer LIKE '%socialbook%' THEN 'Organic Social' end 
 is not null

 ----Customer_Retention Analysis 
 
 select sum(repeat_customer_counts) from(
 select Months,Years ,(count(case when user_counts>1 then user_id end)
 *100.00/count(distinct
 user_id)) as repeat_rate,avg(cust_lifetime)as avg_lifetime,
 count(case when user_counts>1 then user_id end) as repeat_customer_counts,
 count(distinct
 user_id) as total_customers
 from(
 select Month(created_at) as Months ,year(created_at) as years,
 datediff(day,min(created_at)
 ,max(created_at)) as cust_lifetime
 ,user_id,count(*)as user_counts from orders 
 group by user_id,Month(created_at) ,year(created_at)) as a
 group by Months,Years) as ab

 ----Revenue Decline Analysis
 select 
 Months,Years,
 ((Total_revenue - lag(Total_revenue)over(order by years,months))*1.0 /
 lag(Total_revenue)over(order by years,months)) as change_total_revenue_prct,
 ((Total_net_revenue - lag(Total_net_revenue)over(order by years,months))*1.0 /
 lag(Total_net_revenue)over(order by years,months)) as change_total_net_revenue_prct,
 ((refund_rate -lag(refund_rate)over(order by years,months))*1.0/lag(refund_rate)
 over(order by years,months)) as prct_change_refund_rate
 from(
 select Month(orders.created_at) as Months ,
 Year(orders.created_at) as Years,
 sum(price_usd)as Total_revenue ,
 (sum(price_usd) - sum(case when order_item_refunds.order_id is not null then order_item_refunds.refund_amount_usd
 else 0 end )) as Total_net_revenue,count(orders.order_id) as Total_orders,
 (count(case when order_item_refunds.order_id is not null then order_item_refunds.order_id end)*1.0/
 count(orders.order_id)) as refund_rate
 from orders 
 left join order_item_refunds
 on orders.order_id = order_item_refunds.order_id
 group by Month(orders.created_at) , Year(orders.created_at)) as a
 

----App feature diagnostic not possible

----Cart abandonment 

;with website_analysis as(
select website_pageview_id,pageview_url,website_sessions.website_session_id,
max(website_pageview_id)over(partition by website_sessions.website_session_id order by website_pageview_id) as last_page_view
from website_sessions
left join website_pageviews
on website_sessions.website_session_id = website_pageviews.website_session_id
)

select pageview_url, website_session_id,last_page_view from website_analysis
where website_pageview_id = last_page_view
group by website_session_id

------Cart_Abandonment_Analysis

;with pages_summary as (
select a.website_session_id,pageview_url from(
select max(website_pageview_id) as last_page_id  ,
website_sessions.website_session_id 
from website_sessions
left join website_pageviews
on website_sessions.website_session_id = website_pageviews.website_session_id
group by website_sessions.website_session_id
) as a
left join website_pageviews
on a.website_session_id = website_pageviews.website_session_id
and a.last_page_id = website_pageviews.website_pageview_id
)

select 
count(case when pageview_url = '/cart' then 1 end) as cart_abandonment_sessions
from pages_summary
left join orders 
on pages_summary.website_session_id = orders.website_session_id
where orders.website_session_id is null

----Referral Span Traffic Analysis 
--- not possible

---- Seasonal_Impact_Diagnostic 

with Month_year_dist as (
select 
format(session_created_at,'yyyy-MM') as Month_years,
count(user_id)as number_of_users from website_360
group by format(session_created_at,'yyyy-MM')

)

select Month_years,
(number_of_users-lag(number_of_users)over(order by Month_years))*100/
nullif(lag(number_of_users)over(order by Month_years),0)
as prct_change
from Month_year_dist

----Product Performance Decline Analysis 

select * , (Total_net_revenue - lag(Total_net_revenue)over(partition by product_name order
by year_month))*1.0/lag(Total_net_revenue)over(partition by product_name order
by year_month) as perct_chn_total_net_revenue from(
select product_name ,
---month(orders.created_at) as Months , year(orders.created_at) as years,
sum(items_purchased) as count_items_purchased,
DATEFROMPARTS(year(orders.created_at),month(orders.created_at),1) as year_month,
sum(orders.price_usd)- sum(case when order_item_refunds.order_id is not null then refund_amount_usd else 0 end)
as Total_net_revenue,
count(distinct order_item_refunds.order_item_id)*1.0/count(distinct order_items.order_item_id)
as refund_rate
from orders 
left join order_items
on orders.order_id = order_items.order_id
left join order_item_refunds
on order_items.order_id = order_item_refunds.order_id 
and order_items.order_item_id = order_item_refunds.order_item_id
left join products
on orders.primary_product_id = products.product_id
group by product_name,DATEFROMPARTS(year(orders.created_at),month(orders.created_at),1)
) as a

---Search engine crawling /indexing diagnostic 
----not possible 

----Audience Segmentation Performance Diagnostic 

;with website_order_agg as(
select website_sessions.user_id,count(orders.website_session_id) as orders_count,
count(website_sessions.website_session_id) as 
website_session_counts 
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
group by website_sessions.user_id)

select count(*) as customer_traffic_counts, (case when website_session_counts=1 and 
orders_count =0 then 'One_Time_Customer_with_no_purchase' 
when website_session_counts=1 and 
orders_count >0 then 'One_Time_Customer_with_purchase'
when website_session_counts>1 and 
orders_count =0 then 'Repeat_Customer_with_no_purchase'
when website_session_counts>1 and 
orders_count >0 then 'Repeat_Customer_with_purchase' end) as 
customer_traffic from website_order_agg
group by (case when website_session_counts=1 and 
orders_count =0 then 'One_Time_Customer_with_no_purchase' 
when website_session_counts=1 and 
orders_count >0 then 'One_Time_Customer_with_purchase'
when website_session_counts>1 and 
orders_count =0 then 'Repeat_Customer_with_no_purchase'
when website_session_counts>1 and 
orders_count >0 then 'Repeat_Customer_with_purchase' end)


-----On site search behaviour 
---can't perform this 
---form completion 
---app uninstall
----User- experience heatmap analysis 
----User experience heatmap analysis could not be conducted due to 
---lack of click, scroll, and interaction-level tracking data



----customer win back analysis 


----------------------------------------------Behavioural Segmentation-------------------

-----Behavioural segmentation using scientific approach
--it is same as rfm,customer_life cycle...

---Email engagement segmentation 
-- data not having emails info

---Social Behaviour Segments 
;with website_summary as(
select website_sessions.created_at,website_sessions.user_id,
case when utm_source  in ('gsearch','socialbook','bsearch') then 'Paid'
else 'Free' end as channel_type ,
CASE WHEN utm_source IN ('gsearch','bsearch') THEN 'Paid Search'
        WHEN utm_source = 'socialbook' THEN 'Paid Social'
        WHEN utm_source ='not available' AND http_referer LIKE '%gsearch%' THEN 'Organic Search'
        WHEN utm_source ='not available' AND http_referer LIKE '%bsearch%' THEN 'Organic Search'
        WHEN utm_source ='not available' AND http_referer LIKE '%socialbook%' THEN 'Organic Social'
        ELSE 'Direct' end as channel_name
		--case when orders.order_id is not null then 'ordered' else 'not_ordererd' end as
		--ordered_or_not_ordered
		from website_sessions
		
		)
		,

users_more_than_one_channel as(
select case when
exists 
(select 1 from orders o
where o.user_id = website_summary.user_id)
 then 'ordered' else 'not ordered' end as
ordered_or_not_ordered
,website_summary.user_id ,count(distinct channel_name) as channel_counts from 
website_summary
group by 
website_summary.user_id
having count(distinct channel_name)>1
)
,

row_nos as(
select users_more_than_one_channel.user_id,users_more_than_one_channel.ordered_or_not_ordered
,channel_name
,ROW_NUMBER()over(partition by users_more_than_one_channel.
user_id order by 
created_at) as row_no_based_channel
from users_more_than_one_channel
left join website_summary
on users_more_than_one_channel.user_id 
= website_summary.user_id
)
,

channel_seg as(
select * from(
select a.user_id,a.channel_name as First_channel_name,b.channel_name as Second_channel_name,
a.ordered_or_not_ordered
from row_nos as a
left join row_nos  as b
on a.user_id = b.user_id
and a.row_no_based_channel =1 and b.row_no_based_channel =2
and a.channel_name != b.channel_name

) as a
where Second_channel_name is not null
)

select count(distinct user_id) as user_counts,ordered_or_not_ordered
,(case when  First_channel_name = 'Paid Search'
and  Second_channel_name = 'Direct'
then 'Paid_Search_to_Direct' 
when First_channel_name = 'Direct'
and Second_channel_name = 'Paid Search'
then 'Direct_to_Paid_Search' 
when First_channel_name = 'Paid Social'
 and Second_channel_name = 'Paid Search'
then 'Paid_Social_to_Paid_Search' 
when First_channel_name = 'Paid Search'
and  Second_channel_name = 'Paid Social'
then 'Paid_Search_to_Paid_Social' 
when First_channel_name = 'Direct'
and Second_channel_name = 'Paid Social'
then 'Direct_to_Paid_Social'
when  First_channel_name ='Paid Social'
 and Second_channel_name = 'Direct'
then 'Paid_Social_to_Direct'

when  First_channel_name ='Direct'
 and Second_channel_name = 'Organic Search'
then 'Direct_to_Organic_Search'

when  First_channel_name ='Organic Search'
 and Second_channel_name = 'Direct'
then 'Organic_Search_to_Direct'

when  First_channel_name ='Organic Social'
 and Second_channel_name = 'Direct'
then 'Organic_Social_to_Direct'

when  First_channel_name ='Direct'
 and Second_channel_name = 'Organic Social'
then 'Direct_to_Organic_Social'

when  First_channel_name ='Paid Search'
 and Second_channel_name = 'Organic Search'
then 'Paid Search_to_Organic Search'

when  First_channel_name ='Organic Search'
 and Second_channel_name = 'Paid Search'
then 'Organic Search_to_Paid Search'

when  First_channel_name ='Organic Search'
 and Second_channel_name = 'Paid Social'
then 'Organic Search_to_Paid Social'
end
) as Channel_change from channel_seg
group by  
(case when  First_channel_name = 'Paid Search'
and  Second_channel_name = 'Direct'
then 'Paid_Search_to_Direct' 
when First_channel_name = 'Direct'
and Second_channel_name = 'Paid Search'
then 'Direct_to_Paid_Search' 
when First_channel_name = 'Paid Social'
 and Second_channel_name = 'Paid Search'
then 'Paid_Social_to_Paid_Search' 
when First_channel_name = 'Paid Search'
and  Second_channel_name = 'Paid Social'
then 'Paid_Search_to_Paid_Social' 
when First_channel_name = 'Direct'
and Second_channel_name = 'Paid Social'
then 'Direct_to_Paid_Social'
when  First_channel_name ='Paid Social'
 and Second_channel_name = 'Direct'
then 'Paid_Social_to_Direct'

when  First_channel_name ='Direct'
 and Second_channel_name = 'Organic Search'
then 'Direct_to_Organic_Search'

when  First_channel_name ='Organic Search'
 and Second_channel_name = 'Direct'
then 'Organic_Search_to_Direct'

when  First_channel_name ='Organic Social'
 and Second_channel_name = 'Direct'
then 'Organic_Social_to_Direct'

when  First_channel_name ='Direct'
 and Second_channel_name = 'Organic Social'
then 'Direct_to_Organic_Social'

when  First_channel_name ='Paid Search'
 and Second_channel_name = 'Organic Search'
then 'Paid Search_to_Organic Search'

when  First_channel_name ='Organic Search'
 and Second_channel_name = 'Paid Search'
then 'Organic Search_to_Paid Search'

when  First_channel_name ='Organic Search'
 and Second_channel_name = 'Paid Social'
then 'Organic Search_to_Paid Social'

end),ordered_or_not_ordered

-----Checkout Preference Segments 

select count(*) as user_counts,case when website_sessions_count<=2 
then 'Fast_Checkout_users'
when website_sessions_count between 2 and 5 
then 'Considered_Checkout_users'
when website_sessions_count >5
then 'Friction_Sensitive_users' end as type_of_preference_checkouts
from(
select orders.user_id,count(website_sessions.website_session_id)
as website_sessions_count from orders
left join website_sessions
on orders.user_id =
website_sessions.user_id
group by orders.user_id) as a
group by case when website_sessions_count<=2 
then 'Fast_Checkout_users'
when website_sessions_count between 2 and 5 
then 'Considered_Checkout_users'
when website_sessions_count >5
then 'Friction_Sensitive_users' end


select * from orders 
select top 5 * from website_sessions

-------- device shift conversion shift 

;with duplicated_devices as(
select user_id from(
select count(*) as row_counts,user_id,device_type from website_sessions
group by user_id,device_type
) as a
where row_counts>1)
,

summarize as(
select duplicated_devices.user_id,website_session_id,created_at,is_repeat_session,
utm_source,utm_campaign,device_type,http_referer from duplicated_devices
left join website_sessions 
on duplicated_devices.user_id = website_sessions.user_id
)
,

renaming_device_shift as(
select device_type,user_id,row_number()over(partition by user_id order by created_at) 
as orderd_orders,website_session_id
from summarize
),

remove_duplicated as(
select CONCAT(a.device_type,'+',b.device_type) as device_combos,
a.user_id,orders.order_id,a.website_session_id
from 
renaming_device_shift as a
left join renaming_device_shift as b
on a.user_id = b.user_id
left join orders
on a.user_id = orders.user_id
where a.orderd_orders = 1 and b.orderd_orders 
= 2 and a.device_type<> b.device_type
)


select device_combos,CAST(orders_count AS DECIMAL(10,2)) / session_counts * 100 from(
select device_combos, count(distinct user_id) as 
users_counts , count(distinct order_id) as orders_count ,count(distinct website_session_id)
as session_counts
from remove_duplicated
group by device_combos) as ab

