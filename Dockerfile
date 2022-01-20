FROM openjdk:11
RUN  ***.*.jar .
EXPOSE 8080
CMD ["java", "-jar", "*.jar"]
