#epiquery

## What's new?

* [Response Transformations](#response-transformations) - Now you can
  manipulate the response that epiquery will return!
 

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
In order to query against the configured MySQL server the path to
the template needs to contain the string 'mysql' (no quotes).  This
string can occur anywhere in the path to the template, including the
file name of the template.

#### MS SQL
MS SQL is the default destination against which queries will be run, so
a path that doesn't contain mysql will end up in a query being executed
against the configured MS SQL server.

#### MS SQL Server Analysis Service (SSAS)
In order to query against the configured data cube (multi-dimensional database) the path to
the template needs to contain the string 'mdx' (no quotes).  This
string can occur anywhere in the path to the template, including the
file name of the template.

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
on start to allow setting of configuration values. 

  Running Epiquery Locally
    If you want to setup a dev env, copy the etc/environment.dev file to ~/.epiquery_env". 
    Run "sh start"

  Below is an example configuration:

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

	export EPIQUERY_MDX_SERVER=glgdb503.glgroup.com
	export EPIQUERY_MDX_USER=
	export EPIQUERY_MDX_PASSWORD=
	export EPIQUERY_MDX_CATALOG=GLG_DW_PROJECTS
	export EPIQUERY_MDX_URL=http://glgdb503.glgroup.com/olapanon/msmdpump.dll

    export EPIQUERY_HTTP_PORT=9090

### DB Override
You can override the default database connections by passing a
X-DB-CONNECTION
header on a per request basis. Of course the DB must be accesible from
the epiquery server.

Example:

curl -v -H
'X-DB-CONNECTION:{"userName":"sa","password":"xxx","server":"10.211.55.3","options":{"port":"1433"}}'
http://query.glgroup.com/test/sysobjects

### AJAX calls to EpiQuery

JQuery CORS example

```html
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
```html

JQuery CORS POST example
```html
<html>
    <head>
        <script src="http://code.jquery.com/jquery-1.10.1.min.js"></script>
        <script>
            $(function(){
                $.support.cors = true; // for IE
                $.ajax({
                  type: 'POST',
                  url: "https://query.glgroup.com/client/getClientContact.mustache",                  
                  dataType: 'json',
                  data: { consultId: 1662266 },               
                  xhrFields: {
                    withCredentials: true 
                  },
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

jQuery jsonp example

```html
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

***
### MDX Queries

N.B. EpiQuery has only been test against Microsoft SSAS data cubes. We have not tested against any other XMLA providers. Similarly, we have not tested queries with more than 2 axes (columns and rows).

######JQuery example

	<html>
	    <head>
	        <script src="http://code.jquery.com/jquery-1.10.1.min.js"></script>
			<script>
				var j$ = jQuery.noConflict();
			
				function exec_mdx_query() {
					j$.support.cors = true; // for IE
					j$.ajax({
						type: 'GET',
						url: "https://query.glgroup.com/mdx/my_mdx_query.mustache",
						dataType: 'json',
						data: { my_mdx_query_param: 123 },
						crossDomain: true,
						xhrFields: {
							withCredentials: true
						},
						success: function(json) {
							$('#result').html(json);
						},
						error: function (xhr, ajaxOptions, thrownError) {
							$('#result').html(xhr.responseJSON.message);
						}					
					});
				}
			</script>
	    </head>
	    <body>
	        <div id="result"></div>
	    </body>
	</html>

######OLAP Database Override

You can override the configured database by setting the following headers in your request:

- MDX_SERVER (*specifies the data source*)
- MDX_URL (*specifies the XMLA web service*)
- MDX_CATALOG (*specifies the particular data cube within the data source*)

Note, if you are overriding the default OLAP data source, then both MDX_SERVER and MDX_URL are required to connect to a particular OLAP datasource. 

For example, 

	<script>
		var j$ = jQuery.noConflict();
	
		function exec_mdx_query() {
			j$.support.cors = true; // for IE
			j$.ajax({
				type: 'GET',
				beforeSend: function (request)
				{
				  request.setRequestHeader("MDX_CATALOG", 'MYDBCAT');
				  request.setRequestHeader("MDX_URL", 'http://MYDB.com/');
				  request.setRequestHeader("MDX_SERVER", 'MYDBSERVER');
				},
				url: "https://query.glgroup.com/mdx/my_mdx_query.mustache",
				dataType: 'json',
				data: { my_mdx_query_param: 123 },
				crossDomain: true,
				xhrFields: {
					withCredentials: true
				},
				success: function(json) {
					$('#result').html(json);
				},
				error: function (xhr, ajaxOptions, thrownError) {
					$('#result').html(xhr.responseJSON.message);
				}					
			});
		}
	</script>

######Results

EpiQuery returns query results as JSON.  The JSON has this form:


- JSON
	- Axes
		- 0
			- positions
			- hierarchies
		- 1
			- positions
			- hierarchies
		- N 
			- positions
			- hierarchies 	 
	- Cells
		- 0
		- 1...
		- M
	   

For example, consider the following query to list the number of GTCs per contact per month in 2013 for the 3M Canada Company account.

	SELECT 
	NON EMPTY { 
			[Date].[Calendar].[Month].ALLMEMBERS 
		} ON COLUMNS, 
	 NON EMPTY { 
			[Client].[Client].ALLMEMBERS * [Contact].[Contact].ALLMEMBERS * [MEASURES].[GTCs] 
		} ON ROWS 
	 FROM ( 
		SELECT ( { [Date].[Calendar].[Year].&[2013-01-01T00:00:00] } ) ON COLUMNS 
		FROM ( 
			SELECT ( { [Client].[All].[3M Canada Company] } ) ON COLUMNS 
			FROM [GLG Projects])) 
			WHERE ( [Date].[Month].CurrentMember )

If you run this in SQL Server Managerment Studio it would format the output like this:

```
<table>
<tr>
<tr><td></td><td></td><td></td><td>March 2013</td><td>April 2013</td><td>May 2013</td><td>June 2013</td></tr>
<tr><td>3M Canada Company</td><td>Cheryl Haug</td><td>GTCs</td><td>(null)</td><td>2</td><td>(null)</td><td>(null)</td> </tr>
<tr><td>3M Canada Company</td><td>Christian Blyth</td><td>GTCs</td><td>8</td><td>(null)</td><td>(null)</td><td>(null)</td> </tr>
<tr><td>3M Canada Company</td><td>Deb LaBelle</td><td>GTCs</td><td>(null)</td><td>(null)</td><td>(null)</td><td>1</td></tr>
<tr><td>3M Canada Company</td><td>Jonathan Jones</td><td>GTCs</td><td>(null)</td><td>1</td><td>(null)</td><td>(null)</td> </tr>
<tr><td>3M Canada Company</td><td>Laurie Sproul</td><td>GTCs</td><td>5</td><td>(null)</td><td>2</td><td>(null)</td> </tr>
<tr><td>3M Canada Company</td><td>Marcelo Mellicovsky</td><td>GTCs</td><td>(null)</td><td>2</td><td>(null)</td><td>(null)</td> </tr>
<tr><td>3M Canada Company</td><td>Melissa Kenyon</td><td>GTCs</td><td>8</td><td>(null)</td><td>(null)</td><td>(null)</td> </tr>
</table>
```

#########Column Headings

In the JSON output, column headings are listed in the Axis[0] `positions` collection. The first 2 column headings are shown below: 

	"axes": [
	    {
	      "positions": [
	        {
	          "[Date].[Calendar]": {
	            "index": 0,
	            "hierarchy": "[Date].[Calendar]",
	            "UName": "[Date].[Calendar].[Month].&[2013-03-01T00:00:00]",
	            "Caption": "March 2013",
	            "LName": "[Date].[Calendar].[Month]",
	            "LNum": 2,
	            "DisplayInfo": 31
	          }
	        },
	        {
	          "[Date].[Calendar]": {
	            "index": 0,
	            "hierarchy": "[Date].[Calendar]",
	            "UName": "[Date].[Calendar].[Month].&[2013-04-01T00:00:00]",
	            "Caption": "April 2013",
	            "LName": "[Date].[Calendar].[Month]",
	            "LNum": 2,
	            "DisplayInfo": 131102
	          }
	        },
			ETC.

#########Row Headings

Row headings are listed in the Axis[1] `positions` collection. The first row and part of the next are shown below:

	,
	{
      "positions": [
        {
          "[Client]": {
            "index": 0,
            "hierarchy": "[Client]",
            "UName": "[Client].[All].[3M Canada Company]",
            "Caption": "3M Canada Company",
            "LName": "[Client].[Client]",
            "LNum": 1,
            "DisplayInfo": 0
          },
          "[Contact]": {
            "index": 1,
            "hierarchy": "[Contact]",
            "UName": "[Contact].[All].[Cheryl Haug]",
            "Caption": "Cheryl Haug",
            "LName": "[Contact].[Contact]",
            "LNum": 1,
            "DisplayInfo": 0
          },
          "[Measures]": {
            "index": 2,
            "hierarchy": "[Measures]",
            "UName": "[Measures].[GTCs]",
            "Caption": "GTCs",
            "LName": "[Measures].[MeasuresLevel]",
            "LNum": 0,
            "DisplayInfo": 0
          }
        },
        {
          "[Client]": {
            "index": 0,
            "hierarchy": "[Client]",
            "UName": "[Client].[All].[3M Canada Company]",
            "Caption": "3M Canada Company",
            "LName": "[Client].[Client]",
            "LNum": 1,
            "DisplayInfo": 131072
          },
         },
         ETC.

The values for the individual cells--the intersections of the columns and rows--are in the `Cells` array. They run left to right, top to bottom. Here is the first row of cells and the first cell of the second row:

	"cells": [
    {
      "Value": null,
      "FmtValue": null,
      "FormatString": null,
      "ordinal": 0
    },
    {
      "Value": 2,
      "FmtValue": "2",
      "ordinal": 1
    },
    {
      "Value": null,
      "FmtValue": null,
      "FormatString": null,
      "ordinal": 2
    },
    {
      "Value": null,
      "FmtValue": null,
      "FormatString": null,
      "ordinal": 3
    },
    {
      "Value": 8,
      "FmtValue": "8",
      "ordinal": 4
    },
    ETC.

#### Response Transformations

Response transforms are created by placing a node module (a file) in the 
`response_transforms` directory of the template repository. Epiquery will
load the file via `require`. The file should export a single function.
Epiquery will pass that function the response object.

For example, with no filter:

    var o = run_the_query(); 
    respond_with_string(JSON.stringify(o));

With a filter:

    var o = run_the_query(); 
    o = response_filter(o);
    respond_with_string(JSON.stringify(o));

Transforms can be written either in javascript or coffeescript, in the case of
a coffescript based transform the file must end in '.coffee', while javascript
files can end in '.js' or have no extension (theory: convenience).

A transform module must export a single function. The function will be given the
response object and may return anything as output, including an object not related
to the input. epiquery will call `JSON.stringify` on the output and return it as the response.

Here's a simple example of a transform that doesn't change the response but logs 
it so you can check it out. This file would be put in 
`<template repo>/response_transform/log`.

    function logit(o){
      console.log("log filter was run number 4");
      console.log("*************************************************************");
      console.log(JSON.stringify(o, null, 2));
      console.log("*************************************************************");
      return o
    }
    module.exports = logit

You can invoke this transform by adding a querystring paramater called `transform`
with the path of the file relative to the `<template repo>/response_transform` 
directory.

    curl 'http://localhost:9090/test/multiple_rows_multiple_results.mustache?transform=log'

The result would be that you find the following in the stdout of the epiquery server

    log filter was run number 4
    *************************************************************
    [
      [
        {
          "id": 1,
          "name": "pants"
        },
        {
          "id": 2,
          "name": "pants"
        }
      ],
      [
        {
          "id": 1,
          "name": "pants2"
        },
        {
          "id": 2,
          "name": "pants2"
        }
      ]
    ]
    *************************************************************
