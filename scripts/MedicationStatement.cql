library "medicationstatement"
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'

valueset status:'http://hl7.org/fhir/ValueSet/medication-statement-status'
valueset route:'http://hl7.org/fhir/uv/ips/ValueSet/medicine-route-of-administration'

context Patient

define InInitialPopulation:
  [MedicationStatement]

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

define function "Missing values MedicationStatement.id"(MedicationStatement MedicationStatement): 
  MedicationStatement.id is not null

define function "Missing values MedicationStatement.meta"(MedicationStatement MedicationStatement): 
  MedicationStatement.meta is not null

define function "Missing values MedicationStatement.basedOn"(MedicationStatement MedicationStatement): 
  MedicationStatement.basedOn is not null

define function "Missing values MedicationStatement.status"(MedicationStatement MedicationStatement): 
  MedicationStatement.status is not null

define function "Missing values medicationReference"(ms MedicationStatement):
  if ms.medication is Reference then
    (ms.medication as Reference).reference is not null
  else
    false

define function "Missing values subject"(MedicationStatement MedicationStatement): 
  MedicationStatement.subject.reference is not null

define function "Missing values context"(MedicationStatement MedicationStatement): 
  MedicationStatement.context.reference is not null

define function "Missing values dosage.route"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.route is not null

/* 
Consistency 
DQI: Inadmissble categorical values
*/

define function "Status observed"(ms MedicationStatement):
  ms.status

define function "Inadmissible categorical values Status"(ms MedicationStatement):
  if ms.status in "status" then
    null
  else
    ms.status

define function "Weg der Anwendung observed"(ms MedicationStatement):
  ToCodeableConcept(ms.dosage.route.coding.where(system='http://standardterms.edqm.eu'))

define function "Inadmissible categorical values dosage.route"(ms MedicationStatement):
  NonMatching(ms.dosage.route ,route)

/* 
Contradictions
DQI: Logical Contradictions
*/

// Einnahmedauer

define function "Einnahmedauer type"(ms MedicationStatement):
  case
    when ms.effective is null then 'null'
    when ms.effective is dateTime then 'dateTime'
    when ms.effective is Period then 'Period'
    else 'unknown'
  end

define function "Einnahmedauer Ende ist vor Einnahmedauer Start"(ms MedicationStatement):
  ms.effective.start > ms.effective.end
