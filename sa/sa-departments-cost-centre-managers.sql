/*
File Name: sa-departments-cost-centre-managers.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

I supported a couple of organisations who used Cost Centre Manager functionality:
https://docs.oracle.com/en/cloud/saas/human-resources/23a/faigh/cost-centers-and-departments.html#s20030018

These SQLs were useful to extract info about that setup

Queries:

-- DEPARTMENTS BASIC
-- COST CENTRE COUNT PER DEPARTMENT
-- COST CENTRE MANAGER DFF
-- HR_ORGANIZATION_INFORMATION_F DATA DUMP 1
-- HR_ORGANIZATION_INFORMATION_F DATA DUMP 2
-- COST CENTRE MANAGER DATA 1
-- COST CENTRE MANAGER DATA 2
-- COST CENTRE MANAGER DATA 3 - MORE DETAILED HR INFO
-- COST CENTRE MANAGER DATA 4 - INCLUDE SUPERVISOR DATA
-- COST CENTRE MANAGER DATA 5 - RETURN COST CENTRE EVEN IF HAS NO MANAGER
-- HDL UPDATE ATTEMPT
-- HDL END DATE ATTEMPT
-- HDL DELETE ATTEMPT

*/

-- ##############################################################
-- DEPARTMENTS BASIC
-- ##############################################################

		select hov.name dept
			 , '#' || hov.organization_id dept_id
			 , hov.status dept_status
			 , hov.set_id dept_set_id
			 , to_char(hov.effective_start_date, 'yyyy-mm-dd') dept_start
			 , to_char(hov.effective_end_date, 'yyyy-mm-dd') dept_end
			 , to_char(hov.creation_date, 'yyyy-mm-dd hh24:mi:ss') dept_created
			 , hov.attribute10 org_code
			 , hov.created_by dep_created_by
		  from hr_organization_v hov
		 where 1 = 1
		   and hov.classification_code = 'DEPARTMENT'
		   and sysdate between hov.effective_start_date and hov.effective_end_date
		   and 1 = 1

-- ##############################################################
-- COST CENTRE COUNT PER DEPARTMENT
-- ##############################################################

		select hov.name dept
			 , count(*)
			 , min(hoif.org_information7) min_record_identifier
			 , max(hoif.org_information7) max_record_identifier
			 , min(to_char(hoif.creation_date, 'YYYY-MM-DD')) min_date_cc_manager_added
			 , max(to_char(hoif.creation_date, 'YYYY-MM-DD')) max_date_cc_manager_added
		  from hr_organization_v hov
		  join hr_organization_information_f hoif on hov.organization_id = hoif.organization_id
		 where 1 = 1
		   and hoif.org_information_context = 'PER_GL_COST_CENTER_INFO'
		   and hov.classification_code = 'DEPARTMENT'
		   and sysdate between hov.effective_start_date and hov.effective_end_date
		   and sysdate between hoif.effective_start_date and hoif.effective_end_date
		   and 1 = 1
	  group by hov.name
	  order by hov.name

-- ##############################################################
-- COST CENTRE MANAGER DFF
-- ##############################################################

