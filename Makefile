# ======================================================================
# Makefile - builds the sample Java applications
# Copyright (C) 2020 John Neffenger
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# This Makefile requires the following packages:
#   $ sudo apt install make openjdk-14-jdk-headless
#   $ sudo apt install junit4 binutils fakeroot
#
# The Snapcraft Make plugin runs this Makefile with:
#   $ make; make install DESTDIR=$SNAPCRAFT_PART_INSTALL
#
# Note: The jpackage tool is available in JDK 14 or later.
# ======================================================================

# OpenJDK version
jdk = 14

# Java release for source code and target platform
rel = 11

# Project information
pkg = org.status6.hello
app = hello-java
ver = 1.0.0

# Package metadata
copyright   = "Copyright (C) 2020 John Neffenger"
description = "Sample Java applications"
vendor      = "John Neffenger"
icon        = snap/gui/$(app).png
license     = LICENSE
email       = john@status6.com
group       = "Development;Building;"
revision    = 1
category    = java

# Launcher command names
cmd_world = HelloWorld
cmd_swing = HelloSwing

# Module names
mod_world = $(pkg).world
mod_swing = $(pkg).swing

# JAR file names
jar_world = hello-world-$(ver).jar
jar_swing = hello-swing-$(ver).jar
jar_tests = hello-tests-$(ver).jar
src_world = hello-world-$(ver)-sources.jar
src_swing = hello-swing-$(ver)-sources.jar
doc_world = hello-world-$(ver)-javadoc.jar
doc_swing = hello-swing-$(ver)-javadoc.jar

# Debian architecture of build machine
arch := $(shell dpkg --print-architecture)

# Package file names
package_tar = $(app)-$(ver)-linux-$(arch).tar.gz
package_deb = $(app)_$(ver)-$(revision)_$(arch).deb

# Overridden by variables from the environment
JAVA_HOME ?= /usr/lib/jvm/java-$(jdk)-openjdk-$(arch)

# Overridden by variables on the Make command line
JUNIT_JAR = /usr/share/java/junit4.jar
DESTDIR   = dist/$(app)

# Commands
JAVA     = $(JAVA_HOME)/bin/java
JAVAC    = $(JAVA_HOME)/bin/javac
JAVADOC  = $(JAVA_HOME)/bin/javadoc
JAR      = $(JAVA_HOME)/bin/jar
JLINK    = $(JAVA_HOME)/bin/jlink
JPACKAGE = $(JAVA_HOME)/bin/jpackage

# Command options
JLINK_OPT = --strip-debug --no-header-files --no-man-pages \
    --add-modules $(mod_world),$(mod_swing) \
    --launcher $(cmd_swing)=$(mod_swing) \
    --launcher $(cmd_world)=$(mod_world)

# The following issue is fixed in JDK 16:
# jpackage is unable to generate working EXE for add-launcher configurations
# https://bugs.openjdk.java.net/browse/JDK-8253426
JPACKAGE_OPT = --name $(cmd_swing) --module $(mod_swing) \
    --add-launcher $(cmd_world)=conf/$(cmd_world).properties \
    --add-modules $(mod_world) --app-version $(ver) \
    --copyright $(copyright) --description $(description) \
    --vendor $(vendor) --icon $(icon) --license-file $(license)

# Debian package options
deb = --type deb --linux-package-name $(app) \
    --linux-deb-maintainer $(email) --linux-menu-group $(group) \
    --linux-app-release $(revision) --linux-app-category $(category)

# Defines a single space character
sp := $(subst ,, )

# Output directories
out = build/classes
doc = build/apidocs
tst = build/testing

# Main JUnit class and test classes
junit = org.junit.runner.JUnitCore
tests = $(pkg).world.HelloTest $(pkg).swing.HelloTest

# Module sources and colon-separated module path of all prerequisites
srcpath = --module-source-path "./*/src/main/java"
modpath = --module-path $(subst $(sp),:,$^)

# Lists all non-module Java source files for testing
srctest = $(shell find $(pkg).*/src -name "*.java" \
            -a ! -name module-info.java)

# Lists prerequisites in pattern rules using secondary expansion
srcmain = $$(shell find $(pkg).%/src/main -name "*.java")

# Executable JAR options in pattern rules
execjar = --main-class $(pkg).$*.Hello --module-version $(ver)

# ======================================================================
# Pattern Rules
# ======================================================================

.SECONDEXPANSION:

dist/hello-%-$(ver).jar: $(srcmain) | dist
	$(JAVAC) --release $(rel) -d $(out) $(srcpath) --module $(pkg).$*
	$(JAR) --create --file $@ $(execjar) -C $(out)/$(pkg).$* .

dist/hello-%-$(ver)-javadoc.jar: $(srcmain) | dist
	$(JAVADOC) -quiet -d $(doc)/$(pkg).$* $(srcpath) --module $(pkg).$*
	$(JAR) --create --file $@ -C $(doc)/$(pkg).$* .

dist/hello-%-$(ver)-sources.jar: $(srcmain) | dist
	$(JAR) --create --file $@ -C $(pkg).$*/src/main/java .

dist/%.sha256: dist/%
	cd $(@D); sha256sum $(<F) > $(@F)

run-%: dist/hello-%-$(ver).jar
	$(JAVA) -jar $<

# ======================================================================
# Explicit Rules
# ======================================================================

.PHONY: all javadoc sources package install linux run test clean

all: dist/$(jar_world) dist/$(jar_swing)

javadoc: dist/$(doc_world) dist/$(doc_swing)

sources: dist/$(src_world) dist/$(src_swing)

package: all javadoc sources

install: $(DESTDIR)

linux: dist/$(package_tar).sha256 dist/$(package_deb).sha256

run: run-world run-swing

dist:
	mkdir -p $@

# The strip command works around the following issue, fixed in JDK 13:
# Create a jlink plugin for stripping debug info symbols from native libraries
# https://bugs.openjdk.java.net/browse/JDK-8214796
$(DESTDIR): dist/$(jar_world) dist/$(jar_swing)
	rm -rf $(DESTDIR)
	$(JLINK) $(JLINK_OPT) $(modpath) --output $@
	strip --strip-debug $(DESTDIR)/lib/server/libjvm.so

dist/$(package_tar): $(DESTDIR)
	tar --create --file $@ --gzip -C $(<D) $(<F)

dist/$(package_deb): dist/$(jar_world) dist/$(jar_swing)
	$(JPACKAGE) $(JPACKAGE_OPT) $(deb) $(modpath) --dest $(@D)

dist/$(jar_tests): $(srctest) | dist
	$(JAVAC) --release $(rel) -d $(tst) --class-path $(JUNIT_JAR) $^
	$(JAR) --create --file $@ -C $(tst) .

test: dist/$(jar_tests)
	$(JAVA) --class-path $<:$(JUNIT_JAR) $(junit) $(tests)

clean:
	rm -rf build dist
