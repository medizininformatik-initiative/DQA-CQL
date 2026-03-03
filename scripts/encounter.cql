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
valueset Kontaktart: 'http://fhir.de/ValueSet/kontaktart-de'
valueset Fachabteilung: 'http://fhir.de/ValueSet/dkgev/Fachabteilungsschluessel'
valueset Fachabteilung_erweitert: 'http://fhir.de/ValueSet/dkgev/Fachabteilungsschluessel-erweitert'
valueset Diagnosetyp: 'http://fhir.de/ValueSet/DiagnoseTyp'
valueset Diagnosesubtyp: 'http://fhir.de/ValueSet/Diagnosesubtyp'
valueset Aufnahmeanlass: 'http://fhir.de/ValueSet/dgkev/Aufnahmeanlass'
valueset Entlassungsgrund_ErsteUndZweiteStelle: 'http://fhir.de/ValueSet/dkgev/EntlassungsgrundErsteUndZweiteStelle'
valueset Entlassungsgrund_DritteStelle: 'http://fhir.de/ValueSet/dkgev/EntlassungsgrundDritteStelle'

context Patient

define InInitialPopulation:
  [Encounter]


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

define function "Missing values Encounter.id" (encounter Encounter): 
  encounter.id is not null
  
define function "Missing values Encounter.meta.profile"(encounter Encounter): 
  exists(encounter.meta.profile)

// Aufnahmegrund ErsteUndZweiteStelle
define function "Missing values Encounter.Aufnahmegrund.ErsteUndZweiteStelle.code"(encounter Encounter):
  exists(
    encounter.extension
      .where(url = 'http://fhir.de/StructureDefinition/Aufnahmegrund')
      .extension
      .where(url = 'ErsteUndZweiteStelle')
      .value.code 
  )

define function "Missing values Encounter.Aufnahmegrund.ErsteUndZweiteStelle.display"(encounter Encounter):
  exists(
    encounter.extension
      .where(url = 'http://fhir.de/StructureDefinition/Aufnahmegrund')
      .extension
      .where(url = 'ErsteUndZweiteStelle')
      .value.display 
  )

// Aufnahmegrund DritteStelle
define function "Missing values Encounter.Aufnahmegrund.DritteStelle.code"(encounter Encounter):
  exists(
    encounter.extension
     .where(url = 'http://fhir.de/StructureDefinition/Aufnahmegrund')
     .extension
     .where(url = 'DritteStelle')
     .value.code
  )

  define function "Missing values Encounter.Aufnahmegrund.DritteStelle.display"(encounter Encounter):
  exists(
    encounter.extension
     .where(url = 'http://fhir.de/StructureDefinition/Aufnahmegrund')
     .extension
     .where(url = 'DritteStelle')
     .value.display
  )

// Aufnahmegrund VierteStelle
define function "Missing values Encounter.Aufnahmegrund.VierteStelle.code"(encounter Encounter):
  exists(
    encounter.extension
     .where(url = 'http://fhir.de/StructureDefinition/Aufnahmegrund')
     .extension
     .where(url = 'VierteStelle')
     .value.code
  )

  define function "Missing values Encounter.Aufnahmegrund.VierteStelle.display"(encounter Encounter):
  exists(
    encounter.extension
     .where(url = 'http://fhir.de/StructureDefinition/Aufnahmegrund')
     .extension
     .where(url = 'VierteStelle')
     .value.display
  )

define function "Missing values Aufnahmenummer"(encounter Encounter):
  exists (encounter.identifier.where(type ~ "Visit number").value)

define function "Missing values Encounter.status"(encounter Encounter):
  encounter.status is not null

// Kontaktklasse
define function "Missing values Encounter.class.code"(encounter Encounter):
  encounter.class.code is not null

define function "Missing values Encounter.class.display"(encounter Encounter):
  encounter.class.display is not null

// Kontaktebene
define function "Missing values Kontaktebene.code"(encounter Encounter):
  exists(encounter.type.coding.where(system='http://fhir.de/CodeSystem/Kontaktebene').code) 

define function "Missing values Kontaktebene.display"(encounter Encounter):
  exists(encounter.type.coding.where(system='http://fhir.de/CodeSystem/Kontaktebene').display) 

