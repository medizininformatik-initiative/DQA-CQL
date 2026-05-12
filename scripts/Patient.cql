library "Patient"
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'

valueset "Gender": 'http://hl7.org/fhir/ValueSet/administrative-gender'
valueset "Country": 'http://terminology.hl7.org/ValueSet/v3-Country2'
valueset "identifier": 'http://fhir.de/ValueSet/identifier-type-de-basis'
codesystem "ObservationValue": 'http://terminology.hl7.org/CodeSystem/v3-ObservationValue'

context Patient

define InInitialPopulation:
  true

// Helper Functions
define function NonMatchingString(s System.String, valueset System.ValueSet):
  if s in valueset then
    null
  else
    s


/* 
Completeness 
DQI: Missing values
*/
  
define "Missing values Patient.id":
  exists(Patient.id)

define "Missing values Patient.meta.profile":
  exists(Patient.meta.profile)

define "Missing values Patient.identifier":
  exists (Patient.identifier)

define "Missing values Patient.active":
  exists (Patient.active)

define "Missing values Patient.gender":
  exists(Patient.gender)

define "Missing values Patient.birthDate":
  exists(Patient.birthDate)

define "Missing values Patient.address.type":
  exists(Patient.address.type)

define "Missing values Patient.address.postalCode":
  exists(Patient.address.postalCode)

define "Missing values Patient.address.country":
  exists(Patient.address.country)



/* Consistency
DQI: Inadmissible categorical values
*/

define "Inadmissible categorical values Patient.gender":
  not(Patient.gender in "Gender")

define "Inadmissible categorical values Patient.address.country":
  NonMatchingString(Patient.address.country, Country)


