# Sensu handler for Elasticsearch

A sensu handler to send events to Elasticsearch.

## Usage

The handler accepts the following command line options:

```
Usage: handler-elasticsearch.rb (options)
    -i, --index <INDEX>              Elasticsearch index (default: sensu)
    -t, --type <TYPE>                Elasticsearch index type (default: handler)
    -u, --url <URL>                  Elasticsearch URL
```

## Installation

```
/opt/sensu/embedded/bin/gem install sensu-handlers-elasticsearch
```

## Author
Matteo Cerutti - <matteo.cerutti@hotmail.co.uk>
