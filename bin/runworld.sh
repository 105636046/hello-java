#!/bin/bash
# Runs the HelloWorld app
trap exit INT TERM
set -o errexit
set -o xtrace

java -cp dist/hello-world-1.0.0.jar org.status6.hello.world.Hello
java -jar dist/hello-world-1.0.0.jar
java -p dist/hello-world-1.0.0.jar -m org.status6.hello.world
java org.status6.hello.world/src/main/java/org/status6/hello/world/Hello.java
~/opt/hello-java/bin/HelloWorld
/opt/hello-java/bin/HelloWorld
hello-java.console
