select count(*) as `Count`,
A.ContactedTo as `Contacted To` FROM
(select t.id as `Ticket Id`,
 CASE When (tch.entity_type='VEHICLE' and MAX(CASE when tm.metadata_key='vehicleNumber' then  tm.metadata_value END)=tch.entity_value)
 THEN 'Same Vehicle'
 WHEN (tch.entity_type is null)
 THEN 'Not Contacted Yet'
 ELSE tch.entity_type
 END as `ContactedTo`,
 MAX(CASE when tm.metadata_key='businessType' then tm.metadata_value END) as `businessType`,
 MAX(CASE when tm.metadata_key='vehicleType' then tm.metadata_value END) as `vehicleType`,
  MAX(CASE when tm.metadata_key='nearestPitstop' then tm.metadata_value END) as `nearestPitstop`,
 tch.entity_value as `Contacted V.No./Hub/SC`
 from ticket as t
 left join ticket_metadata tm on tm.ticket_id = t.id
 left join ticket_contact_history as tch on tch.ticket_id = t.id
 where t.is_active=1
 and t.ticket_type='BREAKDOWN'
 and t.created_timestamp > (unix_timestamp('[fromDate]')-5.5*60*60)*1000
 and t.created_timestamp < (unix_timestamp('[toDate]')-5.5*60*60 + 24*60*60)*1000
 group by t.id
 ) as A
where (if('[businessType]' = 'ALL',1=1,[A.businessType =businessType]))
and (if('[vehicle_type]' = 'ALL',1=1,[A.vehicleType =vehicle_type]))
and (if('[nearest_pitstop]' = 'ALL',1=1,[A.nearestPitstop =nearest_pitstop]))
group by A.ContactedTo