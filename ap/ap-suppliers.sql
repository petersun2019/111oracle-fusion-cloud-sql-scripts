/*
File Name: ap-suppliers.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- SUPPLIERS HEADERS 1
-- SUPPLIERS HEADERS 2 - USING POZ_SUPPLIERS_V VIEW
-- SUPPLIERS HEADERS AND SITES - WITH CONTACT INFO 1
-- SUPPLIERS HEADERS AND SITES - WITH CONTACT INFO 2
-- SUPPLIERS WITH CONTACT INFO
-- SUPPLIERS WITH DISBURSEMENT INFO
-- TABLE STORING REMITTANCE INFO LINKED TO A PAYMENT PROCESS PROFILE: IBY_REMIT_ADVICE_SETUP
-- COUNT OF REMIT_ADVICE_DELIVERY_METHOD
-- SUPPLIERS WITH LOCATIONS
-- SUPPLIERS - CREATED BY COUNT
-- SPLIT SUPPLIER NAMES INTO SEPARATE WORDS, USING SPACE AS DELIMITER (DELIMITER APPEARS AFTER THE "^" SYMBOL);
-- COUNT SUPPLIER NAMES SPLIT BY FIRST WORD OF THE SUPPLIER NAME
-- COUNT BY SUPPLIER TYPE
-- SUPPLIERS - TAX REGISTRATION NUMBER

*/

-- ##############################################################
-- SUPPLIERS HEADERS 1
-- ##############################################################

		select '#' || psv.vendor_id vendor_id
			 , hp.party_name
			 , ps.segment1 supplier_num
			 , ps.enabled_flag enabled
			 , ps.organization_type_lookup_code
			 , ps.vendor_type_lookup_code
		  from poz_suppliers ps
		  join hz_parties hp on ps.party_id = hp.party_id
		 where 1 = 1
		   -- and ps.enabled_flag = 'Y'
		   and 1 = 1

-- ##############################################################
-- SUPPLIERS HEADERS 2 - USING POZ_SUPPLIERS_V VIEW
-- ##############################################################

		select psv.vendor_id
			 , psv.vendor_name
			 , psv.segment1 supplier_num
			 , psv.enabled_flag enabled
			 , psv.organization_type_lookup_code
			 , psv.vendor_type_lookup_code
			 , to_char(psv.start_date_active, 'yyyy-mm-dd') start_date_active
			 , to_char(psv.end_date_active, 'yyyy-mm-dd') site_end_date
		  from poz_suppliers_v psv
		 where 1 = 1
		   and nvl(psv.end_date_active, sysdate + 1) > sysdate
		   and psv.enabled_flag = 'Y'
		   and 1 = 1

	-- ##############################################################
	-- SUPPLIERS HEADERS AND SITES 1
	-- ##############################################################

		select psv.vendor_name
			 , psv.segment1 supplier_num
			 -- , '#' || psv.vendor_id vendor_id
			 , prc_bu_id.bu_name procurement_bu
			 , psv.enabled_flag enabled
			 , psv.organization_type_lookup_code
			 , psv.vendor_type_lookup_code
			 , to_char(psv.creation_date, 'yyyy-mm-dd hh24:mi:ss') supplier_created
			 , psv.created_by supplier_created_by
			 , to_char(psv.last_update_date, 'yyyy-mm-dd hh24:mi:ss') supplier_updated
			 , psv.last_updated_by supplier_updated_by
			 , ps.auto_tax_calc_flag header_calc_tax
			 , ps.auto_tax_calc_override header_calc_tax_override
			 , ps.allow_awt_flag
			 , ps.withholding_status_lookup_code
			 , to_char(ps.withholding_start_date, 'yyyy-mm-dd') withholding_start_date
			 , '#' site_______________
			 , pssam.vendor_site_code site
			 , to_char(pssam.creation_date, 'yyyy-mm-dd hh24:mi:ss') site_created
			 , pssam.created_by site_created_by
			 , to_char(pssam.last_update_date, 'yyyy-mm-dd hh24:mi:ss') site_updated
			 , pssam.last_updated_by site_updated_by
			 , to_char(pssam.effective_start_date, 'yyyy-mm-dd') site_start_date
			 , to_char(pssam.effective_end_date, 'yyyy-mm-dd') site_end_date
			 , to_char(pssam.inactive_date, 'yyyy-mm-dd') site_inactive_date
			 , pssam.auto_tax_calc_flag site_calc_tax
			 , pssam.email_address
			 , '#' || pssam.party_site_id party_site_id
			 , nvl(pssam.terms_date_basis, 'Not Defined') site_terms_date_basis
			 , att.name site_payment_terms
			 , '#' || pssam.vendor_site_id site_id
			 , hp.party_number
			 , hp.party_name
			 , (select count(*) from ap_invoices_all aia where aia.vendor_id = psv.vendor_id and aia.vendor_site_id = pssam.vendor_site_id) invoice_count
			 , (select count(*) from po_headers_all pha where pha.vendor_id = psv.vendor_id and pha.vendor_site_id = pssam.vendor_site_id) po_count
		  from poz_suppliers_v psv
		  join poz_suppliers ps on psv.vendor_id = ps.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id
		  join hz_parties hp on psv.party_id = hp.party_id
	 left join ap_terms_tl att on pssam.terms_id = att.term_id and att.language = userenv('lang')
	 left join fun_all_business_units_v prc_bu_id on prc_bu_id.bu_id = pssam.prc_bu_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- SUPPLIERS HEADERS AND SITES - WITH CONTACT INFO 1
