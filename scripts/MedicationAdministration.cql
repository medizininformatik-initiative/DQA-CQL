library "MedicationAdministration"
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'

valueset Status:'http://hl7.org/fhir/ValueSet/medication-admin-status'
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

define function "Missing values MedicationAdministration.meta.source"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.meta.source is not null

define function "Missing values MedicationAdministration.meta.profile"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.meta.profile is not null

define function "Missing values MedicationAdministration.identifier"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.identifier is not null

define function "Missing values partOf"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.identifier is not null

define function "Missing values MedicationAdministration.status"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.status is not null

define function "Missing values MedicationAdministration.category"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.category is not null

define function "Missing values MedicationAdministration.medication"(MedicationAdministration MedicationAdministration): 
  if MedicationAdministration.medication is Reference then
    (MedicationAdministration.medication as Reference).reference is not null
  else if MedicationAdministration.medication is CodeableConcept then
    (MedicationAdministration.medication as CodeableConcept).coding is not null
  else    
    false

define function "Missing values Subject"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.subject is not null

define function "Missing values Context"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.context is not null

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

define function "Missing values performer"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.performer is not null

define function "Missing values reasonCode"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.reasonCode is not null

define function "Missing values reasonReference"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.reasonReference is not null

define function "Missing values request"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.request is not null

define function "Missing values note"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.note is not null

define function "Missing values dosage.text"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.dosage.text is not null

define function "Missing values dosage.site"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.dosage.site is not null

define function "Missing values dosage.route"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.dosage.route is not null

define function "Missing values dosage.dose.value"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.dosage.dose.value is not null

define function "Missing values dosage.dose.unit"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.dosage.dose.unit is not null

define function "Missing values dosage.dose.system"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.dosage.dose.system is not null

define function "Missing values dosage.dose.code"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.dosage.dose.code is not null

define function "Missing values dosage.rate"(MedicationAdministration MedicationAdministration): 
  MedicationAdministration.dosage.rate is not null

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

