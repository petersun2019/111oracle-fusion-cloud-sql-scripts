/*
File Name: sa-requests-properties-single-param-values.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

The REQUEST_PROPERTY table can be used to access parameter values used when submitting a request

Queries:

-- BASIC
-- XLAGLTRN - Post Subledger Journal Entries
-- CreateAccounting - Create Accounting for Projects
-- XLAFSNAPRPT - Create Accounting
-- XLAFSNAPRPTRPT - Create Accounting Execution Report 1
-- XLAFSNAPRPTRPT - Create Accounting Execution Report 2
-- JournalImportLauncher - Import Journals - Source
-- InterfaceLoaderController - Load Interface File For Import - file name
-- IBY_FD_SRA_FORMAT - Send Separate Remittance Advice
-- APXPRIMPT - Import Payables Payment Requests
-- LoadSegValAndHierData - Import Segment Values and Hierarchies
-- FlowEssJobDefn - HCM Flow Secured
-- APXIIMPT - Import Payables Invoices
-- APXAPRVL - Validate Payables Invoices
-- StrategyAutomatedProcess - Send Dunning Letters
-- GenerateBurdenTransactionsJob - Generate Burden Costs
-- ImportAndProcessTxnsJob - Import Costs
-- AccountingPeriodClose - Close Accounting Period
-- AccountingPeriodOpen - Open Accounting Period
-- AccountingPeriodOpenReportJob - Open Accounting Period: Generate Report
-- AccountingPeriodCloseReportJob - Close Accounting Period: Generate Report
-- TransactionPrintProgramEss - Print Receivables Transactions
-- APCSTTRF - Transfer Costs to Cost Management
-- ReceiptAccrualProcessMasterEssJobDef - Create Receipt Accounting Distributions
-- TaxBoxReturnPreparation - Tax Box Return Preparation Report

*/

-- ##############################################################
-- BASIC
-- ##############################################################

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , rh.state state_
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , rp.name
			 , rp.value value_
			 -- , '#########################'
			 -- , rhv.name rhv_name
			 -- , rhv.requesttype
			 -- , rhv.lastscheduleinstanceid
			 -- , rhv.submitter_dms_rid
			 -- , rhv.dms_rid
			 -- , rhv.waittime
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		  join fusion_ora_ess.request_history_view rhv on rhv.requestid = rh.requestid
		 where 1 = 1
		   -- and rh.requestid in (123456)
		   -- and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('LoadSegValAndHierData')
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- XLAGLTRN - Post Subledger Journal Entries
-- ##############################################################

/*
submit.argument3: ApplicationID
submit.argument5: EndDate
submit.argument17: ParentID - ID of parent Create Accounting job
*/

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , rp.name
			 , rp.value value_
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , rhv.lastscheduleinstanceid
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		  join fusion_ora_ess.request_history_view rhv on rhv.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('XLAGLTRN')
		   -- and rp.name in ('display.attribute6.value')
		   and rp.name in ('submit.argument5','submit.argument3','submit.argument17')
		   and flv_state.meaning = 'Succeeded'
		   -- and rh.processstart > sysdate - 1 -- last day
		   and 1 = 1
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle

submit.argument3: ApplicationID
submit.argument5: EndDate
submit.argument17: ParentID - ID of parent Create Accounting job
*/

	with my_data as (
			select rh.requestid id
				 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
				 , rh.instanceparentid -- the parent process in that instance run
				 , flv_state.meaning status
				 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
				 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
				 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
				 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
				 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
				 , rh.product
				 , rh.username
				 , rp.name
				 , rp.value value_
				 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
				 , rhv.lastscheduleinstanceid
			  from request_history rh
			  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
			  join request_property rp on rp.requestid = rh.requestid
			  join fusion_ora_ess.request_history_view rhv on rhv.requestid = rh.requestid
			 where 1 = 1
			   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('XLAGLTRN')
			   -- and rp.name in ('display.attribute6.value')
			   and rp.name in ('submit.argument3','submit.argument5','submit.argument17')
			   and flv_state.meaning = 'Succeeded'
			   -- and rh.processstart > sysdate - 1 -- last day
			   -- and rh.requestid in (123456)
			   and 1 = 1)
	select * from (
			select id
				 , absparentid
				 , instanceparentid
				 , status
				 , process_start
				 , process_end
				 , username
				 , definition
				 , product
				 , name
				 , value_
				 , error_warning_message
			  from my_data)
	pivot
	(
	   max(value_)
	   for name in ('submit.argument3' application_id
				   ,'submit.argument5' end_date
				   ,'submit.argument17' parent_id)
	)
		  order by id desc

