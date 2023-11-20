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

*/

-- ##################################################################
-- TABLE DUMPS
-- ##################################################################

select * from jg_zz_vat_rep_status order by creation_date desc
select * from jg_zz_vat_final_reports order by creation_date desc

-- ##################################################################
-- VAT REPORTING DETAILS
-- ##################################################################

		select p.reporting_status_id
			 , r.final_report_id
			 , p.source
			 , trx_src.meaning input_output
			 , substr(p.tax_registration_number,3) tax_registration_number1
			 , p.tax_registration_number tax_registration_number
			 -- , p.vat_reporting_entity_id
			 , e.entity_identifier
			 , hp.party_name
			 , hp.party_number
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

select * from zx_dist_tax_box_assgnmnts where reporting_batch_id = 4002

