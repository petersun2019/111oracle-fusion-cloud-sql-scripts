/*
File Name: pa-settings.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- CONFIGURE PROJECT ACCOUNTING BUSINESS FUNCTION
-- IMPLEMENTATION SETTINGS VIEW

*/

-- ##############################################################
-- CONFIGURE PROJECT ACCOUNTING BUSINESS FUNCTION
-- ##############################################################

/*
Configure Project Accounting Business Function
PA_IMPLEMENTATIONS_ALL stores the parameters and defaults that define the configuration of your Oracle Projects installation
As per Task "Configure Project Accounting Business Function"
*/

select * from pjf_bu_impl_all

-- ##############################################################
-- IMPLEMENTATION SETTINGS VIEW
-- ##############################################################

/*
https://docs.oracle.com/en/cloud/saas/project-management/23a/oedpp/pjfbuimplv-6388.html#pjfbuimplv-6388
*/

select * from pjf_bu_impl_v
