/*
File Name: xla-event-classes.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Manage Subledger Application Transaction Objects
Why Description Rule is not visible in the Dropdown of Line Description Rule under Edit Subledger Journal Entry Rule Set? (Doc ID 2642012.1)
Attributes linked to specific Transaction Object

*/

-- ##############################################################
-- EVENT CLASS DEFINITION
-- ##############################################################

		select app_source.application_name event_src_appl
			 , app_src.application_name event_source_appl
			 , xes.event_class_code
			 , xecb.enabled_flag event_class_enabled
			 , xecb.entity_code
			 , xecb.seed_data_source
			 , xect.name event_class_name
			 , xect.description event_class_desrc
			 , xes.source_code
			 , xes.active_flag
			 , xes.level_code
			 , flv_source.meaning level_code_meaning
			 , xst.name attrib_name
			 , xst.description attrib_description
		  from xla_event_sources xes
		  join fnd_application_tl app_source on app_source.application_id = xes.application_id and app_source.language = userenv('lang')
		  join fnd_application_tl app_src on app_src.application_id = xes.source_application_id and app_src.language = userenv('lang')
		  join xla_event_classes_b xecb on xecb.event_class_code = xes.event_class_code
		  join xla_event_classes_tl xect on xect.entity_code = xecb.entity_code and xect.event_class_code = xecb.event_class_code and xect.language = userenv('lang')
		  join fnd_lookup_values_vl flv_source on flv_source.lookup_code = xes.level_code and flv_source.lookup_type = 'XLA_LEVEL_CODE' and flv_source.view_application_id = 602
	 left join xla_sources_tl xst on xst.source_code = xes.source_code and xst.application_id = xes.application_id and xst.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
