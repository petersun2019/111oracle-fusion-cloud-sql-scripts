/*
File Name: po-purchase-orders-housekeeping.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- PO DATA
-- PO AND REQ DATA

*/

-- ##############################################################
-- PO DATA
-- ##############################################################

/*
I find this useful for listing Purchase Orders along with their status, value, and their receipted and billed values too.
Can be useful when you need e.g. test data, to find POs which have been receipted, but not billed, for example.
*/

		select my_data.po
			 , my_data.bu
			 -- , my_data.line
			 , to_char(my_data.po_created, 'yyyy-mm-dd HH24:MI:SS') po_created
			 , my_data.match_approval_level
			 , my_data.po_status
			 , my_data.supplier
			 , sum(my_data.line_value) doc_value
			 , sum(my_data.assessable_value) assessable_value
			 , sum(my_data.received) received
			 , sum(my_data.billed) billed
			 , count(*) lines
		  from (select pha.segment1 po
					 , pha.creation_date po_created
					 , pha.document_status po_status
					 -- , pla.line_num line
					 , pv.vendor_name supplier
					 , bu.bu_name bu
					 , nvl(case when (plla.quantity is null and pla.unit_price is null) then 'AMOUNT'
							when (plla.amount is null) then 'QUANTITY'
					   end, 0) label
					 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount
							when (plla.amount is null) then pla.unit_price * plla.quantity
					   end, 0) line_value
					 , nvl(plla.assessable_value, 0) assessable_value
					 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount_received
							when (plla.amount is null) then pla.unit_price * plla.quantity_received
					   end, 0) received
					 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount_billed
							when (plla.amount is null) then pla.unit_price * plla.quantity_billed
					   end, 0) billed
					 , case when plla.receipt_required_flag = 'N' then '2-Way'
							when plla.receipt_required_flag = 'Y' and plla.inspection_required_flag = 'N' then '3-Way'
							when plla.receipt_required_flag = 'Y' and plla.inspection_required_flag = 'Y' then '4-Way'
					   end match_approval_level -- prc:po:where is po match approval level stored? (doc id 2092176.1)
				  from po_headers_all pha
				  join po_lines_all pla on pha.po_header_id = pla.po_header_id
				  join poz_suppliers_v pv on pha.vendor_id = pv.vendor_id
				  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id
				  join fun_all_business_units_v bu on bu.bu_id = pha.req_bu_id
				 where 1 = 1
				   and pha.document_status = 'OPEN'
				   and pha.type_lookup_code = 'STANDARD'
				   and 1 = 1) my_data
	  group by my_data.po
			 , my_data.bu
			 -- , my_data.line
			 , my_data.po_created
			 , my_data.match_approval_level
			 , my_data.po_status
			 , my_data.supplier
		having sum(my_data.billed) = 0 and sum(my_data.received) > 0

-- ##############################################################
-- PO AND REQ DATA
-- ##############################################################

/*
Same as above but also includes requisition linked to the Purchase Order.
*/

		select my_data.po
			 , my_data.bu
			 , my_data.line
			 , to_char(my_data.po_created, 'yyyy-mm-dd HH24:MI:SS') po_created
			 , my_data.match_approval_level
			 , my_data.po_status
			 , my_data.supplier
			 , my_data.req
			 -- , my_data.req_header_id
			 , my_data.req_created_by
			 , my_data.req_status
			 , my_data.req_created
			 , sum(my_data.line_value) doc_value
			 -- , sum(my_data.assessable_value) assessable_value
			 , sum(my_data.received) received
			 , sum(my_data.billed) billed
			 , count(*) lines
		  from (select pha.segment1 po
					 , pha.creation_date po_created
					 , pha.document_status po_status
					 , pla.line_num line
					 , pv.vendor_name supplier
					 , prha.requisition_number req
					 , prha.creation_date req_created
					 , prha.document_status req_status
					 , prha.requisition_header_id req_header_id
					 , prha.created_by req_created_by
					 , bu.bu_name bu
					 , nvl(case when (plla.quantity is null and pla.unit_price is null) then 'AMOUNT'
							when (plla.amount is null) then 'QUANTITY'
					   end, 0) label
					 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount
							when (plla.amount is null) then pla.unit_price * plla.quantity
					   end, 0) line_value
					 -- , nvl(plla.assessable_value, 0) assessable_value
					 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount_received
							when (plla.amount is null) then pla.unit_price * plla.quantity_received
					   end, 0) received
					 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount_billed
							when (plla.amount is null) then pla.unit_price * plla.quantity_billed
					   end, 0) billed
					 , case when plla.receipt_required_flag = 'N' then '2-Way'
							when plla.receipt_required_flag = 'Y' and plla.inspection_required_flag = 'N' then '3-Way'
							when plla.receipt_required_flag = 'Y' and plla.inspection_required_flag = 'Y' then '4-Way'
					   end match_approval_level -- prc:po:where is po match approval level stored? (doc id 2092176.1)
				  from po_headers_all pha
				  join po_lines_all pla on pha.po_header_id = pla.po_header_id
				  join poz_suppliers_v pv on pha.vendor_id = pv.vendor_id
				  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id
				  join fun_all_business_units_v bu on bu.bu_id = pha.req_bu_id
			 left join por_requisition_lines_all prla on prla.po_header_id = pha.po_header_id and prla.po_line_id = pla.po_line_id
			 left join por_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
				 where 1 = 1
				   and 1 = 1) my_data
	  group by my_data.po
			 , my_data.bu
			 , my_data.line
			 , my_data.po_created
			 , my_data.match_approval_level
			 , my_data.po_status
			 , my_data.supplier
			 , my_data.req
			 -- , my_data.req_header_id
			 , my_data.req_created_by
			 , my_data.req_status
			 , my_data.req_created
		-- having sum(my_data.billed) = 0 and sum(my_data.received) = 0
	  order by my_data.po_created desc

