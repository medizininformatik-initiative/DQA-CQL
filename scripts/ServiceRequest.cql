library "ServiceRequest"
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'

codesystem "v2-0203": 'http://terminology.hl7.org/CodeSystem/v2-0203'
valueset status: 'http://hl7.org/fhir/ValueSet/request-status'
valueset intent: 'http://hl7.org/fhir/ValueSet/request-intent'
valueset "ServiceRequest-category": 'http://hl7.org/fhir/ValueSet/servicerequest-category'
codesystem "ObservationCategory": 'http://terminology.hl7.org/CodeSystem/observation-category'
valueset Laborparameter: 'https://www.medizininformatik-initiative.de/fhir/core/modul-labor/ValueSet/ValueSetOrderCodes'

context Patient

define "InInitialPopulation":
    [ServiceRequest] S
        where exists S.meta.profile.where(StartsWith($this,
            'https://www.medizininformatik-initiative.de/fhir/core/modul-labor/StructureDefinition/ServiceRequestLab'))


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

define function "Missing Values ServiceRequest meta.source"(ServiceRequest ServiceRequest):
    ServiceRequest.meta.source is not null

define function "Missing Values ServiceRequest meta.profile"(ServiceRequest ServiceRequest):
    ServiceRequest.meta.profile is not null

define function "Missing Values identifierType"(ServiceRequest ServiceRequest):
    ServiceRequest.identifier.type.coding.where(system='http://terminology.hl7.org/CodeSystem/v2-0203') is not null

define function "Missing Values identifier.system"(ServiceRequest ServiceRequest):
    ServiceRequest.identifier.system is not null

define function "Missing Values identifierValue"(ServiceRequest ServiceRequest):
    ServiceRequest.identifier.value is not null

define function "Missing Values assigner"(ServiceRequest ServiceRequest):
    ServiceRequest.identifier.assigner is not null

define function "Missing Values status"(ServiceRequest ServiceRequest):
    ServiceRequest.status is not null

define function "Missing Values intent"(ServiceRequest ServiceRequest):
    ServiceRequest.intent is not null

define function "Missing Values category"(ServiceRequest ServiceRequest):
    ServiceRequest.category.coding.where(system='http://terminology.hl7.org/CodeSystem/observation-category') is not null

define function "Missing Values Laborparameter_LOINC"(ServiceRequest ServiceRequest):
    ServiceRequest.code.coding.where(system='http://mul-ct.de/fhir/CodeSystem/LabTests') is not null

define function "Missing Values Subject"(ServiceRequest ServiceRequest):
    ServiceRequest.subject is not null

define function "Missing Values Encounter"(ServiceRequest ServiceRequest):
    ServiceRequest.encounter is not null

define function "Missing Values Anforderungsdatum"(ServiceRequest ServiceRequest):
    ServiceRequest.authoredOn is not null

define function "Missing Values specimen.reference"(ServiceRequest ServiceRequest):
    ServiceRequest.specimen.reference is not null

define function "Missing Values specimen.identifier"(ServiceRequest ServiceRequest):
    ServiceRequest.specimen.identifier is not null

/* 
Consistency 
DQI: Inadmissble categorical values
*/

//identifierType
define function "identifierType observed"(ServiceRequest ServiceRequest):
  ToCodeableConcept(ServiceRequest.identifier.type.coding.where(system='http://terminology.hl7.org/CodeSystem/v2-0203'))
  
define function "Inadmissible categorical values identifierType"(ServiceRequest ServiceRequest):
  NonMatchingCS("identifierType observed"(ServiceRequest), "v2-0203")

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

//Klassifikation als Laborauftrag

define function "ServiceRequest category observed"(ServiceRequest ServiceRequest):
    ToCodeableConcept(ServiceRequest.category.coding.where(system='http://terminology.hl7.org/CodeSystem/observation-category'))

define function "Inadmissible categorical values ServiceRequest category"(ServiceRequest ServiceRequest):
   NonMatchingCS("ServiceRequest category observed"(ServiceRequest), ObservationCategory)

// Laborparameter LOINC

define function "Laborparameter LOINC observed"(ServiceRequest ServiceRequest):
    ToCodeableConcept(ServiceRequest.code.coding.where(system='http://mul-ct.de/fhir/CodeSystem/LabTests'))

define function "Inadmissible categorical values Laborparameter LOINC"(ServiceRequest ServiceRequest):
    NonMatchingVS("Laborparameter LOINC observed"(ServiceRequest), Laborparameter)