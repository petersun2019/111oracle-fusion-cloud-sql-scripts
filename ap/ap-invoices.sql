/*
File Name: ap-invoices.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- INVOICE HEADERS - BASIC
-- INVOICE HEADERS AND LINES
-- INVOICE HEADERS, LINES AND DISTRIBUTIONS
-- INVOICE HEADERS - LONGER VERSION
-- INVOICE HEADERS - TERMS
-- INVOICE HEADERS - INVOICE - PO - REQ 1
-- INVOICE HEADERS - INVOICE - PO - REQ 2
-- INVOICE HEADERS - INVOICE - PO - REQ - HOLD - BUYER
-- BPM NOTIFICATIONS FOR AP INVOICE HOLDS
-- TAX INFO 1
-- TAX INFO 2
-- INVOICE APPROVAL HISTORY
-- INVOICE APPROVAL HISTORY - COUNT BY APPROVER_ID
-- INVOICE APPROVAL HISTORY - COUNT BY INVOICE_NUM
-- INVOICE HEADERS - WITH PO VALUE 1
-- INVOICE HEADERS - WITH PO VALUE 2
-- INVOICE SOURCE DEFINITIONS
-- INVOICE SOURCE DO NOT APPROVE
-- INVOICE COUNT - BY SOURCE AND TERMS, CHECKING INV DATE vs. RECEIVED DATE
-- INVOICE COUNT - BY WORKFLOW APPROVAL STATUS
-- INVOICE COUNT - BY OPERATING UNIT AND SOURCE
-- INVOICE COUNT - BY SOURCE
-- INVOICE COUNT - BY INVOICE TYPE
-- INVOICE COUNT - ALL INVOICES
-- INVOICE COUNT - BY OU, TYPE, LE, SOB, PAYMENT STATUS, VALIDATION STATUS
-- INVOICE COUNT - BY OU, LE, SOB
-- INVOICE COUNT - BY TYPE AND SOURCE
-- INVOICE COUNT - BY SUPPLIER
-- INVOICE COUNT - JOINED TO PROJECTS
-- INVOICE COUNT - LINES
-- INVOICE COUNT - LINES AND DISTRIBUTIONS
-- INVOICE COUNT - LINES BY OU, SOURCE AND LINES CREATED BY
-- INVOICE COUNT - BY PO_HEADER_ID
-- INVOICE COUNT - BY TAX INFO AT LINE LEVEL
-- INVOICE COUNT - BY HEADER ATTRIBUTE7
-- INVOICE ATTACHMENTS
-- PAYMENT SCHEDULES BASIC

*/

-- ##############################################################
-- INVOICE HEADERS - BASIC
-- ##############################################################

		select aia.invoice_id invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , (replace(replace(aia.description,chr(10),''),chr(13),' ')) description
			 , hou.name operating_unit
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) inv_hdr_status
			 , aia.attribute7
			 , aia.source
			 , flv_source.meaning source_description
			 , aia.invoice_amount
			 , aia.total_tax_amount tax_amt
			 , aia.amount_paid
			 , aia.payment_status_flag
			 , aia.approval_status
			 , aia.wfapproval_status
			 -- , ap_invoices_pkg.get_posting_status(aia.invoice_id) accounted
			 , nvl2(aia.cancelled_amount, 'Y', 'N') cancelled
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , nvl(pssam.terms_date_basis, 'Not Defined') site_terms_date_basis
			 , aia.created_by
			 , aia.payment_status_flag paid
			 , att.name invoice_terms
			 -- , atl.due_days
			 , aba.batch_name
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , to_char(aia.invoice_date, 'yyyy-mm-dd') invoice_date
			 -- , to_char(aia.terms_date, 'yyyy-mm-dd') terms_date
			 -- , to_char(aia.invoice_received_date, 'yyyy-mm-dd') invoice_received_date
			 -- , case when aia.invoice_date = aia.invoice_received_date then 'Inv_Date = Received_Date' when aia.invoice_date > aia.invoice_received_date then 'Inv_Date > Received_Date' when aia.invoice_date < aia.invoice_received_date then 'Inv_Date < Received_Date' when aia.invoice_received_date is null then 'Received_Date NULL' else 'Other' end inv_date_vs_received_date
			 -- , nvl2(aia.cancelled_amount, 'Y', 'N') cancelled
			 -- , to_char(aia.cancelled_date, 'yyyy-mm-dd') cancelled_date
			 -- , aia.cancelled_by
			 -- , aia.cancelled_amount
		  from ap_invoices_all aia
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		  join ap_terms_tl att on aia.terms_id = att.term_id and att.language = userenv('lang')
		  -- join ap_terms_lines atl on atl.term_id = att.term_id
		  join hr_operating_units hou on aia.org_id = hou.organization_id
		  join fnd_lookup_values_vl flv_source on flv_source.lookup_code = aia.source and flv_source.lookup_type = 'SOURCE' and flv_source.view_application_id = 200
	 left join ap_batches_all aba on aba.batch_id = aia.batch_id
		 where 1 = 1
		   -- and aia.invoice_amount = aia.total_tax_amount -- VAT Only Invoice
		   and 1 = 1
	  order by aia.invoice_id desc

-- ##############################################################
-- INVOICE HEADERS AND LINES
-- ##############################################################

		select aia.invoice_id hdr_inv_id
			 , '#' || aia.invoice_num invoice_num
			 , hou.name operating_unit
			 , ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code) status_1
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) inv_hdr_status
			 , aia.invoice_type_lookup_code
			 , aia.source hdr_src
			 , aia.attribute7 inv_approver_dff
			 , flv_source.meaning hdr_src_desc
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , to_char(aia.invoice_date, 'yyyy-mm-dd') inv_date
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') inv_created
			 , aia.created_by hdr_created_by
			 , to_char(aia.last_update_date, 'yyyy-mm-dd hh24:mi:ss') inv_updated
			 , aia.last_updated_by inv_updated_by
			 , aia.invoice_amount hdr_inv_amt
			 , aia.payment_status_flag hdr_payment_status
			 , aia.amount_paid hdr_amt_paid
			 , aia.approval_status hdr_apprv_status
			 , aia.wfapproval_status hdr_wf_status
			 , nvl2(aia.cancelled_amount, 'Y', 'N') cancelled
			 , to_char(aia.cancelled_date, 'yyyy-mm-dd') cancelled_date
			 , aia.cancelled_by
			 , aia.cancelled_amount
			 , '#################' lines
			 , aila.line_number inv_line
			 , aila.trx_business_category
			 , to_char(aila.creation_date, 'yyyy-mm-dd hh24:mi:ss') line_created
			 , aila.created_by line_created_by
			 , to_char(aila.last_update_date, 'yyyy-mm-dd hh24:mi:ss') line_updated
			 , aila.last_updated_by line_updated_by
			 , aila.line_type_lookup_code
			 , aila.line_source
			 , (replace(replace(aila.description,chr(10),''),chr(13),' ')) line_description
			 , aila.match_type
			 , aila.amount line_amount
			 , aila.discarded_flag
			 , aila.original_amount
			 , aila.original_base_amount
			 , '#' || aila.request_id line_request_id
			 , '#' || aila.requester_id line_requester_id
			 , to_char(aila.accounting_date, 'yyyy-mm-dd') line_accounting_date
			 , pha_header.segment1 inv_header_po
			 , pha_line.segment1 inv_line_po_num
			 , '#################' tax_info
			 , aila.tax_regime_code
			 , aila.tax
			 , aila.tax_jurisdiction_code
			 , aila.tax_rate_code
			 , aila.tax_rate
		  from ap_invoices_all aia
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join hr_operating_units hou on aia.org_id = hou.organization_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
	 left join fnd_lookup_values_vl flv_source on flv_source.lookup_code = aia.source and flv_source.lookup_type = 'SOURCE' and flv_source.view_application_id = 200
	 left join po_headers_all pha_header on aia.po_header_id = pha_header.po_header_id
	 left join po_headers_all pha_line on aila.po_header_id = pha_line.po_header_id
		 where 1 = 1
		   and 1 = 1
	  order by to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') desc

