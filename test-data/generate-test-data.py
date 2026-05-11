#!/usr/bin/env python3
"""Generate MII KDS conformant FHIR transaction bundles (1 per patient).

Produces 100 bundles in the directory passed as the first CLI argument
(default: test-data/generated/). Each bundle entry uses PUT.
Reproducible via random.seed(42).
"""
from __future__ import annotations

import json
import random
import sys
from datetime import date, datetime, timedelta
from pathlib import Path

# ---------------------------------------------------------------------------
# Profile canonicals
# ---------------------------------------------------------------------------
P_PATIENT = "https://www.medizininformatik-initiative.de/fhir/core/modul-person/StructureDefinition/Patient"
P_ENCOUNTER = "https://www.medizininformatik-initiative.de/fhir/core/modul-fall/StructureDefinition/KontaktGesundheitseinrichtung"
P_CONDITION = "https://www.medizininformatik-initiative.de/fhir/core/modul-diagnose/StructureDefinition/Diagnose"
P_PROCEDURE = "https://www.medizininformatik-initiative.de/fhir/core/modul-prozedur/StructureDefinition/Procedure"
P_OBS_LAB = "https://www.medizininformatik-initiative.de/fhir/core/modul-labor/StructureDefinition/ObservationLab"
P_SPECIMEN = "https://www.medizininformatik-initiative.de/fhir/core/modul-biobank/StructureDefinition/Specimen"
P_DR_LAB = "https://www.medizininformatik-initiative.de/fhir/core/modul-labor/StructureDefinition/DiagnosticReportLab"
P_DR_PATHO = "https://www.medizininformatik-initiative.de/fhir/ext/modul-patho/StructureDefinition/mii-pr-patho-diagnostic-report"
P_SR_LAB = "https://www.medizininformatik-initiative.de/fhir/core/modul-labor/StructureDefinition/ServiceRequestLab"
P_SR_PATHO = "https://www.medizininformatik-initiative.de/fhir/ext/modul-patho/StructureDefinition/mii-pr-patho-service-request"
P_MEDICATION = "https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/Medication"
P_MED_STATEMENT = "https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/MedicationStatement"
P_MED_REQUEST = "https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/MedicationRequest"
P_MED_ADMIN = "https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/MedicationAdministration"
P_MED_LIST = "https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/Medikationsliste"
P_CONSENT = "https://www.medizininformatik-initiative.de/fhir/modul-consent/StructureDefinition/mii-pr-consent-einwilligung"

# ---------------------------------------------------------------------------
# Code system / value pools
# ---------------------------------------------------------------------------
ICD10 = [
    ("I10", "Essentielle (primäre) Hypertonie"),
    ("E11.9", "Diabetes mellitus, Typ 2, ohne Komplikationen"),
    ("J45.9", "Asthma, nicht näher bezeichnet"),
    ("C50.9", "Bösartige Neubildung der Brustdrüse"),
    ("K29.7", "Gastritis, nicht näher bezeichnet"),
    ("M54.5", "Kreuzschmerz"),
    ("N39.0", "Harnwegsinfektion, Lokalisation nicht näher bezeichnet"),
    ("F32.9", "Depressive Episode, nicht näher bezeichnet"),
    ("J18.9", "Pneumonie, nicht näher bezeichnet"),
    ("I25.1", "Atherosklerotische Herzkrankheit"),
    ("E66.9", "Adipositas, nicht näher bezeichnet"),
    ("R51", "Kopfschmerz"),
    ("K57.30", "Divertikulose des Dickdarms"),
    ("I48.0", "Vorhofflimmern, paroxysmal"),
    ("G40.9", "Epilepsie, nicht näher bezeichnet"),
    ("C34.9", "Bösartige Neubildung Bronchus/Lunge"),
    ("I50.9", "Herzinsuffizienz, nicht näher bezeichnet"),
    ("J44.99", "Chronisch obstruktive Lungenkrankheit"),
    ("M17.1", "Sonstige primäre Gonarthrose"),
    ("S72.0", "Schenkelhalsfraktur"),
    ("K80.20", "Gallenblasenstein ohne Cholezystitis"),
    ("L40.0", "Psoriasis vulgaris"),
    ("E03.9", "Hypothyreose, nicht näher bezeichnet"),
    ("R10.4", "Sonstige und nicht näher bezeichnete Bauchschmerzen"),
    ("Z00.00", "Allgemeine ärztliche Untersuchung"),
    ("D50.9", "Eisenmangelanämie, nicht näher bezeichnet"),
    ("H40.1", "Primäres Offenwinkelglaukom"),
    ("N18.3", "Chronische Nierenkrankheit, Stadium 3"),
    ("F41.1", "Generalisierte Angststörung"),
    ("B34.9", "Virusinfektion, nicht näher bezeichnet"),
]

OPS = [
    ("5-470", "Appendektomie"),
    ("5-820.0", "Endoprothetischer Hüftgelenksersatz"),
    ("8-800", "Transfusion von Vollblut, Erythrozytenkonzentrat"),
    ("1-440", "Diagnostische Endoskopie des oberen Verdauungstraktes"),
    ("5-511", "Cholezystektomie"),
    ("5-787", "Osteosyntheseverfahren"),
    ("8-930", "Monitoring von Atmung, Herz und Kreislauf"),
    ("3-200", "Native Computertomographie des Schädels"),
    ("3-820", "Magnetresonanztomographie der Wirbelsäule"),
    ("8-560", "Lichttherapie"),
    ("9-200", "Hochaufwendige Pflege von Erwachsenen"),
    ("5-399", "Andere Operationen an Blutgefäßen"),
    ("1-632", "Diagnostische Ösophagogastroduodenoskopie"),
    ("8-831", "Legen und Wechsel eines Katheters"),
    ("5-032", "Zugang zur Lendenwirbelsäule"),
]

