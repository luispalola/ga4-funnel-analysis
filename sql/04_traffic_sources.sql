-- q2. traffic sources: sessions and purchases by source / medium

select
    source,
    medium,
    count(*) as sessions,
    countif(purchased) as purchases
from `ga4-funnel-analysis-511719.ga4_analysis.session_base`
group by source, medium
order by sessions desc
limit 30;


-- q2b. channels: group source / medium into channels

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
    round(countif(purchased) / count(*) * 100, 2) as conversion_pct,
    sum(revenue) as revenue
from `ga4-funnel-analysis-511719.ga4_analysis.session_base`
group by channel
order by sessions desc;