/*
File Name: po-transaction-business-categories.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- COUNT BY SHIPMENT TRANSACTION BUSINESS CATEGORY
-- COUNT BY REQUISITION LINE TRANSACTION BUSINESS CATEGORY
-- COUNT BY PRODUCT TYPE, LINE TYPE, SOURCE DOCUMENT TYPE, ORDER TYPE, TRANSACTION BUSINESS CATEGORY ETC
-- TRANSACTION BUSINESS CATEGORY AP INVOICE / PURCHASE ORDER ETC

Transaction Business Category SQLs:

I was working on an issue where AP invoices matched to POs sometimes had the Invoice Line's Transaction Business Category (Trx Bus Cat) populated, and other times it was not populated.
Oracle said on an SR thaat the Trx Bus Cat on the Invoice Line's value is based on the value of the same field on the PO Shipment
I wanted to investigate that, hence these queries.
From what I could see though sometimes the Trx Bus Cat was empty on some invoice lines even if it was populated on the PO Shipment
This was relevant as some Tax Box calculations were based on the value in the Trx Bus Cat - so if it was empty sometimes, exceptions were returned in the Tax Box Prepapartion Report
*/

-- ##############################################################
-- COUNT BY SHIPMENT TRANSACTION BUSINESS CATEGORY
-- ##############################################################

		select nvl2(pla.from_header_id, 'Y', 'N') agreement
			 , nvl2(plla.trx_business_category, 'Y', 'N') trx_bus_cat
			 , '#' po___
			 , min(to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_po_min
			 , max(to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_po_max
			 , min(pha.segment1) min_po
			 , max(pha.segment1) max_po
			 , count(distinct pha.po_header_id) po_count
			 , count(distinct pla.po_line_id) po_line_count
			 , '#' req___
			 , min(to_char(prha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_req_min
			 , max(to_char(prha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_req_max
			 , min(prha.requisition_number) min_req
			 , max(prha.requisition_number) max_req
			 , min(psv.vendor_name) min_suppl
			 , max(psv.vendor_name) max_suppl
			 , count(distinct prha.requisition_header_id) req_count
			 , count(distinct prla.requisition_line_id) req_line_count
		  from po_headers_all pha
		  join po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id and plla.po_header_id = pha.po_header_id
		  join po_distributions_all pda on pda.po_line_id = pla.po_line_id
		  join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
	 left join por_req_distributions_all prda on pda.req_distribution_id = prda.distribution_id
	 left join por_requisition_lines_all prla on prla.requisition_line_id = prda.requisition_line_id
	 left join por_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
		 where 1 = 1
		   and 1 = 1
		   and pda.req_distribution_id is null
	  group by nvl2(pla.from_header_id, 'Y', 'N')
			 , nvl2(plla.trx_business_category, 'Y', 'N')

-- ##############################################################
-- COUNT BY REQUISITION LINE TRANSACTION BUSINESS CATEGORY
-- ##############################################################

		select nvl2(trx_business_category, 'Y', 'N') trx_bus_cat
			 , min(to_char(prha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_min
			 , max(to_char(prha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_max
			 , min(prha.requisition_number) min_req
			 , max(prha.requisition_number) max_req
			 , min(prla.suggested_vendor_name) min_suppl
			 , max(prla.suggested_vendor_name) max_suppl
			 , count(*)
		  from por_requisition_headers_all prha
		  join por_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
	  group by nvl2(trx_business_category, 'Y', 'N')

-- ##############################################################
-- COUNT BY PRODUCT TYPE, LINE TYPE, SOURCE DOCUMENT TYPE, ORDER TYPE, TRANSACTION BUSINESS CATEGORY ETC
-- ##############################################################

		select prla.product_type
			 , pltt.line_type
			 , prla.source_document_type
			 , prla.order_type_lookup_code
			 , prla.purchase_basis
			 , prla.item_source
			 , pha.type_lookup_code
			 , '#' info_
			 , nvl2(pla.from_header_id, 'Y', 'N') agreement
			 , nvl2(plla.trx_business_category, 'Y', 'N') trx_bus_cat
			 , '#' po___
			 , min(to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_po_min
			 , max(to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_po_max
			 , min(pha.segment1) min_po
			 , max(pha.segment1) max_po
			 , count(distinct pha.po_header_id) po_count
			 , count(distinct pla.po_line_id) po_line_count
			 , '#' req___
			 , min(to_char(prha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_req_min
			 , max(to_char(prha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_req_max
			 , min(prha.requisition_number) min_req
			 , max(prha.requisition_number) max_req
			 , min(psv.vendor_name) min_suppl
			 , max(psv.vendor_name) max_suppl
			 , count(distinct prha.requisition_header_id) req_count
			 , count(distinct prla.requisition_line_id) req_line_count
		  from por_requisition_headers_all prha
		  join por_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join por_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
		  join po_distributions_all pda on pda.req_distribution_id = prda.distribution_id
		  join po_lines_all pla on pda.po_line_id = pla.po_line_id
		  join po_headers_all pha on pha.po_header_id = pla.po_header_id
		  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id and plla.po_header_id = pha.po_header_id
		  join po_line_types_tl pltt on pltt.line_type_id = prla.line_type_id and pltt.language = userenv('lang')
		  join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
	  group by prla.product_type
			 , pltt.line_type
			 , prla.source_document_type
			 , prla.order_type_lookup_code
			 , prla.purchase_basis
			 , prla.item_source
			 , pha.type_lookup_code
			 , nvl2(pla.from_header_id, 'Y', 'N')
			 , nvl2(plla.trx_business_category, 'Y', 'N')

-- ##############################################################
-- TRANSACTION BUSINESS CATEGORY AP INVOICE / PURCHASE ORDER ETC
-- ##############################################################

		select '#' info_trx_bus_cat___
			 , nvl2(plla.trx_business_category, 'Y', 'N') trx_bus_cat_po_ship
			 , nvl2(aila.trx_business_category, 'Y', 'N') trx_bus_cat_inv_line
			 , '#' req_line_info___
			 , prla.product_type
			 , pltt.line_type
			 , prla.source_document_type
			 , prla.order_type_lookup_code
			 , prla.purchase_basis
			 , prla.item_source
			 , pha.type_lookup_code
			 , '#' po___
			 , nvl2(pla.from_header_id, 'Y', 'N') agreement
			 , min(to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_po_min
			 , max(to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_po_max
			 , min(pha.segment1) min_po
			 , max(pha.segment1) max_po
			 , count(distinct pha.po_header_id) po_count
			 , count(distinct pla.po_line_id) po_line_count
			 , '#' req___
			 , min(to_char(prha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_req_min
			 , max(to_char(prha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_req_max
			 , min(prha.requisition_number) min_req
			 , max(prha.requisition_number) max_req
			 , min(psv.vendor_name) min_suppl
			 , max(psv.vendor_name) max_suppl
			 , count(distinct prha.requisition_header_id) req_count
			 , count(distinct prla.requisition_line_id) req_line_count
			 , '#' inv___
			 , min(aia.source) min_inv_source
			 , max(aia.source) max_inv_source
			 , min(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_inv_min
			 , max(to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_inv_max
			 , min('#' || aia.invoice_num) min_inv_num
			 , max('#' || aia.invoice_num) max_inv_num
			 , min(aia.invoice_id) min_inv_id
			 , max(aia.invoice_id) max_inv_id
			 , count(distinct aia.invoice_id) inv_count
			 , count(aila.line_number) inv_line_count
		  from po_headers_all pha
	 left join po_lines_all pla on pha.po_header_id = pla.po_header_id
	 left join po_distributions_all pda on pda.po_line_id = pla.po_line_id
	 left join por_req_distributions_all prda on pda.req_distribution_id = prda.distribution_id
	 left join por_requisition_lines_all prla on prla.requisition_line_id = prda.requisition_line_id
	 left join por_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
	 left join po_line_types_tl pltt on pltt.line_type_id = prla.line_type_id and pltt.language = userenv('lang')
	 left join po_line_locations_all plla on pla.po_line_id = plla.po_line_id and plla.po_header_id = pha.po_header_id
	 left join ap_invoice_distributions_all aida on pda.po_distribution_id = aida.po_distribution_id
	 left join ap_invoice_lines_all aila on aila.invoice_id = aida.invoice_id and aila.line_number = aida.invoice_line_number
	 left join ap_invoices_all aia on aia.invoice_id = aila.invoice_id
		  join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
		 where 1 = 1
		   and 1 = 1
	  group by prla.product_type
			 , pltt.line_type
			 , prla.source_document_type
			 , prla.order_type_lookup_code
			 , prla.purchase_basis
			 , prla.item_source
			 , pha.type_lookup_code
			 , nvl2(pla.from_header_id, 'Y', 'N')
			 , nvl2(plla.trx_business_category, 'Y', 'N')
			 , nvl2(aila.trx_business_category, 'Y', 'N')
