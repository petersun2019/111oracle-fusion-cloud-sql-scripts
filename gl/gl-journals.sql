/*
File Name: gl-journals.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- JOURNAL HEADERS - VERSION 1
-- JOURNAL HEADERS - VERSION 2
-- JOURNAL HEADERS - VERSION 3
-- JOURNAL HEADERS - VERSION 4 - WITH REVERSAL DATA
-- JOURNAL HEADERS - APPROVED BY
-- JOURNAL BATCHES AND HEADERS AND LINES WITH RECONCILIATION INFO
-- ACTUALS ATTEMPT
-- COUNT BY CURRENCY_CODE AND LEDGER
-- COUNT BY GROUP ID AND LEDGER
-- COUNT BY GROUP ID, LEDGER, SOURCE, CATEGORY, CREATED BY
-- COUNT BY LEDGER, SOURCE, CATEGORY
-- COUNT BY LEDGER, SOURCE, CATEGORY, CREATED BY
-- COUNT BY LEDGER, SOURCE, CREATED BY
-- COUNT BY SOURCES, CATEGORIES, LEDGERS AND PERIODS
-- COUNT BY SOURCES, LEDGERS AND PERIODS
-- COUNT BY SOURCES AND CATEGORIES
-- COUNT BY SOURCE 1
-- COUNT BY SOURCE 2
-- COUNT BY SOURCES 3
-- COUNT BY BATCH
-- COUNT BY BATCHES, HEADERS AND LINES
-- COUNT BY RECONCILIATION INFO

*/

-- ##############################################################
-- JOURNAL HEADERS - VERSION 1
-- ##############################################################

		select gl.name ledger
			 , gjb.group_id
			 , gjb.je_batch_id
			 , gjb.name batch_name
			 , to_char(gjb.creation_date, 'yyyy-mm-dd') batch_created1
			 , to_char(gjb.creation_date, 'yyyy-mm-dd hh24:mi:ss') batch_created
			 , gjb.created_by batch_created_by
			 , gjh.je_header_id
			 , gjh.name jnl_name
			 , (select count(*) from gl_je_lines gjl where gjh.je_header_id = gjl.je_header_id) lines
			 , to_char(gjh.creation_date, 'yyyy-mm-dd') journal_created1
			 , to_char(gjh.creation_date, 'yyyy-mm-dd hh24:mi:ss') journal_created
			 , gjh.created_by journal_created_by
			 , gjh.period_name period
			 , gjh.accrual_rev_period_name rev_period
			 , (replace(replace(gjh.description,chr(10),''),chr(13),' ')) jnl_description
			 , to_char(gjh.default_effective_date, 'yyyy-mm-dd') gl_date_header
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , decode(gjh.actual_flag,'A','Actual','E','Encumbrance','Other') jnl_type
			 , gjb_status.meaning batch_status
			 , gjh_status.meaning jnl_status
			 , gjb.request_id
			 , gjh.doc_sequence_value doc
			 , decode(gjb.approval_status_code, 'A', gl_journals_rpt_pkg.get_action_user(gjb.je_batch_id, 'APPROVED'), null) approved_by
			 , decode(gjb.approval_status_code, 'A', gl_journals_rpt_pkg.get_action_date(gjb.je_batch_id, 'APPROVED'), null) batch_approved_date
			 , gjb.running_total_dr batch_dr
			 , gjb.running_total_cr batch_cr
			 , gjh.running_total_cr jnl_cr
			 , gjh.running_total_dr jnl_dr
		  from gl_je_batches gjb
		  join gl_je_headers gjh on gjh.je_batch_id = gjb.je_batch_id
	 left join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
	 left join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
	 left join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
	 left join fnd_lookup_values_vl gjh_status on gjh_status.lookup_code = gjh.status and gjh_status.lookup_type = 'MJE_BATCH_STATUS' and gjh_status.view_application_id = 101
	 left join fnd_lookup_values_vl gjb_status on gjb_status.lookup_code = gjb.status and gjb_status.lookup_type = 'MJE_BATCH_STATUS' and gjb_status.view_application_id = 101
		 where 1 = 1
		   and 1 = 1
	  order by gjh.je_header_id desc

