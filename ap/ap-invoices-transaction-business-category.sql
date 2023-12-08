/*
File Name: ap-invoices-transaction-business-category.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- TRANSACTION BUSINESS CATEGORY SUMMARY 1
-- TRX BUSINESS CATEGORY SUMMARY 2
-- INVOICES WITH MISSING TRX BUSINESS CATEGORY
-- INVOICES WITH MISSING TRX BUSINESS CATEGORY - NO PO JOINS
-- TRX BUS CATEGORY BASIC DETAILS

*/

-- ##############################################################
-- TRANSACTION BUSINESS CATEGORY SUMMARY 1
-- ##############################################################

		select aia.invoice_type_lookup_code
			 , nvl(aila.trx_business_category, 'empty')
			 , aila.line_type_lookup_code
			 , hou.name org
			 , count(distinct aia.invoice_id) inv_count
			 , count(*)
			 , min(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_inv_created
			 , max(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_inv_created
			 , min(aia.invoice_num)
			 , max(aia.invoice_num)
		  from ap_invoices_all aia
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
	 left join hr_operating_units hou on aia.org_id = hou.organization_id
	  group by aia.invoice_type_lookup_code
			 , nvl(aila.trx_business_category, 'empty')
			 , aila.line_type_lookup_code
			 , hou.name

-- ##############################################################
-- TRX BUSINESS CATEGORY SUMMARY 2
-- ##############################################################

with inv_data as (select '#' || aia.invoice_num invoice_num
					   , aila.invoice_id
					   , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') inv_created
					   , aia.created_by inv_created_by
					   , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) inv_hdr_status
					   , aia.source inv_source
					   , aia.invoice_amount inv_amt
					   , aia.total_tax_amount tax_amt
					   , aia.amount_paid paid_amt
					   , aia.payment_status_flag
					   , aia.approval_status
					   , aia.wfapproval_status
					   , case when aila.discarded_flag = 'Y' then 1 else 0 end discarded
					   , case when aila.trx_business_category is null then 1 else 0 end empty_cat
					   , psv.vendor_name supplier
					   , pssam.vendor_site_code site
					   , pha.segment1 po
				    from ap_invoice_lines_all aila
				    join ap_invoices_all aia on aila.invoice_id = aia.invoice_id
			   left join po_headers_all pha on aia.po_header_id = pha.po_header_id
				    join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
				    join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
				   where 1 = 1
				     and 1 = 1)
		select invoice_num
			 , invoice_id
			 , inv_created
			 , inv_created_by
			 , inv_hdr_status
			 , inv_source
			 , inv_amt
			 , tax_amt
			 , paid_amt
			 , payment_status_flag
			 , approval_status
			 , wfapproval_status
			 , supplier
			 , site
			 , po
			 , sum(discarded) discarded_lines
			 , sum(empty_cat) empty_cat_lines
			 , count(*) line_count
		  from inv_data
	  group by invoice_num
			 , invoice_id
			 , inv_created
			 , inv_created_by
			 , inv_hdr_status
			 , inv_source
			 , inv_amt
			 , tax_amt
			 , paid_amt
			 , payment_status_flag
			 , approval_status
			 , wfapproval_status
			 , supplier
			 , site
			 , po
		having sum(empty_cat) > 0 -- and sum(discarded) = 0

-- ##############################################################
-- INVOICES WITH MISSING TRX BUSINESS CATEGORY
-- ##############################################################

		select distinct aia.invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , hou.name operating_unit
			 , aia.invoice_type_lookup_code
			 , aia.source
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') inv_created
			 , aia.created_by
			 , to_char(aia.last_update_date, 'yyyy-mm-dd hh24:mi:ss') inv_updated
			 , aia.last_updated_by inv_updated_by
			 , aia.invoice_amount
			 , aia.payment_status_flag
			 , aia.amount_paid
			 , aia.approval_status
			 , aia.wfapproval_status
			 , nvl2(aia.cancelled_amount, 'Y', 'N') inv_cancelled
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) inv_hdr_status
			 , '#' inv_lines________
			 , aila.trx_business_category
			 , aila.line_type_lookup_code
			 , to_char(aila.creation_date, 'yyyy-mm-dd hh24:mi:ss') line_created
			 , aila.creation_date line_created_2
			 , aila.created_by line_created_by
			 , aila.line_number inv_line
			 , aila.line_source
			 , (replace(replace(aila.description,chr(10),''),chr(13),' ')) line_description
			 , aila.match_type
			 , aila.amount line_amount
			 , aila.request_id line_request_id
			 , '#' inv_po_lines________
			 , pha.segment1 po_number
			 , pla.line_num po_line_num
		  from ap_invoices_all aia
		  join ap_terms_tl att on aia.terms_id = att.term_id and att.language = userenv('lang')
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		  join gl_sets_of_books gsob on aia.set_of_books_id = gsob.set_of_books_id
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
	 left join hr_operating_units hou on aia.org_id = hou.organization_id
	 left join po_headers_all pha on aila.po_header_id = pha.po_header_id
	 left join po_lines_all pla on aila.po_line_id = pla.po_line_id and pla.po_header_id = pha.po_header_id
		 where 1 = 1
		   and 1 = 1
	  order by aila.creation_date desc