-- ##############################################################
-- PO AND REQ AND PROJECT DATA
-- ##############################################################

/*
Same as above but also includes requisition linked to the Purchase Order.
*/

		select my_data.po
			 , my_data.bu
			 , to_char(my_data.po_created, 'yyyy-mm-dd HH24:MI:SS') po_created
			 , my_data.match_approval_level
			 , my_data.po_status
			 , my_data.supplier
			 , my_data.project
			 , my_data.req
			 -- , my_data.req_header_id
			 , my_data.req_created_by
			 , my_data.req_status
			 , my_data.req_created
			 , sum(my_data.line_value) doc_value
			 -- , sum(my_data.assessable_value) assessable_value
			 , sum(my_data.received) received
			 , sum(my_data.billed) billed
			 , count(*) lines
		  from (select pha.segment1 po
					 , pha.creation_date po_created
					 , pha.document_status po_status
					 , pv.vendor_name supplier
					 , ppav.segment1 project
					 , prha.requisition_number req
					 , prha.creation_date req_created
					 , prha.document_status req_status
					 , prha.requisition_header_id req_header_id
					 , prha.created_by req_created_by
					 , bu.bu_name bu
					 , nvl(case when (plla.quantity is null and pla.unit_price is null) then 'AMOUNT'
							when (plla.amount is null) then 'QUANTITY'
					   end, 0) label
					 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount
							when (plla.amount is null) then pla.unit_price * plla.quantity
					   end, 0) line_value
					 -- , nvl(plla.assessable_value, 0) assessable_value
					 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount_received
							when (plla.amount is null) then pla.unit_price * plla.quantity_received
					   end, 0) received
					 , nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount_billed
							when (plla.amount is null) then pla.unit_price * plla.quantity_billed
					   end, 0) billed
					 , case when plla.receipt_required_flag = 'N' then '2-Way'
							when plla.receipt_required_flag = 'Y' and plla.inspection_required_flag = 'N' then '3-Way'
							when plla.receipt_required_flag = 'Y' and plla.inspection_required_flag = 'Y' then '4-Way'
					   end match_approval_level -- prc:po:where is po match approval level stored? (doc id 2092176.1)
				  from po_headers_all pha
				  join po_lines_all pla on pha.po_header_id = pla.po_header_id
				  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id and plla.po_header_id = pha.po_header_id
				  join po_distributions_all pda on pla.po_line_id = pda.po_line_id
				  join poz_suppliers_v pv on pha.vendor_id = pv.vendor_id
				  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id
				  join fun_all_business_units_v bu on bu.bu_id = pha.req_bu_id
			 left join por_requisition_lines_all prla on prla.po_header_id = pha.po_header_id and prla.po_line_id = pla.po_line_id
			 left join por_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
			 left join pjf_projects_all_vl ppav on pda.pjc_project_id = ppav.project_id
				 where 1 = 1
				   and 1 = 1) my_data
	  group by my_data.po
			 , my_data.bu
			 , my_data.po_created
			 , my_data.match_approval_level
			 , my_data.po_status
			 , my_data.supplier
			 , my_data.project
			 , my_data.req
			 -- , my_data.req_header_id
			 , my_data.req_created_by
			 , my_data.req_status
			 , my_data.req_created
		-- having sum(my_data.billed) = 0 and sum(my_data.received) = 0
	  order by my_data.po_created desc
