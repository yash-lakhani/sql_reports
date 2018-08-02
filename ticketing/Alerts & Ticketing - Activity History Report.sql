select t.id, 
MAX(CASE when tm.metadata_key='pitstopCode' then tm.metadata_value END) as `Responsible_PS`, 
t.ticket_type, t.ticket_status, 
trim(trailing ',' from (substring(t.body,9,10))) as `Vehicle_Number`,
trim(trailing ',' from trim(leading '-' from substring(t.body,29,8))) as `Journey_Id`, 
MAX(CASE when tm.metadata_key='tripCode' then tm.metadata_value END) as `Trip_Code`,
MAX(CASE when tm.metadata_key='pilotDetails' then tm.metadata_value END) as `Pilot_Details`,
ta.ticket_activity_type, ta.body, ta.created_by,
MAX(CASE when tm.metadata_key='reason' then tm.metadata_value END) as `reason`,
 MAX(CASE when tm.metadata_key='closureComment' then tm.metadata_value END) as `Closure_Comment`,
addtime(from_unixtime(t.created_timestamp/1000),'05:30') as `Created_timestamp`,
ta.last_updated_by,
addtime(from_unixtime(ta.last_updated_timestamp/1000),'05:30') as `Last_updated_timestamp`,
addtime(from_unixtime(t.closure_timestamp/1000),'05:30') as `Closure_timestamp`,
(t.closure_timestamp-t.created_timestamp)/60000 as `Resolution_Time (mins)`
from ticket t
left join ticket_metadata tm on t.id = tm.ticket_id
left join ticket_activity ta on ta.ticket_id = t.id
where t.is_active = 1 and t.ticket_type != 'TRIP_VERIFICATION'
and t.created_timestamp >= ((UNIX_TIMESTAMP(STR_TO_DATE($start_date,'%Y-%m-%d')) - 19800) * 1000)
and t.created_timestamp <= ((UNIX_TIMESTAMP(STR_TO_DATE($end_date, '%Y-%m-%d')) - 19800) * 1000)
group by t.id;