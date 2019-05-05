# Pull base image 
From tomcat:8-jre8 

# Maintainer 
MAINTAINER "makaveli_29_@hotmail.com" 
 COPY ./RESTExample.war /usr/local/tomcat/webapps
