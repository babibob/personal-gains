SELECT  substring_index(substring_index(event_name, '/', 2),'/',-1)  AS event_type, ROUND(sum(current_number_of_bytes_used)/1024/1024, 2) AS mb_currently_used FROM performance_schema.memory_summary_global_by_event_name GROUP BY event_type ;

SELECT substring_index(event_name,'/',2) AS code_area, format_bytes(sum(current_alloc)) AS current_alloc FROM sys.x$memory_global_by_current_bytes GROUP BY substring_index(event_name,'/',2) ORDER BY SUM(current_alloc) DESC;

SELECT event_name, current_alloc, high_alloc FROM sys.memory_global_by_current_bytes;

SELECT * FROM performance_schema.memory_summary_global_by_event_name WHERE EVENT_NAME LIKE 'memory/innodb/buf_buf_pool'\G;

SELECT file_name, tablespace_name, engine, initial_size, total_extents*extent_size AS totalsizebytes, data_free, maximum_size FROM information_schema.files WHERE tablespace_name = 'innodb_temporary'\G

SHOW GLOBAL STATUS LIKE 'Com_dealloc_sql';

SHOW engine innodb STATUS \G;

SHOW STATUS WHERE variable_name LIKE "Threads_%" OR variable_name = "Connections";

SHOW VARIABLES WHERE Variable_Name IN ('key_buffer_size')\G;

SHOW STATUS LIKE 'Open_tables';

SHOW PROCESSLIST;