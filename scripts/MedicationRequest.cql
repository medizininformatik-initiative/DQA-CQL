library "medicationrequest"
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

define function "Missing values MedicationRequest.meta"(MedicationRequest MedicationRequest): 
  MedicationRequest.meta is not null

define function "Missing values Status"(MedicationRequest MedicationRequest): 
  MedicationRequest.status is not null

define function "Missing values Intention"(MedicationRequest MedicationRequest): 
  MedicationRequest.intent is not null

define function "Missing values medicationReference"(MedicationRequest MedicationRequest): 
  if MedicationRequest.medication is Reference then
    (MedicationRequest.medication as Reference).reference is not null
  else
    false

define function "Missing values subject"(MedicationRequest MedicationRequest): 
  MedicationRequest.subject.reference is not null


define function "Missing values encounter"(MedicationRequest MedicationRequest): 
  MedicationRequest.encounter.reference is not null

define function "Missing values authoredOn"(MedicationRequest MedicationRequest): 
  MedicationRequest.authoredOn is not null

define function "Missing values dosageInstruction.timing"(MedicationRequest MedicationRequest): 
  MedicationRequest.dosageInstruction.timing is not null

define function "Missing values dosage.route"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.route is not null

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