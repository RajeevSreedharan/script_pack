
 --Monitor Highest SQL Wait Time Using Active Session History (ASH)
select /*h.session_id, h.session_serial#, h.sql_id,*/ h.session_state state,h.blocking_session blck_ssn,
h.blocking_session_status blckssionstat, h.event, /*e.wait_class,*/ h.module, /*u.username,*/ sql.sql_text,
sum(h.wait_time + h.time_waited) "total wait time (ms)"
from v$active_session_history h, v$sqlarea sql, dba_users u, v$event_name e 
where h.sample_time between sysdate - 1/500 and sysdate --event in the last hour
and h.sql_id = sql.sql_id
and h.user_id = u.user_id
and h.event# = e.event#
group by h.session_id, h.session_serial#, h.sql_id, h.session_state, 
h.blocking_session_status, h.event, e.wait_class, h.module, u.username, sql.sql_text,h.blocking_session
order by sum(h.wait_time + h.time_waited) desc;

/* SQL Waits*/
select h.sql_id,
       h.event,
       u.username,
       sum(h.wait_time + h.time_waited) "total time waited"
  from gv$active_session_history h,
       gv$sqlarea                sql,
       dba_users                 u,
       gv$event_name             e
 where h.sample_time between sysdate - 1/4 / 24 and sysdate
   and h.sql_id = sql.sql_id
   and h.user_id = u.user_id
   and h.event# = e.event#
 group by h.sql_id, h.event, u.username
 order by sum(h.wait_time + h.time_waited) desc;
 
/* Object Waits*/
select o.owner,
       o.object_name,
       o.object_type,
       h.session_id,
       h.session_serial#,
       h.sql_id,
       h.module,
       sum(h.wait_time + h.time_waited) "total time waited"
  from gv$active_session_history h, dba_objects o, gv$event_name e
 where h.sample_time between sysdate - 1 / 4 / 24 and sysdate
   and h.current_obj# = o.object_id
   and h.event_id = e.event_id
   and o.object_name not in ('aud$')
   and h.module like 'modulename%'
 group by o.owner,
          o.object_name,
          o.object_type,
          h.session_id,
          h.session_serial#,
          h.sql_id,
          h.module
 order by sum(h.wait_time + h.time_waited) desc;