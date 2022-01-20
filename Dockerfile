FROM openjdk:11
COPY helloworld-2.1.jar .
EXPOSE 8080
CMD ["java", "-jar", "helloworld-2.1.jar"]
