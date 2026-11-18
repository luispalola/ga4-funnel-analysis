-- q1 funnel: sessions reaching each step

select
  count(*) as sessions,
  countif(viewed_item) as viewed_item,
  countif(added_to_cart) as added_to_cart,
  countif(began_checkout) as began_checkout,
  countif(purchased) as purchased
from `ga4-funnel-analysis-511719.ga4_analysis.session_base`;


-- q1b. funnel checks: buyers who skipped steps, and any-purchase count
select
    countif(purchased and not viewed_item) as purchased_no_view,
    countif(purchased and not added_to_cart) as purchased_no_cart,
    countif(purchased and not began_checkout) as purchased_no_checkout,
    countif(purchased_any) as purchased_any
from `ga4-funnel-analysis-511719.ga4_analysis.session_base`;

-- q1c. cart gap: checkouts without a cart, and whether no-cart buyers are returning visitors
select
    countif(began_checkout and not added_to_cart) as checkout_no_cart,
    countif(purchased and not added_to_cart) as purchased_no_cart,
    countif(purchased and not added_to_cart and not is_new_visitor) as purchased_no_cart_returning
from `ga4-funnel-analysis-511719.ga4_analysis.session_base`;


-- q1d. main funnel: sessions that reached at least each step
select
    count(*) as sessions,
    countif(viewed_item or added_to_cart or began_checkout or purchased) as reached_view,
    countif(added_to_cart or began_checkout or purchased) as reached_cart,
    countif(began_checkout or purchased) as reached_checkout,
    countif(purchased) as reached_purchase
from `ga4-funnel-analysis-511719.ga4_analysis.session_base`;