/*
File Name: pa-expenditures-interface.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- INTERFACE NOTES
-- INTERFACE 1
-- INTERFACE 2
-- TRANSACTION INTERFACE ERRORS
-- ERROR COUNTING 1
-- COUNT BY TRANSACTION SOURCE

*/

-- ##############################################################
-- INTERFACE NOTES
-- ##############################################################

/*
Failure of Import Cost Program Gets Data Purged From Interface (Doc ID 2428357.1)

GOAL
You noticed that the program "Import Costs" automatically spawns the program"Import Costs: Summarize and Purge Subprocess" 
and the interface data gets purged. Whether the data is imported or not, the data gets purged from the interface and the 
only way to get data back into the interface is to re run the BI final report once again.
You expect that when the import is not successful, the data should not get purged from the interface.
Why this happens?
 

SOLUTION
Purging of Data from interface tables happens at the end of Import Costs Process, after BIP report request is Complete , as follows:

PJC_TXN_XFACE_ALL: Data from this table will be purged only after corresponding Expenditure items are created successfully or User deletes the transactions.
PJC_TXN_XFACE_STAGE_ALL: Both Successfully Processed ( transactions Moved to PJC_TXN_XFACE_ALL table)
and Rejected Transactions ( Staging Level rejections for invalid Name or Number etc) will be Purged At the End of Import and process which processes the transactions.

Consequently, data is purged from both tables in case it is successfully imported.

If there are transactions rejected, rejected data from table PJC_TXN_XFACE_ALL is not purged; only from PJC_TXN_XFACE_STAGE_ALL.

-----------------------------

PJC_TXN_XFACE_STAGE_ALL
is the table you use for importing third party transactions with containing name and / or ID for all attributes
like project, task, expenditure type, organization, person, supplier, inventory, etc.
Name to ID conversion will happen and these transactions will be populated into PJC_TXN_XFACE_ALL for one-stop processing.

PJC_TXN_XFACE_ALL
is the table you use for importing transactions from external sources into Oracle Projects.
You load this table with your transaction data and then submit the Transaction Import process to validate and import the data into the Oracle Projects expenditure tables

Run "Load Interface File to Fusion" for "Project Costs"
Data is first loaded into PJC_TXN_XFACE_STAGE_ALL but not PJC_TXN_XFACE_ALL
If run "Import Costs" and it works with no issues, you won't see any data in the PJC_TXN_XFACE_STAGE_ALL or PJC_TXN_XFACE_ALL tables
However, if there is an issue with the import and the record appears in Unprocessed Costs, data can be seen in the PJC_TXN_XFACE_ALL table but it is then removed from PJC_TXN_XFACE_STAGE_ALL
Once the import has run successfully, data is purged from both tables.

Basic flow summary:
Data first loaded into PJC_TXN_XFACE_STAGE_ALL
When Import Costs runs, data loaded into PJC_TXN_XFACE_ALL
If all okay, data removed from both tables
If issues encountered preventing successful import, data removed from PJC_TXN_XFACE_STAGE_ALL but kept in PJC_TXN_XFACE_ALL
*/

select * from pjc_txn_xface_stage_all order by creation_date desc
select count(*) from pjc_txn_xface_stage_all -- 2

select * from pjc_txn_xface_all order by creation_date desc
select count(*) from pjc_txn_xface_all

select count(*) from pjc_txn_xface_all where expenditure_item_id in (123456)
select * from pjc_txn_xface_all where batch_name = 'abc123'
select * from pjc_txn_xface_all where txn_interface_id in (100000249498021,100000460033239)
select count(*) from pjc_txn_xface_all where to_char(expenditure_item_date, 'yyyy-mm') = '2023-03'
select * from pjc_txn_xface_all where expenditure_item_id = 123456

select 'PJC_TXN_XFACE_ALL' tbl, count(*) record_count from pjc_txn_xface_all union all
select 'PJC_TXN_XFACE_STAGE_ALL', count(*) from pjc_txn_xface_stage_all

select count(*) from PJC_TXN_XFACE_ALL where RECVR_GL_PERIOD_NAME is null -- 7
select count(*) from PJC_TXN_XFACE_ALL where RECVR_GL_PERIOD_NAME is not null -- 3710

