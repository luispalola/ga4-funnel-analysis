-- r1. main funnel on clean window only (nov 12 - jan 25)

select
    count(*) as sessions,
    countif(viewed_item or added_to_cart or began_checkout or purchased) as reached_view,
    countif(added_to_cart or began_checkout or purchased) as reached_cart,
    countif(began_checkout or purchased) as reached_checkout,
    countif(purchased) as reached_purchase,
    sum(revenue) as revenue
from `ga4-funnel-analysis-511719.ga4_analysis.session_base`
where date(timestamp_micros(session_start_time)) between date '2020-11-12' and date '2021-01-25';

-- r2. new vs returning on clean window only

select
    case
        when is_new_visitor then 'new'
        when not is_new_visitor then 'returning'
        else 'unknown'
    end as visitor_type,
    count(*) as sessions,
    countif(viewed_item or added_to_cart or began_checkout or purchased) as reached_view,
    countif(added_to_cart or began_checkout or purchased) as reached_cart,
    countif(began_checkout or purchased) as reached_checkout,
    countif(purchased) as purchases,
    sum(revenue) as revenue
from `ga4-funnel-analysis-511719.ga4_analysis.session_base`
where date(timestamp_micros(session_start_time)) between date '2020-11-12' and date '2021-01-25'
group by visitor_type
order by sessions desc;


-- r3. channels on clean window only

select
    case
        when medium is null then 'unknown'
        when source in ('shop.googlemerchandisestore.com', 'googlemerchandisestore.com') then 'self-referral'
        when source = '(direct)' then 'direct'
        when medium = 'organic' then 'organic search'
        when medium = 'cpc' then 'paid search'
        when medium = 'referral' then 'referral'
        when medium = 'email' then 'email'
        when medium = 'affiliate' then 'affiliate'
        when medium in ('<Other>', '(data deleted)') then 'hidden'
        else 'other'
    end as channel,
    count(*) as sessions,
    countif(viewed_item or added_to_cart or began_checkout or purchased) as reached_view,
    countif(purchased) as purchases,
    sum(revenue) as revenue
from `ga4-funnel-analysis-511719.ga4_analysis.session_base`
where date(timestamp_micros(session_start_time)) between date '2020-11-12' and date '2021-01-25'
group by channel
order by sessions desc;


-- r4. count any later purchase event, even without a transaction id

with first_visits as (
    select
        user_pseudo_id,
        case
            when purchased then 'purchased'
            when began_checkout then 'abandoned checkout'
            when added_to_cart then 'abandoned cart'
            when viewed_item then 'viewed only'
            else 'no product view'
        end as first_visit_result
    from `ga4-funnel-analysis-511719.ga4_analysis.session_base`
    where is_new_visitor
),

later_buyers as (
    select distinct user_pseudo_id
    from `ga4-funnel-analysis-511719.ga4_analysis.session_base`
    where purchased_any
    and not is_new_visitor
)

select
    f.first_visit_result,
    count(*) as users,
    countif(l.user_pseudo_id is not null) as bought_later
from first_visits f
left join later_buyers l
    on f.user_pseudo_id = l.user_pseudo_id
group by first_visit_result
order by users desc;