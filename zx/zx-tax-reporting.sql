/*
File Name: zx-tax-reporting.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- TABLE DUMPS
-- VAT REPORTING DETAILS
-- SQL FROM SR
-- ZX_DIST_TAX_BOX_ASSGNMNTS
-- JE_ZZ_VAT_REP_TRX_T - VERSION 1
-- JE_ZZ_VAT_REP_TRX_T - VERSION 2 (SMALLER VERSION)
-- JG_ZZ_VAT_TRX_DETAILS - VERSION 1
-- JG_ZZ_VAT_TRX_DETAILS - VERSION 2

*/

-- ##################################################################
-- TABLE DUMPS
-- ##################################################################

select * from jg_zz_vat_rep_status order by creation_date desc
select * from jg_zz_vat_final_reports order by creation_date desc
select * from je_zz_vat_rep_trx_t order by creation_date desc

-- ##################################################################
-- VAT REPORTING DETAILS 1
-- ##################################################################

		select p.reporting_status_id
			 , r.final_report_id
			 , p.source
			 , trx_src.meaning input_output
			 , p.tax_registration_number tax_registration_number
			 -- , p.vat_reporting_entity_id
			 , e.entity_identifier
			 , hp.party_name
			 , p.tax_calendar_year
			 , p.tax_calendar_name
			 , p.tax_calendar_period
			 , p.selection_status_flag
			 , to_char(p.selection_process_date,'dd/mm/yyyy') as selection_process_date
			 , p.allocation_status_flag
			 , to_char(p.allocation_process_date,'dd/mm/yyyy') as allocation_process_date
			 , p.final_reporting_status_flag
			 , to_char(p.final_reporting_process_date,'dd/mm/yyyy') as final_reporting_process_date
			 , p.final_reporting_process_id
			 , p.request_id finalize_tax_process_id
			 , r.request_id final_tax_box_return_process_id
			 , to_char(p.period_start_date,'dd/mm/yyyy') as period_start_date
			 , to_char(p.period_end_date,'dd/mm/yyyy') as period_end_date
			 , to_char(p.last_update_date,'dd/mm/yyyy') as last_update_date
			 , to_char(p.last_update_date,'dd/mm/yyyy hh24:mi:ss') as last_update_date2
			 -- , p.mapping_vat_rep_entity_id
			 , p.credit_balance_amt
			 , to_char(p.creation_date,'dd/mm/yyyy') as rep_status_creation_date
			 , p.created_by rep_status_created_by
			 , to_char(r.creation_date,'dd/mm/yyyy') as final_report_creation_date
			 , r.created_by final_report_created_by
		  from jg_zz_vat_rep_status p
		  join jg_zz_vat_rep_entities e on e.vat_reporting_entity_id = p.vat_reporting_entity_id
		  join hz_parties hp on hp.party_id = e.party_id
	 left join jg_zz_vat_final_reports r on p.reporting_status_id = r.reporting_status_id
	 left join fnd_lookup_values_vl trx_src on p.source = trx_src.lookup_code and trx_src.lookup_type = 'ZX_TRL_PRODUCT_CODE'
		 where 1 = 1
		   and 1 = 1
	  order by r.final_report_id desc

-- ##################################################################
-- VAT REPORTING DETAILS 2
-- ##################################################################

		select hp.party_name
			 , p.tax_calendar_period
			 , trx_src.meaning input_output
			 , p.tax_registration_number tax_registration_number
			 , p.selection_status_flag
			 , to_char(p.selection_process_date,'dd/mm/yyyy') as selection_process_date
			 , p.allocation_status_flag
			 , to_char(p.allocation_process_date,'dd/mm/yyyy') as allocation_process_date
			 , p.final_reporting_status_flag
			 , to_char(p.final_reporting_process_date,'dd/mm/yyyy') as final_reporting_process_date
			 , to_char(p.last_update_date,'dd/mm/yyyy hh24:mi:ss') as last_update_date
			 , to_char(p.creation_date,'dd/mm/yyyy') as rep_status_creation_date
			 , p.created_by rep_status_created_by
			 , to_char(r.creation_date,'dd/mm/yyyy') as final_report_creation_date
			 , r.created_by final_report_created_by
		  from jg_zz_vat_rep_status p
		  join jg_zz_vat_rep_entities e on e.vat_reporting_entity_id = p.vat_reporting_entity_id
		  join hz_parties hp on hp.party_id = e.party_id
	 left join jg_zz_vat_final_reports r on p.reporting_status_id = r.reporting_status_id
	 left join fnd_lookup_values_vl trx_src on p.source = trx_src.lookup_code and trx_src.lookup_type = 'ZX_TRL_PRODUCT_CODE'
		 where 1 = 1
		   and 1 = 1
	  order by r.final_report_id desc

