/*
File Name: ar-memo-lines.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts
*/

-- ##############################################################
-- MEMO LINES
-- ##############################################################

		select '#' || amlab.memo_line_id memo_line_id
			 , amlat.name memo_line_name
			 , amlat.description memo_line_description
			 , amlab.line_type
			 , '#' || amlab.memo_line_seq_id memo_line_seq_id
			 , to_char(amlab.creation_date, 'yyyy-mm-dd hh24:mi:ss') created
			 , amlab.created_by
			 , to_char(amlab.effective_start_date, 'yyyy-mm-dd') effective_start_date
			 , to_char(amlab.effective_end_date, 'yyyy-mm-dd') effective_end_date
			 , amlab.tax_code
			 , amlab.uom_code
			 , amlab.unit_std_price
			 , org.name org
			 , sob.name sob
			 , gcc_rev.segment1 || '-' || gcc_rev.segment2 || '-' || gcc_rev.segment3 || '-' || gcc_rev.segment4 || '-' || gcc_rev.segment5 || '-' || gcc_rev.segment6 || '-' || gcc_rev.segment7 || '-' || gcc_rev.segment8 code_comb_rev
			 , gcc_rec.segment1 || '-' || gcc_rec.segment2 || '-' || gcc_rec.segment3 || '-' || gcc_rec.segment4 || '-' || gcc_rec.segment5 || '-' || gcc_rec.segment6 || '-' || gcc_rec.segment7 || '-' || gcc_rec.segment8 code_comb_rec
		  from ar_memo_lines_all_tl amlat
		  join ar_memo_lines_all_b amlab on amlat.memo_line_id = amlab.memo_line_id
	 left join ar_ref_accounts_all araa on araa.source_ref_account_id = amlab.memo_line_seq_id and araa.source_ref_table = 'AR_MEMO_LINES_ALL_B'
	 left join gl_code_combinations gcc_rev on gcc_rev.code_combination_id = araa.rev_ccid
	 left join gl_code_combinations gcc_rec on gcc_rec.code_combination_id = araa.rec_ccid
		  join fusion.hr_organization_units_f_tl org on org.organization_id = araa.bu_id
		  join fusion.gl_sets_of_books sob on sob.set_of_books_id = araa.ledger_id
		 where 1 = 1
		   and 1 = 1
