# DQA - CQL

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
