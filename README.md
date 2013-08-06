#epiquery

## I don't care, just tell me how to use the thing

   curl [http://query.glgroup.com/test/servername](http://query.glgroup.com/test/servername)

## Important things to remember

* If you're trying to get this to run locally, you probably shouldn't be.
If you're still trying you probably want to see the Environment
( Configuration ) section at the bottom.
* The query service is available externally, currently it's protected by
the Auth Proxy and you'll need to know the password to connect.
* You can cause the service to connect to an arbitrary MySQL or MSSQ
database by combining an existing template with the X-DB-CONNECTION
header. See the DB Override section for more details.
* The service does **nothing** more than help you with rendering a string
that will be sent to the server, executed, and have the response
returned to you in JSON.  Writing good SQL is up to the consumer e.g.
parameterizing your queries.  There are some examples in the
epiquery-templates repository in the test directory.  No magic here is a
feature, it's important to understand how to write queries that perform
well and work as expected.
* No partials.  If you have multiple uses for the same query, it's the
same query.  Otherwise you'll need to write a new one.  This serves
multiple purposes:
    * It keeps the queries obvious and easy to understand.
    * It helps keep the usage of templates limited so that we confine the
surface area for changes.
* The documentation isn't complete, but neither is anything else. Please
read the code and ask questions.

### Description

Epiquery is intended to be a **simple** solution for running queries
against a relational databse (MySQL and MS SQL Server).  In additon
this architecture is to support the centralization of query logic,s
make available simple JSON REST-y interfaces for interacting with
the database to facilitate client-side application development.

Epiquery strives to do one thing and one thing only: generate T-SQL
strings and execute them against the database it's connected to.  This
pushes some of the logic that developers might otherwise ignore into
their perview e.g. parameterization of queries.

### What it does 

Epiquery takes an inbound HTTP request and maps it to an existing
template on disk.  Data from the inbound request is provided to the
template during rendering and the result is sent to the SQL Server to
be executed.  The response from the server is converted into JSON and
returned in the response.

Query string, form items, and headers are provided to the template
during rendering as key value pairs.  It is also possible to provide
JSON data as the body of the request and that will be made available to
the template during rendering as well.

### Querying

#### MySQL
In order to query against the configued MySQL server the path to
the template needs to contain the string 'mysql' (no quotes).  This
string can occur anywhere in the path to the template, including the
file name of the template.

#### MS SQL
MS SQL is the default destination against which queries will be run, so
a path that doesn't contain mysql will end up in a query being executed
against the configured MS SQL server.

#### Development
It's possible to execute an arbitrary query provided on the request.  If the
inbound request contains an element named __template, then the value of
that element will be used as the contents of the template and rendered
as per the normal execution path.  Specifically the value of the __template
element is written into a file under the template directory named based
on the hash of the contents, then the request processing will proceed as 
normal. The default template engine is mustache, however it is possible to
choose alternates using a request element named __template_type

### Environment ( Configuration )
It is possible to configure EpiQuery by using environment variables, as
a convenience the startup of EpiQuery will source a file ~/.epiquery_env
on start to allow setting of configuration values. Below is an example
configuration:

    export EPIQUERY_SQL_SERVER=10.211.55.4
    export EPIQUERY_SQL_PORT=1433
    export EPIQUERY_SQL_USER=GLGROUP_LIVE
    export EPIQUERY_SQL_PASSWORD=GLGROUP_LIVE
    export EPIQUERY_SQL_RO_USER=GLGROUP_LIVE
    export EPIQUERY_SQL_RO_PASSWORD=GLGROUP_LIVE
    export EPIQUERY_MYSQL_SERVER=localhost
    export EPIQUERY_MYSQL_USER=root
    export EPIQUERY_MYSQL_PASSWORD=
    export EPIQUERY_MYSQL_RO_USER=epiquery_ro
    export EPIQUERY_MYSQL_RO_PASSWORD=
    export EPIQUERY_HTTP_PORT=9090

### DB Override
You can override the default database connections by passing a
X-DB-CONNECTION
header on a per request basis. Of course the DB must be accesible from
the epiquery server.

Example:

curl -v -H
'X-DB-CONNECTION:{"userName":"sa","password":"xxx","server":"10.211.55.3","port":"1433"}'
http://query.glgroup.com/test/sysobjects

### AJAX calls to EpiQuery

JQuery CORS example

```javascript
<html>
    <head>
        <script src="http://code.jquery.com/jquery-1.10.1.min.js"></script>
        <script>
            $(function(){
                $.support.cors = true; // for IE
                $.ajax({
                  type: 'GET',
                  url: 'https://query.glgroup.com/glg_offices.mustache',
                  // Note that any content type other than application/x-www-form-urlencoded, multipart/form-data, or text/plain will trigger a CORS pre-flight check (OPTIONS)
                  contentType: 'application/json',
                  xhrFields: {
                    withCredentials: true 
                  },
                  success: function(json) {
                    $('#result').html(json[2].GLG_OFFICE_NAME);
                  }
                });
            });
        </script>
    </head>
    <body>
        <div id="result"></div>
    </body>
</html>
```

jQuery jsonp example

```javascript
<html>
    <head>
        <script src="http://code.jquery.com/jquery-1.10.1.min.js"></script>
        <script>
            $(function(){
                $.ajax({
                    type: 'POST',
                    url: "https://query.glgroup.com/client/getClientContact.mustache",
                    data: { consultId: 1662266 },               
                    contentType: "application/json",
                    dataType: 'jsonp',
                    success: function(json) {   
                       $('#result').html(json[0][0].firstName + " " + json[0][0].lastName);
                    }
                });
            });
        </script>
    </head>
    <body>
        <div id="result"></div>
    </body>
</html>
```
