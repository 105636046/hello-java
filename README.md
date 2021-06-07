# ![Duke, the Java mascot, waving](images/icon.png) Hello Java!

This project is my template for building and packaging Java applications. It follows the conventions of Apache Maven for its directory structure and includes two sample applications that print "Hello World!" to standard output:

* HelloWorld - a Java console application with a command-line interface
* HelloSwing - a Java Swing application with a graphical user interface

The files in this project let you:

* open the project in an integrated development environment (IDE),
* create an executable Java archive (JAR) of each application,
* package the API documentation and source code as JAR files, and
* test and run the applications.

In addition to the standard JAR artifacts, you can also create packages for Linux that include a custom run-time image. The table below shows the package size and installed size for each type of package. The Snap package remains the same size when installed because the package file is mounted as a compressed read-only file system instead of being extracted like the others.

| Type    | Package (MB) | Installed (MB) |
| ------- |:------------:|:--------------:|
| Archive | 25           | 75             |
| Debian  | 18           | 84             |
| Snap    | 25           | 25             |

Furthermore, on Debian-based distributions like Ubuntu, you can build all of these artifacts locally using only the trusted software from your system's package repositories.

## Building

This project supports the following build automation tools:

* [Apache Maven](https://maven.apache.org) - runs *online* with Maven Central or *offline* with a local Debian repo
* [GNU Make](https://www.gnu.org/software/make/) - requires only the Java Development Kit (JDK)
* [Snapcraft](https://snapcraft.io/build) - builds a self-contained application for any Linux distribution

The `package` phase of Maven creates the following JAR files, where *x.y.z* is the version string:

* Module org.status6.hello.world
    * target/hello-world-*x.y.z*.jar - Java application
    * target/hello-world-*x.y.z*-javadoc.jar - API documentation
    * target/hello-world-*x.y.z*-sources.jar - Source code
* Module org.status6.hello.swing
    * target/hello-swing-*x.y.z*.jar - Java application
    * target/hello-swing-*x.y.z*-javadoc.jar - API documentation
    * target/hello-swing-*x.y.z*-sources.jar - Source code

The `package` target of the Makefile creates the same JAR files in the `dist` directory. The `linux` target, along with the `install` target run by Snapcraft, builds the following Linux packages:

* dist/hello-java-*x.y.z*-linux-amd64.tar.gz - Compressed archive
* dist/hello-java_*x.y.z*-1_amd64.deb - Debian package
* hello-java_*x.y.z*_amd64.snap - Snap package

Maven can run on any system, but the Makefile is configured by default for Ubuntu. Whether you're running Windows, macOS, or Linux, you can use [Multipass](https://multipass.run) to build the project in an Ubuntu virtual machine (VM). For example, the following command will launch the Multipass [primary instance](https://multipass.run/docs/primary-instance) with 2 processors, 4 GiB of RAM, and Ubuntu 20.04 LTS (Focal Fossa):

```console
$ multipass launch --name primary --cpus 2 --mem 4G focal
```

Run the build commands from the directory where you cloned this repository:

```console
$ git clone https://github.com/jgneff/hello-java.git
$ cd hello-java
$ mvn clean package
```

### Apache Maven

The Maven [Project Object Model](pom.xml) lets you build the project with an IDE or from the command line with:

```console
$ sudo apt install maven
$ export JAVA_HOME=/usr/lib/jvm/default-java
$ mvn clean package
```

**Note:** Maven 3.6.3-1 in Ubuntu 20.04 LTS [fails to run with OpenJDK 16](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=980467). The error is fixed in Maven package version 3.6.3-2. To work around the problem, either run Maven with the Ubuntu default of OpenJDK 11, as shown above, or download the [latest version of Maven](https://maven.apache.org/download.cgi) directly from Apache.

By default, the `mvn` command runs the build in *online* mode and downloads the required plugins and dependencies from the Maven Central Repository. On Debian-based systems such as Ubuntu, you can run the build in *offline* mode using the local repository of plugins and dependencies built by your Linux distribution.

To run the build locally, install the Maven Debian Helper and the Maven plugins for creating the Javadoc and source archives:

```console
$ sudo apt install maven-debian-helper
$ sudo apt install libmaven-javadoc-plugin-java
$ sudo apt install libmaven-source-plugin-java
```

With those packages installed, you can build offline using only the local Debian repository:

```console
$ mvn -s /etc/maven/settings-debian.xml -P debian clean package
```

Combine the Debian settings and the `debian` profile activation by creating the file `~/.m2/debian.xml` with the following content:

```XML
<settings>
    <!-- Switches Maven to offline mode and uses the local Debian repo -->
    <localRepository>/usr/share/maven-repo</localRepository>
    <offline>true</offline>
    <activeProfiles>
        <activeProfile>debian</activeProfile>
    </activeProfiles>
</settings>
```

Create a Bash alias in `~/.bash_aliases` that uses the `debian.xml` Maven settings:

```bash
alias dmvn='mvn -s ~/.m2/debian.xml'
```

Then you can run `mvn` for online mode using the Maven Central repository and `dmvn` for offline mode using the local Debian repository.

### GNU Make

The [Makefile](Makefile) builds the same JAR files as Maven, but it does so using only the tools that come with the Java Development Kit. You can install GNU Make and OpenJDK 16 on Debian-based distributions with the commands:

```console
$ sudo apt install make openjdk-16-jdk
```

To run all of the Makefile targets, you'll also need the JUnit testing framework and two extra packages for building the compressed archive and Debian package:

```console
$ sudo apt install junit4 binutils fakeroot
```

Run `make` with the targets shown below to build the JAR files into the `dist` directory and run the unit test cases:

```console
$ make clean package test
```

The `run` target runs each application from its executable JAR file:

```console
$ make run
```

The Makefile can also package the project as a self-contained application in the following formats:

* compressed archive for extracting to any location,
* Debian package for installing into `/opt` on Debian-based systems, and
* Snap package for uploading to the [Snap Store](https://snapcraft.io/store).

The `linux` target builds the compressed archive and Debian package for Linux:

```console
$ make linux
```

### Snapcraft

The [snapcraft.yaml](snap/snapcraft.yaml) file defines the build for Snapcraft. Run the following commands to install Snapcraft, change to the repository directory, and build the Snap package:

```console
$ sudo snap install snapcraft
$ cd hello-java
$ make clean
$ snapcraft
```

Snapcraft launches a new Multipass VM to ensure a clean and isolated build environment. The VM is named `snapcraft-hello-java` and runs Ubuntu 20.04 LTS (Focal Fossa). The project's directory on the host system is mounted as `/root/project` in the guest VM, so any changes you make on the host are seen immediately in the guest, and vice versa.

**Note:** If you run the initial `snapcraft` command itself inside a VM, your system will need *nested VM* functionality. See the [Build Options](https://snapcraft.io/docs/build-options) page for alternatives, such as running a remote build or using an LXD container.

If the build fails, you can run the command again with the `--debug` option to remain in the VM after the error:

```console
$ snapcraft -d
```

From within the VM, you can then clean the Snapcraft part and try again:

```console
# snapcraft clean app
Cleaning pull step (and all subsequent steps) for app
# snapcraft
```

The Snapcraft [*make* plugin](https://snapcraft.io/docs/make-plugin) uses the same [Makefile](Makefile) as before, but it runs GNU Make in the guest VM. The plugin runs the commands `make` and `make install`, as shown below:

```console
# snapcraft
  ...
Building app
+ snapcraftctl build
+ make -j4
  ...
+ make -j4 install DESTDIR=/root/parts/app/install
  ...
Snapping...
Snapped hello-java_1.0.0_amd64.snap
```

When the build completes, you'll find the Snap package in the project's root directory, along with the build log file if you ran the build remotely.

## Running

After building the executable JAR files and installing the Linux packages, you can run the applications in all of the following ways:

1. as a class file,
2. as the main class in a JAR file,
3. as the main class in a module,
4. as a single source-file program,
5. from the compressed archive extracted into `~/opt`,
6. from the installed Debian package, and
7. from the installed Snap package.

Each of these methods is shown below for the two applications.

### HelloWorld

The HelloWorld application prints "Hello World!" to standard output.

```console
$ java -cp dist/hello-world-1.0.0.jar org.status6.hello.world.Hello
Hello World!
$ java -jar dist/hello-world-1.0.0.jar
Hello World!
$ java -p dist/hello-world-1.0.0.jar -m org.status6.hello.world
Hello World!
$ java org.status6.hello.world/src/main/java/org/status6/hello/world/Hello.java
Hello World!
$ ~/opt/hello-java/bin/HelloWorld
Hello World!
$ /opt/hello-java/bin/HelloWorld
Hello World!
$ hello-java.console
Hello World!
```

### HelloSwing

The HelloSwing application prints "Hello World!" to standard output when its button is pressed.

```console
$ java -cp dist/hello-swing-1.0.0.jar org.status6.hello.swing.Hello
Hello World!
$ java -jar dist/hello-swing-1.0.0.jar
Hello World!
$ java -p dist/hello-swing-1.0.0.jar -m org.status6.hello.swing
Hello World!
$ java org.status6.hello.swing/src/main/java/org/status6/hello/swing/Hello.java
Hello World!
$ ~/opt/hello-java/bin/HelloSwing
Hello World!
$ /opt/hello-java/bin/HelloSwing
Hello World!
$ hello-java
Hello World!
```
