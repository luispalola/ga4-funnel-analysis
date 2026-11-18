-- q4. products: what the items list looks like per event

select
    event_name,
    count(*) as item_rows,
    count(distinct item.item_name) as distinct_items,
    countif(item.item_name = '(not set)') as not_set_names
from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
unnest(items) as item
where event_name in ('view_item', 'add_to_cart', 'purchase')
group by event_name;

-- q4b. items per event: item rows vs distinct product names inside each event

select
    event_name,
    count(*) as events,
    countif(array_length(items) = 0) as events_no_items,
    round(avg(array_length(items)), 2) as avg_items,
    round(avg((select count(distinct i.item_name) from unnest(items) as i)), 2) as avg_distinct_names,
    max(array_length(items)) as max_items
from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
where event_name in ('view_item', 'add_to_cart', 'purchase')
group by event_name;

-- q4c. top products by revenue (real, deduplicated purchases only)

with purchased_items as (
    select distinct
        ecommerce.transaction_id,
        item.item_name,
        item.item_variant,
        item.quantity,
        item.item_revenue_in_usd as item_revenue
    from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
    unnest(items) as item
    where event_name = 'purchase'
    and ecommerce.transaction_id != '(not set)'
)

select
    item_name,
    count(distinct transaction_id) as orders,
    sum(quantity) as units,
    sum(item_revenue) as revenue,
    sum(sum(item_revenue)) over () as all_products_revenue
from purchased_items
group by item_name
order by revenue desc
limit 20;