// Kontaktart
define function "Missing values Kontaktart.code"(encounter Encounter):
  exists(encounter.type.coding.where(system='http://fhir.de/CodeSystem/kontaktart-de').code) 

// Fachabteilung
define function "Missing values Fachabteilung.code"(encounter Encounter):
  exists(encounter.serviceType.coding.where(system='http://fhir.de/CodeSystem/dkgev/Fachabteilungsschluessel').code) 

define function "Missing values Fachabteilung.display"(encounter Encounter):
  exists(encounter.serviceType.coding.where(system='http://fhir.de/CodeSystem/dkgev/Fachabteilungsschluessel').display) 

// Fachabteilung erweitert
define function "Missing values Fachabteilung_erweitert.code"(encounter Encounter):
  exists(encounter.serviceType.coding.where(system='http://fhir.de/CodeSystem/dkgev/Fachabteilungsschluessel-erweitert').code) 

define function "Missing values Fachabteilung_erweitert.display"(encounter Encounter):
  exists(encounter.serviceType.coding.where(system='http://fhir.de/CodeSystem/dkgev/Fachabteilungsschluessel-erweitert').display) 

define function "Missing values subject"(encounter Encounter):
  encounter.subject.reference is not null 

define function "Missing values period.start"(encounter Encounter):
  encounter.period.start is not null

define function "Missing values period.end"(encounter Encounter):
  encounter.period.end is not null

// diagnosis
define function "Missing values diagnosis.condition"(encounter Encounter):
  encounter.diagnosis.condition is not null

define function "Missing values Diagnosetyp.code"(encounter Encounter):
  exists(encounter.diagnosis.use.coding.where(system='http://fhir.de/CodeSystem/KontaktDiagnoseProzedur').code) 


define function "Missing values Diagnosetyp.display"(encounter Encounter):
  exists(encounter.diagnosis.use.coding.where(system='http://fhir.de/CodeSystem/KontaktDiagnoseProzedur').display) 


define function "Missing values Diagnosesubtyp.code"(encounter Encounter):
  exists(encounter.diagnosis.use.coding.where(system='http://terminology.hl7.org/CodeSystem/diagnosis-role').code)

define function "Missing values Diagnosesubtyp.display"(encounter Encounter):
  exists(encounter.diagnosis.use.coding.where(system='http://terminology.hl7.org/CodeSystem/diagnosis-role').display)

// hospitalization
define function "Missing values Aufnahmeanlass"(encounter Encounter):
 exists(encounter.hospitalization.admitSource.coding)

define function "Missing values Entlassgrund"(encounter Encounter):
 exists(encounter.hospitalization.dischargeDisposition)

//partOf
define function "Missing values partOf"(encounter Encounter):
  encounter.partOf.reference is not null 

/* Consistency
DQI: Inadmissble categorical values
*/

define function Aufnahmegrund(encounter Encounter):
  encounter.extension.where(url = 'http://fhir.de/StructureDefinition/Aufnahmegrund')

define function "Inadmissible categorical values Encounter.Aufnahmegrund.ErsteUndZweiteStelle"(encounter Encounter):
  NonMatching(Aufnahmegrund(encounter).extension.where(url = 'ErsteUndZweiteStelle').value, AufnahmegrundErsteUndZweiteStelle)

define function "Inadmissible categorical values Encounter.status"(encounter Encounter):
  not (encounter.status in Status)

// Kontaktklasse 
define function "Kontaktklasse observed"(encounter Encounter):
  if encounter.class is null then
    null
  else
    ToCodeableConcept({encounter.class})

define function "Inadmissible categorical values Encounter.class"(encounter Encounter):
  NonMatching("Kontaktklasse observed"(encounter), Kontaktklasse)

// Kontaktebene 
define function "Kontaktebene observed"(encounter Encounter):
  if encounter.type.coding.where(system='http://fhir.de/CodeSystem/Kontaktebene') is null then
    null
  else
    ToCodeableConcept(encounter.type.coding.where(system='http://fhir.de/CodeSystem/Kontaktebene'))

