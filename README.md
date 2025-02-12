# Elasticsearch 3-nodes cluster

## Generate certificates

```bash
$ ./generate_certificates.sh
```

## Elasticsearch

```bash
$ docker compose up -d
```

## Elasticvue GUI

```bash
$ docker run -p 8080:8080 -v ./config.json:/usr/share/nginx/html/api/default_clusters.json --name elasticvue -d cars10/elasticvue

```

### SSL: Temporarily Accept the Certificate

1. When elasticvue displays an error message about the untrusted certificate, click the link to your cluster (or open the URL manually in your browser), which is by default https://localhost:9200.
2. Authenticate in the basic auth dialog. The default username is elastic and the default password is the value of ELASTIC_PASSWORD in `.env`.
3. Your browser will warn you about the untrusted certificate. Accept the warning and trust the certificate.

> Drawback: Trust a certificate this way is only temporary, and you may need to repeat these steps every time you restart your browser.

### Open the GUI

Elasticvue should be available at http://localhost:8080

### Configure the cluster

#### Predefined clusters

Elasticvue comes with a predefined cluster configuration in `config.json`. If `Predefined clusters` is disabled, you can try to clear the browser cache or check `Disable cache` in the Developper Tools's network tab.
