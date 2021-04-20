FROM 723692602888.dkr.ecr.eu-north-1.amazonaws.com/wildfly14-cloudhsm-jre8:14.0.1.4

# Switch user to root
USER root

# Install dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y python-boto

# Copy wildfly configuration and modify permissions
COPY jenkins-files/planetway/artifacts/wildfly/standalone.xml ${WILDFLY_HOME}/standalone/configuration/standalone.xml
RUN chmod 0600 ${WILDFLY_HOME}/standalone/configuration/standalone.xml \
    && chown apps:0 ${WILDFLY_HOME}/standalone/configuration/standalone.xml

# Set JAVA_OPTS
ENV JAVA_OPTS="-Xms2048m -Xmx2048m -XX:MetaspaceSize=192M -XX:MaxMetaspaceSize=2048m -Djava.net.preferIPv4Stack=true"

# Set environment variable for EJBCA
ENV EJBCA_HOME=/opt/ejbca

# Create EJBCA home directory, copy build and configuration artifacts
COPY bin ${EJBCA_HOME}/bin
COPY dist ${EJBCA_HOME}/dist
COPY doc ${EJBCA_HOME}/doc
COPY src ${EJBCA_HOME}/src
COPY jenkins-files/planetway/artifacts/clientToolBox/log4j.xml $EJBCA_HOME/dist/clientToolBox/properties/log4j.xml
COPY jenkins-files/planetway/artifacts/ejbca-ejb-cli/log4j2.xml $EJBCA_HOME/dist/ejbca-ejb-cli/log4j2.xml

# Set permissions and copy ejbca.ear to Wildfly deployments directory
RUN chmod +x ${EJBCA_HOME}/bin/ejbca.sh \
    && chown -R apps:0 ${EJBCA_HOME}/dist \
    && cp ${EJBCA_HOME}/dist/ejbca.ear ${WILDFLY_HOME}/standalone/deployments/ejbca.ear

# Copy tools and set execution privileges
ADD jenkins-files/planetway/artifacts/tools /opt/tools
RUN chmod +x /opt/tools/run.sh /opt/tools/init.sh

# Create p12 directory and set permissions
RUN mkdir -p ${EJBCA_HOME}/p12 \
    && chown apps ${EJBCA_HOME}/p12

# Create persistent_datastore and add privileges
RUN mkdir -p /opt/persistent_datastore \
    && chown apps /opt/persistent_datastore

# Switch user to apps
USER apps

# Update LD_LIBRARY_PATH to include CloudHSM libraries
ENV LD_LIBRARY_PATH /opt/cloudhsm/lib

# Set the working directory to /opt
WORKDIR /opt/

# Expose http, https and https-priv
EXPOSE 8080 8442 8443

#Execute run.sh
CMD ["/opt/tools/run.sh"]
