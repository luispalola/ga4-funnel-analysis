-- session base table: one row per session

with events as (
    select
        user_pseudo_id,
        (select value.int_value from unnest(event_params)
        where key = 'ga_session_id') as session_id,
        (select value.int_value from unnest(event_params)
        where key = 'ga_session_number') as session_number,
        event_timestamp,
        event_name,
        device.category as device,
        (select value.string_value from unnest(event_params)
        where key = 'source') as source,
        (select value.string_value from unnest(event_params)
        where key = 'medium') as medium,
        ecommerce.transaction_id,
        ecommerce.purchase_revenue_in_usd as revenue
    from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
),

purchases as (
    select
        transaction_id,
        user_pseudo_id,
        session_id,
        revenue,
        row_number() over (partition by transaction_id order by event_timestamp) as copy_number
    from events
    where event_name = 'purchase'
    and transaction_id != '(not set)'
),

sessions as (
    select
        user_pseudo_id,
        session_id,
        min(event_timestamp) as session_start_time,
        max(session_number) as session_number,
        array_agg(device ignore nulls order by event_timestamp limit 1)[safe_offset(0)] as device,
        array_agg(source ignore nulls order by event_timestamp limit 1)[safe_offset(0)] as source,
        array_agg(medium ignore nulls order by event_timestamp limit 1)[safe_offset(0)] as medium,
        min(if(event_name = 'view_item', event_timestamp, null)) as first_view_item_time,
        min(if(event_name = 'add_to_cart', event_timestamp, null)) as first_add_to_cart_time,
        min(if(event_name = 'begin_checkout', event_timestamp, null)) as first_begin_checkout_time,
        min(if(event_name = 'purchase' and transaction_id != '(not set)', event_timestamp, null)) as first_purchase_time,
        countif(event_name = 'purchase') > 0 as purchased_any
    from events
    group by user_pseudo_id, session_id
),
session_revenue as (
    select
        user_pseudo_id,
        session_id,
        count(*) as transactions,
        sum(revenue) as revenue
    from purchases
    where copy_number = 1
    group by user_pseudo_id, session_id
),

session_base as (
    select
        s.user_pseudo_id,
        s.session_id,
        s.session_start_time,
        s.session_number,
        s.session_number = 1 as is_new_visitor,
        s.device,
        s.source,
        s.medium,
        s.first_view_item_time is not null as viewed_item,
        s.first_add_to_cart_time is not null as added_to_cart,
        s.first_begin_checkout_time is not null as began_checkout,
        s.first_purchase_time is not null as purchased,
        s.purchased_any,
        s.first_view_item_time,
        s.first_add_to_cart_time,
        s.first_begin_checkout_time,
        s.first_purchase_time,
        coalesce(r.transactions, 0) as transactions,
        coalesce(r.revenue, 0) as revenue
    from sessions s
    left join session_revenue r
        on s.user_pseudo_id = r.user_pseudo_id
        and s.session_id = r.session_id
)
select * from session_base;