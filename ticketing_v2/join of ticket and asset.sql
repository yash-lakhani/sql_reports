-- --no_cache
select t.id as `Ticket Id`,
t.created_by as `Ticket Raised By`,
t.ticket_state as `Ticket State`,
MAX(CASE when tm.metadata_key='clientCode' then tm.metadata_value END) as `Client Code`,
MAX(CASE when tm.metadata_key='tripCode' then  tm.metadata_value END) as `Trip Code`,
MAX(CASE when tm.metadata_key='tripStatus' then  tm.metadata_value END) as `Trip Status`,
MAX(CASE when tm.metadata_key='vehicleNumber' then  tm.metadata_value END) as `Vehicle Number`,
MAX(CASE when tm.metadata_key='pilotDetails' then  tm.metadata_value END) as `Pilot Details`,
MAX(CASE when tm.metadata_key='currentLocation' then  tm.metadata_value END) as `Current Location String`,
MAX(CASE when tm.metadata_key='nearestPitstop' then  tm.metadata_value END) as `Nearest Pitstop`,
MAX(CASE when tm.metadata_key='distanceToNearestPitstop' then  tm.metadata_value END) as `Distance To Nearest Pitstop`,
MAX(CASE when tm.metadata_key='section' then  tm.metadata_value END) as `Section`,
MAX(CASE when tm.metadata_key='previousPitstop' then  tm.metadata_value END) as `Previous Pitstop`,
MAX(CASE when tm.metadata_key='nextPitstop' then  tm.metadata_value END) as `Next Pitstop`,
MAX(CASE when tm.metadata_key='remarks' then  tm.metadata_value END) as `Failure Description`,
tch.entity_type as `Contacted To`,
tch.entity_value as `Contacted V.No./Hub/SC`,
tch.response_status as `Response Status`,
addtime(from_unixtime(floor(tch.last_updated_timestamp/1000)),'05:30') as `Contacted At`,
 MAX(CASE when tchm.metadata_type='CONTACTED' and tchm.metadata_key='Comment' then  tchm.metadata_value END) as `Contacted Comments`,
 MAX(CASE when tchm.metadata_type='CONTACTED' and tchm.metadata_key='Remarks' then  tchm.metadata_value END) as `Contact Remarks`,
 MAX(CASE when tchm.metadata_key='Estimated Time of Arrival' then  addtime(from_unixtime(floor(tchm.metadata_value/1000)),'05:30') END) as `Estimated Time of Arrival`,
 MAX(CASE when tchm.metadata_key='Time of Arrival' then  addtime(from_unixtime(floor(tchm.metadata_value/1000)),'05:30') END) as `Time of Arrival`,
 MAX(CASE when tchm.metadata_key='Work Start Time' then  addtime(from_unixtime(floor(tchm.metadata_value/1000)),'05:30') END) as `Work Start Time`,
 MAX(CASE when tchm.metadata_type='WORK_STARTED' and tchm.metadata_key='Comment' then  tchm.metadata_value END) as `Work Start Time Comment`,
 MAX(CASE when tchm.metadata_type='WORK_STARTED' and tchm.metadata_key='ETAT' then  addtime(from_unixtime(floor(tchm.metadata_value/1000)),'05:30') END) as `Estimated Work Completion Time`,
 MAX(CASE when tchm.metadata_type='WORK_STARTED' and tchm.metadata_key='Remarks' then  tchm.metadata_value END) as `Work Remarks`,
 floor((MAX(CASE when tchm.metadata_type='WORK_STARTED' and tchm.metadata_key='ETAT' then  tchm.metadata_value END) - MAX(CASE when tchm.metadata_key='Work Start Time' then tchm.metadata_value END))/(60*1000*60)) as `Work Done TAT (minutes)`,
addtime(from_unixtime(floor(t.created_timestamp/1000)),'05:30') as `Ticket Created Time`,
aa.reference_id as `Ticket Id`,
aa.id as `Asset Activity Id`,
aa.asset_id as `Asset Id`,
a.identifier as `Asset Identifier`,
a.asset_category_id as `Asset Category Id`,
aa.reference_type as `Ticket Type`
from ticket as t
left join ticket_metadata tm on tm.ticket_id = t.id
left join ticket_contact_history as tch on tch.ticket_id = t.id
left join ticket_contact_history_metadata as tchm on
tchm.ticket_contact_history_id = tch.id
left join asset.asset_activity as aa on t.id = aa.reference_id
left join asset.asset as a on a.id = aa.asset_id
where t.is_active=1
and t.ticket_type = 'BREAKDOWN'
and t.created_timestamp > 1531924200000
and a.is_active
and aa.is_active
group by t.id
order by t.id desc