-- ##############################################################
-- INVOICE HEADERS, LINES AND DISTRIBUTIONS
-- ##############################################################

		select aia.invoice_id invoice_id
			 , '#' || aia.invoice_num invoice_num
			 -- , gllv.legal_entity_name legal_entity_1
			 -- , xep.name legal_entity_2
			 , hou.name operating_unit
			 , aia.invoice_type_lookup_code
			 -- , aia.requester_id requester_id
			 -- , aia.source
			 , flv_source.meaning source_description
			 -- , (replace(replace(aia.description,chr(10),''),chr(13),' ')) inv_description
			 -- , gsob.name set_of_books
			 -- , att.name invoice_terms
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , to_char(aia.invoice_date, 'yyyy-mm-dd') inv_date
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') inv_created
			 , aia.creation_date
			 , aia.created_by
			 -- , to_char(aia.last_update_date, 'yyyy-mm-dd hh24:mi:ss') inv_updated
			 -- , aia.last_updated_by inv_updated_by
			 , aia.invoice_amount
			 , aia.payment_status_flag
			 , aia.amount_paid
			 -- , aia.approval_status
			 -- , aia.wfapproval_status
			 -- , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) inv_hdr_status
			 -- , ap_invoices_pkg.get_posting_status(aia.invoice_id) accounted
			 -- , aia.invoice_currency_code
			 -- , aia.payment_currency_code
			 -- , nvl2(aia.cancelled_amount, 'Y', 'N') cancelled
			 -- , to_char(aia.cancelled_date, 'yyyy-mm-dd') cancelled_date
			 -- , aia.cancelled_by
			 -- , aia.cancelled_amount
			 -- , case when aia.payment_status_flag = 'N' then (decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null)) else 'N/A' end status
			 -- , case when aia.payment_status_flag = 'N' then (select count(aha.invoice_id) from ap_holds_all aha where aha.invoice_id = aia.invoice_id and aha.release_reason is null) else 0 end open_hold_count
			 , to_char(aila.creation_date, 'yyyy-mm-dd hh24:mi:ss') line_created
			 , aila.created_by line_created_by
			 , aila.line_number inv_line
			 , aila.line_type_lookup_code
			 -- , aila.line_source
			 -- , (replace(replace(aila.description,chr(10),''),chr(13),' ')) line_description
			 -- , aila.match_type
			 , aila.amount line_amount
			 , aila.original_amount
			 , aila.original_base_amount
			 -- , aila.request_id line_request_id
			 -- , to_char(aila.accounting_date, 'yyyy-mm-dd') line_accounting_date
			 , to_char(aila.last_update_date, 'yyyy-mm-dd hh24:mi:ss') line_updated
			 , aila.last_updated_by line_updated_by
			 -- , aida.line_type_lookup_code dist_line_type
			 -- , to_char(aida.creation_date, 'yyyy-mm-dd hh24:mi:ss') dist_created
			 -- , aida.created_by dist_created_by
			 -- , to_char(aida.last_update_date, 'yyyy-mm-dd hh24:mi:ss') dist_updated
			 -- , aida.last_updated_by dist_updated_by
			 -- , to_char(aida.accounting_date, 'yyyy-mm-dd') dist_accounting_date
			 -- , aida.amount dist_amount
			 -- , aida.unit_price dist_unit_price
			 -- , aida.quantity_invoiced dist_qty_invoiced
			 -- , ppav.segment1 proj_number
			 -- , '#' || ptv.task_number task_number
			 -- , '#' || aida.invoice_distribution_id invoice_distribution_id
			 -- , '#' || aida.accounting_event_id accounting_event_id
			 -- , aida.po_distribution_id
			 -- , aida.request_id dist_request_id
			 -- , aida.distribution_line_number
			 , aida.line_type_lookup_code dist_type
			 , nvl(aila.discarded_flag, 'N') discarded_flag
			 , nvl2(aia.cancelled_amount, 'Y', 'N') cancelled_amount
			 -- , gcc.enabled_flag
			 , gcc.segment1 || '-' || gcc.segment2 || '-' || gcc.segment3 || '-' || gcc.segment4 || '-' || gcc.segment5 || '-' || gcc.segment6 || '-' || gcc.segment7 || '-' || gcc.segment8 code_comb
			 -- , '#' || gcc.segment1 seg1
			 -- , '#' || gcc.segment2 seg2
			 -- , '#' || gcc.segment3 seg3
			 -- , '#' || gcc.segment4 seg4
			 -- , '#' || gcc.segment5 seg5
			 -- , '#' || gcc.segment6 seg6
			 -- , '#' || gcc.segment7 segment7
			 -- , '#' || gcc.segment8 segment8
			 -- , (select count(aiaha.invoice_id) from ap_inv_aprvl_hist_all aiaha where aiaha.invoice_id = aia.invoice_id) approval_lines_count
			 -- , pha_header.segment1 inv_header_po
			 -- , pha_line.segment1 inv_line_po_num
			 , '#' tax_info_inv_lines_____________
			 , aila.tax_regime_code
			 , aila.tax
			 , aila.tax_jurisdiction_code
			 , aila.tax_rate_code
			 , aila.tax_rate
			 , '#' recovery_info_inv_distribs________________
			 , aida.rec_nrec_rate
			 , aida.recovery_rate_name
			 , aida.recovery_type_code
		  from ap_invoices_all aia
		  -- join ap_terms_tl att on aia.terms_id = att.term_id and att.language = userenv('lang')
	 left join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
	 left join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		  join hr_operating_units hou on aia.org_id = hou.organization_id
		  -- join xle_entity_profiles xep on aia.legal_entity_id = xep.legal_entity_id
		  -- join gl_sets_of_books gsob on aia.set_of_books_id = gsob.set_of_books_id
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
		  join ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id and aila.line_number = aida.invoice_line_number
		  join gl_code_combinations gcc on aida.dist_code_combination_id = gcc.code_combination_id
	 -- left join pjf_projects_all_vl ppav on ppav.project_id = aida.pjc_project_id
	 -- left join pjf_tasks_v ptv on ptv.task_id = aida.pjc_task_id
	 left join fnd_lookup_values_vl flv_source on flv_source.lookup_code = aia.source and flv_source.lookup_type = 'SOURCE' and flv_source.view_application_id = 200
		  -- join gl_ledger_le_v gllv on aia.legal_entity_id = gllv.legal_entity_id
	 -- left join po_headers_all pha_header on aia.po_header_id = pha_header.po_header_id
	 -- left join po_headers_all pha_line on aila.po_header_id = pha_line.po_header_id
		 where 1 = 1
		   and 1 = 1
	  order by aia.creation_date desc

