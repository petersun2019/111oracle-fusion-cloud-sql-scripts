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
-- XLAFSNAPRPTRPT - Create Accounting Execution Report
-- APCSTTRF - Transfer Costs to Cost Management
-- ReceiptAccrualProcessMasterEssJobDef - Create Receipt Accounting Distributions
-- TaxBoxAllocationProcess - Tax Allocation Process
-- EmeaVatSelectionProcess - Select Transactions for Tax Reporting
-- TaxBoxAllocationListing - Tax Allocations Listing Report
-- TaxBoxReturnPreparation - Tax Box Return Preparation Report
-- EmeaVatFinalReportingProcess - Finalize Transactions for Tax Reporting
-- InterfaceLoaderController - Load Interface File for Import
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
-- TransactionPrintProgramEss - Print Receivables Transactions
-- AccountingPeriodOpenReportJob - Open Accounting Period: Generate Report
-- AccountingPeriodCloseReportJob - Close Accounting Period: Generate Report
-- JournalImportLauncher - Import Journals - Source

*/

-- ##############################################################
-- BASIC
-- ##############################################################

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , rh.state state_
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and rh.requestid in (123456)
		   -- and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('LoadSegValAndHierData')
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- XLAGLTRN - Post Subledger Journal Entries
-- ##############################################################

