library "MedicationRequest"
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'

valueset Status:'http://hl7.org/fhir/ValueSet/medicationrequest-status'
valueset intent:'http://hl7.org/fhir/ValueSet/medicationrequest-intent'
valueset route:'http://hl7.org/fhir/uv/ips/ValueSet/medicine-route-of-administration'

context Patient

define InInitialPopulation:
  [MedicationRequest]

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

define function "Missing values MedicationRequest.id"(MedicationRequest MedicationRequest): 
  MedicationRequest.id is not null

define function "Missing values MedicationRequest.meta.source"(MedicationRequest MedicationRequest): 
  MedicationRequest.meta.source is not null

define function "Missing values MedicationRequest.meta.profile"(MedicationRequest MedicationRequest): 
  MedicationRequest.meta.profile is not null

define function "Missing values identifier"(MedicationRequest MedicationRequest): 
  MedicationRequest.identifier is not null

define function "Missing values Status"(MedicationRequest MedicationRequest): 
  MedicationRequest.status is not null

define function "Missing values Intention"(MedicationRequest MedicationRequest): 
  MedicationRequest.intent is not null

define function "Missing values medication"(MedicationRequest MedicationRequest): 
  if MedicationRequest.medication is Reference then
    (MedicationRequest.medication as Reference).reference is not null
  else if MedicationRequest.medication is CodeableConcept then
    (MedicationRequest.medication as CodeableConcept).coding.code is not null
  else
    false

define function "Missing values subject"(MedicationRequest MedicationRequest): 
  MedicationRequest.subject.reference is not null

define function "Missing values encounter"(MedicationRequest MedicationRequest): 
  MedicationRequest.encounter.reference is not null

define function "Missing values authoredOn"(MedicationRequest MedicationRequest): 
  MedicationRequest.authoredOn is not null

define function "Missing values requester"(MedicationRequest MedicationRequest): 
  MedicationRequest.requester is not null

define function "Missing values reasonCode"(MedicationRequest MedicationRequest): 
  MedicationRequest.reasonCode is not null

define function "Missing values reasonReference"(MedicationRequest MedicationRequest): 
  MedicationRequest.reasonReference is not null

define function "Missing values basedOn"(MedicationRequest MedicationRequest): 
  MedicationRequest.basedOn is not null

define function "Missing values note"(MedicationRequest MedicationRequest): 
  MedicationRequest.note is not null

define function "Missing values dosageInstruction.sequence"(MedicationRequest MedicationRequest): 
  MedicationRequest.dosageInstruction.sequence is not null

define function "Missing values dosageInstruction.text"(MedicationRequest MedicationRequest): 
  MedicationRequest.dosageInstruction.text is not null

define function "Missing values dosageInstruction.timing.event"(MedicationRequest MedicationRequest): 
  MedicationRequest.dosageInstruction.timing.event is not null

define function "Missing values dosageInstruction.timing.repeat"(MedicationRequest MedicationRequest): 
  MedicationRequest.dosageInstruction.timing.repeat is not null

define function "Missing values dosageInstruction.asNeeded"(MedicationRequest MedicationRequest): 
  MedicationRequest.dosageInstruction.asNeeded is not null
  
define function "Missing values dosageInstruction.site.coding.system"(MedicationRequest MedicationRequest): 
  MedicationRequest.dosageInstruction.site.coding.system is not null

define function "Missing values dosageInstruction.site.coding.code"(MedicationRequest MedicationRequest): 
  MedicationRequest.dosageInstruction.site.coding.code is not null

define function "Missing values dosageInstruction.route.coding.system"(MedicationRequest MedicationRequest): 
  MedicationRequest.dosageInstruction.route.coding.system is not null

define function "Missing values dosageInstruction.route.coding.code"(MedicationRequest MedicationRequest): 
  MedicationRequest.dosageInstruction.route.coding.code is not null

define function "Missing values dosageInstruction.doseAndRate"(MedicationRequest MedicationRequest): 
  MedicationRequest.dosageInstruction.doseAndRate is not null

define function "Missing values dosageInstruction.maxDosePerPeriod"(MedicationRequest MedicationRequest): 
  MedicationRequest.dosageInstruction.maxDosePerPeriod is not null

define function "Missing values dosageInstruction.maxDosePerAdministration"(MedicationRequest MedicationRequest): 
  MedicationRequest.dosageInstruction.maxDosePerAdministration is not null

define function "Missing values substitution"(MedicationRequest MedicationRequest): 
  MedicationRequest.substitution is not null

define function "Missing values priorPrescription"(MedicationRequest MedicationRequest): 
  MedicationRequest.priorPrescription is not null

/* 
Consistency 
DQI: Inadmissble categorical values
*/

define function "Status observed"(MedicationRequest MedicationRequest):
  MedicationRequest.status

define function "Inadmissible categorical values Status"(MedicationRequest MedicationRequest):
  if MedicationRequest.status in "Status" then
    null
  else
    MedicationRequest.status


define function "Intention observed"(MedicationRequest MedicationRequest):
  MedicationRequest.intent

define function "Inadmissible categorical values Intention"(MedicationRequest MedicationRequest):
  if MedicationRequest.intent in "intent" then
    null
  else
    MedicationRequest.intent

define function "Weg der Anwendung observed"(MedicationRequest MedicationRequest):
  ToCodeableConcept(MedicationRequest.dosageInstruction.route.coding.where(system='http://standardterms.edqm.eu'))

define function "Inadmissible categorical values dosage.route"(MedicationRequest MedicationRequest):
  NonMatching(MedicationRequest.dosageInstruction.route ,route)