-- ##############################################################
-- INVOICE HEADERS - LONGER VERSION
-- ##############################################################

		select aia.invoice_id invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , hou.name operating_unit
			 , (select min(segment1) from po_headers_all pha join po_distributions_all pda on pha.po_header_id = pda.po_header_id join ap_invoice_distributions_all aida on aida.invoice_id = aia.invoice_id and pda.po_distribution_id = aida.po_distribution_id) po
			 , aia.invoice_type_lookup_code
			 , aia.source
			 , aia.legal_entity_id
			 , flv_source.meaning source_description
			 , (replace(replace(aia.description,chr(10),''),chr(13),' ')) description
			 , xep.name legal_entity
			 , gsob.name set_of_books
			 , att.name invoice_terms
			 , psv.vendor_name supplier
			 , psv.segment1 supplier_num
			 , pssam.vendor_site_code site
			 , hp.party_name
			 , hp.party_number
			 , aia.created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , to_char(aia.invoice_date, 'yyyy-mm-dd') inv_date
			 , to_char(aia.budget_date, 'yyyy-mm-dd') budget_date
			 , aia.invoice_amount inv_amt
			 , aia.total_tax_amount tax_amt
			 , aia.amount_paid
			 , aia.payment_status_flag
			 , aia.approval_status
			 , aia.wfapproval_status
			 , ap_invoices_pkg.get_posting_status(aia.invoice_id) accounted
			 , aia.invoice_currency_code
			 , aia.payment_currency_code
			 , nvl2(aia.cancelled_amount, 'Y', 'N') cancelled
			 , to_char(aia.cancelled_date, 'yyyy-mm-dd') cancelled_date
			 , aia.cancelled_by
			 , aia.cancelled_amount
			 , pha.segment1 po
			 , hzl.address1
			 , hzl.address2
			 , hzl.address3
			 , hzl.address4
			 , hzl.city
			 , hzl.state
			 , hzl.county
			 , hzl.country
			 , hzl.postal_code
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) status
			 , (select count(aha.invoice_id) from ap_holds_all aha where aha.invoice_id = aia.invoice_id and aha.release_reason is null) open_hold_count
			 , (select count(aiaha.invoice_id) from ap_inv_aprvl_hist_all aiaha where aiaha.invoice_id = aia.invoice_id) approval_lines_count
			 , (select count(*) from ap_invoice_lines_all aila where aila.invoice_id = aia.invoice_id) line_count
			 , (select count(*) from ap_invoice_distributions_all aida where aida.invoice_id = aia.invoice_id) distr_count
			 , (select count(*) from ap_inv_aprvl_hist_all aiaha2 where aiaha2.invoice_id = aia.invoice_id) apprv_lines_count
			 , (select count(*) from ap_invoice_distributions_all aida where aida.invoice_id = aia.invoice_id and aida.line_type_lookup_code = 'ITEM') dist_item
			 , (select count(*) from ap_invoice_distributions_all aida where aida.invoice_id = aia.invoice_id and aida.line_type_lookup_code = 'ACCRUAL') dist_accrual
		  from ap_invoices_all aia
		  join ap_terms_tl att on aia.terms_id = att.term_id and att.language = userenv('lang')
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		  join hz_parties hp on hp.party_id = aia.party_id
		  join hz_locations hzl on hzl.location_id = pssam.location_id
	 left join po_headers_all pha on aia.po_header_id = pha.po_header_id
		  join hr_operating_units hou on aia.org_id = hou.organization_id
		  join xle_entity_profiles xep on aia.legal_entity_id = xep.legal_entity_id
		  join gl_sets_of_books gsob on aia.set_of_books_id = gsob.set_of_books_id
		  join fnd_lookup_values_vl flv_source on flv_source.lookup_code = aia.source and flv_source.lookup_type = 'SOURCE' and flv_source.view_application_id = 200
		 where 1 = 1
		   and 1 = 1
	  order by aia.invoice_id

-- ##############################################################
-- INVOICE HEADERS - TERMS
-- ##############################################################

		select aia.invoice_id invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , hou.name operating_unit
			 , aia.invoice_type_lookup_code
			 , aia.source
			 , aia.legal_entity_id
			 , flv_source.meaning source_description
			 , (replace(replace(aia.description,chr(10),''),chr(13),' ')) description
			 , att.name invoice_terms
			 , psv.vendor_name supplier
			 , psv.segment1 supplier_num
			 , pssam.vendor_site_code site
			 , aia.created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , to_char(aia.invoice_date, 'yyyy-mm-dd') inv_date
			 , to_char(aia.budget_date, 'yyyy-mm-dd') budget_date
			 , aia.invoice_amount inv_amt
			 , aia.total_tax_amount tax_amt
			 , aia.amount_paid
			 , aia.payment_status_flag
			 , aia.approval_status
			 , aia.wfapproval_status
			 , ap_invoices_pkg.get_posting_status(aia.invoice_id) accounted
			 , aia.invoice_currency_code
			 , aia.payment_currency_code
			 , nvl2(aia.cancelled_amount, 'Y', 'N') cancelled
			 , to_char(aia.cancelled_date, 'yyyy-mm-dd') cancelled_date
			 , aia.cancelled_by
			 , aia.cancelled_amount
			 , pha.segment1 po
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) status
		  from ap_invoices_all aia
		  join ap_terms_tl att on aia.terms_id = att.term_id and att.language = userenv('lang')
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
	 left join po_headers_all pha on aia.po_header_id = pha.po_header_id
		  join hr_operating_units hou on aia.org_id = hou.organization_id
		  join fnd_lookup_values_vl flv_source on flv_source.lookup_code = aia.source and flv_source.lookup_type = 'SOURCE' and flv_source.view_application_id = 200
		 where 1 = 1
		   and 1 = 1
	  order by aia.invoice_id

-- ##############################################################
-- INVOICE HEADERS - INVOICE - PO - REQ 1
-- ##############################################################

		select distinct aia.invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , aia.invoice_amount inv_amt
			 , aia.total_tax_amount tax_amt
			 , aia.amount_paid
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , hou.name operating_unit
			 , xep.name legal_entity
			 , gsob.name set_of_books
			 , aia.created_by
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) status
			 , pha.segment1 po
			 , pha.created_by po_created_by
			 , prha.requisition_number
			 , prha.created_by req_created_by
			 , aida.line_type_lookup_code
			 , aia.last_update_date inv_updated
			 , aila.last_update_date inv_line_updated
			 , aida.last_update_date line_dist_updated
			 , pha.last_update_date po_updated
			 , pla.last_update_date po_line_updated
			 , pda.last_update_date po_dist_updated
		  from ap_invoices_all aia
	 left join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
	 left join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
	 left join hr_operating_units hou on aia.org_id = hou.organization_id
	 left join xle_entity_profiles xep on aia.legal_entity_id = xep.legal_entity_id
	 left join gl_sets_of_books gsob on aia.set_of_books_id = gsob.set_of_books_id
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
		  join ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id and aila.line_number = aida.invoice_line_number
	 left join po_distributions_all pda on pda.po_distribution_id = aida.po_distribution_id
	 left join po_lines_all pla on pla.po_line_id = pda.po_line_id
	 left join po_headers_all pha on pla.po_header_id = pha.po_header_id
	 left join po_line_locations_all plla on pla.po_line_id = plla.po_line_id
	 left join por_requisition_lines_all prla on prla.po_header_id = pla.po_header_id and prla.po_line_id = pla.po_line_id
	 left join por_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
		 where 1 = 1
		   and 1 = 1
	  order by 1

-- ##############################################################
-- INVOICE HEADERS - INVOICE - PO - REQ 2
-- ##############################################################

