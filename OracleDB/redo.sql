with redo_sz as
 (select sysst.snap_id,
         sysst.instance_number,
         begin_interval_time,
         end_interval_time,
         startup_time,
         value - lag(value) over(partition by startup_time, sysst.instance_number order by begin_interval_time, startup_time, sysst.instance_number) stat_value,
         extract(day from(end_interval_time - begin_interval_time)) * 24 * 60 * 60 +
         extract(hour from(end_interval_time - begin_interval_time)) * 60 * 60 +
         extract(minute from(end_interval_time - begin_interval_time)) * 60 +
         extract(second from(end_interval_time - begin_interval_time)) delta
    from sys.wrh$_sysstat sysst, dba_hist_snapshot snaps
   where (sysst.dbid, sysst.stat_id) in
         (select dbid, stat_id
            from sys.wrh$_stat_name
           where stat_name = 'redo size')
     and snaps.snap_id = sysst.snap_id
     and snaps.dbid = sysst.dbid
     and sysst.instance_number = snaps.instance_number
     and begin_interval_time > sysdate - 90)
select instance_number,
       to_date(to_char(begin_interval_time, 'DD-MON-YYYY'), 'DD-MON-YYYY') dt,
       sum(stat_value) redo1
  from redo_sz
 group by instance_number,
          to_date(to_char(begin_interval_time, 'DD-MON-YYYY'),
                  'DD-MON-YYYY')
 order by instance_number, 2;



-- Find redo log generated
declare
  v_1 number;
  v_2 number;
begin
  select value into v_1 from v$sysstat where name = 'redo size';
  for i in 1 .. 500 loop
    update mytable set mycolumn = 'myvalue'; -- Some query that generates redo
    commit;
  end loop;
  select value into v_2 from v$sysstat where name = 'redo size';

  dbms_output.put_line((v_2 - v_1) / 1024 / 1024);
end;


-- Set undo for temporary objects into temp tablespace
alter session set temp_undo_enabled = true;

select * from gv$tempundostat

select *
  from gv$sort_usage
 where sql_id_tempseg in
       (select distinct sql_id
          from gv$sql
         where lower(sql_text) like '%my_temp_table%');

