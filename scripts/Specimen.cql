library "Specimen"
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'

codesystem "v2-0203": 'http://terminology.hl7.org/CodeSystem/v2-0203'
valueset status: 'http://hl7.org/fhir/ValueSet/specimen-status'
codesystem SNOMED: 'http://snomed.info/sct'

context Patient

define "InInitialPopulation":
    [Specimen] 
        
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
  if concept is null then
    null
  else if FHIRHelpers.ToConcept(concept) in codesystem then
    null
  else
    concept


/* 
Completeness
DQI: Missing values
*/

define function "Missing values Specimen ID"(Specimen Specimen):
    exists(Specimen.id)

define function "Missing values Specimen meta.lastUpdated"(Specimen Specimen):
    exists(Specimen.meta.lastUpdated)

define function "Missing values Specimen meta.profile"(Specimen Specimen):
    exists(Specimen.meta.profile)

define function "Missing values Specimen Text"(Specimen Specimen):
    exists(Specimen.text)

define function "Missing values identifier"(Specimen Specimen):
    exists(Specimen.identifier)

define function "Missing values identifier Placer-ID"(Specimen Specimen):
    exists(Specimen.identifier.where(system='https://mul-ct.de/fhir/sid/specimen-identifier'))

define function "Missing values Labor-ID"(Specimen Specimen):
    exists(Specimen.accessionIdentifier)

define function "Missing values Status"(Specimen Specimen):
    exists(Specimen.status)

define function "Missing values Materialart"(Specimen Specimen):
    exists(Specimen.type)

define function "Missing values subject"(Specimen Specimen):
    exists(Specimen.subject)

define function "Missing values parent"(Specimen Specimen):
    exists(Specimen.parent)

define function "Missing values request"(Specimen Specimen):
    exists(Specimen.request)



define function "Missing values Collection time"(Specimen Specimen):
  Specimen.collection.collected is not null

define function "Missing values Entnahmemethode"(Specimen Specimen):
  Specimen.collection.method is not null

define function "Missing values collection.bodySite"(Specimen Specimen):
  Specimen.collection.bodySite is not null

define function "Missing values collection.fastingStatus"(Specimen Specimen):
  Specimen.collection.fastingStatus is not null

define function "Missing values Processing"(Specimen Specimen):
    Specimen.processing is not null

define function "Missing values Probenbehälter"(Specimen Specimen):
    Specimen.container.type.coding.where(system='http://snomed.info/sct') is not null

define function "Missing values container.capacity"(Specimen Specimen):
    Specimen.container.capacity is not null

define function "Missing values container.specimenQuantity"(Specimen Specimen):
    Specimen.container.specimenQuantity is not null

define function "Missing values note"(Specimen Specimen):
    Specimen.note is not null

/* 
Consistency 
DQI: Inadmissble categorical values
*/

//identifier Filler-ID
define function "identifier Filler-ID observed"(Specimen Specimen):
  ToCodeableConcept(Specimen.identifier.type.coding.where(system='http://terminology.hl7.org/CodeSystem/v2-0203'))
  
define function "Inadmissible categorical values identifier Filler-ID"(Specimen Specimen):
  NonMatchingCS("identifier Filler-ID observed"(Specimen) ,"v2-0203")

// Status
define function "Status observed"(Specimen Specimen):
  Specimen.status
  
define function "Inadmissible categorical values Status"(Specimen Specimen):
    if Specimen.status in status then
    null
  else
    Specimen.status

// type (Kind of material that forms the specimen)

define function "Materialart observed"(Specimen Specimen):
  ToCodeableConcept(
    Specimen.type.coding c 
    where c.system = 'http://snomed.info/sct' 
      and c.code is not null 
      and c.code != ''
  )

define function "Inadmissible categorical values Materialart"(Specimen Specimen):
  NonMatchingCS("Materialart observed"(Specimen) ,SNOMED)

// Entnahmemethode
define function "Entnahmemethode observed"(Specimen Specimen):
  ToCodeableConcept(Specimen.collection.method.coding c
  where c.system='http://snomed.info/sct'
     and c.code is not null 
      and c.code != ''
  )

  define function "Inadmissible categorical values Entnahmemethode"(Specimen Specimen):
  NonMatchingCS("Entnahmemethode observed"(Specimen) , SNOMED)



// Probenbehälter
define function "Probenbehälter observed"(Specimen Specimen):
  ToCodeableConcept(Specimen.container.type.coding.where(system='http://snomed.info/sct'))

  define function "Inadmissible categorical values Probenbehälter"(Specimen Specimen):
  NonMatchingCS("Probenbehälter observed"(Specimen), SNOMED)