/*
completionText: Completion text
submit.argument3: ApplicationID
submit.argument5: EndDate
submit.argument17: ParentID - ID of parent Create Accounting job
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('XLAGLTRN')
		   and rp.name in ('completionText','submit.argument3','submit.argument5','submit.argument17')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('XLAGLTRN')
		   and rp.name in ('completionText','submit.argument3','submit.argument5','submit.argument17')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'submit.argument3' application_id
			  , 'submit.argument5' end_date
			  , 'submit.argument17' parent_id)
)
order by id desc

-- ##############################################################
-- CreateAccounting - Create Accounting for Projects
-- ##############################################################

/*
completionText: Completion text
display.attribute6.value: End Date
display.attribute8.value: Mode
display.attribute10.value: Report Style
display.attribute11.value: TransfertoGeneralLedger
display.attribute12.value: PostinGeneralLedger
display.attribute26.value: Ledger
display.attribute27.value: BU
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , rp.name
			 , rp.value value_
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , regexp_replace(substr(rh.error_warning_message, instr(rh.error_warning_message, 'process identifier '), 200), '[^0-9]', '') error_report_id
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('CreateAccounting')
		   and rp.name in ('completionText','display.attribute6.value','display.attribute8.value','display.attribute10.value','display.attribute11.value','display.attribute12.value','display.attribute26.value','display.attribute27.value')
		   and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute8.value' and rp2.value = 'Final') -- final mode
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , rp.name
			 , rp.value value_
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , regexp_replace(substr(rh.error_warning_message, instr(rh.error_warning_message, 'process identifier '), 200), '[^0-9]', '') error_report_id
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('CreateAccounting')
		   and rp.name in ('completionText','display.attribute6.value','display.attribute8.value','display.attribute10.value','display.attribute11.value','display.attribute12.value','display.attribute26.value','display.attribute27.value')
		   and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute8.value' and rp2.value = 'Final') -- final mode
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
		  from my_data)
pivot
(
   max(value_)
   for name in ('completionText' completion_text
			  , 'display.attribute6.value' end_date
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
completionText: Completion text
display.attribute6.value: End Date
display.attribute8.value: Mode
display.attribute26.value: Application
display.attribute27.value: Ledger
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
		 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
		 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
		 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
		 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , rp.name
			 , rp.value value_
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , regexp_replace(substr(rh.error_warning_message, instr(rh.error_warning_message, 'process identifier '), 200), '[^0-9]', '') error_report_id
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('XLAFSNAPRPT')
		   and rp.name in ('completionText','display.attribute6.value','display.attribute8.value','display.attribute26.value','display.attribute27.value')
		   -- and rp.name in ('display.attribute26.value') and rp.value = 'Payroll'
		   and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute8.value' and rp2.value = 'F') -- final
		   and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute26.value' and rp2.value = 'Project Costing')
		   -- and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute27.value' and rp2.value = 'XX Ledger')
		   and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
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
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('XLAFSNAPRPT')
		   and rp.name in ('completionText','display.attribute6.value','display.attribute8.value','display.attribute26.value','display.attribute27.value')
		   -- and rp.name in ('display.attribute26.value') and rp.value = 'Payroll'
		   and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute8.value' and rp2.value = 'F') -- final
		   and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute26.value' and rp2.value = 'Project Costing')
		   -- and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'display.attribute27.value' and rp2.value = 'XX Ledger')
		   and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
		  from my_data)
pivot
(
   max(value_)
   for name in ('completionText' completion_text
			  , 'display.attribute26.value' application
			   ,'display.attribute27.value' ledger
			   ,'display.attribute6.value' end_date
			   ,'display.attribute8.value' mode_)
)
order by id desc

-- ##############################################################
-- XLAFSNAPRPTRPT - Create Accounting Execution Report
-- ##############################################################

/*
This is useful to help find the Request ID of the Create Accounting Execution Report for any given Create Accounting job.
If you have a huge number of Create Accounting jobs, all submitted by the same user at the same time but for different ledgers and applications, it can be hard to know which Execution Report is for which Create Accounting job.
This SQL can be used to find the Execution Report that was generated for the Request ID of a Create Accounting Job.

Therefore on this line:
and rp.value = '123456' -- request ID of parent Create Accounting Job
Replace 123456 with the Create Accounting Request ID.

The ID value returned by the SQL will be the Request ID of the Create Accounting Execution Report
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('XLAFSNAPRPTRPT')
		   and rp.name in ('completionText','submit.argument1')
		   and rp.value = '123456' -- request ID of parent Create Accounting Job
	  order by rh.requestid desc
			 , rp.name

-- ##############################################################
-- APCSTTRF - Transfer Costs to Cost Management
-- ##############################################################

/*
completionText: Completion text
display.attribute2.value: XX BU
display.attribute3.value: 2023-03-31
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and rp.name in ('completionText','display.attribute2.value','display.attribute3.value')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and rp.name in ('completionText','display.attribute2.value','display.attribute3.value')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'display.attribute2.value' business_unit
			  , 'display.attribute3.value' end_date)
)
order by id desc

-- ##############################################################
-- ReceiptAccrualProcessMasterEssJobDef - Create Receipt Accounting Distributions
-- ##############################################################

/*
completionText: Completion text
submit.argument1: BU
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and rp.name in ('completionText','submit.argument1')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and rp.name in ('completionText','submit.argument1')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'submit.argument1' bu)
)
order by id desc

-- ##############################################################
-- TaxBoxAllocationProcess - Tax Allocation Process
-- ##############################################################

/*
completionText: Completion text
display.attribute1.value: Reporting Identifier Name, not ID
display.attribute2.value: Source value (e.g. "Input tax", "Output tax" etc).
display.attribute3.value: Tax Calendar Period
display.attribute4.value: Reallocate
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('TaxBoxAllocationProcess')
		   and rp.name in ('completionText','display.attribute1.value','display.attribute2.value','display.attribute3.value','display.attribute4.value')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('TaxBoxAllocationProcess')
		   and rp.name in ('completionText','display.attribute1.value','display.attribute2.value','display.attribute3.value','display.attribute4.value')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'display.attribute1.value' reporting_identifier
			  , 'display.attribute2.value' reporting_source
			  , 'display.attribute3.value' tax_period
			  , 'display.attribute4.value' reallocate)
)
order by id desc

-- ##############################################################
-- EmeaVatSelectionProcess - Select Transactions for Tax Reporting
-- ##############################################################

/*
completionText: Completion text
submit.argument3: Reporting Identifier ID (links to jg_zz_vat_rep_entities.VAT_REPORTING_ENTITY_ID to get ENTITY_IDENTIFIER)
submit.argument4: Tax Calendar Period
submit.argument5: Source value
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('EmeaVatSelectionProcess')
		   and rp.name in ('completionText','submit.argument3','submit.argument4','submit.argument5')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('EmeaVatSelectionProcess')
		   and rp.name in ('completionText','submit.argument3','submit.argument4','submit.argument5')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'submit.argument3' reporting_identifier
			  , 'submit.argument4' tax_period
			  , 'submit.argument5' reporting_source)
)
order by id desc

-- ##############################################################
-- TaxBoxAllocationListing - Tax Allocations Listing Report
-- ##############################################################

/*
completionText: Completion text
submit.argument1: Reporting Identifier ID (links to jg_zz_vat_rep_entities.VAT_REPORTING_ENTITY_ID to get ENTITY_IDENTIFIER)
submit.argument2: Source (e.g. Input tax (P2P), Output tax (O2C), ALL)
submit.argument3: Tax Calendar Period
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('TaxBoxAllocationListing')
		   and rp.name in ('completionText','submit.argument1','submit.argument3','submit.argument10')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('TaxBoxAllocationListing')
		   and rp.name in ('submit.argument1','submit.argument2','submit.argument3')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'submit.argument1' reporting_identifier
			  , 'submit.argument2' reporting_source
			  , 'submit.argument3' tax_period)
)
order by id desc

-- ##############################################################
-- TaxBoxReturnPreparation - Tax Box Return Preparation Report
-- ##############################################################

/*
completionText: Completion text
submit.argument1: Reporting Identifier ID (links to jg_zz_vat_rep_entities.VAT_REPORTING_ENTITY_ID to get ENTITY_IDENTIFIER)
submit.argument2: Source (e.g. Input tax (P2P), Output tax (O2C), ALL)
submit.argument3: Tax Calendar Period
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and rp.name in ('completionText','submit.argument1','submit.argument3','submit.argument10')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and rp.name in ('completionText','submit.argument1','submit.argument2','submit.argument3')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'submit.argument1' reporting_identifier
			  , 'submit.argument2' reporting_source
			  , 'submit.argument3' tax_period)
)
order by id desc

-- ##############################################################
-- EmeaVatFinalReportingProcess - Finalize Transactions for Tax Reporting
-- ##############################################################

/*
completionText: Completion Text
display.attribute1.value: Reporting Identifier Name, not ID
display.attribute2.value: Tax Calendar Period
display.attribute3.value: Source value (e.g. "Input tax", "Output tax" etc).
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('EmeaVatFinalReportingProcess')
		   and rp.name in ('completionText','display.attribute1.value','display.attribute2.value','display.attribute3.value')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('EmeaVatFinalReportingProcess')
		   and rp.name in ('completionText','display.attribute1.value','display.attribute2.value','display.attribute3.value')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'display.attribute1.value' reporting_identifier
			  , 'display.attribute2.value' tax_period
			  , 'display.attribute3.value' reporting_source)
)
order by id desc

-- ##############################################################
-- InterfaceLoaderController - Load Interface File for Import
-- ##############################################################

/*
Notes about the job
++++++++++++++++++

When "Load Interface File for Import" is submitted, it normally kicks off at least 2 child jobs:

Load Interface File for Import
- Transfer File
- Load File to Interface

The IDs of these jobs appear as parameters in the parent "Load Interface File for Import" job.
The "name" values of these parameters appear as numbers.

e.g. might be kick off "Load Interface File for Import", Request ID 6363408
Looking in the REQUEST_PROPERTY table for that ID, it has 2 parameters:

NAME__________VALUE
6363409_______NULL
6363410_______PJC_TXN_XFACE_STAGE_ALL

In the above case:

6363409: ID for "Transfer File"
6363410: ID for "Load File to Interface"

If the VALUE is populated for the ID for the "Load File to Interface" job, the value is the name of the interface table.

Examples:

submit.argument5.attributeValue: Import Costs
ImportJobName: /oracle/apps/ess/projects/costing/transactions/onestop;ImportProcessParallelEssJob
6363399: PJC_TXN_XFACE_STAGE_ALL

submit.argument5.attributeValue: Validate and Upload Budgets
ImportJobName: /oracle/apps/ess/financials/generalLedger/ledgers/ledgerDefinitions;ValidateAndLoadBudgets
6400126: GL_BUDGET_INTERFACE

To return parameter names made up of only numbers uncomment this line:

and regexp_like(rp.name, '^[[:digit:]]+$') -- parameter name only contains numbers

++++++++++++++++++

Parameters:

completionText: Completion text
submit.argument5.attributeValue: Import Process Name - e.g. "Import Costs"
submit.argument6.attributeValue: File Name
ImportJobName: e.g. "/oracle/apps/ess/financials/generalLedger/ledgers/ledgerDefinitions;ValidateAndLoadBudgets"
REQUEST_SUBMITTED_FROM_UI: Y - e.g. was submitted via front-end
submit.argument2: Document ID value - links to UCM "REVISIONS" table's "DID" column
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and rp.name in ('completionText','submit.argument5.attributeValue','submit.argument6.attributeValue','ImportJobName','REQUEST_SUBMITTED_FROM_UI','submit.argument2')
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('InterfaceLoaderController')
		   -- and regexp_like(rp.name, '[0-9]') -- parameter contains a number
		   -- and regexp_like(rp.name, '^[[:digit:]]+$') and rp.value is not null -- parameter name only contains numbers and is not null - if uncomment this line and comment out line starting with "and rp.name in ('completionText..." that might return related interface table name for the job
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('InterfaceLoaderController')
		   and rp.name in ('completionText','submit.argument5.attributeValue','submit.argument6.attributeValue','ImportJobName','REQUEST_SUBMITTED_FROM_UI','submit.argument2')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'submit.argument5.attributeValue' import_process
			  , 'submit.argument6.attributeValue' file_name
			  , 'REQUEST_SUBMITTED_FROM_UI' ran_from_front_end
			  , 'submit.argument2' ucm_doc_id
			  , 'ImportJobName' import_job_name)
)
order by id desc

-- ##############################################################
-- IBY_FD_SRA_FORMAT - Send Separate Remittance Advice
-- ##############################################################

/*
completionText: Completion Text
submit.argument1: Payment File Name
submit.argument2: Remittance Advice Format Name
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('IBY_FD_SRA_FORMAT')
		   and rp.name in ('completionText','submit.argument1','submit.argument2')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('IBY_FD_SRA_FORMAT')
		   and rp.name in ('completionText','submit.argument1','submit.argument2')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'submit.argument1' payment_file_name
			  , 'submit.argument2' remit_advice_format_name)
)
order by id desc

-- ##############################################################
-- APXPRIMPT - Import Payables Payment Requests
-- ##############################################################

/*
completionText: Completion Text
REQUEST_SUBMITTED_FROM_UI: Y - e.g. was submitted via front-end
submit.argument1: Business Unit ID
submit.argument12.attributeValue: Business Unit Name
submit.argument11.attributeValue: Ledger Name
submit.argument2: Accounting Date
submit.argument4: Source
submit.argument6: Purge
submit.argument7: Summarize Report
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , rp.name
			 , rp.value value_
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , case when rp.name = 'submit.argument1' then (select bu_name from fun_all_business_units_v bu where bu.bu_id = rp.value) end business_unit
			 , case when rp.name = 'submit.argument8' then (select name from gl_ledgers gl where gl.ledger_id = rp.value) end ledger
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('APXPRIMPT')
		   and rp.name in ('completionText','REQUEST_SUBMITTED_FROM_UI','submit.argument1','submit.argument12','submit.argument11','submit.argument2','submit.argument4','submit.argument6','submit.argument7')
		   -- and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'submit.argument4' and rp2.value = 'IMAGE') -- optional - uncomment to return import jobs for a specific source - e.g. IMAGE
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('APXPRIMPT')
		   and rp.name in ('completionText','REQUEST_SUBMITTED_FROM_UI','submit.argument1','submit.argument12','submit.argument11','submit.argument2','submit.argument4','submit.argument6','submit.argument7')
		   -- and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'submit.argument4' and rp2.value = 'IMAGE') -- optional - uncomment to return import jobs for a specific source - e.g. IMAGE
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'REQUEST_SUBMITTED_FROM_UI' REQUEST_SUBMITTED_FROM_UI
			  , 'submit.argument1' bus_unit_id
			  , 'submit.argument2' accounting_date
			  , 'submit.argument4' source
			  , 'submit.argument6' purge
			  , 'submit.argument7' summarize_report
			  , 'submit.argument11' ledger
			  , 'submit.argument12' bus_unit_name)
)
order by id desc

-- ##############################################################
-- LoadSegValAndHierData - Import Segment Values and Hierarchies
-- ##############################################################

/*
Returns the Chart of Accounts Segment the job ran against (e.g. XX_GL_COST_CENTRE, XX_GL_PROJECT) via "submit.argument2" property

completionText: Completion Text
submit.argument2: Chart of Accounts Segment Name
submit.argument4: Request ID of parent "Load Interface File for Import" job
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('LoadSegValAndHierData')
		   and rp.name in ('completionText','submit.argument2','submit.argument4')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('LoadSegValAndHierData')
		   and rp.name in ('completionText','submit.argument2','submit.argument4')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'submit.argument2' coa_segment_name
			  , 'submit.argument4' parent_load_request_id)
)
order by id desc

-- ##############################################################
-- FlowEssJobDefn - HCM Flow Secured
-- ##############################################################

/*
completionText: Completion Text
FlowParam_flowId: Flow ID
FlowParam_flowInstanceId: Flow Instance ID (linked to PAY_FLOW_INSTANCES.FLOW_INSTANCE_ID)
FlowParam_flowTaskId: Flow Task ID
FlowParam_flowTaskInstanceId: Flow Task Instance ID
FlowParam_requestId: Request ID
FlowParam_flowInstanceName: Flow Instance Name
FlowParam_flowTaskName: Flow Task Name
FlowParam_userName: Flow User Name
FlowParam_taskType: Task Type
FlowParam_executionMode: Execution Mode
FlowParam_pay.start_date: Start Date
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('FlowEssJobDefn')
		   and rp.name in ('completionText','FlowParam_flowId','FlowParam_flowInstanceId','FlowParam_flowTaskId','FlowParam_flowTaskInstanceId','FlowParam_requestId','FlowParam_flowInstanceName','FlowParam_flowTaskName','FlowParam_userName','FlowParam_taskType','FlowParam_executionMode','FlowParam_pay.start_date')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('FlowEssJobDefn')
		   and rp.name in ('completionText','FlowParam_flowId','FlowParam_flowInstanceId','FlowParam_flowTaskId','FlowParam_flowTaskInstanceId','FlowParam_requestId','FlowParam_flowInstanceName','FlowParam_flowTaskName','FlowParam_userName','FlowParam_taskType','FlowParam_executionMode','FlowParam_pay.start_date')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'FlowParam_flowId' flow_id
			  , 'FlowParam_flowInstanceId' flow_instance_id
			  , 'FlowParam_flowTaskId' flow_task_id)
			  , 'FlowParam_flowTaskInstanceId' flow_task_instance_id)
			  , 'FlowParam_requestId' request_id)
			  , 'FlowParam_flowInstanceName' flow_instance_name)
			  , 'FlowParam_flowTaskName' flow_task_name)
			  , 'FlowParam_userName' user_name)
			  , 'FlowParam_taskType' task_type)
			  , 'FlowParam_executionMode' execution_mode
			  , 'FlowParam_pay.start_date', start_date)
)
order by id desc

-- ##############################################################
-- APXIIMPT - Import Payables Invoices
-- ##############################################################

/*
completionText: Completion Text
display.attribute4.value: Accounting Date
display.attribute8.value: Source Full Name
display.attribute9.value: Import Set
display.attribute10.value: Purge
display.attribute11.value: Summarize
display.attribute13.value: Invoice Group
display.attribute14.value: Number of Parallel Processes
display.attribute15.value: Ledger
display.attribute16.value: Business Unit
submit.argument8: Source
submit.argument15.attributeValue: Ledger
submit.argument16.attributeValue: Business Unit
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('APXIIMPT')
		   -- and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'submit.argument8' and rp2.value = 'IMAGE') -- uncomment to return a specific source
		   and rp.name in ('completionText','display.attribute4.value','display.attribute8.value','display.attribute9.value','display.attribute10.value','display.attribute11.value','display.attribute13.value','display.attribute14.value','display.attribute15.value','display.attribute16.value','submit.argument8','submit.argument15.attributeValue','submit.argument16.attributeValue')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('APXIIMPT')
		   -- and exists (select 'y' from request_property rp2 where rp2.requestid = rh.requestid and rp2.name = 'submit.argument8' and rp2.value = 'IMAGE') -- uncomment to return a specific source
		   and rp.name in ('completionText','display.attribute4.value','display.attribute8.value','display.attribute9.value','display.attribute10.value','display.attribute11.value','display.attribute13.value','display.attribute14.value','display.attribute15.value','display.attribute16.value','submit.argument8','submit.argument15.attributeValue','submit.argument16.attributeValue')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'display.attribute4.value' accounting_date
			  , 'display.attribute8.value' source_full_name
			  , 'display.attribute9.value' import_set
			  , 'display.attribute10.value' purge
			  , 'display.attribute11.value' summarize_report
			  , 'display.attribute13.value' invoice_group
			  , 'display.attribute14.value' num_parallel_processes
			  , 'display.attribute15.value' ledger
			  , 'display.attribute16.value' business_unit
			  , 'submit.argument8' source
			  , 'submit.argument15.attributeValue' ledger_name
			  , 'submit.argument16.attributeValue' bus_unit_name)
)
order by id desc

-- ##############################################################
-- APXAPRVL - Validate Payables Invoices
-- ##############################################################

/*
completionText: Completion Text
display.attribute7.value: Supplier or Party
display.attribute10.value: Invoice Number
display.attribute14.value: Invoice Group
display.attribute17.value: Max Invoice Count
display.attribute18.value: Number Parallel Processes
submit.argument2: Option
submit.argument3: From Invoice Date
submit.argument4: To Invoice Date
submit.argument6: Pay Group
submit.argument8: Entered By
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('APXAPRVL')
		   and rp.name in ('completionText','display.attribute7.value','display.attribute14.value','display.attribute17.value','display.attribute18.value','submit.argument2','submit.argument3','submit.argument4','submit.argument6','submit.argument8')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('APXAPRVL')
		   and rp.name in ('completionText','display.attribute7.value','display.attribute14.value','display.attribute17.value','display.attribute18.value','submit.argument2','submit.argument3','submit.argument4','submit.argument6','submit.argument8')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'display.attribute7.value' supplier_or_party
			  , 'display.attribute10.value' invoice_number
			  , 'display.attribute14.value' invoice_group
			  , 'display.attribute17.value' max_inv_count
			  , 'display.attribute18.value' num_parallel_processes
			  , 'submit.argument2' option_
			  , 'submit.argument3' from_inv_date
			  , 'submit.argument4' to_inv_date
			  , 'submit.argument6' pay_group
			  , 'submit.argument8' entered_by)
)
order by id desc

-- ##############################################################
-- StrategyAutomatedProcess - Send Dunning Letters
-- ##############################################################

/*
completionText: Completion text
submit.argument11: RestartRequestID
submit.argument12: not known but seems to be a request ID
submit.argument13: e.g. #First Reminder
submit.argument14: Draft or Final (B = Final?)
submit.argument9: Business Unit ID
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('StrategyAutomatedProcess')
		   and rp.name in ('completionText','submit.argument11','submit.argument12','submit.argument13','submit.argument14','submit.argument9')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('StrategyAutomatedProcess')
		   and rp.name in ('completionText','submit.argument11','submit.argument12','submit.argument13','submit.argument14','submit.argument9')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'submit.argument11' restart_requestid
			  , 'submit.argument12' request_id
			  , 'submit.argument13' label_
			  , 'submit.argument14' draft_or_final
			  , 'submit.argument9' bus_unit_id)
)
order by id desc

-- ##############################################################
-- GenerateBurdenTransactionsJob - Generate Burden Costs
-- ##############################################################

/*
completionText: Completion text
parentRequest: Parent Request
display.attribute1.value: Business Unit
display.attribute5.value: Expenditure Item Through Date
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('GenerateBurdenTransactionsJob')
		   and rp.name in ('completionText','parentRequest','display.attribute1.value','display.attribute5.value')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('GenerateBurdenTransactionsJob')
		   and rp.name in ('completionText','parentRequest','display.attribute1.value','display.attribute5.value')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'parentRequest' parent_request
			  , 'display.attribute1.value' business_unit
			  , 'display.attribute5.value' exp_item_through_date)
)
order by id desc

-- ##############################################################
-- ImportAndProcessTxnsJob - Import Costs
-- ##############################################################

/*
completionText: Completion text
submit.argument2 - Business Unit ID
submit.argument4 - Batch Name
submit.argument6 - Transaction Source ID
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , rp.name
			 , rp.value value_
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , case when rp.name = 'submit.argument6' then (select user_transaction_source from pjf_txn_sources_tl ptst where ptst.transaction_source_id = rp.value and ptst.language = userenv('lang')) end trx_source
			 , case when rp.name = 'submit.argument2' then (select bu_name from fun_all_business_units_v fabuv where fabuv.bu_id = rp.value) end business_unit
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('ImportAndProcessTxnsJob')
		   and rp.name in ('completionText','submit.argument2','submit.argument4','submit.argument6')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('ImportAndProcessTxnsJob')
		   and rp.name in ('completionText','submit.argument2','submit.argument4','submit.argument6')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'submit.argument2' business_unit_id
			  , 'submit.argument4' batch_name
			  , 'submit.argument6' trx_source_id)
)
order by id desc

-- ##############################################################
-- AccountingPeriodClose - Close Accounting Period
-- ##############################################################

/*
completionText: Completion text
submit.argument2: ledger
submit.argument5: period_name
submit.argument8: online_flag
submit.argument9: close_type
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('AccountingPeriodClose')
		   and rp.name in ('completionText','submit.argument2','submit.argument5','submit.argument8','submit.argument9')
		   -- and rh.requestid in (select rp.requestid id from request_property rp where substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('AccountingPeriodClose') and rp.name in ('submit.argument5') and rp.value = 'Mar-23')
		   -- and rh.requestid in (select rp.requestid id from request_property rp where substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('AccountingPeriodClose') and rp.name in ('submit.argument2') and rp.value = 'XCC Ledger')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('AccountingPeriodClose')
		   and rp.name in ('completionText','submit.argument2','submit.argument5','submit.argument8','submit.argument9')
		   -- and rh.requestid in (select rp.requestid id from request_property rp where substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('AccountingPeriodClose') and rp.name in ('submit.argument5') and rp.value = 'Mar-23')
		   -- and rh.requestid in (select rp.requestid id from request_property rp where substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('AccountingPeriodClose') and rp.name in ('submit.argument2') and rp.value = 'XCC Ledger')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'submit.argument2' ledger
			  , 'submit.argument5' period_name
			  , 'submit.argument8' online_flag
			  , 'submit.argument9' close_type)
)
order by id desc

-- ##############################################################
-- AccountingPeriodOpen - Open Accounting Period
-- ##############################################################

/*
completionText: Completion text
submit.argument1: LEDGER_ID_1
submit.argument2: LEDGER_ID_2
submit.argument3: period_name
submit.argument4: close_type
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('AccountingPeriodOpen')
		   and rp.name in ('completionText','submit.argument1','submit.argument2','submit.argument3','submit.argument4')
		   -- and rh.requestid in (select rp.requestid id from request_property rp where substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('AccountingPeriodOpen') and rp.name in ('submit.argument3') and rp.value = 'Mar-23')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('AccountingPeriodOpen')
		   and rp.name in ('completionText','submit.argument1','submit.argument2','submit.argument3','submit.argument4')
		   -- and rh.requestid in (select rp.requestid id from request_property rp where substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('AccountingPeriodOpen') and rp.name in ('submit.argument3') and rp.value = 'Mar-23')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'submit.argument1' ledger_id_1
			  , 'submit.argument2' ledger_id_2
			  , 'submit.argument3' period_name
			  , 'submit.argument4' close_type)
)
order by id desc

-- ##############################################################
-- TransactionPrintProgramEss - Print Receivables Transactions
-- ##############################################################

/*
completionText: Completion text
display.attribute1.value: XX BU
display.attribute27.value: Default Invoice Template
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('TransactionPrintProgramEss')
		   and rp.name in ('completionText','display.attribute1.value','display.attribute27.value')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name

/*
one row per job using PIVOT
https://stackoverflow.com/questions/64390380/rows-to-columns-using-pivot-function-oracle
*/

