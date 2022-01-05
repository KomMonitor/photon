# ---- Base Maven build ----
FROM maven:3.5-jdk-8-alpine as build
WORKDIR /app

# Cache dependencies as long as the POM changes
COPY ./pom.xml ./photon/pom.xml
RUN mvn -f ./photon/pom.xml dependency:go-offline --fail-never

# Copy source files for build
COPY . /app/photon/

# Run the Maven build
RUN mvn -f ./photon/pom.xml clean install -DskipTests

# ---- Run the application ----
FROM openjdk:alpine
WORKDIR /app

# Copy from the base build image
COPY --from=build app/photon/target/photon-0.3.5.jar /app/photon-app.jar

# set ENV variables
ENV NOMINATIM_DB_HOST=localhost
ENV NOMINATIM_DB_PORT=5432
ENV NOMINATIM_DB_NAME=nominatim
ENV NOMINATIM_DB_USER=nominatim
ENV NOMINATIM_DB_PASSWORD=lanwer871h3piubqv075hzpiuhßq934
ENV NOMINATIM_LANGUAGES=de,en

# Set the entrypoint for starting the app
ENTRYPOINT java -jar /app/photon-app.jar -host ${NOMINATIM_DB_HOST} -port ${NOMINATIM_DB_PORT} -database ${NOMINATIM_DB_NAME} -user ${NOMINATIM_DB_USER} -password ${NOMINATIM_DB_PASSWORD} -languages ${NOMINATIM_LANGUAGES}