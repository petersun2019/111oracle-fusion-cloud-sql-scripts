/*
File Name: sa-hr-records-skills-quals.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- HR RECORDS - SKILLS AND QUALIFICATIONS
-- HR RECORDS - COLUMN NAMES
-- HR RECORDS - COLUMN HEADINGS

*/

-- ##############################################################
-- SKILLS AND QUALIFICATIONS
-- ##############################################################

		select '#' || papf.person_id person_id
			 , '#' || papf.person_number emp_num
			 , ppnf.first_name
			 , ppnf.last_name
			 , ppnf.full_name
			 , '#' hpb________________
			 , hpb.profile_code
			 , hpb.profile_status_code
			 , hpb.profile_usage_code
			 , '#' hpts________________
			 , hpts.section_context
			 , hpts.security_context
			 , hpts.dff_context_name
			 , hpts.display_order
			 , hpts.section_layout
			 , hpts.content_type_id
			 , '#' || hpts.section_id section_id
			 , '#' || hpts.parent_section_id parent_section_id
			 , hptst.name section_name
			 , '#' other________________
			 , hctt.content_type_name
			 , hctt.content_description
			 , hcit.name content_item_name
			 , hcit.item_description content_item_description
			 , hpi.item_text240_2 certificate_number
			 , hpi.item_text2000_1 training_provider
			 , hpi.item_text240_3 awarding_body
			 , to_char(hpi.date_from, 'yyyy-mm-dd') date_from
			 , to_char(hpi.date_to, 'yyyy-mm-dd') date_to
			 , to_char(hpi.item_date_6, 'yyyy-mm-dd') issue_date
			 , to_char(hpi.item_date_3, 'yyyy-mm-dd') expiration_date
		  from per_all_people_f papf 
		  join per_person_names_f ppnf on ppnf.person_id = papf.person_id and ppnf.name_type = 'GLOBAL'
		  join hrt_profiles_b hpb on hpb.person_id = papf.person_id
		  join hrt_profile_items hpi on hpi.profile_id = hpb.profile_id and sysdate between nvl(hpi.date_from, sysdate - 1) and nvl(hpi.date_to, sysdate + 1)
		  join hrt_profile_typ_sections hpts on hpts.section_id = hpi.section_id
		  join hrt_profile_typ_sections_tl hptst on hpts.section_id = hptst.section_id
		  join hrt_content_types_tl hctt on hctt.content_type_id = hpi.content_type_id
		  join hrt_content_items_b hcib on hcib.content_item_id = hpi.content_item_id
		  join hrt_content_items_tl hcit on hcit.content_item_id = hcib.content_item_id
		 where 1 = 1
		   and sysdate between papf.effective_start_date and papf.effective_end_date
		   and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
		   and 1 = 1

-- ##############################################################
-- COLUMN NAMES
-- ##############################################################

select *
from hrt_profile_tp_sc_prp_b
where section_id in (123456,123457)

-- ##############################################################
-- COLUMN HEADINGS
-- ##############################################################

select *
from hrt_profile_tp_sc_prp_tl
where section_prop_id in (123456,123457)
