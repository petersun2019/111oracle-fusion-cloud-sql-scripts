/*
File Name: po-purchase-orders.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- TABLE DUMPS
-- BASIC PO VALUE
-- PO HEADERS
-- PURCHASE ORDERS AND LINES
-- PURCHASE ORDERS AND LINES - WITH LINK TO REQUISITION
-- PURCHASE ORDERS, LINES AND DISTRIBUTIONS
-- CONTRACTS
-- CALL OFF ORDERS
-- PO CHANGE ORDERS (PO_VERSIONS)
-- COUUNT WITH LINES - NO REQ TABLES JOINS
-- COUNT WITH LINES - WITH REQ TABLES JOINS
-- COUNT BY BILL TO
-- COUNT BY PO STATUS
-- COUNT LINES BY MATCHING BASIS
-- COUNT SHIPMENTS BY MATCH OPTION
-- COUNT SHIPMENTS BY ACCRUE ON RECEIPT FLAG
-- COUNT - SUMMARY
-- COUNT BY CHART OF ACCOUNT SEGMENT
-- COUNT BY ITEM ID AND ORG

*/

-- ##############################################################
-- TABLE DUMPS
-- ##############################################################

select * from po_headers_all where segment1 = '123'
select * from po_lines_all where po_header_id = 123
select * from po_line_locations_all where po_header_id = 123
select * from po_distributions_all where po_header_id = 123

-- ##############################################################
-- BASIC PO VALUE
-- ##############################################################

		select pha.segment1 po
			 , '#' || pha.po_header_id po_id
			 , pha.type_lookup_code
			 , pha.document_creation_method
			 , psv.vendor_name supplier
			 , pha.cancel_flag
			 , to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , pha.created_by
			 , to_char(pha.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , pha.last_updated_by
			 , pha.closed_date
			 , pha.document_status
			 , flv_po_status.meaning po_status
			 , hla_bill.location_code bill_to
			 , hla_bill.address_line_1 || ' ' || hla_bill.address_line_2 || ' ' || hla_bill.address_line_3 || ' ' || hla_bill.town_or_city || ' ' || hla_bill.postal_code bill_to_loc
			 , sum (nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount when (plla.amount is null) then pla.unit_price * plla.quantity end, 0)) po_value
		  from po_headers_all pha
		  join po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id
		  join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on pha.vendor_site_id = pssam.vendor_site_id and pssam.vendor_id = psv.vendor_id
		  join fnd_lookup_values_vl flv_po_status on flv_po_status.lookup_code = pha.document_status and flv_po_status.view_application_id = 201 and flv_po_status.lookup_type = 'ORDER_STATUS'
	 left join hr_locations_all hla_ship on hla_ship.location_id = pha.ship_to_location_id
	 left join hr_locations_all hla_bill on hla_bill.location_id = pha.ship_to_location_id
		 where 1 = 1
		   and 1 = 1
		   and pha.segment1 = '123'
	  group by pha.segment1
			 , '#' || pha.po_header_id
			 , pha.type_lookup_code
			 , pha.document_creation_method
			 , psv.vendor_name
			 , pha.cancel_flag
			 , to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , pha.created_by
			 , to_char(pha.last_update_date, 'yyyy-mm-dd hh24:mi:ss')
			 , pha.last_updated_by
			 , pha.closed_date
			 , pha.document_status
			 , flv_po_status.meaning
			 , hla_bill.location_code
			 , hla_bill.address_line_1 || ' ' || hla_bill.address_line_2 || ' ' || hla_bill.address_line_3 || ' ' || hla_bill.town_or_city || ' ' || hla_bill.postal_code

