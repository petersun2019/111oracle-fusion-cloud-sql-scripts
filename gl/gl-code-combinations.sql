/*
File Name: gl-code-combinations.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- GL CODE COMBINATIONS VERSION 1
-- GL CODE COMBINATIONS VERSION 2
-- GL CODE COMBINATIONS SUMMARY

*/

-- ###############################################################
-- GL CODE COMBINATIONS VERSION 1
-- ###############################################################

		select '#' || gcc.code_combination_id ccid
			 , '#' || gcc.chart_of_accounts_id chart_of_accounts_id
			 , '#' || gcc.segment1 seg1
			 , '#' || gcc.segment2 seg2
			 , '#' || gcc.segment3 seg3
			 , '#' || gcc.segment4 seg4
			 , '#' || gcc.segment5 seg5
			 , '#' || gcc.segment6 seg6
			 , '#' || gcc.segment7 seg7
			 , '#' || gcc.segment8 seg8
			 , gcc.segment1 || '-' || gcc.segment2 || '-' || gcc.segment3 || '-' || gcc.segment4 || '-' || gcc.segment5 || '-' || gcc.segment6 || '-' || gcc.segment7 || '-' || gcc.segment8 code_comb
			 , flv_acct_type.meaning acct_type
			 , gcc.enabled_flag enabled
			 , gcc.summary_flag summary
			 , gcc.detail_posting_allowed_flag posting_flag
			 , gcc.detail_budgeting_allowed_flag budget_flag
			 , gcc.jgzz_recon_flag reconcil_flag
			 , gcc.preserve_flag
			 , flv_fin_cat.meaning financial_category
			 -- , '#' descriptions___
			 -- , gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id, 1, gcc.segment1) seg1_descr
			 -- , gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id, 2, gcc.segment2) seg2_descr
			 -- , gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id, 3, gcc.segment3) seg3_descr
			 -- , gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id, 4, gcc.segment4) seg4_descr
			 -- , gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id, 5, gcc.segment5) seg5_descr
			 -- , gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id, 6, gcc.segment6) seg6_descr
			 -- , gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id, 7, gcc.segment7) seg7_descr
			 -- , gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id, 8, gcc.segment8) seg8_descr
			 , '#' who___
			 , to_char(gcc.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , gcc.created_by
			 , to_char(gcc.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , gcc.last_updated_by
			 -- , '#' counts___
			 -- , (select count(*) from gl_je_lines gjl where gjl.code_combination_id = gcc.code_combination_id) jnl_line_count
			 -- , (select count(*) from gl_balances gb where gb.code_combination_id = gcc.code_combination_id) balances_line_count
			 -- , (select count(*) from ap_invoice_distributions_all aida where aida.dist_code_combination_id = gcc.code_combination_id) ap_inv_dist_line_count
			 -- , (select count(*) from po_distributions_all pda where pda.code_combination_id = gcc.code_combination_id) po_dist_line_count
			 -- , (select count(*) from ra_cust_trx_line_gl_dist_all rctlgda where rctlgda.code_combination_id = gcc.code_combination_id) ar_dist_line_count
		  from gl_code_combinations gcc
	 left join fnd_lookup_values_vl flv_acct_type on gcc.account_type = flv_acct_type.lookup_code and flv_acct_type.lookup_type = 'ACCOUNT TYPE' and flv_acct_type.view_application_id = 101
	 left join fnd_lookup_values_vl flv_fin_cat on gcc.financial_category = flv_fin_cat.lookup_code and flv_fin_cat.lookup_type = 'FINANCIAL_CATEGORY' and flv_fin_cat.view_application_id = 0
		 where 1 = 1
		   and 1 = 1

-- ###############################################################
-- GL CODE COMBINATIONS VERSION 2
-- ###############################################################

/*
Can get messy with ledgers etc. because as some organisations can have two legal entities in gl_ledger_le_v linked to the same ledger ID so get duplicates
*/

		select '#' || gcc.code_combination_id ccid
			 , gllv.legal_entity_name
			 , gllv.ledger_name
			 , to_char(gcc.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , gcc.created_by
			 , to_char(gcc.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , gcc.last_updated_by
			 , '#' || gcc.segment1 seg1
			 , '#' || gcc.segment2 seg2
			 , '#' || gcc.segment3 seg3
			 , '#' || gcc.segment4 seg4
			 , '#' || gcc.segment5 seg5
			 , '#' || gcc.segment6 seg6
			 , '#' || gcc.segment7 seg7
			 , '#' || gcc.segment8 seg8
			 , gcc.segment1 || '-' || gcc.segment2 || '-' || gcc.segment3 || '-' || gcc.segment4 || '-' || gcc.segment5 || '-' || gcc.segment6 || '-' || gcc.segment7 || '-' || gcc.segment8 code_comb
			 , flv.meaning acct_type
			 , gcc.enabled_flag enabled
			 , gcc.summary_flag summary
			 , gcc.detail_posting_allowed_flag posting_flag
			 , gcc.detail_budgeting_allowed_flag budget_flag
			 , gcc.jgzz_recon_flag reconcil_flag
			 , gcc.preserve_flag
			 , gcc.financial_category
			 , '#' descriptions___
			 , gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id, 1, gcc.segment1) seg1_descr
			 , gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id, 2, gcc.segment2) seg2_descr
			 , gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id, 3, gcc.segment3) seg3_descr
			 , gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id, 4, gcc.segment4) seg4_descr
			 , gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id, 5, gcc.segment5) seg5_descr
			 , gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id, 6, gcc.segment5) seg6_descr
			 , gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id, 7, gcc.segment5) seg7_descr
			 , gl_flexfields_pkg.get_description_sql(gcc.chart_of_accounts_id, 8, gcc.segment5) seg8_descr
		  from gl_code_combinations gcc
		  join gl_ledger_le_v gllv on gllv.chart_of_accounts_id = gcc.chart_of_accounts_id and gllv.ledger_id = gllv.primary_ledger_id -- gllv.ledger_id = gllv.primary_ledger_id required to remove duplicates where there is more than one legal entity linked to the same ledger id
	 left join fnd_lookup_values_vl flv on gcc.account_type = flv.lookup_code and flv.lookup_type = 'ACCOUNT TYPE' and flv.view_application_id = 101
		 where 1 = 1
		   and 1 = 1
	  order by gcc.creation_date desc

-- ###############################################################
-- GL CODE COMBINATIONS SUMMARY
-- ###############################################################

		select gllv.legal_entity_name
			 , gllv.ledger_name
			 , gcc.segment6
			 , min(gcc.created_by)
			 , max(gcc.created_by)
			 , count(*)
		  from gl_code_combinations gcc
		  join fnd_lookup_values_vl flv on gcc.account_type = flv.lookup_code and flv.lookup_type = 'ACCOUNT TYPE' and flv.view_application_id = 101
		  join gl_ledger_le_v gllv on gllv.chart_of_accounts_id = gcc.chart_of_accounts_id
		 where 1 = 1
		   and gcc.segment6 in ('AA1','AA3','AA5')
		   and 1 = 1
	  group by gllv.legal_entity_name
			 , gllv.ledger_name
			 , gcc.segment6