-- ##################################################################
-- SQL FROM SR
-- ##################################################################

		SELECT tax_line_id
			 , box_numberid
			 , codes.reporting_code_char_value
			 , periodicity_code
		  FROM (SELECT tax_line_id
					 , periodicity_code
					 , box_numberid
					 , reporting_batch_id
				  FROM zx_dist_tax_box_assgnmnts
			   UNPIVOT INCLUDE NULLS (BOX_NUMBERID FOR tax_box_number IN (box_number1_id
																	    , box_number2_id
																		, box_number3_id
																		, box_number4_id
																		, box_number5_id
																		, box_number6_id
																		, box_number7_id
																		, box_number8_id
																		, box_number9_id
																		, box_number10_id))
				 where tax_line_id in (select tax_line_id 
										 from zx_lines
										where trx_number = '#TRX123'
										  and application_id = 200
										  and reporting_batch_id is not null)) box_number
			 , zx_reporting_codes_b codes
		 WHERE box_number.box_numberid = codes.reporting_code_id
		   AND codes.reporting_type_id in (select reporting_type_id 
											 from zx_reporting_types_b 
											where legal_message_flag = 'B')

-- ##################################################################
-- ZX_DIST_TAX_BOX_ASSGNMNTS
-- ##################################################################

/*
This table stores the tax box assignment for a given tax line or distribution.
*/

select * from zx_dist_tax_box_assgnmnts where reporting_batch_id = 1234

-- ##################################################################
-- JE_ZZ_VAT_REP_TRX_T - VERSION 1
-- ##################################################################