-- ##############################################################
-- PO HEADERS
-- ##############################################################

		select pha.segment1 po
			 , '#' || pha.po_header_id po_id
			 , pha.type_lookup_code
			 , pha.document_creation_method
			 , psv.vendor_name supplier
			 , pha.cancel_flag
			 , to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , pha.created_by
			 , to_char(pha.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , pha.last_updated_by
			 , pha.closed_date
			 , pha.document_status
			 , flv_po_status.meaning po_status
			 , hla_bill.location_code bill_to
			 , req_bu_id.bu_name "Requisitioning BU"
			 , prc_bu_id.bu_name "Procurement BU"
			 , ppnf.full_name buyer
			 -- , hla_bill.address_line_1 || ' ' || hla_bill.address_line_2 || ' ' || hla_bill.address_line_3 || ' ' || hla_bill.town_or_city || ' ' || hla_bill.postal_code bill_to_loc
		  from po_headers_all pha
		  join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on pha.vendor_site_id = pssam.vendor_site_id and pssam.vendor_id = psv.vendor_id
		  join fnd_lookup_values_vl flv_po_status on flv_po_status.lookup_code = pha.document_status and flv_po_status.view_application_id = 201 and flv_po_status.lookup_type = 'ORDER_STATUS'
	 left join hr_locations_all hla_ship on hla_ship.location_id = pha.ship_to_location_id
	 left join hr_locations_all hla_bill on hla_bill.location_id = pha.ship_to_location_id
		  join fun_all_business_units_v req_bu_id on req_bu_id.bu_id = pha.req_bu_id
		  join fun_all_business_units_v prc_bu_id on prc_bu_id.bu_id = pha.prc_bu_id
		  join per_person_names_f ppnf on ppnf.person_id = pha.agent_id and sysdate between ppnf.effective_start_date and ppnf.effective_end_date and ppnf.name_type = 'GLOBAL'
		 where 1 = 1 
		   and 1 = 1
	  order by pha.last_update_date desc

-- ##############################################################
-- PURCHASE ORDERS AND LINES
-- ##############################################################

		select pha.segment1 "Order"
			 , pha.type_lookup_code
			 , pha.document_creation_method
			 , xep.name "Sold-to Legal Entity"
			 , psv.vendor_name "Supplier"
			 , pla.line_num "Line"
			 , replace(replace(pla.item_description,chr(10),''),chr(13),' ') "Line Description"
			 , plla.quantity "Ordered Quantity"
			 , pla.uom_code "UOM"
			 , pla.unit_price "Price"
			 , plla.amount "Amount"
			 , pla.unit_price "Unit Price"
			 , plla.quantity "Quantity"
			 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount
					when (plla.amount is null) then pla.unit_price * plla.quantity
			   end, 0) ordered
			 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount_received
					when (plla.amount is null) then pla.unit_price * plla.quantity_received
			   end, 0) received
			 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount_billed
					when (plla.amount is null) then pla.unit_price * plla.quantity_billed
			   end, 0) billed
			 , pha.currency_code "Currency"
			 , hla_ship.location_code "Ship-to Location"
			 , to_char(plla.need_by_date, 'yyyy-mm-dd') "Requested Date"
			 , to_char(plla.promised_date, 'yyyy-mm-dd') "Promised Date"
			 , to_char(pha.creation_date, 'yyyy-mm-dd') "Creation Date"
			 , hla_bill.location_code "Bill-to Location"
			 , ppnf.full_name "Buyer"
			 , to_char(pha.closed_date, 'yyyy-mm-dd') "Closed Date" 
			 , pla.line_status "Line Status"
			 , pltt.line_type "Line Type"
			 , pha.document_status "Order Status"
			 , req_bu_id.bu_name "Requisitioning BU"
			 , hou.name "Ship-to Organization"
			 , agreement.segment1 "Source Agreement"
			 , agreement_lines.line_num "Source Agreement Line"
			 , pla.vendor_product_num "Supplier Item"
			 , pssam.vendor_site_code "Supplier Site"
			 , plla.quantity_accepted "Accepted Quantity"
			 , plla.match_option "Invoice Match Option"
			 , plla.last_accept_date "Last Acceptable Delivery Date"
			 , pha.revision_num "Revision"
			 , att.name "Payment Terms"
			 , prc_bu_id.bu_name "Procurement BU"
			 , agreement.type_lookup_code "Source Agreement Document Type"
			 , plla.amount_cancelled "Canceled Amount"
			 , plla.trx_business_category "Transaction Business Category"
			 , case when plla.receipt_required_flag = 'N' then '2-Way'
					when plla.receipt_required_flag = 'Y' and plla.inspection_required_flag = 'N' then '3-Way'
					when plla.receipt_required_flag = 'Y' and plla.inspection_required_flag = 'Y' then '4-Way'
			   end "Match Approval Level"
			 , cat.category_name "Category Name"
		  from po_headers_all pha
		  join xle_entity_profiles xep on pha.soldto_le_id = xep.legal_entity_id 
		  join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on pha.vendor_site_id = pssam.vendor_site_id and pssam.vendor_id = psv.vendor_id
		  join po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id and plla.po_header_id = pha.po_header_id
		  join po_line_types_tl pltt on pltt.line_type_id = pla.line_type_id
		  join hr_locations_all hla_ship on hla_ship.location_id = pha.ship_to_location_id
		  join hr_locations_all hla_bill on hla_bill.location_id = pha.bill_to_location_id
		  join per_person_names_f ppnf on ppnf.person_id = pha.agent_id and sysdate between ppnf.effective_start_date and ppnf.effective_end_date and ppnf.name_type = 'GLOBAL'
		  join fun_all_business_units_v req_bu_id on req_bu_id.bu_id = pha.req_bu_id
		  join fun_all_business_units_v prc_bu_id on prc_bu_id.bu_id = pha.prc_bu_id
		  join hr_organization_units hou on hou.organization_id = plla.ship_to_organization_id
	 left join po_headers_all agreement on agreement.po_header_id = pla.from_header_id
	 left join po_lines_all agreement_lines on agreement_lines.po_line_id = pla.from_line_id
	 left join ap_terms_tl att on att.term_id = pha.terms_id
	 left join egp_categories_tl cat on pla.category_id = cat.category_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- PURCHASE ORDERS AND LINES - WITH LINK TO REQUISITION