-- ##############################################################
-- INVOICES WITH MISSING TRX BUSINESS CATEGORY - NO PO JOINS
-- ##############################################################

		select aia.invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , hou.name operating_unit
			 , aia.invoice_type_lookup_code
			 , aia.source
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') inv_created
			 , aia.created_by
			 , to_char(aia.last_update_date, 'yyyy-mm-dd hh24:mi:ss') inv_updated
			 , aia.last_updated_by inv_updated_by
			 , aia.invoice_amount
			 , aia.payment_status_flag
			 , aia.amount_paid
			 , aia.approval_status
			 , aia.wfapproval_status
			 , nvl2(aia.cancelled_amount, 'Y', 'N') inv_cancelled
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) inv_hdr_status
			 , '#' inv_lines________
			 , aila.trx_business_category
			 , aila.line_type_lookup_code
			 , to_char(aila.creation_date, 'yyyy-mm-dd hh24:mi:ss') line_created
			 , aila.creation_date line_created_2
			 , aila.created_by line_created_by
			 , aila.line_number inv_line
			 , aila.line_source
			 , (replace(replace(aila.description,chr(10),''),chr(13),' ')) line_description
			 , aila.match_type
			 , aila.amount line_amount
			 , aila.request_id line_request_id
		  from ap_invoices_all aia
		  join ap_terms_tl att on aia.terms_id = att.term_id and att.language = userenv('lang')
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
		  join hr_operating_units hou on aia.org_id = hou.organization_id
		 where 1 = 1
		   and aila.trx_business_category is null
		   and aila.line_type_lookup_code = 'ITEM'
		   and aila.discarded_flag = 'N'
		   and aia.invoice_type_lookup_code not in ('AWT')
	  order by aila.creation_date desc

-- ##############################################################
-- TRX BUS CATEGORY BASIC DETAILS
-- ##############################################################

		select '#' || aia.invoice_num invoice_num
			 , aila.invoice_id
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') inv_created
			 , aia.source inv_source
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , aila.line_number line
			 , aila.line_type_lookup_code line_type
			 , aila.line_source
			 , aila.match_type
			 , aila.amount
			 , aila.quantity_invoiced
			 , aila.unit_price
			 , aila.original_amount
			 , aila.discarded_flag
			 , to_char(aila.creation_date, 'yyyy-mm-dd hh24:mi:ss') line_created
			 , aila.created_by
			 , to_char(aila.last_update_date, 'yyyy-mm-dd hh24:mi:ss') line_updated
			 , aila.last_updated_by
			 , aila.trx_business_category
			 , (replace(replace(aila.description,chr(10),''),chr(13),' ')) line_description
			 , (replace(replace(aila.item_description,chr(10),''),chr(13),' ')) item_description
			 , (select count(*) from ap_invoice_lines_all aila2 where aila2.invoice_id = aia.invoice_id and aila.discarded_flag = 'Y') discarded_line_count
		  from ap_invoice_lines_all aila
		  join ap_invoices_all aia on aila.invoice_id = aia.invoice_id
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		 where 1 = 1
		   and 1 = 1
	  order by aia.invoice_id desc
