/*
File Name: sa-bpm-history.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- TABLE DUMPS
-- TASKS INFORMATION 1
-- TASKS INFORMATION 2
-- COUNT BY CREATION DATE, ASSIGNEES AND STATE
-- COUNT BY ASSIGNEES AND STATE
-- COUNT BY COMPONENTNAME (e.g. FinApInvoiceApproval etc)

*/

-- ##############################################################
-- TABLE DUMPS
-- ##############################################################

/*
ORA-01031: Insufficient privileges when run these
*/

select * from fa_fusion_soainfra.wfnotification
select * from hcm_fusion_soainfra.wfuservacation

/*
Tables we can access
https://community.oracle.com/customerconnect/discussion/532954/ability-to-run-queries-on-table-fa-fusion-soainfra-wftaskmetadata
As per Oracle, only the below tables are opened up for clients to use
*/

select * from fa_fusion_soainfra.wftask 
select * from fa_fusion_soainfra.wfassignee 
select * from fa_fusion_soainfra.wfcomments 
select * from fa_fusion_soainfra.wfattachment 
select * from fa_fusion_soainfra.wftaskassignmentstatistic 
select * from fa_fusion_soainfra.wftaskhistory 
select * from fa_fusion_soainfra.wfmessageattribute 
select * from fa_fusion_soainfra.wfapprovalgroups 
select * from fa_fusion_soainfra.wfapprovalgroupmembers 
select * from fa_fusion_soainfra.wfcollectiontarget
select * from fa_fusion_soainfra.wftask_view
select * from fa_fusion_soainfra.wftaskhistory_view
select * from fa_fusion_soainfra.wftasktl_view
select * from fa_fusion_soainfra.wfcomments_view
select * from fa_fusion_soainfra.wfattachment_view
select * from fa_fusion_soainfra.wfassignee_view
select * from fa_fusion_soainfra.wftask fwt where tasknumber = '123456'
select * from fa_fusion_soainfra.wftask fwt where fwt.title = 'Approval of Invoice INV123 from Blue Cheese Corp (123.45 GBP)'

-- ##############################################################
-- TASKS INFORMATION 1
-- ##############################################################

/*
https://www.oracleappsdna.com/2020/06/sql-query-to-fetch-bpm-tasks-information/
*/

select * from fa_fusion_soainfra.wftask fwt where tasknumber in (123456)
select * from fa_fusion_soainfra.wftask fwt where to_char(fwt.createddate, 'yyyy-mm-dd') = '2023-05-27' and componentname = 'FinApHoldApproval'
select * from fa_fusion_soainfra.wftask fwt where title like '%123%' and componentname = 'FinApHoldApproval'

		select distinct fwt.taskdefinitionname
			 , '#' || fwt.taskid taskid
			 , '#' || fwt.identificationkey identificationkey
			 , fwt.tasknumber
			 , to_char(fwt.createddate, 'yyyy-mm-dd hh24:mi:ss') createddate
			 , to_char(fwt.assigneddate, 'yyyy-mm-dd hh24:mi:ss') assigneddate
			 , to_char(fwt.enddate, 'yyyy-mm-dd hh24:mi:ss') enddate
			 , fwt.fromuserdisplayname
			 , fwt.state
			 , fwt.title
			 , fwt.componentname
			 , fwt.packagename
			 , fwt.assignees
			 , fwt.assigneesdisplayname
			 , coalesce(length(fwt.assigneesdisplayname) - length(replace(fwt.assigneesdisplayname,':',null)), length(fwt.assigneesdisplayname), 0) + 1 assignee_count
			 , fwt.outcome
			 -- , (replace(replace(fwc.wfcomment,chr(10),''),chr(13),' ')) wfcomment
			 -- , fwh.processname
			 -- , fwh.approvers
			 -- , fwh.outcome fwh_outcome
			 -- , fwh.state fwh_state
			 -- , fwh.updatedbydisplayname
			 -- , to_char(fwh.assigneddate, 'yyyy-mm-dd hh24:mi:ss') fwh_assigneddate
			 -- , fwh.versionreason
			 -- , fwt.taskdefinitionid
			 -- , fwat.content
			 -- , fwat.name as attachmentname
			 -- , fwat.description
			 -- , fwat.attachmentsize
			 -- , fwm.name
			 -- , fwm.encoding
			 -- , fwm.blobvalue
			 -- , fwm.elementseq
		  from fa_fusion_soainfra.wftask fwt
	 left join fa_fusion_soainfra.wfassignee fwa on fwt.taskid = fwa.taskid
	 -- left join fa_fusion_soainfra.wftaskhistory fwh on fwt.taskid = fwh.taskid
	 -- left join fa_fusion_soainfra.wfcomments fwc on fwa.taskid = fwc.taskid
	 -- left join fa_fusion_soainfra.wfattachment fwat on fwt.taskid = fwat.taskid
	 -- left join fa_fusion_soainfra.wftaskassignmentstatistic fwst on fwat.taskid = fwst.taskid
	 -- left join fa_fusion_soainfra.wfmessageattribute fwm on fwt.taskid = fwm.taskid
	 -- left join fa_fusion_soainfra.wfcollectiontarget x on fwt.taskid = fwtg.taskid
		 where 1 = 1
		   and 1 = 1
	  order by fwt.tasknumber desc