-- ##############################################################
-- JOURNAL HEADERS - VERSION 2
-- ##############################################################

		select gl.name ledger
			 , gjb.group_id group_id
			 , gjb.name batch_name
			 , (replace(replace(gjb.description,chr(10),''),chr(13),' ')) batch_description
			 , to_char(gjb.creation_date, 'yyyy-mm-dd hh24:mi:ss') batch_created
			 , to_char(gjb.posted_date, 'yyyy-mm-dd hh24:mi:ss') batch_posted
			 , gjb.created_by batch_created_by
			 , gjh.name jnl_name
			 , (replace(replace(gjh.description,chr(10),''),chr(13),' ')) jnl_description
			 , gjh.external_reference jnl_ref
			 , to_char(gjh.creation_date, 'yyyy-mm-dd hh24:mi:ss') journal_created
			 , gjh.created_by journal_created_by
			 , (select count(*) from gl_je_lines gjl where gjh.je_header_id = gjl.je_header_id) lines
			 , gjh.period_name period
			 , gjh.accrual_rev_period_name rev_period
			 , gjb.running_total_cr batch_cr
			 , gjb.running_total_dr batch_dr
			 , gjh.running_total_cr jnl_cr
			 , gjh.running_total_dr jnl_dr
			 , to_char(gjh.default_effective_date, 'yyyy-mm-dd') gl_date_header
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , decode(gjh.actual_flag,'A','Actual','E','Encumbrance','Other') jnl_type
			 , gjb.request_id
			 , gjb.status batch_status
			 , gjh.status jnl_status
		  from gl_je_batches gjb
		  join gl_je_headers gjh on gjh.je_batch_id = gjb.je_batch_id
	 left join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
	 left join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
	 left join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- JOURNAL HEADERS - VERSION 3
-- ##############################################################

		select gjb.je_batch_id
			 , gjb.name batch_name
			 , gjb.group_id
			 , to_char(gjb.creation_date, 'yyyy-mm-dd hh24:mi:ss') batch_created
			 , gjb.created_by batch_created_by
			 , gjb_status.meaning batch_status
			 , gjh.je_header_id je_header_id
			 , to_char(gjh.default_effective_date, 'yyyy-mm-dd') gl_date_header
			 , gjh.name jnl_name
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , gjh_status.meaning jnl_status
			 , gjb.running_total_cr batch_cr
			 , gjb.running_total_dr batch_dr
			 , gjh.running_total_cr jnl_cr
			 , gjh.running_total_dr jnl_dr
			 , (select count(*) from gl_je_lines gjl where gjl.je_header_id = gjh.je_header_id) line_count
		  from gl_je_batches gjb
		  join gl_je_headers gjh on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
		  join fnd_lookup_values_vl gjh_status on gjh_status.lookup_code = gjh.status and gjh_status.lookup_type = 'MJE_BATCH_STATUS' and gjh_status.view_application_id = 101
		  join fnd_lookup_values_vl gjb_status on gjb_status.lookup_code = gjb.status and gjb_status.lookup_type = 'MJE_BATCH_STATUS' and gjb_status.view_application_id = 101
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- JOURNAL HEADERS - VERSION 4 - WITH REVERSAL DATA
-- ##############################################################

		select gl.name ledger
			 , gjb.je_batch_id
			 , gjb.name batch_name
			 , gjb.group_id
			 , to_char(gjb.creation_date, 'yyyy-mm-dd hh24:mi:ss') batch_created
			 , gjb.created_by batch_created_by
			 , gjh.je_header_id
			 , gjh.accrual_rev_je_header_id jnl_id_of_reversal
			 , gjh.name jnl_name
			 , (select count(*) from gl_je_lines gjl where gjh.je_header_id = gjl.je_header_id) lines
			 , to_char(gjh.creation_date, 'yyyy-mm-dd') journal_created1
			 , to_char(gjh.creation_date, 'yyyy-mm-dd hh24:mi:ss') journal_created
			 , gjh.created_by journal_created_by
			 , gjh.period_name period
			 , gjh.accrual_rev_period_name rev_period
			 , (replace(replace(gjh.description,chr(10),''),chr(13),' ')) jnl_description
			 , to_char(gjh.default_effective_date, 'yyyy-mm-dd') gl_date_header
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , decode(gjh.actual_flag,'A','Actual','E','Encumbrance','Other') jnl_type
			 , gjb_status.meaning batch_status
			 , gjh_status.meaning jnl_status
			 , gjb.request_id
			 , gjh.doc_sequence_value doc
			 , decode(gjb.approval_status_code, 'A', gl_journals_rpt_pkg.get_action_user(gjb.je_batch_id, 'APPROVED'), null) approved_by
			 , decode(gjb.approval_status_code, 'A', gl_journals_rpt_pkg.get_action_date(gjb.je_batch_id, 'APPROVED'), null) batch_approved_date
			 , gjb.running_total_cr batch_cr
			 , gjb.running_total_dr batch_dr
			 , gjh.running_total_cr jnl_cr
			 , gjh.running_total_dr jnl_dr
			 , '#' rev___
			 , gjh_rev.je_header_id rev_jnl_id
			 , gjh_rev.reversed_je_header_id parent_id
			 , gjh_rev.name rev_journal
			 , gjh_rev_status.meaning rev_journal_status
			 , gjh_rev.period_name rev_journal_period
			 , to_char(gjh_rev.creation_date, 'yyyy-mm-dd hh24:mi:ss') rev_created
			 , gjh_rev.created_by reversal_created_by
			 , gjb_rev.name rev_batch
			 , gjb_rev_status.meaning rev_batch_status
		  from gl_je_batches gjb
		  join gl_je_headers gjh on gjh.je_batch_id = gjb.je_batch_id
		  join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
	 left join gl_je_headers gjh_rev on gjh_rev.reversed_je_header_id = gjh.je_header_id
	 left join gl_je_batches gjb_rev on gjh_rev.je_batch_id = gjb_rev.je_batch_id
	 left join fnd_lookup_values_vl gjh_status on gjh_status.lookup_code = gjh.status and gjh_status.lookup_type = 'MJE_BATCH_STATUS' and gjh_status.view_application_id = 101
	 left join fnd_lookup_values_vl gjb_status on gjb_status.lookup_code = gjb.status and gjb_status.lookup_type = 'MJE_BATCH_STATUS' and gjb_status.view_application_id = 101
	 left join fnd_lookup_values_vl gjh_rev_status on gjh_rev_status.lookup_code = gjh_rev.status and gjh_rev_status.lookup_type = 'MJE_BATCH_STATUS' and gjh_rev_status.view_application_id = 101
	 left join fnd_lookup_values_vl gjb_rev_status on gjb_rev_status.lookup_code = gjb_rev.status and gjb_rev_status.lookup_type = 'MJE_BATCH_STATUS' and gjb_rev_status.view_application_id = 101
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- JOURNAL HEADERS - APPROVED BY
-- ##############################################################