LOINC = [
    ("718-7", "Hemoglobin [Mass/volume] in Blood", "g/dL", "g/dL", 12.0, 17.0),
    ("4548-4", "Hemoglobin A1c/Hemoglobin.total in Blood", "%", "%", 4.0, 6.0),
    ("2345-7", "Glucose [Mass/volume] in Serum or Plasma", "mg/dL", "mg/dL", 70.0, 110.0),
    ("2160-0", "Creatinine [Mass/volume] in Serum or Plasma", "mg/dL", "mg/dL", 0.6, 1.3),
    ("2885-2", "Protein [Mass/volume] in Serum or Plasma", "g/dL", "g/dL", 6.0, 8.3),
    ("1742-6", "Alanine aminotransferase [Enzymatic activity/volume] in Serum or Plasma", "U/L", "U/L", 7.0, 56.0),
    ("1920-8", "Aspartate aminotransferase [Enzymatic activity/volume] in Serum or Plasma", "U/L", "U/L", 10.0, 40.0),
    ("2951-2", "Sodium [Moles/volume] in Serum or Plasma", "mmol/L", "mmol/L", 135.0, 145.0),
    ("2823-3", "Potassium [Moles/volume] in Serum or Plasma", "mmol/L", "mmol/L", 3.5, 5.1),
    ("17861-6", "Calcium [Mass/volume] in Serum or Plasma", "mg/dL", "mg/dL", 8.5, 10.5),
    ("3094-0", "Urea nitrogen [Mass/volume] in Serum or Plasma", "mg/dL", "mg/dL", 7.0, 20.0),
    ("1751-7", "Albumin [Mass/volume] in Serum or Plasma", "g/dL", "g/dL", 3.5, 5.0),
    ("6690-2", "Leukocytes [#/volume] in Blood", "10*3/uL", "10*3/uL", 4.0, 10.0),
    ("777-3", "Platelets [#/volume] in Blood", "10*3/uL", "10*3/uL", 150.0, 400.0),
    ("789-8", "Erythrocytes [#/volume] in Blood", "10*6/uL", "10*6/uL", 4.2, 5.9),
    ("1988-5", "C reactive protein [Mass/volume] in Serum or Plasma", "mg/L", "mg/L", 0.0, 5.0),
    ("2093-3", "Cholesterol [Mass/volume] in Serum or Plasma", "mg/dL", "mg/dL", 100.0, 200.0),
    ("2571-8", "Triglyceride [Mass/volume] in Serum or Plasma", "mg/dL", "mg/dL", 50.0, 150.0),
    ("4544-3", "Hematocrit [Volume Fraction] of Blood", "%", "%", 36.0, 50.0),
    ("3084-1", "Urate [Mass/volume] in Serum or Plasma", "mg/dL", "mg/dL", 3.5, 7.2),
]

SNOMED_BODYSITE = [
    ("49521004", "Left external ear"),
    ("80581009", "Upper arm"),
    ("76752008", "Breast"),
    ("39937001", "Skin structure"),
    ("69536005", "Head"),
    ("64237003", "Lung structure"),
    ("181268008", "Liver structure"),
    ("64033007", "Kidney structure"),
    ("80891009", "Heart structure"),
    ("113257007", "Cerebrum structure"),
]

SNOMED_SPECIMEN_TYPE = [
    ("119297000", "Blood specimen"),
    ("122575003", "Urine specimen"),
    ("119339001", "Stool specimen"),
    ("258450006", "Cerebrospinal fluid sample"),
    ("119376003", "Tissue specimen"),
]

SNOMED_PROC_CATEGORY = [
    ("387713003", "Surgical procedure"),
    ("103693007", "Diagnostic procedure"),
    ("277132007", "Therapeutic procedure"),
]

GENDER = ["male", "female", "other", "unknown"]

ENC_CLASS = [
    ("AMB", "ambulant"),
    ("IMP", "stationär"),
    ("PRENC", "vorstationär"),
]

KONTAKTEBENE = [
    ("einrichtungskontakt", "Einrichtungskontakt"),
    ("abteilungskontakt", "Abteilungskontakt"),
    ("versorgungsstellenkontakt", "Versorgungsstellenkontakt"),
]

KONTAKTART = [
    ("normalstationaer", "Normalstationär"),
    ("intensivstationaer", "Intensivstationär"),
    ("teilstationaer", "Teilstationär"),
]

FACHABTEILUNG = [
    ("0100", "Innere Medizin"),
    ("0200", "Geriatrie"),
    ("0300", "Kardiologie"),
    ("1500", "Allgemeine Chirurgie"),
    ("1700", "Gefäßchirurgie"),
    ("2400", "Frauenheilkunde und Geburtshilfe"),
    ("2800", "Neurologie"),
    ("3000", "Psychiatrie"),
]

AUFNAHMEGRUND_12 = ["01", "02", "03", "04", "05", "06", "07", "08"]
AUFNAHMEGRUND_3 = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
AUFNAHMEGRUND_4 = ["1", "2", "3", "4", "5"]

ENTLASSGRUND_12 = ["01", "02", "03", "04", "05", "06", "07", "08", "09"]
ENTLASSGRUND_3 = ["1", "2"]

AUFNAHMEANLASS = ["E", "Z", "N", "R", "V", "A", "G", "B"]

DIAGNOSE_USE = [
    ("HD", "Hauptdiagnose"),
    ("ND", "Nebendiagnose"),
    ("AD", "Aufnahmediagnose"),
    ("BD", "Behandlungsrelevante Diagnose"),
    ("AED", "Ausrückungsdiagnose"),
]

CLINICAL_STATUS = ["active", "recurrence", "relapse", "inactive", "remission", "resolved"]
VERIFICATION_STATUS = ["confirmed", "provisional", "differential", "unconfirmed"]

DIAGNOSESICHERHEIT = ["A", "V", "Z", "G"]
SEITENLOKALISATION = ["L", "R", "B"]

EDQM_ROUTE = [
    ("20053000", "Oral use"),
    ("20066000", "Intravenous use"),
    ("20062000", "Intramuscular use"),
    ("20071000", "Subcutaneous use"),
    ("20055000", "Topical use"),
]

ATC = [
    ("A10BA02", "Metformin"),
    ("C09AA05", "Ramipril"),
    ("C07AB07", "Bisoprolol"),
    ("N02BE01", "Paracetamol"),
    ("M01AE01", "Ibuprofen"),
    ("B01AC06", "Acetylsalicylsäure"),
    ("A02BC01", "Omeprazol"),
    ("C10AA05", "Atorvastatin"),
    ("R03AC02", "Salbutamol"),
    ("J01CA04", "Amoxicillin"),
]

LIST_STATUS = ["current", "retired", "entered-in-error"]
LIST_MODE = ["working", "snapshot", "changes"]

OBS_INTERPRETATION = ["N", "L", "H", "A"]

LAB_IDENTIFIER_TYPE = [("OBI", "Observation Instance Identifier")]

# ---------------------------------------------------------------------------
# Random helpers
# ---------------------------------------------------------------------------
RNG = random.Random(42)


def maybe(prob: float) -> bool:
    return RNG.random() < prob


def pick(seq):
    return RNG.choice(seq)


