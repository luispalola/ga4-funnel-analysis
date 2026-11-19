-- q5. new vs returning: funnel by visitor type

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
group by visitor_type
order by sessions desc;

-- q5b. do new visitors come back and buy later?

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
    where purchased
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