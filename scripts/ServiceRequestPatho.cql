library "ServiceRequestPatho"
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'

codesystem "v2-0203": 'http://terminology.hl7.org/CodeSystem/v2-0203'
valueset status: 'http://hl7.org/fhir/ValueSet/request-status'
valueset intent: 'http://hl7.org/fhir/ValueSet/request-intent'
valueset "ServiceRequest-category": 'http://hl7.org/fhir/ValueSet/servicerequest-category'
codesystem "ObservationCategory": 'http://terminology.hl7.org/CodeSystem/observation-category'
valueset Laborparameter: 'https://www.medizininformatik-initiative.de/fhir/core/modul-labor/ValueSet/ValueSetOrderCodes'
codesystem SNOMED: 'http://snomed.info/sct'

context Patient

define "InInitialPopulation":
    [ServiceRequest] S
        where S.meta.profile contains 'https://www.medizininformatik-initiative.de/fhir/ext/modul-patho/StructureDefinition/mii-pr-patho-service-request'

// Helper Functions
define function ToCodeableConcept(codings List<Coding>):
  if exists codings then
    CodeableConcept {
      coding: codings
    }
  else
    null

//NonMatching prüft momentan nur Codes und kein display 
//NonMatching ValueSet 
define function NonMatchingVS(concept CodeableConcept, valueset System.ValueSet):
  if FHIRHelpers.ToConcept(concept) in valueset then
    null
  else
    concept

//NonMatching Codesystem
define function NonMatchingCS(concept CodeableConcept, codesystem System.CodeSystem):
  if concept is null then
    null
  else if FHIRHelpers.ToConcept(concept) in codesystem then
    null
  else
    concept

/* 
Completeness
DQI: Missing values
*/

define function "Missing Values ServiceRequest id"(ServiceRequest ServiceRequest):
    ServiceRequest.id is not null

define function "Missing Values ServiceRequest meta"(ServiceRequest ServiceRequest):
    ServiceRequest.meta is not null

define function "Missing Values identifierType"(ServiceRequest ServiceRequest):
  ServiceRequest.identifier.type.coding.where(system='http://terminology.hl7.org/CodeSystem/v2-0203') is not null
    

define function "Missing Values identifierValue"(ServiceRequest ServiceRequest):
    ServiceRequest.identifier.value is not null

define function "Missing Values Identifikator für Auftragsgruppen"(ServiceRequest ServiceRequest):
    ServiceRequest.requisition is not null

define function "Missing Values status"(ServiceRequest ServiceRequest):
    ServiceRequest.status is not null

define function "Missing Values Kategorie des Untersuchungsauftrags"(ServiceRequest ServiceRequest):
    ServiceRequest.category.coding.where(system='http://snomed.info/sct') is not null


define function "Missing Values Code für die angeforderte Leistung"(ServiceRequest ServiceRequest):
  ServiceRequest.code is not null

define function "Missing Values subject"(ServiceRequest ServiceRequest):
  ServiceRequest.subject is not null

define function "Missing Values encounter"(ServiceRequest ServiceRequest):
  ServiceRequest.encounter is not null

define function "Missing Values authoredOn"(ServiceRequest ServiceRequest):
  ServiceRequest.authoredOn is not null

define function "Missing Values requester"(ServiceRequest ServiceRequest):
  ServiceRequest.requester is not null

define function "Missing Values specimen"(ServiceRequest ServiceRequest):
  ServiceRequest.specimen is not null

/* 
Consistency 
DQI: Inadmissble categorical values
*/

//identifierType
define function "identifierType observed"(ServiceRequest ServiceRequest):
  ToCodeableConcept(ServiceRequest.identifier.type.coding.where(system='http://terminology.hl7.org/CodeSystem/v2-0203'))
  
//define function "Inadmissible categorical values identifierType"(ServiceRequest ServiceRequest):
//  NonMatchingCS("identifierType observed"(ServiceRequest), "v2-0203")

// Status
define function "Status observed"(ServiceRequest ServiceRequest):
  ServiceRequest.status

define function "Inadmissible categorical values Status"(ServiceRequest ServiceRequest):
    if ServiceRequest.status in status then
        null
     else
        ServiceRequest.status

//Intent
define function "Intent observed"(ServiceRequest ServiceRequest):
    ServiceRequest.intent

define function "Inadmissible categorical values Intent"(ServiceRequest ServiceRequest):
  if ServiceRequest.intent in intent then
    null
  else
    ServiceRequest.intent

//Kategorie des Untersuchungsauftrags

define function "Kategorie des Untersuchungsauftrags observed"(ServiceRequest ServiceRequest):
  ToCodeableConcept(ServiceRequest.category.coding.where(system='http://snomed.info/sct'))

define function "Inadmissible categorical values Kategorie des Untersuchungsauftrags"(ServiceRequest ServiceRequest):
  NonMatchingCS("Kategorie des Untersuchungsauftrags observed"(ServiceRequest), SNOMED)

// Code für die angeforderte Leistung

define function "Code für die angeforderte Leistung observed"(ServiceRequest ServiceRequest):
  ToCodeableConcept(ServiceRequest.code.coding.where(system='http://mul-ct.de/fhir/CodeSystem/LabTests'))
