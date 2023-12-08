/*
File Name: fun.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- INTERCOMPANY TABLE DUMPS
-- INTERCOMPANY BATCHES, HEADERS, LINES AND DISTRIBUTIONS
-- INTERCOMPANY BALANCING RULES
-- FUN_BAL_INTER_ACCOUNTS_ADDL

https://docs.oracle.com/en/cloud/saas/financials/22d/oedmf/funinerroractions-25587.html#funinerroractions-25587
*/

-- ##############################################################
-- INTERCOMPANY TABLE DUMPS
-- ##############################################################

select * from fun_trx_batches order by creation_date desc
select * from fun_trx_headers order by creation_date desc
select * from fun_trx_lines order by creation_date desc

-- ##############################################################
-- INTERCOMPANY BATCHES, HEADERS, LINES AND DISTRIBUTIONS
-- ##############################################################

		select ftb.batch_id batch_id
			 , ftb.batch_number
			 , ftb.original_batch_id
			 , ftb.reversed_batch_id
			 , to_char(ftb.creation_date, 'yyyy-mm-dd hh24:mi:ss') batch_created
			 , to_char(ftb.gl_date, 'yyyy-mm-dd') batch_gl_date
			 , to_char(ftb.batch_date, 'yyyy-mm-dd') batch_date
			 , ftb.created_by batch_created_by
			 , ftb.status batch_status
			 , ftb.description batch_description
			 , ftb.note batch_note
			 , ftb.from_le_id
			 , ftb.from_ledger_id
			 , ftb.control_total
			 , ftb.running_total_dr
			 , ftb.running_total_cr
			 , ftb.reject_allow_flag
			 , '#' header_______
			 , fth.trx_id
			 , fth.to_le_id
			 , fth.to_ledger_id
			 , fth.status header_status
			 , fth.init_amount_dr
			 , fth.reci_amount_cr
			 , fth.ar_invoice_number
			 , fth.invoice_flag
			 , fth.approver_id
			 , fth.description hdr_descr
			 , fth.attribute1
			 , fth.attribute2
			 , (replace(replace(fth.error_reason,chr(10),' - '),chr(13),' # ')) error_reason
			 , to_char(fth.approval_date, 'yyyy-mm-dd') approval_date
			 , to_char(fth.creation_date, 'yyyy-mm-dd hh24:mi:ss') hdr_created
			 , fth.created_by hdr_created_by
			 , fth.ar_inv_cm_trx_type_id
			 , '#' lines_______
			 , ftl.line_id
			 , ftl.init_amount_dr line_init_amount_dr
			 , ftl.init_amount_cr line_init_amount_cr
			 , to_char(ftl.creation_date, 'yyyy-mm-dd hh24:mi:ss') line_created
			 , ftl.created_by line_created_by
			 , ftl.line_number
			 , ftl.line_type_flag
			 , '#' dists_______
			 , fdl.dist_id
			 , fdl.dist_number
			 , fdl.party_type_flag
			 , fdl.dist_type_flag
			 , fdl.amount_dr
			 , fdl.amount_cr
			 , '#' || gcc.segment1 seg1
			 , '#' || gcc.segment2 seg2
			 , '#' || gcc.segment3 seg3
			 , '#' || gcc.segment4 seg4
			 , '#' || gcc.segment5 seg5
			 , '#' || gcc.segment6 seg6
			 , '#' || gcc.segment7 seg7
			 , '#' || gcc.segment8 seg8
			 , gcc.segment1 || '-' || gcc.segment2 || '-' || gcc.segment3 || '-' || gcc.segment4 || '-' || gcc.segment5 || '-' || gcc.segment6 || '-' || gcc.segment7 || '-' || gcc.segment8 code_comb
			 , hp.party_name
			 , (replace(replace(fdl.description,chr(10),' - '),chr(13),' # ')) distrib_description
		  from fun_trx_batches ftb
	 left join fun_trx_headers fth on ftb.batch_id = fth.batch_id
	 left join fun_trx_lines ftl on ftl.trx_id = fth.trx_id
	 left join fun_dist_lines fdl on fdl.line_id = ftl.line_id and fdl.trx_id = fth.trx_id
	 left join gl_code_combinations gcc on gcc.code_combination_id = fdl.ccid
	 left join hz_parties hp on hp.party_id = fdl.party_id
		 where 1 = 1
		   and 1 = 1
	  order by ftb.creation_date desc

-- ##############################################################
-- INTERCOMPANY BALANCING RULES
-- ##############################################################

select * from fun_bal_inter_rules

-- ##############################################################
-- FUN_BAL_INTER_ACCOUNTS_ADDL
-- ##############################################################

/*
FUN_BAL_INTER_ACCOUNTS_ADDL:
Intercompany accounts code combinations table for reconciliation report.
*/
		select fbiaa.type
			 , to_char(fbiaa.start_date, 'yyyy-mm-dd') start_date
			 , to_char(fbiaa.end_date, 'yyyy-mm-dd') end_date
			 , to_char(fbiaa.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , fbiaa.created_by
			 , to_char(fbiaa.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , fbiaa.last_updated_by
			 , fbiaa.object_version_number
			 , gl_from.name from_ledger
			 , gl_to.name to_ledger
			 , xep_from.name from_legal_entity
			 , xep_to.name to_legal_entity
			 , gcc.segment1 || '-' || gcc.segment2 || '-' || gcc.segment3 || '-' || gcc.segment4 || '-' || gcc.segment5 || '-' || gcc.segment6 || '-' || gcc.segment7 || '-' || gcc.segment8 code_comb
		  from fun_bal_inter_accounts_addl fbiaa
	 left join gl_ledgers gl_from on fbiaa.from_ledger_id = gl_from.ledger_id
	 left join gl_ledgers gl_to on fbiaa.to_ledger_id = gl_to.ledger_id
	 left join xle_entity_profiles xep_from on xep_from.legal_entity_id = fbiaa.from_le_id
	 left join xle_entity_profiles xep_to on xep_to.legal_entity_id = fbiaa.to_le_id
	 left join gl_code_combinations gcc on gcc.code_combination_id = fbiaa.ccid