-- ##############################################################
-- CreateAccounting - Create Accounting for Projects
-- ##############################################################

/*
display.attribute6.value: End Date
display.attribute8.value: Mode
display.attribute10.value: Report Style
display.attribute11.value: TransfertoGeneralLedger
display.attribute12.value: PostinGeneralLedger
display.attribute26.value: Ledger
display.attribute27.value: BU
*/

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , rp.name
			 , rp.value value_
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , regexp_replace(substr(rh.error_warning_message, instr(rh.error_warning_message, 'process identifier '), 200), '[^0-9]', '') error_report_id
			 , rhv.lastscheduleinstanceid
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		  join fusion_ora_ess.request_history_view rhv on rhv.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('CreateAccounting')
		   -- and rp.name in ('display.attribute6.value')
		   and rp.name in ('display.attribute6.value','display.attribute8.value','display.attribute10.value','display.attribute11.value','display.attribute12.value','display.attribute26.value','display.attribute27.value')
		   and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute8.value' and rp2.value = 'Final') -- final mode
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle

display.attribute6.value: End Date
display.attribute8.value: Mode
display.attribute10.value: Report Style
display.attribute11.value: TransfertoGeneralLedger
display.attribute12.value: PostinGeneralLedger
display.attribute26.value: Ledger
display.attribute27.value: BU
*/

with my_data as (
		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , rp.name
			 , rp.value value_
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , regexp_replace(substr(rh.error_warning_message, instr(rh.error_warning_message, 'process identifier '), 200), '[^0-9]', '') error_report_id
			 , rhv.lastscheduleinstanceid
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		  join fusion_ora_ess.request_history_view rhv on rhv.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('CreateAccounting')
		   -- and rp.name in ('display.attribute6.value')
		   and rp.name in ('display.attribute6.value','display.attribute8.value','display.attribute10.value','display.attribute11.value','display.attribute12.value','display.attribute26.value','display.attribute27.value')
		   and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute8.value' and rp2.value = 'Final') -- final mode
		   and 1 = 1)
select * from (
		select id
			 , absparentid
			 , instanceparentid
			 , status
			 , process_start
			 , process_end
			 , username
			 , definition
			 , product
			 , name
			 , value_
			 , error_report_id
			 , error_warning_message
			 , lastscheduleinstanceid
		  from my_data)
pivot
(
   max(value_)
   for name in ('display.attribute6.value' end_date
			  , 'display.attribute8.value' mode_
			  , 'display.attribute10.value' report_style
			  , 'display.attribute11.value' transfertogeneralledger
			  , 'display.attribute12.value' postingeneralledger
			  , 'display.attribute26.value' ledger
			  , 'display.attribute27.value' bu)
)
order by id desc

-- ##############################################################
-- XLAFSNAPRPT - Create Accounting
-- ##############################################################