def random_date(start: date, end: date) -> date:
    delta = (end - start).days
    return start + timedelta(days=RNG.randint(0, delta))


def random_datetime(start: date, end: date) -> str:
    d = random_date(start, end)
    h = RNG.randint(0, 23)
    m = RNG.randint(0, 59)
    s = RNG.randint(0, 59)
    return datetime(d.year, d.month, d.day, h, m, s).strftime("%Y-%m-%dT%H:%M:%S+02:00")


def random_instant(start: date, end: date) -> str:
    """FHIR instant — must be UTC (Z) or a numeric offset, not both."""
    d = random_date(start, end)
    h = RNG.randint(0, 23)
    m = RNG.randint(0, 59)
    s = RNG.randint(0, 59)
    return datetime(d.year, d.month, d.day, h, m, s).strftime("%Y-%m-%dT%H:%M:%SZ")


def random_period(start: date, end: date, max_days: int = 14, allow_inverted: bool = False):
    s = random_date(start, end)
    e = s + timedelta(days=RNG.randint(0, max_days), hours=RNG.randint(0, 23))
    if allow_inverted and maybe(0.05):
        s, e = e, s
    return (
        datetime(s.year, s.month, s.day, RNG.randint(0, 23), 0).strftime("%Y-%m-%dT%H:%M:%S+02:00"),
        datetime(e.year, e.month, e.day, RNG.randint(0, 23), 0).strftime("%Y-%m-%dT%H:%M:%S+02:00"),
    )


def damage(resource: dict, missing_keys: list[str], invalid: list[tuple[str, callable]]) -> dict:
    """Optionally remove a field (10%) or inject an invalid value (5%)."""
    roll = RNG.random()
    if roll < 0.10 and missing_keys:
        key = pick(missing_keys)
        _remove_path(resource, key.split("."))
    elif roll < 0.15 and invalid:
        path, mutator = pick(invalid)
        _mutate_path(resource, path.split("."), mutator)
    return resource


def _remove_path(obj, parts):
    if obj is None:
        return
    head, *tail = parts
    if isinstance(obj, list):
        for el in obj:
            _remove_path(el, parts)
        return
    if not tail:
        obj.pop(head, None)
        return
    if head in obj:
        _remove_path(obj[head], tail)


def _mutate_path(obj, parts, fn):
    if obj is None:
        return
    head, *tail = parts
    if isinstance(obj, list):
        for el in obj:
            _mutate_path(el, parts, fn)
        return
    if not tail:
        if head in obj:
            obj[head] = fn(obj[head])
        return
    if head in obj:
        _mutate_path(obj[head], tail, fn)


# ---------------------------------------------------------------------------
# Resource builders
# ---------------------------------------------------------------------------
def build_patient(pid: str) -> dict:
    birth = random_date(date(1930, 1, 1), date(2015, 12, 31))
    res = {
        "resourceType": "Patient",
        "id": pid,
        "meta": {"profile": [P_PATIENT]},
        "identifier": [
            {
                "use": "usual",
                "type": {
                    "coding": [
                        {
                            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                            "code": "MR",
                        }
                    ]
                },
                "system": "https://www.charite.de/fhir/sid/patienten",
                "value": f"P-{pid}",
            },
            {
                "use": "secondary",
                "type": {
                    "coding": [
                        {
                            "system": "http://fhir.de/CodeSystem/identifier-type-de-basis",
                            "code": "PSEUDONYM",
                        }
                    ]
                },
                "system": "https://www.medizininformatik-initiative.de/fhir/sid/pseudonym",
                "value": f"PSN-{pid}",
            },
        ],
        "gender": pick(["male", "female", "male", "female", "other"]),
        "birthDate": birth.isoformat(),
        "address": [
            {
                "type": "both",
                "line": [f"{RNG.randint(1, 200)} Musterstraße"],
                "city": pick(["Berlin", "München", "Hamburg", "Köln", "Leipzig", "Dresden"]),
                "postalCode": f"{RNG.randint(10000, 99999)}",
                "country": "DE",
            }
        ],
    }
    return damage(
        res,
        missing_keys=[
            "meta.profile",
            "gender",
            "birthDate",
            "address.country",
            "address.postalCode",
        ],
        invalid=[
            ("gender", lambda _v: pick(["xx", "n/a", "unspecified-x"])),
            ("address.country", lambda _v: pick(["DEU", "Germany", "ZZ"])),
        ],
    )


