/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

	select customer_id,sum(price) from sales join
    menu
    on sales.product_id = menu.product_id
    group by sales.customer_id;
    
-- 2. How many days has each customer visited the restaurant?

	select customer_id,count(distinct order_date) from sales
    group by customer_id;
    
-- 3. What was the first item from the menu purchased by each customer?

	with cte as
    (
	select customer_id,order_date,product_name,
    rank() over(partition by customer_id order by order_date) as rnk,
    row_number() over(partition by customer_id order by order_date) as row_num
    from sales
    join menu
    on sales.product_id = menu.product_id
    )
    select customer_id,product_name 
    from cte
    where row_num = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

		select product_name,count(product_name) as cnt from sales
        join menu
        on sales.product_id = menu.product_id
        group by product_name
        order by cnt desc
        limit 1;
        
-- 5. Which item was the most popular for each customer?

	with cte as(
		select customer_id,product_name,count(product_name) as cnt,
        rank() over(partition by customer_id order by count(product_name) desc) as rnk,
        row_number() over(partition by customer_id order by count(product_name) desc) as row_num
		from sales
        join
        menu
        on sales.product_id = menu.product_id
        group by customer_id,product_name
	)
    select customer_id,product_name from cte where row_num = 1;
        
-- 6. Which item was purchased first by the customer after they became a member?
  with cte as
	(
	select sales.customer_id,product_name,
    rank() over(partition by sales.customer_id order by order_date) as rnk  
    from sales
    join members
    on sales.customer_id = members.customer_id
    join menu
    on sales.product_id = menu.product_id
    where order_date>=join_date
    )
    select * from cte where rnk = 1;
-- 7. Which item was purchased just before the customer became a member?

	with cte as
	(
	select sales.customer_id,product_name,order_date,join_date,
    rank() over(partition by sales.customer_id order by order_date desc) as rnk  
    from sales
    join members
    on sales.customer_id = members.customer_id
    join menu
    on sales.product_id = menu.product_id
    where order_date<join_date
    )
    select customer_id,product_name from cte where rnk = 1;
    
-- 8. What is the total items and amount spent for each member before they became a member?
	select sales.customer_id,count(menu.product_id),sum(price)
    from sales
    join members
    on sales.customer_id = members.customer_id
    join menu
    on sales.product_id = menu.product_id
    where order_date<join_date
    group by sales.customer_id;
    
    
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

	select customer_id,
    sum(case
    when product_name = 'sushi' then price * 10 *2
    else price *10
    end ) as points
    from menu
    join sales
    on menu.product_id = sales.product_id
    group by customer_id;
    
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
	select sales.customer_id,
    sum(case
    when order_date between join_date and date_add(join_date,interval 6 day) then price *10*2
    when product_name = 'sushi' then price * 10 *2
    else price *10
    end)  as points
    from menu
    join sales
    on menu.product_id = sales.product_id
    join members
    on members.customer_id = sales.customer_id
    where date_format(order_date,'%Y-%m-01') = '2021-01-01' 
    group by customer_id
    order by customer_id;
    
-- Bonus Questions

-- Check wheter the customer was a member when he ordered the food create a corresponding column if he was a member add 'Y' and if he was not a member 'N'

select sales.customer_id,sales.order_date,menu.product_name,price,
case
	when join_date is null then 'N'
    when order_date<join_date then 'N'
    else 'Y'
end as member
from sales
join menu
on sales.product_id = menu.product_id
left join members
on sales.customer_id = members.customer_id
order by sales.customer_id,order_date,price desc;    


-- Rank all things
with cte as(
select sales.customer_id,sales.order_date,menu.product_name,price,
case
	when join_date is null then 'N'
    when order_date<join_date then 'N'
    else 'Y'
end as member
from sales
join menu
on sales.product_id = menu.product_id
left join members
on members.customer_id = sales.customer_id
order by sales.customer_id,order_date,price desc
)
select *,
case
	when member = 'N' then NULL
    else rank() over(partition by customer_id,member order by order_date)
end as rnk
from cte;    
 
    
-- Example Query:
SELECT
  	product_id,
    product_name,
    price
FROM dannys_diner.menu
ORDER BY price DESC
LIMIT 5;