/*
display.attribute6.value: End Date
display.attribute8.value: Mode
display.attribute26.value: Application
display.attribute27.value: Ledger
*/

			select rh.requestid id
				 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
				 , rh.instanceparentid -- the parent process in that instance run
				 , flv_state.meaning status
				 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
				 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
				 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
				 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
				 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
				 , rh.product
				 , rh.username
				 , rp.name
				 , rp.value value_
				 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
				 , regexp_replace(substr(rh.error_warning_message, instr(rh.error_warning_message, 'process identifier '), 200), '[^0-9]', '') error_report_id
				 , rhv.lastscheduleinstanceid
			  from request_history rh
			  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
			  join request_property rp on rp.requestid = rh.requestid
			  join fusion_ora_ess.request_history_view rhv on rhv.requestid = rh.requestid
			 where 1 = 1
			   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('XLAFSNAPRPT')
			   and rp.name in ('display.attribute6.value','display.attribute8.value','display.attribute27.value','display.attribute26.value')
			   -- and rp.name in ('display.attribute26.value') and rp.value = 'Payroll'
			   and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute8.value' and rp2.value = 'F') -- final
			   and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute26.value' and rp2.value = 'Project Costing')
			   -- and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute27.value' and rp2.value = 'XX Ledger')
			   -- and rh.requestid in (123456)
			   -- and rh.username = 'USER123'
			   -- and to_char(rh.processstart, 'YYYY') = '2023'
			   -- and to_char(rh.processstart, 'MM') = '10'
			   and rh.processend is not null
		  order by rh.requestid desc
				 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , rp.name
			 , rp.value value_
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , regexp_replace(substr(rh.error_warning_message, instr(rh.error_warning_message, 'process identifier '), 200), '[^0-9]', '') error_report_id
			 , rhv.lastscheduleinstanceid
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		  join fusion_ora_ess.request_history_view rhv on rhv.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('XLAFSNAPRPT')
		   and rp.name in ('display.attribute6.value','display.attribute8.value','display.attribute27.value','display.attribute26.value')
		   -- and rp.name in ('display.attribute26.value') and rp.value = 'Payroll'
		   and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute8.value' and rp2.value = 'F') -- final
		   and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute26.value' and rp2.value = 'Project Costing')
		   -- and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute27.value' and rp2.value = 'XX Ledger')
		   -- and rh.requestid in (123456)
		   -- and rh.username = 'USER123'
		   and to_char(rh.processstart, 'YYYY') = '2023'
		   and to_char(rh.processstart, 'MM') >= '11'
		   and rh.processend is not null
		   and flv_state.meaning = 'Warning'
		   and 1 = 1)
select * from (
		select id
			 , absparentid
			 , instanceparentid
			 , status
			 , process_start
			 , process_end
			 , username
			 , definition
			 , product
			 , name
			 , value_
			 , error_report_id
			 , error_warning_message
			 , lastscheduleinstanceid
		  from my_data)
pivot
(
   max(value_)
   for name in ('display.attribute26.value' application
			   ,'display.attribute27.value' ledger
			   ,'display.attribute6.value' end_date
			   ,'display.attribute8.value' mode_)
)
order by id desc

-- ##############################################################
-- XLAFSNAPRPT - Create Accounting + XLAFSNAPRPTRPT - Create Accounting Execution Report
-- ##############################################################

/*
display.attribute6.value: End Date
display.attribute8.value: Mode
display.attribute26.value: Application
display.attribute27.value: Ledger
*/

			select rh.requestid id
				 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
				 , rh.instanceparentid -- the parent process in that instance run
				 -- , tbl_execution_report.execution_report_id
				 , flv_state.meaning status
				 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
				 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
				 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
				 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
				 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
				 , rh.product
				 , rh.username
				 , rp.name
				 , rp.value value_
				 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
				 , regexp_replace(substr(rh.error_warning_message, instr(rh.error_warning_message, 'process identifier '), 200), '[^0-9]', '') error_report_id
				 , rhv.lastscheduleinstanceid
			  from request_history rh
			  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
			  join request_property rp on rp.requestid = rh.requestid
			  join fusion_ora_ess.request_history_view rhv on rhv.requestid = rh.requestid
		 left join (select rh.requestid execution_report_id
						 , rp.value create_accounting_job_id
					  from request_history rh
					  join request_property rp on to_number(rp.requestid) = to_number(rh.requestid)
					 where substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('XLAFSNAPRPTRPT')
					   and rp.name in ('submit.argument1')) tbl_execution_report on to_number(tbl_execution_report.create_accounting_job_id) = rh.requestid
			 where 1 = 1
			   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('XLAFSNAPRPT')
			   and rp.name in ('display.attribute6.value','display.attribute8.value','display.attribute27.value','display.attribute26.value')
			   -- and rp.name in ('display.attribute26.value') and rp.value = 'Payroll'
			   and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute8.value' and rp2.value = 'F') -- final
			   and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute26.value' and rp2.value = 'Project Costing')
			   -- and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute27.value' and rp2.value = 'XX Ledger')
			   -- and rh.requestid in (123456)
			   -- and rh.username = 'USER123'
			   -- and to_char(rh.processstart, 'YYYY') = '2023'
			   -- and to_char(rh.processstart, 'MM') = '10'
			   and flv_state.meaning = 'Warning'
			   and rh.processend is not null -- job has completed
		  order by rh.requestid desc
				 , rp.name


					select rh.requestid execution_report_id
						 , rp.value create_accounting_job_id
						 , to_number(rp.value) d1
					  from request_history rh
					  join request_property rp on to_number(rp.requestid) = to_number(rh.requestid)
					 where substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('XLAFSNAPRPTRPT')
					   and rp.name in ('submit.argument1')
					   and rh.requestid = 1784173

