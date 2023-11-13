/*
File Name: sa-requests-history.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- TABLE DUMPS
-- REQUEST HISTORY - NO HR TABLES
-- REQUEST HISTORY - HR TABLES
-- REQUEST HISTORY - SCHEDULED
-- REQUEST HIERARCHY ATTEMPT DOES NOT WORK (ORA-01436: CONNECT BY LOOP IN USER DATA)
-- COUNT BY PRODUCT
-- COUNT BY JOB
-- COUNT BY STATUS
-- COUNT BY DAY
-- COUNT BY DAY, WEEKDAY AND HOUR
-- COUNT BY HOUR
-- COUNT BY USERNAME
-- COUNT LINKED TO HR RECORD
-- COUNT SCHEDULED JOBS BY PRODUCT
-- JOB HISTORY INCLUDING JOB NAME LOOKUP
-- JOB DEFINITION
-- BI PUBLISHER JOB HISTORY

Notes

REQUEST_HISTORY and ESS_REQUEST_HISTORY contain the same data

- Can have lots of different REQUESTIDS, all with same ABSPARENTID as all scheduled via same scheduled parent ID
	- but can have different blocks of INSTANCEPARENTID
	- e.g. blocks of 3 INSTANCEPARENTIDs, since there can be a parent instance with 3 different child REQUESTIDs, but still all jobs have the same ABSPARENTID
	- but that parent with 3 child jobs still has the same ultimate parent id

e.g. 

REQUESTID	ABSPARENTID	INSTANCEPARENTID
3966549		3963654		3966549
3966547		3963654		3966538
3966546		3963654		3966538
3966538		3963654		3966538
3966537		3963654		3966532
3966536		3963654		3966532
3966532		3963654		3966532
3966531		3963654		3966526
3966530		3963654		3966526
3966526		3963654		3966526
3966525		3963654		3966522
3966524		3963654		3966522
3966522		3963654		3966522
3966521		3963654		3966517
3966520		3963654		3966517
3966517		3963654		3966517
3966516		3963654		3966511
3966515		3963654		3966511
3966511		3963654		3966511

*/

-- ##############################################################
-- TABLE DUMPS
-- ##############################################################

select * from fusion_ora_ess.request_history where requestid = 123456
select * from fusion_ora_ess.request_history where username = 'USER123'
select * from fusion_ora_ess.request_history_view where requestid = 123456
select * from fusion_ora_ess.request_property where requestid = 123456

-- ##############################################################
-- REQUEST HISTORY - NO HR TABLES
-- ##############################################################

		select rh.requestid
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 -- , rh.state
			 , flv_state.meaning status
			 -- , rh.name submission_comments
			 -- , to_char(rh.processstart, 'dy') weekday
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 -- , '#' || replace(substr(to_char(rh.processend-rh.processstart, 'DD HH24:MI:SS'), 0, instr(to_char(rh.processend-rh.processstart, 'DD HH24:MI:SS'), '.')-1),'+0000000','') duration -- dd_mm_hh_ss
			 -- , round((cast(sys_extract_utc (rh.processend) as date) - cast(sys_extract_utc (rh.processstart) as date)) * 1440,2) total_minutes
			 , rh.definition definition1
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition2
			 , rh.jobtype
			 -- , rh.product
			 , rh.username
			 -- , rh.adhocschedule
			 -- , to_timestamp(substr((substr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<start>') +length('<start>'),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'</start>') - instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<start>') -length('<start>'))),1,19), 'yyyy-mm-dd hh24:mi:ss') schedule_start
			 -- , to_timestamp(substr((substr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<end>') +length('<end>'),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'</end>') - instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<end>') - length('<end>'))),1,19), 'yyyy-mm-dd hh24:mi:ss') schedule_end
			 -- , substr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<frequency>') +length('<frequency>'),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'</frequency>') - instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<frequency>') -length('<frequency>')) frequency
			 -- , substr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<interval>') +length('<interval>'),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),'') ,'</interval>')- instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),'') ,'<interval>') -length('<interval>')) interval_
			 -- , substr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<ical-expression>') +length('<ical-expression>'),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),'') ,'</ical-expression>')- instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),'') ,'<ical-expression>') -length('<ical-expression>')) sched_data
			 -- , replace(replace(replace(utl_raw.cast_to_varchar2(rh.adhocschedule),chr(0),''),chr(10),''),chr(13),'') adhocschedule_cast
			 -- , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 -- , rh.error_warning_detail -- including this breaks excel export as it always has line breaks and things in it, even if you try and strip them out they always appear at the start of the field, whatever i try...
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		 where 1 = 1
		   -------------------------- ids --------------------------
		   -- and rh.requestid = 123456
		   -- and rh.requestid between 123456 and 123490
		   -- and rh.absparentid = 1609423
		   -------------------------- definition --------------------------
		   -- and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('APCSTTRF')
		   -------------------------- users --------------------------
		   and rh.username = 'THIS'
		   -- and rh.username not in ('FIN_SCHEDULE','FAAdmin','FUSION_APPS_PRC_SOA_APPID')
		   -- and rh.username in ('APXIIMPT_BIP')
		   -------------------------- misc --------------------------
		   -- and flv_state.meaning = 'Wait'
		   -- and rh.executable_status = 'ERROR'
		   -- and rh.error_warning_detail is not null
		   -- and rh.adhocschedule is not null
		   -- and rh.adhocschedule is not null
		   and rh.adhocschedule is null -- not scheduled
		   -------------------------- product --------------------------
		   -- and rh.product = 'IEX'
		   -- and rh.product like 'PJ%'
		   -- and rh.product in ('FUN','GL')
		   -------------------------- dates and times --------------------------
		   -- and rh.processstart > sysdate - 10
		   -- and rh.completedtime is null
		   -- and rh.scheduled is null
		   and to_char(rh.processstart, 'YYYY') = '2023'
		   and to_char(rh.processstart, 'MM') = '10'
		   and to_char(rh.processstart, 'DD') = '03'
		   -- and to_char(rh.processstart, 'HH24') = '03'
		   -- and to_char(rh.processstart, 'HH24') > 22
		   -- and to_char(rh.processstart, 'DD') in ('01','02','03','04','05','06')
		   -- and to_char(rh.processstart, 'HH24') in ('01')
		   -- and round((cast(sys_extract_utc (rh.processend) as date) - cast(sys_extract_utc (rh.processstart) as date)) * 1440,2) > 200
	  order by rh.requestid desc