/*
Returns data about requester on invoice line
Requester ID on Invoice Line is same as Preparer ID on REQ Line
*/

		select distinct aia.invoice_id invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , aia.invoice_amount inv_amt
			 , aia.total_tax_amount tax_amt
			 , aia.amount_paid
			 , aia.attribute7 header_approver
			 , psv.vendor_name supplier
			 , ah.hold_reason
			 , pssam.vendor_site_code site
			 , hou.name operating_unit
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') inv_created
			 , aia.creation_date inv_created_2
			 , aia.created_by inv_created_by
			 , flv_source.meaning source
			 , '#################' ap_lines_____
			 , aila.line_number inv_line
			 , aila.trx_business_category
			 , '#' || aila.requester_id requester_id
			 , ppnf.full_name inv_line_requester
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
			 , '#################' ap_inv_dists_____
			 , aida.line_type_lookup_code dist_line_type
			 , to_char(aida.creation_date, 'yyyy-mm-dd hh24:mi:ss') dist_created
			 , aida.created_by dist_created_by
			 , to_char(aida.last_update_date, 'yyyy-mm-dd hh24:mi:ss') dist_updated
			 , aida.last_updated_by dist_updated_by
			 , to_char(aida.accounting_date, 'yyyy-mm-dd') dist_accounting_date
			 , aida.amount dist_amount
			 , aida.unit_price dist_unit_price
			 , aida.quantity_invoiced dist_qty_invoiced
			 , '#' || aida.invoice_distribution_id invoice_distribution_id
			 , '#' || aida.accounting_event_id accounting_event_id
			 , aida.po_distribution_id
			 , aida.request_id dist_request_id
			 , aida.distribution_line_number
			 , aida.line_type_lookup_code dist_type
			 , '#################' po_dists_____
			 , pda.distribution_num
			 , '#' || pda.po_distribution_id po_dist_id
			 , '#################' po_lines_____
			 , '#' || pla.po_line_id po_line_id
			 , pla.line_num
			 , pla.quantity
			 , pla.amount
			 , pla.quantity_committed -- only populated for blanket and planned PO lines
			 , pla.committed_amount -- only populated for blanket and planned PO lines
			 , '#################' po_reqs_____
			 , prha.requisition_number req_number
			 , prha.created_by req_created_by
			 , '#' || prha.preparer_id req_preparer_id
			 , to_char(prha.creation_date, 'yyyy-mm-dd hh24:mi:ss') req_created
			 , '#################' po_req_lines_____
			 , prla.line_number req_line
			 , '#################' po_____
			 , pha.segment1 po
			 , pha.created_by po_created_by
			 , to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss') po_created
		  from ap_invoices_all aia
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
		  join ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id and aida.invoice_line_number = aila.line_number
	 left join per_person_names_f ppnf on aila.requester_id = ppnf.person_id and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join po_distributions_all pda on pda.po_distribution_id = aida.po_distribution_id
	 left join po_lines_all pla on pla.po_line_id = pda.po_line_id
	 left join po_headers_all pha on pla.po_header_id = pha.po_header_id
	 left join po_line_locations_all plla on pla.po_line_id = plla.po_line_id
	 left join por_requisition_lines_all prla on prla.po_header_id = pla.po_header_id and prla.po_line_id = pla.po_line_id
	 left join por_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
		  join fnd_lookup_values_vl flv_source on flv_source.lookup_code = aia.source and flv_source.lookup_type = 'SOURCE' and flv_source.view_application_id = 200
		  join hr_operating_units hou on aia.org_id = hou.organization_id
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
	 left join ap_holds_all ah on aia.invoice_id = ah.invoice_id
		 where 1 = 1
		   and 1 = 1
order by aia.creation_date desc

-- ##############################################################
-- INVOICE HEADERS - INVOICE - PO - REQ - HOLD - BUYER
-- ##############################################################

		select distinct aia.invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , aia.creation_date invoice_created
			 , psv.vendor_name supplier
			 , pha.segment1 po
			 , prha.requisition_number req
			 , flv.meaning hold
			 , ah.creation_date hold_created
			 , prha.created_by req_created_by
			 , pha.created_by po_created_by
			 , ppnf.full_name buyer
			 , nvl(pea.email_address, 'no-email') buyer_email
		  from ap_invoices_all aia
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id
		  join po_distributions_all pda on pda.po_distribution_id = aida.po_distribution_id
		  join po_lines_all pla on pla.po_line_id = pda.po_line_id
		  join po_headers_all pha on pla.po_header_id = pha.po_header_id
		  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id
		  join por_requisition_lines_all prla on prla.po_header_id = pla.po_header_id and prla.po_line_id = pla.po_line_id
		  join por_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
		  join ap_holds_all ah on aia.invoice_id = ah.invoice_id
		  join fnd_lookup_values_vl flv on flv.lookup_code = ah.hold_lookup_code and flv.lookup_type = 'HOLD CODE' and flv.view_application_id = 200
		  join per_all_people_f papf on pha.agent_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
		  join per_person_names_f ppnf on papf.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join per_email_addresses pea on papf.person_id = pea.person_id and pea.email_type = 'W1'
		 where 1 = 1
		   and 1 = 1
	  order by ah.creation_date desc

-- ##############################################################
-- BPM NOTIFICATIONS FOR AP INVOICE HOLDS
-- ##############################################################

		select distinct 
			  '#' || fwt.identificationkey id_key
			 , fwt.tasknumber num
			 , to_char(fwt.createddate, 'yyyy-mm-dd hh24:mi:ss') created
			 , to_char(fwt.assigneddate, 'yyyy-mm-dd hh24:mi:ss') assigned
			 , fwt.state
			 , fwt.title
			 , fwt.assignees
			 , coalesce(length(fwt.assigneesdisplayname) - length(replace(fwt.assigneesdisplayname,':',null)), length(fwt.assigneesdisplayname), 0) + 1 assignee_count
			 , substr(fwt.title, instr(fwt.title,' ',-1) + 1) po
			 , to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss') po_created
			 , substr(replace(replace(replace(fwt.title,'Ordered quantity Hold on Invoice ', ''),'Received quantity Hold on Invoice ', ''),'Price Hold on Invoice ', ''), 0, instr(replace(replace(replace(fwt.title,'Ordered quantity Hold on Invoice ', ''),'Received quantity Hold on Invoice ', ''),'Price Hold on Invoice ', ''),' ')-1) invoice_num
			 , substr(replace(replace(replace(fwt.title,'Ordered quantity Hold on Invoice ', ''),'Received quantity Hold on Invoice ', ''),'Price Hold on Invoice ', ''),(instr(replace(replace(replace(fwt.title,'Ordered quantity Hold on Invoice ', ''),'Received quantity Hold on Invoice ', ''),'Price Hold on Invoice ', ''), ' for Supplier ')) + 14, instr(substr(replace(replace(replace(fwt.title,'Ordered quantity Hold on Invoice ', ''),'Received quantity Hold on Invoice ', ''),'Price Hold on Invoice ', ''),(instr(replace(replace(replace(fwt.title,'Ordered quantity Hold on Invoice ', ''),'Received quantity Hold on Invoice ', ''),'Price Hold on Invoice ', ''), ' for Supplier ')) + 14, 500), ', PO ')-1) supplier
			 -- , req_bu_id.bu_name "Requisitioning BU"
			 , prc_bu_id.bu_name "Procurement BU"
		  from fa_fusion_soainfra.wftask fwt
		  join po_headers_all pha on pha.segment1 = substr(fwt.title, instr(fwt.title,' ',-1) + 1)
		  -- join fun_all_business_units_v req_bu_id on req_bu_id.bu_id = pha.req_bu_id
		  join fun_all_business_units_v prc_bu_id on prc_bu_id.bu_id = pha.prc_bu_id
		 where 1 = 1
		   and 1 = 1
	  order by fwt.tasknumber desc

-- ##############################################################
-- TAX INFO 1
-- ##############################################################

		select aia.invoice_id invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , hou.name org
			 , aia.invoice_type_lookup_code
			 , aia.source
			 , flv_source.meaning source_description
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , aia.created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , to_char(aia.invoice_date, 'yyyy-mm-dd') inv_date
			 , aia.invoice_amount
			 , '#' zx_lines________
			 , zl.tax_regime_code zl_tax_regime_code
			 , zl.tax zl_tax
			 , zl.tax_status_code zl_tax_status_code
			 , zl.tax_rate_code zl_tax_rate_code
			 , zl.hq_estb_reg_number zl_hq_estb_reg_number
			 , zl.tax_rate zl_tax_rate
			 , '#' zx_witholding_lines________
			 , zwl.tax_regime_code zwl_tax_regime_code
			 , zwl.tax zwl_tax 
			 , zwl.tax_amt
			 , zwl.tax_status_code zwl_tax_status_code
			 , zwl.tax_rate_code zwl_tax_rate_code
			 , zwl.tax_rate zwl_tax_rate
			 , zwl.hq_estb_reg_number zwl_hq_estb_reg_number
		  from ap_invoices_all aia
	 left join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
	 left join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
	 left join hr_operating_units hou on aia.org_id = hou.organization_id
	 left join fnd_lookup_values_vl flv_source on flv_source.lookup_code = aia.source and flv_source.lookup_type = 'SOURCE' and flv_source.view_application_id = 200
	 left join zx_lines zl on zl.trx_id = aia.invoice_id
	 left join zx_withholding_lines zwl on zwl.trx_id = aia.invoice_id
		 where 1 = 1
		   and 1 = 1
	  order by aia.invoice_id desc

-- ##############################################################
-- TAX INFO 2
-- ##############################################################

