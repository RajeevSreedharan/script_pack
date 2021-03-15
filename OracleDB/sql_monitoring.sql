-- gv$sql
select * from gv$sql where users_executing > 0;
select * from gv$sql where sql_id='4bau1o71fx4ep'
select a.executions, a.users_executing, a.rows_processed,a.buffer_gets, a.* from  gv$sql a where module like 'MYMODULE%' and users_executing > 0;
select sysdate,  a.inst_id,a.users_executing, a.rows_processed,a.buffer_gets, a.* from  gv$sql a where sql_id = '4bau1o71fx4ep' and users_executing > 0;
select sysdate, sum(a.users_executing), sum(a.rows_processed) from gv$sql a where users_executing > 0 and sql_id = '4bau1o71fx4ep';

-- gv$session
select * from gv$session where status = 'active';
select t.sql_id, t.sql_child_number from gv$session t where t.status = 'ACTIVE' and t.username = 'MYUSER' and t.module like 'MYMODULE%';

select * from gv$session_longops where sofar <> totalwork and username ='MYUSER';


-- plan
select a.output_rows, a.* from gv$sql_plan_monitor a where sql_id = '4bau1o71fx4ep' order by a.output_rows desc;
select * from gv$sql_plan where sql_id = '4bau1o71fx4ep' and inst_id = 2;
select * from table( dbms_xplan.display_cursor(sql_id => '4bau1o71fx4ep',cursor_child_no => null,format => 'advanced') );

select * from v$db_object_cache where owner='MYUSER' and property = 'HOT';

select a.sql_id, a.address,a.hash_value from gv$sqlarea a where a.sql_id = '4bau1o71fx4ep';
begin
  dbms_shared_pool.purge('0700017b582aa530', '4291297280', 'C');
end;

-- io
select * from v$sess_io order by block_changes desc;

select s.sid,s.serial#,s.username,s.program,s.module,s.action,i.block_changes
from gv$session s,gv$sess_io i where s.sid = i.sid and s.status = 'active' order by 7 desc,1,2,3,4;

-- ash
select a.event, sql_opname,sql_id,sql_plan_operation,  current_obj#,sql_plan_options,session_state,module,  a.* 
from gv$active_session_history a where module like 'MYMODULE%';

select a.event,
       sql_opname,
       sql_id,
       sql_plan_operation,
       sql_plan_options,
       session_state,
       module,
       a.wait_class,
       a.p2text,
       a.p3text,
       a.*
  from gv$active_session_history a
 where sql_id = '4bau1o71fx4ep';
 
 select /*+parallel(8)*/ event, sql_id, a.* from dba_hist_active_sess_history a 
 where sql_exec_start between timestamp'2021-01-01 16:01:01' and timestamp'2021-01-01 16:02:01' 
 and event like '%library%' and sql_id='4bau1o71fx4ep' group by event, sql_id
  
 -- check i/o consuming queries for active session
select s.sid,s.serial#,s.username,s.program,s.module,s.action,s.inst_id,
       i.block_changes, s.prev_exec_start, (sysdate - (s.prev_exec_start))*24*60*60 time_taken, s.sql_id
from gv$session s,gv$sess_io i
where s.sid = i.sid and s.status ='active' and username='MYUSER' /*and program not like 'oracle%'*/ 
order by 8 desc,1,2,3,4;

---locked object find 
select distinct object_name from gv$locked_object a, dba_objects b where a.object_id=b.object_id;
