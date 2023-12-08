/*
File Name: ap-invoices-terms.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- INVOICE TERMS - DEFINITION
-- INVOICE TERMS - USAGE COUNT

*/

-- ##############################################################
-- INVOICE TERMS - DEFINITION
-- ##############################################################

		select att.name
			 , atb.term_id
			 , atb.enabled_flag
			 , to_char(atb.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , atb.created_by
			 , to_char(atb.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , atb.last_updated_by
			 , atb.type
			 , atb.rank
			 , att.description
			 , atl.due_percent
			 , atl.due_amount
			 , atl.due_days
			 , atl.due_day_of_month
			 , atl.due_months_forward
			 , atl.discount_days
		  from ap_terms_b atb
		  join ap_terms_tl att on atb.term_id = att.term_id and att.language = userenv('lang')
		  join ap_terms_lines atl on atl.term_id = atb.term_id
		 where 1 = 1
		   and 1 = 1
	  order by att.name

-- ##############################################################
-- INVOICE TERMS - USAGE COUNT
-- ##############################################################

		select att.name
			 , att.description
			 , min(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_creation_date
			 , max(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_creation_date
			 , min('#' || aia.invoice_num) inv_min
			 , max('#' || aia.invoice_num) inv_max
			 , max(request_id) max_request_id
			 , count(distinct atl.sequence_num) term_line_count
			 , count(distinct aia.invoice_id) invoice_count
		  from ap_terms_tl att
		  join ap_terms_lines atl on atl.term_id = att.term_id
	 left join ap_invoices_all aia on aia.terms_id = att.term_id and att.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by att.name
			 , att.description
	  order by att.name
