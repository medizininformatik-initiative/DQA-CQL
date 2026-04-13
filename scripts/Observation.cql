library "Observation"
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'

valueset identifierType: 'https://www.medizininformatik-initiative.de/fhir/core/modul-labor/ValueSet/mii-vs-labor-identifier-type-codes' 
codesystem "v2-0203": 'http://terminology.hl7.org/CodeSystem/v2-0203'
valueset ObservationStatus: 'http://hl7.org/fhir/ValueSet/observation-status'
valueset Laborbereich: 'https://www.medizininformatik-initiative.de/fhir/core/modul-labor/ValueSet/Laborbereich'
valueset ObservationCategory: 'http://terminology.hl7.org/ValueSet/observation-category'
valueset Laborparameter: 'http://hl7.org/fhir/uv/ips/ValueSet/results-laboratory-observations-uv-ips' //'http://hl7.org/fhir/ValueSet/observation-codes'
valueset Laborergebnis: 'https://www.medizininformatik-initiative.de/fhir/core/modul-labor/ValueSet/Laborergebnis-qualitativ'
valueset Interpretation: 'http://hl7.org/fhir/ValueSet/observation-interpretation'
codesystem LOINC: 'http://loinc.org'

context Patient

define "InInitialPopulation":
    [Observation] O
        where not exists O.meta.profile.where(StartsWith($this,
            'https://gematik.de/fhir/isik/StructureDefinition/sd-mii-icu-o2saettigung-im-arteriellen-blut-durch-pulsoxymetrie'))

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
  if FHIRHelpers.ToConcept(concept) in codesystem then
    null
  else
    concept


/* 
Completeness
DQI: Missing values
*/

define function "Missing values Observation.id"(Observation Observation): 
  Observation.id is not null

define function "Missing values meta.source"(Observation Observation): 
  Observation.meta.source is not null

define function "Missing values meta.profile"(Observation Observation): 
  Observation.meta.profile is not null 

define function "Missing values modifierExtension"(Observation Observation): 
  Observation.modifierExtension is not null 

define function "Missing values identifierType"(Observation Observation): 
  Observation.identifier.type.coding.where(system='http://terminology.hl7.org/CodeSystem/v2-0203') is not null

define function "Missing values identifier System"(Observation Observation): 
  Observation.identifier.system is not null

define function "Missing values identifier Value"(Observation Observation): 
  Observation.identifier.value is not null

define function "Missing values identifier assigner"(Observation Observation): 
  Observation.identifier.assigner is not null

define function "Missing values status"(Observation Observation): 
  Observation.status is not null

define function "Missing values loinc-observation"(Observation Observation): 
  Observation.category.coding.where(system='http://loinc.org') is not null

define function "Missing values observation-category"(Observation Observation): 
  Observation.category.coding.where(system='http://terminology.hl7.org/CodeSystem/observation-category') is not null

define function "Missing values Laborgruppe"(Observation Observation): 
  Observation.category.coding.where(system='http://exmple.org/fhir/sid/Laborgruppe') is not null

define function "Missing values Laborparameter"(Observation Observation): 
  Observation.code.coding.where(system='http://loinc.org') is not null

define function "Missing values subject"(Observation Observation): 
  Observation.subject is not null

define function "Missing values encounter"(Observation Observation): 
  Observation.encounter.reference is not null

define function "Missing values Untersuchungszeitpunkt"(Observation Observation): 
  Observation.effective is not null

define function "Missing values Dokumentationsdatum"(Observation Observation): 
  Observation.issued is not null

define function "Missing values Messwert"(Observation Observation): 
  Observation.value is not null

define function "Missing values dataAbsentReason"(Observation Observation): 
  Observation.dataAbsentReason is not null

define function "Missing values Interpretation"(Observation Observation): 
  Observation.interpretation is not null

define function "Missing values note"(Observation Observation): 
  Observation.note is not null

define function "Missing values method.coding.system"(Observation Observation): 
  Observation.method.coding.system is not null

define function "Missing values method.coding.code"(Observation Observation): 
  Observation.method.coding.code is not null

define function "Missing values method.coding.display"(Observation Observation): 
  Observation.method.coding.display is not null

define function "Missing values specimen.reference"(Observation Observation): 
  Observation.specimen.reference is not null

define function "Missing values specimen.identifier"(Observation Observation): 
  Observation.specimen.identifier is not null

define function "Missing values device.reference"(Observation Observation): 
  Observation.device.reference is not null

define function "Missing values device.identifier"(Observation Observation): 
  Observation.device.identifier is not null

define function "Missing values referenceRange.low"(Observation Observation): 
  Observation.referenceRange.low is not null

define function "Missing values referenceRange.high"(Observation Observation): 
  Observation.referenceRange.high is not null

/* 
Consistency 
DQI: Inadmissble categorical values
*/

//identifierType
define function "identifierType observed"(Observation Observation):
  ToCodeableConcept(Observation.identifier.type.coding.where(system='http://terminology.hl7.org/CodeSystem/v2-0203'))
  
define function "Inadmissible categorical values identifierType"(Observation Observation):
  NonMatchingVS("identifierType observed"(Observation) ,identifierType)

//Observation Status
define function "Status observed"(Observation Observation):
  Observation.status
  
define function "Inadmissible categorical values Status"(Observation Observation):
  if Observation.status in ObservationStatus then
    null
  else
    Observation.status

// LOINC Observation
define function "loinc-observation observed"(Observation Observation):
  ToCodeableConcept(Observation.category.coding.where(system='http://loinc.org'))
  
define function "Inadmissible categorical values loinc-observation"(Observation Observation):
  NonMatchingVS("loinc-observation observed"(Observation) ,Laborbereich)

// Observation Category
define function "observation-category observed"(Observation Observation):
  ToCodeableConcept(Observation.category.coding.where(system='http://terminology.hl7.org/CodeSystem/observation-category'))
  
define function "Inadmissible categorical values observation-category"(Observation Observation):
  NonMatchingVS("observation-category observed"(Observation), ObservationCategory)

//Laborparameter

define function "Laborparameter Loinc observed"(Observation Observation):
  ToCodeableConcept(Observation.code.coding.where(system='http://loinc.org'))
  
define function "Inadmissible categorical values Laborparameter Loinc"(Observation Observation):
  NonMatchingCS("Laborparameter Loinc observed"(Observation), LOINC)

//Laborergebnis_Qualitativ
define function "Laborergebnis_Qualitativ observed"(Observation Observation): 
  ToCodeableConcept(Observation.value.coding.where(system='http://snomed.info/sct'))

define function "Inadmissible categorical values Laborergebnis_Qualitativ"(Observation Observation):
  NonMatchingVS("Laborergebnis_Qualitativ observed"(Observation), Laborergebnis)

//Interpretation
define function "Interpretation observed"(Observation Observation): 
  ToCodeableConcept(Observation.interpretation.coding.where(system='http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation'))

define function "Inadmissible categorical values Interpretation"(Observation Observation):
  NonMatchingVS("Interpretation observed"(Observation), Interpretation)


/* 
Contradictions
DQI: Logical Contradictions
*/

define function "Dokumentationsdatum ist vor ist vor Untersuchungszeitpunkt"(Observation Observation):
  (Observation.issued < Observation.effective) is true