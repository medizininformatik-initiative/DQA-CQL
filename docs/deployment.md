# Minimal Example Deployment

The docker compose file contains a minimal example deployment for testing purposes. 

> [!CAUTION]
> Don't use the deployment in production.

The scripts use the SNOMED CT terminology, but will also work without it (all SNOMED CT concepts will be flagged as non-matching in that case). Because everyone using SNOMED CT needs a license, you have to provide the release files yourself. In case you have a [SNOMED MLDS][1] account, you can download the SNOMED CT Germany Edition release packages and unzip them. Instead of editing `docker-compose.yml` directly, create a `docker-compose.override.yml` file with your specific paths to keep your configuration local and uncommitted:

```yaml
services:
  terminology-server:
    environment:
      ENABLE_TERMINOLOGY_SNOMED_CT: "true"
      SNOMED_CT_RELEASE_PATH: "/app/sct-release"
    volumes:
      - "/path/to/your/SnomedCT_Release:/app/sct-release"
```

After that, please start the Docker containers: 

```sh
docker compose up --wait
```

On port 8080, the data server should run. You can test that via:

```sh
curl -s http://localhost:8080/fhir/metadata | jq .software
```

That should output:

```json
{
  "name": "Blaze",
  "version": "1.7.0",
  "releaseDate": "2026-04-28"
}
```

On port 8082, the terminology server should run. You can test that via:

```sh
curl -s 'http://localhost:8082/fhir/metadata?mode=terminology' | jq '.codeSystem[] | select(.uri == "http://loinc.org")'
```

That should output:

```json
{
  "uri": "http://loinc.org",
  "version": [
    {
      "code": "2.78",
      "isDefault": true
    }
  ]
}
```

## Importing all Codesystem and ValueSet Resources used in the MII

SU-Termserv provides a NPM package named [Bill Of Materials Package][2] which includes all Codesystem and ValueSet resources used in the MII.

Please run `make -C terminology-data install` in order to install that package.

After that please run `terminology-data/upload-all.sh` to import all of that resources into the terminology server. If the script finishes successfully, it will output the number of available code systems. Otherwise you can check that number yourself. It should be 1530.

```sh
curl -s 'http://localhost:8082/fhir/metadata?mode=terminology' | jq -r '.codeSystem | length'
```

### Updating the Terminology Resources

Please change the version number of `terminology-data/package.json` and run `make -C terminology-data update` in order to update the package.

[1]: <https://mlds.ihtsdotools.org>
[2]: <https://gitlab.com/mii-termserv/fhir-resources/mii-kerndatensatz/de.medizininformatikinitiative.kerndatensatz.terminology.bill-of-materials>