-- ##############################################################

		select pha.segment1 "Order"
			 , xep.name "Sold-to Legal Entity"
			 , psv.vendor_name "Supplier"
			 , pla.line_num "Line"
			 , replace(replace(pla.item_description,chr(10),''),chr(13),' ') "Line Description"
			 , plla.quantity "Ordered Quantity"
			 , pla.uom_code "UOM"
			 , pla.unit_price "Price"
			 , plla.amount "Amount"
			 , pla.unit_price "Unit Price"
			 , plla.quantity "Quantity"
			 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount
					when (plla.amount is null) then pla.unit_price * plla.quantity
			   end, 0) ordered
			 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount_received
					when (plla.amount is null) then pla.unit_price * plla.quantity_received
			   end, 0) received
			 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount_billed
					when (plla.amount is null) then pla.unit_price * plla.quantity_billed
			   end, 0) billed
			 , pha.currency_code "Currency"
			 , hla_ship.location_code "Ship-to Location"
			 , to_char(plla.need_by_date, 'yyyy-mm-dd') "Requested Date"
			 , to_char(plla.promised_date, 'yyyy-mm-dd') "Promised Date"
			 , to_char(pha.creation_date, 'yyyy-mm-dd') "Creation Date"
			 , hla_bill.location_code "Bill-to Location"
			 , ppnf.full_name "Buyer"
			 , to_char(pha.closed_date, 'yyyy-mm-dd') "Closed Date" 
			 , pla.line_status "Line Status"
			 , pltt.line_type "Line Type"
			 , pha.document_status "Order Status"
			 , req_bu_id.bu_name "Requisitioning BU"
			 , hou.name "Ship-to Organization"
			 , agreement.segment1 "Source Agreement"
			 , agreement_lines.line_num "Source Agreement Line"
			 , pla.vendor_product_num "Supplier Item"
			 , pssam.vendor_site_code "Supplier Site"
			 , plla.quantity_accepted "Accepted Quantity"
			 , plla.match_option "Invoice Match Option"
			 , plla.last_accept_date "Last Acceptable Delivery Date"
			 , pha.revision_num "Revision"
			 , att.name "Payment Terms"
			 , prc_bu_id.bu_name "Procurement BU"
			 , agreement.type_lookup_code "Source Agreement Document Type"
			 , plla.amount_cancelled "Canceled Amount"
			 , plla.trx_business_category "Transaction Business Category"
			 , case when plla.receipt_required_flag = 'N' then '2-Way'
					when plla.receipt_required_flag = 'Y' and plla.inspection_required_flag = 'N' then '3-Way'
					when plla.receipt_required_flag = 'Y' and plla.inspection_required_flag = 'Y' then '4-Way'
			   end "Match Approval Level"
			 , cat.category_name "Category Name"
			 , prha.requisition_number "Requisition"
		  from po_headers_all pha
		  join xle_entity_profiles xep on pha.soldto_le_id = xep.legal_entity_id 
		  join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on pha.vendor_site_id = pssam.vendor_site_id and pssam.vendor_id = psv.vendor_id
		  join po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id and plla.po_header_id = pha.po_header_id
		  join po_distributions_all pda on pla.po_line_id = pda.po_line_id
		  join po_line_types_tl pltt on pltt.line_type_id = pla.line_type_id
		  join hr_locations_all hla_ship on hla_ship.location_id = pha.ship_to_location_id
		  join hr_locations_all hla_bill on hla_bill.location_id = pha.bill_to_location_id
		  join per_person_names_f ppnf on ppnf.person_id = pha.agent_id and sysdate between ppnf.effective_start_date and ppnf.effective_end_date and ppnf.name_type = 'GLOBAL'
		  join fun_all_business_units_v req_bu_id on req_bu_id.bu_id = pha.req_bu_id
		  join fun_all_business_units_v prc_bu_id on prc_bu_id.bu_id = pha.prc_bu_id
		  join hr_organization_units hou on hou.organization_id = plla.ship_to_organization_id
	 left join po_headers_all agreement on agreement.po_header_id = pla.from_header_id
	 left join po_lines_all agreement_lines on agreement_lines.po_line_id = pla.from_line_id
	 left join ap_terms_tl att on att.term_id = pha.terms_id
	 left join por_req_distributions_all prda on pda.req_distribution_id = prda.distribution_id
	 left join por_requisition_lines_all prla on prla.requisition_line_id = prda.requisition_line_id
	 left join por_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
	 left join egp_categories_tl cat on pla.category_id = cat.category_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- PURCHASE ORDERS, LINES AND DISTRIBUTIONS
