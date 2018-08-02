select count(*),
A.category as `Category`
FROM
(select 
a.id as `Asset id`,
aa.id as `Asset Activity Id`,
aa.reference_id as `Ticket Id`,
a1.identifier as `Vehicle Number`,
ap1.property_value_text as `BOSS?`,
MAX(CASE when tm.metadata_key='businessType' then tm.metadata_value END) as `businessType`,
 MAX(CASE when tm.metadata_key='vehicleType' then tm.metadata_value END) as `vehicleType`,
  MAX(CASE when tm.metadata_key='nearestPitstop' then tm.metadata_value END) as `nearestPitstop`,
count(*) as cnt,
ap.property_value_text as `category`
from ticket_metadata as tm
join asset.asset_activity as aa on tm.ticket_id=aa.reference_id
join asset.asset as a on a.id = aa.asset_id and a.tenant_id=1
join asset.asset as a1 on a1.id = a.super_parent_id and a1.tenant_id=1
left join asset.asset_property as ap on ap.asset_id = a.id and  ap.asset_category_property_id=218 and ap.tenant_id=1
join asset.asset_property as ap1 on ap1.asset_id=a1.id and ap1.asset_category_property_id=3 and ap1.tenant_id=1
join asset.asset_category as ac on ac.id = a.asset_category_id and ac.tenant_id=1
-- left join asset_activity_property as aap on aap.asset_activity_id= aa.id and aap.property_id=218 and aap.tenant_id=1
where aa.reference_type='PUNCTURE' and aa.tenant_id=1 
and tm.created_timestamp > (unix_timestamp('[fromDate]')-5.5*60*60)*1000
and tm.created_timestamp < (unix_timestamp('[toDate]')-5.5*60*60 + 24*60*60)*1000
and ap1.property_value_text<>'BOSS1212'
group by ticket_id,a.id
order by aa.id desc)  as A
where (if('[businessType]' = 'ALL',1=1,[A.businessType =businessType]))
and (if('[vehicle_type]' = 'ALL',1=1,[A.vehicleType =vehicle_type]))
and (if('[nearest_pitstop]' = 'ALL',1=1,[A.nearestPitstop =nearest_pitstop]))
group by A.category