library "List"
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'

valueset Status: 'http://hl7.org/fhir/ValueSet/list-status'
valueset mode: 'http://hl7.org/fhir/ValueSet/list-mode'
valueset Medikationslistencode: 'http://terminology.hl7.org/ValueSet/list-example-codes'
valueset Fallkontext: 'https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/ValueSet/fallkontext'

context Patient

define InInitialPopulation:
  ["List"]


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

define function "Missing values List.id"(lst "List"):
  lst.id is not null

define function "Missing values List.meta"(lst "List"):
  lst.meta is not null

define function "Missing values List.status"(lst "List"):
  lst.status is not null

define function "Missing values List.mode"(lst "List"):
  lst.mode is not null

define function "Missing values List.title"(lst "List"):
  lst.title is not null

define function "Missing values Medikationslistencode"(lst "List"):
  lst.code.coding.where(system='http://terminology.hl7.org/CodeSystem/list-example-use-codes') is not null

define function "Missing values Fallkontext"(lst "List"):
  lst.code.coding.where(system='http://ihe-d.de/CodeSystems/FallkontextBeiDokumentenerstellung') is not null

define function "Missing values subject"(lst "List"):
  lst.subject is not null

define function "Missing values encounter"(lst "List"):
  lst.encounter is not null

define function "Missing values entry"(lst "List"):
  lst.entry is not null


/* 
Consistency 
DQI: Inadmissble categorical values
*/

define function "Status observed"(lst "List"):
  lst.status

define function "Inadmissible categorical values Status"(lst "List"):
  if lst.status in "Status" then
    null
  else
    lst.status

define function "mode observed"(lst "List"):
  lst.mode

define function "Inadmissible categorical values mode"(lst "List"):
  if lst.mode in "mode" then
    null
  else
    lst.mode


define function "Medikationslistencode observed"(lst "List"):
  ToCodeableConcept(lst.code.coding.where(system='http://terminology.hl7.org/CodeSystem/list-example-use-codes'))

define function "Inadmissible categorical values Medikationslistencode"(lst "List"):
  if lst.code.coding.where(system='http://terminology.hl7.org/CodeSystem/list-example-use-codes').code.first() in "Medikationslistencode" then
    null
  else 
    lst.code.coding.where(system='http://terminology.hl7.org/CodeSystem/list-example-use-codes').code.first()


define function "Fallkontext observed"(lst "List"):
  ToCodeableConcept(lst.code.coding.where(system='http://ihe-d.de/CodeSystems/FallkontextBeiDokumentenerstellung'))

define function "Inadmissible categorical values Fallkontext"(lst "List"):
  if lst.code.coding.where(system='http://ihe-d.de/CodeSystems/FallkontextBeiDokumentenerstellung').code.first() in "Fallkontext" then
    null
  else 
    lst.code.coding.where(system='http://ihe-d.de/CodeSystems/FallkontextBeiDokumentenerstellung').code.first()