-- ##############################################################

		select pha.segment1 po
			 , '#' || pha.po_header_id po_header_id
			 , pha.type_lookup_code
			 , '#' || pha.vendor_id vendor_id
			 , '#' || pla.po_line_id po_line_id
			 , pla.line_num
			 , pla.quantity
			 , pla.amount
			 , pla.quantity_committed -- only populated for blanket and planned PO lines
			 , pla.committed_amount -- only populated for blanket and planned PO lines
			 , psv.vendor_name
			 , pssam.vendor_site_code site
			 , pha.created_by
			 , '#' || pha.agent_id agent_id
			 , pha.cancel_flag
			 , pha.document_status
			 , flv_po_status.meaning po_status
			 , pda.distribution_num
			 , '#' || pda.po_distribution_id po_distribution_id
			 , pda.accrued_flag
			 , pda.accrue_on_receipt_flag
			 , pla.unit_price
			 , '========' pda_qty
			 , nvl(pda.quantity_ordered,0) quantity_ordered
			 , nvl(pda.quantity_delivered,0) quantity_delivered
			 , nvl(pda.quantity_billed,0) quantity_billed
			 , nvl(pda.quantity_cancelled,0) quantity_cancelled
			 , '========' pda_amount
			 , nvl(pda.amount_ordered,0) amount_ordered
			 , nvl(pda.amount_delivered,0) amount_delivered
			 , nvl(pda.amount_billed,0) amount_billed
			 , nvl(pda.amount_cancelled,0) amount_cancelled
			 , '===========================' distribution_values
			 , gcc1.segment1 || '.' || gcc1.segment2 || '.' || gcc1.segment3 || '.' || gcc1.segment4 || '.' || gcc1.segment5 || '.' || gcc1.segment6 || '.' || gcc1.segment7 || '.' || gcc1.segment8 code_comb
			 , ppav.segment1 project
			 , '========' shipment
			 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount
					when (plla.amount is null) then pla.unit_price * plla.quantity
			   end, 0) ordered
			 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount_received
					when (plla.amount is null) then pla.unit_price * plla.quantity_received
			   end, 0) received
			 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount_billed
					when (plla.amount is null) then pla.unit_price * plla.quantity_billed
			   end, 0) billed
		  from po_headers_all pha
		  join po_lines_all pla on pla.po_header_id = pha.po_header_id
		  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id and plla.po_header_id = pha.po_header_id
		  join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on pha.vendor_site_id = pssam.vendor_site_id and pssam.vendor_id = psv.vendor_id
		  join po_distributions_all pda on pda.po_line_id = pla.po_line_id and pda.po_header_id = pha.po_header_id
		  join gl_code_combinations gcc1 on gcc1.code_combination_id = pda.code_combination_id
		  join fnd_lookup_values_vl flv_po_status on flv_po_status.lookup_code = pha.document_status and flv_po_status.view_application_id = 201 and flv_po_status.lookup_type = 'ORDER_STATUS'
	 left join pjf_projects_all_vl ppav on pda.pjc_project_id = ppav.project_id
		 where 1 = 1
		   and 1 = 1
	  order by pha.last_update_date desc

