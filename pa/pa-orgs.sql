/*
File Name: pa-orgs.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- PROJECT ORGANIZATIONS INFO
-- DEPARTMENTS AND WHETHER FLAGGED AS EXPENDITURE ORG, PROJECT ORG OR BOTH

*/

-- ##############################################################
-- PROJECT ORGANIZATIONS INFO
-- ##############################################################

/*
https://cloudcustomerconnect.oracle.com/posts/104def26eb?commentid=382104#382104
*/

		select hov.name
			 , hov.organization_id org_id
			 , to_char(hov.effective_start_date, 'yyyy-mm-dd') effective_start_date
			 , to_char(hov.effective_end_date, 'yyyy-mm-dd') effective_end_date
			 , hov.classification_code
			 , hov.status
			 , to_char(hov.creation_date, 'yyyy-mm-dd hh24:mi:ss') created
			 , hov.created_by
			 , hla.location_name
			 , hla.location_code
		  from hr_organization_v hov
	 left join hr_locations_all hla on hov.location_id = hla.location_id
		 where 1 = 1
		   and hov.classification_code in ('PA_EXPENDITURE_ORG', 'PA_PROJECT_ORG', 'DEPARTMENT')
		   and 1 = 1

-- ##############################################################
-- DEPARTMENTS AND WHETHER FLAGGED AS EXPENDITURE ORG, PROJECT ORG OR BOTH
-- ##############################################################

		select hov.name
			 , hov.organization_id org_id
			 , to_char(hov.effective_start_date, 'yyyy-mm-dd') effective_start_date
			 , to_char(hov.effective_end_date, 'yyyy-mm-dd') effective_end_date
			 , hov.status
			 , hov.classification_code
			 , to_char(hov.creation_date, 'yyyy-mm-dd hh24:mi:ss') created
			 , hov.created_by
			 , hla.location_name
			 , hla.location_code
			 , (select count(*) from pjc_exp_items_all peia where peia.expenditure_organization_id = hov.organization_id) exp_item_count
			 , nvl((select 'Y'
					  from hr_organization_v y
					 where hov.organization_id = y.organization_id
					   and y.classification_code = 'PA_EXPENDITURE_ORG'
					   and sysdate between y.effective_start_date and y.effective_end_date
					   and y.status ='A'), 'N') pa_expenditure_org
			 , nvl((select 'Y'
					  from hr_organization_v y
					 where hov.organization_id = y.organization_id
					   and y.classification_code = 'PA_PROJECT_ORG'
					   and sysdate between y.effective_start_date and y.effective_end_date
					   and y.status ='A'), 'N') pa_project_org
			 , nvl2(pao.organization_id, 'Y', 'N') expenditure_org
		  from hr_organization_v hov
	 left join hr_locations_all hla on hov.location_id = hla.location_id
	 left join pjf_all_organizations pao on pao.organization_id = hov.organization_id
		 where 1 = 1
		   and hov.classification_code = 'DEPARTMENT'
		   -- and pao.pa_org_use_type ='EXPENDITURES' -- uncomment to only return Project Expenditure Owning Organizations
		   and sysdate between hov.effective_start_date and hov.effective_end_date
		   and 1 = 1
