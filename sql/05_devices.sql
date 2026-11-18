-- q3. devices: funnel by device

select
    device,
    count(*) as sessions,
    countif(viewed_item or added_to_cart or began_checkout or purchased) as reached_view,
    countif(added_to_cart or began_checkout or purchased) as reached_cart,
    countif(began_checkout or purchased) as reached_checkout,
    countif(purchased) as purchases,
    sum(revenue) as revenue
from `ga4-funnel-analysis-511719.ga4_analysis.session_base`
group by device
order by sessions desc;