-- ##############################################################
-- XLAFSNAPRPTRPT - Create Accounting Execution Report 1
-- ##############################################################

/*
This is useful to help find the Request ID of the Create Accounting Execution Report for any given Create Accounting job.
If you have a huge number of Create Accounting jobs, all submitted by the same user at the same time but for different ledgers and applications, it can be hard to know which Execution Report is for which Create Accounting job.
This SQL can be used to find the Execution Report that was generated for the Request ID of a Create Accounting Job.
*/

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , rp.name
			 , rp.value value_
			 -- , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , rhv.lastscheduleinstanceid
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		  join fusion_ora_ess.request_history_view rhv on rhv.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('XLAFSNAPRPTRPT')
		   and rp.name in ('submit.argument1')
		   -- and rp.value = '3505105' -- request ID of parent Create Accounting Job
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- XLAFSNAPRPTRPT - Create Accounting Execution Report 2
-- ##############################################################

/*
This is useful to help find the Request ID of the Create Accounting Execution Report for any given Create Accounting job.
If you have a huge number of Create Accounting jobs, all submitted by the same user at the same time but for different ledgers and applications, it can be hard to know which Execution Report is for which Create Accounting job.
This SQL can be used to find the Execution Report that was generated for the Request ID of a Create Accounting Job.
This query returns the parent ID for the Execution Report along with the module the parent Create Accounting job ran against
*/

		select rh.requestid id_of_execution_report
			 , rp.value id_of_create_accounting_job
			 , tbl_parent.module_name application
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , rh.username
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		  join fusion_ora_ess.request_history_view rhv on rhv.requestid = rh.requestid
		  join (select rh.requestid
					 , rp.value module_name
				  from request_history rh
				  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
				  join request_property rp on rp.requestid = rh.requestid
				 where 1 = 1
				  and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('XLAFSNAPRPT')
				  and rp.name in ('display.attribute26.value')
				  and flv_state.meaning = 'Warning'
				  and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute8.value' and rp2.value = 'F') -- final
				  and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute26.value' and rp2.value = 'Payables')
				  -- and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute27.value' and rp2.value = 'XX Ledger')
				  and to_char(rh.processstart, 'YYYY') = '2023'
				  and to_char(rh.processstart, 'MM') = '11'
				  -- and to_char(rh.processstart, 'DD') = '11'
				  and 1 = 1) tbl_parent on '#' || tbl_parent.requestid = '#' || rp.value
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('XLAFSNAPRPTRPT')
		   and rp.name in ('submit.argument1')
		   -- and rh.requestid in (123456)
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- JournalImportLauncher - Import Journals - Source
-- ##############################################################

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , rp.name
			 , rp.value value_
			 , gjst.user_je_source_name
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		  join gl_je_sources_tl gjst on rp.value = gjst.je_source_name
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('JournalImportLauncher')
		   and rp.name = 'submit.argument2'
		   and rh.username = 'USER123'
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- InterfaceLoaderController - Load Interface File For Import - file name
-- ##############################################################

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , rp.name
			 , rp.value value_
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('InterfaceLoaderController')
		   and rp.name = 'submit.argument6.attributeValue'
		   and rh.username = 'USER123'
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- IBY_FD_SRA_FORMAT - Send Separate Remittance Advice
-- ##############################################################

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , rp.name
			 , rp.value value_
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('IBY_FD_SRA_FORMAT')
		   and rp.name = 'submit.argument1'
		   and rh.username = 'USER123'
		   -- and rp.value = 123
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- APXPRIMPT - Import Payables Payment Requests
-- ##############################################################

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , rp.name
			 , rp.value value_
			 , case when rp.name = 'submit.argument1' then (select bu_name from fun_all_business_units_v bu where bu.bu_id = rp.value) end business_unit
			 , case when rp.name = 'submit.argument8' then (select name from gl_ledgers gl where gl.ledger_id = rp.value) end ledger
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('APXPRIMPT')
		   and rp.name in ('submit.argument8','submit.argument1')
		   and rp.name in ('submit.argument8') -- ledger
		   and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'submit.argument4' and rp2.value = 'XX_SOURCE')
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- LoadSegValAndHierData - Import Segment Values and Hierarchies
-- ##############################################################

