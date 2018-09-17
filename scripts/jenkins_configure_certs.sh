#!/usr/bin/env bash


# Configure SSL cert for OpenJDK
# When adding Slack notification plugin, Slack connection may fail because of SSL certs
# This is the issue https://github.com/jenkinsci/slack-plugin/issues/149

# Following commands configures ssl.

__java_cert_file=/etc/ssl/certs/java/cacerts

# Get Slack server certificate
openssl s_client  -connect slack.com:443  < /dev/null 2>/dev/null | openssl x509 -text > slack.crt
# Add it to Java cert keystore
# 'changeit' is default keystore password
echo changeit > keystore_input
echo yes >> keystore_input
cat keystore_input | keytool -keystore ${__java_cert_file} -importcert -alias slack_child -file slack.crt
# create dir and copy certs
mkdir -p /var/lib/.keystore
cp ${__java_cert_file} /var/lib/.keystore/
# Restart Jenkins
systemctl restart jenkins

