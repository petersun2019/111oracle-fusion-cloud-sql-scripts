/*
File Name: ap-invoices-holds.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- INVOICE - MATCH / HOLD INFORMATION - HEADERS
-- INVOICE - MATCH / HOLD INFORMATION - LINES
-- INVOICE - MATCH / HOLD COUNTS
-- INVOICE - MATCH / HOLD COUNTS BY SOURCE
-- INVOICE - MATCH / HOLD INFORMATION ON INVOICES
-- HOLD DEFINITIONS

*/

-- ##############################################################
-- INVOICE - MATCH / HOLD INFORMATION - HEADERS
-- ##############################################################

select * from ap_invoices_all where validation_request_id = 123

		select '#' || aia.invoice_id id
			 , '#' || aia.invoice_num invoice_num
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , aia.invoice_amount hdr_inv_amt
			 , aia.payment_status_flag hdr_payment_status
			 , aia.amount_paid hdr_amt_paid
			 , aia.approval_status hdr_apprv_status
			 , aia.wfapproval_status hdr_wf_status
			 , to_char(aia.creation_date, 'yyyy-mm-dd HH24:MM:SS') inv_created
			 , aia.created_by inv_created_by
			 , to_char(aia.last_update_date, 'yyyy-mm-dd HH24:MM:SS') inv_updated
			 , aia.last_update_date inv_updated_by
			 , to_char(aia.invoice_date, 'yyyy-mm-dd') invoice_date
			 , flv.meaning hold
			 , aha.hold_reason
			 , aha.hold_date
			 , to_char(aha.creation_date, 'yyyy-mm-dd HH24:MM:SS') hold_created
			 , aha.created_by hold_created_by
			 , to_char(aha.last_update_date, 'yyyy-mm-dd HH24:MM:SS') hold_updated
			 , aha.last_updated_by hold_updated_by
			 , aha.release_lookup_code
			 , aha.release_reason
			 , aha.validation_request_id
			 , aia.cancelled_amount
			 , aia.cancelled_by
			 , aia.cancelled_date
			 -- , (select count(*) from ap_holds_all ah2 where ah2.invoice_id = aia.invoice_id and aha.release_reason is null) open_hold_count
		  from ap_invoices_all aia
		  join poz_suppliers_v pv on aia.vendor_id = pv.vendor_id
		  join poz_supplier_sites_all_m pvsa on aia.vendor_site_id = pvsa.vendor_site_id
		  join ap_holds_all aha on aia.invoice_id = aha.invoice_id
		  join fnd_lookup_values_vl flv on flv.lookup_code = aha.hold_lookup_code and flv.lookup_type = 'HOLD CODE' and flv.view_application_id = 200
		 where 1 = 1
		   -- and aha.hold_reason = 'create_detail_wht_lines: -1 : ORA-00001: unique constraint (FUSION.ZX_WITHHOLDING_LINES_U1) violated The tax calculation has failed.'
		   and 1 = 1
	  order by to_char(aha.creation_date,'yyyy-mm-dd HH24:MM:SS') desc

-- ##############################################################
-- INVOICE - MATCH / HOLD INFORMATION - LINES
-- ##############################################################

