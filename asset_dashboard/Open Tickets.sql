(select count(*) FROM
(select 
t.id as `Ticket Id`,
MAX(CASE when tm.metadata_key='businessType' then tm.metadata_value END) as `businessType`,
 MAX(CASE when tm.metadata_key='vehicleType' then tm.metadata_value END) as `vehicleType`,
  MAX(CASE when tm.metadata_key='nearestPitstop' then tm.metadata_value END) as `nearestPitstop`
from ticket as t
join ticket_metadata as tm on tm.ticket_id=t.id
where t.created_timestamp > (unix_timestamp('[fromDate]')-5.5*60*60)*1000
and t.created_timestamp < (unix_timestamp('[toDate]')-5.5*60*60 + 24*60*60)*1000
and t.ticket_type ='BREAKDOWN'
and t.ticket_state='OPENED'
and t.ticket_stage='WORK_ORDER'
and t.is_active and tm.is_active
group by t.id
 ) as A
where (if('[businessType]' = 'ALL',1=1,[A.businessType =businessType]))
and (if('[vehicle_type]' = 'ALL',1=1,[A.vehicleType =vehicle_type]))
and (if('[nearest_pitstop]' = 'ALL',1=1,[A.nearestPitstop =nearest_pitstop]))
)