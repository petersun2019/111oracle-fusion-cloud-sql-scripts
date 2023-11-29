/*
File Name: inv-transactions.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts
*/

-- ##################################################################
-- INVENTORY TRANSACTIONS
-- ##################################################################

		select imt.inventory_item_id
			 , imt.transaction_id
			 , imt.subinventory_code subinv
			 , iil.segment1 || '.' || iil.segment2 || '.' || iil.segment3 || '.' || iil.segment4 locator
			 , iodv.organization_code org_code
			 , iodv.organization_name org_name
			 , iodv.business_unit_name bu_name
			 , ittt.transaction_type_name trx_type
			 , itstt.description trx_source
			 , imt.transaction_quantity
			 , imt.transaction_uom
			 , to_char(imt.transaction_date, 'yyyy-mm-dd hh24:mi:ss') trx_date
			 , imt.request_id -- Request ID of the job that created or last updated the row
			 , imt.load_request_id -- Request ID of the interface job that created the row
			 , esib.item_number
			 , imt.mvt_stat_status -- Flag to indicate that the transaction is updated/processed/new
			 , imt.source_code
			 , ppav.segment1 project
			 , ptv.task_number task
			 , pett.expenditure_type_name exp_type
			 , to_char(imt.pjc_expenditure_item_date) proj_expenditure_item_date
			 , esit.description item_description
			 -- , '#' who_data___
			 -- , to_char(imt.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 -- , imt.created_by
			 -- , to_char(imt.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 -- , imt.last_updated_by
		  from inv_material_txns imt
		  join egp_system_items_b esib on esib.inventory_item_id = imt.inventory_item_id and esib.organization_id = imt.organization_id
		  join egp_system_items_tl esit on esit.inventory_item_id = esib.inventory_item_id and esit.organization_id = esib.organization_id and esit.language = userenv('lang')
		  join inv_organization_definitions_v iodv on iodv.organization_id = imt.organization_id
	 left join inv_item_locations iil on iil.inventory_location_id = imt.locator_id
	 left join inv_transaction_types_tl ittt on ittt.transaction_type_id = imt.transaction_type_id and ittt.language = userenv('lang')
	 left join inv_txn_source_types_tl itstt on itstt.transaction_source_type_id = imt.transaction_source_type_id and itstt.language = userenv('lang')
	 left join pjf_projects_all_vl ppav on ppav.project_id = imt.pjc_project_id
	 left join pjf_tasks_v ptv on ptv.project_id = ppav.project_id and imt.pjc_task_id = ptv.task_id
	 left join pjf_exp_types_tl pett on pett.expenditure_type_id = imt.pjc_expenditure_type_id and pett.language = userenv('lang')
	  order by imt.creation_date desc