select * from ap_invoices_all where validation_request_id = 123

		select '#' || aia.invoice_id id
			 , '#' || aia.invoice_num invoice_num
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , aia.invoice_amount hdr_inv_amt
			 , aia.payment_status_flag hdr_payment_status
			 , aia.amount_paid hdr_amt_paid
			 , aia.approval_status hdr_apprv_status
			 , aia.wfapproval_status hdr_wf_status
			 , to_char(aia.creation_date, 'yyyy-mm-dd HH24:MM:SS') inv_created
			 , aia.created_by inv_created_by
			 , to_char(aia.last_update_date, 'yyyy-mm-dd HH24:MM:SS') inv_updated
			 , aia.last_update_date inv_updated_by
			 , to_char(aia.invoice_date, 'yyyy-mm-dd') invoice_date
			 , flv.meaning hold
			 , aha.hold_reason
			 , aha.hold_date
			 , to_char(aha.creation_date, 'yyyy-mm-dd HH24:MM:SS') hold_created
			 , aha.created_by hold_created_by
			 , to_char(aha.last_update_date, 'yyyy-mm-dd HH24:MM:SS') hold_updated
			 , aha.last_updated_by hold_updated_by
			 , aha.release_lookup_code
			 , aha.release_reason
			 , aha.validation_request_id
			 , aia.cancelled_amount
			 , aia.cancelled_by
			 , aia.cancelled_date
			 -- , aha.*
			 -- , (select count(*) from ap_holds_all ah2 where ah2.invoice_id = aia.invoice_id and aha.release_reason is null) open_hold_count
			 , '#################' ap_lines_____
			 , aila.line_number inv_line
			 , aila.trx_business_category
			 , '#' || aila.requester_id requester_id
			 , to_char(aila.creation_date, 'yyyy-mm-dd hh24:mi:ss') line_created
			 , aila.created_by line_created_by
			 , to_char(aila.last_update_date, 'yyyy-mm-dd hh24:mi:ss') line_updated
			 , aila.last_updated_by line_updated_by
			 , aila.line_type_lookup_code
			 , aila.line_source
			 , (replace(replace(aila.description,chr(10),''),chr(13),' ')) line_description
			 , aila.match_type
			 , aila.amount line_amount
			 , aila.request_id line_request_id
			 , '#' || aila.requester_id line_requester_id
			 , to_char(aila.accounting_date, 'yyyy-mm-dd') line_accounting_date
		  from ap_invoices_all aia
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
		  join poz_suppliers_v pv on aia.vendor_id = pv.vendor_id
		  join poz_supplier_sites_all_m pvsa on aia.vendor_site_id = pvsa.vendor_site_id
		  join ap_holds_all aha on aia.invoice_id = aha.invoice_id
		  join fnd_lookup_values_vl flv on flv.lookup_code = aha.hold_lookup_code and flv.lookup_type = 'HOLD CODE' and flv.view_application_id = 200
		 where 1 = 1
		   and 1 = 1
	  order by to_char(aha.creation_date,'yyyy-mm-dd HH24:MM:SS') desc

		select distinct '#' || aia.invoice_num invoice_num
			 -- , '#' || aia.invoice_id id
			 , pv.vendor_name supplier
			 , pvsa.vendor_site_code site
			 , aia.invoice_amount hdr_inv_amt
			 -- , aia.payment_status_flag hdr_payment_status
			 , aia.amount_paid hdr_amt_paid
			 , aia.approval_status hdr_apprv_status
			 , aia.wfapproval_status hdr_wf_status
			 , to_char(aia.creation_date, 'yyyy-mm-dd HH24:MM:SS') inv_created
			 , aia.created_by inv_created_by
			 , to_char(aia.last_update_date, 'yyyy-mm-dd HH24:MM:SS') inv_updated
			 , aia.last_updated_by inv_updated_by
			 , to_char(aia.invoice_date, 'yyyy-mm-dd') invoice_date
			 , flv.meaning hold
			 -- , aha.hold_reason
			 -- , aha.hold_date
			 , to_char(aha.creation_date, 'yyyy-mm-dd HH24:MM:SS') hold_created
			 , aha.created_by hold_created_by
			 , to_char(aha.last_update_date, 'yyyy-mm-dd HH24:MM:SS') hold_updated
			 , aha.last_updated_by hold_updated_by
			 -- , aha.release_lookup_code
			 -- , aha.release_reason
			 , aha.validation_request_id
		  from ap_invoices_all aia
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
		  join poz_suppliers_v pv on aia.vendor_id = pv.vendor_id
		  join poz_supplier_sites_all_m pvsa on aia.vendor_site_id = pvsa.vendor_site_id
		  join ap_holds_all aha on aia.invoice_id = aha.invoice_id
		  join fnd_lookup_values_vl flv on flv.lookup_code = aha.hold_lookup_code and flv.lookup_type = 'HOLD CODE' and flv.view_application_id = 200
		 where 1 = 1
		   and 1 = 1
	  order by to_char(aha.creation_date,'yyyy-mm-dd HH24:MM:SS') desc