def build_encounter(eid: str, pid: str, period_start_year: int, conditions: list[str]) -> dict:
    start, end = random_period(
        date(period_start_year, 1, 1),
        date(period_start_year, 12, 28),
        max_days=10,
        allow_inverted=True,
    )
    klass_code, klass_display = pick(ENC_CLASS)
    keb_code, keb_display = pick(KONTAKTEBENE)
    kart_code, kart_display = pick(KONTAKTART)
    fa_code, fa_display = pick(FACHABTEILUNG)
    res = {
        "resourceType": "Encounter",
        "id": eid,
        "meta": {"profile": [P_ENCOUNTER]},
        "extension": [
            {
                "url": "http://fhir.de/StructureDefinition/Aufnahmegrund",
                "extension": [
                    {
                        "url": "ErsteUndZweiteStelle",
                        "valueCoding": {
                            "system": "http://fhir.de/CodeSystem/dkgev/AufnahmegrundErsteUndZweiteStelle",
                            "code": pick(AUFNAHMEGRUND_12),
                            "display": "Aufnahmegrund 1./2. Stelle",
                        },
                    },
                    {
                        "url": "DritteStelle",
                        "valueCoding": {
                            "system": "http://fhir.de/CodeSystem/dkgev/AufnahmegrundDritteStelle",
                            "code": pick(AUFNAHMEGRUND_3),
                            "display": "Aufnahmegrund 3. Stelle",
                        },
                    },
                    {
                        "url": "VierteStelle",
                        "valueCoding": {
                            "system": "http://fhir.de/CodeSystem/dkgev/AufnahmegrundVierteStelle",
                            "code": pick(AUFNAHMEGRUND_4),
                            "display": "Aufnahmegrund 4. Stelle",
                        },
                    },
                ],
            }
        ],
        "identifier": [
            {
                "type": {
                    "coding": [
                        {
                            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                            "code": "VN",
                        }
                    ]
                },
                "system": "https://www.charite.de/fhir/sid/encounter",
                "value": f"VN-{eid}",
            }
        ],
        "status": pick(["finished", "in-progress", "planned", "cancelled"]),
        "class": {
            "system": "http://terminology.hl7.org/CodeSystem/v3-ActCode",
            "code": klass_code,
            "display": klass_display,
        },
        "type": [
            {
                "coding": [
                    {
                        "system": "http://fhir.de/CodeSystem/Kontaktebene",
                        "code": keb_code,
                        "display": keb_display,
                    },
                    {
                        "system": "http://fhir.de/CodeSystem/kontaktart-de",
                        "code": kart_code,
                        "display": kart_display,
                    },
                ]
            }
        ],
        "serviceType": {
            "coding": [
                {
                    "system": "http://fhir.de/CodeSystem/dkgev/Fachabteilungsschluessel",
                    "code": fa_code,
                    "display": fa_display,
                },
                {
                    "system": "http://fhir.de/CodeSystem/dkgev/Fachabteilungsschluessel-erweitert",
                    "code": fa_code + "00",
                    "display": fa_display + " (erweitert)",
                },
            ]
        },
        "subject": {"reference": f"Patient/{pid}"},
        "period": {"start": start, "end": end},
        "diagnosis": [
            {
                "condition": {"reference": f"Condition/{cond_id}"},
                "use": {
                    "coding": [
                        {
                            "system": "http://fhir.de/CodeSystem/KontaktDiagnoseProzedur",
                            "code": pick(DIAGNOSE_USE)[0],
                            "display": pick(DIAGNOSE_USE)[1],
                        },
                        {
                            "system": "http://terminology.hl7.org/CodeSystem/diagnosis-role",
                            "code": pick(["AD", "DD", "CC"]),
                            "display": "diagnosis-role",
                        },
                    ]
                },
            }
            for cond_id in conditions[:3]
        ],
        "hospitalization": {
            "admitSource": {
                "coding": [
                    {
                        "system": "http://fhir.de/CodeSystem/dgkev/Aufnahmeanlass",
                        "code": pick(AUFNAHMEANLASS),
                        "display": "Aufnahmeanlass",
                    }
                ]
            },
            "dischargeDisposition": {
                "extension": [
                    {
                        "url": "http://fhir.de/StructureDefinition/Entlassungsgrund",
                        "extension": [
                            {
                                "url": "ErsteUndZweiteStelle",
                                "valueCoding": {
                                    "system": "http://fhir.de/CodeSystem/dkgev/EntlassungsgrundErsteUndZweiteStelle",
                                    "code": pick(ENTLASSGRUND_12),
                                    "display": "Entlassgrund 1./2. Stelle",
                                },
                            },
                            {
                                "url": "DritteStelle",
                                "valueCoding": {
                                    "system": "http://fhir.de/CodeSystem/dkgev/EntlassungsgrundDritteStelle",
                                    "code": pick(ENTLASSGRUND_3),
                                    "display": "Entlassgrund 3. Stelle",
                                },
                            },
                        ],
                    }
                ],
                "text": "Entlassung",
            },
        },
    }
    return damage(
        res,
        missing_keys=[
            "meta.profile",
            "extension",
            "identifier",
            "status",
            "class.code",
            "class.display",
            "serviceType",
            "period.end",
            "period.start",
            "hospitalization.admitSource",
            "hospitalization.dischargeDisposition",
            "diagnosis",
        ],
        invalid=[
            ("status", lambda _v: pick(["bogus", "weird", "made-up"])),
            ("class.code", lambda _v: "ZZZ"),
        ],
    )


def build_condition(cid: str, pid: str, eid: str, asserted_year: int) -> dict:
    code, display = pick(ICD10)
    onset_start, onset_end = random_period(
        date(asserted_year, 1, 1), date(asserted_year, 12, 28), max_days=200, allow_inverted=True
    )
    asserted = random_datetime(date(asserted_year, 1, 1), date(asserted_year, 12, 28))
    res = {
        "resourceType": "Condition",
        "id": cid,
        "meta": {"profile": [P_CONDITION]},
        "extension": [
            {
                "url": "http://hl7.org/fhir/StructureDefinition/condition-assertedDate",
                "valueDateTime": asserted,
            }
        ],
        "clinicalStatus": {
            "coding": [
                {
                    "system": "http://terminology.hl7.org/CodeSystem/condition-clinical",
                    "code": pick(CLINICAL_STATUS),
                }
            ]
        },
        "verificationStatus": {
            "coding": [
                {
                    "system": "http://terminology.hl7.org/CodeSystem/condition-ver-status",
                    "code": pick(VERIFICATION_STATUS),
                }
            ]
        },
        "code": {
            "coding": [
                {
                    "system": "http://fhir.de/CodeSystem/bfarm/icd-10-gm",
                    "code": code,
                    "display": display,
                    "extension": [
                        {
                            "url": "http://fhir.de/StructureDefinition/icd-10-gm-diagnosesicherheit",
                            "valueCoding": {
                                "system": "https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_ICD_DIAGNOSESICHERHEIT",
                                "code": pick(DIAGNOSESICHERHEIT),
                            },
                        },
                        {
                            "url": "http://fhir.de/StructureDefinition/seitenlokalisation",
                            "valueCoding": {
                                "system": "https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_ICD_SEITENLOKALISATION",
                                "code": pick(SEITENLOKALISATION),
                            },
                        },
                    ],
                },
                {
                    "system": "http://snomed.info/sct",
                    "code": str(RNG.randint(10000000, 999999999)),
                    "display": display,
                },
            ],
            "text": display,
        },
        "bodySite": [
            {
                "coding": [
                    {
                        "system": "http://snomed.info/sct",
                        "code": pick(SNOMED_BODYSITE)[0],
                        "display": pick(SNOMED_BODYSITE)[1],
                    }
                ]
            }
        ],
        "subject": {"reference": f"Patient/{pid}"},
        "encounter": {"reference": f"Encounter/{eid}"},
        "onsetPeriod": {"start": onset_start, "end": onset_end},
        "recordedDate": asserted,
    }
    return damage(
        res,
        missing_keys=[
            "meta.profile",
            "extension",
            "clinicalStatus",
            "verificationStatus",
            "bodySite",
            "encounter",
            "recordedDate",
            "onsetPeriod",
        ],
        invalid=[
            ("code.coding.code", lambda _v: pick(["XYZ99", "ABC123", "999"])),
            ("clinicalStatus.coding.code", lambda _v: "weird-status"),
            ("verificationStatus.coding.code", lambda _v: "bogus-ver"),
        ],
    )


