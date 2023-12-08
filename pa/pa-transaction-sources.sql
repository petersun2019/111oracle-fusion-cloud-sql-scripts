/*
File Name: pa-transaction-sources.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- PA TRANSACTION SOURCES
-- PA TRANSACTION SOURCES - DOCUMENTS

*/

-- ##############################################################
-- PA TRANSACTION SOURCES
-- ##############################################################

		select ptsb.transaction_source_id
			 , ptsb.transaction_source trx_src
			 , ptst.user_transaction_source trx_src_name
			 , ptst.description trx_src_description
			 , ptsb.batch_size processing_set_size
			 , to_char(ptsb.creation_date, 'yyyy-mm-dd hh24:mi:ss') trx_src_creation_date
			 , ptsb.created_by trx_src_created_by
			 , ptdb.document_id
			 , ptdb.document_code
			 , ptdb.predefined_flag
			 , to_char(ptdb.start_date_active, 'yyyy-mm-dd') doc_start_date
			 , to_char(ptdb.end_date_active, 'yyyy-mm-dd') doc_end_date
			 , (select count(*) from pjc_exp_items_all peia where peia.transaction_source_id = ptsb.transaction_source_id) exp_item_count
			 -- , '##############'
			 -- , ptdb.*
		  from pjf_txn_sources_b ptsb
		  join pjf_txn_sources_tl ptst on ptsb.transaction_source_id = ptst.transaction_source_id and ptst.language = userenv('lang')
		  join pjf_txn_document_b ptdb on ptdb.transaction_source_id = ptsb.transaction_source_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- PA TRANSACTION SOURCES - DOCUMENTS
-- ##############################################################

/*
https://docs.oracle.com/en/cloud/saas/project-management/23b/oedpp/pjftxndocumentb-17980.html#pjftxndocumentb-17980
*/

		select ptdt.document_name
			 , ptdb.document_code
			 , ptdb.document_id
			 , to_char(ptdb.creation_date, 'yyyy-mm-dd hh24:mi:ss') doc_created
			 , ptdb.created_by doc_created_by
			 , to_char(ptdb.last_update_date, 'yyyy-mm-dd hh24:mi:ss') doc_updated
			 , ptdb.last_updated_by doc_updated_by
			 , (select count(*) from pjc_exp_items_all peia where peia.document_id = ptdb.document_id) exp_item_count
			 , (select min(to_char(creation_date, 'yyyy-mm-dd')) from pjc_exp_items_all peia where peia.document_id = ptdb.document_id) min_exp_item_created
			 , (select max(to_char(creation_date, 'yyyy-mm-dd')) from pjc_exp_items_all peia where peia.document_id = ptdb.document_id) max_exp_item_created
			 , ptdb.import_in_closed_period_flag -- Allow accounted cost to be processed and imported when the project accounting periods are closed.
			 , ptdb.costed_flag -- Indicates that raw cost amounts are imported on transactions from this document.
			 , ptdb.allow_burden_flag -- Indicates that burdened cost amounts are imported on transactions from this document.
			 , ptdb.allow_duplicate_ref_flag -- Indicates that the same original system reference is allowed for transactions from this document.
			 , ptdb.allow_emp_org_override_flag -- Indicates that the person's primary HR assignment organization can be overridden on transactions from this document.
			 , ptdb.purgeable_flag -- Indicates that transactions from this document are to be archived after successful import.
			 , ptdb.import_cost_acc_flag -- Option to determine if cost transactions for this document have already been accounted in the source application.
			 , ptdb.cost_acc_journal_flag -- Indicates that raw cost accounting journal entries are to be created on transactions from this document.
			 , ptdb.adjust_acc_journal_flag -- Indicates that adjustment accounting journals entries are to be created on transactions from this document.
			 , ptdb.acct_during_import -- Indicates that accounting will be created in final mode for transactions from this document.
			 , ptdb.acct_source_code -- Used for subledger accounting purpose, not visible in UI.
			 , ptdb.skip_txn_controls -- Used to determine if transaction controls need to be performed on transactions. Not visible in UI, defined only for seeded transactions.
			 , ptdb.tieback_to_source -- Indicates that transactions from this document will tie back to the source system.
			 , ptdb.process_funds_check -- Used to determine if funds check needs to be performed on transactions.Not visible in UI, defined only for seeded transactions.
			 , ptdb.commitment_flag -- Specifies if the document can be used to import Commitment transactions or Actual transactions.
			 , ptdb.commitment_type -- 	Specifies the type of document (Supplier Invoice, Purchase Requisition , Purchase Order , External)
			 , ptdb.revalidate_flag -- A value of Y indicates that the transaction must be revalidated during import.
			 , '#' trx_source_____
			 , ptsb.batch_size processing_set_size
			 , ptsb.transaction_source trx_src
			 , ptst.user_transaction_source trx_src_name
			 , ptst.description trx_src_description
			 , to_char(ptsb.creation_date, 'yyyy-mm-dd hh24:mi:ss') trx_src_created
			 , ptsb.created_by trx_src_created_by
			 , to_char(ptsb.last_update_date, 'yyyy-mm-dd hh24:mi:ss') trx_src_updated
			 , ptsb.last_updated_by trx_src_updated_by
		  from pjf_txn_document_b ptdb
		  join pjf_txn_document_tl ptdt on ptdb.document_id = ptdt.document_id and ptdt.language = userenv('lang')
	 left join pjf_txn_sources_b ptsb on ptsb.transaction_source_id = ptdb.transaction_source_id
	 left join pjf_txn_sources_tl ptst on ptst.transaction_source_id = ptdb.transaction_source_id and ptst.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