/*
Cost Centre Manager part only works if the Cost Centre in the Chart of Accounts is held in Segment2
*/

		select aia.invoice_id invoice_id
			 , aia.source
			 , flv_source.meaning source_description
			 , '#' || aia.invoice_num invoice_num
			 , aia.created_by
			 , aia.payment_status_flag paid
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , to_char(aia.invoice_date, 'yyyy-mm-dd') inv_date
			 , aia.invoice_amount
			 , aia.total_tax_amount tax_amt
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , gcc.segment2 cost_centre
			 , tbl_ccm.cc_manager cost_centre_manager
			 , zlv.tax_status_code
			 , zlv.tax_rate_code
			 , zlv.tax_rate
			 , sum(nvl(zlv.orig_taxable_amt,0)) orig_taxable_amt
			 , sum(nvl(zlv.orig_tax_amt,0)) orig_tax_amt
			 , sum(nvl(zlv.line_assessable_value,0)) line_assessable_value
			 , count(*) ct
		  from ap_invoices_all aia
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
		  join ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id and aila.line_number = aida.invoice_line_number
		  join gl_code_combinations gcc on aida.dist_code_combination_id = gcc.code_combination_id
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		  join fnd_lookup_values_vl flv_source on flv_source.lookup_code = aia.source and flv_source.lookup_type = 'SOURCE' and flv_source.view_application_id = 200
		  join zx_lines_v zlv on aia.invoice_id = zlv.trx_id and zlv.application_id = 200 and zlv.event_class_code = 'STANDARD INVOICES' and zlv.entity_code = 'AP_INVOICES' and zlv.trx_id = aia.invoice_id and zlv.trx_line_number = aila.line_number
	 left join (select hoif.org_information1 cost_centre
					 , ppnf.full_name cc_manager
				  from hr_organization_v hov
				  join hr_organization_information_f hoif on hov.organization_id = hoif.organization_id and hoif.org_information_context = 'PER_GL_COST_CENTER_INFO' and hov.classification_code = 'DEPARTMENT' and sysdate between hov.effective_start_date and hov.effective_end_date and sysdate between hoif.effective_start_date and hoif.effective_end_date
				  join per_person_names_f ppnf on ppnf.person_id = hoif.org_information6 and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date) tbl_ccm on tbl_ccm.cost_centre = gcc.segment2
		 where 1 = 1
		   and aia.invoice_amount > 100
		   and zlv.cancel_flag = 'N' -- tax line is not cancelled
		   and aia.cancelled_date is null -- invoice is not cancelled
		   and 1 = 1
	  group by aia.invoice_id
			 , aia.source
			 , flv_source.meaning
			 , aia.invoice_num
			 , aia.created_by
			 , aia.payment_status_flag
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , to_char(aia.invoice_date, 'yyyy-mm-dd')
			 , aia.invoice_amount
			 , aia.total_tax_amount
			 , psv.vendor_name
			 , pssam.vendor_site_code
			 , gcc.segment2
			 , tbl_ccm.cc_manager
			 , zlv.tax_status_code
			 , zlv.tax_rate_code
			 , zlv.tax_rate

-- ##############################################################
-- INVOICE APPROVAL HISTORY
-- ##############################################################

/*
https://docs.oracle.com/en/cloud/saas/financials/21d/oedmf/apinvaprvlhistall-23628.html#apinvaprvlhistall-23628
AP_INV_APRVL_HIST_ALL
AP_INV_APRVL_HIST_ALL contains the approval and rejection history of each invoice that passes through the invoice approval workflow process.
The process inserts a record for each approver assigned to review an invoice.
This table corresponds to the invoice approval history window.
*/

		select aia.invoice_id invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , aia.doc_sequence_value voucher
			 , hou.name operating_unit
			 , aia.invoice_type_lookup_code
			 , aia.source
			 , aia.attribute7
			 , aia.approval_status
			 , aia.wfapproval_status
			 , aia.requester_id requester_id
			 , flv_source.meaning source_description
			 , (replace(replace(aia.description,chr(10),''),chr(13),' ')) description
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , aia.created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , to_char(aia.invoice_date, 'yyyy-mm-dd') inv_date
			 , aia.invoice_amount
			 , aia.payment_status_flag
			 , aia.amount_paid
			 , '##################'
			 , to_char(aiaha.creation_date, 'yyyy-mm-dd hh24:mi:ss') apprv_created
			 , '#' || aiaha.approval_history_id apprv_id
			 , aiaha.response apprv_resp_1
			 , flv_status.meaning apprv_resp_2
			 , '#' || aiaha.approver_id approver_id
			 , aiaha.amount_approved apprv_amt
			 , (replace(replace(aiaha.approver_comments,chr(10),''),chr(13),' ')) apprv_comments
			 , aiaha.approval_request_id apprv_req_id
			 , aiaha.rule_name -- The workflow rule used for assigning the workflow task to the user.
			 , aiaha.approval_step -- The approval step where the workflow rule is defined.
			 -- , (select count(*) from ap_inv_aprvl_hist_all aiaha2 where aiaha2.invoice_id = aia.invoice_id) apprv_lines_count
			 -- , (select distinct approver_id from ap_inv_aprvl_hist_all h2 where h2.invoice_id = aia.invoice_id and h2.response = 'ORA_ASSIGNED TO' and approver_id like '%@%' and approver_id != aia.created_by and rownum = 1) other_approver
		  from ap_invoices_all aia
	 left join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
	 left join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		  join ap_inv_aprvl_hist_all aiaha on aiaha.invoice_id = aia.invoice_id
	 left join hr_operating_units hou on aia.org_id = hou.organization_id
	 left join fnd_lookup_values_vl flv_source on flv_source.lookup_code = aia.source and flv_source.lookup_type = 'SOURCE' and flv_source.view_application_id = 200
	 left join fnd_lookup_values_vl flv_status on flv_status.lookup_code = aiaha.response and flv_status.lookup_type = 'AP_WFAPPROVAL_STATUS' and flv_status.view_application_id = 200
		 where 1 = 1
		   and 1 = 1
  order by to_char(aiaha.creation_date, 'yyyy-mm-dd hh24:mi:ss')