/*
The SQLs on this page link to the "Organization Information EFF" DFF, which is defined as:

SEQ___END_USER_COLUMN_NAME___FORM_LEFT_PROMPT_______APPLICATION_COLUMN_NAME_____FLEX_VALUE_SET_NAME
1_____RECORD_IDENTIFIER______Record Identifier______ORG_INFORMATION7____________HRC_CHAR_30
2_____COMPANY_VALUESET_______Company Value Set______ORG_INFORMATION2____________HR_COMPANY_VS
3_____COMPANY________________Company________________ORG_INFORMATION3____________HR_COMPANY_LIST
4_____COST_CENTER_VALUESET___Cost Center Value Set__ORG_INFORMATION4____________HR_COST_CENTER_VS
5_____COST_CENTER____________Cost Center____________ORG_INFORMATION1____________HR_COST_CENTER_LIST
6_____COST_CENTER_MGR________Cost Center Manager____ORG_INFORMATION6____________HR_COST_CENTER_MANAGER

Cost Centre Manager data is stored in the HR_ORGANIZATION_INFORMATION_F table, and within that:

ORG_INFORMATION1: Cost Centre
ORG_INFORMATION2: Company Value Set ID
ORG_INFORMATION3: Balancing Segment Value's Value
ORG_INFORMATION4: Cost Centre Value Set ID
ORG_INFORMATION6: Person ID of Cost Centre Manager
ORG_INFORMATION7: Record Identifier

This SQL shows the setup for the PER_GL_COST_CENTER_INFO DFF
*/

		select fat.application_name
			 , fdfv.title dff_title
			 , fdfv.description dff_description
			 , to_char(fdfv.creation_date, 'yyyy-mm-dd hh24:mi:ss') dff_created
			 , fdfv.created_by dff_created_by
			 , to_char(fdfv.last_update_date, 'yyyy-mm-dd hh24:mi:ss') dff_updated
			 , fdfv.last_updated_by dff_updated_by
			 , fdfv.descriptive_flexfield_name dff_name
			 , fdfcv.global_flag -- if N then other DESCRIPTIVE_FLEX_CONTEXT_NAME values = Context values
			 , fdfcv.descriptive_flex_context_code
			 , fdfcv.descriptive_flex_context_name
			 , fdfcv.description context_description
			 , fdfcv.enabled_flag context_enabled
			 , fdfv.application_table_name
			 , fdfv.freeze_flex_definition_flag
			 , fdfv.concatenated_segment_delimiter
			 , fdfv.context_column_name
			 , '####' segments____
			 , fdfcuv.column_seq_num seq
			 , fdfcuv.end_user_column_name
			 , fdfcuv.form_left_prompt
			 , fdfcuv.application_column_name
			 , ffvs.flex_value_set_name
			 , ffvs.description value_set_description
			 , fdfcuv.required_flag required
			 , fdfcuv.display_flag display
			 , fdfcuv.enabled_flag enabled
			 , fdfcuv.security_enabled_flag
			 , (replace(replace(fdfcuv.default_value,chr(10),''),chr(13),' ')) default_val
			 , to_char(fdfcuv.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , fdfcuv.created_by
			 , to_char(fdfcuv.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , fdfcuv.last_updated_by
		  from fnd_descriptive_flexs_vl fdfv
		  join fnd_application_tl fat on fdfv.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_descr_flex_contexts_vl fdfcv on fdfv.descriptive_flexfield_name = fdfcv.descriptive_flexfield_name
		  join fnd_descr_flex_col_usage_vl fdfcuv on fdfcv.descriptive_flexfield_name = fdfcuv.descriptive_flexfield_name and fdfcuv.descriptive_flex_context_code = fdfcv.descriptive_flex_context_code
		  join fnd_flex_value_sets ffvs on fdfcv.descriptive_flex_context_code = fdfcuv.descriptive_flex_context_code and fdfcuv.flex_value_set_id = ffvs.flex_value_set_id
		 where 1 = 1
		   and fdfv.application_table_name = 'HR_ORGANIZATION_INFORMATION_F'
		   and fdfcv.descriptive_flex_context_code = 'PER_GL_COST_CENTER_INFO'
		   and 1 = 1

-- ##############################################################
-- HR_ORGANIZATION_INFORMATION_F DATA DUMP 1
-- ##############################################################

		select *
		  from hr_organization_information_f
		 where 1 = 1
		   and org_information_context = 'PER_GL_COST_CENTER_INFO'
		   and sysdate between effective_start_date and effective_end_date
		   and 1 = 1

-- ##############################################################
-- HR_ORGANIZATION_INFORMATION_F DATA DUMP 2
-- ##############################################################

		select hov.name dept
			 , hoif.*
		  from hr_organization_v hov
		  join hr_organization_information_f hoif on hov.organization_id = hoif.organization_id
		 where 1 = 1
		   and hoif.org_information_context = 'PER_GL_COST_CENTER_INFO'
		   and hov.classification_code = 'DEPARTMENT'
		   and sysdate between hov.effective_start_date and hov.effective_end_date
		   and sysdate between hoif.effective_start_date and hoif.effective_end_date
		   and 1 = 1
	  order by hoif.org_information1

-- ##############################################################
-- COST CENTRE MANAGER DATA 1
-- ##############################################################

		select '#' || fnd_value.flex_value segment_value
			 , fnd_value_tl.description description_us
			 , ftn.tree_code hierarchy
			 , tree_version.tree_version_name hierarchy_version
			 , ftn.parent_pk1_value parent_value
			 , ppnf.full_name cost_centre_manager_name
			 , '#' || papf.person_number person_number
			 , pd.name person_department
			 , fnd_value.enabled_flag enabled_
			 , '#' || hoif.org_information_id hoif_id
			 , to_char(hoif.effective_start_date) cc_manager_effective_start
			 , to_char(fnd_value.creation_date, 'yyyy-mm-dd hh24:mi:ss') cc_created
			 , to_char(hoif.creation_date, 'yyyy-mm-dd hh24:mi:ss') hoif_created
			 , hoif.created_by hoif_created_by
			 , to_char(hoif.last_update_date, 'yyyy-mm-dd hh24:mi:ss') hoif_updated
			 , hoif.last_updated_by hoif_updated_by
		  from fnd_flex_values fnd_value
		  join fnd_flex_values_tl fnd_value_tl on fnd_value.flex_value_id = fnd_value_tl.flex_value_id and fnd_value_tl.language = userenv('lang')
		  join fnd_flex_value_sets fnd_set on fnd_value.flex_value_set_id = fnd_set.flex_value_set_id
	 left join fnd_tree_node ftn on fnd_value.flex_value = ftn.pk1_start_value
	 left join fnd_tree_version_tl tree_version on tree_version.tree_version_id = ftn.tree_version_id
	 left join hr_organization_information_f hoif on hoif.org_information1 = fnd_value.flex_value and hoif.org_information_context = 'PER_GL_COST_CENTER_INFO' and sysdate between hoif.effective_start_date and hoif.effective_end_date
	 left join per_person_names_f ppnf on ppnf.person_id = hoif.org_information6 and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join per_all_people_f papf on papf.person_id = ppnf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_all_assignments_m paam on paam.person_id = papf.person_id and paam.assignment_status_type = 'ACTIVE' and paam.primary_flag = 'Y' and sysdate between nvl(paam.effective_start_date, sysdate - 1) and nvl(paam.effective_end_date, sysdate + 1)
	 left join per_departments pd on paam.organization_id = pd.organization_id and sysdate between nvl(pd.effective_start_date, sysdate - 1) and nvl(pd.effective_end_date, sysdate + 1)
		 where 1 = 1
		   and fnd_set.flex_value_set_name in ('XX_GL_COST_CENTRE')
		   and 1 = 1
	  order by hoif.last_update_date desc

-- ##############################################################
-- COST CENTRE MANAGER DATA 2
-- ##############################################################

		select hov.name dept
			 , '#' || hov.organization_id dept_id
			 , hov.status dept_status
			 , to_char(hov.effective_start_date, 'yyyy-mm-dd') dept_start
			 , to_char(hov.creation_date, 'yyyy-mm-dd hh24:mi:ss') dept_created
			 , hov.attribute10 org_code
			 , hov.created_by dep_created_by
			 , '######'
			 , hoif.org_information1 cost_centre
			 , to_char(hoif.creation_date, 'yyyy-mm-dd hh24:mi:ss') cost_centre_link_created
			 , hoif.created_by cost_centre_link_created_by
			 , to_char(hoif.last_update_date, 'yyyy-mm-dd hh24:mi:ss') cost_centre_link_updated
			 , hoif.created_by cost_centre_link_updated_by
			 , '#######'
			 , ppnf.full_name cc_manager
			 , '#' || papf.person_number cc_manager_empno
			 , pd.name cc_manager_department
			 , pjfv.name cc_manager_job_title
			 , pjfv.approval_authority cc_manager_job_level
			 , nvl(pea.email_address, 'no-email') cc_manager_email
			 , '###########################' technical_info_______
			 , '#' || hoif.org_information_id hoif_id
			 , to_char(hoif.effective_start_date, 'yyyy-mm-dd') hoif_start
			 , to_char(hoif.effective_end_date  , 'yyyy-mm-dd') hoif_end
			 , '#' || hoif.org_information1  hoif_cost_centre
			 , '#' || hoif.org_information2  hoif_val_set_id_ent
			 , fnd_set_ent.flex_value_set_name value_set_name_ent
			 , '#' || hoif.org_information3  hoif_bsv
			 , '#' || hoif.org_information4  hoif_val_set_id_cc
			 , fnd_set_cc.flex_value_set_name value_set_name_cc
			 , '#' || hoif.org_information6  hoif_person_id
			 , '#' || hoif.org_information7  hoif_record_identifier
			 , '#' || hoif.sequence_number   hoif_seq_num
		  from hr_organization_v hov
		  join hr_organization_information_f hoif on hov.organization_id = hoif.organization_id and hoif.org_information_context = 'PER_GL_COST_CENTER_INFO' and hov.classification_code = 'DEPARTMENT' and sysdate between hov.effective_start_date and hov.effective_end_date -- and sysdate between hoif.effective_start_date and hoif.effective_end_date
	 left join per_person_names_f ppnf on ppnf.person_id = hoif.org_information6 and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join per_all_people_f papf on papf.person_id = ppnf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_email_addresses pea on pea.person_id = papf.person_id and pea.email_type = 'W1'
	 left join per_all_assignments_m paam on paam.person_id = papf.person_id and paam.assignment_status_type = 'ACTIVE' and paam.primary_flag = 'Y' and sysdate between nvl(paam.effective_start_date, sysdate - 1) and nvl(paam.effective_end_date, sysdate + 1)
	 left join per_departments pd on paam.organization_id = pd.organization_id and sysdate between nvl(pd.effective_start_date, sysdate - 1) and nvl(pd.effective_end_date, sysdate + 1)
	 left join per_jobs_f_vl pjfv on paam.job_id = pjfv.job_id and sysdate between pjfv.effective_start_date and pjfv.effective_end_date
	 left join fnd_flex_value_sets fnd_set_ent  on hoif.org_information2 = fnd_set_ent.flex_value_set_id
	 left join fnd_flex_value_sets fnd_set_cc  on hoif.org_information4 = fnd_set_cc.flex_value_set_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- COST CENTRE MANAGER DATA 3 - MORE DETAILED HR INFO
-- ##############################################################

		select hoif.org_information1 cc
			 , '#' || hoif.org_information6 person_id
			 , hoif.org_information1 || '#' || hoif.org_information6 joined
			 , '###### department'
			 , hov.name department
			 , hov.attribute10 org_code
			 , '###### cost_centre data'
			 , hoif.org_information1 cost_centre
			 , tbl_cc_descr.description cost_centre_description
			 , to_char(hoif.creation_date, 'yyyy-mm-dd hh24:mi:ss') cc_link_created
			 , to_char(hoif.last_update_date, 'yyyy-mm-dd hh24:mi:ss') cc_link_updated
			 , hoif.created_by cc_link_created_by
			 , '#######' cost_centre_manager_______
			 , ppnf.full_name ccm_name
			 , '#' || papf.person_number ccm_employee_num
			 , hauft.name ccm_employer
			 , pea.email_address ccm_email
			 , pd.name ccm_department
			 , pjfv.name ccm_job_title
			 , pjfv.approval_authority ccm_job_level
			 , paam.assignment_status_type ccm_assignment_status_type
			 , pastt.user_status ccm_assigment_status
			 , '#' || hoif.org_information6 ccm_person_id
			 , hla.location_code ccm_location
			 , hapf.position_code ccm_position
			 , hapft.name ccm_position_name
			 , '#######' technical_info_______
			 , '#' || hoif.org_information_id hoif_id
			 , to_char(hoif.effective_start_date, 'yyyy-mm-dd') hoif_start
			 , to_char(hoif.effective_end_date , 'yyyy-mm-dd') hoif_end
			 , '#' || hoif.org_information1 hoif_cost_centre
			 , '#' || hoif.org_information2 hoif_val_set_id_ent
			 , fnd_set_ent.flex_value_set_name value_set_name_ent
			 , '#' || hoif.org_information3 hoif_bsv
			 , '#' || hoif.org_information4 hoif_val_set_id_cc
			 , fnd_set_cc.flex_value_set_name value_set_name_cc
			 , '#' || hoif.org_information6 hoif_person_id
			 , '#' || hoif.org_information7 hoif_record_identifier
			 , '#' || hoif.sequence_number hoif_seq_num
		  from hr_organization_v hov
		  join hr_organization_information_f hoif on hov.organization_id = hoif.organization_id and hoif.org_information_context = 'PER_GL_COST_CENTER_INFO' and hov.classification_code = 'DEPARTMENT' and sysdate between hov.effective_start_date and hov.effective_end_date and sysdate between hoif.effective_start_date and hoif.effective_end_date
	 left join (select fnd_value.flex_value, fnd_value_tl.description from fnd_flex_values fnd_value join fnd_flex_value_sets fnd_set on fnd_value.flex_value_set_id = fnd_set.flex_value_set_id join fnd_flex_values_tl fnd_value_tl on fnd_value.flex_value_id = fnd_value_tl.flex_value_id where fnd_set.flex_value_set_name in ('XX Cost Centre')) tbl_cc_descr on tbl_cc_descr.flex_value = hoif.org_information1
	 left join fnd_flex_value_sets fnd_set_ent on hoif.org_information2 = fnd_set_ent.flex_value_set_id
	 left join fnd_flex_value_sets fnd_set_cc on hoif.org_information4 = fnd_set_cc.flex_value_set_id
	 -- ################## person info
	 left join per_person_names_f ppnf on ppnf.person_id = hoif.org_information6 and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join per_all_people_f papf on papf.person_id = ppnf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_email_addresses pea on papf.person_id = pea.person_id and pea.email_type = 'W1' and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_all_assignments_m paam on paam.person_id = papf.person_id and sysdate between nvl(paam.effective_start_date, sysdate - 1) and nvl(paam.effective_end_date, sysdate + 1)
	 left join per_departments pd on paam.organization_id = pd.organization_id and sysdate between nvl(pd.effective_start_date, sysdate - 1) and nvl(pd.effective_end_date, sysdate + 1)
	 left join per_jobs_f_vl pjfv on paam.job_id = pjfv.job_id and sysdate between pjfv.effective_start_date and pjfv.effective_end_date
	 left join per_assignment_status_types past on paam.assignment_status_type_id = past.assignment_status_type_id
	 left join per_assignment_status_types_tl pastt on past.assignment_status_type_id = pastt.assignment_status_type_id
	 left join hr_all_positions_f hapf on paam.position_id = hapf.position_id and sysdate between hapf.effective_start_date and hapf.effective_end_date
	 left join hr_all_positions_f_tl hapft on hapf.position_id = hapft.position_id and sysdate between hapft.effective_start_date and hapft.effective_end_date and hapf.object_version_number = (select max(object_version_number) from hr_all_positions_f max_pos where max_pos.position_id = hapf.position_id)
	 left join hr_locations_all hla on hla.location_id = paam.location_id
	 left join hr_organization_units_f_tl hauft on hauft.organization_id = paam.legal_entity_id and sysdate between hauft.effective_start_date and hauft.effective_end_date and hauft.language = userenv('lang')
	 left join hr_all_organization_units_f haouf on haouf.organization_id = hauft.organization_id and sysdate between haouf.effective_start_date and haouf.effective_end_date
	 left join hr_org_unit_classifications_f houcf on haouf.organization_id = houcf.organization_id and haouf.effective_start_date between houcf.effective_start_date and houcf.effective_end_date and houcf.classification_code = 'HCM_LEMP'
		 where 1 = 1
		   -- and paam.assignment_status_type = 'ACTIVE'
		   and paam.primary_flag = 'Y'
		   and paam.effective_latest_change = 'Y'
		   and 1 = 1

-- ##############################################################
-- COST CENTRE MANAGER DATA 4 - INCLUDE SUPERVISOR DATA
-- ##############################################################

		select hov.name department
			 , hov.attribute10 org_code
			 , '###### cost_centre data'
			 , '#' || hoif.org_information1 cost_centre
			 , tbl_cc_descr.description cost_centre_descriotion
			 , to_char(hoif.creation_date, 'yyyy-mm-dd hh24:mi:ss') cc_link_created
			 , to_char(hoif.last_update_date, 'yyyy-mm-dd hh24:mi:ss') cc_link_updated
			 , hoif.created_by cc_link_created_by
			 , '#######' cost_centre_manager_______
			 , ppnf.full_name ccm_name
			 , '#' || papf.person_number ccm_employee_num
			 , hauft.name ccm_employer
			 , pea.email_address ccm_email
			 , pd.name ccm_department
			 , pjfv.name ccm_job_title
			 , pjfv.approval_authority ccm_job_level
			 , paam.assignment_status_type ccm_assignment_status_type
			 , pastt.user_status ccm_assigment_status
			 , '#' || hoif.org_information6 ccm_person_id
			 , hla.location_code ccm_location
			 , hapf.position_code ccm_position
			 , hapft.name ccm_position_name
			 , '#######' line_manager_______
			 , ppnf_mgr.full_name mgr_name
			 , '#' || papf_mgr.person_number mgr_employee_num
			 , hauft_mgr.name mgr_employer
			 , pea_mgr.email_address mgr_email
			 , pd_mgr.name mgr_dept
			 , pjfv_mgr.name mgr_job_title
			 , pjfv_mgr.approval_authority mgr_job_level
			 , hla.location_code mgr_location
			 , hapf_mgr.position_code mgr_position
			 , hapft_mgr.name mgr_position_name
			 , '#######' technical_info_______
			 , '#' || hoif.org_information_id hoif_id
			 , to_char(hoif.effective_start_date, 'yyyy-mm-dd') hoif_start
			 , to_char(hoif.effective_end_date , 'yyyy-mm-dd') hoif_end
			 , '#' || hoif.org_information1 hoif_cost_centre
			 , '#' || hoif.org_information2 hoif_val_set_id_ent
			 , fnd_set_ent.flex_value_set_name value_set_name_ent
			 , '#' || hoif.org_information3 hoif_bsv
			 , '#' || hoif.org_information4 hoif_val_set_id_cc
			 , fnd_set_cc.flex_value_set_name value_set_name_cc
			 , '#' || hoif.org_information6 hoif_person_id
			 , '#' || hoif.org_information7 hoif_record_identifier
			 , '#' || hoif.sequence_number hoif_seq_num
		  from hr_organization_v hov
		  join hr_organization_information_f hoif on hov.organization_id = hoif.organization_id and hoif.org_information_context = 'PER_GL_COST_CENTER_INFO' and hov.classification_code = 'DEPARTMENT' and sysdate between hov.effective_start_date and hov.effective_end_date and sysdate between hoif.effective_start_date and hoif.effective_end_date
	 left join (select fnd_value.flex_value, fnd_value_tl.description from fnd_flex_values fnd_value join fnd_flex_value_sets fnd_set on fnd_value.flex_value_set_id = fnd_set.flex_value_set_id join fnd_flex_values_tl fnd_value_tl on fnd_value.flex_value_id = fnd_value_tl.flex_value_id where fnd_set.flex_value_set_name in ('XX_COST_CENTRE')) tbl_cc_descr on tbl_cc_descr.flex_value = hoif.org_information1
	 left join fnd_flex_value_sets fnd_set_ent on hoif.org_information2 = fnd_set_ent.flex_value_set_id
	 left join fnd_flex_value_sets fnd_set_cc on hoif.org_information4 = fnd_set_cc.flex_value_set_id
	 -- ################## person info
	 left join per_person_names_f ppnf on ppnf.person_id = hoif.org_information6 and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join per_all_people_f papf on papf.person_id = ppnf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_email_addresses pea on papf.person_id = pea.person_id and pea.email_type = 'W1' and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_all_assignments_m paam on paam.person_id = papf.person_id and sysdate between nvl(paam.effective_start_date, sysdate - 1) and nvl(paam.effective_end_date, sysdate + 1)
	 left join per_departments pd on paam.organization_id = pd.organization_id and sysdate between nvl(pd.effective_start_date, sysdate - 1) and nvl(pd.effective_end_date, sysdate + 1)
	 left join per_jobs_f_vl pjfv on paam.job_id = pjfv.job_id and sysdate between pjfv.effective_start_date and pjfv.effective_end_date
	 left join per_assignment_status_types past on paam.assignment_status_type_id = past.assignment_status_type_id
	 left join per_assignment_status_types_tl pastt on past.assignment_status_type_id = pastt.assignment_status_type_id
	 left join hr_all_positions_f hapf on paam.position_id = hapf.position_id and sysdate between hapf.effective_start_date and hapf.effective_end_date
	 left join hr_all_positions_f_tl hapft on hapf.position_id = hapft.position_id and sysdate between hapft.effective_start_date and hapft.effective_end_date and hapf.object_version_number = (select max(object_version_number) from hr_all_positions_f max_pos where max_pos.position_id = hapf.position_id)
	 left join hr_locations_all hla on hla.location_id = paam.location_id
	 left join hr_organization_units_f_tl hauft on hauft.organization_id = paam.legal_entity_id and sysdate between hauft.effective_start_date and hauft.effective_end_date and hauft.language = userenv('lang')
	 left join hr_all_organization_units_f haouf on haouf.organization_id = hauft.organization_id and sysdate between haouf.effective_start_date and haouf.effective_end_date
	 left join hr_org_unit_classifications_f houcf on haouf.organization_id = houcf.organization_id and haouf.effective_start_date between houcf.effective_start_date and houcf.effective_end_date and houcf.classification_code = 'HCM_LEMP'
	 -- ################## manager info
	 left join per_assignment_supervisors_f pasf on pasf.person_id = papf.person_id and pasf.assignment_id = paam.assignment_id and sysdate between pasf.effective_start_date and pasf.effective_end_date
	 left join per_all_people_f papf_mgr on papf_mgr.person_id = pasf.manager_id and sysdate between papf_mgr.effective_start_date and papf_mgr.effective_end_date
	 left join per_all_assignments_m paam_mgr on paam_mgr.assignment_id = pasf.manager_assignment_id and paam_mgr.person_id = papf_mgr.person_id and sysdate between paam_mgr.effective_start_date and paam_mgr.effective_end_date and paam_mgr.primary_flag = 'Y'
	 left join per_jobs_f_vl pjfv_mgr on paam_mgr.job_id = pjfv_mgr.job_id and sysdate between pjfv_mgr.effective_start_date and pjfv_mgr.effective_end_date
	 left join per_person_names_f ppnf_mgr on papf_mgr.person_id = ppnf_mgr.person_id and ppnf_mgr.name_type = 'GLOBAL' and sysdate between ppnf_mgr.effective_start_date and ppnf_mgr.effective_end_date
	 left join per_departments pd_mgr on paam_mgr.organization_id = pd_mgr.organization_id and sysdate between nvl(pd_mgr.effective_start_date, sysdate - 1) and nvl(pd_mgr.effective_end_date, sysdate + 1)
	 left join per_email_addresses pea_mgr on papf_mgr.person_id = pea_mgr.person_id and pea_mgr.email_type = 'W1' -- not all users have email addresses
	 left join hr_all_positions_f hapf_mgr on paam_mgr.position_id = hapf_mgr.position_id and sysdate between hapf_mgr.effective_start_date and hapf_mgr.effective_end_date
	 left join hr_all_positions_f_tl hapft_mgr on hapf_mgr.position_id = hapft_mgr.position_id and hapf_mgr.object_version_number = (select max(object_version_number) from hr_all_positions_f max_pos where max_pos.position_id = hapf_mgr.position_id) and sysdate between hapft_mgr.effective_start_date and hapft_mgr.effective_end_date
	 left join hr_locations_all hla_mgr on hla_mgr.location_id = paam_mgr.location_id
	 left join hr_organization_units_f_tl hauft_mgr on hauft_mgr.organization_id = paam_mgr.legal_entity_id and sysdate between hauft_mgr.effective_start_date and hauft_mgr.effective_end_date and hauft_mgr.language = userenv('lang')
	 left join hr_all_organization_units_f haouf_mgr on haouf_mgr.organization_id = hauft_mgr.organization_id and sysdate between haouf_mgr.effective_start_date and haouf_mgr.effective_end_date
	 left join hr_org_unit_classifications_f houcf_mgr on haouf_mgr.organization_id = houcf_mgr.organization_id and haouf_mgr.effective_start_date between houcf_mgr.effective_start_date and houcf_mgr.effective_end_date and houcf_mgr.classification_code = 'HCM_LEMP'
		 where 1 = 1
		   -- and paam.assignment_status_type = 'ACTIVE'
		   and paam.primary_flag = 'Y'
		   and paam.effective_latest_change = 'Y'
		   and 1 = 1

-- ##############################################################
-- COST CENTRE MANAGER DATA 5 - RETURN COST CENTRE EVEN IF HAS NO MANAGER
-- ##############################################################

/*
Need to hard-code the Cost Centre Segment Name in the inline table "TBL_CC"
On this bit: where fnd_set.flex_value_set_name in ('XX Cost Centre')
*/

		select '#' || tbl_cc.cc cc
			 , tbl_cc.cc_desc cc_description
			 , tbl_cc.cc_budget_holder cc_bh
			 , tbl_cc.cc_fin_contact_name
			 , '#' || tbl_cc.cc_bh_empno cc_bh_empno
			 , '#' dept___
			 , hov.name dept
			 , '#' || hov.organization_id dept_id
			 -- , hov.status dept_status
			 -- , to_char(hov.effective_start_date, 'yyyy-mm-dd') dept_start
			 -- , to_char(hov.creation_date, 'yyyy-mm-dd hh24:mi:ss') dept_created
			 -- , hov.attribute10 org_code
			 -- , hov.created_by dep_created_by
			 , '#' hoif___
			 , '#' || hoif.org_information1 cost_centre
			 , to_char(hoif.creation_date, 'yyyy-mm-dd hh24:mi:ss') cost_centre_link_created
			 , hoif.created_by cost_centre_link_created_by
			 , '#' cc_manager_hr___
			 , ppnf.full_name cc_manager
			 , '#' || papf.person_number cc_manager_empno
			 , pd.name cc_manager_department
			 , pjfv.name cc_manager_job_title
			 , pjfv.approval_authority cc_manager_job_level
			 , '#' hoif_tech___
			 , to_char(hoif.effective_start_date, 'yyyy-mm-dd') hoif_start
			 , to_char(hoif.effective_end_date  , 'yyyy-mm-dd') hoif_end
			 , '#' || hoif.org_information1  hoif_cost_centre
			 , '#' || hoif.org_information2  hoif_val_set_id_ent
			 , fnd_set_ent.flex_value_set_name value_set_name_ent
			 , '#' || hoif.org_information3  hoif_bsv
			 , '#' || hoif.org_information4  hoif_val_set_id_cc
			 , fnd_set_cc.flex_value_set_name value_set_name_cc
			 , '#' || hoif.org_information6  hoif_person_id
			 , '#' || hoif.org_information7  hoif_record_identifier
			 , '#' || hoif.sequence_number   hoif_seq_num
		  from (select fnd_value.flex_value cc, fnd_value_tl.description cc_desc, fnd_value.enabled_flag cc_enabled, fnd_value.attribute1 cc_budget_holder, fnd_value.attribute2 cc_fin_contact_name, fnd_value.attribute4 cc_bh_empno from fnd_flex_values fnd_value join fnd_flex_value_sets fnd_set on fnd_value.flex_value_set_id = fnd_set.flex_value_set_id join fnd_flex_values_tl fnd_value_tl on fnd_value.flex_value_id = fnd_value_tl.flex_value_id where fnd_set.flex_value_set_name in ('XX Cost Centre')) tbl_cc
	 left join hr_organization_information_f hoif on hoif.org_information1 = tbl_cc.cc and sysdate between hoif.effective_start_date and hoif.effective_end_date
	 left join hr_organization_v hov on hov.organization_id = hoif.organization_id and hoif.org_information_context = 'PER_GL_COST_CENTER_INFO' and hov.classification_code = 'DEPARTMENT' and sysdate between hov.effective_start_date and hov.effective_end_date
	 left join per_person_names_f ppnf on ppnf.person_id = hoif.org_information6 and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join per_all_people_f papf on papf.person_id = ppnf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_all_assignments_m paam on paam.person_id = papf.person_id and paam.assignment_status_type = 'ACTIVE' and paam.primary_flag = 'Y' and sysdate between nvl(paam.effective_start_date, sysdate - 1) and nvl(paam.effective_end_date, sysdate + 1)
	 left join per_departments pd on paam.organization_id = pd.organization_id and sysdate between nvl(pd.effective_start_date, sysdate - 1) and nvl(pd.effective_end_date, sysdate + 1)
	 left join per_jobs_f_vl pjfv on paam.job_id = pjfv.job_id and sysdate between pjfv.effective_start_date and pjfv.effective_end_date
	 left join fnd_flex_value_sets fnd_set_ent  on hoif.org_information2 = fnd_set_ent.flex_value_set_id
	 left join fnd_flex_value_sets fnd_set_cc  on hoif.org_information4 = fnd_set_cc.flex_value_set_id
		 where 1 = 1
		   and tbl_cc.cc_enabled = 'Y'
		   and 1 = 1
	  order by cc

-- ##############################################################
-- HDL UPDATE ATTEMPT
-- ##############################################################

/*
For updating records - there is already data in HRC_INTEGRATION_KEY_MAP
The SURROGATE_ID from HRC_INTEGRATION_KEY_MAP is the org_information_id from HR_ORGANIZATION_INFORMATION_F
Need to specify SourceSystemOwner and SourceSystemId for new records
*/

		select 'METADATA|OrgInformation|OrgInformationId|OrganizationId|EffectiveStartDate|OrganizationName|FLEX:PER_ORGANIZATION_INFORMATION_EFF|recordIdentifier(PER_ORGANIZATION_INFORMATION_EFF=PER_GL_COST_CENTER_INFO)|_COMPANY_VALUESET_Display(PER_ORGANIZATION_INFORMATION_EFF=PER_GL_COST_CENTER_INFO)|_COMPANY(PER_ORGANIZATION_INFORMATION_EFF=PER_GL_COST_CENTER_INFO)|_COST_CENTER_VALUESET_Display(PER_ORGANIZATION_INFORMATION_EFF=PER_GL_COST_CENTER_INFO)|_COST_CENTER(PER_ORGANIZATION_INFORMATION_EFF=PER_GL_COST_CENTER_INFO)|_COST_CENTER_MGR(PER_ORGANIZATION_INFORMATION_EFF=PER_GL_COST_CENTER_INFO)|EFF_CATEGORY_CODE' hdl_headings
			 , 'MERGE|OrgInformation|' || hoif.org_information_id || '|' || hov.organization_id || '|' || to_char(sysdate, 'yyyy/mm/dd') || '|' || hov.name || '|PER_GL_COST_CENTER_INFO|' || hoif.org_information7 || '|' || fnd_set_ent.flex_value_set_name || '|' || hoif.org_information3 || '|' || fnd_set_cc.flex_value_set_name || '|' || hoif.org_information1 || '|' || hoif.org_information6 || '|DEPARTMENT' hdl_data
		  from hr_organization_v hov
		  join hr_organization_information_f hoif on hov.organization_id = hoif.organization_id and hoif.org_information_context = 'PER_GL_COST_CENTER_INFO' and hov.classification_code = 'DEPARTMENT' and sysdate between hov.effective_start_date and hov.effective_end_date and sysdate between hoif.effective_start_date and hoif.effective_end_date
		  join fnd_flex_value_sets fnd_set_ent on hoif.org_information2 = fnd_set_ent.flex_value_set_id
		  join fnd_flex_value_sets fnd_set_cc on hoif.org_information4 = fnd_set_cc.flex_value_set_id
		  join hrc_integration_key_map hikm on hikm.surrogate_id = hoif.org_information_id and hikm.object_name = 'OrgInformationEFF'
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- HDL END DATE ATTEMPT
-- ##############################################################

		select 'METADATA|OrgInformation|OrgInformationId|SourceSystemOwner|SourceSystemId|OrganizationId|EffectiveStartDate|EffectiveEndDate|OrganizationName|FLEX:PER_ORGANIZATION_INFORMATION_EFF|recordIdentifier(PER_ORGANIZATION_INFORMATION_EFF=PER_GL_COST_CENTER_INFO)|_COMPANY_VALUESET_Display(PER_ORGANIZATION_INFORMATION_EFF=PER_GL_COST_CENTER_INFO)|_COMPANY(PER_ORGANIZATION_INFORMATION_EFF=PER_GL_COST_CENTER_INFO)|_COST_CENTER_VALUESET_Display(PER_ORGANIZATION_INFORMATION_EFF=PER_GL_COST_CENTER_INFO)|_COST_CENTER(PER_ORGANIZATION_INFORMATION_EFF=PER_GL_COST_CENTER_INFO)|_COST_CENTER_MGR(PER_ORGANIZATION_INFORMATION_EFF=PER_GL_COST_CENTER_INFO)|EFF_CATEGORY_CODE|ReplaceLastEffectiveEndDate' hdl_headings
			 , 'MERGE|OrgInformation|' || hoif.org_information_id || '|' || hikm.source_system_owner || '|' || hikm.source_system_id || '|' || hov.organization_id || '|' || to_char(hoif.effective_start_date, 'yyyy/mm/dd') || '|' || to_char(sysdate-1,'yyyy/mm/dd') || '|' || hov.name || '|PER_GL_COST_CENTER_INFO|' || hoif.org_information7 || '|' || fnd_set_ent.flex_value_set_name || '|' || hoif.org_information3 || '|' || fnd_set_cc.flex_value_set_name || '|' || hoif.org_information1 || '|' || hoif.org_information6 || '|DEPARTMENT|Y' hdl_data
		  from hr_organization_v hov
		  join hr_organization_information_f hoif on hov.organization_id = hoif.organization_id and hoif.org_information_context = 'PER_GL_COST_CENTER_INFO' and hov.classification_code = 'DEPARTMENT' and sysdate between hov.effective_start_date and hov.effective_end_date and sysdate between hoif.effective_start_date and hoif.effective_end_date
		  join fnd_flex_value_sets fnd_set_ent on hoif.org_information2 = fnd_set_ent.flex_value_set_id
		  join fnd_flex_value_sets fnd_set_cc on hoif.org_information4 = fnd_set_cc.flex_value_set_id
		  join hrc_integration_key_map hikm on hikm.surrogate_id = hoif.org_information_id and hikm.object_name = 'OrgInformationEFF'
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- HDL DELETE ATTEMPT
-- ##############################################################

/*
How to remove the cost centers from departments when eror Max Limit Not Reached is coming (Doc ID 2568991.1)
*/

		select 'METADATA|OrgInformation|OrganizationId|FLEX:PER_ORGANIZATION_INFORMATION_EFF|recordIdentifier(PER_ORGANIZATION_INFORMATION_EFF=PER_GL_COST_CENTER_INFO)|OrgInformationId|EFF_CATEGORY_CODE|EffectiveStartDate|EffectiveEndDate' hdl_headings
			 , 'DELETE|OrgInformation|' || hov.organization_id || '|PER_GL_COST_CENTER_INFO|' || hoif.org_information7 || '|' || hoif.org_information_id || '|DEPARTMENT|' || to_char(hoif.effective_start_date, 'yyyy/mm/dd') || '|' || to_char(hoif.effective_end_date, 'yyyy/mm/dd') hdl_data
		  from hr_organization_v hov
		  join hr_organization_information_f hoif on hov.organization_id = hoif.organization_id and hoif.org_information_context = 'PER_GL_COST_CENTER_INFO' and hov.classification_code = 'DEPARTMENT' and sysdate between hov.effective_start_date and hov.effective_end_date and sysdate between hoif.effective_start_date and hoif.effective_end_date
		  join fnd_flex_value_sets fnd_set_ent on hoif.org_information2 = fnd_set_ent.flex_value_set_id
		  join fnd_flex_value_sets fnd_set_cc on hoif.org_information4 = fnd_set_cc.flex_value_set_id
		  join hrc_integration_key_map hikm on hikm.surrogate_id = hoif.org_information_id and hikm.object_name = 'OrgInformationEFF'
		 where 1 = 1
		   and 1 = 1