with my_data as (
		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('TransactionPrintProgramEss')
		   and rp.name in ('completionText','display.attribute1.value','display.attribute27.value')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
		   and 1 = 1)
select * from (
		select id
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
   for name in ('completionText' completion_text
			  , 'display.attribute1.value' bu_name
			  , 'display.attribute27.value' default_inv_template)
)
order by id desc

/*
completionText: Completion text
display.attribute1.value: XX BU
display.attribute27.value: Default Invoice Template
*/

-- ##############################################################
-- AccountingPeriodOpenReportJob - Open Accounting Period: Generate Report
-- AccountingPeriodCloseReportJob - Close Accounting Period: Generate Report
-- ##############################################################

/*
Find ID of Projects Period Close / Open Reporting Jobs

completionText: Completion text
submit.argument1: 123456 -- ID of the parent job
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
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
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('AccountingPeriodOpenReportJob','AccountingPeriodCloseReportJob')
		   and rp.name in ('completionText','submit.argument1')
		   and rp.value in ('123456') -- request ID of parent Create Accounting Job
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
			 , rp.name

-- ##############################################################
-- JournalImportLauncher - Import Journals - Source
-- ##############################################################

/*
submit.argument2: Source
*/

		select rh.requestid id
			 -- , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 -- , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') process_start
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') process_end
			 -- , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 -- , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , rp.name
			 , rp.value value_
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , gjst.user_je_source_name
		  from request_history rh
		  join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
		  join request_property rp on rp.requestid = rh.requestid
	 left join gl_je_sources_tl gjst on rp.value = gjst.je_source_name and rp.name = 'submit.argument2'
		 where 1 = 1
		   and substr(rh.definition,(instr(rh.definition,'/',-1)+1)) in ('JournalImportLauncher')
		   and rp.name in ('submit.argument2')
		   -- and flv_state.meaning = 'Warning'
		   -- and rh.requestid = 123456
	  order by rh.requestid desc
			 , rp.name