def build_procedure(pid_proc: str, pid: str, eid: str, year: int) -> dict:
    code, display = pick(OPS)
    cat_code, cat_display = pick(SNOMED_PROC_CATEGORY)
    res = {
        "resourceType": "Procedure",
        "id": pid_proc,
        "meta": {"profile": [P_PROCEDURE]},
        "status": pick(["completed", "in-progress", "not-done"]),
        "category": {
            "coding": [
                {"system": "http://snomed.info/sct", "code": cat_code, "display": cat_display}
            ]
        },
        "code": {
            "coding": [
                {
                    "system": "http://fhir.de/CodeSystem/bfarm/ops",
                    "version": "2024",
                    "code": code,
                    "display": display,
                }
            ]
        },
        "subject": {"reference": f"Patient/{pid}"},
        "encounter": {"reference": f"Encounter/{eid}"},
        "performedDateTime": random_datetime(date(year, 1, 1), date(year, 12, 28)),
    }
    return damage(
        res,
        missing_keys=["meta.profile", "category", "encounter", "performedDateTime"],
        invalid=[
            ("code.coding.code", lambda _v: "99-99-99"),
            ("status", lambda _v: "weird"),
        ],
    )


def build_observation_lab(oid: str, pid: str, eid: str, year: int) -> dict:
    code, display, unit, ucum, low, high = pick(LOINC)
    value = round(RNG.uniform(low * 0.5, high * 1.5), 2)
    interpretation = "N" if low <= value <= high else ("L" if value < low else "H")
    effective = random_datetime(date(year, 1, 1), date(year, 12, 28))
    issued = random_instant(date(year, 1, 1), date(year, 12, 28))
    res = {
        "resourceType": "Observation",
        "id": oid,
        "meta": {"profile": [P_OBS_LAB]},
        "identifier": [
            {
                "type": {
                    "coding": [
                        {
                            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                            "code": "OBI",
                        }
                    ]
                },
                "system": "https://www.charite.de/fhir/sid/observation",
                "value": f"OBS-{oid}",
                "assigner": {"display": "Charité"},
            }
        ],
        "status": pick(["final", "preliminary", "amended", "corrected"]),
        "category": [
            {
                "coding": [
                    {
                        "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                        "code": "laboratory",
                    },
                    {
                        "system": "http://loinc.org",
                        "code": "26436-6",
                        "display": "Laboratory studies",
                    },
                    {
                        "system": "http://exmple.org/fhir/sid/Laborgruppe",
                        "code": "G-CHEM",
                        "display": "Klinische Chemie",
                    },
                ]
            }
        ],
        "code": {
            "coding": [
                {"system": "http://loinc.org", "code": code, "display": display}
            ],
            "text": display,
        },
        "subject": {"reference": f"Patient/{pid}"},
        "encounter": {"reference": f"Encounter/{eid}"},
        "effectiveDateTime": effective,
        "issued": issued,
        "valueQuantity": {
            "value": value,
            "unit": unit,
            "system": "http://unitsofmeasure.org",
            "code": ucum,
        },
        "interpretation": [
            {
                "coding": [
                    {
                        "system": "http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation",
                        "code": interpretation,
                    }
                ]
            }
        ],
        "referenceRange": [
            {
                "low": {"value": low, "unit": unit, "system": "http://unitsofmeasure.org", "code": ucum},
                "high": {"value": high, "unit": unit, "system": "http://unitsofmeasure.org", "code": ucum},
            }
        ],
    }
    return damage(
        res,
        missing_keys=[
            "meta.profile",
            "identifier",
            "status",
            "category",
            "encounter",
            "effectiveDateTime",
            "valueQuantity",
            "interpretation",
            "referenceRange",
        ],
        invalid=[
            ("status", lambda _v: "bogus"),
            ("code.coding.code", lambda _v: "not-real-loinc"),
            ("interpretation.coding.code", lambda _v: "ZZZ"),
        ],
    )


def build_specimen(sid: str, pid: str, year: int) -> dict:
    type_code, type_display = pick(SNOMED_SPECIMEN_TYPE)
    res = {
        "resourceType": "Specimen",
        "id": sid,
        "meta": {"profile": [P_SPECIMEN]},
        "identifier": [
            {
                "type": {
                    "coding": [
                        {"system": "http://terminology.hl7.org/CodeSystem/v2-0203", "code": "ACSN"}
                    ]
                },
                "system": "https://www.charite.de/fhir/sid/specimen",
                "value": f"SPN-{sid}",
            }
        ],
        "status": pick(["available", "unavailable", "unsatisfactory", "entered-in-error"]),
        "type": {
            "coding": [{"system": "http://snomed.info/sct", "code": type_code, "display": type_display}]
        },
        "subject": {"reference": f"Patient/{pid}"},
        "collection": {
            "collectedDateTime": random_datetime(date(year, 1, 1), date(year, 12, 28)),
            "bodySite": {
                "coding": [
                    {
                        "system": "http://snomed.info/sct",
                        "code": pick(SNOMED_BODYSITE)[0],
                        "display": pick(SNOMED_BODYSITE)[1],
                    }
                ]
            },
        },
    }
    return damage(
        res,
        missing_keys=["meta.profile", "type", "collection.collectedDateTime"],
        invalid=[("status", lambda _v: "weird"), ("type.coding.code", lambda _v: "999999999")],
    )


def build_diagnostic_report_lab(drid: str, pid: str, eid: str, obs_ids: list[str], year: int) -> dict:
    res = {
        "resourceType": "DiagnosticReport",
        "id": drid,
        "meta": {"profile": [P_DR_LAB]},
        "identifier": [
            {
                "type": {
                    "coding": [
                        {"system": "http://terminology.hl7.org/CodeSystem/v2-0203", "code": "FILL"}
                    ]
                },
                "system": "https://www.charite.de/fhir/sid/dr-lab",
                "value": f"DRL-{drid}",
            }
        ],
        "status": pick(["final", "preliminary", "amended", "corrected"]),
        "category": [
            {
                "coding": [
                    {
                        "system": "http://terminology.hl7.org/CodeSystem/v2-0074",
                        "code": "LAB",
                        "display": "Laboratory",
                    }
                ]
            }
        ],
        "code": {
            "coding": [
                {
                    "system": "http://loinc.org",
                    "code": "11502-2",
                    "display": "Laboratory report",
                }
            ]
        },
        "subject": {"reference": f"Patient/{pid}"},
        "encounter": {"reference": f"Encounter/{eid}"},
        "effectiveDateTime": random_datetime(date(year, 1, 1), date(year, 12, 28)),
        "issued": random_instant(date(year, 1, 1), date(year, 12, 28)),
        "result": [{"reference": f"Observation/{oid}"} for oid in obs_ids],
    }
    return damage(
        res,
        missing_keys=["meta.profile", "identifier", "status", "category", "code", "encounter"],
        invalid=[
            ("status", lambda _v: "weird"),
            ("category.coding.code", lambda _v: "ZZZ"),
        ],
    )


