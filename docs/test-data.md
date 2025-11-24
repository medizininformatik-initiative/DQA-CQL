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
Condition                         : 12111
Consent                           :  9687
Encounter                         : 24078
Medication                        :   105
MedicationAdministration          :   119
MedicationStatement               :  1785
Observation                       : 16979
Patient                           : 12036
Procedure                         :    15
StructureDefinition               :   185
-----------------------------------------
total                             : 77100
```
