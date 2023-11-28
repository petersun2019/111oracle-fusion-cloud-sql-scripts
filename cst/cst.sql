/*
File Name: cst.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- COST TRANSACTIONS
-- COST TRANSACTIONS - DISTRIBUTIONS
-- PERIOD CLOSE ACTIONS
-- PERIOD CLOSE ACTIONS - STUCK IN "PENDING INTERFACE" STATUS

*/

-- ##################################################################
-- COST TRANSACTIONS
-- ##################################################################

		select cit.cst_inv_transaction_id
			 , inv_orgs.organization_code inv_org
			 , inv_items.item_number
			 , inv_items_info.description item_description
			 , cit.subinventory_code subinv
			 , locations.segment1 || '.' || locations.segment2 || '.' || locations.segment3 || '.' || locations.segment4 locator
			 , to_char(cit.transaction_date, 'yyyy-mm-dd') transaction_date
			 , to_char(cit.creation_date, 'yyyy-mm-dd hh24:mi:ss') trx_created
			 , cit.created_by trx_created_by
			 , trx_types.transaction_type_name trx_type
			 , cit.transaction_qty trx_qty
			 , cit.transaction_uom_code trx_uom
			 , projects.segment1 project
			 , proj_tasks.task_number task
			 , exp_type.expenditure_type_name exp_type
			 , to_char(cit.pjc_expenditure_item_date) proj_expenditure_item_date
			 , proj_orgs.name proj_expend_org
			 , cit.external_system_reference
			 , cit.txn_group_id
			 , cit.txn_source_doc_type
			 , cit.txn_source_doc_number
			 , cit.pjc_context_category
		  from cst_inv_transactions cit
	 left join inv_organization_definitions_v inv_orgs on inv_orgs.organization_id = cit.inventory_org_id
	 left join egp_system_items_b inv_items on inv_items.inventory_item_id = cit.inventory_item_id and inv_items.organization_id = inv_orgs.organization_id
	 left join egp_system_items_tl inv_items_info on inv_items_info.inventory_item_id = inv_items.inventory_item_id and inv_items_info.organization_id = inv_items.organization_id and inv_items_info.language = userenv('lang')
	 left join pjf_projects_all_vl projects on projects.project_id = cit.pjc_project_id
	 left join pjf_tasks_v proj_tasks on projects.project_id = proj_tasks.project_id and cit.pjc_task_id = proj_tasks.task_id
	 left join pjf_exp_types_tl exp_type on cit.pjc_expenditure_type_id = exp_type.expenditure_type_id and exp_type.language = userenv('lang')
	 left join hr_all_organization_units proj_orgs on proj_orgs.organization_id = pjc_organization_id
	 left join inv_txn_source_types_tl trx_src on trx_src.transaction_source_type_id = cit.inv_txn_source_type_id and trx_src.language = userenv('lang')
	 left join inv_transaction_types_tl trx_types on trx_types.transaction_type_id = cit.base_txn_type_id and trx_types.language = userenv('lang')
	 left join inv_item_locations locations on locations.inventory_location_id = cit.locator_id
		 where 1 = 1
		   and 1 = 1
	  order by cit.creation_date desc