-- ##############################################################
-- CONTRACTS
-- ##############################################################

		select pha.segment1 po
			 , '#' || pha.po_header_id po_id
			 , pha.type_lookup_code
			 , psv.vendor_name supplier
			 , pha.cancel_flag
			 , pha.creation_date
			 , pha.created_by
			 , pha.last_update_date
			 , pha.last_updated_by
			 , pha.closed_date
			 , pha.document_status
			 , flv_po_status.meaning po_status
			 , pha.amount_released
			 , pha.blanket_total_amount
			 , pha.amount_limit
			 , to_char(pha.last_release_date, 'yyyy-mm-dd hh24:mi:ss') last_release_date
			 , (select count(distinct pla.po_header_id) from po_lines_all pla where pla.contract_id = pha.po_header_id) released_po_count
		  from po_headers_all pha
		  join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on pha.vendor_site_id = pssam.vendor_site_id and pssam.vendor_id = psv.vendor_id
		  join fnd_lookup_values_vl flv_po_status on flv_po_status.lookup_code = pha.document_status and flv_po_status.view_application_id = 201 and flv_po_status.lookup_type = 'ORDER_STATUS'
		 where 1 = 1 
		   and pha.type_lookup_code = 'CONTRACT'
		   and 1 = 1
	  order by pha.last_update_date desc

-- ##############################################################
-- CALL OFF ORDERS
-- ##############################################################

		select po_head.segment1 po_number
			 , po_head.comments po_description
			 , sum(po_line.unit_price*po_line.quantity) po_value
			 , (select vendor_name from poz_suppliers_v where vendor_id = po_head.vendor_id) suppler_name
			 , to_char(po_head.creation_date, 'yyyy-mm-dd') po_creation_date
			 , sum(case when upper (comments) like '%CALL%OFF%' then 1 else 0 end) header_call_off
			 , sum(case when po_line.line_type_id = 1020 then 1 else 0 end) numb_service_lines
			 , sum(case when upper (po_line.item_description) like '%CALL%OFF%' then 1 else 0 end) numb_call_off_lines
		  from po_headers_all po_head
			 , po_lines_all po_line
		 where po_head.document_status = 'OPEN'
		   and po_head.approved_flag = 'Y'
		   and po_line.po_header_id = po_head.po_header_id
	  group by po_head.segment1
			 , po_head.comments
			 , po_head.vendor_id
			 , to_char(po_head.creation_date, 'yyyy-mm-dd')
		having sum(case when upper (comments) like '%CALL%OFF%' then 1 else 0 end) > 0
			or sum(case when po_line.line_type_id = 1020 then 1 else 0 end) > 0
			or sum(case when upper (po_line.item_description) like '%CALL%OFF%' then 1 else 0 end) > 0

