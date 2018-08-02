-- --no_cache
set @a := 
(select sum(A.closure_timestamp-A.created_timestamp) FROM
(select 
t.id as `Ticket Id`,
MAX(CASE when tm.metadata_key='businessType' then tm.metadata_value END) as `businessType`,
 MAX(CASE when tm.metadata_key='vehicleType' then tm.metadata_value END) as `vehicleType`,
  MAX(CASE when tm.metadata_key='nearestPitstop' then tm.metadata_value END) as `nearestPitstop`,
 t.closure_timestamp as `closure_timestamp`,
 t.created_timestamp as `created_timestamp`
from ticket as t
join ticket_metadata as tm on tm.ticket_id=t.id
where t.closure_timestamp > t.created_timestamp and 
t.ticket_type ='BREAKDOWN'
and t.created_timestamp > (unix_timestamp('[fromDate]')-5.5*60*60)*1000
and t.created_timestamp < (unix_timestamp('[toDate]')-5.5*60*60 + 24*60*60)*1000
and t.is_active and tm.is_active
group by t.id) as A
where (if('[businessType]' = 'ALL',1=1,[A.businessType =businessType]))
and (if('[vehicle_type]' = 'ALL',1=1,[A.vehicleType =vehicle_type]))
and (if('[nearest_pitstop]' = 'ALL',1=1,[A.nearestPitstop =nearest_pitstop]))
 )
;

set @b := (select count(*) FROM
(select 
t.id as `Ticket Id`,
MAX(CASE when tm.metadata_key='businessType' then tm.metadata_value END) as `businessType`,
 MAX(CASE when tm.metadata_key='vehicleType' then tm.metadata_value END) as `vehicleType`,
  MAX(CASE when tm.metadata_key='nearestPitstop' then tm.metadata_value END) as `nearestPitstop`
from ticket as t
join ticket_metadata as tm on tm.ticket_id=t.id
where t.closure_timestamp is not null
and t.ticket_type ='BREAKDOWN'
and t.created_timestamp > (unix_timestamp('[fromDate]')-5.5*60*60)*1000
and t.created_timestamp < (unix_timestamp('[toDate]')-5.5*60*60 + 24*60*60)*1000
and t.is_active and tm.is_active
group by t.id) as A
where (if('[businessType]' = 'ALL',1=1,[A.businessType =businessType]))
and (if('[vehicle_type]' = 'ALL',1=1,[A.vehicleType =vehicle_type]))
and (if('[nearest_pitstop]' = 'ALL',1=1,[A.nearestPitstop =nearest_pitstop]))
 );

select round(@a/(@b*1000*60*60)) as `TAT of Ticket Closure (in hours)`