-- ##################################################################
-- COST TRANSACTIONS - DISTRIBUTIONS
-- ##################################################################

		select inv_orgs.organization_code inv_org
			 , inv_items.item_number
			 , inv_items_info.description item_description
			 , cit.subinventory_code subinv
			 , locations.segment1 || '.' || locations.segment2 || '.' || locations.segment3 || '.' || locations.segment4 locator
			 , to_char(cit.transaction_date, 'yyyy-mm-dd') transaction_date
			 , to_char(cit.creation_date, 'yyyy-mm-dd hh24:mi:ss') trx_created
			 , cit.created_by trx_created_by
			 , trx_types.transaction_type_name trx_type
			 , cit.transaction_qty trx_qty
			 , cit.transaction_uom_code trx_uom
			 , projects.segment1 project
			 , proj_tasks.task_number task
			 , exp_type.expenditure_type_name exp_type
			 , to_char(cit.pjc_expenditure_item_date) proj_expenditure_item_date
			 , proj_orgs.name proj_expend_org
			 , cit.cst_inv_transaction_id
			 , cit.external_system_reference
			 , cit.txn_group_id
			 , cit.txn_source_doc_type
			 , cit.txn_source_doc_number
			 , cit.pjc_context_category
			 , '#' distributions___
			 , dists.distribution_id
			 , dists.request_id
			 , dists.event_id
			 , dists.entity_code
			 , dists.event_class_code
			 , dists.event_type_code
			 , dists.cost_transaction_type
			 , dists.transaction_number
			 , to_char(dists.creation_date, 'yyyy-mm-dd hh24:mi:ss') dist_created
			 , dists.created_by dist_created_by
		  from cst_inv_transactions cit
	 left join inv_organization_definitions_v inv_orgs on inv_orgs.organization_id = cit.inventory_org_id
	 left join egp_system_items_b inv_items on inv_items.inventory_item_id = cit.inventory_item_id and inv_items.organization_id = inv_orgs.organization_id and cit.inventory_org_id = inv_items.organization_id
	 left join egp_system_items_tl inv_items_info on inv_items_info.inventory_item_id = inv_items.inventory_item_id and inv_items_info.organization_id = inv_items.organization_id and inv_items_info.language = userenv('lang')
	 left join pjf_projects_all_vl projects on projects.project_id = cit.pjc_project_id
	 left join pjf_tasks_v proj_tasks on projects.project_id = proj_tasks.project_id and cit.pjc_task_id = proj_tasks.task_id
	 left join pjf_exp_types_tl exp_type on cit.pjc_expenditure_type_id = exp_type.expenditure_type_id and exp_type.language = userenv('lang')
	 left join hr_all_organization_units proj_orgs on proj_orgs.organization_id = pjc_organization_id
	 left join inv_txn_source_types_tl trx_src on trx_src.transaction_source_type_id = cit.inv_txn_source_type_id and trx_src.language = userenv('lang')
	 left join inv_transaction_types_tl trx_types on trx_types.transaction_type_id = cit.base_txn_type_id and trx_types.language = userenv('lang')
	 left join inv_item_locations locations on locations.inventory_location_id = cit.locator_id
	 left join cst_cost_distributions dists on dists.transaction_id = cit.cst_inv_transaction_id -- and dists.cost_organization_id = cit.inventory_org_id
		 where 1 = 1
		   and 1 = 1
	  order by cit.creation_date desc

-- ##################################################################
-- PERIOD CLOSE ACTIONS
-- ##################################################################

		select cpsa.period_name
			 , cpsa.run_id
			 , to_char(cpsa.creation_date, 'yyyy-mm-dd hh24:mi:ss') created
			 , cpsa.created_by
			 , to_char(cpsa.last_update_date, 'yyyy-mm-dd hh24:mi:ss') updated
			 , cpsa.last_updated_by
			 , cpsa.from_status_code
			 , cpsa.to_status_code
			 , cpsa.process_status_code
			 , cpsa.inv_pending_count
			 , cpsa.uncosted_txn_count
			 , cpsa.journals_pending_count
			 , cpsa.pending_intf_txn_count
		  from cst_period_close_actions cpsa
	  order by cpsa.run_id desc

-- ##################################################################
-- PERIOD CLOSE ACTIONS - STUCK IN "PENDING INTERFACE" STATUS
-- ##################################################################

/*
Fusion CST: Pending Interface Error For Source-Payables (Doc ID 2679235.1)
Run "Transfer Costs to Cost Management" program to clear issues
*/

		select count(*)
		  from ap_invoice_distributions_all aid
		  join ap_invoice_lines_all ail on ail.invoice_id = aid.invoice_id and ail.line_number = aid.invoice_line_number
		  join ap_invoices_all ai on ai.invoice_id = ail.invoice_id
		  join po_distributions_all pod on aid.po_distribution_id = pod.po_distribution_id
		  join po_line_locations_all poll on pod.line_location_id = poll.line_location_id
		  join cst_cost_inv_orgs ccio on pod.destination_organization_id = ccio.inv_org_id
		 where 1 = 1
		   and nvl(aid.inventory_transfer_status,'N') = 'N'
		   and aid.posted_flag = 'Y'
		   and (aid.po_distribution_id is not null
			 or aid.rcv_transaction_id is not null
			 or ail.lcm_enabled_flag ='Y')
		   and trunc(aid.accounting_date) < sysdate - 30 ----[modify the accounting date accordingly ]
		   and nvl(ai.invoice_type_lookup_code,'X') <> 'PREPAYMENT'
		   and aid.prepay_distribution_id is null
		   and ccio.cost_org_id = 123 --[pass the impacted cost_org_id fetched from above query]
		   and 1 = 1

-- ##################################################################
-- COST INV ORGS
-- ##################################################################

select * from cst_cost_inv_orgs
select * from cst_organization_definitions_v
