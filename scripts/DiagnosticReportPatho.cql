library "DiagnosticReportPatho"
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'


valueset identifierType:'http://hl7.org/fhir/ValueSet/identifier-type'
valueset Status: 'http://hl7.org/fhir/ValueSet/diagnostic-report-status'
valueset Schlussfolgerungscode: 'http://fhir.de/ValueSet/bfarm/icd-10-gm'
valueset ReportCodes: 'http://hl7.org/fhir/ValueSet/report-codes'

context Patient

/*  
define "InInitialPopulation":
  [DiagnosticReport]
*/

define "InInitialPopulation":
  from [DiagnosticReport] DR
    where exists DR.meta.profile.where(StartsWith($this,
        'https://www.medizininformatik-initiative.de/fhir/ext/modul-patho/StructureDefinition/mii-pr-patho-report'))

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

define function "Missing values ServiceRequest"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.basedOn.reference is not null

define function "Missing values Status"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.status is not null

define function "Missing values Pathology report code"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.code.coding.where(system='http://loinc.org') is not null

define function "Missing values subject"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.subject.reference is not null

define function "Missing values encounter"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.encounter.reference is not null


define function "Effective type"(DiagnosticReport DiagnosticReport):
  case
    when DiagnosticReport.effective is null then 'null'
    when DiagnosticReport.effective is dateTime then 'dateTime'
    when DiagnosticReport.effective is Period then 'Period'
    else 'unknown'
  end

define function "Missing values Dokumentationsdatum"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.effective is not null

define function "Missing values performer"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.performer.reference is not null

define function "Missing values specimen"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.specimen.reference is not null

define function "Missing values result"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.result is not null

define function "Missing values Schlussfolgerungscode"(DiagnosticReport DiagnosticReport): 
  DiagnosticReport.conclusionCode.coding.where(system='http://fhir.de/CodeSystem/bfarm/icd-10-gm') is not null

/* 
Consistency 
DQI: Inadmissble categorical values
*/


//identifierType
define function "identifierType observed"(DiagnosticReport DiagnosticReport):
  ToCodeableConcept(DiagnosticReport.identifier.type.coding.where(system='http://terminology.hl7.org/CodeSystem/v2-0203'))
  
define function "Inadmissible categorical values identifierType"(DiagnosticReport DiagnosticReport):
  NonMatching(DiagnosticReport.identifier.type ,identifierType)

// Status
define function "Status observed"(DiagnosticReport DiagnosticReport):
  DiagnosticReport.status
  
define function "Inadmissible categorical values Status"(DiagnosticReport DiagnosticReport):
  if DiagnosticReport.status in "Status" then
    null
  else
    DiagnosticReport.status

//Pathology Report Code
  
define function "Pathology report code observed"(DiagnosticReport DiagnosticReport):
  ToCodeableConcept(DiagnosticReport.code.coding.where(system='http://loinc.org'))
  
define function "Inadmissible categorical values Pathology report code"(DiagnosticReport DiagnosticReport):
  NonMatching("Pathology report code observed"(DiagnosticReport) ,ReportCodes)
  
//Schlussfolgerungscode

define function "Schlussfolgerungscode observed"(DiagnosticReport DiagnosticReport):
  ToCodeableConcept(DiagnosticReport.conclusionCode.coding.where(system='http://fhir.de/CodeSystem/bfarm/icd-10-gm'))

define function "Inadmissible categorical values Schlussfolgerungscode"(DiagnosticReport DiagnosticReport):
  NonMatching("Schlussfolgerungscode observed"(DiagnosticReport) ,Schlussfolgerungscode)