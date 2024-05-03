SELECT * FROM dannys_diner.members;

-- 6.	Which item was purchased first by the customer after they became a member?
with ranked as (
select
	mb.customer_id,
    s.order_date,
    mb.join_date,
    m.product_name,
    rank() over(partition by mb.customer_id order by s.order_date) as ranks
from
	dannys_diner.sales as s
		join
	dannys_diner.menu as m
		on s.product_id=m.product_id
        join
	dannys_diner.members as mb
		on mb.customer_id=s.customer_id
where
	order_date >= join_date)
    
select customer_id, product_name from ranked where ranks=1;


-- 7.	Which item was purchased just before the customer became a member?
with ranked as (
select
	s.customer_id,
    s.order_date,
    m.product_name,
    mm.join_date,
    rank() over(partition by s.customer_id order by s.order_date desc) as ranks
from 
	dannys_diner.sales as s
		join
	dannys_diner.menu as m on s.product_id=m.product_id
		join
	dannys_diner.members as mm on s.customer_id=mm.customer_id
where
	order_date < join_date)
    
select customer_id, product_name from ranked where ranks=1;
	
-- 8. What are the total items and amount spent for each member before they became a member?

select
	s.customer_id,
    count(m.product_name) as total_number_of_items,
    sum(m.price) as total_spent
from
	sales as s
		join
	menu as m on s.product_id=m.product_id
		join
	members as mm on s.customer_id=mm.customer_id

where
	s.order_date < mm.join_date
    
group by s.customer_id
order by 1;
		
-- 9.	If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

-- Case= To create a custom column based on some condition. must be written in the select clause

with menu_points as (
select
	product_id,
    product_name,
    price,
    case
		when product_id= 1 then price * 20
        else price * 10
	end as points
from
	dannys_diner.menu)
    
select
	s.customer_id,
    sum(mp.points) as total_points
from
	dannys_diner.sales as s
		join
	menu_points as mp on s.product_id=mp.product_id
group by
	1;