-- ##############################################################
-- INVOICE APPROVAL HISTORY - COUNT BY APPROVER_ID
-- ##############################################################

		select '#' || aiaha.approver_id approver_id
			 , aiaha.rule_name -- The workflow rule used for assigning the workflow task to the user.
			 , aiaha.approval_step -- The approval step where the workflow rule is defined.
			 , min(to_char(aiaha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) wf_created_min
			 , max(to_char(aiaha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) wf_created_max
			 , min(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) inv_created_min
			 , max(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) inv_created_max
			 , min(aia.invoice_num) inv_min
			 , max(aia.invoice_num) inv_max
			 , sum(aia.invoice_amount) inv_amt
			 , sum(aia.total_tax_amount) tax_amt
			 , sum(aia.amount_paid)
			 , count(*) ct
		  from ap_invoices_all aia
		  join ap_inv_aprvl_hist_all aiaha on aiaha.invoice_id = aia.invoice_id
		 where 1 = 1
		   and 1 = 1
	  group by '#' || aiaha.approver_id
			 , aiaha.rule_name
			 , aiaha.approval_step

-- ##############################################################
-- INVOICE APPROVAL HISTORY - COUNT BY INVOICE_NUM
-- ##############################################################

		select '#' || aia.invoice_num invoice_num
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , count(*) ct
		  from ap_invoices_all aia
		  join ap_inv_aprvl_hist_all aiaha on aiaha.invoice_id = aia.invoice_id
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		 where 1 = 1
		   and aia.wfapproval_status in ('WFAPPROVED')
		   and aia.invoice_id not in (select invoice_id from ap_inv_aprvl_hist_all where invoice_id = aia.invoice_id and response not in ('WITHDRAWN','INITIATED','ORA_AUTO APPROVED'))
		   and aia.invoice_id in (select invoice_id from ap_inv_aprvl_hist_all where invoice_id = aia.invoice_id)
		   and aia.invoice_num = 'INV123'
	  group by aia.invoice_num
			 , psv.vendor_name
			 , pssam.vendor_site_code
	    having count(*) between 10 and 20
      order by 4 desc

-- ##############################################################
-- INVOICE HEADERS - WITH PO VALUE 1
-- ##############################################################

		select aia.invoice_id invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , hou.name operating_unit
			 , aia.invoice_type_lookup_code
			 , aia.source
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , aia.created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , to_char(aia.invoice_date, 'yyyy-mm-dd') inv_date
			 , aia.invoice_amount inv_amt
			 , aia.total_tax_amount tax_amt
			 , aia.amount_paid
			 , aia.payment_status_flag
			 , aia.approval_status
			 , aia.wfapproval_status
			 , ap_invoices_pkg.get_posting_status(aia.invoice_id) accounted
			 , nvl2(aia.cancelled_amount, 'Y', 'N') cancelled
			 , pha.segment1 po
			 , sum(nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount when (plla.amount is null) then pla.unit_price * plla.quantity end, 0)) po_value
		  from ap_invoices_all aia
		  join ap_invoice_distributions_all aida on aida.invoice_id = aia.invoice_id
		  join po_distributions_all pda on pda.po_distribution_id = aida.po_distribution_id
		  join po_lines_all pla on pla.po_line_id = pda.po_line_id
		  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id
		  join po_headers_all pha on pha.po_header_id = pla.po_header_id
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		  join hr_operating_units hou on aia.org_id = hou.organization_id
		 where 1 = 1
		   and ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code) = 'APPROVED'
		   and exists (select 'Y' from ap_invoice_distributions_all aida where aida.invoice_id = aia.invoice_id and aida.po_distribution_id is not null)
		   and aia.payment_status_flag = 'Y'
		   and ap_invoices_pkg.get_posting_status(aia.invoice_id) = 'Y'
		   and aia.invoice_num = '123'
	  group by aia.invoice_id
			 , aia.invoice_num
			 , hou.name
			 , aia.invoice_type_lookup_code
			 , aia.source
			 , psv.vendor_name
			 , pssam.vendor_site_code
			 , aia.created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , to_char(aia.invoice_date, 'yyyy-mm-dd')
			 , aia.invoice_amount
			 , aia.total_tax_amount
			 , aia.amount_paid
			 , aia.payment_status_flag
			 , aia.approval_status
			 , aia.wfapproval_status
			 , ap_invoices_pkg.get_posting_status(aia.invoice_id)
			 , nvl2(aia.cancelled_amount, 'Y', 'N')
			 , pha.segment1
	  order by aia.invoice_id

-- ##############################################################
-- INVOICE HEADERS - WITH PO VALUE 2
-- ##############################################################

		with my_data as
	   (select aia.invoice_id invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , (select min(pha.po_header_id) from po_headers_all pha join po_distributions_all pda on pha.po_header_id = pda.po_header_id join ap_invoice_distributions_all aida on aida.invoice_id = aia.invoice_id and pda.po_distribution_id = aida.po_distribution_id) po_header_id
			 , hou.name operating_unit
			 , aia.invoice_type_lookup_code
			 , aia.source
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , aia.created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , to_char(aia.invoice_date, 'yyyy-mm-dd') inv_date
			 , aia.invoice_amount inv_amt
			 , aia.total_tax_amount tax_amt
			 , aia.amount_paid
			 , aia.payment_status_flag
			 , aia.approval_status
			 , aia.wfapproval_status
			 , ap_invoices_pkg.get_posting_status(aia.invoice_id) accounted
			 , nvl2(aia.cancelled_amount, 'Y', 'N') cancelled
		  from ap_invoices_all aia
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		  join hr_operating_units hou on aia.org_id = hou.organization_id
		 where 1 = 1
		   and ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code) = 'APPROVED'
		   and exists (select 'Y' from ap_invoice_distributions_all aida where aida.invoice_id = aia.invoice_id and aida.po_distribution_id is not null)
		   and aia.payment_status_flag = 'Y'
		   and ap_invoices_pkg.get_posting_status(aia.invoice_id) = 'Y'
		   -- and aia.invoice_num = '123'
		   and 1 = 1)
		select my_data.invoice_id
			 , my_data.invoice_num
			 , '#' || my_data.po_header_id po_header_id
			 , my_data.operating_unit
			 , my_data.invoice_type_lookup_code
			 , my_data.source
			 , my_data.supplier
			 , my_data.site
			 , my_data.created_by
			 , my_data.creation_date
			 , my_data.inv_date
			 , my_data.inv_amt
			 , my_data.tax_amt
			 , my_data.amount_paid
			 , my_data.payment_status_flag
			 , my_data.approval_status
			 , my_data.wfapproval_status
			 , my_data.accounted
			 , my_data.cancelled
			 , '#' || po_value.po po
			 , po_value.po_value
			 , po_value.po_received
			 , po_value.po_billed
		  from my_data
		  join (select sum(nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount when (plla.amount is null) then pla.unit_price * plla.quantity end, 0)) po_value
					 , sum(nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount_received when (plla.amount is null) then pla.unit_price * plla.quantity_received end, 0)) po_received
					 , sum(nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount_billed when (plla.amount is null) then pla.unit_price * plla.quantity_billed end, 0)) po_billed
					 , pla.po_header_id
					 , pha.segment1 po
				  from po_lines_all pla
				  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id
				  join po_headers_all pha on pha.po_header_id = pla.po_header_id
			  group by pla.po_header_id
					 , pha.segment1) po_value on po_value.po_header_id = my_data.po_header_id

