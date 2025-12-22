# Import Test Data

## MII Test Data

Test data from https://github.com/medizininformatik-initiative/mii-testdata 

```sh
test-data/download-mii-test-data.sh
blazectl --server http://localhost:8080/fhir upload <temp-dir>
```

## POLAR Test Data

Tes data from https://github.com/medizininformatik-initiative/kerndatensatz-testdaten

```sh
test-data/download-polar-test-data.sh
blazectl --server http://localhost:8080/fhir upload <temp-dir>
```

## Vorhofflimmern Test Data

Tes data from https://github.com/medizininformatik-initiative/kerndatensatz-testdaten

```sh
test-data/download-vorhofflimmern-test-data.sh
blazectl --server http://localhost:8080/fhir upload <temp-dir>
```

## Verify Uploads

```sh
blazectl --server http://localhost:8080/fhir count-resources
```

Should output similar numbers:

```text
BodyStructure                     :     1
CarePlan                          :     1
Composition                       :     1
Condition                         : 12125
Consent                           :  9697
Device                            :    33
DeviceMetric                      :    10
DiagnosticReport                  :    13
Encounter                         : 24089
FamilyMemberHistory               :     2
ImagingStudy                      :     1
Library                           :    14
List                              :    17
Measure                           :    14
Medication                        :   132
MedicationAdministration          :   143
MedicationRequest                 :    26
MedicationStatement               :  1813
Observation                       : 17051
Organization                      :    30
Patient                           : 12047
Practitioner                      :    12
PractitionerRole                  :    10
Procedure                         :    40
ServiceRequest                    :    13
Specimen                          :    21
StructureDefinition               :   185
Substance                         :     1
Task                              :     2
-----------------------------------------
total                             : 77544
```
