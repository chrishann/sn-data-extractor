# SN Data Extractor

Extracts data (in XML format) from a ServiceNow instance ServiceNow

## Pre-requisites

* Install ruby 2.1.5+
* Install [bundler](http://bundler.io/) (`gem install bundler`)
* Install dependencies (`bundle install`)

## Configuration

There is a config.yml file in the root directory. It is in the following format:

```yaml
instance: demo01
username: admin
password: admin
extracts:
    - table: cmn_schedule
    - table: service_offering
    	query: active=true^EQ
```

`instance`, `username` and `password` are all fairly self-explanitory.

The `extracts` parameter allows one or more tables to be specified, the script will extract data from the table and store it within the `./data` directory.

Each entry in the `extracts` can have the following parameters:

* `table`: The name of the table to extract data from
* `query`: The query that should be applied when extracting data (optional)