-- ##############################################################

/*
https://oraclebytes.com/supplier-details-query-in-oracle-fusion-poz_suppliers/
*/

		select hp.party_name vendor_name
			 , ps.segment1 supplier_number
			 , ps.vendor_type_lookup_code supplier_type
			 , ps.organization_type_lookup_code tax_organization_type
			 , ps.business_relationship
			 , hop.duns_number_c duns_number
			 , ps.customer_num
			 , ps.standard_industry_class sic
			 , hop.party_number registry_id
			 , hop.year_established
			 , hop.mission_statement
			 , psp.income_tax_id taxpayer_id
			 , hps.party_site_name address_name
			 , hp.address1
			 , hp.address2
			 , hp.city
			 , hp.state
			 , hp.county
			 , hp_contact.person_last_name||', '||hp_contact.person_pre_name_adjunct||' '||hp_contact.person_first_name contact_person
		  from poz_suppliers ps
		  join hz_parties hp on hp.party_id = ps.party_id
		  join hz_organization_profiles hop on hop.party_id = ps.party_id
	 left join poz_suppliers_pii psp on psp.vendor_id = ps.vendor_id
	 left join hz_party_sites hps on hps.party_site_id = hp.iden_addr_party_site_id
	 left join hz_parties hp_contact on hp_contact.party_id = hp.preferred_contact_person_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- SUPPLIERS HEADERS AND SITES - WITH CONTACT INFO 2
-- ##############################################################

/*
https://oraclebytes.com/supplier-details-query-in-oracle-fusion-poz_suppliers/
*/

		select hp.party_name vendor_name
			 , ps.segment1 supplier_number
			 , ps.vendor_type_lookup_code supplier_type
			 , ps.organization_type_lookup_code tax_organization_type
			 , ps.business_relationship
			 , hop.duns_number_c duns_number
			 , ps.customer_num
			 , ps.standard_industry_class sic
			 , hop.party_number registry_id
			 , hop.year_established
			 , hop.mission_statement
			 , psp.income_tax_id taxpayer_id
			 , hps.party_site_name address_name
			 , hp.address1
			 , hp.address2
			 , hp.city
			 , hp.state
			 , hp.county
			 , hp.person_last_name||', '||hp.person_pre_name_adjunct||' '||hp.person_first_name contact_person
		  from poz_suppliers ps
		  join hz_parties hp on hp.party_id = ps.party_id
		  join hz_organization_profiles hop on hop.party_id = ps.party_id
	 left join poz_suppliers_pii psp on psp.vendor_id = ps.vendor_id
	 left join hz_party_sites hps on hps.party_site_id = hp.iden_addr_party_site_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- SUPPLIERS WITH CONTACT INFO
-- ##############################################################

