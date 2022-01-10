# Nilus - API - Backend

Last Update: 01/31/2019

[![Build Status](https://img.shields.io/codeship/fe7da910-3d14-0136-59ad-1ed0266f5d63/master.svg)](https://app.codeship.com/projects/290661)
[![Maintainability](https://api.codeclimate.com/v1/badges/d4885e6adb6c7d2127d1/maintainability)](https://codeclimate.com/repos/5af4aa870297440293002282/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/d4885e6adb6c7d2127d1/test_coverage)](https://codeclimate.com/repos/5af4aa870297440293002282/test_coverage)

### Dependencies

**Mission critical:** User API must be up and running for logistic-api to work.

### Requirements

- Ruby 2.6.8
- Post GIS 9+
- Redi s

### Setup environment!

#### Ubuntu

```bash
sudo apt install -y postgresql-10-postgis-2.4
rbenv install
./bin/setup
```

#### MacOS 

- TODO

### Test suite

This project runs their specs with Rspec:

```bash
- bundle exec rspec
```

### Seeds & Database

In order to clone a branched DB with PostgreSQL:
`pg_dump -U [username] -h [hostname] [original_db_to_clone] | psql -U [user] -d [destination_db]`

You can recreate the db migrations from an non existing-db with:

```bash
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```

Due to an error in rail seeds it is necessary to manually enable created stocks and variants with:

```Bash
$ rails console
$ Variant.update_all(revised_at: Time.zone.now, revised: true)
```
