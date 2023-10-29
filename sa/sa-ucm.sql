/*
File Name: sa-ucm.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- UCM DATA 1
-- UCM DATA 2 - ALL COLUMNS
-- SUMMARY

*/



-- ##############################################################
-- UCM DATA 1
-- ##############################################################

/*
DATA FROM HOME > TOOLS > FILE IMPORT AND EXPORT
Note - Process ID is not included in the revisions table
Can see it via File Import and Export front-end but not in revisions table
*/

		select rev.ddocname -- "Content ID" on front-end
			 , rev.ddoctitle || '.' || rev.dwebextension file_name
			 , rev.ddoctype
			 , rev.ddocauthor
			 , rev.dsecuritygroup
			 , to_char(rev.dcreatedate, 'yyyy-mm-dd hh24:mi:ss') dcreatedate
			 , rev.ddocaccount
			 , rev.dwebextension
			 , rev.ddoctitle -- "Title" on front-end ("File" on front-end is DDOCTITLE + "." + DWEBEXTENSION)
			 , rev.did
			 , to_char(rev.dindate, 'yyyy-mm-dd hh24:mi:ss') dindate
			 , to_char(rev.dreleasedate, 'yyyy-mm-dd hh24:mi:ss') dreleasedate
			 , rev.dstatus
			 , rev.dreleasestate
			 , rev.dprocessingstate
			 , rev.dindexerstate
			 , rev.drevrank
			 , rev.drevclassid
			 , rev.drevisionid
			 , rev.drevlabel
			 , rev.discheckedout
		  from revisions rev
		 where 1 = 1
		   and 1 = 1
	  order by rev.did desc

-- ##############################################################
-- UCM DATA 2 - ALL COLUMNS
-- ##############################################################

		select rev.*
		  from revisions rev
		 where 1 = 1
		   and 1 = 1
	  order by rev.did desc

-- ##############################################################
-- SUMMARY
-- ##############################################################

		select rev.ddocaccount
			 , count(*) ct
		  from revisions rev
		 where 1 = 1
		   and 1 = 1
	  group by rev.ddocaccount
	  order by 2 desc
