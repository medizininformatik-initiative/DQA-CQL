# Import Test Data

## MII Test Data

Test data from https://github.com/medizininformatik-initiative/mii-testdata

The script downloads the bundles to a temporary directory and uploads them to
Blaze. Override the target server via the `BLAZE_SERVER` environment variable
(default: `http://localhost:8080/fhir`).

```sh
test-data/download-mii-test-data.sh
```

## POLAR Test Data

Test data from https://github.com/medizininformatik-initiative/kerndatensatz-testdaten

```sh
test-data/download-polar-test-data.sh
```

## Vorhofflimmern Test Data

Test data from https://github.com/medizininformatik-initiative/kerndatensatz-testdaten

```sh
test-data/download-vorhofflimmern-test-data.sh
```

## Generated Test Data

Synthetic MII KDS conformant FHIR transaction bundles (100 patients) generated locally via `test-data/generate-test-data.py`. The script generates into a temporary directory and uploads to Blaze.

```sh
test-data/generate-and-upload-test-data.sh
```

## Verify Uploads

```sh
blazectl --server http://localhost:8080/fhir count-resources
```

Should output similar numbers:

```text
Condition                         : 12402
Consent                           :  9797
Device                            :     3
DeviceMetric                      :     1
DiagnosticReport                  :   139
Encounter                         : 24294
List                              :    59
Medication                        :   331
MedicationAdministration          :   246
MedicationRequest                 :   133
MedicationStatement               :  1986
Observation                       : 18039
Organization                      :     3
Patient                           : 12147
Practitioner                      :     2
PractitionerRole                  :     1
Procedure                         :   139
ServiceRequest                    :   105
Specimen                          :   100
StructureDefinition               :   185
-----------------------------------------
total                             : 80112
```
