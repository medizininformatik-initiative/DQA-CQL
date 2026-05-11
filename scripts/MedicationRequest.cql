library "MedicationRequest"
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'

valueset Status: 'http://hl7.org/fhir/ValueSet/medicationrequest-status'
valueset intent: 'http://hl7.org/fhir/ValueSet/medicationrequest-intent'
valueset route: 'http://hl7.org/fhir/uv/ips/ValueSet/medicine-route-of-administration'

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

define function "Missing values MedicationRequest.id"(medicationRequest MedicationRequest): 
  medicationRequest.id is not null

define function "Missing values MedicationRequest.meta"(medicationRequest MedicationRequest):
  medicationRequest.meta is not null

define function "Missing values Status"(medicationRequest MedicationRequest): 
  medicationRequest.status is not null

define function "Missing values Intention"(medicationRequest MedicationRequest): 
  medicationRequest.intent is not null

define function "Missing values medicationReference"(medicationRequest MedicationRequest): 
  if medicationRequest.medication is Reference then
    (medicationRequest.medication as Reference).reference is not null
  else
    false

define function "Missing values subject"(medicationRequest MedicationRequest): 
  medicationRequest.subject.reference is not null

define function "Missing values encounter"(medicationRequest MedicationRequest): 
  medicationRequest.encounter.reference is not null

define function "Missing values authoredOn"(medicationRequest MedicationRequest): 
  medicationRequest.authoredOn is not null

define function "Missing values dosageInstruction.timing"(medicationRequest MedicationRequest): 
  medicationRequest.dosageInstruction.timing is not null

define function "Missing values dosageInstruction.route"(medicationRequest MedicationRequest):
  exists medicationRequest.dosageInstruction.route

/* 
Consistency 
DQI: Inadmissble categorical values
*/

define function "Status observed"(medicationRequest MedicationRequest):
  medicationRequest.status

define function "Inadmissible categorical values Status"(medicationRequest MedicationRequest):
  if medicationRequest.status in "Status" then
    null
  else
    medicationRequest.status


define function "Intention observed"(medicationRequest MedicationRequest):
  medicationRequest.intent

define function "Inadmissible categorical values Intention"(medicationRequest MedicationRequest):
  if medicationRequest.intent in "intent" then
    null
  else
    medicationRequest.intent

define function "Weg der Anwendung observed"(medicationRequest MedicationRequest):
  ToCodeableConcept(medicationRequest.dosageInstruction.route.coding.where(system='http://standardterms.edqm.eu'))

define function "Inadmissible categorical values dosageInstruction.route"(medicationRequest MedicationRequest):
  ToCodeableConcept(flatten((medicationRequest.dosageInstruction.route) R
    return Coalesce(NonMatching(R, route).coding, {} as List<Coding>)))