/*
Oracle internal use only.
This temporary table contains reporting information related to tax, that must be sent to the tax authority.
*/

		select trx.reporting_batch_id
			 , trx.transaction_source
			 , trx.request_id
			 , trx.job_definition_name
			 , trx.created_by
			 , hp.party_name
			 , rpt_status.tax_calendar_period
			 , rpt_status.source
			 , rpt_status.tax_registration_number
			 , rpt_status.final_reporting_status_flag
			 , rpt_status.final_reporting_process_id
			 , rpt_status.final_reporting_process_date
			 , min(to_char(trx.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_created
			 , max(to_char(trx.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_created
			 , min(to_char(trx.last_update_date, 'yyyy-mm-dd hh24:mi:ss')) min_updated
			 , max(to_char(trx.last_update_date, 'yyyy-mm-dd hh24:mi:ss')) max_updated
			 , count(*) ct
		  from je_zz_vat_rep_trx_t trx
		  join jg_zz_vat_rep_status rpt_status on rpt_status.reporting_status_id = trx.reporting_batch_id
		  join jg_zz_vat_rep_entities entities on entities.vat_reporting_entity_id = rpt_status.vat_reporting_entity_id
		  join hz_parties hp on hp.party_id = entities.party_id
	  group by trx.reporting_batch_id
			 , trx.transaction_source
			 , trx.request_id
			 , trx.job_definition_name
			 , trx.created_by
			 , hp.party_name
			 , rpt_status.tax_calendar_period
			 , rpt_status.source
			 , rpt_status.tax_registration_number
			 , rpt_status.final_reporting_status_flag
			 , rpt_status.final_reporting_process_id
			 , rpt_status.final_reporting_process_date
	  order by trx.request_id desc

-- ##################################################################
-- JE_ZZ_VAT_REP_TRX_T - VERSION 2 (SMALLER VERSION)
-- ##################################################################

		select trx.reporting_batch_id
			 , trx.transaction_source
			 , rpt_status.tax_calendar_period
			 , rpt_status.source
			 , rpt_status.final_reporting_status_flag
			 , rpt_status.final_reporting_process_id
			 , rpt_status.final_reporting_process_date
			 , min(to_char(trx.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_created
			 , max(to_char(trx.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_created
			 , count(*) ct
		  from je_zz_vat_rep_trx_t trx
		  join jg_zz_vat_rep_status rpt_status on rpt_status.reporting_status_id = trx.reporting_batch_id
		  join jg_zz_vat_rep_entities entities on entities.vat_reporting_entity_id = rpt_status.vat_reporting_entity_id
		  join hz_parties hp on hp.party_id = entities.party_id
	  group by trx.reporting_batch_id
			 , trx.transaction_source
			 , rpt_status.tax_calendar_period
			 , rpt_status.source
			 , rpt_status.final_reporting_status_flag
			 , rpt_status.final_reporting_process_id
			 , rpt_status.final_reporting_process_date

-- ##################################################################
-- JG_ZZ_VAT_TRX_DETAILS - VERSION 1
-- ##################################################################

/*
JG_ZZ_VAT_TRX_DETAILS contains all payment related transactions selected for tax reporting.
Taxable transactions (invoices) are already marked as selected directly in ZX repository itself, since payment related transactions have no tax impact, they are not stored in tax repository and they are marked as finally reported using this table.
It can be used as a source for audits to provide information reported to the tax authorities at any point in time.
*/

		select trx.final_reporting_id
			 , trx.extract_source_ledger
			 , trx.request_id
			 , trx.rep_context_entity_name
			 , trx.created_by
			 , rpt_status.tax_calendar_period
			 , rpt_status.source
			 , rpt_status.tax_registration_number
			 , rpt_status.final_reporting_status_flag
			 , rpt_status.final_reporting_process_id
			 , rpt_status.final_reporting_process_date
			 , min(to_char(trx.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_created
			 , max(to_char(trx.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_created
			 , min(to_char(trx.last_update_date, 'yyyy-mm-dd hh24:mi:ss')) min_updated
			 , max(to_char(trx.last_update_date, 'yyyy-mm-dd hh24:mi:ss')) max_updated
			 , count(*) ct
		  from jg_zz_vat_trx_details trx
		  join jg_zz_vat_rep_status rpt_status on rpt_status.reporting_status_id = trx.reporting_status_id
	  group by trx.final_reporting_id
			 , trx.extract_source_ledger
			 , trx.request_id
			 , trx.rep_context_entity_name
			 , trx.created_by
			 , rpt_status.tax_calendar_period
			 , rpt_status.source
			 , rpt_status.tax_registration_number
			 , rpt_status.final_reporting_status_flag
			 , rpt_status.final_reporting_process_id
			 , rpt_status.final_reporting_process_date
	  order by trx.request_id desc

-- ##################################################################
-- JG_ZZ_VAT_TRX_DETAILS - VERSION 2
-- ##################################################################

		select trx.extract_source_ledger
			 , trx.request_id
			 , trx.rep_context_entity_name
			 , trx.created_by
			 , min(to_char(trx.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_created
			 , max(to_char(trx.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_created
			 , min(to_char(trx.last_update_date, 'yyyy-mm-dd hh24:mi:ss')) min_updated
			 , max(to_char(trx.last_update_date, 'yyyy-mm-dd hh24:mi:ss')) max_updated
			 , count(*) ct
		  from jg_zz_vat_trx_details trx
	  group by trx.final_reporting_id
			 , trx.extract_source_ledger
			 , trx.request_id
			 , trx.rep_context_entity_name
			 , trx.created_by
	  order by trx.request_id desc
