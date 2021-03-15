CREATE OR REPLACE DIRECTORY db_replay_capture_dir AS '/u01/app/oracle/db_replay_capture/';

BEGIN
  dbms_workload_capture.start_capture (name     => 'test_capture_1', 
                                       dir      => 'DB_REPLAY_CAPTURE_DIR',
                                       duration => NULL);
END;
/


-- CONN sys/password@prod AS SYSDBA

BEGIN
  dbms_workload_capture.finish_capture;
END;
/




DECLARE
  l_report  CLOB;
BEGIN
  l_report := dbms_workload_capture.report(capture_id => 21,
                                           format     => dbms_workload_capture.TYPE_HTML);
END;
/



BEGIN
  dbms_workload_capture.export_awr (capture_id => 21);
END;
/



BEGIN
  dbms_workload_replay.process_capture('DB_REPLAY_CAPTURE_DIR');

  dbms_workload_replay.initialize_replay (replay_name => 'test_capture_1',
                                          replay_dir  => 'DB_REPLAY_CAPTURE_DIR');

  dbms_workload_replay.prepare_replay (synchronization => TRUE);
END;
/



-- calibrate using wrc
$ wrc mode=calibrate replaydir=/u01/app/oracle/db_replay_capture


BEGIN
  dbms_workload_replay.start_replay;
END;
/


DECLARE
  l_report  CLOB;
BEGIN
  l_report := dbms_workload_replay.report(replay_id => 11,
                                          format     => dbms_workload_replay.TYPE_HTML);
END;
/

