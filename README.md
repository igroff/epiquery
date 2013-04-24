#epiquery

## I don't care, just tell me how to start the thing

Epiquery doesn't run on windows, at all.  Don't try, just deal.  Getting
it running on Vagrant (Virtual Box) should be straight forward.  First
you'll need to make sure you have an appropriate Vagrant box installed
(e.g. glgub11-10). 

### configuration

It's configured out of the box to do things in a somewhat sensible
manner.  However you'll probably at least want to change some of the SQL
config.  To configure what MS SQL server Epiquery connects to you can
set the following environment variables (shown with their defaults).


#### sql server configuration
EPIQUERY_SQL_SERVER_PORT				1433
EPIQUERY_SQL_SERVER							localhost
EPIQUERY_SQL_USER								GLGROUP_LIVE
EPIQUERY_SQL_PASSWORD						GLGROUP_LIVE
EPIQUERY_SQL_RO_USER						GLGROUP_LIVE_RO
EPIQUERY_SQL_RO_PASSWORD				GLGROUP_LIVE_RO_PASSWORD

### mysql server configuration
EPIQUERY_MYSQL_SERVER 					localhost
EPIQUERY_MYSQL_USER 						root
EPIQUERY_MYSQL_PASSWORD					"" - defaults to not set, no password
EPIQUERY_MYSQL_RO_USER 					epiquery_ro
EPIQUERY_MYSQL_RO_PASSWORD			"" - defaults to not set, no password

### epiquery server configuration
EPIQUERY_TEMPLATE_DIRECTORY 						-- must be specified to start
EPIQUERY_TEMPLATE_REPOSITORY    				-- must be specified to start
EPIQUERY_TEMPLATE_UPDATE_INTERVAL				60000
EPIQUERY_HTTP_PORT											9090

The template update interval is the period (in seconds) at which the
templates will be checked for updates.  When running the system checks
the provided template repository for updates, and if any are availble
pulls them down on the update interval.

As a convenience the startup process for eqiquery will source a file
called .epiquery_env if such a file exists in the home directory of the
user starting Epiquery (i.e. ~/.epiquery_env) to facilitate setting some
of these variables.

Then, from the root of the epiquery source tree you
can:

- vagrant up
- vagrant ssh
- cd vagrant
- make start

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

### querying

### MySQL
In order to query against the configued MySQL server the path to
the tempalte needs to contain the string 'mysql' (no quotes).  This
string can occur anywhere in the path to the template, including the
file name of the template.

#### MS SQL
MS SQL is the default destination against which queries will be run, so
a path that doesn't contain mysql will end up in a query being executed
against the configured MS SQL server.

#### Development
It's possible to execute an arbitrary provided on the request.  If the
inbound request contains an element named __template, then the value of
that element will be used as the contents of the template and rendered
as per the normal execution path.  Specifically the value of the __template
element is written into a file under the template directory named based
on the hash of the contents, then the request processing will proceed as 
normal. The default template engine is mustache, however it is possible to
choose alternates using a request element named __template_type