def build_diagnostic_report_patho(drid: str, pid: str, eid: str, year: int) -> dict:
    icd_code, icd_display = pick(ICD10)
    res = {
        "resourceType": "DiagnosticReport",
        "id": drid,
        "meta": {"profile": [P_DR_PATHO]},
        "identifier": [
            {
                "type": {
                    "coding": [
                        {"system": "http://terminology.hl7.org/CodeSystem/v2-0203", "code": "FILL"}
                    ]
                },
                "system": "https://www.charite.de/fhir/sid/dr-patho",
                "value": f"DRP-{drid}",
            }
        ],
        "status": pick(["final", "preliminary", "amended"]),
        "category": [
            {
                "coding": [
                    {
                        "system": "http://terminology.hl7.org/CodeSystem/v2-0074",
                        "code": "PAT",
                        "display": "Pathology",
                    }
                ]
            }
        ],
        "code": {
            "coding": [
                {"system": "http://loinc.org", "code": "60568-3", "display": "Pathology Synoptic report"}
            ]
        },
        "subject": {"reference": f"Patient/{pid}"},
        "encounter": {"reference": f"Encounter/{eid}"},
        "effectiveDateTime": random_datetime(date(year, 1, 1), date(year, 12, 28)),
        "issued": random_instant(date(year, 1, 1), date(year, 12, 28)),
        "conclusionCode": [
            {
                "coding": [
                    {
                        "system": "http://fhir.de/CodeSystem/bfarm/icd-10-gm",
                        "code": icd_code,
                        "display": icd_display,
                    }
                ]
            }
        ],
    }
    return damage(
        res,
        missing_keys=["meta.profile", "category", "encounter", "conclusionCode"],
        invalid=[("status", lambda _v: "weird")],
    )


def build_service_request_lab(srid: str, pid: str, eid: str, year: int) -> dict:
    return _build_service_request(srid, pid, eid, year, P_SR_LAB, "lab", "108252007", "Laboratory procedure")


def build_service_request_patho(srid: str, pid: str, eid: str, year: int) -> dict:
    return _build_service_request(srid, pid, eid, year, P_SR_PATHO, "lab", "726007", "Pathology consultation")


def _build_service_request(srid, pid, eid, year, profile, category_code, snomed_code, snomed_display):
    res = {
        "resourceType": "ServiceRequest",
        "id": srid,
        "meta": {"profile": [profile]},
        "identifier": [
            {
                "type": {
                    "coding": [
                        {"system": "http://terminology.hl7.org/CodeSystem/v2-0203", "code": "PLAC"}
                    ]
                },
                "system": "https://www.charite.de/fhir/sid/sr",
                "value": f"SR-{srid}",
            }
        ],
        "status": pick(["active", "completed", "draft", "revoked"]),
        "intent": pick(["order", "original-order", "filler-order"]),
        "category": [
            {
                "coding": [
                    {
                        "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                        "code": category_code,
                    },
                    {
                        "system": "http://snomed.info/sct",
                        "code": snomed_code,
                        "display": snomed_display,
                    },
                ]
            }
        ],
        "code": {
            "coding": [
                {
                    "system": "http://loinc.org",
                    "code": pick(LOINC)[0],
                    "display": "Order code",
                }
            ]
        },
        "subject": {"reference": f"Patient/{pid}"},
        "encounter": {"reference": f"Encounter/{eid}"},
        "authoredOn": random_datetime(date(year, 1, 1), date(year, 12, 28)),
    }
    return damage(
        res,
        missing_keys=["meta.profile", "category", "encounter", "authoredOn", "intent"],
        invalid=[
            ("status", lambda _v: "bogus"),
            ("intent", lambda _v: "weird"),
        ],
    )


def build_medication(mid: str) -> dict:
    code, display = pick(ATC)
    res = {
        "resourceType": "Medication",
        "id": mid,
        "meta": {"profile": [P_MEDICATION]},
        "code": {
            "coding": [
                {
                    "system": "http://fhir.de/CodeSystem/dimdi/atc",
                    "code": code,
                    "display": display,
                }
            ],
            "text": display,
        },
        "form": {
            "coding": [
                {
                    "system": "http://standardterms.edqm.eu",
                    "code": "10219000",
                    "display": "Tablet",
                }
            ]
        },
    }
    return damage(res, missing_keys=["meta.profile", "form"], invalid=[])


def build_medication_statement(msid: str, pid: str, eid: str, mid: str, year: int) -> dict:
    start, end = random_period(date(year, 1, 1), date(year, 12, 28), max_days=60, allow_inverted=True)
    route_code, route_display = pick(EDQM_ROUTE)
    res = {
        "resourceType": "MedicationStatement",
        "id": msid,
        "meta": {"profile": [P_MED_STATEMENT]},
        "status": pick(["active", "completed", "stopped", "intended"]),
        "medicationReference": {"reference": f"Medication/{mid}"},
        "subject": {"reference": f"Patient/{pid}"},
        "context": {"reference": f"Encounter/{eid}"},
        "effectivePeriod": {"start": start, "end": end},
        "dateAsserted": random_datetime(date(year, 1, 1), date(year, 12, 28)),
        "dosage": [
            {
                "route": {
                    "coding": [
                        {
                            "system": "http://standardterms.edqm.eu",
                            "code": route_code,
                            "display": route_display,
                        }
                    ]
                },
                "doseAndRate": [
                    {
                        "doseQuantity": {
                            "value": pick([1, 2, 5, 10, 20, 40]),
                            "unit": "mg",
                            "system": "http://unitsofmeasure.org",
                            "code": "mg",
                        }
                    }
                ],
            }
        ],
    }
    return damage(
        res,
        missing_keys=["meta.profile", "context", "dosage", "dosage.route"],
        invalid=[
            ("status", lambda _v: "weird"),
            ("dosage.route.coding.code", lambda _v: "ZZ-route"),
        ],
    )


