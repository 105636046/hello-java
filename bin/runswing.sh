#!/bin/bash
# Runs the Helloswing app
trap exit INT TERM
set -o errexit
set -o xtrace

java -cp dist/hello-swing-1.0.0.jar org.status6.hello.swing.Hello
java -jar dist/hello-swing-1.0.0.jar
java -p dist/hello-swing-1.0.0.jar -m org.status6.hello.swing
java org.status6.hello.swing/src/main/java/org/status6/hello/swing/Hello.java
~/opt/hello-java/bin/HelloSwing
/opt/hello-java/bin/HelloSwing
hello-java