define function "Inadmissible categorical values Kontaktebene"(encounter Encounter):
  NonMatching("Kontaktebene observed"(encounter), Kontaktebene)

//Kontaktart
define function "Kontaktart observed"(encounter Encounter):
  if encounter.type.coding.where(system='http://fhir.de/CodeSystem/kontaktart-de') is null then
    null
  else
    ToCodeableConcept(encounter.type.coding.where(system='http://fhir.de/CodeSystem/kontaktart-de'))

define function "Inadmissible categorical values Kontaktart"(encounter Encounter):
  NonMatching("Kontaktart observed"(encounter), Kontaktart)

//Fachabteilung
define function "Fachabteilung observed"(encounter Encounter):
  if encounter.serviceType.coding.where(system='http://fhir.de/CodeSystem/dkgev/Fachabteilungsschluessel') is null then
    null
  else
    ToCodeableConcept(encounter.serviceType.coding.where(system='http://fhir.de/CodeSystem/dkgev/Fachabteilungsschluessel'))

define function "Inadmissible categorical values Fachabteilung"(encounter Encounter):
  NonMatching("Fachabteilung observed"(encounter), Fachabteilung)

//Fachabteilung_erweitert
define function "Fachabteilung_erweitert observed"(encounter Encounter):
  if encounter.serviceType.coding.where(system='http://fhir.de/CodeSystem/dkgev/Fachabteilungsschluessel-erweitert') is null then
    null
  else
    ToCodeableConcept(encounter.serviceType.coding.where(system='http://fhir.de/CodeSystem/dkgev/Fachabteilungsschluessel-erweitert'))

define function "Inadmissible categorical values Fachabteilung_erweitert"(encounter Encounter):
  NonMatching("Fachabteilung_erweitert observed"(encounter), Fachabteilung_erweitert)


//Hospitalization

define function "Aufnahmeanlass observed"(encounter Encounter):
  if encounter.hospitalization.admitSource is null then 
    null
  else 
    ToCodeableConcept(encounter.hospitalization.admitSource.coding.where(system='http://fhir.de/CodeSystem/dgkev/Aufnahmeanlass'))

define function "Inadmissible categorical values Aufnahmeanlass"(encounter Encounter):
  NonMatching("Aufnahmeanlass observed"(encounter), Aufnahmeanlass)

//Entlassgrund
define function Entlassgrund(encounter Encounter):
  encounter.hospitalization.dischargeDisposition.extension.where(url='http://fhir.de/StructureDefinition/Entlassungsgrund')

define function "Entlassgrund ErsteUndZweiteStelle observed"(encounter Encounter):
  if Entlassgrund(encounter).extension.where(url = 'ErsteUndZweiteStelle').value is null then 
    null
  else
    ToCodeableConcept(Entlassgrund(encounter).extension.where(url = 'ErsteUndZweiteStelle').value)

define function "Inadmissible categorical values Entlassgrund ErsteUndZweiteStelle"(encounter Encounter):
  NonMatching("Entlassgrund ErsteUndZweiteStelle observed"(encounter), Entlassungsgrund_ErsteUndZweiteStelle)

define function "Entlassgrund DritteStelle observed"(encounter Encounter):
  if Entlassgrund(encounter).extension.where(url = 'DritteStelle').value is null then
    null
  else
    ToCodeableConcept(Entlassgrund(encounter).extension.where(url='DritteStelle').value)

define function "Inadmissible categorical values Entlassgrund DritteStelle"(encounter Encounter):
  NonMatching("Entlassgrund DritteStelle observed"(encounter), Entlassungsgrund_DritteStelle)


// Contradictions
define function "Contradiction"(encounter Encounter):
  if exists(encounter.class.display) and exists(encounter.class.code)
     and encounter.class.code = 'AMB'
     and not (exists(encounter.class.display) and encounter.class.display = 'ambulatory')
  then { code: encounter.class.code, display: encounter.class.display }
  else null //null --> No Contradictions
 
define function "Entlassdatum vor Aufnahmedatum"(encounter Encounter):
  if encounter.period.start is not null
     and encounter.period.end is not null
     and encounter.period.start > encounter.period.end
  then true
  else false




