# ArchUnit Setup

Use ArchUnit when architecture findings can be converted into executable rules.

## Gradle

```kotlin
testImplementation("com.tngtech.archunit:archunit-junit5:<version>")
```

## Maven

```xml
<dependency>
  <groupId>com.tngtech.archunit</groupId>
  <artifactId>archunit-junit5</artifactId>
  <version>${archunit.version}</version>
  <scope>test</scope>
</dependency>
```

## Baseline Test

```java
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;

@AnalyzeClasses(packages = "com.example")
class ArchitectureTest {
  @ArchTest
  static final ArchRule controllers_do_not_access_repositories =
      noClasses()
          .that().resideInAPackage("..api..")
          .should().accessClassesThat().resideInAPackage("..infrastructure..");
}
```

## Review Guidance

- Use the project's existing ArchUnit version if present; otherwise choose the current version compatible with the build.
- Add rules only for boundaries the team has accepted.
- Start with high-signal rules: controller-to-repository access, module dependency direction, and domain-to-infrastructure imports.
- If current code violates the desired rule broadly, document a migration plan before enabling the rule in CI.