-- ##############################################################
-- REQUEST HISTORY - HR TABLES
-- ##############################################################

		select rh.requestid
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , rh.state
			 , flv_state.meaning status
			 , rh.name submission_comments
			 , to_char(rh.processstart, 'dy') weekday
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , '#' || replace(substr(to_char(rh.processend-rh.processstart, 'DD HH24:MI:SS'), 0, instr(to_char(rh.processend-rh.processstart, 'DD HH24:MI:SS'), '.')-1),'+0000000','') duration -- dd_mm_hh_ss
			 , round((cast(sys_extract_utc (rh.processend) as date) - cast(sys_extract_utc (rh.processstart) as date)) * 1440,2) total_minutes
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , replace(rh.definition, 'JobDefinition://', '') def1
			 , rh.definition full_definition
			 , regexp_substr(replace(rh.definition, 'JobDefinition://', ''), '[^/]+', 1, 1) segment1
			 , rh.product
			 , rh.username
			 , ppnf.full_name
			 , ppx.person_number
			 , nvl(pea.email_address, 'no-email') email_address
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , rh.error_warning_detail -- including this breaks excel export as it always has line breaks and things in it, even if you try and strip them out they always appear at the start of the field, whatever i try...
			 , '#########################'
			 , rhv.name rhv_name
			 , rhv.lastscheduleinstanceid
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS' and flv_state.view_application_id = 0
	left join per_users pu on rh.username = pu.username and pu.active_flag = 'Y' -- some user accounts have more than 1 row in user tables e.g. FAAdmin, so only select active user
	left join per_people_x ppx on ppx.person_id = pu.person_id
	left join per_person_names_f ppnf on ppx.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	left join per_email_addresses pea on ppx.person_id = pea.person_id and pea.email_type = 'W1'
	left join fusion_ora_ess.request_history_view rhv on rhv.requestid = rh.requestid
		 where 1 = 1
		   -------------------------- ids --------------------------
		   -- and rh.requestid = 123456
		   -- and rh.requestid between 123456 and 123490
		   -- and rh.requestid in (123456,123457)
		   -------------------------- definition --------------------------
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) not in ('RebuildLearningItemSearchKeywordsJob')
		   -------------------------- users --------------------------
		   -- and fu.username = 'USER123'
		   -- and rh.username not in ('FIN_SCHEDULE','FAAdmin','FUSION_APPS_PRC_SOA_APPID')
		   -- and rh.username in ('APXIIMPT_BIP')
		   -------------------------- misc --------------------------
		   -- and flv_state.meaning = 'Error'
		   -- and rh.executable_status = 'ERROR'
		   -- and rh.error_warning_detail is not null
		   -- and rh.adhocschedule is not null
		   -- and rh.adhocschedule is null -- not scheduled
		   -------------------------- product --------------------------
		   -- and rh.product = 'AP'
		   -- and rh.product like 'PJ%'
		   -- and rh.product in ('FUN','GL')
		   -------------------------- dates and times --------------------------
		   -- and rh.processstart > sysdate - 10
		   -- and rh.completedtime is null
		   -- and rh.scheduled is null
		   -- and to_char(rh.processstart, 'YYYY') = '2023'
		   -- and to_char(rh.processstart, 'MM') = '04'
		   -- and to_char(rh.processstart, 'DD') = '27'
		   -- and to_char(rh.processstart, 'HH24') > 10
		   -- and to_char(rh.processstart, 'HH24') < 15
		   -- and to_char(rh.processstart, 'DD') in ('01','02','03','04','05','06')
		   -- and to_char(rh.processstart, 'HH24') in ('01')
		   -- and round((cast(sys_extract_utc (rh.processend) as date) - cast(sys_extract_utc (rh.processstart) as date)) * 1440,2) > 200
	  order by rh.requestid desc

-- ##############################################################
-- REQUEST HISTORY - SCHEDULED
-- ##############################################################

