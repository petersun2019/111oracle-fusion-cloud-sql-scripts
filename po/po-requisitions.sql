/*
File Name: po-requisitions.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- TABLE DUMPS
-- REQUISITION HEADERS
-- REQUISITION VALUE
-- REQUISITION CREATION ERRORS
-- REQUISITION HEADERS AND LINES (NO PO TABLE JOINS)
-- REQUISITION HEADERS AND LINES (WITH PO TABLE JOINS)
-- REQUISIONS MAPPED TO CATEGORY ACCOUNT CODE
-- COST CENTRE MAPPINGS ONLY
-- COUNT BY MAPPINGS
-- REQUISITION PREPAPER DETAILS
-- COUNT BY CREATION DATE AND CREATED BY
-- COUNT BY LINES AND LINE TYPE
-- COUNY BY REQUISITION, PROJECT, EXPENDITURE TYPE AND ORG
-- COUNT BY ORG, BUSINESS UNIT AND SEGMENT
-- COUNT BY CREATION_DATE

*/

-- ##############################################################
-- TABLE DUMPS
-- ##############################################################

select * from por_requisition_headers_all where requisition_number = 'REQ1234'
select * from por_requisition_lines_all where requisition_header_id = 123
select * from por_req_distributions_all where requisition_line_id = 123

-- ##############################################################
-- REQUISITION HEADERS
-- ##############################################################

		select prha.requisition_number req
			 , prha.requisition_header_id
			 , bu.bu_name bu
			 , to_char(prha.creation_date,'yyyy-mm-dd hh24:mi:ss') req_created
			 , to_char(prha.last_update_date,'yyyy-mm-dd hh24:mi:ss') req_updated
			 , to_char(prha.approved_date,'yyyy-mm-dd hh24:mi:ss') approved_date
			 , (replace(replace(prha.description,chr(10),''),chr(13),' ')) req_description
			 , (replace(replace(prha.justification,chr(10),''),chr(13),' ')) req_justification
			 , prha.document_status
			 , prha.created_by
			 , ppnfv1.full_name req_preparer
			 , ppnfv1.person_id req_preparer_id
			 , ppnfv2.full_name req_requester
			 , ppnfv2.person_id req_requester_id
		  from por_requisition_headers_all prha
		  join por_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join por_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
		  join gl_code_combinations gcc on prda.code_combination_id = gcc.code_combination_id
		  join egp_categories_tl cat on prla.category_id = cat.category_id
		  join egp_categories_b catb on cat.category_id = catb.category_id
		  join hr_locations_all hla on prla.deliver_to_location_id = hla.location_id
		  join per_person_names_f_v ppnfv1 on ppnfv1.person_id = prha.preparer_id
		  join per_person_names_f_v ppnfv2 on ppnfv2.person_id = prla.requester_id
		  join fun_all_business_units_v bu on bu.bu_id = prha.req_bu_id
		 where 1 = 1
		   and 1 = 1
	  order by prha.requisition_header_id desc

-- ##############################################################
-- REQUISITION VALUE
-- ##############################################################

		select prha.requisition_number req
			 , prha.requisition_header_id
			 , bu.bu_name bu
			 , to_char(prha.creation_date,'yyyy-mm-dd hh24:mi:ss') req_created
			 , to_char(prha.last_update_date,'yyyy-mm-dd hh24:mi:ss') req_updated
			 , to_char(prha.approved_date,'yyyy-mm-dd hh24:mi:ss') approved_date
			 , prha.document_status
			 , prha.created_by
			 , ppnfv1.full_name req_preparer
			 , ppnfv1.person_id req_preparer_id
			 , ppnfv2.full_name req_requester
			 , ppnfv2.person_id req_requester_id
			 , sum(nvl(prla.quantity,prla.amount)*nvl(prla.unit_price,1)) value
			 , count(*) lines
			 , count(distinct prla.category_id) distinct_categories
			 , count(distinct prla.requester_id) requester_count
		  from por_requisition_headers_all prha
		  join por_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join por_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
		  join gl_code_combinations gcc on prda.code_combination_id = gcc.code_combination_id
		  join egp_categories_tl cat on prla.category_id = cat.category_id
		  join egp_categories_b catb on cat.category_id = catb.category_id
		  join hr_locations_all hla on prla.deliver_to_location_id = hla.location_id
		  join per_person_names_f_v ppnfv1 on ppnfv1.person_id = prha.preparer_id
		  join per_person_names_f_v ppnfv2 on ppnfv2.person_id = prla.requester_id
		  join fun_all_business_units_v bu on bu.bu_id = prha.req_bu_id
		 where 1 = 1
		   and 1 = 1
	  group by prha.requisition_number
			 , prha.requisition_header_id
			 , bu.bu_name
			 , to_char(prha.creation_date,'yyyy-mm-dd hh24:mi:ss')
			 , to_char(prha.last_update_date,'yyyy-mm-dd hh24:mi:ss')
			 , to_char(prha.approved_date,'yyyy-mm-dd hh24:mi:ss')
			 , prha.document_status
			 , prha.created_by
			 , ppnfv1.full_name
			 , ppnfv1.person_id
			 , ppnfv2.full_name
			 , ppnfv2.person_id
	  order by to_char(prha.creation_date,'yyyy-mm-dd hh24:mi:ss') desc