/*
Returns the Chart of Accounts Segment the job ran against (e.g. XX_GL_COST_CENTRE, XX_GL_PROJECT)
*/

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , rh.state
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , rp.name
			 , rp.value value_
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('LoadSegValAndHierData')
		   and rp.name = 'display.attribute2.value'
		   and flv_state.meaning = 'Error'
		   -- and rp.value = 'XX_FIN_GL_COST_CENTRE'
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- FlowEssJobDefn - HCM Flow Secured
-- ##############################################################

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , rp.name
			 , rp.value value_
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('FlowEssJobDefn')
		   and rp.name in ('FlowParam_flowInstanceName','FlowParam_pay.start_date')
		   and rp.value not like 'QuickPay%'
		   -- and flv_state.meaning = 'Error'
		   -- and rp.value = 'XX_GL_COST_CENTRE'
		   -- and rh.completedtime is not null
		   and to_char(rh.processstart, 'YYYY') = '2022'
		   and to_char(rh.processstart, 'MM') in ('09','10','11')
		   -- and to_char(rh.processstart, 'DD') = '13'
		   -- and to_char(rh.processstart, 'HH24') = '13'
		   -- and to_char(rh.processstart, 'DD') in ('01','02','03','04','05','06')
		   -- and to_char(rh.processstart, 'HH24') in ('01')
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- APXIIMPT - Import Payables Invoices
-- ##############################################################

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , rp.name
			 , rp.value value_
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('APXIIMPT')
		   -- and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'submit.argument8' and rp2.value = 'IMAGE')
		   -- and rp.value is not null
		   and rp.name in ('submit.argument8')
		   and rp.value = 'PAMS'
		   and to_char(rh.processend, 'yyyy-mm-dd') = '2023-06-02'
		   -- and rh.requestid in (123456)
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- APXAPRVL - Validate Payables Invoices
-- ##############################################################

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , rp.name
			 , rp.value value_
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('APXAPRVL')
		   and rp.name in ('submit.argument16.attributeValue') -- #XCC Ledger
		   -- and rh.requestid in (123456)
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- StrategyAutomatedProcess - Send Dunning Letters
-- ##############################################################

/*
submit.argument11: RestartRequestID
submit.argument12: not known but seems to be a request ID
submit.argument13: e.g. #First Reminder
submit.argument14: Draft or Final (B = Final?)
submit.argument9: Business Unit ID
*/

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , rp.name
			 , rp.value value_
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('StrategyAutomatedProcess')
		   and rp.name in ('submit.argument11','submit.argument12','submit.argument13','submit.argument14','submit.argument9') -- #XCC Ledger
		   -- and rh.requestid in (123456)
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- GenerateBurdenTransactionsJob - Generate Burden Costs
-- ##############################################################

/*
parentRequest
display.attribute1.value: Business Unit
display.attribute5.value: Expenditure Item Through Date
*/

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , rp.name
			 , rp.value value_
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('GenerateBurdenTransactionsJob')
		   and rp.name in ('parentRequest','display.attribute1.value','display.attribute5.value')
		   -- and rh.requestid in (123456)
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- ImportAndProcessTxnsJob - Import Costs
-- ##############################################################

/*
submit.argument2 - Business Unit ID
submit.argument4 - Batch Name
submit.argument6 - Transaction Source ID
*/

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , rp.name
			 , rp.value value_
			 , case when rp.name = 'submit.argument6' then (select user_transaction_source from pjf_txn_sources_tl ptst where ptst.transaction_source_id = rp.value and ptst.language = userenv('lang')) end trx_source
			 , case when rp.name = 'submit.argument2' then (select bu_name from fun_all_business_units_v fabuv where fabuv.bu_id = rp.value) end business_unit
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('ImportAndProcessTxnsJob')
		   and rp.name in ('submit.argument2','submit.argument4','submit.argument6')
		   -- and rh.requestid in (123456)
		   -- and rh.username = 'USER123'
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- AccountingPeriodClose - Close Accounting Period
-- ##############################################################

