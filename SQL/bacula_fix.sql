# mysql bacula - on the bacula-director>$ mysql

USE bacula

# Look column 'JobID' for Job with '<NAME-job>' , where 'JobStatus == f', and remember that '<JobID>'
SELECT Job, JobId, JobStatus, Level FROM Job WHERE Name="<NAME-job>" ORDER BY JobId DESC LIMIT 10 ;

UPDATE Job SET JobStatus="T" WHERE JobId=<JobID>;

# Look when "f" cange to "T"
SELECT Job, JobId, JobStatus, Level FROM Job WHERE Name="<NAME-job>" ORDER by JobId DESC LIMIT 10 ;