/*
https://rpforacle.blogspot.com/2020/08/sql-query-to-get-journal-approver-in-oracle-fusion.html
*/

		select gjh.name
			 , gjh.je_source
			 , gjh.je_category
			 , gjh.je_header_id "je_reference"
			 , to_char(gjb.creation_date, 'yyyy-mm-dd hh24:mi:ss') batch_created
			 , gjb.created_by batch_created_by
			 , gjh.period_name
			 , gjb.description "batch_desc"
			 , gjh.description "header_desc"
			 , gjh.running_total_cr jnl_cr
			 , gjh.running_total_dr jnl_dr
			 , decode(gjb.approval_status_code, 'A', gl_journals_rpt_pkg.get_action_user(gjb.je_batch_id, 'APPROVED'), null) approved_by
			 , decode(gjb.approval_status_code, 'A', gl_journals_rpt_pkg.get_action_date(gjb.je_batch_id, 'APPROVED'), null) batch_approved_date
		  from gl_je_headers gjh
		  join gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
		 where 1 = 1
	  order by gjh.je_header_id desc

-- ##############################################################
-- JOURNAL BATCHES AND HEADERS AND LINES WITH RECONCILIATION INFO
-- ##############################################################

		select gl.name ledger
			 , gjb.group_id
			 , gjb.je_batch_id
			 , gjb.name batch_name
			 , to_char(gjb.creation_date, 'yyyy-mm-dd') batch_created1
			 , to_char(gjb.creation_date, 'yyyy-mm-dd hh24:mi:ss') batch_created
			 , gjb.created_by batch_created_by
			 , gjh.je_header_id
			 , gjh.parent_je_header_id
			 , gjh.accrual_rev_je_header_id
			 , nvl(gjh.reversed_je_header_id, null) reversed_je_header_id
			 , to_char(gjh.creation_date, 'yyyy-mm-dd') journal_created1
			 , to_char(gjh.creation_date, 'yyyy-mm-dd hh24:mi:ss') journal_created
			 , gjh.created_by journal_created_by
			 , gjh.period_name period
			 , to_char(gp.start_date, 'yyyy-mm-dd') period_start
			 , to_char(gp.end_date, 'yyyy-mm-dd') period_end
			 , gjh.accrual_rev_period_name rev_period
			 , gjh.name journal
			 , gjb.running_total_cr batch_cr
			 , gjb.running_total_dr batch_dr
			 , gjh.running_total_cr jnl_cr
			 , gjh.running_total_dr jnl_dr
			 , to_char(gjh.default_effective_date, 'yyyy-mm-dd') gl_date_header
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , decode(gjh.actual_flag,'A','Actual','E','Encumbrance','Other') jnl_type
			 , gjl.je_line_num line
			 , gjl.accounted_dr dr
			 , gjl.accounted_cr cr
			 , gcc.segment1 || '.' || gcc.segment2 || '.' || gcc.segment3 || '.' || gcc.segment4 || '.' || gcc.segment5 || '.' || gcc.segment6 cgh_acct
			 , to_char(gjl.effective_date, 'yyyy-mm-dd') gl_date_line
			 , gjlr.jgzz_recon_status
			 , gjlr.jgzz_recon_ref
		  from gl_je_batches gjb
		  join gl_je_headers gjh on gjh.je_batch_id = gjb.je_batch_id
		  join gl_periods gp on gjh.period_name = gp.period_name
	 left join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
	 left join gl_code_combinations gcc on gjl.code_combination_id = gcc.code_combination_id
	 left join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
	 left join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
	 left join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
	 left join fnd_lookup_values_vl gjh_status on gjh_status.lookup_code = gjh.status and gjh_status.lookup_type = 'MJE_BATCH_STATUS' and gjh_status.view_application_id = 101
	 left join fnd_lookup_values_vl gjb_status on gjb_status.lookup_code = gjb.status and gjb_status.lookup_type = 'MJE_BATCH_STATUS' and gjb_status.view_application_id = 101
	 left join gl_je_lines_recon gjlr on gjlr.je_header_id = gjh.je_header_id and gjlr.je_line_num = gjl.je_line_num
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- ACTUALS ATTEMPT
-- ##############################################################

		select gjh.period_name period
			 , gcc.segment1
			 , gcc.segment2
			 , gl_flexfields_pkg.get_description_sql(3001, 1, gcc.segment1) seg1_descr
			 , gl_flexfields_pkg.get_description_sql(3001, 2, gcc.segment2) seg2_descr
			 , nvl(sum(gjl.accounted_dr),0) - nvl(sum(gjl.accounted_cr),0) actual
		  from gl_je_headers gjh
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_code_combinations gcc on gjl.code_combination_id = gcc.code_combination_id
		 where 1 = 1
		   and 1 = 1
	  group by gjh.period_name
			 , gcc.segment1
			 , gcc.segment2
			 , gl_flexfields_pkg.get_description_sql(3001, 1, gcc.segment1)
			 , gl_flexfields_pkg.get_description_sql(3001, 2, gcc.segment2)