-- ##############################################################
-- PO CHANGE ORDERS (PO_VERSIONS)
-- ##############################################################

		select pha.segment1 po
			 , pha.type_lookup_code
			 , psv.vendor_name supplier
			 , pha.cancel_flag
			 , pha.creation_date
			 , pha.created_by
			 , pha.last_update_date
			 , pha.last_updated_by
			 , pha.closed_date
			 , pha.document_status
			 , flv_po_status.meaning po_status
			 , pha.po_header_id
			 , '################'
			 , pv.revision_num
			 , pv.change_order_desc
			 , pv.change_order_status
			 , pv.created_by change_order_created_by
			 , to_char(pv.creation_date,'yyyy-mm-dd hh24:mi:ss') po_change_created
			 , to_char(pv.submitted_date,'yyyy-mm-dd hh24:mi:ss') po_change_submitted
		  from po_headers_all pha
		  join po_versions pv on pha.po_header_id = pv.po_header_id
		  join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on pha.vendor_site_id = pssam.vendor_site_id and pssam.vendor_id = psv.vendor_id
		  join fnd_lookup_values_vl flv_po_status on flv_po_status.lookup_code = pha.document_status and flv_po_status.view_application_id = 201 and flv_po_status.lookup_type = 'ORDER_STATUS'
		 where 1 = 1
		   and 1 = 1
	  order by pha.last_update_date desc

-- ##############################################################
-- COUUNT WITH LINES - NO REQ TABLES JOINS
-- ##############################################################

		select pha.segment1 po
			 , '#' || pha.po_header_id po_id
			 , pha.type_lookup_code
			 , psv.vendor_name supplier
			 , pha.cancel_flag
			 , pha.creation_date
			 , pha.created_by
			 , pha.last_update_date
			 , pha.last_updated_by
			 , pha.closed_date
			 , pha.document_status
			 , flv_po_status.meaning po_status
			 , flv_match.meaning matching_basis
			 , pha.po_header_id
			 , case when plla.receipt_required_flag = 'N' then '2-Way'
					when plla.receipt_required_flag = 'Y' and plla.inspection_required_flag = 'N' then '3-Way'
					when plla.receipt_required_flag = 'Y' and plla.inspection_required_flag = 'Y' then '4-Way'
			   end match_approval_level -- prc:po:where is po match approval level stored? (doc id 2092176.1)
			 , count(*) line_count
		  from po_headers_all pha
		  join po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join po_line_locations_all plla on plla.po_header_id = pla.po_header_id and plla.po_header_id = pha.po_header_id
		  join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on pha.vendor_site_id = pssam.vendor_site_id and pssam.vendor_id = psv.vendor_id
		  join fnd_lookup_values_vl flv_po_status on flv_po_status.lookup_code = pha.document_status and flv_po_status.view_application_id = 201 and flv_po_status.lookup_type = 'ORDER_STATUS'
		  join fnd_lookup_values_vl flv_match on flv_match.lookup_code = pla.matching_basis and flv_match.view_application_id = 200 and flv_match.lookup_type = 'MATCHING BASIS'
		 where 1 = 1 
		   and 1 = 1
	  group by pha.segment1
			 , '#' || pha.po_header_id
			 , pha.type_lookup_code
			 , psv.vendor_name
			 , pha.cancel_flag
			 , pha.creation_date
			 , pha.created_by
			 , pha.last_update_date
			 , pha.last_updated_by
			 , pha.closed_date
			 , pha.document_status
			 , flv_po_status.meaning
			 , flv_match.meaning
			 , pha.po_header_id
			 , case when plla.receipt_required_flag = 'N' then '2-Way'
					when plla.receipt_required_flag = 'Y' and plla.inspection_required_flag = 'N' then '3-Way'
					when plla.receipt_required_flag = 'Y' and plla.inspection_required_flag = 'Y' then '4-Way'
			   end
	  order by pha.last_update_date desc

