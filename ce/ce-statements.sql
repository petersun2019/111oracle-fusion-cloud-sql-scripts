/*
File Name: ce-statements.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- TABLE DUMPS
-- STATEMENTS - BASIC
-- STATEMENTS - SUMMARY

*/

-- ##############################################################
-- TABLE DUMPS
-- ##############################################################

select * from ce_statement_headers where statement_header_id = 123456
select * from ce_statement_lines where statement_header_id = 123456
select * from ce_stmt_import_errors where statement_header_int_id = 123456

-- ##############################################################
-- STATEMENTS - BASIC
-- ##############################################################

		select csh.statement_header_id
			 , csh.statement_number
			 , to_char(csh.statement_date, 'yyyy-mm-dd') statement_date
			 , csh.balance_check
			 , csh.currency_code
			 , csh.recon_status_code
			 , csh.autorec_process_code
			 , csh.statement_entry_type
			 , csh.statement_type
			 , to_char(csh.creation_date, 'yyyy-mm-dd hh24:mi:ss') header_created
			 , csh.created_by header_created_by
			 , '#' lines_______
			 , csl.statement_line_id
			 , csl.line_number
			 , csl.trx_type
			 , csl.trx_code_id
			 , csl.amount
			 , csl.trx_amount
			 , csl.recon_status
			 , csl.reversal_ind_flag
			 , csl.customer_reference
			 , csl.end_to_end_id
			 , csl.transaction_id
			 , csl.recon_reference
			 , csl.check_number
			 , csl.clearing_system_ref
			 , csl.exception_flag
			 , csl.reversal_reason_code
			 , to_char(csl.booking_date, 'yyyy-mm-dd') booking_date
			 , to_char(csl.value_date, 'yyyy-mm-dd') value_date
			 , to_char(csl.creation_date, 'yyyy-mm-dd hh24:mi:ss') line_created
			 , csl.created_by line_created_by
			 , '#' bank_______
			 , csh.bank_account_id
			 , cba.bank_account_name
			 , cba.bank_account_num
			 , '#' file_______
			 , iif.processing_status
			 , iif.format_type_code
			 , iif.format_code
			 , iif.transmit_config_id
			 , iif.file_path
			 , iif.file_name
			 , iif.file_length
			 , iif.request_id
			 , iif.ucm_doc_id
		  from ce_statement_headers csh
		  join ce_statement_lines csl on csh.statement_header_id = csl.statement_header_id
	 left join ce_bank_accounts cba on cba.bank_account_id = csh.bank_account_id
	 left join iby_inbound_file iif on iif.inbound_file_id = csh.inbound_file_id

-- ##################################################################
-- STATEMENTS - SUMMARY
-- ##################################################################

		select csh.statement_header_id
			 , csh.statement_number
			 , csh.balance_check
			 , csh.currency_code
			 , to_char(csh.statement_date, 'yyyy-mm-dd')
			 , to_char(csh.creation_date, 'yyyy-mm-dd hh24:mi:ss') header_created
			 , cba.bank_account_name
			 , cba.bank_account_num
			 , csl.recon_status
			 , iif.processing_status
			 , iif.format_type_code
			 , iif.format_code
			 , iif.transmit_config_id
			 , iif.file_path
			 , iif.file_name
			 , iif.file_length
			 , iif.request_id
			 , iif.ucm_doc_id
			 , count(*) lines
			 , sum(csl.amount) amt
		  from ce_statement_headers csh
		  join ce_statement_lines csl on csh.statement_header_id = csl.statement_header_id
	 left join ce_bank_accounts cba on cba.bank_account_id = csh.bank_account_id
	 left join iby_inbound_file iif on iif.inbound_file_id = csh.inbound_file_id
		 where 1 = 1
		   and 1 = 1
	  group by csh.statement_header_id
			 , csh.statement_number
			 , csh.balance_check
			 , csh.currency_code
			 , to_char(csh.statement_date, 'yyyy-mm-dd')
			 , cba.bank_account_name
			 , cba.bank_account_num
			 , csl.recon_status
			 , to_char(csh.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , iif.processing_status
			 , iif.format_type_code
			 , iif.format_code
			 , iif.transmit_config_id
			 , iif.file_path
			 , iif.file_name
			 , iif.file_length
			 , iif.request_id
			 , iif.ucm_doc_id
	  order by csh.statement_header_id desc
