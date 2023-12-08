/*
File Name: sa-purge-job-frequency.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Fusion Applications: SOA Purge Details of a Software as a Service (SaaS) Fusion Apps Environment (Doc ID 2175534.1)
Is data purged from FA_FUSION_SOAINFRA WF% tables?
https://cloudcustomerconnect.oracle.com/posts/396af4367b
*/

		select owner
			 , job_name
			 , to_char(start_date, 'yyyy-mm-dd hh24:mi:ss') start_date
			 , repeat_interval
			 , state
			 , to_char(last_start_date, 'yyyy-mm-dd hh24:mi:ss') last_start_date
			 , job_action
			 , to_char(next_run_date, 'yyyy-mm-dd hh24:mi:ss') next_run_date
		  from dba_scheduler_jobs 
		 where job_name like '%%PURGE%%' 
		   and owner = 'FA_FUSION_SOAINFRA'
