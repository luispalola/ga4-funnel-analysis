-- q0. test query: event types on a single day (12/1/20)

SELECT event_name, COUNT(*) AS events
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20201201`
GROUP BY event_name
ORDER BY events DESC;

-- q1. scope: date range, total events, total users
select
    min(event_date) as first_day,
    max(event_date) as last_day,
    count(*) as total_events,
    count(distinct user_pseudo_id) as users
from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;

-- q2. event types across full dataset
select event_name, count(*) as events
from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
group by event_name
order by events desc;

-- q3. event parameter keys
select ep.key, count(*) as occurrences
from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
    unnest(event_params) as ep
where _table_suffix = '20201201'
group by ep.key
order by occurrences desc;

-- q4. sessions: user_pseudo_id + ga_session_id
with events as (
    select
        user_pseudo_id,
        (select value.int_value from unnest(event_params)
        where key = 'ga_session_id') as session_id
    from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
)
select
    count(distinct concat(user_pseudo_id, '-', cast(session_id as string))) as sessions,
    count(distinct user_pseudo_id) as users,
    countif(session_id is null) as events_missing_session_id
from events;

-- q5. device and first-touch medium: spot obfuscated values
select
    device.category as device,
    traffic_source.medium as first_user_medium,
    count(distinct user_pseudo_id) as users
from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
group by device, first_user_medium
order by users desc;

-- q6. purchase events on a single day
select
    event_date,
    user_pseudo_id,
    ecommerce.transaction_id,
    ecommerce.purchase_revenue_in_usd,
    array_length(items) as line_items,
    items
from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
where _table_suffix = '20201201'
and event_name = 'purchase';