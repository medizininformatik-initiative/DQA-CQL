library "MedicationStatement"
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

define function "Missing values MedicationStatement.meta.source"(MedicationStatement MedicationStatement): 
  MedicationStatement.meta.source is not null

define function "Missing values MedicationStatement.meta.profile"(MedicationStatement MedicationStatement): 
  MedicationStatement.meta.profile is not null

define function "Missing values MedicationStatement.identifier"(MedicationStatement MedicationStatement): 
  MedicationStatement.identifier is not null

define function "Missing values MedicationStatement.basedOn"(MedicationStatement MedicationStatement): 
  MedicationStatement.basedOn is not null

define function "Missing values MedicationStatement.partOf"(MedicationStatement MedicationStatement): 
  MedicationStatement.partOf is not null

define function "Missing values MedicationStatement.status"(MedicationStatement MedicationStatement): 
  MedicationStatement.status is not null

define function "Missing values MedicationStatement.category"(MedicationStatement MedicationStatement): 
  MedicationStatement.category is not null


define function "Missing values medication"(ms MedicationStatement):
  if ms.medication is Reference then
    (ms.medication as Reference).reference is not null
  else if ms.medication is CodeableConcept then
    ms.medication.coding.code is not null
  else
    false

define function "Missing values subject"(MedicationStatement MedicationStatement): 
  MedicationStatement.subject.reference is not null

define function "Missing values context"(MedicationStatement MedicationStatement): 
  MedicationStatement.context.reference is not null

define function "Effective type"(MedicationStatement MedicationStatement):
  case
    when MedicationStatement.effective is null then 'null'
    when MedicationStatement.effective is dateTime then 'dateTime'
    when MedicationStatement.effective is Period then 'Period'
    else 'unknown'
  end

define function "Missing values Effective"(MedicationStatement MedicationStatement): 
  MedicationStatement.effective is not null

define function "Missing values dateAsserted"(MedicationStatement MedicationStatement): 
  MedicationStatement.dateAsserted is not null

define function "Missing values informationSource"(MedicationStatement MedicationStatement): 
  MedicationStatement.informationSource is not null

define function "Missing values reasonCode"(MedicationStatement MedicationStatement): 
  MedicationStatement.reasonCode is not null

define function "Missing values reasonReference"(MedicationStatement MedicationStatement): 
  MedicationStatement.reasonReference is not null

define function "Missing values note"(MedicationStatement MedicationStatement): 
  MedicationStatement.note is not null

define function "Missing values dosage.sequence"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.sequence is not null

define function "Missing values dosage.text"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.text is not null

define function "Missing values dosage.timing.event"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.timing.event is not null

define function "Missing values dosage.timing.repeat"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.timing.repeat is not null

define function "Missing values dosage.timing.repeat"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.timing.repeat is not null

define function "Missing values dosage.asNeeded"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.asNeeded is not null

define function "Missing values dosage.site.coding.system"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.site.coding.system is not null

define function "Missing values dosage.site.coding.code"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.site.coding.code is not null

define function "Missing values dosage.route.coding.system"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.route.coding.system is not null

define function "Missing values dosage.route.coding.code"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.route.coding.code is not null



define function "Missing values dosage.doseAndRate.dose.value"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.dose.value is not null

define function "Missing values dosage.doseAndRate.dose.unit"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.dose.unit is not null

define function "Missing values dosage.doseAndRate.dose.system"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.dose.system is not null

define function "Missing values dosage.doseAndRate.dose.code"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.dose.code is not null

define function "Missing values dosage.doseAndRate.dose.low.value"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.dose.low.value is not null

define function "Missing values dosage.doseAndRate.dose.low.unit"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.dose.low.unit is not null

define function "Missing values dosage.doseAndRate.dose.low.system"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.dose.low.system is not null

define function "Missing values dosage.doseAndRate.dose.low.code"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.dose.low.code is not null

define function "Missing values dosage.doseAndRate.dose.high.value"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.dose.high.value is not null

define function "Missing values dosage.doseAndRate.dose.high.unit"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.dose.high.unit is not null

define function "Missing values dosage.doseAndRate.dose.high.system"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.dose.high.system is not null

define function "Missing values dosage.doseAndRate.dose.high.code"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.dose.high.code is not null





define function "Missing values dosage.doseAndRate.rate.numerator.value"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.rate.numerator.value is not null

define function "Missing values dosage.doseAndRate.rate.numerator.unit"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.rate.numerator.unit is not null


define function "Missing values dosage.doseAndRate.rate.numerator.system"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.rate.numerator.system is not null

define function "Missing values dosage.doseAndRate.rate.numerator.code"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.rate.numerator.code is not null

define function "Missing values dosage.doseAndRate.rate.denominator.value"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.rate.denominator.value is not null

define function "Missing values dosage.doseAndRate.rate.denominator.unit"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.rate.denominator.unit is not null

define function "Missing values dosage.doseAndRate.rate.denominator.system"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.rate.denominator.system is not null

define function "Missing values dosage.doseAndRate.rate.denominator.code"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.rate.denominator.code is not null




define function "Missing values dosage.doseAndRate.rate.low.value"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.rate.low.value is not null

define function "Missing values dosage.doseAndRate.rate.low.unit"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.rate.low.unit is not null

define function "Missing values dosage.doseAndRate.rate.low.system"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.rate.low.system is not null

define function "Missing values dosage.doseAndRate.rate.low.code"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.rate.low.code is not null

define function "Missing values dosage.doseAndRate.rate.high.value"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.rate.high.value is not null

define function "Missing values dosage.doseAndRate.rate.high.unit"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.rate.high.unit is not null

define function "Missing values dosage.doseAndRate.rate.high.system"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.rate.high.system is not null

define function "Missing values dosage.doseAndRate.rate.high.code"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.doseAndRate.rate.high.code is not null



define function "Missing values dosage.maxDosePerPeriod.numerator.value"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.maxDosePerPeriod.numerator.value is not null

define function "Missing values dosage.maxDosePerPeriod.numerator.unit"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.maxDosePerPeriod.numerator.unit is not null

define function "Missing values dosage.maxDosePerPeriod.numerator.system"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.maxDosePerPeriod.numerator.system is not null

define function "Missing values dosage.maxDosePerPeriod.numerator.code"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.maxDosePerPeriod.numerator.code is not null

define function "Missing values dosage.maxDosePerPeriod.denominator.value"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.maxDosePerPeriod.denominator.value is not null

define function "Missing values dosage.maxDosePerPeriod.denominator.unit"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.maxDosePerPeriod.denominator.unit is not null

define function "Missing values dosage.maxDosePerPeriod.denominator.system"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.maxDosePerPeriod.denominator.system is not null

define function "Missing values dosage.maxDosePerPeriod.denominator.code"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.maxDosePerPeriod.denominator.code is not null

define function "Missing values dosage.maxDosePerAdministration.value"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.maxDosePerAdministration.value is not null

define function "Missing values dosage.maxDosePerAdministration.unit"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.maxDosePerAdministration.unit is not null

define function "Missing values dosage.maxDosePerAdministration.system"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.maxDosePerAdministration.system is not null

define function "Missing values dosage.maxDosePerAdministration.code"(MedicationStatement MedicationStatement): 
  MedicationStatement.dosage.maxDosePerAdministration.code is not null

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
  (ms.effective.start > ms.effective.end) is true