-- ##############################################################
-- COUNT BY CURRENCY_CODE AND LEDGER
-- ##############################################################

		select gl.name ledger
			 , gjh.currency_code
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd')) min_gjh_cr_date
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd')) max_gjh_cr_date
			 , min(gjb.request_id)
			 , max(gjb.request_id)
			 , count(distinct gjb.je_batch_id) jnl_batch_count
			 , count(distinct gjh.je_header_id) jnl_header_count
			 , count(*) ct
		  from gl_je_batches gjb
		  join gl_je_headers gjh on gjh.je_batch_id = gjb.je_batch_id
	 left join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
	 left join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by gl.name
			 , gjh.currency_code

-- ##############################################################
-- COUNT BY GROUP ID AND LEDGER
-- ##############################################################

		select gl.name ledger
			 , gjb.group_id
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd')) min_gjh_cr_date
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd')) max_gjh_cr_date
			 , min(gjb.request_id)
			 , max(gjb.request_id)
			 , count(distinct gjb.je_batch_id) jnl_batch_count
			 , count(distinct gjh.je_header_id) jnl_header_count
			 , count(*) ct
		  from gl_je_batches gjb
		  join gl_je_headers gjh on gjh.je_batch_id = gjb.je_batch_id
	 left join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
	 left join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by gl.name
			 , gjb.group_id

