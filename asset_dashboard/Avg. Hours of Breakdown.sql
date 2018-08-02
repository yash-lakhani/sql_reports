set @a := (select sum(floor((A.ETAT-A.workStart)/(1000*60*60))) FROM
(select 
t.id as `Ticket Id`,
MAX(CASE when tm.metadata_key='businessType' then tm.metadata_value END) as `businessType`,
 MAX(CASE when tm.metadata_key='vehicleType' then tm.metadata_value END) as `vehicleType`,
  MAX(CASE when tm.metadata_key='nearestPitstop' then tm.metadata_value END) as `nearestPitstop`,
 tchm1.metadata_value as `ETAT`,
 tchm4.metadata_value as `workStart`
from ticket as t
join ticket_metadata as tm on tm.ticket_id=t.id
left join ticket_contact_history as tch on tch.ticket_id = t.id
left join ticket_contact_history_metadata as tchm1 on tchm1.ticket_contact_history_id = tch.id and tchm1.metadata_type='WORK_STARTED' and tchm1.metadata_key='ETAT'
left join ticket_contact_history_metadata as tchm4 on tchm4.ticket_contact_history_id = tch.id and tchm4.metadata_key='Work Start Time'
where tchm1.metadata_value > tchm4.metadata_value 
and t.ticket_type ='BREAKDOWN'
and t.created_timestamp > (unix_timestamp('[fromDate]')-5.5*60*60)*1000
and t.created_timestamp < (unix_timestamp('[toDate]')-5.5*60*60 + 24*60*60)*1000
and t.is_active and tm.is_active and tchm1.is_active and tchm4.is_active and tch.is_active
group by t.id) as A
where (if('[businessType]' = 'ALL',1=1,[A.businessType =businessType]))
and (if('[vehicle_type]' = 'ALL',1=1,[A.vehicleType =vehicle_type]))
and (if('[nearest_pitstop]' = 'ALL',1=1,[A.nearestPitstop =nearest_pitstop]))
 );
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

select round(@a/@b) as `Total Hours of Breakdown`