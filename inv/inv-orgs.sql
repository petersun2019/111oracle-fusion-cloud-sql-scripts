/*
File Name: inv-orgs.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- INVENTORY ORGS QUERY
-- INVENTORY ORGS VIEW

*/

-- ##################################################################
-- INVENTORY ORGS QUERY
-- ##################################################################

		select hou.organization_id org_id
			 , bu.bu_name business_unit_name
			 , to_char(hou.effective_start_date, 'yyyy-mm-dd') start_date
			 , to_char(hou.effective_end_date, 'yyyy-mm-dd') disable_date
			 , mp.organization_code org_code
			 , hou.name org_name
			 , lgr.ledger_id
			 , lgr.chart_of_accounts_id
			 , lgr.currency_code
			 , lgr.period_set_name
			 , decode(hoi1.status, 'A', 'Y', 'N') inventory_enabled_flag
			 , hla.location_code
			 , mp.created_by
			 , to_char(mp.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , mp.last_updated_by
			 , to_char(mp.last_update_date, 'yyyy-mm-dd hh24:mi:ss') inv_last_update_date
		  from hr_all_organization_units_x hou
		  join hr_org_unit_classifications_x hoi1 on hou.organization_id = hoi1.organization_id and hoi1.classification_code = 'INV'
		  join inv_org_parameters mp on hou.organization_id = mp.organization_id
	 left join fun_all_business_units_v bu on bu.bu_id = mp.business_unit_id
	 left join gl_ledgers lgr on bu.primary_ledger_id = lgr.ledger_id and lgr.object_type_code = 'L' and nvl(lgr.complete_flag, 'Y') = 'Y'
	 left join hr_locations_all hla on hla.location_id = hou.location_id
		 where 1 = 1

-- ##################################################################
-- INVENTORY ORGS VIEW
-- ##################################################################

select * from inv_organization_definitions_v 
