Select (A.cnt/C.B)*100 as cnt1,
 A.* FROM
(select E.*,count(*) as `cnt` FROM
(select 
least(
  substring(
    MAX(CASE when tm.metadata_key='section' then tm.metadata_value END),1,5
  ),
  substring(
    MAX(CASE when tm.metadata_key='section' then tm.metadata_value END),9,5)
) as `City1`,
greatest(
  substring(
    MAX(CASE when tm.metadata_key='section' then tm.metadata_value END),1,5
  ),
  substring(
    MAX(CASE when tm.metadata_key='section' then tm.metadata_value END),9,5)
) as `City2`,
CASE 
WHEN 
 strcmp(
   substring(
     MAX(CASE when tm.metadata_key='section' then tm.metadata_value END),9,5
   ),""
 ) <>0 
 THEN
CONCAT(
  least(
    substring(
      MAX(CASE when tm.metadata_key='section' then tm.metadata_value END),1,5)
    ,
    substring(
      MAX(
        CASE when tm.metadata_key='section' then tm.metadata_value END),9,5)
  ),
  "-",
  greatest(
    substring(
      MAX(CASE when tm.metadata_key='section' then tm.metadata_value END),1,5)
    ,substring(
      MAX(CASE when tm.metadata_key='section' then tm.metadata_value END),9,5)
  )
)
ELSE substring(
  MAX(CASE when tm.metadata_key='section' then tm.metadata_value END),1,5
)
END as `Section`,
MAX(CASE when tm.metadata_key='businessType' then tm.metadata_value END) as `businessType`,
 MAX(CASE when tm.metadata_key='vehicleType' then tm.metadata_value END) as `vehicleType`,
  MAX(CASE when tm.metadata_key='nearestPitstop' then tm.metadata_value END) as `nearestPitstop`
from ticket as t
join ticket_metadata as tm on tm.ticket_id=t.id
where t.created_timestamp > (unix_timestamp('[fromDate]')-5.5*60*60)*1000
and t.created_timestamp < (unix_timestamp('[toDate]')-5.5*60*60 + 24*60*60)*1000
and t.ticket_type ='BREAKDOWN'
group by t.id
) as E where E.section is not null
and (if('[businessType]' = 'ALL',1=1,[E.businessType =businessType]))
and (if('[vehicle_type]' = 'ALL',1=1,[E.vehicleType =vehicle_type]))
and (if('[nearest_pitstop]' = 'ALL',1=1,[E.nearestPitstop =nearest_pitstop])) 
group by E.Section
) as A
CROSS JOIN (select count(*) as `B` FROM ticket_metadata where metadata_key='section') as C
WHERE (A.cnt/C.B)*100>0.01