/*
Where the adhocschedule contains the <ical-expression> tag
It is usually the case that the job was run by a user account ending in "APPID" e.g. FUSION_APPS_HCM_ESS_APPID
As per:
https://community.oracle.com/customerconnect/discussion/comment/888413#Comment_888413

- %APPID - These are internal application users, their purpose is to authorize an application to exchange/access another application. 
- These users do not actually have functional access to your data (eg you cannot login with any of these users to access business flows).
- The user is an internal account for Fusion Applications functionality.
- These accounts are not visible in Security Console.
- These accounts are owned by Oracle software.
- Most those users are used by program, no human know their password.

Re. CREATED_BY in PER_USERS for those %APPID user accounts:

- The create_by user in the table is the user who brought the data from ldap server into per_users table
- not the user who create the APPID user in ldap server.
- the create_by user in ldap server will be an system user, but cloud customer does not have access to ldap server
- for example, the user who run retrieve latest ldap changes process, will bring data into per_users table, and that user can be the create_by user in the table

Other <ical-expression> jobs are submitted by the "FAAdmin" user

FndExtMgrDigestPurgeJob - Job for purging Extension Manager old Digests
FndIDCSSyncNotifyServiceJob - Job for FA IDCS Users Sync
FndOSCSBulkIngestJob - Job for processing errored rows to Oracle Search Cloud Service
FndOSCSAvailabilityJob - Job to check Search Cloud Service availability
FndOSCSAttachmentIngestJob - Job for ingesting attachments to Oracle Search Cloud Service
BPMSMCAttachmentUploadServiceJob - Job to Upload Attachments of BPM Archive Tasks.
BPMSMCTranslationServiceJob - Job to Process Translation of BPM Archive Tasks.
BPMSMCDataExtractServiceJob - Job to Extract Workflow Tasks for Archive.

Also, some jobs are submitted by "regular" non system users where the <ical-expression> tag is populated in adhocschedule

Main job seems to be the "EssBipJob" under the "BI Publisher" Product name, so these are scheduled BI Publisher jobs.

Therefore, to return non <ical-expression> jobs, add this line:

and instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<ical-expression>') = 0 -- exclude jobs run by system %APPID accounts, plus the "EssBipJob" BI Publiser job
*/


		select rh.requestid
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 -- , rh.state
			 , flv_state.meaning status
			 , rh.name submission_comments
			 , to_char(rh.processstart, 'dy') weekday
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 -- , rh.adhocschedule
			 , to_char(to_timestamp(substr((substr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<start>') +length('<start>'),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'</start>') - instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<start>') - length('<start>'))),1,19), 'yyyy-mm-dd hh24:mi:ss'), 'yyyy-mm-dd hh24:mi:ss') schedule_start
			 , to_char(to_timestamp(substr((substr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<end>') +length('<end>'),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'</end>') - instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<end>') - length('<end>'))),1,19), 'yyyy-mm-dd hh24:mi:ss'), 'yyyy-mm-dd hh24:mi:ss') schedule_end
			 , substr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<frequency>') +length('<frequency>'),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'</frequency>') - instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<frequency>') - length('<frequency>')) frequency
			 , substr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<interval>') +length('<interval>'),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),'') ,'</interval>')- instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),'') ,'<interval>') - length('<interval>')) interval_
			 , substr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<months-of-year>') +length('<months-of-year>'),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),'') ,'</months-of-year>')- instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),'') ,'<months-of-year>') - length('<months-of-year>')) months_of_year
			 , substr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<days-of-week>') +length('<days-of-week>'),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),'') ,'</days-of-week>')- instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),'') ,'<days-of-week>') - length('<days-of-week>')) days_of_week
			 , substr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<weeks-of-month>') +length('<weeks-of-month>'),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),'') ,'</weeks-of-month>')- instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),'') ,'<weeks-of-month>') - length('<weeks-of-month>')) weeks_of_month
			 , substr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<days-of-month>') +length('<days-of-month>'),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),'') ,'</days-of-month>')- instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),'') ,'<days-of-month>') - length('<days-of-month>')) days_of_month
			 , substr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<ical-expression>') +length('<ical-expression>'),instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),'') ,'</ical-expression>')- instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),'') ,'<ical-expression>') - length('<ical-expression>')) sched_data
			 , replace(replace(replace(utl_raw.cast_to_varchar2(rh.adhocschedule),chr(0),''),chr(10),''),chr(13),'') adhocschedule_cast
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		 where 1 = 1
		   -------------------------- scheduled --------------------------
		   and rh.parentrequestid = -1
		   and rh.requesttype = 2
		   and rh.state = 1
		   and flv_state.meaning = 'Wait'
		   and rh.adhocschedule is not null
		   and instr(replace(utl_raw.cast_to_varchar2(adhocschedule),chr(0),''),'<ical-expression>') = 0 -- exclude jobs run by system %APPID accounts, plus the "EssBipJob" BI Publiser job
		   -------------------------- ids --------------------------
		   -- and rh.requestid = 123456
		   -- and rh.requestid between 123456 and 123490
		   -- and rh.requestid in (5000811, 5000817, 5000822, 5000825)
		   -------------------------- definition --------------------------
		   -- and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) = 'XLAFSNAPRPT'
		   -------------------------- users --------------------------
		   -- and rh.username not like '%APPID'
		   -- and rh.username not in ('FIN_SCHEDULE','FAAdmin','FUSION_APPS_PRC_SOA_APPID')
		   -- and rh.username in ('APXIIMPT_BIP')
		   -------------------------- misc --------------------------
		   -- and flv_state.meaning = 'Error'
		   -- and rh.executable_status = 'ERROR'
		   -- and rh.error_warning_detail is not null
		   -------------------------- product --------------------------
		   -- and rh.product = 'AP'
		   -- and rh.product like 'PJ%'
		   -- and rh.product in ('FUN','GL')
		   -------------------------- dates and times --------------------------
		   -- and rh.processstart > sysdate - 10
		   -- and rh.completedtime is null
		   -- and rh.scheduled is null
		   -- and to_char(rh.processstart, 'YYYY') = '2023'
		   -- and to_char(rh.processstart, 'MM') = '04'
		   -- and to_char(rh.processstart, 'DD') = '27'
		   -- and to_char(rh.processstart, 'HH24') > 10
		   -- and to_char(rh.processstart, 'HH24') < 15
		   -- and to_char(rh.processstart, 'DD') in ('01','02','03','04','05','06')
		   -- and to_char(rh.processstart, 'HH24') in ('01')
		   -- and round((cast(sys_extract_utc (rh.processend) as date) - cast(sys_extract_utc (rh.processstart) as date)) * 1440,2) > 200
	  order by rh.requestid desc

-- ##############################################################
-- REQUEST HIERARCHY ATTEMPT DOES NOT WORK (ORA-01436: CONNECT BY LOOP IN USER DATA)
-- ##############################################################

		select rh.requestid
			 , trim(lpad('_', (level - 1) * 2, '_') || rh.requestid) id
			 , level
			 , trim(lpad('_', (level - 1) * 2, '_') || substr(rh.definition,(instr(rh.definition,'/',-1)+1))) job
			 , rh.absparentid parent_
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , '#' || replace(substr(to_char(rh.processend-rh.processstart, 'DD HH24:MI:SS'), 0, instr(to_char(rh.processend-rh.processstart, 'DD HH24:MI:SS'), '.')-1),'+0000000','') duration -- dd_mm_hh_ss
			 , round((cast(sys_extract_utc (rh.processend) as date) - cast(sys_extract_utc (rh.processstart) as date)) * 1440,2) total_minutes
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS' and flv_state.view_application_id = 0
		 where 1 = 1
		   and rh.requestid != rh.absparentid
	start with rh.requestid = 123453
	connect by prior rh.requestid = rh.instanceparentid
order siblings by rh.requestid

