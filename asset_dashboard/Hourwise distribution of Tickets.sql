select 
count(*),
A.TicketStage as `Ticket Stage`,
A.TicketState as `Ticket State`,
A.hour
from
((select 
ta.ticket_id as `Ticket Id`,
ta.ticket_stage as `TicketStage`,
ta.ticket_state as `TicketState`,
hour(addtime(from_unixtime(floor(ta.created_timestamp/1000)),'05:30')) as `hour`,
MAX(CASE when tm.metadata_key='businessType' then tm.metadata_value END) as `businessType`,
 MAX(CASE when tm.metadata_key='vehicleType' then tm.metadata_value END) as `vehicleType`,
  MAX(CASE when tm.metadata_key='nearestPitstop' then tm.metadata_value END) as `nearestPitstop`
from ticket_activity as ta
join ticket_metadata as tm on tm.ticket_id=ta.ticket_id
where ta.ticket_type='BREAKDOWN'
and ta.ticket_stage='WORK_ORDER' and ta.ticket_state='CLOSED'
and ta.created_timestamp > (unix_timestamp('[fromDate]')-5.5*60*60)*1000
and ta.created_timestamp < (unix_timestamp('[toDate]')-5.5*60*60 + 24*60*60)*1000
group by ta.ticket_id)
UNION 
(select 
ta.ticket_id as `Ticket Id`,
ta.ticket_stage as `TicketStage`,
ta.ticket_state as `TicketState`,
hour(addtime(from_unixtime(floor(ta.created_timestamp/1000)),'05:30')) as `hour`,
MAX(CASE when tm.metadata_key='businessType' then tm.metadata_value END) as `businessType`,
 MAX(CASE when tm.metadata_key='vehicleType' then tm.metadata_value END) as `vehicleType`,
  MAX(CASE when tm.metadata_key='nearestPitstop' then tm.metadata_value END) as `nearestPitstop`
from ticket_activity as ta
join ticket_metadata as tm on tm.ticket_id = ta.ticket_id
where ta.ticket_type='BREAKDOWN'
and ta.ticket_stage='WORK_REQUEST' and ta.ticket_state='OPENED'
and ta.created_timestamp > (unix_timestamp('[fromDate]')-5.5*60*60)*1000
and ta.created_timestamp < (unix_timestamp('[toDate]')-5.5*60*60 + 24*60*60)*1000
group by ta.ticket_id)) as A
where (if('[businessType]' = 'ALL',1=1,[A.businessType =businessType]))
and (if('[vehicle_type]' = 'ALL',1=1,[A.vehicleType =vehicle_type]))
and (if('[nearest_pitstop]' = 'ALL',1=1,[A.nearestPitstop =nearest_pitstop])) group by A.hour,A.TicketStage