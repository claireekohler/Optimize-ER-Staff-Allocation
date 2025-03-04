set search_path to waittime
;

select *
from er_wait_time_2
;

-- Visit date - varchar(20) - i want to separate into time and date

alter table er_wait_time_2
add column visit_date date,
add column visit_time time;

update er_wait_time_2
set visit_date = cast("Visit Date" as date),
	visit_time = cast("Visit Date" as time)
;

	
alter table er_wait_time_2
drop column "Visit Date",
drop column "Time of Day"
;

-- average wait time and nurse-to-patient ratio by date and time 
-- split the times into 4 (early morning, morning, afternoon, evening)

select 
	visit_date,
	case
		when extract(hour from visit_time) between 0 and 5 then '00:00:00 - 05:59:00'
		when extract(hour from visit_time) between 6 and 11 then '06:00:00 - 11:59:00'
		when extract(hour from visit_time) between 12 and 17 then '12:00:00 - 17:59:00'
		else '18:00:00 - 23:59:00'
	end as time_block,
	round(avg("Time to Registration"),2) as avg_registration_time,
	round(avg("Time to Triage"),2) as avg_triag_time,
	round(avg("Total Wait Time"),2) as avg_wait_time,
	round(avg("Nurse-to-Patient Ratio"),2) as avg_nurse_ratio
from er_wait_time_2
group by visit_date, time_block, "Hospital Name"
order by avg_wait_time desc
limit 30
;

-- Greatest insight: Longer wait times for nurse-to-patient ratios 4 and 5
-- Longer wait times in the morning.

-- Visualize using Python