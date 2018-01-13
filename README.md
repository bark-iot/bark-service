# bark-service

See `bark` repository for instructions.

# API docs
- to view go to [http://localhost/barks/docs](http://localhost/barks/docs)
- to build run `cd docs && mkdocs build`

# Migrations
- `docker-compose run bark-service ./cli db_migrate`

# Run tests
- `dc run bark-service rspec`