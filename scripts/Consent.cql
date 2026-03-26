library "Consent"
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'

valueset ConsentCategory: 'http://hl7.org/fhir/ValueSet/consent-category'
valueset ConsentProvisionType: 'http://hl7.org/fhir/ValueSet/consent-provision-type'

context Patient

define InInitialPopulation:
  [Consent]


// Helper Functions
define function ToCodeableConcept(codings List<Coding>):
  if exists codings then
    CodeableConcept {
      coding: codings
    }
  else
    null

//NonMatching prüft momentan nur Codes und kein display  
define function NonMatching(concept CodeableConcept, valueset System.ValueSet):
  if FHIRHelpers.ToConcept(concept) in valueset then
    null
  else
    concept
 
/* 
Completeness
DQI: Missing values
*/

define function "Missing values Consent.id" (consent Consent): 
  consent.id is not null

define function "Missing values Consent.meta" (consent Consent): 
  consent.meta is not null

define function "Missing values Consent.status" (consent Consent): 
  consent.status is not null

define function "Missing values consent-category Loinc" (consent Consent): 
  exists(consent.category.coding.where(system='http://loinc.org').code)

define function "Missing values MII consent-category" (consent Consent): 
  exists(consent.category.coding.where(system='https://www.medizininformatik-initiative.de/fhir/modul-consent/CodeSystem/mii-cs-consent-consent_category').code)

define function "Missing values Patient" (consent Consent): 
  exists(consent.patient.reference)

define function "Missing values Erstellungszeitpunkt"(consent Consent): 
    exists(consent.dateTime)

define function "Missing values policy"(consent Consent): 
  exists(consent.policy)

define function "Missing values Beginn der Gültigkeit der Consent-Policy"(consent Consent): 
  exists(consent.provision.period.start)

define function "Missing values Ende der Gültigkeit der Consent-Policy"(consent Consent): 
  exists(consent.provision.period.end)

define function "Missing values provision type"(consent Consent): 
  exists(consent.provision.type)

/* 
Consistency 
DQI: Inadmissble categorical values
*/

// Consent Category
define function "consent-category Loinc observed"(consent Consent):
  if consent.category.coding.where(system='http://loinc.org') is null then
    null
  else
    ToCodeableConcept(consent.category.coding.where(system='http://loinc.org'))

define function "Inadmissible categorical values consent-category Loinc"(consent Consent):
  NonMatching("consent-category Loinc observed"(consent), ConsentCategory)


// mii-cs-consent-consent_category
 
define function "MII consent-category observed"(consent Consent):
  if consent.category.coding.where(system='https://www.medizininformatik-initiative.de/fhir/modul-consent/CodeSystem/mii-cs-consent-consent_category') is null then
    null
  else
    ToCodeableConcept(consent.category.coding.where(system='https://www.medizininformatik-initiative.de/fhir/modul-consent/CodeSystem/mii-cs-consent-consent_category'))

define function "Inadmissible categorical values MII consent-category"(consent Consent):
  NonMatching("MII consent-category observed"(consent), ConsentCategory)

// Provision Type
define function "Provision Type observed"(consent Consent):
  if consent.provision.type is null then
    null
  else
    consent.provision.type

define function "Inadmissible categorical values Provision Type"(consent Consent):
   if consent.provision.type in ConsentProvisionType then
    null
  else
    consent.provision.type



/* 
Contradictions
DQI: Logical Contradictions
*/

define function "Consent-Policy - Ende der Gültigkeit vor Beginn der Gültigkeit"(consent Consent):
  consent.provision.period.start > consent.provision.period.end
