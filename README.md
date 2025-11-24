# DQA - CQL

Non-official, non-binding Data Quality Assessments inspired by [DQA](https://github.com/medizininformatik-initiative/DQA).

## Goal

The scripts have the following goals:

* provide a tool to assess the data quality of [MII - KDS][1] resources in a FHIR server
* make use of [FHIR R4 - Quality Reporting Module][2] in combination with [Clinical Quality Language][3]
* make use of [MII SU-TermServ][4] for metadata

## Architecture

```mermaid
architecture-beta
    service ts[Terminology Server]
    service db[FHIR Server]
    db:L -- R:ts
```

# Preparation

```sh
docker compose up -d
```

```sh
./download-synthea-test-data.sh
```

```sh
blazectl --server http://localhost:8080/fhir upload <temp-dir>
```

# CQL Script Execution

## Condition

```sh
blazectl --server http://localhost:8080/fhir evaluate-measure scripts/condition.yml | jq -rf scripts/table.jq
```

[1]: <https://simplifier.net/organization/koordinationsstellemii>
[2]: <https://hl7.org/fhir/R4/clinicalreasoning-quality-reporting.html>
[3]: <https://cql.hl7.org>
[4]: <https://mii-termserv.de>