/*
http://oracleebsgeeks.blogspot.com/2020/08/sql-query-to-get-supplier-contact.html
04-JUL-2023
*/

		select hpo.party_name supplier_name
			 , hpp.person_pre_name_adjunct title
			 , hpp.person_first_name
			 , hpp.person_last_name
			 , hpp.status contact_status
			 , pu.username
			 , hc.job_title
			 , hps.party_site_name
			 , email.email_address
			 , email.last_updated_by
			 , email.last_update_date
			 , phone.phone_area_code
			 , phone.phone_number
		  FROM hz_parties hpo
		  join hz_relationships hzr on hzr.object_id = hpo.party_id
		  join hz_parties hpp on hpp.party_id = hzr.subject_id
		  join hz_org_contacts hc on hc.party_relationship_id = hzr.relationship_id
	 left join hz_org_contact_roles hor on hor.org_contact_id = hc.org_contact_id
	 left join poz_supplier_contacts poc on hzr.relationship_id = poc.relationship_id
	 left join hz_party_sites hps on hps.party_site_id =  poc.party_site_id
	 left join poz_suppliers ps on ps.party_id = hpo.party_id
	 left join per_users pu on pu.user_guid = hpp.user_guid
	 left join (select email_address
					 , owner_table_id
					 , last_updated_by
					 , to_char(last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
				  from hz_contact_points hcp 
				 where hcp.contact_point_type = 'EMAIL' 
				   and hcp.owner_table_name = 'HZ_PARTIES') email on email.owner_table_id = hpp.party_id
	 left join (select phone_country_code
					 , phone_area_code
					 , phone_number
					 , phone_extension
					 , owner_table_id from hz_contact_points hcp 
				 where hcp.contact_point_type = 'PHONE' 
				   and hcp.owner_table_name = 'HZ_PARTIES' 
				   and hcp.phone_line_type = 'GEN') phone on phone.owner_table_id = hpp.party_id
		 where 1 = 1
		   and hpo.party_type = 'ORGANIZATION'
		   and hpp.party_type = 'PERSON'
		   and hzr.relationship_code = 'CONTACT_OF'
		   and 1 = 1
	  order by email.last_update_date desc

-- ##############################################################
-- SUPPLIERS WITH DISBURSEMENT INFO
-- ##############################################################

		select psv.vendor_name
			 , psv.vendor_id
			 , psv.segment1 supplier_num
			 , psv.enabled_flag enabled
			 , pssam.vendor_site_code site
			 , to_char(pssam.effective_start_date, 'yyyy-mm-dd') site_start_date
			 , to_char(pssam.effective_end_date, 'yyyy-mm-dd') site_end_date
			 , to_char(pssam.inactive_date, 'yyyy-mm-dd') site_inactive_date
			 , case when iepa.ext_payee_id is not null and iepa.party_site_id is null and iepa.supplier_site_id is null then 'Supplier Header'
					when iepa.ext_payee_id is not null and iepa.party_site_id is not null and iepa.supplier_site_id is null then 'Address'
					when iepa.ext_payee_id is not null and iepa.party_site_id is not null and iepa.supplier_site_id is not null then 'Site'
			   end email_set_at
			 , iepa.remit_advice_email "iepa remit_advice_email"
			 , replace(iepa.remit_advice_email,' ','___') email_space
			 , case when substr(iepa.remit_advice_email,1,1) = ' ' then '<-- leading'
					when substr(iepa.remit_advice_email,-1,1) = ' ' then 'trailing -->'
			   end space_issue
			 , iepa.remit_advice_delivery_method "iepa remit_advice_delivery_method"
		  from poz_suppliers_v psv
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id
		  join iby_external_payees_all iepa on iepa.supplier_site_id = pssam.vendor_site_id and iepa.payment_function = 'PAYABLES_DISB'
		 where 1 = 1
		   and iepa.remit_advice_email is not null -- remittance advice email is populated
		   and iepa.ext_payee_id is not null and iepa.party_site_id is not null and iepa.supplier_site_id is not null -- disbursement is at site level
		   -- and iepa.party_site_id is null and iepa.supplier_site_id is null -- disbursement is at supplier level
		   -- and iepa.ext_payee_id is not null and iepa.party_site_id is not null and iepa.supplier_site_id is null -- disbursement is at address level
		   -- and substr(iepa.remit_advice_email,1,1) = ' ' or substr(iepa.remit_advice_email,-1,1) = ' ' -- leading or trailing spaces in email address
		   and 1 = 1

-- ##############################################################
-- TABLE STORING REMITTANCE INFO LINKED TO A PAYMENT PROCESS PROFILE: IBY_REMIT_ADVICE_SETUP
-- ##############################################################

		select * 
		  from iby_remit_advice_setup 
	  order by last_update_date desc

-- ##############################################################
-- COUNT OF REMIT_ADVICE_DELIVERY_METHOD
-- ##############################################################

		select iepa.remit_advice_delivery_method "iepa remit_advice_delivery_method"
			 , count(*)
		  from poz_suppliers_v psv
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id
		  join hz_parties hp on psv.party_id = hp.party_id
		  join iby_external_payees_all iepa on iepa.payee_party_id = hp.party_id and iepa.payment_function = 'PAYABLES_DISB'
		 where 1 = 1
		   and 1 = 1
	  group by iepa.remit_advice_delivery_method

-- ##############################################################
-- SUPPLIERS WITH LOCATIONS
-- ##############################################################

		select psv.vendor_id
			 , psv.vendor_name
			 , psv.segment1 supplier_num
			 , psv.enabled_flag enabled
			 , psv.organization_type_lookup_code
			 , psv.vendor_type_lookup_code
			 , to_char(pssam.effective_start_date, 'yyyy-mm-dd') site_start_date
			 , to_char(pssam.effective_end_date, 'yyyy-mm-dd') site_end_date
			 , to_char(pssam.inactive_date, 'yyyy-mm-dd') site_inactive_date
			 , pssam.vendor_site_code site_name
			 , pssam.email_address
			 , hzl.address1
			 , hzl.address2
			 , hzl.address3
			 , hzl.address4
			 , hzl.city
			 , hzl.state
			 , hzl.county
			 , hzl.country
			 , hzl.postal_code
			 , hps.duns_number_c
		  from poz_suppliers_v psv
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id
		  join hz_parties hp on psv.party_id = hp.party_id
	 left join hz_locations hzl on hzl.location_id = pssam.location_id
	 left join hz_party_sites hps on hps.party_site_id = pssam.party_site_id
		 where 1 = 1
		   -- and psv.enabled_flag = 'Y'
		   -- and regexp_substr(psv.vendor_name, '[^ ]+', 1, 1) = 'THE' -- SUPPLIER NAME STARTS WITH "THE"
		   -- and sysdate between pssam.effective_start_date and pssam.effective_end_date
		   -- and nvl(pssam.inactive_date, sysdate + 1) > sysdate
		   and 1 = 1

-- ##############################################################
-- SUPPLIERS - CREATED BY COUNT
-- ##############################################################

		select psv.created_by
			 , min(psv.creation_date)
			 , max(psv.creation_date)
			 , count(*)
		  from poz_suppliers_v psv
	  group by psv.created_by
	  order by 4 desc

-- ##############################################################
-- SPLIT SUPPLIER NAMES INTO SEPARATE WORDS, USING SPACE AS DELIMITER (DELIMITER APPEARS AFTER THE "^" SYMBOL);
-- ##############################################################

		select psv.vendor_name
			 , regexp_substr(psv.vendor_name, '[^ ]+', 1, 1) segment1
			 , regexp_substr(psv.vendor_name, '[^ ]+', 1, 2) segment2
			 , regexp_substr(psv.vendor_name, '[^ ]+', 1, 3) segment3
			 , regexp_substr(psv.vendor_name, '[^ ]+', 1, 4) segment4
			 , regexp_substr(psv.vendor_name, '[^ ]+', 1, 5) segment5
			 , regexp_substr(psv.vendor_name, '[^ ]+', 1, 6) segment6
			 , regexp_substr(psv.vendor_name, '[^ ]+', 1, 7) segment7
			 , regexp_substr(psv.vendor_name, '[^ ]+', 1, 8) segment8
			 , regexp_substr(psv.vendor_name, '[^ ]+', 1, 9) segment9
			 , regexp_substr(psv.vendor_name, '[^ ]+', 1, 10) segment10
		  from poz_suppliers_v psv

-- ##############################################################
-- COUNT SUPPLIER NAMES SPLIT BY FIRST WORD OF THE SUPPLIER NAME
-- ##############################################################

		select regexp_substr(psv.vendor_name, '[^ ]+', 1, 1) segment1
			 , count(*)
		  from poz_suppliers_v psv
	  group by regexp_substr(psv.vendor_name, '[^ ]+', 1, 1)
	  order by 2 desc

-- ##############################################################
-- COUNT BY SUPPLIER TYPE
-- ##############################################################

		select psv.vendor_type_lookup_code
			 , count(*)
		  from poz_suppliers_v psv
		 where psv.enabled_flag = 'Y'
		   and nvl(psv.end_date_active, sysdate + 1) > sysdate
	  group by psv.vendor_type_lookup_code
	  order by 2 desc

-- ##############################################################
-- SUPPLIERS - TAX REGISTRATION NUMBER
-- ##############################################################

/*
VAT Registration Number can be held at Supplier Header and / or Supplier Site level
*/

		select psv.vendor_name
			 -- , '#' || psv.vendor_id supp_id
			 , psv.segment1 supplier_num
			 , psv.enabled_flag supplier_enabled
			 , psv.organization_type_lookup_code
			 , psv.vendor_type_lookup_code
			 , to_char(pssam.effective_start_date, 'yyyy-mm-dd') site_start_date
			 , to_char(pssam.effective_end_date, 'yyyy-mm-dd') site_end_date
			 , to_char(pssam.inactive_date, 'yyyy-mm-dd') site_inactive_date
			 , pssam.vendor_site_code site
			 , pssam.email_address
			 , hp.party_number
			 , hp.party_name
			 , zptp_header.tax_classification_code supplier_tax_class_code
			 , zptp_site.tax_classification_code site_tax_class_code
			 -- , (select count(*) from ap_invoices_all aia where aia.vendor_id = psv.vendor_id and aia.vendor_site_id = pssam.vendor_site_id) invoice_count
			 , '#' || hp.party_id party_id
			 , '#' || psv.vendor_id vendor_id
			 , '#' || zptp_header.party_id zptp_header_party_id
			 , '#' || pssam.party_site_id
			 , '#' || pssam.vendor_site_id
			 , '#' || zptp_site.party_id zptp_site_party_id
			 , '#' || zptp_site.party_tax_profile_id party_tax_profile_id
			 , zr_header.tax_regime_code tax_regime_header
			 , zr_header.registration_number tax_reg_header
			 , zr_site.tax_regime_code tax_regime_site
			 , zr_site.registration_number tax_reg_site
			 , zptp_header.rep_registration_number header_reg_num_2
			 , zptp_site.rep_registration_number site_reg_num_2
			 , ps.vat_registration_num ps_vat_reg
			 , pssam.vat_registration_num pssam_vat_reg
		  from poz_suppliers_v psv
		  join poz_suppliers ps on ps.vendor_id = psv.vendor_id
		  join hz_parties hp on hp.party_id = psv.party_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id
	 left join zx_party_tax_profile zptp_header on zptp_header.party_id = hp.party_id and zptp_header.party_type_code = 'THIRD_PARTY'
	 left join zx_registrations zr_header on zr_header.party_tax_profile_id = zptp_header.party_tax_profile_id
	 left join zx_party_tax_profile zptp_site on zptp_site.party_id = pssam.party_site_id and zptp_site.party_type_code = 'THIRD_PARTY_SITE'
	 left join zx_registrations zr_site on zr_site.party_tax_profile_id = zptp_site.party_tax_profile_id
		 where 1 = 1
		   and 1 = 1

/*
http://oracleebslearning.blogspot.com/2012/10/how-is-due-date-calculated-on-payables.html
https://www.oracleerpappsguide.com/2014/07/r12-how-due-date-is-calculated-in-payable-invoices.html
*/