-- ##############################################################
-- REQUISITION CREATION ERRORS
-- ##############################################################

		select distinct prha.requisition_number
			 , bu.bu_name bu
			 , cat.category_name
			 , to_char(catb.creation_date,'yyyy-mm-dd') cat_created
			 , to_char(prha.creation_date,'yyyy-mm-dd') req_created
			 , prha.created_by
			 , gcc.segment1
			 , gcc.segment2
			 , gcc.segment3
			 , gcc.segment4
			 , gcc.segment5
			 , hla.effective_start_date
			 , hla.effective_end_date
			 , hla.business_group_id
			 , hla.active_status
			 , hla.ship_to_site_flag
			 , hla.ship_to_location_id
			 , hla.receiving_site_flag
			 , hla.bill_to_site_flag
			 , hla.office_site_flag
			 , hla.location_code
			 , hla.location_name
			 , hla.internal_location_code
			 , hla.address_line_1
			 , hla.country
			 , hla.town_or_city
		  from por_requisition_headers_all prha
		  join por_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join por_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
		  join gl_code_combinations gcc on prda.code_combination_id = gcc.code_combination_id
		  join egp_categories_tl cat on prla.category_id = cat.category_id
		  join egp_categories_b catb on cat.category_id = catb.category_id
		  join hr_locations_all hla on prla.deliver_to_location_id = hla.location_id
		  join po_action_history pah on pah.object_id = prha.requisition_header_id and pah.object_sub_type_code = 'PURCHASE' and pah.object_type_code = 'REQ' and pah.action_code = 'REJECT' and pah.note = 'Approvals encountered an error.'
		  join fun_all_business_units_v bu on bu.bu_id = prha.req_bu_id
		 where 1 = 1
		   and prha.document_status = 'REJECTED'
		   and 1 = 1
	  order by to_char(prha.creation_date,'yyyy-mm-dd') desc

-- ##############################################################
-- REQUISITION HEADERS AND LINES (NO PO TABLE JOINS)
-- ##############################################################

		select prha.requisition_number
			 , prha.requisition_header_id
			 , prha.document_status
			 , bu.bu_name bu
			 , haou.name org
			 , psv.vendor_name supplier
			 , cat.category_name
			 , cat.creation_date cat_created
			 , to_char(prha.creation_date,'yyyy-mm-dd') req_created
			 , to_char(prha.approved_date, 'yyyy-mm-dd') req_approved
			 , prha.created_by
			 , hla.location_code
			 , prla.quantity
			 , prla.unit_price
			 , prla.amount
			 , prla.line_number req_line
			 , prla.source_doc_header_id
			 , prla.source_doc_line_id
			 , prla.requisition_line_id
			 , gcc.segment1
			 , gcc.segment2
			 , gcc.segment3
			 , gcc.segment4
			 , gcc.segment5
			 , (replace(replace(prla.item_description,chr(10),''),chr(13),' ')) item_description
			 , esib.item_number
			 , esit.description inv_item_descr
		  from por_requisition_headers_all prha
		  join por_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join por_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
		  join gl_code_combinations gcc on prda.code_combination_id = gcc.code_combination_id
		  join egp_categories_tl cat on prla.category_id = cat.category_id
		  join egp_categories_b catb on cat.category_id = catb.category_id
		  join hr_locations_all hla on prla.deliver_to_location_id = hla.location_id
		  join poz_suppliers_v psv on prla.vendor_id = psv.vendor_id 
	 left join hr_all_organization_units haou on prda.pjc_organization_id = haou.organization_id
	 left join fun_all_business_units_v bu on bu.bu_id = prha.req_bu_id
	 left join egp_system_items_b esib on esib.inventory_item_id = prla.item_id and esib.organization_id = prla.destination_organization_id
	 left join egp_system_items_tl esit on esit.inventory_item_id = esib.inventory_item_id and esit.organization_id = esib.organization_id and esit.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  order by to_char(prha.creation_date,'yyyy-mm-dd') desc