-- ##############################################################
-- COUNT WITH LINES - WITH REQ TABLES JOINS
-- ##############################################################

		select pha.segment1 po
			 , '#' || pha.po_header_id po_id
			 , pha.type_lookup_code po_type
			 , psv.vendor_name supplier
			 , to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss') bpa_created
			 , pha.created_by po_created_by
			 , pha.document_status bpa_status
			 , flv_po_status.meaning po_status
			 , '#' po_lines_______________
			 , pla.line_num bpa_line
			 , '#' || pla.po_line_id po_line_id
			 , cat.category_name bpa_cat
			 , pla.vendor_product_num bpa_product_num
			 , to_char(pla.expiration_date, 'yyyy-mm-dd') bpa_line_expir_date
			 , pla.component_amount_released bpa_line_component_amount_released
			 , pla.amount_released bpa_line_amount_released
			 , pla.committed_amount bpa_line_committed_amount
			 , prha.document_status req_status
			 , count(distinct prla.requisition_line_id) req_line_count
			 , count(distinct prha.requisition_header_id) req_count
			 , min(prha.requisition_number) min_req
			 , max(prha.requisition_number) max_req
			 , min(to_char(prha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_req_created
			 , max(to_char(prha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_req_created
			 , sum(prla.quantity * prla.unit_price) req_line_value
		  from po_headers_all pha
		  join po_lines_all pla on pha.po_header_id = pla.po_header_id
		  join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on pha.vendor_site_id = pssam.vendor_site_id and pssam.vendor_id = psv.vendor_id
		  join fnd_lookup_values_vl flv_po_status on flv_po_status.lookup_code = pha.document_status and flv_po_status.view_application_id = 201 and flv_po_status.lookup_type = 'ORDER_STATUS'
	 left join por_requisition_lines_all prla on prla.source_doc_header_id = pha.po_header_id and prla.source_doc_line_id = pla.po_line_id
	 left join por_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
	 left join egp_categories_tl cat on pla.category_id = cat.category_id
		 where 1 = 1 
		   and 1 = 1
	 group by pha.segment1
			 , '#' || pha.po_header_id
			 , pha.type_lookup_code
			 , psv.vendor_name
			 , to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , pha.created_by
			 , pha.document_status
			 , flv_po_status.meaning
			 , '#'
			 , pla.line_num
			 , '#' || pla.po_line_id
			 , cat.category_name
			 , pla.vendor_product_num
			 , to_char(pla.expiration_date, 'yyyy-mm-dd')
			 , pla.component_amount_released
			 , pla.amount_released
			 , pla.committed_amount
			 , prha.document_status

-- ##############################################################
-- COUNT BY BILL TO
-- ##############################################################

		select hla_bill.location_code bill_to
			 , hla_bill.postal_code
			 , min(to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_po_created
			 , max(to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_po_created
			 , count(*)
		  from po_headers_all pha
		  join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on pha.vendor_site_id = pssam.vendor_site_id and pssam.vendor_id = psv.vendor_id
		  join fnd_lookup_values_vl flv_po_status on flv_po_status.lookup_code = pha.document_status and flv_po_status.view_application_id = 201 and flv_po_status.lookup_type = 'ORDER_STATUS'
		  join hr_locations_all hla_bill on hla_bill.location_id = pha.ship_to_location_id
		 where 1 = 1 
		   and 1 = 1
	  group by hla_bill.location_code
			 , hla_bill.postal_code

-- ##############################################################
-- COUNT BY PO STATUS
-- ##############################################################

		select pha.document_status
			 , flv_po_status.meaning po_status
			 , pha.type_lookup_code po_type
			 , min(to_char(pha.creation_date, 'yyyy-mm-dd')) min_po_created
			 , max(to_char(pha.creation_date, 'yyyy-mm-dd')) max_po_created
			 , count(*)
		  from po_headers_all pha
		  join fnd_lookup_values_vl flv_po_status on flv_po_status.lookup_code = pha.document_status and flv_po_status.view_application_id = 201 and flv_po_status.lookup_type = 'ORDER_STATUS'
	  group by pha.document_status
			 , pha.type_lookup_code
			 , flv_po_status.meaning

-- ##############################################################
-- COUNT LINES BY MATCHING BASIS
-- ##############################################################

		select count(*)
			 , matching_basis
		  from po_lines_all
	  group by matching_basis

-- ##############################################################
-- COUNT SHIPMENTS BY MATCH OPTION
-- ##############################################################

		select count(*)
			 , match_option
		  from po_line_locations_all
	  group by match_option

-- ##############################################################
-- COUNT SHIPMENTS BY ACCRUE ON RECEIPT FLAG
-- ##############################################################

		select count(*)
			 , accrue_on_receipt_flag
		  from po_line_locations_all
	  group by accrue_on_receipt_flag

-- ##############################################################
-- COUNT - SUMMARY
-- ##############################################################

		select distinct pha.segment1 po_num
			 , pha.creation_date
			 , (select count(distinct receipt_num)
				  from rcv_shipment_lines rsl
					 , rcv_shipment_headers rsh
				 where rsl.shipment_header_id = rsh.shipment_header_id
				   and pha.po_header_id = rsl.po_header_id) receipt_count
			 , (select count(distinct aia.invoice_num)
				  from ap_invoices_all aia
					 , ap_invoice_distributions_all aida
					 , po_distributions_all pda
				 where aia.invoice_id = aida.invoice_id
				   and aida.po_distribution_id = pda.po_distribution_id
				   and pda.po_header_id = pha.po_header_id
			  group by pha.segment1) invoice_count
			 , (select sum(pla.amount)
				  from po_lines_all pla
				 where pla.po_header_id = pha.po_header_id
			  group by pha.po_header_id) po_value
			 , (select sum(aida.amount)
				  from ap_invoices_all aia
					 , ap_invoice_distributions_all aida
					 , po_distributions_all pda
				 where aia.invoice_id = aida.invoice_id
				   and aida.po_distribution_id = pda.po_distribution_id
				   and pda.po_header_id = pha.po_header_id
			  group by pha.segment1) matched_value
		  from po_lines_all pla
			 , po_headers_all pha
		 where pha.po_header_id = pla.po_header_id
		   and pha.document_status = 'OPEN'
		   and pha.approved_flag = 'Y'
		   and pha.closed_date is null
	  order by 4 desc;

-- ##############################################################
-- COUNT BY CHART OF ACCOUNT SEGMENT
-- ##############################################################

		select gcc.segment1
			 , gcc.segment2
			 , gcc.segment3
			 , gcc.enabled_flag
			 , gllv.ledger_name
			 , min(to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_po_created
			 , max(to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_po_created
			 , count(pda.po_line_id) ct
		  from gl_code_combinations gcc
	 left join po_distributions_all pda on gcc.code_combination_id = pda.code_combination_id 
	 left join po_lines_all pla on pda.po_line_id = pla.po_line_id
	 left join po_headers_all pha on pla.po_header_id = pha.po_header_id and pda.po_header_id = pha.po_header_id
	 left join gl_ledger_le_v gllv on gllv.chart_of_accounts_id = gcc.chart_of_accounts_id
		 where 1 = 1 
		   and 1 = 1
	  group by gcc.segment1
			 , gcc.segment2
			 , gcc.segment3
			 , gcc.enabled_flag
			 , gllv.ledger_name

-- ##############################################################
-- COUNT BY ITEM ID AND ORG
-- ##############################################################

		select req_bu_id.bu_name req_bu
			 , prc_bu_id.bu_name procurement_bu
			 , nvl2(pla.item_id, 'Y', 'N') item_id_populated
			 , min(to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_po_created
			 , max(to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_po_created
			 , count(*)
		  from po_lines_all pla
		  join po_headers_all pha on pla.po_header_id = pha.po_header_id
		  join fun_all_business_units_v req_bu_id on req_bu_id.bu_id = pha.req_bu_id
		  join fun_all_business_units_v prc_bu_id on prc_bu_id.bu_id = pha.prc_bu_id
		 where 1 = 1 
		   and 1 = 1
	  group by req_bu_id.bu_name
			 , prc_bu_id.bu_name
			 , nvl2(pla.item_id, 'Y', 'N')