-- ##############################################################
-- COUNT BY GROUP ID, LEDGER, SOURCE, CATEGORY, CREATED BY
-- ##############################################################

		select gl.name ledger
			 , gjb.group_id
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , gjh.created_by
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd')) min_gjh_cr_date
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd')) max_gjh_cr_date
			 , min(gjb.request_id)
			 , max(gjb.request_id)
			 , count(distinct gjb.je_batch_id) jnl_batch_count
			 , count(distinct gjh.je_header_id) jnl_header_count
			 , count(*) ct
		  from gl_je_batches gjb
		  join gl_je_headers gjh on gjh.je_batch_id = gjb.je_batch_id
		  join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by gl.name
			 , gjb.group_id
			 , gjst.user_je_source_name
			 , gjct.user_je_category_name
			 , gjh.created_by

-- ##############################################################
-- COUNT BY LEDGER, SOURCE, CATEGORY
-- ##############################################################

		select gl.name ledger
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd')) min_gjh_cr_date
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd')) max_gjh_cr_date
			 , min(gjb.request_id)
			 , max(gjb.request_id)
			 , count(distinct gjb.je_batch_id) jnl_batch_count
			 , count(distinct gjh.je_header_id) jnl_header_count
			 , count(*) ct
		  from gl_je_batches gjb
		  join gl_je_headers gjh on gjh.je_batch_id = gjb.je_batch_id
		  join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by gl.name
			 , gjst.user_je_source_name
			 , gjct.user_je_category_name

-- ##############################################################
-- COUNT BY LEDGER, SOURCE, CATEGORY, CREATED BY
-- ##############################################################

		select gl.name ledger
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , gjh.created_by
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd')) min_gjh_cr_date
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd')) max_gjh_cr_date
			 , min(gjb.request_id)
			 , max(gjb.request_id)
			 , count(distinct gjb.je_batch_id) jnl_batch_count
			 , count(distinct gjh.je_header_id) jnl_header_count
			 , count(*) jnl_line_count
		  from gl_je_batches gjb
		  join gl_je_headers gjh on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_code_combinations gcc on gjl.code_combination_id = gcc.code_combination_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
		  join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by gl.name
			 , gjst.user_je_source_name
			 , gjct.user_je_category_name
			 , gjh.created_by

-- ##############################################################
-- COUNT BY LEDGER, SOURCE, CREATED BY
-- ##############################################################

		select gl.name ledger
			 , gjst.user_je_source_name source
			 , gjh.created_by
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_gjh_cr_date
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_gjh_cr_date
			 , min(gjb.request_id)
			 , max(gjb.request_id)
			 , count(distinct gjb.je_batch_id) jnl_batch_count
			 , count(distinct gjh.je_header_id) jnl_header_count
			 , count(*) jnl_line_count
		  from gl_je_batches gjb
		  join gl_je_headers gjh on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_code_combinations gcc on gjl.code_combination_id = gcc.code_combination_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by gl.name
			 , gjst.user_je_source_name
			 , gjh.created_by

-- ##############################################################
-- COUNT BY SOURCES, CATEGORIES, LEDGERS AND PERIODS
-- ##############################################################

		select gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , gl.name
			 , gjh.period_name
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd')) min_gjh_cr_date
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd')) max_gjh_cr_date
			 , min(gjh.created_by) min_gjh_created_byt
			 , max(gjh.created_by) max_gjh_created_byt
			 , count(*)
		  from gl_je_batches gjb
		  join gl_je_headers gjh on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
	 left join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by gjst.user_je_source_name
			 , gjct.user_je_category_name
			 , gl.name
			 , gjh.period_name