-- ##############################################################
-- COUNT BY PRODUCT
-- ##############################################################

		select product
			 , min(to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss')) min_start
			 , max(to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss')) max_start
			 , min(to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss')) min_submission
			 , max(to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss')) max_submission
			 , min(requestid)
			 , max(requestid)
			 , count(*)
		  from request_history rh
		 where 1 = 1
		   and 1 = 1
	  group by product

-- ##############################################################
-- COUNT BY JOB
-- ##############################################################

		select substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , product
			 , username
			 , min(to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss')) min_start
			 , max(to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss')) max_start
			 , min(to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss')) min_submission
			 , max(to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss')) max_submission
			 , min(requestid)
			 , max(requestid)
			 , count(*)
		  from request_history rh
		 where 1 = 1
		   and to_char(rh.processstart, 'YYYY') = '2023'
		   and to_char(rh.processstart, 'MM') = '01'
		   -- and to_char(rh.processstart, 'DD') in ('4','5','11','12','18','19','25','26')
		   -- and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('PostingSingleLedger')
		   and 1 = 1
		   and product = 'IEX'
	  group by substr(rh.definition,(instr(rh.definition,'/',-1)+1))
			 , product
			 , username

-- ##############################################################
-- COUNT BY STATUS
-- ##############################################################

		select flv_state.meaning status
			 , min(to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss')) min_start
			 , max(to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss')) max_start
			 , min(to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss')) min_submission
			 , max(to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss')) max_submission
			 , min(requestid)
			 , max(requestid)
			 , count(*)
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS' and flv_state.view_application_id = 0
		 where 1 = 1
		   -- and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) = 'XLAOTEC'
	  group by flv_state.meaning
	  order by flv_state.meaning

		select rh.state
			 , min(to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss')) min_start
			 , max(to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss')) max_start
			 , min(to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss')) min_submission
			 , max(to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss')) max_submission
			 , min(requestid)
			 , max(requestid)
			 , count(*)
		  from request_history rh
	  group by rh.state

-- ##############################################################
-- COUNT BY DAY
-- ##############################################################

		select to_char(rh.processstart, 'yyyy-mm-dd') the_date
			 , product
			 , username
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , min(to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss')) min_start
			 , max(to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss')) max_start
			 , min(to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss')) min_submission
			 , max(to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss')) max_submission
			 , min(requestid)
			 , max(requestid)
			 , count(*)
		  from request_history rh
		 where 1 = 1
		   and rh.processstart is not null
		   and to_char(rh.processstart, 'YYYY') = '2023'
		   and to_char(rh.processstart, 'MM') = '01'
		   and product = 'IEX'
		   -- and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('XLAJELRPT')
		   -- and to_char(submission, 'YYYY') = '2022'
		   -- and to_char(submission, 'MM') = '10'
		   -- and processstart > sysdate - 100
	  group by to_char(rh.processstart, 'yyyy-mm-dd')
			 , product
			 , username
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1))
	  order by 1 desc

-- ##############################################################
-- COUNT BY DAY, WEEKDAY AND HOUR
-- ##############################################################

		select to_char(rh.processstart, 'yyyy-mm-dd') the_date
			 , to_char(rh.processstart, 'hh24') hr
			 , to_char(rh.processstart, 'dy') dy
			 , min(requestid)
			 , max(requestid)
			 , count(*)
		  from request_history rh
		 where 1 = 1
		   -- and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('XLAJELRPT')
		   and to_char(submission, 'YYYY') = '2022'
		   and to_char(submission, 'MM') = '11'
		   and to_char(submission, 'DD') > '10'
		   and to_char(rh.processstart, 'dy') in (6,7)
	  group by to_char(rh.processstart, 'yyyy-mm-dd')
			 , to_char(rh.processstart, 'hh24')
			 , to_char(rh.processstart, 'dy')
	  order by 1 desc

-- ##############################################################
-- COUNT BY HOUR
-- ##############################################################

		select to_char(rh.processstart, 'hh24') hr
			 , count(*)
		  from request_history rh
		 where 1 = 1
		   and to_char(submission, 'YYYY') = '2022'
		   and to_char(submission, 'MM') = '10'
		   and to_char(submission, 'DD') = '21'
	  group by to_char(rh.processstart, 'hh24')
	  order by to_char(rh.processstart, 'hh24') desc

-- ##############################################################
-- COUNT BY USERNAME
-- ##############################################################

		select rh.username
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , min(to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss')) min_run
			 , max(to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss')) max_run
			 , min(requestid)
			 , max(requestid)
			 , count(*)
		  from request_history rh
		 where 1 = 1
		   -- and rh.username = 'USER123'
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) = 'ImportProcessParallelEssJob'
		   and to_char(processstart, 'YYYY') = '2022'
		   and to_char(processstart, 'MM') >= '07'
		   -- and to_char(processstart, 'DD') = '29'
		   -- and to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') > '2020-03-15 00:00:00'
	  group by rh.username
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1))
	  order by 4 desc

-- ##############################################################
-- COUNT BY USERNAME, DEFINITION AND STATUS
-- ##############################################################

		select rh.username
			 , pu.suspended
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , flv_state.meaning status
			 , min(to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss')) min_run
			 , max(to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss')) max_run
			 , min(requestid)
			 , max(requestid)
			 , min(absparentid)
			 , max(absparentid)
			 , min(instanceparentid)
			 , max(instanceparentid)
			 , count(*)
		  from request_history rh
		  join per_users pu on pu.username = rh.username
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS' and flv_state.view_application_id = 0
		 where 1 = 1
		   and rh.product = 'IEX'
		   -- and rh.username in ('USER1')
		   -- and rh.product = 'PJS'
	  group by rh.username
			 , pu.suspended
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1))
			 , flv_state.meaning

-- ##############################################################
-- COUNT LINKED TO HR RECORD
-- ##############################################################

		select rh.username
			 , ppnf.full_name
			 , ppx.person_number
			 , nvl(pea.email_address, 'no-email') email_address
			 , min(to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss')) min_run
			 , max(to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss')) max_run
			 , count(*)
		  from request_history rh
		  join per_users fu on rh.username = fu.username
		  join per_people_x ppx on ppx.person_id = fu.person_id
		  join per_person_names_f ppnf on ppx.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL'
	 left join per_email_addresses pea on ppx.person_id = pea.person_id and pea.email_type = 'W1'
		 where 1 = 1
		   and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
		   and to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') > '2020-03-15 00:00:00'
	  group by rh.username
			 , ppnf.full_name
			 , ppx.person_number
			 , nvl(pea.email_address, 'no-email')
	  order by 7 desc

-- ##############################################################
-- COUNT SCHEDULED JOBS BY PRODUCT
-- ##############################################################

		select rh.product
			 , min(substr(rh.definition,(instr(rh.definition,'/',-1)+1))) min_job
			 , max(substr(rh.definition,(instr(rh.definition,'/',-1)+1))) max_job
			 , min(rh.requestid) min_id
			 , max(rh.requestid) max_id
			 , min(rh.username) min_user
			 , max(rh.username) max_user
			 , count(rh.requestid) job_count
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		 where 1 = 1
		   and flv_state.meaning = 'Wait'
		   and rh.adhocschedule is not null -- not scheduled
	  group by rh.product
	  order by rh.product

-- ##############################################################
-- JOB HISTORY INCLUDING JOB NAME LOOKUP
-- ##############################################################

/*
The full job name is not accessible in any Fusion tables accessible to regular users hence this over the top statement
*/

with tbl_job_lookups as
	   (select 'ABSDLYDTLS', 'Generate Daily Breakdown of Absence Details' from dual union all
		select 'ABSDLYDTLSCHILD', 'Generate Daily Breakdown of Absence Details: Subprocess' from dual union all
		select 'ABSEVAL', 'Evaluate Absences' from dual union all
		select 'ACRPRC', 'Calculate Accruals and Balances' from dual union all
		select 'ACRPRCCHILD', 'Calculate Accrual and Balances: Subprocess' from dual union all
		select 'APCSTTRF', 'Transfer Costs to Cost Management' from dual union all
		select 'APINVSEL', 'Payables Selected Installments Report' from dual union all
		select 'APMACR', 'Create Mass Additions' from dual union all
		select 'APXAPRVL', 'Validate Payables Invoices' from dual union all
		select 'APXIAWRE', 'Initiate Invoice Approval Workflow' from dual union all
		select 'APXIIMPT', 'Import Payables Invoices' from dual union all
		select 'APXIIMPT_BIP', 'Import Payables Invoices Report' from dual union all
		select 'AccountingPeriodOpen', 'Open Accounting Period' from dual union all
		select 'AccountingPeriodOpenReportJob', 'Open Accounting Period: Generate Report' from dual union all
		select 'AccrueCostJob', 'Transfer Transactions from Receiving to Costing' from dual union all
		select 'ActionCaptureAggregationIncrementalJob', 'Aggregate Action Capture Data' from dual union all
		select 'Apoap', 'Open Payables Accounting Period' from dual union all
		select 'ArInterfaceJob', 'Transfer Invoice Details to Receivables' from dual union all
		select 'ArInterfaceReportJob', 'Transfer Invoice Details to Receivables: Generate Report' from dual union all
		select 'ArchiveRepDelJob', 'Archive Integration with Document of Records' from dual union all
		select 'ArchiveWriteOnlyJob', 'Generate Payroll Extract or Report' from dual union all
		select 'AseImportUsersAndRolesJob', 'Import User and Role Application Security Data' from dual union all
		select 'AseInactiveUsersDataLoadJob', 'Import User Login History' from dual union all
		select 'AutoInvoiceImportEss', 'Import AutoInvoice' from dual union all
		select 'AutoInvoiceMainEss', 'Import AutoInvoice: Execution Report' from dual union all
		select 'AutoReconciliation', 'Autoreconcile Bank Statements' from dual union all
		select 'AutoSelect', 'Initiate Payment Process Request' from dual union all
		select 'AutomaticPosting', 'AutoPost Journals' from dual union all
		select 'AutomaticReversal', 'AutoReverse Journals' from dual union all
		select 'BENEADEB', 'Enroll in Default Benefits' from dual union all
		select 'BENEADEBSUBPROC', 'Enroll in Default Benefits: Subprocess' from dual union all
		select 'BENMNGLE', 'Evaluate Life Event Participation' from dual union all
		select 'BENMNGLESUBPROC', 'Evaluate Life Event Participation: Subprocess' from dual union all
		select 'BICloudConnectorJobDefinition', 'BICloudConnectorJobDefinition' from dual union all
		select 'BIPDelivery', 'Archive Integration with BI Publisher' from dual union all
		select 'BPMSMCAttachmentUploadServiceJob', 'Upload Workflow Task Attachment for Archive' from dual union all
		select 'BPMSMCTranslationServiceJob', 'Process Translation Workflow Tasks for Archive' from dual union all
		select 'BPMSMCDataExtractServiceJob', 'Extract Workflow Tasks for Archive' from dual union all
		select 'BankStatementTransactionCreation', 'Create Bank Statement Transactions' from dual union all
		select 'BankStatementsProcessing', 'Process Electronic Bank Statements' from dual union all
		select 'BankStatementsProcessingForCloud', 'Load and Import Bank Statement' from dual union all
		select 'BillPlanProcessEss', 'Generate Recurring Billing Data' from dual union all
		select 'BudgetsXfaceBIP', 'Import Project Budget Report' from dual union all
		select 'buildAccPeriodStdCube', 'Create Balances Cube: Create Accounting Calendar Dimension Members and Hierarchies' from dual union all
		select 'buildLedgerDimensionCube', 'Create Balances Cube: Create Ledger Dimension Members' from dual union all
		select 'BuildProgramDef', 'Build Payments' from dual union all
		select 'CWorkerJob', 'Payroll Subprocess' from dual union all
		select 'CancelPpr', 'Terminate Payment Process Request' from dual union all
		select 'CashPositionDataDeletion', 'Cash Position Data Deletion' from dual union all
		select 'CashPositionDataExtraction', 'Cash Position Data Extraction' from dual union all
		select 'CashPositionDataTransfer', 'Cash Position Data Transfer' from dual union all
		select 'CommitmentProcessingJob', 'Import Commitments' from dual union all
		select 'ClosePeriod', 'Close General Ledger Periods' from dual union all
		select 'CoverArtProcessingJob', 'Process Learning Cover Art Image' from dual union all
		select 'CreateAccounting', 'Create Accounting for Projects' from dual union all
		select 'createCubes', 'Create Balances Cube: Initialize Cube' from dual union all
		select 'CreditMemoEmailReport', 'Print Receivables Transactions Email Delivery: Credit Memos' from dual union all
		select 'CubeCreationStdProgram', 'Create General Ledger Balances Cube' from dual union all
		select 'DashboardAddNewRecords', 'Update Collections Summary Data: Add Delinquency Records to Collector Dashboard' from dual union all
		select 'DashboardDelSummaryChild', 'Update Collections Summary Data: Reset Delinquency Records for Collector Dashboard' from dual union all
		select 'DashboardSummaryBatch', 'Update Collections Summary Data' from dual union all
		select 'DeleteTimeCardsJob', 'Delete Time Cards' from dual union all
		select 'DelinquencyScoreConcur', 'Collections Scoring' from dual union all
		select 'DunningDelivery', 'Dunning Delivery' from dual union all
		select 'ELearningPackageIngestionJob', 'Upload SCORM Package' from dual union all
		select 'EssBipJob', 'EssBipJob' from dual union all
		select 'ExecuteMetricsJob', 'Generate Metrics for Supply Chain Management Cloud Services' from dual union all
		select 'ExecuteScriptJob', 'Learn Migration' from dual union all
		select 'ExtractsDataPurgePLSQLJobDefn', 'Processed Flow Statistics' from dual union all
		select 'FAS822', 'Create Mass Additions Report' from dual union all
		select 'FinExmExportERToAPJobDef', 'Process Expense Reimbursements and Cash Advances' from dual union all
		select 'FlowEssJobDefn', 'HCM Flow Secured' from dual union all
		select 'FndOSCSAvailabilityJob', 'ESS process to check Search Cloud Service availability' from dual union all
		select 'GenerateBurdenTransactionsJob', 'Generate Burden Costs' from dual union all
		select 'GenerateBurdenTransactionsReportJob', 'Generate Burden Costs: Generate Report' from dual union all
		select 'GenerateOrdersJobV2', 'Generate Orders' from dual union all
		select 'GenerateRevenueJob', 'Generate Revenue' from dual union all
		select 'GenerateRevenueReportJob', 'Generate Revenue: Generate Report' from dual union all
		select 'GenericBatchJob', 'Transfer HCM Upload Entry Batch' from dual union all
		select 'GenericBatchProcessorJobDefn', 'Transfer HCM Upload Entry Batch' from dual union all
		select 'GlobalGlSlaAcctAnalysis', 'General Ledger and Subledger Account Analysis Report' from dual union all
		select 'HRC_DL_DISPATCH_IMPORT_REQUEST', 'Import Business Object: Subprocess' from dual union all
		select 'HRC_DL_IMPORT_OBJECT', 'Import and Load Business Object: Import Business Object' from dual union all
		select 'HRC_DL_MAIN', 'Import and Load HCM Data File' from dual union all
		select 'HcmAlertRunPurgeJob', 'Purge Alert Processing and Log Entries' from dual union all
		select 'HcmAtomFeedPurgeJob', 'Purge Atom Feed Entries from Oracle Fusion Schema' from dual union all
		select 'IBY_FD_FINAL_PMT_REGISTER', 'Payment File Register' from dual union all
		select 'IBY_FD_PAYMENT_FORMAT', 'Format Payment Files' from dual union all
		select 'IBY_FD_PPR_STATUS_RPT', 'Payment Process Request Status Report' from dual union all
		select 'IBY_FD_SRA_FORMAT', 'Send Separate Remittance Advice' from dual union all
		select 'ImportAndProcessTxnsJob', 'Import Costs' from dual union all
		select 'ImportBudgetsInterfaceData', 'Import Project Budgets' from dual union all
		select 'ImportProcessParallelBipJob', 'Import Costs: Generate Output Report' from dual union all
		select 'ImportProcessParallelEssJob', 'Import Costs' from dual union all
		select 'ImportProjectJobDef', 'Import Projects' from dual union all
		select 'ImportProjectReportJob', 'Import Projects: Generate Output Report' from dual union all
		select 'IncrementalLoadingDashboardMetrics', 'Incremental Load Collections Metrics' from dual union all
		select 'InterfaceLoaderAsyncJob', 'Transfer File' from dual union all
		select 'InterfaceLoaderController', 'Load Interface File for Import' from dual union all
		select 'InterfaceLoaderPurge', 'Purge Interface Tables' from dual union all
		select 'InterfaceLoaderSqlldrImport', 'Load File to Interface' from dual union all
		select 'InvCstInterfaceJob', 'Transfer Transactions from Inventory to Costing' from dual union all
		select 'InvoiceDeletionJob', 'Delete Invoices' from dual union all
		select 'InvoiceDeletionReportJob', 'Delete Invoices: Generate Report' from dual union all
		select 'InvoiceEmailReport', 'Print Receivables Transactions Email Delivery: Invoices' from dual union all
		select 'InvoiceGenerationJob', 'Generate Invoices' from dual union all
		select 'InvoiceGenerationReportJob', 'Generate Invoices: Generate Report' from dual union all
		select 'InvoicePrintReport', 'Print Receivables Transactions: Invoices' from dual union all
		select 'JWorkerJob', 'Payroll Subprocess' from dual union all
		select 'Job_MKT_IMPORT', 'Initiate Data Integrator' from dual union all
		select 'JournalImport', 'Import Journals: Child' from dual union all
		select 'JournalImportLauncher', 'Import Journals' from dual union all
		select 'OpenPeriod', 'Open General Ledger Periods' from dual union all
		select 'Optimizer', 'Optimize Journal Import Performance' from dual union all
		select 'OptimizeLearningItemKeywordsIndexJob', 'Optimize Learning Text Indexes' from dual union all
		select 'OracleSearchCrawler', 'Oracle Secure Enterprise Search Crawler' from dual union all
		select 'OracleSearchIndexOptimizer', 'Oracle Secure Enterprise Search Index Optimizer' from dual union all
		select 'PFConfirmDef', 'Payment File Confirmation' from dual union all
		select 'PICPDef', 'Create Electronic Payment Files' from dual union all
		select 'PPRTerminationDef', 'Terminate Payment Request' from dual union all
		select 'PayOnReceiptJob', 'Send Pay on Receipt' from dual union all
		select 'PersonKeywordSearch', 'Update Person Search Keywords' from dual union all
		select 'PersonSynchronization', 'Synchronize Person Records' from dual union all
		select 'PjsContractSumMainJobDef', 'Update Project Contract Performance Data' from dual union all
		select 'PjsContractSumMainJobDefNonBIP', 'Update Project Contract Performance Data Without Producing Report' from dual union all
		select 'PjsContractSumMainReportJobDef', 'Update Project Contract Performance Data: Generate Report' from dual union all
		select 'PjsProjPlanUpdateJobDefNonBIP', 'Update Project Plan Data Without Producing Report' from dual union all
		select 'PjsSumDataMaintenanceJobDefNonBIP', 'Maintain Project Performance Data Without Producing Report' from dual union all
		select 'PjsSumEssbaseJobDef', 'Maintain Project Performance Data: Maintain Oracle Essbase Cube' from dual union all
		select 'PjsSumHelperJobDef', 'Update Project Performance Data: Helper Subprocess' from dual union all
		select 'PjsSumMainJobDef', 'Update Project Performance Data' from dual union all
		select 'PjsSumMainJobDefNonBIP', 'Update Project Performance Data Without Producing Report' from dual union all
		select 'PjsSumMainReportJobDef', 'Update Project Performance Data: Generate Report' from dual union all
		select 'PjsSumOlapJobDef', 'Maintain Project Performance Data: Maintain Oracle Essbase Queue' from dual union all
		select 'Posting', 'Post Journals' from dual union all
		select 'PostingSingleLedger', 'Post Journals for Single Ledger' from dual union all
		select 'PrepareMassAdditions', 'Prepare Assets Transaction Data' from dual union all
		select 'ProcessAutoProvisionAllUsers', 'Autoprovision Roles for All Users' from dual union all
		select 'ProcessLdapRequests', 'Send Pending LDAP Requests' from dual union all
		select 'ProcessLdapRequestsChild', 'Send Prorated LDAP Requests' from dual union all
		select 'ProcessLockboxesMasterEss', 'Process Receipts Through Lockbox' from dual union all
		select 'PurgeObjectChangeProcess', 'Purge HCM Event Archive Data' from dual union all
		select 'ReAssignReportsJob', 'Run Reassign Pending Approvals for Terminations and Correct Invalid Supervisor Assignments Process' from dual union all
		select 'ReRunJob', 'Retry Payroll Calculation or Costing Process' from dual union all
		select 'RebuildLearnIndexesJob', 'Rebuild Learning Item Indexes' from dual union all
		select 'RecalculateBurdenCostAmountsJob', 'Recalculate Burden Cost' from dual union all
		select 'RecalculateBurdenCostAmountsReportJob', 'Recalculate Burden Cost: Generate Report' from dual union all
		select 'RecalculatePpr', 'Initiate Payment Process Request: Recalculate Payment Process Request' from dual union all
		select 'ReceiptAccountingDistributionProcess', 'Create Receipt Accounting Distributions: Subprocess.' from dual union all
		select 'ReceiptAccountingPreProcessJobDef', 'Import Transactions from Interface for Receipt Accounting.' from dual union all
		select 'ReceiptAccrualProcessMasterEssJobDef', 'Create Receipt Accounting Distributions' from dual union all
		select 'RefreshARTransactionsSummaryTablesEss', 'Refresh Receivables Transactions for Customer Account Summaries' from dual union all
		select 'RefreshForecast', 'Refresh Forecast' from dual union all
		select 'RestLOVStartsWithSwitch', 'Optimize Workforce Structures LOV to Use Starts With' from dual union all
		select 'RetrieveEntitlementsJob', 'User and Role Access Audit Report' from dual union all
		select 'RevenueContingencyAnalyserEss', 'Monitor Revenue Contingencies' from dual union all
		select 'RevenueRecognitionChildEss', 'Recognize Revenue: Parallel Workers' from dual union all
		select 'RevenueRecognitionMasterEss', 'Recognize Revenue' from dual union all
		select 'RevenueRecognitionReportEss', 'Recognize Revenue: Log' from dual union all
		select 'ReverseJournals', 'Reverse Journals' from dual union all
		select 'RollbackJob', 'Roll Back Payroll Process' from dual union all
		select 'SvcBIAuditServiceRequestJob', 'Execute Incremental Load of SR Audit Data for Reporting' from dual union all
		select 'ServiceRequestAggregationIncrementalJob', 'Aggregate Service Requests' from dual union all
		select 'SegmentValueAttributesInheritance', 'Inherit Segment Value Attributes' from dual union all
		select 'StrategyAutomatedProcess', 'Send Dunning Letters' from dual union all
		select 'StrategyCorrespondenceDelivery', 'Dunning Delivery' from dual union all
		select 'SubmitAccountingEss', 'Create Receivables Accounting' from dual union all
		select 'SyncBellNotifications', 'Synchronize Notifications in Global Header' from dual union all
		select 'SvcInteractionCrossChnlAggregationIncrloadJob', 'Execute Incremental Load of Cross-Channel Interaction Data for Reporting' from dual union all
		select 'SyncRolesJob', 'Retrieve Latest LDAP Changes' from dual union all
		select 'TiebackInvoiceJob', 'Confirm Invoice Acceptance Status in Receivables' from dual union all
		select 'TiebackInvoiceReportJob', 'Confirm Invoice Acceptance Status in Receivables: Generate Report' from dual union all
		select 'TransactionPrintDeliveryStatusEss', 'Print Receivables Transactions: Email Delivery' from dual union all
		select 'TransactionPrintProgramEss', 'Print Receivables Transactions' from dual union all
		select 'TransactionPrintUploadReportChildEss', 'Upload Printed Receivables Transactions Child Process' from dual union all
		select 'TransactionPrintUploadReportEss', 'Upload Printed Receivables Transactions' from dual union all
		select 'TrialBalMaintain', 'Maintain Payables Trial Balance Report' from dual union all
		select 'UAClickHistoryAggregationJob', 'User Analytics Click History Data Aggregation PLSQL Procedure Process' from dual union all
		select 'UAClickHistoryMappingScheduler', 'Process Click History Mapping Data' from dual union all
		select 'VideoReadyJob', 'Video Transcoding and Processing' from dual union all
		select 'XLAFSNAPENG', 'Create Accounting: Subprocess' from dual union all
		select 'XLAFSNAPRPT', 'Create Accounting' from dual union all
		select 'XLAFSNAPRPTRPT', 'Create Accounting Execution Report' from dual union all
		select 'XLAGLTRN', 'Post Subledger Journal Entries' from dual union all
		select 'XLAGLTRNW', 'Post Subledger Journal Entries: Subprocess' from dual union all
		select 'XLAJELRPT', 'Journal Entries Report' from dual union all
		select 'XLAOTEC', 'Provide Online Transaction Engine Functionality' from dual union all
		select 'refreshStdBalances', 'Transfer General Ledger Balances to Balances Cubes' from dual union all
		select 'refreshStdBalancesCube', 'Create Balances Cubes: Transfer General Ledger Balances' from dual)
		select rh.requestid
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , '#' || replace(substr(to_char(rh.processend-rh.processstart, 'DD HH24:MI:SS'), 0, instr(to_char(rh.processend-rh.processstart, 'DD HH24:MI:SS'), '.')-1),'+0000000','') duration -- dd_mm_hh_ss
			 -- , rh.definition full_definition
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 -- , replace(rh.definition, 'JobDefinition://', '') def1
			 -- , regexp_substr(replace(rh.definition, 'JobDefinition://', ''), '[^/]+', 1, 1) segment1
			 -- , regexp_substr(replace(rh.definition, 'JobDefinition://', ''), '[^/]+', 1, 2) segment2
			 -- , regexp_substr(replace(rh.definition, 'JobDefinition://', ''), '[^/]+', 1, 3) segment3
			 -- , regexp_substr(replace(rh.definition, 'JobDefinition://', ''), '[^/]+', 1, 4) segment4
			 -- , regexp_substr(replace(rh.definition, 'JobDefinition://', ''), '[^/]+', 1, 5) segment5
			 -- , regexp_substr(replace(rh.definition, 'JobDefinition://', ''), '[^/]+', 1, 6) segment6
			 -- , regexp_substr(replace(rh.definition, 'JobDefinition://', ''), '[^/]+', 1, 7) segment7
			 -- , regexp_substr(replace(rh.definition, 'JobDefinition://', ''), '[^/]+', 1, 8) segment8
			 -- , regexp_substr(replace(rh.definition, 'JobDefinition://', ''), '[^/]+', 1, 9) segment9
			 -- , regexp_substr(replace(rh.definition, 'JobDefinition://', ''), '[^/]+', 1, 10) segment10
			 , rh.product
			 , rh.username
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , flv_meta.name job_name
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS' and flv_state.view_application_id = 0
	 left join tbl_job_lookups flv_meta on flv_meta.meta = substr(rh.definition,(instr(rh.definition,'/',-1)+1))
	 left join per_users fu on rh.username = fu.username
		 where 1 = 1
		   -------------------------- ids --------------------------
		   -- and rh.requestid = 123456
		   -- and rh.requestid between 123456 and 123490
		   -- and rh.requestid in (123456,123457)
		   -------------------------- definition --------------------------
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) not in ('RebuildLearningItemSearchKeywordsJob')
		   -------------------------- users --------------------------
		   -- and fu.username = 'USER123'
		   -- and rh.username not in ('FIN_SCHEDULE','FAAdmin','FUSION_APPS_PRC_SOA_APPID')
		   -- and rh.username in ('APXIIMPT_BIP')
		   -------------------------- misc --------------------------
		   -- and flv_state.meaning = 'Error'
		   -- and rh.executable_status = 'ERROR'
		   -- and rh.error_warning_detail is not null
		   -------------------------- product --------------------------
		   -- and rh.product = 'AP'
		   -- and rh.product like 'PJ%'
		   -- and rh.product in ('FUN','GL')
		   -------------------------- dates and times --------------------------
		   -- and rh.processstart > sysdate - 10
		   -- and rh.completedtime is null
		   -- and rh.scheduled is null
		   -- and to_char(rh.processstart, 'YYYY') = '2023'
		   -- and to_char(rh.processstart, 'MM') = '04'
		   -- and to_char(rh.processstart, 'DD') = '27'
		   -- and to_char(rh.processstart, 'HH24') > 10
		   -- and to_char(rh.processstart, 'HH24') < 15
		   -- and to_char(rh.processstart, 'DD') in ('01','02','03','04','05','06')
		   -- and to_char(rh.processstart, 'HH24') in ('01')
		   -- and round((cast(sys_extract_utc (rh.processend) as date) - cast(sys_extract_utc (rh.processstart) as date)) * 1440,2) > 200
	  order by rh.requestid desc

-- ##############################################################
-- JOB DEFINITION
-- ##############################################################

/*
https://community.oracle.com/customerconnect/discussion/comment/782554#Comment_782554
Error when I try to run the SQL: ORA-01031: insufficient privileges
*/

		select distinct mdp.path_name
			 , mdp.path_fullname
			 , mdp.path_doc_elem_name
			 , c.comp_localname
			 , c.comp_value
		  from fusion_mds.mds_attributes attr
		  join fusion_mds.mds_partitions p on attr.att_partition_id = p.partition_id
		  join fusion_mds.mds_components c on c.comp_seq = attr.att_comp_seq and c.comp_partition_id = attr.att_partition_id and c.comp_contentid = att_contentid
		  join fusion_mds.mds_namespaces ns on ns.ns_partition_id = attr.att_partition_id and ns.ns_id = c.comp_nsid
		  join fusion_mds.mds_paths mdp on c.comp_contentid = mdp.path_contentid
		 where 1 = 1
		   and c.comp_localname = 'display-name'
		   and p.partition_name = 'globalEss'
		   and mdp.path_fullname like '/oracle/apps/ess/financials%'
		   and mdp.path_doc_elem_name <> 'jobset'
		   and mdp.path_name in ('InterfaceLoaderController.xml')

-- ##############################################################
-- BI PUBLISHER JOB HISTORY
-- ##############################################################

/*
BI Publisher (Report Job History)
https://zz.oraclecloud.com/analytics/saw.dll?bipublisherEntry&Action=history

Report Job ID: EXTERNALPROCESSID
Report Job Name: REQUESTID
*/

select * from fusion_ora_ess.request_history_view where requestid = 123
select * from fusion_ora_ess.request_history where requestid = 123
