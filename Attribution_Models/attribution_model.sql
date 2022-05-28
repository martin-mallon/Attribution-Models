/**********************************************************************
Clear temp space
**********************************************************************/
if object_id('tempdb.dbo.#conv_user', 'U') is not null drop table dbo.#conv_user;



/**********************************************************************
#conv_user
- subset point of conversion
**********************************************************************/
select a.*
into #conv_user
from Attribution.dbo.attribution a
where a.event = 'conversion';



select a.*
, case when b.cookie is not null then 1 else 0 end conv_user_ind				-- flag converting cookies
, rank () over (partition by a.cookie order by a.date_time asc) click_seq_first	-- first click seq
, rank () over (partition by a.cookie order by a.date_time desc) click_seq_last	-- last click seq

, cast(
	cast(datediff(second, a.date_time, max(a.date_time) over (partition by a.cookie)) as decimal(12, 4)) 
	/ (60 * 60 * 24)
	as decimal(12,4))

from Attribution.dbo.attribution a

left join #conv_user b
	on b.cookie = a.cookie

order by 1, 2;


--select top 100 * from #attribution_1;