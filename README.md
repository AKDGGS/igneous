# Igneous
This is the webapp for the [Alaska Geologic Materials Center](https://dggs.alaska.gov/gmc/)
inventory system. An in-production version of this software can be viewed at
<https://maps.dggs.alaska.gov/gmc/>. It is intended as a single-site
installation, and is being presented here to give other material centers a
starting point and reference for their own efforts. The
[Alaska Division of Geological & Geophysical Surveys](https://dggs.alaska.gov/)
is actively working on the [replacement for this software](https://github.com/AKDGGS/gmcwebapp)
and any external efforts to improve this software should be focused there
instead.

## Getting Started
Igneous requires Java 9+, PostgreSQL 12+, Apache Solr, and Apache Tomcat 8+.

### Building
From the `WEB-INF` directory, edit `build.xml` to point `catalina.home` to
your Tomcat installation directory. Then `ant war` to produce a Java WAR file
for deployment.

### Configuration - PostgreSQL
A database will need to be setup and configured. Required database materials
can be found in the [Granite](https://github.com/AKDGGS/granite) repository.

### Configuration - Tomcat
Igneous expects named resources configured for its database and Solr
connections. Below are examples for Solr, refer to Tomcat's documentation for
configuring a database resource and deploying web applications.

`<Environment type="java.lang.String" name="igneous/solr-url"
              value="http://127.0.0.1:8983/solr/igneous" />
<Environment type="java.lang.String" name="igneous/solr-user"
             value="solr" />
<Environment type="java.lang.String" name="igneous/solr-pass"
             value="password" />`

### Configuration - Solr
An example Solr data configuration can be found in
[WEB-INF/misc/solr-data-config.xml](WEB-INF/misc/solr-data-config.xml). Refer
to Solr's documentation for creating and managing cores.