-- ##############################################################
-- REQUISITION HEADERS AND LINES (WITH PO TABLE JOINS)
-- ##############################################################

		select prha.requisition_number
			 , prha.requisition_header_id
			 , prha.document_status
			 , bu.bu_name bu
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , cat.category_name
			 , cat.creation_date cat_created
			 , to_char(prha.creation_date,'yyyy-mm-dd') req_created
			 , to_char(prha.approved_date, 'yyyy-mm-dd') req_approved
			 , prha.created_by
			 , prha.funds_status header_funds_status
			 , prha.funds_chk_fail_warn_flag
			 , prha.funds_override_approver_id
			 , prha.insufficient_funds_flag
			 , prha.lifecycle_status
			 , hla.location_code
			 , prla.quantity
			 , prla.unit_price
			 , prla.amount
			 , prla.line_status
			 , prla.funds_status line_funds_status
			 , prla.line_number req_line
			 , prla.source_doc_header_id
			 , prla.source_doc_line_id
			 , prla.requisition_line_id
			 , gcc.segment1
			 , gcc.segment2
			 , gcc.segment3
			 , gcc.segment4
			 , gcc.segment5
			 , gcc.segment6
			 , (replace(replace(prla.item_description,chr(10),''),chr(13),' ')) item_description
			 , esib.item_number
			 , esit.description inv_item_descr
			 , '#' project_info____
			 , ppav.segment1 proj_number
			 , ptv.task_number
			 , ptv.task_name
			 , ptv.chargeable_flag
			 , ppav.name proj_name
			 , to_char(ppav.start_date, 'yyyy-mm-dd') proj_start_date
			 , to_char(ppav.completion_date, 'yyyy-mm-dd') proj_completion_date
			 , to_char(ppav.closed_date, 'yyyy-mm-dd') proj_closed_date
			 , to_char(ptv.start_date, 'yyyy-mm-dd') task_start_date
			 , to_char(ptv.completion_date, 'yyyy-mm-dd') task_completion_date
			 , ppav.project_status_code
			 , petl.expenditure_type_name
			 , haou.name exp_org
			 , to_char(prda.pjc_expenditure_item_date, 'yyyy-mm-dd') expenditure_item_date
			 , prda.funds_status dist_funds_status
			 , to_char(prda.budget_date, 'yyyy-mm-dd') budget_date
			 , '#' po___
			 , pha.segment1 po_num
			 , pha.amount_released
			 , pha.blanket_total_amount
			 , pha.amount_limit
			 , pla.component_amount_released
			 , pla.amount_released pla_amount_released
		  from por_requisition_headers_all prha
	 left join por_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
	 left join por_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
	 left join gl_code_combinations gcc on prda.code_combination_id = gcc.code_combination_id
	 left join egp_categories_tl cat on prla.category_id = cat.category_id
	 left join egp_categories_b catb on cat.category_id = catb.category_id
	 left join hr_locations_all hla on prla.deliver_to_location_id = hla.location_id
	 left join poz_suppliers_v psv on prla.vendor_id = psv.vendor_id 
	 left join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and prla.vendor_site_id = pssam.vendor_site_id
	 left join pjf_projects_all_vl ppav on prda.pjc_project_id = ppav.project_id
	 left join pjf_tasks_v ptv on ppav.project_id = ptv.project_id and prda.pjc_task_id = ptv.task_id
	 left join pjf_exp_types_tl petl on prda.pjc_expenditure_type_id = petl.expenditure_type_id
	 left join hr_all_organization_units haou on prda.pjc_organization_id = haou.organization_id
	 left join fun_all_business_units_v bu on bu.bu_id = prha.req_bu_id
	 left join po_headers_all pha on pha.po_header_id = prla.source_doc_header_id
	 left join po_lines_all pla on pla.po_line_id = prla.source_doc_line_id
	 left join egp_system_items_b esib on esib.inventory_item_id = prla.item_id and esib.organization_id = prla.destination_organization_id
	 left join egp_system_items_tl esit on esit.inventory_item_id = esib.inventory_item_id and esit.organization_id = esib.organization_id and esit.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  order by to_char(prha.creation_date,'yyyy-mm-dd') desc

