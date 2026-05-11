# MII KDS Test Data Generator — Design

## Goal

Generate synthetic, reproducible MII KDS conformant FHIR test data that exercises both
the happy path and the missing-value / inadmissible-categorical-value / contradiction
checks defined by the DQA CQL scripts under `scripts/`.

## Output

- Script: `test-data/generate-test-data.py` (Python 3, stdlib only).
- 100 transaction bundles at `test-data/generated/Bundle-pat-001.json` … `Bundle-pat-100.json`.
- Each bundle entry uses `request.method = PUT` with `request.url = "<ResourceType>/<id>"`.
- Resources have stable, deterministic `id` fields (`pat-001`, `enc-001-1`, …) and
  reference each other within the bundle as `<ResourceType>/<id>`.
- Reproducible via `random.seed(42)`.
- Upload via `blazectl --server http://localhost:8080/fhir upload test-data/generated`.

## Resources per patient

| Resource                 | Count | MII KDS profile (canonical, no version pin)                                                                           |
|--------------------------|-------|-----------------------------------------------------------------------------------------------------------------------|
| Patient                  | 1     | `https://www.medizininformatik-initiative.de/fhir/core/modul-person/StructureDefinition/Patient`                      |
| Encounter                | 1–3   | `https://www.medizininformatik-initiative.de/fhir/core/modul-fall/StructureDefinition/KontaktGesundheitseinrichtung`  |
| Condition                | 1–5   | `https://www.medizininformatik-initiative.de/fhir/core/modul-diagnose/StructureDefinition/Diagnose`                   |
| Procedure                | 0–2   | `https://www.medizininformatik-initiative.de/fhir/core/modul-prozedur/StructureDefinition/Procedure`                  |
| Observation (Lab)        | 5–15  | `https://www.medizininformatik-initiative.de/fhir/core/modul-labor/StructureDefinition/ObservationLab`                |
| Specimen                 | 0–2   | `https://www.medizininformatik-initiative.de/fhir/core/modul-biobank/StructureDefinition/Specimen`                    |
| DiagnosticReport Lab     | 0–2   | `https://www.medizininformatik-initiative.de/fhir/core/modul-labor/StructureDefinition/DiagnosticReportLab`           |
| DiagnosticReport Patho   | 0–1   | `https://www.medizininformatik-initiative.de/fhir/ext/modul-patho/StructureDefinition/mii-pr-patho-diagnostic-report` |
| ServiceRequest Lab       | 0–1   | `https://www.medizininformatik-initiative.de/fhir/core/modul-labor/StructureDefinition/ServiceRequestLab`             |
| ServiceRequest Patho     | 0–1   | `https://www.medizininformatik-initiative.de/fhir/ext/modul-patho/StructureDefinition/mii-pr-patho-service-request`   |
| Medication               | 1–3   | `https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/Medication`               |
| MedicationStatement      | 0–3   | `https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/MedicationStatement`      |
| MedicationRequest        | 0–2   | `https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/MedicationRequest`        |
| MedicationAdministration | 0–2   | `https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/MedicationAdministration` |
| List (Medikationsliste)  | 0–1   | `https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/Medikationsliste`         |
| Consent                  | 1     | `https://www.medizininformatik-initiative.de/fhir/modul-consent/StructureDefinition/mii-pr-consent-einwilligung`      |

## Data variability

- **~85%** of resources are fully conformant.
- **~10%** have a single missing field (e.g. `meta.profile`, `recordedDate`,
  `verificationStatus`, `period.end`, `Aufnahmegrund` extension, pseudonym
  identifier, `dosage.route`, `interpretation`).
- **~5%** have a single invalid categorical value (e.g. ICD-10-GM `XYZ99`,
  gender `xx`, encounter status `bogus`, OPS `99-99-99`, LOINC `not-real-loinc`,
  list status `garbage`).
- A handful of patients have inverted periods (`end < start`) to trigger
  contradiction checks.

## Sample value pools

- ICD-10-GM (~30 codes): `I10`, `E11.9`, `J45.9`, `C50.9`, `K29.7`, …
- OPS (~15 codes): `5-470`, `8-800`, `1-440`, …
- LOINC (~20): `2160-0`, `718-7`, `4548-4`, `2345-7`, `2885-2`, …
- SNOMED body site (~10): `49521004`, `80581009`, …
- DKGEV Aufnahmegrund / Entlassgrund / Fachabteilung from the linked German base profiles.
- EDQM routes: `20053000` (oral), `20066000` (intravenous), …

## Out of scope

- Full code-system completeness (the pools are illustrative, not exhaustive).
- Realistic clinical co-occurrence (ICD/OPS combinations are random).
- Validation against StructureDefinitions — Blaze upload + DQA reports are the
  primary acceptance signal.
