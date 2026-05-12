library "DiagnosticReportLab"
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'


valueset identifierType:'http://hl7.org/fhir/ValueSet/identifier-type'
valueset Status: 'http://hl7.org/fhir/ValueSet/diagnostic-report-status'
valueset ServiceSectionID: 'http://hl7.org/fhir/ValueSet/diagnostic-service-sections'
valueset ReportCodes: 'http://hl7.org/fhir/ValueSet/report-codes'

context Patient

define "InInitialPopulation":
  from [DiagnosticReport] DR
    where exists DR.meta.profile.where(StartsWith($this,'https://www.medizininformatik-initiative.de/fhir/core/modul-labor/StructureDefinition/DiagnosticReportLab'))

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

define function "Missing values DiagnosticReport.id"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.id is not null

define function "Missing values meta.source"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.meta.source is not null

define function "Missing values meta.profile"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.meta.profile is not null

define function "Missing values identifierTypeSystem"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.identifier.type.coding.system is not null

define function "Missing values identifierType"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.identifier.type.coding.where(system='http://terminology.hl7.org/CodeSystem/v2-0203') is not null

define function "Missing values identifierSystem"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.identifier.system is not null

define function "Missing values identifierValue"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.identifier.value is not null

define function "Missing values assigner"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.identifier.assigner is not null

define function "Missing values basedOn.reference"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.basedOn.reference is not null

define function "Missing values basedOn.identifier"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.basedOn.identifier is not null

define function "Missing values status"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.status is not null

define function "Missing values category.system"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.category.coding.system is not null

define function "Missing values LOINC"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.category.coding.where(system='http://loinc.org') is not null

define function "Missing values ServiceSectionID"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.category.coding.where(system='http://terminology.hl7.org/CodeSystem/v2-0074') is not null

define function "Missing values LOINC.Befund"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.code.coding.where(system='http://loinc.org') is not null

define function "Missing values subject.reference"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.subject.reference is not null

define function "Missing values subject.identifier"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.subject.identifier is not null

define function "Missing values encounter.reference"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.encounter.reference is not null

define function "Missing values encounter.identifier"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.encounter.identifier is not null

define function "Effective type"(DiagnosticReport DiagnosticReport):
  case
    when DiagnosticReport.effective is null then 'null'
    when DiagnosticReport.effective is dateTime then 'dateTime'
    when DiagnosticReport.effective is Period then 'Period'
    else 'unknown'
  end

define function "Missing values effective"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.effective is not null

define function "Missing values Dokumentationsdatum"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.issued is not null

define function "Missing values performer.reference"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.performer.reference is not null

define function "Missing values performer.identifier"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.performer.identifier is not null

define function "Missing values specimen.reference"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.specimen.reference is not null

define function "Missing values specimen.identifier"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.specimen.identifier is not null

define function "Missing values result.reference"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.result.reference is not null

define function "Missing values conclusion"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.conclusion is not null


/* 
Consistency 
DQI: Inadmissble categorical values
*/
  
define function "identifierType observed"(DiagnosticReport DiagnosticReport):
  ToCodeableConcept(DiagnosticReport.identifier.type.coding.where(system='http://terminology.hl7.org/CodeSystem/v2-0203'))
  
define function "Inadmissible categorical values identifierType"(DiagnosticReport DiagnosticReport):
  NonMatching(DiagnosticReport.identifier.type ,identifierType)


define function "Status observed"(DiagnosticReport DiagnosticReport):
  DiagnosticReport.status
  
define function "Inadmissible categorical values Status"(DiagnosticReport DiagnosticReport):
  if DiagnosticReport.status in "Status" then
    null
  else
    DiagnosticReport.status

// LOINC
define function "LOINC observed"(DiagnosticReport DiagnosticReport):
  ToCodeableConcept(DiagnosticReport.category.coding.where(system='http://loinc.org'))

define function "Inadmissible categorical values LOINC"(DiagnosticReport DiagnosticReport):
  NonMatching("LOINC observed"(DiagnosticReport), ReportCodes)

// Service Section ID
define function "ServiceSectionID observed"(DiagnosticReport DiagnosticReport):
  ToCodeableConcept(DiagnosticReport.category.coding.where(system='http://terminology.hl7.org/CodeSystem/v2-0074'))

define function "Inadmissible categorical values ServiceSectionID"(DiagnosticReport DiagnosticReport):
  NonMatching("ServiceSectionID observed"(DiagnosticReport), ServiceSectionID)

// LOINC Befund
define function "LOINC.Befund observed"(DiagnosticReport DiagnosticReport):
  ToCodeableConcept(DiagnosticReport.code.coding.where(system='http://loinc.org'))

define function "Inadmissible categorical values LOINC.Befund"(DiagnosticReport DiagnosticReport):
  NonMatching("LOINC.Befund observed"(DiagnosticReport), ReportCodes)