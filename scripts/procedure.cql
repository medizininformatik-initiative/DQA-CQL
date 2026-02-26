library "procedure"
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'

valueset procedure_category_sct: 'https://www.medizininformatik-initiative.de/fhir/core/modul-prozedur/ValueSet/procedures-category-sct'
valueset OPS: 'http://fhir.de/ValueSet/bfarm/ops'

context Patient

define InInitialPopulation:
  [Procedure]

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

define function "Missing values Procedure.id" (procedure Procedure): 
  procedure.id is not null

define function "Missing values Procedure.meta" (procedure Procedure): 
  procedure.meta is not null

 /* 
define function "Missing values Dokumentationsdatum"(procedure Procedure):
  procedure.extension.where(url='https://www.medizininformatik-initiative.de/fhir/core/modul-prozedur/StructureDefinition/Durchfuehrungsabsicht').valueDateTime
*/


 /* 
define function "Missing values Durchfuehrungsabsicht" (procedure Procedure) 
  procedure.extension.where(url='https://www.medizininformatik-initiative.de/fhir/core/modul-prozedur/StructureDefinition/Durchfuehrungsabsicht')
*/ 


define function "Missing values status" (procedure Procedure): 
  procedure.status is not null

define function "Missing values SNOMED.code" (procedure Procedure):
  exists(procedure.category.coding.where(system='http://snomed.info/sct').code)

define function "Missing values SNOMED.display" (procedure Procedure):
  exists(procedure.category.coding.where(system='http://snomed.info/sct').display)


define function "Missing values OPS.code" (procedure Procedure):
  exists(procedure.code.coding.where(system='http://fhir.de/CodeSystem/bfarm/ops').code)

define function "Missing values OPS.display" (procedure Procedure):
  exists(procedure.code.coding.where(system='http://fhir.de/CodeSystem/bfarm/ops').display)


define function "Missing values subject" (procedure Procedure):
  exists(procedure.subject.reference)

define function "Missing values encounter" (procedure Procedure):
  exists(procedure.encounter.reference)

define function "Missing values Durchfuehrungsdatum" (procedure Procedure):
  exists(procedure.performed as dateTime) 

/* Consistency
DQI: Inadmissble categorical values
*/

//SNOMED
define function "procedure_category_sct observed"(procedure Procedure):
  if procedure.category.coding.where(system='http://snomed.info/sct') is null then
    null
  else
    ToCodeableConcept({procedure.category.coding.where(system='http://snomed.info/sct')})

define function "Inadmissible categorical values procedure_category_sct"(procedure Procedure):
  NonMatching("procedure_category_sct observed"(procedure), procedure_category_sct)

//OPS
define function "OPS observed"(procedure Procedure):
  if procedure.code.coding.where(system='http://fhir.de/CodeSystem/bfarm/ops') is null then
    null
  else
    ToCodeableConcept({procedure.code.coding.where(system='http://fhir.de/CodeSystem/bfarm/ops')})

//define function "Inadmissible categorical values OPS"(procedure Procedure):
//  NonMatching("OPS observed"(procedure), OPS)



