library "DiagnosticReportLab"
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'

/*  
codesystem "v2-0074": 'http://terminology.hl7.org/CodeSystem/v2-0074'
code "Labor": 'LAB' from "v2-0074"
*/

/*  
codesystem loinc: 'http://loinc.org'
code "Labor": '11502-2' from loinc
*/


valueset identifierType:'http://hl7.org/fhir/ValueSet/identifier-type'
valueset Status: 'http://hl7.org/fhir/ValueSet/diagnostic-report-status'
valueset ServiceSectionID: 'http://hl7.org/fhir/ValueSet/diagnostic-service-sections'
valueset ReportCodes: 'http://hl7.org/fhir/ValueSet/report-codes'

context Patient

/*  
define "InInitialPopulation":
  [DiagnosticReport]
*/

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

define function "Missing values meta"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.meta is not null

define function "Missing values identifierType"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.identifier.type.coding.where(system='http://terminology.hl7.org/CodeSystem/v2-0203') is not null

define function "Missing values identifierValue"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.identifier.value is not null

define function "Missing values basedOn"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.basedOn is not null

define function "Missing values status"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.status is not null

define function "Missing values LOINC"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.category.coding.where(system='http://loinc.org') is not null

define function "Missing values ServiceSectionID"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.category.coding.where(system='http://terminology.hl7.org/CodeSystem/v2-0074') is not null

define function "Missing values LOINC.Befund"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.code.coding.where(system='http://loinc.org') is not null

define function "Missing values subject"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.subject is not null

define function "Missing values encounter"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.encounter is not null

define function "Missing values observation"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.result is not null

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