-- ##############################################################
-- COUNT BY SOURCES, LEDGERS AND PERIODS
-- ##############################################################

		select gjst.user_je_source_name source
			 , gl.name
			 , gjh.period_name
			 , gjb.status batch_status
			 , gjh.status jnl_status
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd')) min_gjh_cr_date
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd')) max_gjh_cr_date
			 , min(gjh.created_by) min_gjh_created_byt
			 , max(gjh.created_by) max_gjh_created_byt
			 , count(*)
		  from gl_je_batches gjb
		  join gl_je_headers gjh on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
	 left join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by gjst.user_je_source_name
			 , gl.name
			 , gjh.period_name
			 , gjb.status
			 , gjh.status

-- ##############################################################
-- COUNT BY SOURCES AND CATEGORIES
-- ##############################################################

		SELECT gjsb.je_source_key
			 , gjcb.je_category_key
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd')) min_gjh_cr_date
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd')) max_gjh_cr_date
			 , count(*)
		  FROM gl_je_batches gjb
			 , gl_je_sources_b gjsb
			 , gl_je_categories_b gjcb
			 , gl_je_headers gjh
		 WHERE 1 = 1
		   AND gjsb.je_source_name = gjb.je_source
		   AND gjcb.je_category_name = gjh.je_category
		   AND gjb.group_id IS NOT NULL
		   AND gjb.je_batch_id = gjh.je_batch_id
	  group by gjsb.je_source_key
			 , gjcb.je_category_key

-- ##############################################################
-- COUNT BY SOURCE 1
-- ##############################################################

		select gjst.user_je_source_name source
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_gjh_cr_date
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_gjh_cr_date
			 , min(gjb.request_id)
			 , max(gjb.request_id)
			 , count(distinct gjb.je_batch_id) jnl_batch_count
			 , count(distinct gjh.je_header_id) jnl_header_count
		  from gl_je_batches gjb
		  join gl_je_headers gjh on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by gjst.user_je_source_name

-- ##############################################################
-- COUNT BY SOURCE 2
-- ##############################################################

		select gl.name ledger
			 , gjh.period_name period
			 , to_char(gjb.creation_date, 'yyyy-mm-dd') batch_created
			 , gjb.created_by batch_created_by
			 , gjst.user_je_source_name source
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd')) min_gjh_cr_date
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd')) max_gjh_cr_date		
			 , count(*)
		  from gl_je_batches gjb
		  join gl_je_headers gjh on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by gl.name
			 , gjh.period_name
			 , to_char(gjb.creation_date, 'yyyy-mm-dd')
			 , gjb.created_by
			 , gjst.user_je_source_name

-- ##############################################################
-- COUNT BY SOURCES 3
-- ##############################################################

		select gjst.user_je_source_name source
			 , gl.name ledger
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_created
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_created
			 , count(distinct gjh.je_header_id) journal_count
			 , count(*) journal_lines_count
		  from gl_je_sources_tl gjst
		  join gl_je_headers gjh on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
	  group by gjst.user_je_source_name
			 , gl.name

