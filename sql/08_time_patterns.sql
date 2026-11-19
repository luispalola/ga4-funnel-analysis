-- q6. time patterns: sessions and purchases by day

select
    date (timestamp_micros(session_start_time)) as session_date,
    count(*) as sessions,
    countif(purchased) as purchases,
    sum(revenue) as revenue
from `ga4-funnel-analysis-511719.ga4_analysis.session_base`
group by session_date
order by session_date;


--q6b. purchase tracking check: real vs any purchase events by day

select
    date(timestamp_micros(session_start_time)) as session_date,
    countif(purchased) as purchases,
    countif(purchased_any) as purchased_any
from `ga4-funnel-analysis-511719.ga4_analysis.session_base`
group by session_date
order by session_date;


-- q6c. timezione check: does event_date follow utc or pacific?

select
    count(*) as events,
    countif(event_date = format_date("%Y%m%d", date(timestamp_micros(event_timestamp)))) as matches_utc,
    countif(event_date = format_date("%Y%m%d", date(timestamp_micros(event_timestamp), 'America/Los_Angeles'))) as matches_pacific
from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;


-- q6d. day of week: sessions and purchases (clean window only)

with clean_sessions as (
    select
        date(timestamp_micros(session_start_time)) as session_date,
        purchased,
        revenue
    from `ga4-funnel-analysis-511719.ga4_analysis.session_base`
    where date(timestamp_micros(session_start_time)) between date '2020-11-12' and date '2021-01-25'
)
select
    extract(dayofweek from session_date) as day_number,
    format_date("%A", session_date) as day_of_week,
    count(*) as sessions,
    countif(purchased) as purchases,
    sum(revenue) as revenue
from clean_sessions
group by day_number, day_of_week
order by day_number;


-- q6e. hour of day (utc): sessions and purchases (clean window only)

with clean_sessions as (
    select
        extract(hour from timestamp_micros(session_start_time)) as session_hour,
        purchased,
        revenue
    from `ga4-funnel-analysis-511719.ga4_analysis.session_base`
    where date(timestamp_micros(session_start_time)) between date '2020-11-12' and date '2021-01-25'
)
select
    session_hour,
    count(*) as sessions,
    countif(purchased) as purchases,
    sum(revenue) as revenue
from clean_sessions
group by session_hour
order by session_hour;