-- ##############################################################
-- REQUISIONS MAPPED TO CATEGORY ACCOUNT CODE
-- ##############################################################

		select bu.bu_name
			 , prha.requisition_number 
			 , prha.document_status
			 , psv.vendor_name supplier
			 , cat.category_name
			 , mapping.value_constant cat_mapping_account_code
			 , cat.creation_date cat_created
			 , to_char(prha.creation_date,'yyyy-mm-dd') req_created
			 , prha.created_by
			 , prla.amount
			 , prla.line_number req_line
			 , gcc.segment1
			 , gcc.segment2
			 , gcc.segment3
		  from por_requisition_headers_all prha
		  join por_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join por_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
		  join gl_code_combinations gcc on prda.code_combination_id = gcc.code_combination_id
		  join egp_categories_tl cat on prla.category_id = cat.category_id and cat.language = userenv('lang')
		  join egp_categories_b catb on cat.category_id = catb.category_id
		  join poz_suppliers_v psv on prla.vendor_id = psv.vendor_id 
		  join fun_all_business_units_v bu on bu.bu_id = prha.req_bu_id
		  join (select value_constant
					 , input_value_constant1
					 , input_value_constant2
				  from xla_mapping_set_values xmsv
				 where mapping_set_code = 'XX_SUBJECTIVE_MAPPING' -- THIS IS DIFFERENT FOR EACH CUSTOMER
				   and nvl(xmsv.effective_end_date, sysdate + 1) > sysdate) mapping on mapping.input_value_constant1 = cat.category_id
		 where 1 = 1
		   and 1 = 1
	  order by to_char(prha.creation_date,'yyyy-mm-dd') desc

-- ##############################################################
-- COST CENTRE MAPPINGS ONLY
-- ##############################################################

		select xmsv.value_constant
			 , ect.category_name
			 , ecb.description
			 , ecb.disable_date
			 , ecb.enabled_flag
			 , ecb.segment1
			 , ecb.segment2
			 , ecb.segment3
			 , to_char(ecb.start_date_active, 'yyyy-mm-dd') start_date_active
			 , to_char(ecb.end_date_active, 'yyyy-mm-dd') end_date_active
		  from xla_mapping_set_values xmsv
		  join egp_categories_b ecb on xmsv.input_value_constant1 = ecb.category_id
		  join egp_categories_tl ect on ect.category_id = ecb.category_id and ect.language = userenv('lang')
		 where 1 = 1
		   and xmsv.mapping_set_code = 'XX_SUBJECTIVE_MAPPING' -- THIS IS DIFFERENT FOR EACH CUSTOMER
		   and nvl(xmsv.effective_end_date, sysdate + 1) > sysdate
		   -- and xmsv.value_constant in ('123')
		   and 1 = 1

-- ##############################################################
-- COUNT BY MAPPINGS
-- ##############################################################

		select xmsv.value_constant value_
			 , ect.category_name
			 , bu.bu_name bu
			 , count (distinct prha.requisition_header_id) req_count
			 , min(to_char(prha.creation_date, 'yyyy-mm-dd')) min_req_created
			 , max(to_char(prha.creation_date, 'yyyy-mm-dd')) max_req_created
			 , min(prha.requisition_number) min_req
			 , max(prha.requisition_number) max_req
		  from xla_mapping_set_values xmsv
		  join egp_categories_b ecb on xmsv.input_value_constant1 = ecb.category_id
		  join egp_categories_tl ect on ect.category_id = ecb.category_id and ect.language = userenv('lang')
	 left join por_requisition_lines_all prla on prla.category_id = ecb.category_id
	 left join por_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
	 left join fun_all_business_units_v bu on bu.bu_id = prha.req_bu_id
		 where 1 = 1
		   and xmsv.mapping_set_code = 'XX_SUBJECTIVE_MAPPING' -- THIS IS DIFFERENT FOR EACH CUSTOMER
		   and nvl(xmsv.effective_end_date, sysdate + 1) > sysdate
		   and ecb.enabled_flag = 'Y'
		   and ecb.disable_date is null
		   and 1 = 1
	  group by xmsv.value_constant
			 , ect.category_name
			 , bu.bu_name

