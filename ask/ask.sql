/*
File Name: ask.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

ASK Application: Applications Functional Core

Queries:

-- RELEASE VERSIONS
-- APPLICATION CLOUD
-- DEPLOYED APPLICATIONS
-- DEPLOYED DOMAINS 1
-- DEPLOYED DOMAINS 2
-- DEPLOYED DATABASES
-- DEPLOYED SCHEMAS
-- DEPLOYED DOMAINS

*/

-- ##############################################################
-- RELEASE VERSIONS
-- ##############################################################

		select arv.name release_version_name
			 , arv.external_version release_external_version
			 , arv.current_release_flag
			 , nvl2(apr.id, 'Y', 'N') applied_flag
			 , to_char(apr.creation_date, 'yyyy-mm-dd hh24:mi:ss') previously_applied_date
			 , to_char(arv.creation_date, 'yyyy-mm-dd hh24:mi:ss') release_version_created
			 , to_char(arv.last_update_date, 'yyyy-mm-dd hh24:mi:ss') release_version_updated
			 , arv.id release_version_id
			 , arv.release_sequence
			 , arv.enterprise_id
			 , arv.object_version_number
		  from ask_release_versions arv
	 left join ask_previous_releases apr on apr.external_version = arv.external_version
		 where 1 = 1
		   and 1 = 1
	  order by arv.id desc

-- ##############################################################
-- APPLICATION CLOUD
-- ##############################################################

		select enterprise_id
			 , object_version_number
			 , id
			 , name
			 , short_name
			 , type
			 , customer
			 , to_char(creation_date, 'yyyy-mm-dd hh24:mi:ss') created
			 , to_char(last_update_date, 'yyyy-mm-dd hh24:mi:ss') updated
		  from ask_application_clouds

-- ##############################################################
-- DEPLOYED APPLICATIONS
-- ##############################################################

select * from fusion.ask_deployed_applications

-- ##############################################################
-- DEPLOYED DOMAINS 1
-- ##############################################################

select * from fusion.ask_deployed_domains

-- ##############################################################
-- DEPLOYED DOMAINS 2
-- ##############################################################

		select addom.external_server_protocol || '://' || addom.external_virtual_host || '/fscmUI/faces/FuseWelcome' instance
		  from ask_deployed_domains addom
		 where addom.deployed_domain_name = 'FADomain'

-- ##############################################################
-- DEPLOYED DATABASES
-- ##############################################################

select * from fusion.ask_deployed_databases

-- ##############################################################
-- DEPLOYED SCHEMAS
-- ##############################################################

select * from fusion.ask_deployed_schemas

-- ##############################################################
-- DEPLOYED DOMAINS
-- ##############################################################

select * from fusion.ask_deployed_domains
