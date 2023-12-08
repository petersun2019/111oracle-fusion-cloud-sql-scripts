/*
File Name: ap-audit.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts
*/

/*
FND_AUDIT_ATTRIBUTES
This table will store the attributes enabled for Auditing.
*/

select *
from FND_AUDIT_ATTRIBUTES
where table_name = 'AP_INVOICES_ALL'

select *
from FND_AUDIT_ATTRIBUTES
where table_name like 'AP_INVOICE%'
