/*
File Name: po-requisitions-purchase-orders-join.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- REQUISITION TO PURCHASE ORDER JOIN
-- REQUISITION TO PURCHASE ORDER JOIN - SUMMARY
-- PURCHASE ORDER TO REQUISITION JOIN

*/

-- ##############################################################
-- REQUISITION TO PURCHASE ORDER JOIN
-- ##############################################################

		select prha.requisition_number req
			 , prha.requisition_header_id req_id
			 , bu_req.bu_name req_bu
			 , prha.document_status req_status
			 , to_char(prha.creation_date,'yyyy-mm-dd hh24:mi:ss') req_created
			 , to_char(prha.approved_date,'yyyy-mm-dd hh24:mi:ss') req_approved
			 , prha.created_by
			 , prla.source_document_type
			 , prla.source_doc_header_id
			 , prla.unit_price
			 , prla.amount
			 , prla.quantity
			 , prla.item_source
			 , prla.smart_form_id
			 , pha.segment1 po
			 , pha.po_header_id po_id
			 , bu_po.bu_name po_bu
			 , pha.document_status po_status
			 , to_char(pha.creation_date,'yyyy-mm-dd hh24:mi:ss') po_created
			 , to_char(pha.approved_date,'yyyy-mm-dd hh24:mi:ss') po_approved
			 , pha.created_by po_created_by
			 , pha.document_creation_method doc_method
		  from por_requisition_headers_all prha
		  join por_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join por_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
		  join po_distributions_all pda on pda.req_distribution_id = prda.distribution_id
		  join po_lines_all pla on pda.po_line_id = pla.po_line_id
		  join po_headers_all pha on pha.po_header_id = pla.po_header_id
		  join egp_categories_tl cat on prla.category_id = cat.category_id
		  join fun_all_business_units_v bu_req on bu_req.bu_id = prha.req_bu_id
		  join fun_all_business_units_v bu_po on bu_po.bu_id = pha.prc_bu_id
		 where 1 = 1
		   and 1 = 1
	  order by prha.requisition_header_id desc

-- ##############################################################
-- REQUISITION TO PURCHASE ORDER JOIN - SUMMARY
-- ##############################################################

		select prha.requisition_number req
			 , bu_req.bu_name req_bu
			 , prha.document_status req_status
			 , to_char(prha.creation_date,'yyyy-mm-dd hh24:mi:ss') req_created
			 , to_char(prha.approved_date,'yyyy-mm-dd hh24:mi:ss') req_approved
			 , prha.created_by
			 , pha.segment1 po
			 , bu_po.bu_name po_bu
			 , pha.document_status po_status
			 , to_char(pha.creation_date,'yyyy-mm-dd hh24:mi:ss') po_created
			 , to_char(pha.approved_date,'yyyy-mm-dd hh24:mi:ss') po_approved
			 , pha.created_by po_created_by
			 , pha.document_creation_method doc_method
			 , count(*) line_count
		  from por_requisition_headers_all prha
		  join por_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join por_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
		  join po_distributions_all pda on pda.req_distribution_id = prda.distribution_id
		  join po_lines_all pla on pda.po_line_id = pla.po_line_id
		  join po_headers_all pha on pha.po_header_id = pla.po_header_id
		  join fun_all_business_units_v bu_req on bu_req.bu_id = prha.req_bu_id
		  join fun_all_business_units_v bu_po on bu_po.bu_id = pha.prc_bu_id
		 where 1 = 1
		   and 1 = 1
	  group by prha.requisition_number
			 , bu_req.bu_name
			 , prha.document_status
			 , to_char(prha.creation_date,'yyyy-mm-dd hh24:mi:ss')
			 , to_char(prha.approved_date,'yyyy-mm-dd hh24:mi:ss')
			 , prha.created_by
			 , pha.segment1
			 , bu_po.bu_name
			 , pha.document_status
			 , to_char(pha.creation_date,'yyyy-mm-dd hh24:mi:ss')
			 , to_char(pha.approved_date,'yyyy-mm-dd hh24:mi:ss')
			 , pha.created_by
			 , pha.document_creation_method
	  order by to_char(prha.creation_date,'yyyy-mm-dd hh24:mi:ss') desc

-- ##############################################################
-- PURCHASE ORDER TO REQUISITION JOIN
-- ##############################################################

		select pha.segment1 po
			 , pha.po_header_id po_header_id
			 , bu_po.bu_name po_bu
			 , pha.type_lookup_code
			 , pha.document_creation_method
			 , pha.document_status po_status
			 , to_char(pha.creation_date,'yyyy-mm-dd hh24:mi:ss') po_created
			 , pha.created_by po_created_by
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code "Supplier Site"
			 , pla.line_num po_line
			 , pda.req_distribution_id
			 , prha.requisition_number req
			 , bu_req.bu_name req_bu
			 , prha.document_status req_status
			 , to_char(prha.creation_date,'yyyy-mm-dd hh24:mi:ss') req_created
			 , prha.created_by req_created_by
			 , prla.requester_id req_requester_id
			 , cat_req.category_name req_category
			 , cat_po.category_name po_category
			 , pda.code_combination_id po_ccid
			 , '#' || gcc_po.segment1 po_seg1
			 , '#' || gcc_po.segment2 po_seg2
			 , '#' || gcc_po.segment3 po_seg3
			 , '#' || gcc_po.segment4 po_seg4
			 , '#' || gcc_po.segment5 po_seg5
			 , '#' || gcc_po.segment6 po_seg6
			 , '#' || gcc_po.segment7 po_seg7
			 , '#' || gcc_po.segment8 po_seg8
			 , prda.code_combination_id req_ccid
			 , '#' || gcc_req.segment1 req_seg1
			 , '#' || gcc_req.segment2 req_seg2
			 , '#' || gcc_req.segment3 req_seg3
			 , '#' || gcc_req.segment4 req_seg4
			 , '#' || gcc_req.segment5 req_seg5
			 , '#' || gcc_req.segment6 req_seg6
			 , '#' || gcc_req.segment7 req_seg7
			 , '#' || gcc_req.segment8 req_seg8
		  from po_headers_all pha
		  join po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on pha.vendor_site_id = pssam.vendor_site_id and pssam.vendor_id = psv.vendor_id
		  join egp_categories_tl cat_po on pla.category_id = cat_po.category_id
		  join po_distributions_all pda on pda.po_line_id = pla.po_line_id
		  join gl_code_combinations gcc_po on pda.code_combination_id = gcc_po.code_combination_id
		  join por_req_distributions_all prda on pda.req_distribution_id = prda.distribution_id
		  join gl_code_combinations gcc_req on prda.code_combination_id = gcc_req.code_combination_id
		  join por_requisition_lines_all prla on prla.requisition_line_id = prda.requisition_line_id
		  join por_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
		  join egp_categories_tl cat_req on prla.category_id = cat_req.category_id
		  join fun_all_business_units_v bu_req on bu_req.bu_id = prha.req_bu_id
		  join fun_all_business_units_v bu_po on bu_po.bu_id = pha.prc_bu_id
		 where 1 = 1
		   and 1 = 1
	  order by pha.segment1
			 , pla.line_num
