# ======================================================================
# Makefile - builds the sample Java application
#
# This Makefile requires the following packages:
#   make openjdk-14-jdk-headless
# Additional packages are required, depending on the target:
#   test    - junit4
#   install - binutils
#   linux   - fakeroot
# To build with OpenJDK 15 on Ubuntu 20.10, run:
#   $ make package JAVA_HOME=/usr/lib/jvm/java-15-openjdk-amd64
# The Snapcraft "make" plugin runs this Makefile with:
#   $ make; make install DESTDIR=/root/parts/hello-java/install
# ======================================================================

# JDK and target platform versions
openjdk = 14
release = 11

# Avoids OutOfMemoryError running jlink and jpackage
maxheap = -XX:MaxHeapSize=1g

# Environment variables
JAVA_HOME = /usr/lib/jvm/java-$(openjdk)-openjdk-amd64
JUNIT_JAR = /usr/share/java/junit4.jar
DESTDIR   = dist/$(project)

# Project information
project = hello-java
modname = org.status6.hello
appname = HelloJava
version = 1.0.0

# Package metadata
description = "Sample Java application"
copyright   = "Copyright (C) 2020 John Neffenger"
vendor      = "John Neffenger"
email       = john@status6.com
categories  = "Development;ConsoleOnly;"
section     = java
revision    = 1

# Commands
JAVAC = $(JAVA_HOME)/bin/javac
JAR   = $(JAVA_HOME)/bin/jar
JAVA  = $(JAVA_HOME)/bin/java
JDOC  = $(JAVA_HOME)/bin/javadoc
JLINK = $(JAVA_HOME)/bin/jlink
JPKG  = $(JAVA_HOME)/bin/jpackage

# Command options
JAVAC_OPT = --release $(release)
JAR_OPT   = --create
JDOC_OPT  = -quiet --source-path src/main/java

JLINK_OPT = --strip-debug --no-header-files --no-man-pages \
            --add-modules $(modname) --launcher $(appname)=$(modname)

JPKG_OPT  = --module $(modname) --name $(appname) \
            --app-version $(version) --description $(description) \
            --copyright $(copyright) --vendor $(vendor) \
            --icon images/icon.png --license-file LICENSE

# Debian package options
debian = --type deb --linux-package-name $(project) \
    --linux-deb-maintainer $(email) --linux-menu-group $(categories) \
    --linux-app-category $(section) --linux-app-release $(revision)

# Java source files
sources := $(shell find src -name "*.java")

# Hardware architecture
arch := $(shell dpkg --print-architecture)

# Root source files for the Java compiler
root_info = src/main/java/module-info.java
root_main = src/main/java/org/status6/hello/HelloJava.java
root_test = src/test/java/org/status6/hello/HelloJavaTest.java
list_main = $(root_info) $(root_main)
list_test = $(root_test) $(root_main)

# Main and test classes
main_class = org.status6.hello.HelloJava
test_class = org.status6.hello.HelloJavaTest
main_junit = org.junit.runner.JUnitCore

# Application packages
package_jar = dist/$(project)-$(version).jar
package_deb = dist/$(project)_$(version)-$(revision)_$(arch).deb
package_tar = dist/$(project)-$(version)-linux-$(arch).tar.gz

# Other artifacts
javadoc_jar = dist/$(project)-$(version)-javadoc.jar
sources_jar = dist/$(project)-$(version)-sources.jar
testing_jar = dist/$(project)-$(version)-testing.jar

# Options for the modular executable JAR file
modular_jar = --main-class $(main_class) --module-version $(version)

# Classpath options
cp_junit = --class-path $(JUNIT_JAR)
cp_tests = --class-path $(testing_jar):$(JUNIT_JAR)

# ======================================================================
# Pattern Rules
# ======================================================================

%.sha256: %
	cd $(@D); sha256sum $(<F) > $(@F)

# ======================================================================
# Explicit Rules
# ======================================================================

.PHONY: all package install linux run test clean

all: $(package_jar)

package: $(package_jar) $(javadoc_jar) $(sources_jar)

install: $(package_jar) $(DESTDIR)

linux: $(package_deb).sha256 $(package_tar).sha256

dist:
	mkdir -p $@

$(package_jar): $(sources) | dist
	$(JAVAC) $(JAVAC_OPT) -d build/classes $(list_main)
	$(JAR) $(JAR_OPT) --file $@ $(modular_jar) -C build/classes .

$(javadoc_jar): $(sources) | dist
	$(JDOC) $(JDOC_OPT) -d build/apidocs $(modname)
	$(JAR) $(JAR_OPT) --file $@ -C build/apidocs .

$(sources_jar): $(sources) | dist
	$(JAR) $(JAR_OPT) --file $@ -C src/main/java .

$(DESTDIR): export JAVA_TOOL_OPTIONS = $(maxheap)
$(DESTDIR): $(package_jar)
	rm -rf $(DESTDIR)
	$(JLINK) $(JLINK_OPT) --module-path $< --output $@

$(package_deb): export JAVA_TOOL_OPTIONS = $(maxheap)
$(package_deb): $(package_jar)
	$(JPKG) $(JPKG_OPT) $(debian) --module-path $< --dest $(@D)

$(package_tar): $(DESTDIR)
	tar --create --file $@ --gzip -C $(<D) $(<F)

$(testing_jar): $(sources) | dist
	$(JAVAC) $(JAVAC_OPT) -d build/test-classes $(cp_junit) $(list_test)
	$(JAR) $(JAR_OPT) --file $@ -C build/test-classes .

run: $(package_jar)
	$(JAVA) -jar $<

test: $(testing_jar)
	$(JAVA) $(cp_tests) $(main_junit) $(test_class)

clean:
	rm -rf build dist