-- ##############################################################
-- TASKS INFORMATION 2
-- ##############################################################

/*
https://cloudcustomerconnect.oracle.com/posts/5613d9d41d
*/

		select bpm_task.approvers
			 , to_char(bpm_task.createddate, 'yyyy-mm-dd hh24:mi:ss') task_created
			 , bpm_task.creator task_created_by
			 , to_char(bpm_task.enddate, 'yyyy-mm-dd hh24:mi:ss') task_end
			 , bpm_hist.acquiredby
			 , bpm_hist.fromuser
			 , bpm_hist.assigneesdisplayname
			 , bpm_hist.fromuserdisplayname
			 , bpm_hist.updatedbydisplayname
			 , bpm_hist.tasknumber
			 , bpm_hist.taskdefinitionname
			 , bpm_hist.title approval_title
			 , bpm_hist.state status
			 , bpm_hist.outcome outcome
		  from fa_fusion_soainfra.wftask_view bpm_task
		  join fa_fusion_soainfra.wftaskhistory bpm_hist on bpm_task.taskid = bpm_hist.taskid
		 where 1 = 1
		   and 1 = 1
	  order by bpm_task.createddate desc

-- ##############################################################
-- COUNT BY CREATION DATE, ASSIGNEES AND STATE
-- ##############################################################

		select to_char(fwt.createddate, 'yyyy-mm-dd') createddate
			 , fwt.assignees
			 , fwt.state
			 , count(*)
		  from fa_fusion_soainfra.wftask fwt
		 where 1 = 1
		   and 1 = 1
	  group by to_char(fwt.createddate, 'yyyy-mm-dd')
			 , fwt.assignees
			 , fwt.state
	  order by 1 desc

-- ##############################################################
-- COUNT BY ASSIGNEES AND STATE
-- ##############################################################

		select fwt.assignees
			 , fwt.state
			 , min(fwt.tasknumber)
			 , max(fwt.tasknumber)
			 , count(*)
		  from fa_fusion_soainfra.wftask fwt
		 where 1 = 1
		   and 1 = 1
	  group by fwt.assignees
			 , fwt.state

-- ##############################################################
-- COUNT BY COMPONENTNAME (e.g. FinApInvoiceApproval etc)
-- ##############################################################

		select fwt.componentname
			 , fwt.packagename
			 , fwt.activityid
			 , min(to_char(fwt.createddate, 'yyyy-mm-dd hh24:mi:ss')) min_created
			 , max(to_char(fwt.createddate, 'yyyy-mm-dd hh24:mi:ss')) max_created
			 , min(fwt.tasknumber)
			 , max(fwt.tasknumber)
			 , count(*)
		  from fa_fusion_soainfra.wftask fwt
		 where 1 = 1
		   and 1 = 1
  group by fwt.componentname
		 , fwt.packagename
		 , fwt.activityid