-- ##############################################################
-- INVOICE - MATCH / HOLD COUNTS
-- ##############################################################

		select flv.meaning
			 , aha.hold_lookup_code
			 , min(to_char(aha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_creation
			 , max(to_char(aha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_creation
			 , min(pv.vendor_name || '___' || pvsa.vendor_site_code) min_supplier_info
			 , max(pv.vendor_name || '___' || pvsa.vendor_site_code) max_supplier_info
			 , count(*)
		  from ap_holds_all aha
		  join fnd_lookup_values_vl flv on flv.lookup_code = aha.hold_lookup_code and flv.lookup_type = 'HOLD CODE' and flv.view_application_id = 200
		  join ap_invoices_all aia on aia.invoice_id = aha.invoice_id
		  join poz_suppliers_v pv on aia.vendor_id = pv.vendor_id
		  join poz_supplier_sites_all_m pvsa on aia.vendor_site_id = pvsa.vendor_site_id
		 where 1 = 1
		   and 1 = 1
	  group by flv.meaning
			 , aha.hold_lookup_code

-- ##############################################################
-- INVOICE - MATCH / HOLD COUNTS BY SOURCE
-- ##############################################################

		select flv.meaning
			 , aha.hold_lookup_code
			 , aia.source
			 , min('#' || aia.invoice_num) min_inv_num
			 , max('#' || aia.invoice_num) max_inv_num
			 , min(to_char(aha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_creation
			 , max(to_char(aha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_creation
			 , min(pv.vendor_name || '___' || pvsa.vendor_site_code) min_supplier_info
			 , max(pv.vendor_name || '___' || pvsa.vendor_site_code) max_supplier_info
			 , count(*)
		  from ap_holds_all aha
		  join fnd_lookup_values_vl flv on flv.lookup_code = aha.hold_lookup_code and flv.lookup_type = 'HOLD CODE' and flv.view_application_id = 200
		  join ap_invoices_all aia on aia.invoice_id = aha.invoice_id
		  join poz_suppliers_v pv on aia.vendor_id = pv.vendor_id
		  join poz_supplier_sites_all_m pvsa on aia.vendor_site_id = pvsa.vendor_site_id
		 where 1 = 1
		   and 1 = 1
	  group by flv.meaning
			 , aha.hold_lookup_code
			 , aia.source

-- ##############################################################
-- INVOICE - MATCH / HOLD COUNTS BY SOURCE AND DATE
-- ##############################################################

		select to_char(aia.creation_date, 'yyyy-mm-dd') creation_date
			 , flv.meaning
			 , aha.hold_lookup_code
			 , aia.source
			 , min('#' || aia.invoice_num) min_inv_num
			 , max('#' || aia.invoice_num) max_inv_num
			 , min(to_char(aha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_creation
			 , max(to_char(aha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_creation
			 , min(pv.vendor_name || '___' || pvsa.vendor_site_code) min_supplier_info
			 , max(pv.vendor_name || '___' || pvsa.vendor_site_code) max_supplier_info
			 , count(*)
		  from ap_holds_all aha
		  join fnd_lookup_values_vl flv on flv.lookup_code = aha.hold_lookup_code and flv.lookup_type = 'HOLD CODE' and flv.view_application_id = 200
		  join ap_invoices_all aia on aia.invoice_id = aha.invoice_id
		  join poz_suppliers_v pv on aia.vendor_id = pv.vendor_id
		  join poz_supplier_sites_all_m pvsa on aia.vendor_site_id = pvsa.vendor_site_id
		 where 1 = 1
		   and 1 = 1
	  group by to_char(aia.creation_date, 'yyyy-mm-dd')
			 , flv.meaning
			 , aha.hold_lookup_code
			 , aia.source

-- ##############################################################
-- INVOICE - MATCH / HOLD INFORMATION ON INVOICES
-- ##############################################################

		select distinct aia.invoice_id invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , aia.creation_date invoice_created
			 , psv.vendor_name supplier
			 , pha.segment1 po
			 , prha.requisition_number req
			 , flv.meaning hold
			 , aha.creation_date hold_created
			 , aha.last_update_date hold_updated
			 , aha.release_lookup_code
			 , aha.release_reason
			 , prha.created_by req_created_by
			 , pha.created_by po_created_by
			 , ppnf.full_name buyer
			 , nvl(pea.email_address, 'no-email') buyer_email
			 , (select count(*) from ap_holds_all ah2 where ah2.invoice_id = aia.invoice_id and aha.release_reason is null) open_hold_count
		  from ap_invoices_all aia
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id
		  join po_distributions_all pda on pda.po_distribution_id = aida.po_distribution_id
		  join po_lines_all pla on pla.po_line_id = pda.po_line_id
		  join po_headers_all pha on pla.po_header_id = pha.po_header_id
		  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id
		  join por_requisition_lines_all prla on prla.po_header_id = pla.po_header_id and prla.po_line_id = pla.po_line_id
		  join por_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
		  join ap_holds_all aha on aia.invoice_id = aha.invoice_id
		  join fnd_lookup_values_vl flv on flv.lookup_code = aha.hold_lookup_code and flv.lookup_type = 'HOLD CODE' and flv.view_application_id = 200
		  join per_all_people_f papf on pha.agent_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
		  join per_person_names_f ppnf on papf.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join per_email_addresses pea on papf.person_id = pea.person_id and pea.email_type = 'W1'
		 where 1 = 1
		   and 1 = 1
	  order by aha.creation_date desc

-- ##############################################################
-- HOLD DEFINITIONS
-- ##############################################################

		select ahc.hold_lookup_code 
			 , ahc.hold_type
			 , flv.meaning hold_description
			 , to_char(ahc.creation_date, 'yyyy-mm-dd hh24:mm:ss') hold_code_created
			 , ahc.user_releaseable_flag
			 , ahc.user_updateable_flag
			 , ahc.postable_flag
			 , ahc.initiate_workflow_flag allow_holds_resolution
			 , count(aha.hold_lookup_code)
			 , min(to_char(aha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_creation
			 , max(to_char(aha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_creation
		  from ap_hold_codes ahc
		  join fnd_lookup_values_vl flv on flv.lookup_code = ahc.hold_lookup_code and flv.lookup_type = 'HOLD CODE' and flv.view_application_id = 200
	 left join ap_holds_all aha on ahc.hold_lookup_code = aha.hold_lookup_code
	  group by ahc.hold_lookup_code 
			 , ahc.hold_type
			 , flv.meaning
			 , to_char(ahc.creation_date, 'yyyy-mm-dd hh24:mm:ss')
			 , ahc.user_releaseable_flag
			 , ahc.user_updateable_flag
			 , ahc.postable_flag
			 , ahc.initiate_workflow_flag