-- ##############################################################
-- INVOICE SOURCE DEFINITIONS
-- ##############################################################

		select '#' || lookup_code lookup_code
			 , meaning
			 , description
			 , enabled_flag enabled
			 , to_char(creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , created_by
			 , to_char(start_date_active, 'yyyy-mm-dd') start_date
			 , to_char(end_date_active, 'yyyy-mm-dd') end_date
		  from fnd_lookup_values_vl
		 where lookup_type = 'SOURCE'
		   and view_application_id = 200 -- payables
		   and language = userenv('lang')
	  order by lookup_code

-- ##############################################################
-- INVOICE SOURCE DO NOT APPROVE
-- ##############################################################

/*
If you have Invoice Approval enable, you can add Invoice Sources to the AP_SKIP_SOA_APPROVAL Value Set to tell the system they do not require approval.
*/

		select '#' || lookup_code lookup_code
			 , meaning
			 , description
			 , enabled_flag enabled
			 , to_char(creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , created_by
			 , to_char(start_date_active, 'yyyy-mm-dd') start_date
			 , to_char(end_date_active, 'yyyy-mm-dd') end_date
		  from fnd_lookup_values_vl
		 where lookup_type = 'AP_SKIP_SOA_APPROVAL'
		   and view_application_id = 0
		   and language = userenv('lang')
	  order by lookup_code

-- ##############################################################
-- INVOICE COUNT - BY SOURCE AND TERMS, CHECKING INV DATE vs. RECEIVED DATE
-- ##############################################################

/*
On Manage Invoice Options screen, Terms Date Basis can be:

1. Invoice Date
2. Invoice received date
3. Goods received date

SQL to compare Invoice Date with Received Date
*/

		select hou.name operating_unit
			 , flv_source.meaning source_description
			 , att.name invoice_terms
			 , case when aia.invoice_date = aia.invoice_received_date then 'Inv_Date = Received_Date'
					when aia.invoice_date > aia.invoice_received_date then 'Inv_Date > Received_Date'
					when aia.invoice_date < aia.invoice_received_date then 'Inv_Date < Received_Date'
					when aia.invoice_received_date is null then 'Received_Date NULL'
					else 'Other'
			   end inv_date_vs_received_date
			 , min(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_min
			 , max(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_max
			 , min(aia.invoice_num) inv_min
			 , max(aia.invoice_num) inv_max
			 , sum(aia.invoice_amount) inv_amt
			 , sum(aia.total_tax_amount) tax_amt
			 , sum(aia.amount_paid)
			 , count(*) ct
		  from ap_invoices_all aia
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		  join ap_terms_tl att on aia.terms_id = att.term_id and att.language = userenv('lang')
		  join hr_operating_units hou on aia.org_id = hou.organization_id
		  join fnd_lookup_values_vl flv_source on flv_source.lookup_code = aia.source and flv_source.lookup_type = 'SOURCE' and flv_source.view_application_id = 200
		 where 1 = 1
		   and aia.invoice_id in (123,234,345)
		   and 1 = 1
	  group by hou.name
			 , flv_source.meaning
			 , att.name
			 , case when aia.invoice_date = aia.invoice_received_date then 'Inv_Date = Received_Date'
					when aia.invoice_date > aia.invoice_received_date then 'Inv_Date > Received_Date'
					when aia.invoice_date < aia.invoice_received_date then 'Inv_Date < Received_Date'
					when aia.invoice_received_date is null then 'Received_Date NULL'
					else 'Other'
			   end

-- ##############################################################
-- INVOICE COUNT - BY WORKFLOW APPROVAL STATUS
-- ##############################################################

		select aia.wfapproval_status
			 , count(distinct aia.invoice_id) invoice_count
			 , min(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_inv_created
			 , max(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_inv_created
			 , min(aia.invoice_num) inv_min
			 , max(aia.invoice_num) inv_max
			 , max(aia.request_id)
		  from ap_invoices_all aia
	  group by aia.wfapproval_status

-- ##############################################################
-- INVOICE COUNT - BY OPERATING UNIT AND SOURCE
-- ##############################################################

		select hou.name operating_unit
			 , aia.source
			 , flv_source.meaning source_description
			 , min(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_inv_created
			 , max(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_inv_created
			 , min(aia.invoice_num) inv_min
			 , max(aia.invoice_num) inv_max
			 , count(*)
		  from ap_invoices_all aia
		  join hr_operating_units hou on aia.org_id = hou.organization_id
		  join fnd_lookup_values_vl flv_source on flv_source.lookup_code = aia.source and flv_source.lookup_type = 'SOURCE' and flv_source.view_application_id = 200
		 where 1 = 1
		   -- and aia.source = 'Manual Invoice Entry'
		   and 1 = 1
	  group by hou.name
			 , aia.source
			 , flv_source.meaning

-- ##############################################################
-- INVOICE COUNT - BY SOURCE
-- ##############################################################

		select aia.source
			 , count(distinct aia.invoice_id) invoice_count
			 , min(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_inv_created
			 , max(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_inv_created
			 -- , min(to_char(aila.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_line_created
			 -- , max(to_char(aila.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_line_created
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) status
			 , min(to_char(aida.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_dist_created
			 , max(to_char(aida.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_dist_created
			 , max(aia.request_id)
		  from ap_invoices_all aia
	 -- left join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
	 left join ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id
		 where aia.source in ('Scanned','Migration')
	  group by aia.source
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null)

-- ##############################################################
-- INVOICE COUNT - BY INVOICE TYPE
-- ##############################################################

		select aia.invoice_type_lookup_code
			 , min(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_creation_date
			 , max(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_creation_date
			 , min(aia.invoice_num) inv_min
			 , max(aia.invoice_num) inv_max
			 , max(request_id)
			 , count(*)
		  from ap_invoices_all aia
	  group by aia.invoice_type_lookup_code

-- ##############################################################
-- INVOICE COUNT - ALL INVOICES
-- ##############################################################

		select count(*)
			 , min(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_creation_date
			 , max(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_creation_date
			 , min(aia.invoice_num) inv_min
			 , max(aia.invoice_num) inv_max
		  from ap_invoices_all aia

-- ##############################################################
-- INVOICE COUNT - BY OU, TYPE, LE, SOB, PAYMENT STATUS, VALIDATION STATUS
-- ##############################################################

		select hou.name operating_unit
			 , aia.invoice_type_lookup_code inv_type
			 , xep.name legal_entity
			 , gsob.name set_of_books
			 , aia.payment_status_flag
			 , nvl2(aia.cancelled_amount, 'Y', 'N') cancelled
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) status
			 , min(to_char(aia.creation_date, 'yyyy-mm-dd')) min_creation_date
			 , max(to_char(aia.creation_date, 'yyyy-mm-dd')) max_creation_date
			 , min(aia.invoice_num) inv_min
			 , max(aia.invoice_num) inv_max
			 , count(*) inv_count
		  from ap_invoices_all aia
		  join hr_operating_units hou on aia.org_id = hou.organization_id
		  join xle_entity_profiles xep on aia.legal_entity_id = xep.legal_entity_id
		  join gl_sets_of_books gsob on aia.set_of_books_id = gsob.set_of_books_id
		 where 1 = 1
		   and 1 = 1
	  group by hou.name
			 , aia.invoice_type_lookup_code
			 , xep.name
			 , gsob.name
			 , aia.payment_status_flag
			 , nvl2(aia.cancelled_amount, 'Y', 'N')
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null)

-- ##############################################################
-- INVOICE COUNT - BY OU, LE, SOB
-- ##############################################################

		select hou.name operating_unit
			 , xep.name legal_entity
			 , gsob.name set_of_books
			 , min(to_char(aia.creation_date, 'yyyy-mm-dd')) min_creation_date
			 , max(to_char(aia.creation_date, 'yyyy-mm-dd')) max_creation_date
			 , min(aia.invoice_num) inv_min
			 , max(aia.invoice_num) inv_max
			 , count(*) inv_count
		  from ap_invoices_all aia
		  join hr_operating_units hou on aia.org_id = hou.organization_id
		  join xle_entity_profiles xep on aia.legal_entity_id = xep.legal_entity_id
		  join gl_sets_of_books gsob on aia.set_of_books_id = gsob.set_of_books_id
		 where 1 = 1
		   and 1 = 1
	  group by hou.name
			 , xep.name
			 , gsob.name

-- ##############################################################
-- INVOICE COUNT - BY TYPE AND SOURCE
-- ##############################################################

		select aia.invoice_type_lookup_code inv_type
			 , aia.source
			 -- , flv.meaning source_meaning
			 -- , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') source_created
			 -- , flv.created_by source_created_by
			 , min(to_char(aia.creation_date, 'yyyy-mm-dd')) min_creation_date
			 , max(to_char(aia.creation_date, 'yyyy-mm-dd')) max_creation_date
			 , min(aia.invoice_num) inv_min
			 , max(aia.invoice_num) inv_max
			 , count(*) inv_count
		  from ap_invoices_all aia
		  -- join fnd_lookup_values_vl flv on flv.lookup_code = aia.source and flv.lookup_type = 'SOURCE' and flv.view_application_id = 200
		 where 1 = 1
		   and 1 = 1
	  group by aia.invoice_type_lookup_code
			 , aia.source
			 -- , flv.meaning
			 -- , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 -- , flv.created_by

-- ##############################################################
-- INVOICE COUNT - BY SUPPLIER
-- ##############################################################

		select psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , min(to_char(aia.creation_date, 'yyyy-mm-dd')) min_creation_date
			 , max(to_char(aia.creation_date, 'yyyy-mm-dd')) max_creation_date
			 , min(aia.invoice_num) inv_min
			 , max(aia.invoice_num) inv_max
			 , count(aia.invoice_id) invoice_count
		  from ap_invoices_all aia
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		 where 1 = 1
		   and 1 = 1
	  group by psv.vendor_name
			 , pssam.vendor_site_code

-- ##############################################################
-- INVOICE COUNT - JOINED TO PROJECTS
-- ##############################################################

		select hou.name bu
			 , flv_source.meaning source
			 , min(to_char(aia.creation_date, 'yyyy-mm-dd')) min_creation_date
			 , max(to_char(aia.creation_date, 'yyyy-mm-dd')) max_creation_date
			 , min(aia.invoice_num) inv_min
			 , max(aia.invoice_num) inv_max
			 , count(distinct aia.invoice_id) invoice_count
			 , count(*) dists_count
		  from ap_invoices_all aia
		  join hr_operating_units hou on aia.org_id = hou.organization_id
		  join ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id
		  join pjf_projects_all_vl ppav on ppav.project_id = aida.pjc_project_id
		  join fnd_lookup_values_vl flv_source on flv_source.lookup_code = aia.source and flv_source.lookup_type = 'SOURCE' and flv_source.view_application_id = 200
		 where 1 = 1
		   and 1 = 1
	  group by hou.name
			 , flv_source.meaning

-- ##############################################################
-- INVOICE COUNT - LINES
-- ##############################################################

		select aia.invoice_id invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , aia.source
			 , flv_source.meaning source_description
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , aia.created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , to_char(aia.invoice_date, 'yyyy-mm-dd') inv_date
			 , aia.invoice_amount inv_amt
			 , aia.total_tax_amount tax_amt
			 , count(*) line_count
		  from ap_invoices_all aia
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		  join fnd_lookup_values_vl flv_source on flv_source.lookup_code = aia.source and flv_source.lookup_type = 'SOURCE' and flv_source.view_application_id = 200
	  group by aia.invoice_id
			 , aia.invoice_num
			 , aia.source
			 , flv_source.meaning
			 , psv.vendor_name
			 , pssam.vendor_site_code
			 , aia.created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , to_char(aia.invoice_date, 'yyyy-mm-dd')
			 , aia.invoice_amount
			 , aia.total_tax_amount
	  order by count(*) desc

-- ##############################################################
-- INVOICE COUNT - LINES AND DISTRIBUTIONS
-- ##############################################################

		select aia.invoice_id invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , aia.source
			 , flv_source.meaning source_description
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , aia.created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , to_char(aia.invoice_date, 'yyyy-mm-dd') inv_date
			 , aia.invoice_amount inv_amt
			 , aia.total_tax_amount tax_amt
			 , count(distinct aila.line_number || aia.invoice_id) line_count
			 , count(distinct aida.invoice_distribution_id) inv_dist_count
		  from ap_invoices_all aia
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
		  join ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id and aida.invoice_line_number = aila.line_number
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		  join fnd_lookup_values_vl flv_source on flv_source.lookup_code = aia.source and flv_source.lookup_type = 'SOURCE' and flv_source.view_application_id = 200
		 where aia.invoice_id in (123,234,345)
	  group by aia.invoice_id
			 , aia.invoice_num
			 , aia.source
			 , flv_source.meaning
			 , psv.vendor_name
			 , pssam.vendor_site_code
			 , aia.created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , to_char(aia.invoice_date, 'yyyy-mm-dd')
			 , aia.invoice_amount
			 , aia.total_tax_amount

-- ##############################################################
-- INVOICE COUNT - LINES BY OU, SOURCE AND LINES CREATED BY
-- ##############################################################

		select hou.name operating_unit
			 , aia.source
			 , aila.created_by line_created_by
			 , min(to_char(aila.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_created
			 , min(to_char(aila.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_created
			 , min(aia.invoice_num) min_inv
			 , max(aia.invoice_num) max_inv
			 , min(psv.vendor_name) min_supplier
			 , max(psv.vendor_name) max_supplier
			 , min(prha.requisition_number) min_req
			 , max(prha.requisition_number) max_req
			 , min(pha.segment1) min_po
			 , max(pha.segment1) max_po
			 , count(*) count_
		  from ap_invoices_all aia
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
		  join ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id and aida.invoice_line_number = aila.line_number
		  join po_distributions_all pda on pda.po_distribution_id = aida.po_distribution_id
		  join po_lines_all pla on pla.po_line_id = pda.po_line_id
		  join po_headers_all pha on pla.po_header_id = pha.po_header_id
		  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id
		  join por_requisition_lines_all prla on prla.po_header_id = pla.po_header_id and prla.po_line_id = pla.po_line_id
		  join por_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
		  join hr_operating_units hou on aia.org_id = hou.organization_id
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		  join ap_holds_all ah on aia.invoice_id = ah.invoice_id
		 where 1 = 1
		   and 1 = 1
	  group by hou.name
			 , aia.source
			 , aila.created_by

-- ##############################################################
-- INVOICE COUNT - BY PO_HEADER_ID
-- ##############################################################

		select hou.name ou
			 , aia.invoice_type_lookup_code
			 , aia.source
			 , aia.payment_status_flag
			 , ap_invoices_pkg.get_posting_status(aia.invoice_id) accounted
			 , nvl2(aia.po_header_id, 'Y', 'N') po_header_id
			 , nvl2(aia.cancelled_amount, 'Y', 'N') cancelled
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) inv_hdr_status
			 , min(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_min
			 , max(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_max
			 , min(aia.invoice_num) inv_min
			 , max(aia.invoice_num) inv_max
			 , sum(aia.invoice_amount) inv_amt
			 , sum(aia.total_tax_amount) tax_amt
			 , sum(aia.amount_paid)
			 , count(*) ct
		  from ap_invoices_all aia
	 left join hr_operating_units hou on aia.org_id = hou.organization_id
		 where 1 = 1
		   and 1 = 1
	  group by hou.name
			 , aia.invoice_type_lookup_code
			 , aia.source
			 , aia.payment_status_flag
			 , ap_invoices_pkg.get_posting_status(aia.invoice_id)
			 , nvl2(aia.po_header_id, 'Y', 'N')
			 , nvl2(aia.cancelled_amount, 'Y', 'N')
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null)

-- ##############################################################
-- INVOICE COUNT - BY TAX INFO AT LINE LEVEL
-- ##############################################################

		select hou.name operating_unit
			 , aia.invoice_type_lookup_code
			 , aia.source hdr_src
			 , aila.tax_regime_code
			 , aila.tax
			 , aila.tax_jurisdiction_code
			 , aila.tax_rate_code
			 , aila.tax_rate
			 , min(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) inv_created_min
			 , max(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) inv_created_max
			 , min(aia.invoice_num) inv_min
			 , max(aia.invoice_num) inv_max
			 , count(*)
		  from ap_invoices_all aia
		  join hr_operating_units hou on aia.org_id = hou.organization_id
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
		 where 1 = 1
		   and 1 = 1
	  group by hou.name
			 , aia.invoice_type_lookup_code
			 , aia.source
			 , aila.tax_regime_code
			 , aila.tax
			 , aila.tax_jurisdiction_code
			 , aila.tax_rate_code
			 , aila.tax_rate

-- ##############################################################
-- INVOICE COUNT - BY HEADER ATTRIBUTE7
-- ##############################################################

		select aia.attribute7
			 , min(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) inv_created_min
			 , max(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) inv_created_max
			 , min(aia.invoice_num) inv_min
			 , max(aia.invoice_num) inv_max
			 , count(*)
		  from ap_invoices_all aia
		 where 1 = 1
		   and 1 = 1
	  group by aia.attribute7
	  order by aia.attribute7

-- ##############################################################
-- INVOICE ATTACHMENTS
-- ##############################################################

		select '#' || aia.invoice_num invoice_num
			 , '#' || fad.pk1_value pk1_value
			 , aia.invoice_id invoice_id
			 , psv.vendor_name supplier
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') inv_created
			 , to_char(fad.creation_date, 'yyyy-mm-dd hh24:mi:ss') att_created
			 , aia.invoice_type_lookup_code
			 , aia.source
			 , fad.category_name
			 , fdt.uri
			 , fdt.description
			 , fdt.title
			 , case when (upper(fdt.title) in ('invoice image') or upper(fdt.description) in ('INVOICE IMAGE')) then 'Y' else 'N' end check_in
			 , case when (upper(fdt.title) like ('%invoice image%') or upper(fdt.description) like ('%INVOICE IMAGE%')) then 'Y' else 'N' end check_like
		  from fnd_attached_documents fad
	 left join fnd_documents_tl fdt on fad.document_id = fdt.document_id
	 left join ap_invoices_all aia on aia.invoice_id = fad.pk1_value
	 left join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		 where 1 = 1
		   and fad.entity_name = 'AP_INVOICES_ALL'
		   and aia.source = 'IMAGE'
		   and 1 = 1
	  order by fad.creation_date desc

-- ##############################################################
-- PAYMENT SCHEDULES BASIC
-- ##############################################################

select * from ap_payment_schedules_all where invoice_id = 123456
