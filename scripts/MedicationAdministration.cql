library "MedicationAdministration"
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'

valueset Status:'http://hl7.org/fhir/ValueSet/medication-admin-status'
//valueset intent:'http://hl7.org/fhir/ValueSet/medicationrequest-intent'
valueset route:'http://hl7.org/fhir/uv/ips/ValueSet/medicine-route-of-administration'

context Patient

define InInitialPopulation:
  [MedicationAdministration]

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

define function "Missing values MedicationAdministration.id"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.id is not null

define function "Missing values MedicationAdministration.meta"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.meta is not null

define function "Missing values MedicationAdministration.status"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.status is not null

define function "Missing values MedicationAdministration.medicationReference"(MedicationAdministration MedicationAdministration): 
    if MedicationAdministration.medication is Reference then
    (MedicationAdministration.medication as Reference).reference is not null
    else
    false

define function "Missing values Subject"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.subject is not null

define function "Missing values Context"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.context is not null

define function "Missing values request"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.request is not null

// Verabreichungszeitpunkt

define function "Effective type"(MedicationAdministration MedicationAdministration):
  case
    when MedicationAdministration.effective is null then 'null'
    when MedicationAdministration.effective is dateTime then 'dateTime'
    when MedicationAdministration.effective is Period then 'Period'
    else 'unknown'
  end

define function "Missing values Effective"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.effective is not null


define function "Missing values dosage.route"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.dosage.route is not null


/* 
Consistency 
DQI: Inadmissible categorical values
*/

define function "Status observed"(MedicationAdministration MedicationAdministration):
  MedicationAdministration.status

define function "Inadmissible categorical values Status"(MedicationAdministration MedicationAdministration):
  if MedicationAdministration.status in "Status" then
    null
  else
    MedicationAdministration.status


define function "Weg der Anwendung observed"(MedicationAdministration MedicationAdministration):
  ToCodeableConcept(MedicationAdministration.dosage.route.coding.where(system='http://standardterms.edqm.eu'))

define function "Inadmissible categorical values dosage.route"(MedicationAdministration MedicationAdministration):
  NonMatching(MedicationAdministration.dosage.route ,route)

/* 
Contradictions
DQI: Logical Contradictions
*/
