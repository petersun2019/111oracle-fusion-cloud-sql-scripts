/*
File Name: misc-count-volumes-group-by-rollup.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- USERS COUNT SETUP
-- PROJECTS COUNT SETUP
-- STAFF COUNT SETUP
-- PO COUNT
-- REQUISITION COUNT
-- AP INVOICE COUNT
-- SUPPLIER HEADER COUNT
-- SUPPLIER SITE COUNT

*/

-- ##################################################################
-- USERS COUNT SETUP
-- ##################################################################

		select
			nvl(to_char(extract(year from creation_date)),'TOTAL') creation_year,
			sum(decode(extract (month from creation_date),1,1,0)) jan,
			sum(decode(extract (month from creation_date),2,1,0)) feb,
			sum(decode(extract (month from creation_date),3,1,0)) mar,
			sum(decode(extract (month from creation_date),4,1,0)) apr,
			sum(decode(extract (month from creation_date),5,1,0)) may,
			sum(decode(extract (month from creation_date),6,1,0)) jun,
			sum(decode(extract (month from creation_date),7,1,0)) jul,
			sum(decode(extract (month from creation_date),8,1,0)) aug,
			sum(decode(extract (month from creation_date),9,1,0)) sep,
			sum(decode(extract (month from creation_date),10,1,0)) oct,
			sum(decode(extract (month from creation_date),11,1,0)) nov,
			sum(decode(extract (month from creation_date),12,1,0)) dec,
			sum(1) total
		  from per_users
	  group by rollup(extract(year from creation_date))

-- ##################################################################
-- PROJECTS COUNT SETUP
-- ##################################################################

		select
			nvl(to_char(extract(year from creation_date)),'TOTAL') creation_year,
			sum(decode(extract (month from creation_date),1,1,0)) jan,
			sum(decode(extract (month from creation_date),2,1,0)) feb,
			sum(decode(extract (month from creation_date),3,1,0)) mar,
			sum(decode(extract (month from creation_date),4,1,0)) apr,
			sum(decode(extract (month from creation_date),5,1,0)) may,
			sum(decode(extract (month from creation_date),6,1,0)) jun,
			sum(decode(extract (month from creation_date),7,1,0)) jul,
			sum(decode(extract (month from creation_date),8,1,0)) aug,
			sum(decode(extract (month from creation_date),9,1,0)) sep,
			sum(decode(extract (month from creation_date),10,1,0)) oct,
			sum(decode(extract (month from creation_date),11,1,0)) nov,
			sum(decode(extract (month from creation_date),12,1,0)) dec,
			sum(1) total
		  from pjf_projects_all_vl
	  group by rollup(extract(year from creation_date))

-- ##################################################################
-- STAFF COUNT SETUP
-- ##################################################################

		select
			nvl(to_char(extract(year from creation_date)),'TOTAL') creation_year,
			sum(decode(extract (month from creation_date),1,1,0)) jan,
			sum(decode(extract (month from creation_date),2,1,0)) feb,
			sum(decode(extract (month from creation_date),3,1,0)) mar,
			sum(decode(extract (month from creation_date),4,1,0)) apr,
			sum(decode(extract (month from creation_date),5,1,0)) may,
			sum(decode(extract (month from creation_date),6,1,0)) jun,
			sum(decode(extract (month from creation_date),7,1,0)) jul,
			sum(decode(extract (month from creation_date),8,1,0)) aug,
			sum(decode(extract (month from creation_date),9,1,0)) sep,
			sum(decode(extract (month from creation_date),10,1,0)) oct,
			sum(decode(extract (month from creation_date),11,1,0)) nov,
			sum(decode(extract (month from creation_date),12,1,0)) dec,
			sum(1) total
		  from per_all_people_f
	  group by rollup(extract(year from creation_date))

-- ##################################################################
-- PO COUNT
-- ##################################################################

		select
			nvl(to_char(extract(year from creation_date)),'TOTAL') creation_year,
			sum(decode(extract (month from creation_date),1,1,0)) jan,
			sum(decode(extract (month from creation_date),2,1,0)) feb,
			sum(decode(extract (month from creation_date),3,1,0)) mar,
			sum(decode(extract (month from creation_date),4,1,0)) apr,
			sum(decode(extract (month from creation_date),5,1,0)) may,
			sum(decode(extract (month from creation_date),6,1,0)) jun,
			sum(decode(extract (month from creation_date),7,1,0)) jul,
			sum(decode(extract (month from creation_date),8,1,0)) aug,
			sum(decode(extract (month from creation_date),9,1,0)) sep,
			sum(decode(extract (month from creation_date),10,1,0)) oct,
			sum(decode(extract (month from creation_date),11,1,0)) nov,
			sum(decode(extract (month from creation_date),12,1,0)) dec,
			sum(1) total
		  from po_headers_all pha
	  group by rollup(extract(year from creation_date))

