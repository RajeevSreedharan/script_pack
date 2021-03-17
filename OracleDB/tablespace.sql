-- query all tablespace 
select A.Tablespace_Name,
       round(B.Total / 1024 / 1024 / 1024, 2) "Total GB",
       round((B.Total - a.Total_Free) / 1024 / 1024 / 1024, 2) "GB Used",
       round(A.Total_Free / 1024 / 1024 / 1024, 2) "GB Free",
       round((A.Total_Free / B.Total) * 100, 2) "Pct Free",
       round(((B.Total - A.Total_Free) / B.Total) * 100, 2) "Pct Used"
  from (Select Tablespace_Name, Sum(Bytes) Total_Free
          From Sys.Dba_Free_Space
         Group By Tablespace_Name) A,
       (Select Tablespace_Name, Sum(Bytes) Total
          From Sys.Dba_Data_Files
         Group By Tablespace_Name) B
 where  A.Tablespace_Name = B.Tablespace_Name
 order By 1 ;

-- query all segments 
SELECT /*+parallel(32)*/ DISTINCT b.*, a.segment_type
  FROM dba_segments a,
       (SELECT owner,
               segment_name,
               tablespace_name,
               round(SUM(bytes) / 1024 / 1024 / 1024, 2) AS GB
          FROM dba_segments
         GROUP BY owner, tablespace_name, segment_name
         ORDER BY gb DESC) b
 WHERE a.owner = b.owner
   AND a.segment_name = b.segment_name
   AND a.owner= 'C51PRODHST'
   and gb > 1
   and (b.segment_name not like 'BIN%' and b.segment_name not like 'SYS%$$')
 ORDER BY b.owner,
          b.segment_name;


select sum(bytes/1024/1024/1024) from dba_segments;
select round(SUM(bytes) / 1024 / 1024 / 1024, 2) AS GB from dba_temp_files ; -- temp space
select inst_id, round(SUM(bytes) / 1024 / 1024 / 1024, 2) AS GB FROM gv$log group by inst_id; --redo space , take one instance only
select * FROM v$log ;
select * FROM v$logfile
