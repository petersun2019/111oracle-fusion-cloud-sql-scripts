/*
File Name: inv-items.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- ITEM DETAILS
-- CREATED BY SUMMARY

*/

-- ##################################################################
-- ITEM DETAILS
-- ##################################################################

		select esib.inventory_item_id
			 , esib.item_number
			 , iodv.organization_code org_code
			 , iodv.organization_name org_name
			 , iodv.business_unit_name bu_name
			 , esib.enabled_flag enabled
			 , esib.inventory_item_status_code
			 , esib.primary_uom_code
			 , esit.description
			 , esit.long_description
			 , esit.template_name
			 , '#' who_data___
			 , to_char(esib.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , esib.created_by
			 , to_char(esib.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , esib.last_updated_by
			 , '#' flags___
			 , esib.purchasing_item_flag
			 , esib.shippable_item_flag
			 , esib.customer_order_flag
			 , esib.internal_order_flag
			 , esib.inventory_item_flag
			 , esib.inventory_asset_flag
			 , esib.purchasing_enabled_flag
			 , esib.customer_order_enabled_flag
			 , esib.internal_order_enabled_flag
			 , esib.so_transactions_flag
			 , esib.mtl_transactions_enabled_flag
			 , esib.stock_enabled_flag
			 , esib.build_in_wip_flag
			 , esib.returnable_flag
			 , esib.allow_item_desc_update_flag
		  from egp_system_items_b esib
		  join inv_organization_definitions_v iodv on iodv.organization_id = esib.organization_id
		  join egp_system_items_tl esit on esit.inventory_item_id = esib.inventory_item_id and esit.organization_id = esib.organization_id and esit.language = userenv('lang')
		  join egp_item_org_associations eioa on eioa.inventory_item_id = esib.inventory_item_id and eioa.item_definition_org_id = esib.organization_id and eioa.inventory_item_id = esit.inventory_item_id and eioa.item_definition_org_id = esit.organization_id -- Storage for Item and Organization Associations.
		 where 1 = 1
		   and iodv.organization_code = 'MST' -- MASTER INV ORG
		   and eioa.change_row_flag = 'N'
		   and esib.template_item_flag = 'N'
		   and esib.approval_status = 'A'
		   and esib.acd_type = 'PROD'
		   and esib.change_line_id = -1
		   and esib.version_id = -1
		   and 1 = 1
	  order by esib.inventory_item_id desc

-- ##################################################################
-- CREATED BY SUMMARY
-- ##################################################################

		select created_by
			 , min(to_char(creation_date, 'yyyy-mm'))
			 , max(to_char(creation_date, 'yyyy-mm'))
			 , count(*)
		  from egp_system_items_b
	  group by created_by
	  order by 4 desc