def build_medication_request(
    mrid: str, pid: str, eid: str, mid: str, year: int, force_invalid_route: bool = False
) -> dict:
    # Emit 1-3 dosageInstructions; ~40% have multiple to exercise CQL paths that
    # break under singleton promotion (e.g. dosageInstruction.route).
    n_dosage = 2 if force_invalid_route else pick([1, 1, 1, 2, 2, 3])
    invalid_idx = RNG.randint(0, n_dosage - 1) if force_invalid_route else -1
    dosage_instructions = []
    for i in range(n_dosage):
        if i == invalid_idx:
            route_code, route_display = ("ZZ-bogus-route", "Invalid route")
        else:
            route_code, route_display = pick(EDQM_ROUTE)
        dosage_instructions.append(
            {
                "route": {
                    "coding": [
                        {
                            "system": "http://standardterms.edqm.eu",
                            "code": route_code,
                            "display": route_display,
                        }
                    ]
                }
            }
        )
    res = {
        "resourceType": "MedicationRequest",
        "id": mrid,
        "meta": {"profile": [P_MED_REQUEST]},
        "status": pick(["active", "completed", "stopped", "draft", "cancelled"]),
        "intent": pick(["order", "plan", "proposal"]),
        "medicationReference": {"reference": f"Medication/{mid}"},
        "subject": {"reference": f"Patient/{pid}"},
        "encounter": {"reference": f"Encounter/{eid}"},
        "authoredOn": random_datetime(date(year, 1, 1), date(year, 12, 28)),
        "dosageInstruction": dosage_instructions,
    }
    if force_invalid_route:
        return res
    return damage(
        res,
        missing_keys=["meta.profile", "intent", "encounter", "dosageInstruction"],
        invalid=[("status", lambda _v: "bogus"), ("intent", lambda _v: "weird")],
    )


def build_medication_administration(maid: str, pid: str, eid: str, mid: str, mrid: str | None, year: int) -> dict:
    route_code, route_display = pick(EDQM_ROUTE)
    res = {
        "resourceType": "MedicationAdministration",
        "id": maid,
        "meta": {"profile": [P_MED_ADMIN]},
        "status": pick(["completed", "in-progress", "stopped", "not-done"]),
        "medicationReference": {"reference": f"Medication/{mid}"},
        "subject": {"reference": f"Patient/{pid}"},
        "context": {"reference": f"Encounter/{eid}"},
        "effectiveDateTime": random_datetime(date(year, 1, 1), date(year, 12, 28)),
        "dosage": {
            "route": {
                "coding": [
                    {
                        "system": "http://standardterms.edqm.eu",
                        "code": route_code,
                        "display": route_display,
                    }
                ]
            },
            "dose": {
                "value": pick([1, 2, 5, 10, 20]),
                "unit": "mg",
                "system": "http://unitsofmeasure.org",
                "code": "mg",
            },
        },
    }
    if mrid:
        res["request"] = {"reference": f"MedicationRequest/{mrid}"}
    return damage(
        res,
        missing_keys=["meta.profile", "context", "dosage.route"],
        invalid=[("status", lambda _v: "weird")],
    )


def build_medication_list(lid: str, pid: str, eid: str, ms_ids: list[str], year: int) -> dict:
    res = {
        "resourceType": "List",
        "id": lid,
        "meta": {"profile": [P_MED_LIST]},
        "extension": [
            {
                "url": "https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/Fallkontext",
                "valueReference": {"reference": f"Encounter/{eid}"},
            }
        ],
        "status": pick(LIST_STATUS),
        "mode": pick(LIST_MODE),
        "code": {
            "coding": [
                {
                    "system": "http://terminology.hl7.org/CodeSystem/list-example-codes",
                    "code": "medications",
                    "display": "Medication List",
                }
            ]
        },
        "subject": {"reference": f"Patient/{pid}"},
        "encounter": {"reference": f"Encounter/{eid}"},
        "date": random_datetime(date(year, 1, 1), date(year, 12, 28)),
        "entry": [{"item": {"reference": f"MedicationStatement/{msid}"}} for msid in ms_ids],
    }
    return damage(
        res,
        missing_keys=["meta.profile", "extension", "code", "encounter"],
        invalid=[
            ("status", lambda _v: "garbage"),
            ("mode", lambda _v: "weird"),
        ],
    )


def build_consent(cid: str, pid: str, year: int) -> dict:
    start, end = random_period(date(year, 1, 1), date(year, 12, 28), max_days=365, allow_inverted=False)
    res = {
        "resourceType": "Consent",
        "id": cid,
        "meta": {"profile": [P_CONSENT]},
        "status": pick(["active", "inactive", "draft", "rejected"]),
        "scope": {
            "coding": [
                {
                    "system": "http://terminology.hl7.org/CodeSystem/consentscope",
                    "code": "research",
                }
            ]
        },
        "category": [
            {
                "coding": [
                    {
                        "system": "http://loinc.org",
                        "code": "57016-8",
                        "display": "Privacy policy acknowledgement",
                    }
                ]
            }
        ],
        "patient": {"reference": f"Patient/{pid}"},
        "dateTime": random_datetime(date(year, 1, 1), date(year, 12, 28)),
        "policy": [{"uri": "https://www.medizininformatik-initiative.de/fhir/modul-consent/policy"}],
        "provision": {
            "type": pick(["permit", "deny"]),
            "period": {"start": start, "end": end},
            "provision": [
                {
                    "type": pick(["permit", "deny"]),
                    "code": [
                        {
                            "coding": [
                                {
                                    "system": "urn:oid:2.16.840.1.113883.3.1937.777.24.5.3",
                                    "code": "2.16.840.1.113883.3.1937.777.24.5.3.1",
                                    "display": "PATDAT_erheben_speichern_nutzen",
                                }
                            ]
                        }
                    ],
                }
            ],
        },
    }
    return damage(
        res,
        missing_keys=["meta.profile", "category", "provision.period.end", "provision.period.start"],
        invalid=[
            ("status", lambda _v: "weird"),
            ("provision.type", lambda _v: "garbage"),
        ],
    )


