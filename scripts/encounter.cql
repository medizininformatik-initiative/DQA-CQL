library "encounter"
using FHIR version '4.0.0'
include FHIRHelpers version '4.0.0'

codesystem "v2-0203": 'http://terminology.hl7.org/CodeSystem/v2-0203'
code "Visit number": 'VN' from "v2-0203"

valueset AufnahmegrundErsteUndZweiteStelle: 'http://fhir.de/ValueSet/dkgev/AufnahmegrundErsteUndZweiteStelle'
valueset AufnahmegrundDritteStelle: 'http://fhir.de/ValueSet/dkgev/AufnahmegrundDritteStelle'
valueset AufnahmegrundVierteStelle: 'http://fhir.de/ValueSet/dkgev/AufnahmegrundVierteStelle'
valueset Kontaktklasse: 'http://fhir.de/ValueSet/EncounterClassDE'
valueset Status: 'http://fhir.de/ValueSet/EncounterStatusDe'
valueset Kontaktebene: 'http://fhir.de/ValueSet/kontaktebene-de'

context Patient

define InInitialPopulation:
  [Encounter]

define function ToCodeableConcept(codings List<Coding>):
  if exists codings then
    CodeableConcept {
      coding: codings
    }
  else
    null

define function NonMatching(concept CodeableConcept, valueset System.ValueSet):
  if FHIRHelpers.ToConcept(concept) in valueset then
    null
  else
    concept

// Aufnahmegrund
define function Aufnahmegrund(encounter Encounter):
  encounter.extension.where(url = 'http://fhir.de/StructureDefinition/Aufnahmegrund')

define function "Aufnahmegrund ErsteUndZweiteStelle observed"(encounter Encounter):
  ToCodeableConcept(Aufnahmegrund(encounter).extension.where(url = 'ErsteUndZweiteStelle').value)

define function "Aufnahmegrund DritteStelle observed"(encounter Encounter):
  ToCodeableConcept(Aufnahmegrund(encounter).extension.where(url = 'DritteStelle').value)

define function "Aufnahmegrund VierteStelle observed"(encounter Encounter):
  ToCodeableConcept(Aufnahmegrund(encounter).extension.where(url = 'VierteStelle').value)

// Aufnahmenummer
define function "Aufnahmenummer missing"(encounter Encounter):
  not exists encounter.identifier.where(type ~ "Visit number").value

define function "Aufnahmenummer System observed"(encounter Encounter):
  encounter.identifier.where(type ~ "Visit number").system.first()

// Status
define function "Status observed"(encounter Encounter):
  encounter.status

define function "Status non-matching"(encounter Encounter):
  if encounter.status in Status then
     null
  else
     encounter.status

// Kontaktklasse
define function "Kontaktklasse observed"(encounter Encounter):
  if encounter.class is null then
    null
  else
    ToCodeableConcept({encounter.class})

define function "Kontaktklasse non-matching"(encounter Encounter):
  NonMatching("Kontaktklasse observed"(encounter), Kontaktklasse)

// Kontaktebene
define function "Kontaktebene observed"(encounter Encounter):
  ToCodeableConcept(encounter.type.coding.where(system = 'http://fhir.de/CodeSystem/Kontaktebene'))

define function "Kontaktebene non-matching"(encounter Encounter):
  NonMatching("Kontaktebene observed"(encounter), Kontaktebene)

// Patient
define function "Patient missing"(encounter Encounter):
  encounter.subject.reference is null

// Parent Encounter
define function "Parent Encounter missing"(encounter Encounter):
  encounter.partOf.reference is null
