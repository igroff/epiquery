#epiquery


### description
Epiquery is intended to be a **simple** solution for running queries
against a relational databse (MySQL and MS SQL Server).  In additon
this architecture is to support the centralization of query logic,s
make available simple JSON REST-y interfaces for interacting with
the database to facilitate client-side application development.

Epiquery strives to do one thing and one thing only: generate T-SQL
strings and execute them against the database it's connected to.  This
pushes some of the logic that developers might otherwise ignore into
their perview e.g. parameterization of queries.


### what it does (technically)

Epiquery takes an inbound HTTP request and maps it to an existing
template on disk.  Data from the inbound request is provided to the
template during rendering and the result is sent to the SQL Server to
be executed.  The response from the server is converted into JSON and
returned in the response.

Query string, form items, and headers are provided to the template
during rendering as key value pairs.  It is also possible to provide
JSON data as the body of the request and that will be made available to
the template during rendering as well.

### usage

In order to query against the configued MySQL server the path to
the tempalte needs to contain the string 'mysql' (no quotes).  This
string can occur anywhere in the path to the template, including the
file name of the template.

MS SQL is the default destination against which queries will be run, so
a path that doesn't contain mysql will end up in a query being executed
against the configured MS SQL server.