/*
submit.argument8: ONLINE
submit.argument9: GL_CLOSE_PEND
submit.argument5: Mar-23
submit.argument2: Ledger
*/

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , rp.name
			 , rp.value value_
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('AccountingPeriodClose')
		   and rp.name in ('submit.argument5')
		   -- and rh.requestid in (123456)
		   -- and rh.username = 'USER123'
		   and rh.requestid in (select rp.requestid id from request_property rp where substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('AccountingPeriodClose') and rp.name in ('submit.argument5') and rp.value = 'Mar-23')
		   and rh.requestid in (select rp.requestid id from request_property rp where substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('AccountingPeriodClose') and rp.name in ('submit.argument2') and rp.value = 'XCC Ledger')
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- AccountingPeriodOpen - Open Accounting Period
-- ##############################################################

/*
submit.argument1: LEDGER_ID
submit.argument2: LEDGER_ID
submit.argument3: Mar-23
submit.argument4: GL_OPEN
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 -- , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , rp.name
			 , rp.value value_
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('AccountingPeriodOpen')
		   and rp.name in ('submit.argument4')
		   -- and rh.requestid in (123456)
		   -- and rh.username = 'USER123'
		   and rh.requestid in (select rp.requestid id from request_property rp where substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('AccountingPeriodOpen') and rp.name in ('submit.argument3') and rp.value = 'Mar-23')
		   -- and rh.requestid in (select rp.requestid id from request_property rp where substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('AccountingPeriodClose') and rp.name in ('submit.argument2') and rp.value = 'XX Ledger')
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- AccountingPeriodOpenReportJob - Open Accounting Period: Generate Report
-- AccountingPeriodCloseReportJob - Close Accounting Period: Generate Report
-- ##############################################################

/*
Find ID of Projects Period Close / Open Reporting Jobs

submit.argument1: 4508931 -- ID of the parent job
*/

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , rp.name
			 , rp.value value_
			 -- , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , rhv.lastscheduleinstanceid
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		  join fusion_ora_ess.request_history_view rhv on rhv.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('AccountingPeriodOpenReportJob','AccountingPeriodCloseReportJob')
		   and rp.name in ('submit.argument1')
		   and rp.value in ('123456') -- request ID of parent Create Accounting Job
			 , rp.name

-- ##############################################################
-- TransactionPrintProgramEss - Print Receivables Transactions
-- ##############################################################

/*
display.attribute1.value: XX BU
display.attribute27.value: Default Invoice Template
*/

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , rp.name
			 , rp.value value_
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('TransactionPrintProgramEss')
		   and rp.name in ('display.attribute1.value','display.attribute27.value')
		   -- and rh.requestid in (123456)
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- APCSTTRF - Transfer Costs to Cost Management
-- ##############################################################

/*
display.attribute2.value: XX BU
display.attribute3.value: 2023-03-31
*/

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , rp.name
			 , rp.value value_
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('APCSTTRF')
		   and rp.name in ('display.attribute2.value','display.attribute3.value')
		   -- and rh.requestid in (123456)
		   -- and rh.username = 'USER123'
		   -- and to_char(rh.processstart, 'YYYY') = '2023'
		   -- and to_char(rh.processstart, 'MM') = '01'
		   and rh.processend is not null
	  order by rh.requestid desc
			 , rp.name

/*
pivot version
*/

with my_data as (
		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , rp.name
			 , rp.value value_
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('APCSTTRF')
		   and rp.name in ('display.attribute2.value','display.attribute3.value')
		   -- and rh.requestid in (123456)
		   -- and rh.username = 'USER123'
		   -- and to_char(rh.processstart, 'YYYY') = '2023'
		   -- and to_char(rh.processstart, 'MM') = '01'
		   and rh.processend is not null
		   and 1 = 1)