-- ##############################################################
-- COUNT BY BATCH
-- ##############################################################

		select gl.name ledger
			 , gjb.je_batch_id
			 , gjb.name batch_name
			 , gjb.group_id
			 , to_char(gjb.creation_date, 'yyyy-mm-dd hh24:mi:ss') batch_created
			 , gjb.created_by batch_created_by
			 , abs(gjb.running_total_cr) batch_cr
			 , gjb.request_id
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd')) min_gjh_cr_date
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd')) max_gjh_cr_date		
			 , count(*)
		  from gl_je_batches gjb
		  join gl_je_headers gjh on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
		  join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by gl.name
			 , gjb.je_batch_id
			 , gjb.name
			 , gjb.group_id
			 , to_char(gjb.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , gjb.created_by
			 , abs(gjb.running_total_cr)
			 , gjb.request_id
			 , gjst.user_je_source_name
			 , gjct.user_je_category_name

-- ##############################################################
-- COUNT BY BATCHES, HEADERS AND LINES
-- ##############################################################

		select gl.name ledger
			 , gjb.group_id
			 , gjb.je_batch_id
			 , gjb.name batch_name
			 , to_char(gjb.creation_date, 'yyyy-mm-dd hh24:mi:ss') batch_created
			 , gjb.created_by batch_created_by
			 , gjh.je_header_id
			 , to_char(gjh.creation_date, 'yyyy-mm-dd') journal_created1
			 , to_char(gjh.creation_date, 'yyyy-mm-dd hh24:mi:ss') journal_created
			 , gjh.created_by journal_created_by
			 , gjh.period_name period
			 , to_char(gp.start_date, 'yyyy-mm-dd') period_start
			 , to_char(gp.end_date, 'yyyy-mm-dd') period_end
			 , gjh.accrual_rev_period_name rev_period
			 , gjh.name journal
			 , to_char(gjh.default_effective_date, 'yyyy-mm-dd') gl_date_header
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , decode(gjh.actual_flag,'A','Actual','E','Encumbrance','Other') jnl_type
			 , gjb_status.meaning batch_status
			 , gjh_status.meaning jnl_status
			 , gjb.request_id
			 , gjb.running_total_cr batch_cr
			 , gjb.running_total_dr batch_dr
			 , gjh.running_total_cr jnl_cr
			 , gjh.running_total_dr jnl_dr
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd')) min_gjh_cr_date
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd')) max_gjh_cr_date		
			 , sum(gjl.accounted_dr) dr
			 , sum(gjl.accounted_cr) cr
			 , count(*) line_ct
		  from gl_je_batches gjb
		  join gl_je_headers gjh on gjh.je_batch_id = gjb.je_batch_id
		  join gl_periods gp on gjh.period_name = gp.period_name
	 left join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
	 left join gl_code_combinations gcc on gjl.code_combination_id = gcc.code_combination_id
	 left join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
	 left join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
	 left join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
	 left join fnd_lookup_values_vl gjh_status on gjh_status.lookup_code = gjh.status and gjh_status.lookup_type = 'MJE_BATCH_STATUS' and gjh_status.view_application_id = 101
	 left join fnd_lookup_values_vl gjb_status on gjb_status.lookup_code = gjb.status and gjb_status.lookup_type = 'MJE_BATCH_STATUS' and gjb_status.view_application_id = 101
		 where 1 = 1
		   and 1 = 1
	  group by gl.name
			 , gjb.group_id
			 , gjb.je_batch_id
			 , gjb.name
			 , to_char(gjb.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , gjb.created_by
			 , gjh.je_header_id
			 , to_char(gjh.creation_date, 'yyyy-mm-dd')
			 , to_char(gjh.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , gjh.created_by
			 , gjh.period_name
			 , to_char(gp.start_date, 'yyyy-mm-dd')
			 , to_char(gp.end_date, 'yyyy-mm-dd')
			 , gjh.accrual_rev_period_name
			 , gjh.name
			 , to_char(gjh.default_effective_date, 'yyyy-mm-dd')
			 , gjst.user_je_source_name
			 , gjct.user_je_category_name
			 , decode(gjh.actual_flag,'A','Actual','E','Encumbrance','Other')
			 , gjb_status.meaning
			 , gjh_status.meaning
			 , gjb.request_id
			 , gjb.running_total_cr
			 , gjb.running_total_dr
			 , gjh.running_total_cr
			 , gjh.running_total_dr

-- ##############################################################
-- COUNT BY RECONCILIATION INFO
-- ##############################################################

		select gl.name ledger
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , gjh.period_name period
			 , gjlr.jgzz_recon_status
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd')) min_gjh_cr_date
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd')) max_gjh_cr_date			 
			 , count(*) ct
		  from gl_je_batches gjb
		  join gl_je_headers gjh on gjh.je_batch_id = gjb.je_batch_id
		  join gl_periods gp on gjh.period_name = gp.period_name
	 left join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
	 left join gl_code_combinations gcc on gjl.code_combination_id = gcc.code_combination_id
	 left join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
	 left join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
	 left join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
	 left join fnd_lookup_values_vl gjh_status on gjh_status.lookup_code = gjh.status and gjh_status.lookup_type = 'MJE_BATCH_STATUS' and gjh_status.view_application_id = 101
	 left join fnd_lookup_values_vl gjb_status on gjb_status.lookup_code = gjb.status and gjb_status.lookup_type = 'MJE_BATCH_STATUS' and gjb_status.view_application_id = 101
	 left join gl_je_lines_recon gjlr on gjlr.je_header_id = gjh.je_header_id and gjlr.je_line_num = gjl.je_line_num
		 where 1 = 1
		   and 1 = 1
	  group by gl.name
			 , gjst.user_je_source_name
			 , gjct.user_je_category_name
			 , gjh.period_name
			 , gjlr.jgzz_recon_status
			 , gjlr.jgzz_recon_ref
