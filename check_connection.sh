#!/bin/bash
source .env
curl -k -u elastic:$ELASTIC_PASSWORD https://localhost:9200/_cluster/health