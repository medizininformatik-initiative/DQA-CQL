library "Condition"
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'

codesystem ICD10: 'http://fhir.de/CodeSystem/bfarm/icd-10-gm' //	http://fhir.de/ValueSet/bfarm/icd-10-gm OR 'https://www.medizininformatik-initiative.de/fhir/core/modul-diagnose/ValueSet/mii-vs-diagnose-icd10gm'
valueset Verifizierungsstatus: 'http://hl7.org/fhir/ValueSet/condition-ver-status'
valueset "Klinischer Status": 'http://hl7.org/fhir/ValueSet/condition-clinical'
valueset Diagnosesicherheit: 'https://fhir.kbv.de/ValueSet/KBV_VS_SFHIR_ICD_DIAGNOSESICHERHEIT'
valueset Seitenlokalisation: 'https://fhir.kbv.de/ValueSet/KBV_VS_SFHIR_ICD_SEITENLOKALISATION'
valueset "Mehrfachkodierungs-Kennzeichen": 'http://fhir.de/ValueSet/icd-10-gm-mehrfachcodierungs-kennzeichen'
valueset "BodySite": 'http://hl7.org/fhir/ValueSet/body-site'

context Patient

define InInitialPopulation:
  [Condition]


// Helper Functions
define function ToCodeableConcept(codings List<Coding>):
  if exists codings then
    CodeableConcept {
      coding: codings
    }
  else
    null

//NonMatching prüft momentan nur Codes und kein display  
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

define function "Missing values Condition.id" (condition Condition): 
  condition.id is not null

define function "Missing values Condition.meta" (condition Condition): 
  condition.meta is not null

  // Referenz Primaerdiagnose
define function "Missing values Primaerdiagnose"(condition Condition):
  exists(
    condition.extension.where(url = 'http://hl7.org/fhir/StructureDefinition/condition-related').value
  )

define function "Missing values Feststellungsdatum"(condition Condition):
  exists(
    condition.extension.where(url = 'http://hl7.org/fhir/StructureDefinition/condition-assertedDate').value
  )

define function "Missing values clinicalStatus"(condition Condition):
  exists(condition.clinicalStatus)


define function "Missing values Verifizierungsstatus"(condition Condition):
  exists(condition.verificationStatus)


define function "Missing values ICD10"(condition Condition):
  exists(
    condition.code.coding.where(system = 'http://fhir.de/CodeSystem/bfarm/icd-10-gm')
  )

define function "Missing values alpha-id"(condition Condition):
  exists(
    condition.code.coding.where(system = 'http://fhir.de/CodeSystem/bfarm/alpha-id')
  )

define function "Missing values SNOMED"(condition Condition):
  exists(
    condition.code.coding.where(system = 'http://snomed.info/sct')
  )

define function "Missing values Orpha"(condition Condition):
  exists(
    condition.code.coding.where(system = 'http://www.orpha.net')
  )

define function "Missing values bodySite"(condition Condition):
  exists(
    condition.bodySite.coding.where(system = 'http://snomed.info/sct')
  )

define function "Missing values subject"(condition Condition):
  exists(
    condition.subject.reference
  )

define function "Missing values encounter"(condition Condition):
  exists(
    condition.encounter.reference
  )

define function "Missing values Klinischer Zeitraum"(condition Condition):
  condition.onset is not null


define function "Missing values recordedDate"(condition Condition):
  exists(
    condition.recordedDate
  )

/* 
Consistency 
DQI: Inadmissble categorical values
*/

//ICD10

define function "icd-10-gm observed"(condition Condition):
  if condition.code.coding.where(system='http://fhir.de/CodeSystem/bfarm/icd-10-gm') is null then
    null
  else
    ToCodeableConcept({condition.code.coding.where(system='http://fhir.de/CodeSystem/bfarm/icd-10-gm')})

define function "Inadmissible categorical values icd-10-gm"(condition Condition):
  NonMatchingCS("icd-10-gm observed"(condition), ICD10)


// Verifizierungsstatus
define function "Verifizierungsstatus observed"(condition Condition):
  condition.verificationStatus


define function "Inadmissible categorical values Verifizierungsstatus"(condition Condition):
  NonMatching(condition.verificationStatus, "Verifizierungsstatus")

// Klinischer Status
define function "Klinischer Status observed"(condition Condition):
  condition.clinicalStatus

define function "Inadmissible categorical values Klinischer Status"(condition Condition):
  NonMatchingVS(condition.clinicalStatus, "Klinischer Status")

// Diagnosesicherheit
define function "Diagnosesicherheit observed"(condition Condition):
  ToCodeableConcept(condition.code.coding.extension.where(url = 'http://fhir.de/StructureDefinition/icd-10-gm-diagnosesicherheit').value)

define function "Inadmissible categorical values Diagnosesicherheit"(condition Condition):
  NonMatchingVS("Diagnosesicherheit observed"(condition), Diagnosesicherheit)


// Seitenlokalisation
define function "Seitenlokalisation observed"(condition Condition):
  ToCodeableConcept(condition.code.coding.extension.where(url = 'http://fhir.de/StructureDefinition/seitenlokalisation').value)

define function "Inadmissible categorical values Seitenlokalisation"(condition Condition):
  NonMatchingVS("Seitenlokalisation observed"(condition), Seitenlokalisation)


// bodySite
define function "bodySite observed"(condition Condition):
  ToCodeableConcept(condition.bodySite.coding.where(system = 'http://snomed.info/sct'))

define function "Inadmissible categorical values Seitenlokalisation"(condition Condition):
  NonMatchingVS("bodySite observed"(condition), BodySite)


// Mehrfachkodierungs-Kennzeichen
define function "Mehrfachkodierungs-Kennzeichen observed"(condition Condition):
  ToCodeableConcept(condition.code.coding.extension.where(url = 'http://fhir.de/StructureDefinition/icd-10-gm-mehrfachcodierungs-kennzeichen').value)

define function "Inadmissible categorical values Mehrfachkodierungs-Kennzeichen"(condition Condition):
  NonMatchingVS("Mehrfachkodierungs-Kennzeichen observed"(condition), "Mehrfachkodierungs-Kennzeichen")


/* 
Contradictions
DQI: Logical Contradictions
*/

// Klinischer Zeitraum

define function "Klinischer Zeitraum type"(condition Condition):
  case
    when condition.onset is null then 'null'
    when condition.onset is dateTime then 'dateTime'
    when condition.onset is Period then 'Period'
    else 'unknown'
  end

define function "Klinischer Zeitraum Ende ist vor klinischer Zeitraum Start"(condition Condition):
  condition.onset.start > condition.onset.end
