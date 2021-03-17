-- Archive log size hourly
 select nvl(to_char(archived_date, 'YYYY-MM-DD'), 'Total Size') archived_date,
       "Time (hh24)",
       nvl(to_char(inst_id), ' ') inst_id,
       size_in_gb
  from (select trunc(completion_time) archived_date,
               to_char(completion_time, 'HH24') "Time (hh24)",
               thread# inst_id,
               round(sum(blocks * block_size) / 1024 / 1024 / 1024, 2) size_in_gb
          from v$archived_log t
         where t.completion_time between timestamp'2021-03-16 22:00:00' and
               timestamp'2021-03-16 23:00:00'
         group by rollup((trunc(completion_time),
                          to_char(completion_time, 'HH24')),
                         thread#)
         order by nvl(to_char(archived_date, 'YYYY-MM-DD'), '1'), 2, 3);

-- Archive log size 10 min
  select nvl(to_char(archived_date, 'YYYY-MM-DD'), 'Total Size') archived_date,
         "Time (hh24)",
         decode("Minute Period",
                '0',
                'min 00',
                nvl2("Minute Period",
                     'from min ' || (to_number("Minute Period") * 10 - 9) ||
                     ' to min ' || "Minute Period" * 10,
                     'Total')) "Minute Range",
         nvl(to_char(inst_id), 'both') inst_id,
         size_in_gb
    from (select trunc(completion_time) archived_date,
                 to_char(completion_time, 'HH24') "Time (hh24)",
                 ceil(to_char(completion_time, 'MI') / 10) "Minute Period",
                 thread# inst_id,
                 round(sum(blocks * block_size) / 1024 / 1024 / 1024, 2) size_in_gb
            from v$archived_log t
           where t.completion_time between timestamp'2021-03-16 22:00:00' and
               timestamp'2021-03-16 23:00:00'
           group by rollup((trunc(completion_time),
                            to_char(completion_time, 'HH24'),
                            ceil(to_char(completion_time, 'MI') / 10)),
                           thread#)
           order by nvl(to_char(archived_date, 'YYYY-MM-DD'), '1'), 2, 3);


-- Step 1: Know which table / object has more changes during the problematic window:
select to_char(begin_interval_time, 'YYYY_MM_DD HH24:MI') snap_time,
       dhsso.object_name,
       sum(db_block_changes_delta) as maxchages
  from dba_hist_seg_stat     dhss,
       dba_hist_seg_stat_obj dhsso,
       dba_hist_snapshot     dhs
 where dhs.snap_id = dhss.snap_id
   and dhs.instance_number = dhss.instance_number
   and dhss.obj# = dhsso.obj#
   and owner = 'MYOWNER'
   and dhss.dataobj# = dhsso.dataobj#
   and begin_interval_time between timestamp'2021-03-16 22:00:00' and
       timestamp'2021-03-16 23:00:00'
 group by to_char(begin_interval_time, 'YYYY_MM_DD HH24:MI'),
          dhsso.object_name
 order by maxchages asc;

-- Step 2: Once you know the objects, get SQL info related to those objects:
select to_char(begin_interval_time, 'YYYY_MM_DD HH24:MI'),
       dbms_lob.substr(sql_text, 4000, 1),
       dhss.instance_number,
       dhss.sql_id,
       executions_delta,
       rows_processed_delta
  from dba_hist_sqlstat dhss, dba_hist_snapshot dhs, dba_hist_sqltext dhst
 where upper(dhst.sql_text) like '%MY_OBJECT_NAME%'
   and dhss.snap_id = dhs.snap_id
   and dhss.instance_number = dhs.instance_number
   and begin_interval_time between timestamp'2021-03-16 22:00:00' and
       timestamp'2021-03-16 23:00:00'
   and dhss.sql_id = dhst.sql_id;

