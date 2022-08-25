# Example of the Citus maintenance setup for [Dzone blog post](https://dzone.com/articles/maintenance-of-a-citus-cluster)

Migration scripts described in the post are located in `src/main/resources/db/migration`

In order to use this example do run following:

```shell
# Spin up a citus cluster
docker-compose up -d
# Apply migratons
./gradlew flywayMigrate -i
```

After that the Citus cluster with applied migrations will be available at `localhost:5432`.

# Notes

For the sake of simplicity a role of the `maintenance` database is performed by `postgres`. It is implied
that in production systems `maintenance` database is created outside the main migration scripts, manually or via
dedicated set of migrations.
