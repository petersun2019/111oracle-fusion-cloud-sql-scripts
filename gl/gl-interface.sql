/*
File Name: gl-interface.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- GL INTERFACE DETAILS 1
-- GL INTERFACE DETAILS 2
-- GL INTERFACE SUMMARY

*/

-- ##############################################################
-- GL INTERFACE DETAILS 1
-- ##############################################################

		select *
		  from gl_interface
		 where 1 = 1
		   -- and lower(reference1) like '%cheese%'
		   -- and gi.user_je_source_name = 'XX Cheese'
		   and group_id = 1234
		   and 1 = 1
	  order by last_update_date desc

-- ##############################################################
-- GL INTERFACE DETAILS 2
-- ##############################################################

		select '#' || gi.group_id group_id
			 , '#' || gi.ledger_id ledger_id
			 , '#' || gi.set_of_books_id set_of_books_id
			 , '#' || gi.gl_interface_id gl_interface_id
			 , gi.request_id
			 , to_char(gi.date_created, 'yyyy-mm-dd hh24:mi:ss') date_created
			 , gi.created_by
			 , to_char(gi.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , gi.last_updated_by
			 , to_char(gi.accounting_date, 'yyyy-mm-dd') gl_date
			 , gi.period_name period_name_table
			 -- , (select gps.period_name from gl.gl_period_statuses gps where gps.application_id = 101 and sysdate between gps.start_date and gps.end_date) period_name_calc
			 , gi.actual_flag
			 , gi.status
			 , gi.transaction_date
			 , decode(gi.actual_flag,'A','Actual','E','Encumbrance','Other') jnl_type
			 , gi.user_je_category_name category
			 , gi.user_je_source_name source
			 , gi.entered_dr
			 , gi.entered_cr
			 , gi.accounted_dr
			 , gi.accounted_cr
			 , '#' || gi.segment1 seg1
			 , '#' || gi.segment2 seg2
			 , '#' || gi.segment3 seg3
			 , '#' || gi.segment4 seg4
			 , '#' || gi.segment5 seg5
			 , '#' || gi.segment6 seg6
			 , '#' || gi.segment7 seg7
			 , '#' || gi.segment8 seg8
			 , gi.segment1 || '.' || gi.segment2 || '.' || gi.segment3 || '.' || gi.segment4 || '.' || gi.segment5 || '.' || gi.segment6 || '.' || gi.segment7 || '.' || gi.segment8 || '.' || gi.segment9 || '.' || gi.segment10 code_combination
			 , '#' || gcc.code_combination_id ccid
			 , gcc.enabled_flag enabled
			 , gcc.summary_flag summary
			 , gcc.detail_posting_allowed_flag posting_flag
			 , gcc.detail_budgeting_allowed_flag budget_flag
		  from gl_interface gi
	 left join gl_code_combinations gcc on gi.segment1 || '.' || gi.segment2 || '.' || gi.segment3 || '.' || gi.segment4 || '.' || gi.segment5 || '.' || gi.segment6 = gcc.segment1 || '.' || gcc.segment2 || '.' || gcc.segment3 || '.' || gcc.segment4 || '.' || gcc.segment5 || '.' || gcc.segment6
		 where 1 = 1
		   and 1 = 1
	  order by gi.date_created desc

-- ##############################################################
-- GL INTERFACE SUMMARY
-- ##############################################################

		select gl.name ledger
			 , gi.group_id
			 , gi.status
			 , gi.user_je_source_name
			 , gi.user_je_category_name
			 , gi.period_name
			 , to_char(gi.creation_date, 'yyyy-mm-dd hh24:mi') created
			 , gi.created_by
			 , gi.load_request_id
			 , min(gi.reference4) min_ref_4
			 , min(gi.reference5) min_ref_5
			 , min(gi.reference6) min_ref_6
			 , min(to_char(gi.accounting_date, 'yyyy-mm-dd')) min_acct_date
			 , sum(entered_dr) dr
			 , sum(entered_cr) cr
			 , count(*) line_count
		  from gl_interface gi
	 left join gl_ledgers gl on gl.ledger_id = gi.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by gl.name
			 , gi.group_id
			 , gi.status
			 , gi.user_je_source_name
			 , gi.user_je_category_name
			 , gi.period_name
			 , to_char(gi.creation_date, 'yyyy-mm-dd hh24:mi')
			 , gi.created_by
			 , gi.load_request_id
	  order by gl.name
			 , gi.group_id
			 , gi.status
			 , gi.user_je_source_name
			 , gi.user_je_category_name
			 , gi.period_name
			 , to_char(gi.creation_date, 'yyyy-mm-dd hh24:mi')
			 , gi.created_by
			 , gi.load_request_id