-- ##################################################################
-- REQUISITION COUNT
-- ##################################################################

		select
			nvl(to_char(extract(year from creation_date)),'TOTAL') creation_year,
			sum(decode(extract (month from creation_date),1,1,0)) jan,
			sum(decode(extract (month from creation_date),2,1,0)) feb,
			sum(decode(extract (month from creation_date),3,1,0)) mar,
			sum(decode(extract (month from creation_date),4,1,0)) apr,
			sum(decode(extract (month from creation_date),5,1,0)) may,
			sum(decode(extract (month from creation_date),6,1,0)) jun,
			sum(decode(extract (month from creation_date),7,1,0)) jul,
			sum(decode(extract (month from creation_date),8,1,0)) aug,
			sum(decode(extract (month from creation_date),9,1,0)) sep,
			sum(decode(extract (month from creation_date),10,1,0)) oct,
			sum(decode(extract (month from creation_date),11,1,0)) nov,
			sum(decode(extract (month from creation_date),12,1,0)) dec,
			sum(1) total
		  from por_requisition_headers_all
	  group by rollup(extract(year from creation_date))

-- ##################################################################
-- AP INVOICE COUNT
-- ##################################################################

		select
			nvl(to_char(extract(year from creation_date)),'TOTAL') creation_year,
			sum(decode(extract (month from creation_date),1,1,0)) jan,
			sum(decode(extract (month from creation_date),2,1,0)) feb,
			sum(decode(extract (month from creation_date),3,1,0)) mar,
			sum(decode(extract (month from creation_date),4,1,0)) apr,
			sum(decode(extract (month from creation_date),5,1,0)) may,
			sum(decode(extract (month from creation_date),6,1,0)) jun,
			sum(decode(extract (month from creation_date),7,1,0)) jul,
			sum(decode(extract (month from creation_date),8,1,0)) aug,
			sum(decode(extract (month from creation_date),9,1,0)) sep,
			sum(decode(extract (month from creation_date),10,1,0)) oct,
			sum(decode(extract (month from creation_date),11,1,0)) nov,
			sum(decode(extract (month from creation_date),12,1,0)) dec,
			sum(1) total
		  from ap_invoices_all
	  group by rollup(extract(year from creation_date))

-- ##################################################################
-- SUPPLIER HEADER COUNT
-- ##################################################################

		select
			nvl(to_char(extract(year from creation_date)),'TOTAL') creation_year,
			sum(decode(extract (month from creation_date),1,1,0)) jan,
			sum(decode(extract (month from creation_date),2,1,0)) feb,
			sum(decode(extract (month from creation_date),3,1,0)) mar,
			sum(decode(extract (month from creation_date),4,1,0)) apr,
			sum(decode(extract (month from creation_date),5,1,0)) may,
			sum(decode(extract (month from creation_date),6,1,0)) jun,
			sum(decode(extract (month from creation_date),7,1,0)) jul,
			sum(decode(extract (month from creation_date),8,1,0)) aug,
			sum(decode(extract (month from creation_date),9,1,0)) sep,
			sum(decode(extract (month from creation_date),10,1,0)) oct,
			sum(decode(extract (month from creation_date),11,1,0)) nov,
			sum(decode(extract (month from creation_date),12,1,0)) dec,
			sum(1) total
		  from poz_suppliers_v
	  group by rollup(extract(year from creation_date))

-- ##################################################################
-- SUPPLIER SITE COUNT
-- ##################################################################

		select
			nvl(to_char(extract(year from creation_date)),'TOTAL') creation_year,
			sum(decode(extract (month from creation_date),1,1,0)) jan,
			sum(decode(extract (month from creation_date),2,1,0)) feb,
			sum(decode(extract (month from creation_date),3,1,0)) mar,
			sum(decode(extract (month from creation_date),4,1,0)) apr,
			sum(decode(extract (month from creation_date),5,1,0)) may,
			sum(decode(extract (month from creation_date),6,1,0)) jun,
			sum(decode(extract (month from creation_date),7,1,0)) jul,
			sum(decode(extract (month from creation_date),8,1,0)) aug,
			sum(decode(extract (month from creation_date),9,1,0)) sep,
			sum(decode(extract (month from creation_date),10,1,0)) oct,
			sum(decode(extract (month from creation_date),11,1,0)) nov,
			sum(decode(extract (month from creation_date),12,1,0)) dec,
			sum(1) total
		  from poz_supplier_sites_all_m
	  group by rollup(extract(year from creation_date))