select * from (
		select id
			 , absparentid
			 , instanceparentid
			 , status
			 , process_start
			 , process_end
			 , username
			 , definition
			 , product
			 , name
			 , value_
			 , error_warning_message
		  from my_data)
pivot 
(
   max(value_)
   for name in ('display.attribute2.value' business_unit
			   ,'display.attribute3.value' end_date)
)
order by id desc

-- ##############################################################
-- ReceiptAccrualProcessMasterEssJobDef - Create Receipt Accounting Distributions
-- ##############################################################

/*
submit.argument1: BU
*/

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , rp.name
			 , rp.value value_
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('ReceiptAccrualProcessMasterEssJobDef')
		   and rp.name in ('submit.argument1')
		   -- and rh.requestid in (123456)
		   -- and rh.username = 'USER123'
		   -- and to_char(rh.processstart, 'YYYY') = '2023'
		   -- and to_char(rh.processstart, 'MM') = '01'
		   and rh.processend is not null
	  order by rh.requestid desc
			 , rp.name

/*
pivot
*/

with my_data as (
		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , rp.name
			 , rp.value value_
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('ReceiptAccrualProcessMasterEssJobDef')
		   and rp.name in ('submit.argument1')
		   -- and rh.requestid in (123456)
		   and rh.username like '%@%'
		   -- and to_char(rh.processstart, 'YYYY') = '2023'
		   -- and to_char(rh.processstart, 'MM') = '01'
		   and rh.processend is not null
		   and 1 = 1)
select * from (
		select id
			 , absparentid
			 , instanceparentid
			 , status
			 , process_start
			 , process_end
			 , username
			 , definition
			 , product
			 , name
			 , value_
			 , error_warning_message
		  from my_data)
pivot 
(
   max(value_)
   for name in ('submit.argument1' bu)
)
order by id desc

-- ##############################################################
-- TaxBoxReturnPreparation - Tax Box Return Preparation Report
-- ##############################################################

/*
submit.argument1: Reporting Identifier ID (links to jg_zz_vat_rep_entities.VAT_REPORTING_ENTITY_ID to get ENTITY_IDENTIFIER)
submit.argument2: Source (e.g. Input tax (P2P), Output tax (O2C), ALL)
submit.argument3: Tax Calendar Period
*/

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , rp.name
			 , rp.value value_
			 , case when rp.name = 'submit.argument1' then (select entity_identifier from jg_zz_vat_rep_entities where vat_reporting_entity_id = rp.value) end reporting_identifier
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('TaxBoxReturnPreparation')
		   and rp.name in ('submit.argument1','submit.argument3','submit.argument10')
		   -- and rh.requestid in (123456)
		   -- and rh.username = 'USER123'
		   -- and to_char(rh.processstart, 'YYYY') = '2023'
		   -- and to_char(rh.processstart, 'MM') = '01'
		   and rh.processend is not null
	  order by rh.requestid desc
			 , rp.name

/*
pivot
*/

with all_data as (
with my_data as (
		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , rp.name
			 , rp.value value_
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('TaxBoxReturnPreparation')
		   and rp.name in ('submit.argument1','submit.argument2','submit.argument3')
		   -- and rh.requestid in (123456)
		   -- and rh.username = 'USER123'
		   -- and to_char(rh.processstart, 'YYYY') = '2023'
		   -- and to_char(rh.processstart, 'MM') = '01'
		   and rh.processend is not null
		   and 1 = 1)
select * from (
		select id
			 , absparentid
			 , instanceparentid
			 , status
			 , process_start
			 , process_end
			 , username
			 , definition
			 , product
			 , name
			 , value_
			 , error_warning_message
		  from my_data)
pivot 
(
   max(value_)
   for name in ('submit.argument1' reporting_identifier
			  , 'submit.argument2' reporting_source
			  , 'submit.argument3' tax_period)
))
		select all_data.id
			 , all_data.absparentid
			 , all_data.instanceparentid
			 , all_data.status
			 , all_data.process_start
			 , all_data.process_end
			 , all_data.username
			 , all_data.definition
			 , all_data.product
			 , all_data.error_warning_message
			 , all_data.reporting_identifier
			 , all_data.reporting_source
			 , all_data.tax_period
	  order by all_data.id desc
