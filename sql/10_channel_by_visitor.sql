-- q7. new vs returning visitors within each channel (clean days only)
-- checks if returning visitors buy more in every channel, not just overall

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
    case
        when is_new_visitor then 'new'
        when not is_new_visitor then 'returning'
        else 'unknown'
    end as visitor_type,
    count(*) as sessions,
    countif(began_checkout or purchased) as reached_checkout,
    countif(purchased) as purchases,
    sum(revenue) as revenue
from `ga4-funnel-analysis-511719.ga4_analysis.session_base`
where date(timestamp_micros(session_start_time)) between date '2020-11-12' and date '2021-01-25'
group by channel, visitor_type
order by channel, visitor_type;