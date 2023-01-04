{% macro ongoing_model_match(GFGH_LIST) %}
with exclude as (
   SELECT id,gfgh from {{ref('gfgh_sku_match')}}
   union
   SELECT id,gfgh from {{ref('new_gfgh_sku_match')}}
)

, pt1 as (
{% for GFGH in GFGH_LIST %}

select
   '{{GFGH}}' AS gfgh,
   s.id AS id,
   s.packaging_unit AS packaging_unit,
   s.name AS name,
   s.manufacturer,
   s.no_of_base_units,
   s.base_unit_content,
   s.direct_shop_release,
   s.gtin_packaging_unit AS gtin_packaging_unit,
   s.status AS status,
   s.kollex_active AS kollex_active,
   s.created AS created,
   s.updated AS updated,
   s.sku AS sku,
   s.tool_link,
   s.gtin_single_unit,
   m.code AS match_code
from {{ref(GFGH)}} s
join {{ref('pim_catalog_product_model')}} m
   on s.gpu = m.raw_values::JSON->'gtin_single_unit'->'<all_channels>'->>'<all_locales>'
left join exclude on s.id = exclude.id and exclude.gfgh = '{{GFGH}}'
where
   s.sku is null and coalesce(s.direct_shop_release, 'false') <> 'true'
   and exclude.id is null and s.kollex_active = true
{% if not loop.last %}
union
{% endif %}

{% endfor %}
)

select * from pt1 where pt1.id not in (select gfgh_product_id from sheet_loader.special_cases_to_exclude) and gfgh not in (select merchant_key from sheet_loader.special_cases_to_exclude) and gfgh in {{GFGH_LIST}}
{% endmacro %}

