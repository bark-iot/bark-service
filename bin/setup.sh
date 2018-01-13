#!/bin/bash
docker-compose run bark-service bundle
docker-compose run bark-service bundle exec ./cli db_migrate
cd ../bark-service/docs && mkdocs build # build api doc