plugins {
    id("java")
    id("org.flywaydb.flyway") version "9.0.1"
}

group = "org.dzone.vyazmitinov.examples"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.postgresql:postgresql:42.3.6")
    testImplementation("org.junit.jupiter:junit-jupiter-api:5.8.1")
    testRuntimeOnly("org.junit.jupiter:junit-jupiter-engine:5.8.1")
}

tasks.getByName<Test>("test") {
    useJUnitPlatform()
}

flyway {
    url = "jdbc:postgresql://localhost:5432/postgres"
    user = "postgres"
    password = ""
}