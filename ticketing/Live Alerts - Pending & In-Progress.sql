select t.id, 
MAX(CASE when tm.metadata_key='pitstopCode' then tm.metadata_value END) as `Responsible_PS`, 
t.ticket_type, t.ticket_status,
trim(trailing ',' from (substring(t.body,9,10))) as `Vehicle_Number`,
trim(trailing ',' from trim(leading '-' from substring(t.body,29,8))) as `Journey_Id`, 
MAX(CASE when tm.metadata_key='tripCode' then tm.metadata_value END) as `Trip_Code`, MAX(CASE when tm.metadata_key='pilotDetails' then tm.metadata_value END) as `Pilot_Details`,
ta3.body as 'last comment',
MAX(CASE when tm.metadata_key='reason' then tm.metadata_value END) as `Reason`,
addtime(from_unixtime(t.created_timestamp/1000),'05:30') as `Created_timestamp`,
round(((unix_timestamp()*1000)-t.created_timestamp)/3600000,2) as `Pending_Since (Hrs)`
from ticket t
left join ticket_metadata tm on tm.ticket_id=t.id
left join 
(select ta1.body as 'body', ta1.ticket_id as 'ticket_id' from ticket_activity ta1 left join ticket_activity ta2  on ta1.ticket_id = ta2.ticket_id and ta1.id < ta2.id and ta2.ticket_activity_type = 'COMMENT' where ta2.id is null and ta1.ticket_activity_type = 'COMMENT') as ta3 on ta3.ticket_id = t.id 
where t.is_active = 1 and t.ticket_status in ('ASSIGNED','OPENED') and ticket_type in ('PS_WAITING','UNSCHEDULED_STOPPAGE')
group by t.id;select t.id, 
MAX(CASE when tm.metadata_key='pitstopCode' then tm.metadata_value END) as `Responsible_PS`, 
t.ticket_type, t.ticket_status,
trim(trailing ',' from (substring(t.body,9,10))) as `Vehicle_Number`,
trim(trailing ',' from trim(leading '-' from substring(t.body,29,8))) as `Journey_Id`, 
MAX(CASE when tm.metadata_key='tripCode' then tm.metadata_value END) as `Trip_Code`, MAX(CASE when tm.metadata_key='pilotDetails' then tm.metadata_value END) as `Pilot_Details`,
ta3.body as 'last comment',
MAX(CASE when tm.metadata_key='reason' then tm.metadata_value END) as `Reason`,
addtime(from_unixtime(t.created_timestamp/1000),'05:30') as `Created_timestamp`,
round(((unix_timestamp()*1000)-t.created_timestamp)/3600000,2) as `Pending_Since (Hrs)`
from ticket t
left join ticket_metadata tm on tm.ticket_id=t.id
left join 
(select ta1.body as 'body', ta1.ticket_id as 'ticket_id' from ticket_activity ta1 left join ticket_activity ta2  on ta1.ticket_id = ta2.ticket_id and ta1.id < ta2.id and ta2.ticket_activity_type = 'COMMENT' where ta2.id is null and ta1.ticket_activity_type = 'COMMENT') as ta3 on ta3.ticket_id = t.id 
where t.is_active = 1 and t.ticket_status in ('ASSIGNED','OPENED') and ticket_type in ('PS_WAITING','UNSCHEDULED_STOPPAGE')
group by t.id;