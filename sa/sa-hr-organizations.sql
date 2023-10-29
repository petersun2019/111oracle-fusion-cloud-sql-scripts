/*
File Name: sa-hr-organizations.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts
*/

-- ##############################################################
-- ORGANIZATIONS AND CLASSIFICATIONS
-- ##############################################################

		select hov.name org_name
			 , '#' || hov.organization_id org_id
			 , to_char(hov.effective_start_date) effective_start_date
			 , to_char(hov.effective_end_date) effective_end_date
			 , hov.status org_status
			 , hoct.classification_name
			 , hoct.classification_code
			 , hoct.description
		  from hr_organization_v hov
		  join hr_org_classifications_tl hoct on hoct.classification_code = hov.classification_code and hoct.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  order by hov.name
			 , hoct.classification_code