-- ##################################################################
-- REQUISITION PREPAPER DETAILS
-- ##################################################################

/*
Requisitions are created by the preparer
The preparer is stored at requisition header, and the preparer_id is the hr person_id for the user raising the req
The requester is the person who the requisition is being created on behalf of.
The requester is stored at requisition line level
In iproc, in a requisition, the preparer means the person who is preparing the requisition.
Requestor is someone who is requesting the item.
Preparer and requestor may be different if the person (preparer) is preparing a requisition for an item requested by someone else (requestor).
*/

		select prha.requisition_number req
			 , prha.requisition_header_id
			 , bu.bu_name bu
			 , to_char(prha.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , prla.line_number line
			 , to_char(prla.creation_date, 'yyyy-mm-dd hh24:mi:ss') line_created
			 , prha.created_by
			 , pu.person_id created_by_person_id
			 , ppnf_creation.full_name created_by_name
			 , prha.preparer_id
			 , ppnf_preparer.full_name p_name
		  from por_requisition_headers_all prha
		  join por_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join per_users pu on pu.username = prha.created_by
		  join fun_all_business_units_v bu on bu.bu_id = prha.req_bu_id
	 left join per_person_names_f ppnf_creation on pu.person_id = ppnf_creation.person_id and ppnf_creation.name_type = 'GLOBAL' and sysdate between ppnf_creation.effective_start_date and ppnf_creation.effective_end_date
	 left join per_person_names_f ppnf_preparer on prha.preparer_id = ppnf_preparer.person_id and ppnf_preparer.name_type = 'GLOBAL' and sysdate between ppnf_preparer.effective_start_date and ppnf_preparer.effective_end_date
		 where 1 = 1
		   and 1 = 1

-- ##################################################################
-- REQUISITION INTERFACE
-- ##################################################################

select * from por_req_headers_interface_all
select * from por_req_lines_interface_all
select * from por_req_lines_interface_all where item_number is not null
select * from por_req_dists_interface_all

		select prhia.req_header_interface_id
			 , prhia.interface_header_key
			 , prhia.process_flag
			 , prhia.interface_source_code
			 , prhia.document_status
			 , prhia.batch_id
			 , prhia.attribute2
			 , prhia.req_bu_name
			 , to_char(prhia.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , prhia.created_by
			 , prhia.request_id
			 , prhia.preparer_email_addr
			 , prhia.description
			 , '#' lines_____
			 , prlia.attribute10
			 , prlia.request_id line_request_id
			 , prlia.load_request_id
			 , prlia.quantity
			 , prlia.category_name
			 , prlia.line_type
			 , prlia.destination_organization_code
			 , prlia.deliver_to_location_code
			 , prlia.suggested_vendor_name
			 , prlia.suggested_vendor_site
			 , prlia.item_number
			 , prlia.item_description
			 , '#' dists______
			 , prdia.req_dist_interface_id
			 , prdia.distribution_id
			 , prdia.interface_distribution_key
			 , '#' || prdia.charge_account_segment1 charge_account_segment1
			 , '#' || prdia.charge_account_segment2 charge_account_segment2
			 , '#' || prdia.charge_account_segment3 charge_account_segment3
			 , '#' || prdia.charge_account_segment4 charge_account_segment4
			 , '#' || prdia.charge_account_segment5 charge_account_segment5
			 , '#' || prdia.charge_account_segment6 charge_account_segment6
			 , prdia.percent percent_
			 , prdia.distribution_quantity
			 , prdia.pjc_project_number
			 , prdia.pjc_project_name
			 , prdia.pjc_task_number
			 , prdia.pjc_expenditure_type_name
			 , to_char(prdia.pjc_expenditure_item_date, 'yyyy-mm-dd') pjc_expenditure_item_date
		  from por_req_headers_interface_all prhia
		  join por_req_lines_interface_all prlia on prlia.req_header_interface_id = prhia.req_header_interface_id
		  join por_req_dists_interface_all prdia on prdia.req_line_interface_id = prlia.req_line_interface_id
		 where 1 = 1
		   and 1 = 1
	  order by prhia.creation_date desc

-- ##############################################################
-- COUNT BY CREATION DATE AND CREATED BY
-- ##############################################################

		select to_char(prha.creation_date, 'yyyy-mm-dd')
			 , prha.created_by
			 , count(*)
		  from por_requisition_headers_all prha
		 where 1 = 1
		   and 1 = 1
	  group by to_char(prha.creation_date, 'yyyy-mm-dd')
			 , prha.created_by
	  order by to_char(prha.creation_date, 'yyyy-mm-dd') desc
			 , prha.created_by

-- ##############################################################
-- COUNT BY LINES AND LINE TYPE
-- ##############################################################

		select prla.product_type
			 , pltt.line_type
			 , prla.source_document_type
			 , prla.order_type_lookup_code
			 , prla.purchase_basis
			 , prla.item_source
			 , min(to_char(prla.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_req_min
			 , max(to_char(prla.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_req_max
			 , count(*) ct
		  from por_requisition_lines_all prla
	 left join po_line_types_tl pltt on pltt.line_type_id = prla.line_type_id and pltt.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by prla.product_type
			 , pltt.line_type
			 , prla.source_document_type
			 , prla.order_type_lookup_code
			 , prla.purchase_basis
			 , prla.item_source

-- ##############################################################
-- COUNY BY REQUISITION, PROJECT, EXPENDITURE TYPE AND ORG
-- ##############################################################

		select prha.requisition_number req
			 , prha.creation_date req_created
			 , bu.bu_name bu
			 , ppav.segment1 project
			 , petl.expenditure_type_name
			 , haou.name exp_org
			 , prha.document_status req_status
			 , count(*) lines
		  from por_requisition_headers_all prha
		  join por_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join por_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
		  join fun_all_business_units_v bu on bu.bu_id = prha.req_bu_id
		  join pjf_projects_all_vl ppav on prda.pjc_project_id = ppav.project_id
		  join pjf_tasks_v ptv on ppav.project_id = ptv.project_id and prda.pjc_task_id = ptv.task_id
		  join pjf_exp_types_tl petl on prda.pjc_expenditure_type_id = petl.expenditure_type_id
		  join hr_all_organization_units haou on prda.pjc_organization_id = haou.organization_id
		 where 1 = 1
		   and 1 = 1
	  group by prha.requisition_number
			 , prha.creation_date
			 , bu.bu_name
			 , ppav.segment1
			 , petl.expenditure_type_name
			 , haou.name
			 , prha.document_status
	  order by prha.creation_date desc

-- ##############################################################
-- COUNT BY ORG, BUSINESS UNIT AND SEGMENT
-- ##############################################################

		select haou.name
			 , bu.bu_name
			 , gcc.segment3 cc
			 , count(distinct prha.requisition_header_id) req_count
			 , min(to_char(prha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_inv_created
			 , max(to_char(prha.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_inv_created
		  from por_requisition_headers_all prha
		  join por_requisition_lines_all prla on prha.requisition_header_id = prla.requisition_header_id
		  join por_req_distributions_all prda on prla.requisition_line_id = prda.requisition_line_id
		  join hr_all_organization_units haou on haou.organization_id = prda.pjc_organization_id
		  join fun_all_business_units_v bu on bu.bu_id = prha.req_bu_id
		  join gl_code_combinations gcc on prda.code_combination_id = gcc.code_combination_id
		 where 1 = 1
		   and 1 = 1
	  group by haou.name
			 , bu.bu_name
			 , gcc.segment3

-- ##############################################################
-- COUNT BY CREATION_DATE
-- ##############################################################

		select to_char(prha.creation_date, 'yyyy-mm-dd') created
			 , min(prha.requisition_number) min_req_num
			 , max(prha.requisition_number) max_req_num
			 , min(prha.created_by) min_created_by
			 , max(prha.created_by) max_created_by
			 , count(*) requsition_count
		  from por_requisition_headers_all prha
		 where 1 = 1
		   and 1 = 1
	  group by to_char(prha.creation_date, 'yyyy-mm-dd')
	  order by to_char(prha.creation_date, 'yyyy-mm-dd') desc
