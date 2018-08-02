select 
pt.id as `Pilot Trip Id`,
pt.start_node_id,
pt.start_node_type,
pt.end_node_id,
pt.end_node_type,
pt.vehicle_number,
pth.from_location_type,
pth.from_location_id,
vnt1.journey_id,
pth.to_location_type,
pth.to_location_id,
vnt2.journey_id
from pilot_trip as pt
join pilot_trip_history as pth on pth.pilot_trip_id=pt.id and from_location_type='CLIENT_WAREHOUSE'  and to_location_type='CLIENT_WAREHOUSE'  and from_location_id <> to_location_id  
join vehicle_node_tracking as vnt1 on vnt1.id = (select start_vehicle_tracking_node_id from pilot_trip_history where pilot_trip_id=pt.id and from_location_id = to_location_id and from_location_id = pth.from_location_id group by pth.from_location_id) and vnt1.is_active
join vehicle_node_tracking as vnt2 on vnt2.id = (select start_vehicle_tracking_node_id from pilot_trip_history where pilot_trip_id=pt.id and from_location_id = to_location_id and from_location_id = pth.to_location_id group by pth.to_location_id) and vnt2.is_active
where  
 pt.created_timestamp >  (UNIX_TIMESTAMP('2018-08-01 00:00:00')*1000 - 19800000) 
and pt.created_timestamp <   (UNIX_TIMESTAMP('2018-08-01 23:59:59')*1000 - 19800000)
and vnt1.journey_id <> vnt2.journey_id
and pt.start_node_id <> pt.end_node_id
and pt.is_active and pth.is_active
group by pilot_trip_id,start_node_id,end_node_id,vnt1.journey_id,vnt2.journey_id
order by pt.id desc;