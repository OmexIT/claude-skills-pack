# Stack Defaults & Auto-Detection

Read this file when inferring tech stack for a spec. Confirm with the user before dispatching execution agents if detected stack differs from defaults.

## Default Stack (Java / Web)

| Layer | Default | Alternatives |
|---|---|---|
| Backend Language | Java 25 (LTS, preview features enabled) | Kotlin (JVM), Go |
| Backend Framework | Spring Boot 4.x + Spring Modulith 2.x | — |
| Persistence | Spring Data JDBC (preferred for aggregates) + jOOQ (complex queries) | Spring Data JPA (legacy) |
| Mapping | MapStruct 1.6+ | — |
| Build | Gradle (Kotlin DSL) | Maven (some legacy projects) |
| Frontend (Web) | React 19 + Next.js 15 + TypeScript 5 + Tailwind 4 + shadcn/ui + TanStack Query + Zustand | AngularJS 1.x (legacy only) |
| Frontend (Mobile) | Flutter 3.x + Dart (Riverpod, GoRouter) | React Native + TypeScript, Android (Kotlin + Compose) |
| Database (Relational) | PostgreSQL 16+ | — |
| Database (Document) | MongoDB (when document store is needed) | — |
| Search | Elasticsearch 8.x | Typesense |
| Cache / Queue | Redis 7+, RabbitMQ via Spring Cloud Stream 4.x, Kafka for high-throughput | — |
| Workflow | Temporal.io Java SDK 1.26+ | db-scheduler (cluster-safe scheduling) |
| Auth | Spring Security 6.x + JWT / OAuth2 | — |
| Containerization | Docker + Docker Compose | — |
| Orchestration | Kubernetes | — |
| IaC | Terraform | — |
| BE Testing | JUnit 5 + Mockito 5 + AssertJ + Testcontainers + REST Assured | — |
| FE Testing (Web) | Vitest + React Testing Library | Karma + Jasmine (AngularJS) |
| FE Testing (Mobile) | Flutter: widget + integration tests | RN: Jest + RNTL, Android: JUnit + MockK |
| E2E Testing | Playwright (Chromium) | Detox (React Native), Espresso (Android) |
| API Style | REST (OpenAPI 3.1) | gRPC for internal service-to-service |
| Migrations (SQL) | Liquibase 4.x (Kifiya) or Flyway 10+ (new projects) | — |
| Migrations (Mongo) | mongosh scripts (idempotent, tracked in `_migrations`) | — |

## Observability Stack

| Layer | Default | Alternatives |
|---|---|---|
| Structured Logging | Logback + logstash-logback-encoder (JSON) | Log4j2 + JSON layout |
| Distributed Tracing | OpenTelemetry (OTLP) + Spring Boot Actuator | — |
| Metrics | Micrometer + Prometheus exposition format | — |
| Dashboards | Grafana (JSON model) | — |
| Log Aggregation | Loki (or ELK) | — |
| Trace Backend | Tempo (or Jaeger) | — |
| Alerting | Grafana Alerting (or Prometheus Alertmanager) | — |

## Architectural Principles (encode in every agent prompt)

- **Clean Architecture**: domain has zero external dependencies; depend inward only
- **Config-driven workflows**: behavior from YAML/properties, not code branches
- **Double-entry ledger**: every money movement is balanced (see fintech-ledger skill)
- **SAGA with explicit compensation**: register compensation before forward execution (see temporal-workflow skill)
- **Idempotency**: every write operation has an idempotency key
- **Event sourcing for audit**: state changes publish domain events
- **MapStruct for mapping**: never manual DTO↔Entity conversion
- **Testcontainers for integration tests**: real DB, real Redis, real broker
- **Conventional commits**: `feat:`, `fix:`, `refactor:`, `chore:`
- **No raw SQL in application code**: use repositories or jOOQ DSL
- **Constructor injection only**: no field injection, no setter injection
- **BigDecimal for money, Instant/OffsetDateTime for time**: never `double`/`Date`
- **Multi-tenancy**: PostgreSQL RLS with `SET LOCAL app.tenant_id` per request

## Auto-Detection from Project Files

```bash
# Detect build system + language
[ -f "build.gradle" ] || [ -f "build.gradle.kts" ] && echo "Gradle project"
[ -f "pom.xml" ]            && echo "Maven project"
[ -f "pubspec.yaml" ]       && echo "Flutter detected"
[ -f "package.json" ]       && echo "Node project (React/Next/RN/TS)"
[ -f "angular.json" ]       && echo "Angular detected"
[ -f "bower.json" ]         && echo "AngularJS detected"
[ -f "go.mod" ]             && echo "Go project"
[ -f "Cargo.toml" ]         && echo "Rust project"

# Detect infra
[ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ] && echo "Docker Compose"
[ -d "terraform" ]          && echo "Terraform"
[ -d "k8s" ] || [ -d "kubernetes" ] || [ -d "manifests" ] && echo "Kubernetes"

# Detect Spring Boot version from build file
grep -hE "org\.springframework\.boot[\"' ]*:[\"' ]*[0-9.]+" build.gradle* pom.xml 2>/dev/null | head -3
grep -hE "id[\"(' ]*org\.springframework\.boot[\"')]*.+version" build.gradle* 2>/dev/null

# Detect Java version
grep -hE "languageVersion\.set|sourceCompatibility|<java\.version>" build.gradle* pom.xml 2>/dev/null | head -5

# Detect persistence layer
grep -qE "spring-boot-starter-data-jdbc" build.gradle* pom.xml 2>/dev/null && echo "Spring Data JDBC detected"
grep -qE "spring-boot-starter-data-jpa"  build.gradle* pom.xml 2>/dev/null && echo "Spring Data JPA detected"
grep -qE "jooq"                           build.gradle* pom.xml 2>/dev/null && echo "jOOQ detected"

# Detect observability stack
grep -qE "micrometer"                    build.gradle* pom.xml 2>/dev/null && echo "Micrometer detected"
grep -qE "opentelemetry"                 build.gradle* pom.xml 2>/dev/null && echo "OpenTelemetry detected"
grep -qE "logstash-logback-encoder"      build.gradle* pom.xml 2>/dev/null && echo "Structured logging detected"
grep -qE "prometheus"                    docker-compose.y*ml 2>/dev/null && echo "Prometheus detected"

# Detect testing
grep -qE "junit-jupiter|testcontainers|rest-assured|mockito"  build.gradle* pom.xml 2>/dev/null

# Detect frontend framework version
node -e "const p=require('./package.json'); console.log('Next.js', p.dependencies?.next||p.devDependencies?.next||'-'); console.log('React', p.dependencies?.react||'-');" 2>/dev/null
```

## Rules

- Always run auto-detection before assuming defaults
- Always confirm stack with user before dispatching execution agents if detection returns unexpected versions
- If detected stack < default (e.g., Spring Boot 3.x when default is 4.x), ask user — may be intentional legacy
- Project-specific CLAUDE.md overrides defaults — read it before this file