/*
pjc_txn_xface_stage_all.transaction_type from FBDI loader files

* Transaction Type
This value is used to describe the type of transaction that is being created.
Options are; LABOR, NONLABOR, MISCELLANEOUS, EXPENSES, SUPPLIER, INVENTORY.
For this template, enter LABOR.
*/

-- ##############################################################
-- INTERFACE 1
-- ##############################################################

		select ppav.segment1 project
			 , ppav.name project_name
			 , ptv.task_number
			 , to_char(ptxa.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , ptxa.expenditure_item_id
			 , haou.name exp_org
			 , to_char(ptxa.expenditure_item_date, 'yyyy-mm-dd') expenditure_item_date
			 , to_char(ptxa.expenditure_ending_date, 'yyyy-mm-dd') expenditure_ending_date
			 , ptst.user_transaction_source trx_source
			 , petl.expenditure_type_name
			 , ptxa.document_name
			 , '#' || ptxa.document_id document_id
			 , ptdet.doc_entry_name exp_document_entry
			 , ptdt.document_name exp_document
			 , ptxa.batch_name
			 , ptxa.prvdr_pa_period_name pa_period
			 , ptxa.prvdr_gl_period_name gl_period
			 , ptxa.quantity
			 , ptxa.projfunc_raw_cost
			 , ptxa.projfunc_burdened_cost
			 , ptxa.project_raw_cost
			 , ptxa.project_burdened_cost
			 , replace(replace(ptxa.expenditure_comment,chr(10),' '),chr(13),' ') expenditure_comment
			 , ptxa.transaction_status_code
			 , '#' || ptxa.orig_transaction_reference orig_transaction_reference
			 , ptxa.user_transaction_source
			 , ptxa.denom_currency_code
			 , ptxa.acct_currency_code
			 , ptxa.unit_of_measure
			 , ptxa.context_category
			 , ptxa.error_group
			 , ptxa.doc_ref_id1
			 , ptxa.doc_ref_id2
			 , ptxa.doc_ref_id3
		  from pjf_projects_all_vl ppav
		  join pjf_tasks_v ptv on ppav.project_id = ptv.project_id
		  join pjc_txn_xface_all ptxa on ptxa.project_id = ppav.project_id and ptxa.task_id = ptv.task_id
	 left join pjf_txn_sources_tl ptst on ptxa.transaction_source_id = ptst.transaction_source_id
	 left join pjf_exp_types_tl petl on ptxa.expenditure_type_id = petl.expenditure_type_id
	 left join hr_all_organization_units haou on ptxa.organization_id = haou.organization_id
	 left join pjf_txn_doc_entry_tl ptdet on ptdet.doc_entry_id = ptxa.doc_entry_id
	 left join pjf_txn_document_tl ptdt on ptdt.document_id = ptxa.document_id
		 where 1 = 1
		   and 1 = 1
	  order by ptxa.creation_date desc

-- ##############################################################
-- INTERFACE 2
-- ##############################################################

		select ptxa.*
		  from pjf_projects_all_vl ppav
		  join pjf_tasks_v ptv on ppav.project_id = ptv.project_id
	 left join pjc_txn_xface_all ptxa on ptxa.project_id = ppav.project_id
		 where 1 = 1
		   and 1 = 1
	  order by ptxa.creation_date desc

-- ##############################################################
-- TRANSACTION INTERFACE ERRORS
-- ##############################################################

/*
https://cloudcustomerconnect.oracle.com/posts/c7c8591753
*/

		select ptxa.expenditure_item_id
			 , to_char(ptxa.creation_date, 'yyyy-mm-dd hh24:mi:ss') item_created
			 , to_char(ptxa.expenditure_item_date, 'yyyy-mm-dd') expenditure_item_date
			 , to_char(ptxa.expenditure_ending_date, 'yyyy-mm-dd') expenditure_ending_date
			 , ptst.user_transaction_source trx_source
			 , petl.expenditure_type_name
			 , haou.name exp_org
			 , ptxa.document_name
			 , '#' || ptxa.document_id document_id
			 , ptdet.doc_entry_name exp_document_entry
			 , ptdt.document_name exp_document
			 , ptxa.batch_name
			 , ptxa.prvdr_pa_period_name pa_period
			 , ptxa.prvdr_gl_period_name gl_period
			 , ptxa.quantity
			 , ptxa.expenditure_comment
			 , ptxa.transaction_status_code
			 , ptxa.orig_transaction_reference
			 , ptxa.user_transaction_source
			 , ptxa.denom_currency_code
			 , ptxa.acct_currency_code
			 , ptxa.unit_of_measure
			 , ptxa.context_category
			 , ptxa.error_group
			 , ptxa.doc_ref_id1
			 , ptxa.doc_ref_id2
			 , ptxa.doc_ref_id3
			 , ppav.segment1 as project_number
			 , to_char(ppav.start_date, 'yyyy-mm-dd') proj_start_date
			 , to_char(ppav.completion_date, 'yyyy-mm-dd') proj_completion_date
			 , pptt.project_type
			 , ppst.project_status_name as project_status
			 , haou.name as project_org
			 , papf.person_number
			 , ppnf.full_name
			 , pam.assignment_number
			 , okha.contract_number
			 , '#' errors____________
			 , to_char(pte.creation_date, 'yyyy-mm-dd hh24:mi:ss') as x_error_created
			 , pte.message_name as x_error_code
			 , pte.error_group x_error_group
			 , pte.message_type_code
			 , pte.source_entity
			 , fmv.message_text as x_error_message
		  from pjc_txn_errors pte
	 left join pjc_txn_xface_all ptxa on pte.source_txn_id = ptxa.txn_interface_id and pte.error_group = ptxa.error_group
	 left join fnd_messages_vl fmv on pte.message_name = fmv.message_name
	 left join pjf_exp_types_tl petl on ptxa.expenditure_type_id = petl.expenditure_type_id 
	 left join pjf_projects_all_vl ppav on ptxa.project_id = ppav.project_id
	 left join pjf_project_types_tl pptt on ppav.project_type_id = pptt.project_type_id
	 left join pjf_project_statuses_tl ppst on ppav.project_status_code = ppst.project_status_code
	 left join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id and nvl(haou.effective_end_date,sysdate) >= sysdate
	 left join per_all_people_f_v papf on ptxa.person_id = papf.person_id and nvl(papf.effective_end_date,sysdate) > = sysdate
	 left join per_person_names_f_v ppnf on ptxa.person_id = ppnf.person_id and nvl(ppnf.effective_end_date,sysdate) > = sysdate and ppnf.name_type = 'GLOBAL'
	 left join per_all_assignments_m pam on ptxa.hcm_assignment_id = pam.assignment_id and nvl(pam.effective_end_date,sysdate) > = sysdate and pam.assignment_type = 'E' and pam.effective_latest_change = 'Y' and pam.assignment_status_type = 'ACTIVE' 
	 left join okc_k_headers_all_b okha on ptxa.contract_id = okha.id and okha.version_type = 'C'
	 left join pjf_txn_sources_tl ptst on ptxa.transaction_source_id = ptst.transaction_source_id
	 left join pjf_txn_doc_entry_tl ptdet on ptdet.doc_entry_id = ptxa.doc_entry_id
	 left join pjf_txn_document_tl ptdt on ptdt.document_id = ptxa.document_id
		 where 1 = 1
	  order by pte.creation_date desc
			 , ppav.segment1

-- ##############################################################
-- ERROR COUNTING 1
-- ##############################################################

		select pte.message_name
			 , count(*)
		  from pjc_txn_errors pte
		 where 1 = 1
	  group by pte.message_name
	  order by pte.message_name

-- ##############################################################
-- COUNT BY TRANSACTION SOURCE
-- ##############################################################

		select ptst.user_transaction_source trx_source
			 , min(to_char(ptxa.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_ptxa_created
			 , max(to_char(ptxa.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_ptxa_created
			 , min(ptxa.request_id)
			 , max(ptxa.request_id)
			 , count(*)
		  from pjc_txn_xface_all ptxa
		  join pjf_txn_sources_tl ptst on ptxa.transaction_source_id = ptst.transaction_source_id
		 where 1 = 1
		   and 1 = 1
	  group by ptst.user_transaction_source