# ---------------------------------------------------------------------------
# Bundle assembly
# ---------------------------------------------------------------------------
def make_bundle(patient_idx: int) -> dict:
    pid = f"pat-{patient_idx:03d}"
    base_year = RNG.randint(2018, 2025)
    entries = []

    # Patient
    entries.append(build_patient(pid))

    # Encounters (1-3)
    encounters = []
    n_enc = RNG.randint(1, 3)
    for ei in range(1, n_enc + 1):
        encounters.append(f"enc-{patient_idx:03d}-{ei}")

    # Conditions (1-5), each linked to a random encounter
    n_cond = RNG.randint(1, 5)
    cond_ids = []
    for ci in range(1, n_cond + 1):
        cid = f"cond-{patient_idx:03d}-{ci}"
        cond_ids.append(cid)
        entries.append(build_condition(cid, pid, RNG.choice(encounters), base_year))

    # Add Primärdiagnose backref extension on some non-first conditions
    if len(cond_ids) > 1:
        primary = cond_ids[0]
        for cid in cond_ids[1:]:
            for e in entries:
                if e.get("resourceType") == "Condition" and e.get("id") == cid:
                    if not maybe(0.20):
                        e.setdefault("extension", []).append(
                            {
                                "url": "http://hl7.org/fhir/StructureDefinition/condition-related",
                                "valueReference": {"reference": f"Condition/{primary}"},
                            }
                        )

    # Build encounters now that we have condition IDs
    for ei, enc_id in enumerate(encounters, start=1):
        enc_conds = [c for c in cond_ids if RNG.random() < 0.5] or cond_ids[:1]
        entries.append(build_encounter(enc_id, pid, base_year, enc_conds))

    # Procedures (0-2)
    n_proc = RNG.randint(0, 2)
    for pi in range(1, n_proc + 1):
        entries.append(
            build_procedure(
                f"proc-{patient_idx:03d}-{pi}", pid, RNG.choice(encounters), base_year
            )
        )

    # Observations (5-15)
    n_obs = RNG.randint(5, 15)
    obs_ids = []
    for oi in range(1, n_obs + 1):
        oid = f"obs-{patient_idx:03d}-{oi}"
        obs_ids.append(oid)
        entries.append(build_observation_lab(oid, pid, RNG.choice(encounters), base_year))

    # Specimens (0-2)
    spec_ids = []
    for si in range(1, RNG.randint(0, 2) + 1):
        sid = f"spec-{patient_idx:03d}-{si}"
        spec_ids.append(sid)
        entries.append(build_specimen(sid, pid, base_year))

    # DiagnosticReport Lab (0-2), referencing some observations
    for di in range(1, RNG.randint(0, 2) + 1):
        drid = f"drlab-{patient_idx:03d}-{di}"
        sample = RNG.sample(obs_ids, k=min(len(obs_ids), RNG.randint(1, 5)))
        entries.append(
            build_diagnostic_report_lab(drid, pid, RNG.choice(encounters), sample, base_year)
        )

    # DiagnosticReport Patho (0-1)
    if maybe(0.4):
        entries.append(
            build_diagnostic_report_patho(
                f"drpatho-{patient_idx:03d}-1", pid, RNG.choice(encounters), base_year
            )
        )

    # ServiceRequest Lab (0-1)
    if maybe(0.6):
        entries.append(
            build_service_request_lab(
                f"srlab-{patient_idx:03d}-1", pid, RNG.choice(encounters), base_year
            )
        )

    # ServiceRequest Patho (0-1)
    if maybe(0.3):
        entries.append(
            build_service_request_patho(
                f"srpatho-{patient_idx:03d}-1", pid, RNG.choice(encounters), base_year
            )
        )

    # Medications (1-3)
    n_med = RNG.randint(1, 3)
    med_ids = []
    for mi in range(1, n_med + 1):
        mid = f"med-{patient_idx:03d}-{mi}"
        med_ids.append(mid)
        entries.append(build_medication(mid))

    # MedicationStatement (0-3)
    ms_ids = []
    for msi in range(1, RNG.randint(0, 3) + 1):
        msid = f"medst-{patient_idx:03d}-{msi}"
        ms_ids.append(msid)
        entries.append(
            build_medication_statement(
                msid, pid, RNG.choice(encounters), RNG.choice(med_ids), base_year
            )
        )

    # MedicationRequest (0-2; patient 1 always gets one with an invalid route
    # coding, to exercise "Inadmissible categorical values dosageInstruction.route")
    mr_ids = []
    n_mr = RNG.randint(0, 2)
    if patient_idx == 1:
        mrid = f"medrq-{patient_idx:03d}-invalid-route"
        mr_ids.append(mrid)
        entries.append(
            build_medication_request(
                mrid, pid, RNG.choice(encounters), RNG.choice(med_ids), base_year,
                force_invalid_route=True,
            )
        )
    for mri in range(1, n_mr + 1):
        mrid = f"medrq-{patient_idx:03d}-{mri}"
        mr_ids.append(mrid)
        entries.append(
            build_medication_request(
                mrid, pid, RNG.choice(encounters), RNG.choice(med_ids), base_year
            )
        )

    # MedicationAdministration (0-2)
    for mai in range(1, RNG.randint(0, 2) + 1):
        maid = f"medad-{patient_idx:03d}-{mai}"
        entries.append(
            build_medication_administration(
                maid,
                pid,
                RNG.choice(encounters),
                RNG.choice(med_ids),
                RNG.choice(mr_ids) if mr_ids else None,
                base_year,
            )
        )

    # MedicationList (0-1)
    if ms_ids and maybe(0.5):
        entries.append(
            build_medication_list(
                f"medlist-{patient_idx:03d}-1",
                pid,
                RNG.choice(encounters),
                ms_ids,
                base_year,
            )
        )

    # Consent (always 1)
    entries.append(build_consent(f"cons-{patient_idx:03d}-1", pid, base_year))

    # Wrap into bundle entries with PUT requests
    bundle_entries = []
    for r in entries:
        rid = r.get("id")
        rt = r["resourceType"]
        if not rid:
            # Damage may have removed id; restore a fallback so the URL is valid
            rid = f"missing-{RNG.randint(1, 1_000_000)}"
            r["id"] = rid
        bundle_entries.append(
            {
                "fullUrl": f"urn:uuid:{rt}-{rid}",
                "resource": r,
                "request": {"method": "PUT", "url": f"{rt}/{rid}"},
            }
        )

    return {
        "resourceType": "Bundle",
        "id": f"bundle-{pid}",
        "type": "transaction",
        "entry": bundle_entries,
    }


def main():
    if len(sys.argv) > 1:
        out_dir = Path(sys.argv[1])
    else:
        out_dir = Path(__file__).parent / "generated"
    out_dir.mkdir(parents=True, exist_ok=True)

    # Wipe stale files (only those we'd overwrite)
    for old in out_dir.glob("Bundle-pat-*.json"):
        old.unlink()

    for i in range(1, 101):
        bundle = make_bundle(i)
        path = out_dir / f"Bundle-pat-{i:03d}.json"
        path.write_text(json.dumps(bundle, indent=2, ensure_ascii=False))

    print(f"Wrote 100 bundles to {out_dir}")


if __name__ == "__main__":
    main()
