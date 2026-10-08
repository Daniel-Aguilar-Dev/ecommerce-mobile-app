# Guía de desarrollo de la API

Esta guía describe cómo ejecutar y documentar la API, organizar los módulos y reutilizar las clases comunes de `shared`.

## Tecnologías y estructura

El proyecto usa Java 21, Spring Boot 4.1.1, Maven, Spring MVC, Spring Data JPA y MySQL. El paquete base es `utez.edu.mx.ecommerceapi`.

La organización es por funcionalidad: cada módulo contiene sus capas. Por ejemplo:

```text
src/main/java/utez/edu/mx/ecommerceapi/
├── productos/
│   ├── controller/
│   ├── dto/
│   ├── entity/
│   ├── mapper/
│   ├── repository/
│   └── service/
├── ventas/
│   ├── controller/
│   ├── dto/
│   ├── entity/
│   ├── mapper/
│   ├── repository/
│   └── service/
└── shared/
    ├── audit/
    ├── config/
    ├── exception/
    ├── response/
    ├── util/
    └── web/
```

Los paquetes de `shared` contienen funcionalidades transversales. Los módulos pueden depender de `shared`, pero `shared` no debe depender de módulos como `productos`, `usuarios` o `ventas`.

## Ejecutar la API

Antes de arrancar, verifica que MySQL esté activo, que exista la base `ecommerce_db` y que `src/main/resources/application.properties` tenga las credenciales locales correctas. Ese archivo está ignorado por Git: cada integrante debe crear su propia copia a partir de `application-example.properties` y completar los valores en su equipo. No compartan ni suban contraseñas o claves JWT.

En PowerShell, desde la raíz del proyecto, puede crear el archivo local con:

```powershell
Copy-Item .\src\main\resources\application-example.properties .\src\main\resources\application.properties
```

La configuración JWT también debe estar completa en `application.properties`:

```properties
app.jwt.secret=CLAVE_BASE64_ALEATORIA_DE_AL_MENOS_32_BYTES
app.jwt.expiration-ms=43200000
```

`43200000` equivale a 12 horas. Cada desarrollador puede generar su propia clave desde PowerShell y pegar el resultado en su archivo local:

```powershell
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$bytes = New-Object byte[] 32
$rng.GetBytes($bytes)
[Convert]::ToBase64String($bytes)
$rng.Dispose()
```

La clave debe permanecer privada. Si alguien cambia la clave mientras la API está corriendo, los tokens creados con la clave anterior dejarán de validarse al reiniciar.

Desde la carpeta raíz del proyecto, arranca la API:

```powershell
.\mvnw.cmd spring-boot:run
```

En Linux o macOS:

```bash
./mvnw spring-boot:run
```

Durante desarrollo, `spring.jpa.hibernate.ddl-auto=update` permite que Hibernate actualice el esquema al iniciar. Úsalo solo con la base local; para producción o cambios compartidos de esquema se deben revisar y versionar las migraciones. Si el arranque falla al crear el `EntityManagerFactory`, revisa primero que MySQL responda en el host/puerto configurado y que la base y credenciales existan.

## Swagger / OpenAPI

Con la aplicación ejecutándose, abre:

- Swagger UI: <http://localhost:8080/swagger-ui.html>
- Documento OpenAPI en JSON: <http://localhost:8080/v3/api-docs>
- Endpoint de prueba protegido: <http://localhost:8080/api/v1/ping>

Swagger agrupa las operaciones por tags. Usa `@Tag` en el controller y `@Operation` en los endpoints para agregar nombres y resúmenes útiles:

```java
@Tag(name = "Productos", description = "Consulta y administración de productos")
@RestController
@RequestMapping("/api/v1/productos")
public class ProductoController {

    @Operation(summary = "Consulta el catálogo de productos")
    @GetMapping
    public ApiResponse<List<ProductoRespuesta>> listar() {
        // Delegar en el servicio y devolver una respuesta estándar.
    }
}
```

`OpenApiConfig` agrega el esquema HTTP Bearer JWT a Swagger. La seguridad real la aplica `SecurityConfig` junto con `JwtAuthenticationFilter`: Swagger UI y OpenAPI, el registro y el login son públicos; las demás rutas, incluido el ping, requieren un JWT válido. Por eso el botón **Authorize** sirve para probar rutas protegidas, y documentar un esquema Bearer sin configurar Spring Security no bastaría para protegerlas.

Para probar el ciclo actual desde Swagger:

1. Ejecuta `POST /api/v1/auth/registro` con los datos válidos de `RegistroRequest`, o usa una cuenta ya registrada.
2. Ejecuta `POST /api/v1/auth/login`. La respuesta envuelve el token en `data.token` y contiene `data.tipo: "Bearer"`.
3. Sin autorizar Swagger, llama `GET /api/v1/ping`: debe devolver HTTP 401 y `error: "NO_AUTENTICADO"`.
4. Pulsa **Authorize**, pega solo el valor de `data.token` y confirma. Swagger agrega el prefijo `Bearer` al encabezado.
5. Vuelve a llamar el ping: un token vigente debe devolver HTTP 200 y `message: "pong"`. Un token alterado o vencido debe devolver HTTP 401.

Si Swagger conserva un token anterior, usa **Authorize / Logout** antes de probar el caso sin token. El access token actual dura 12 horas; todavía no hay refresh token. La renovación se puede agregar después en `auth` sin modificar cada endpoint protegido, porque la validación del access token está centralizada en el filtro.

La configuración de rutas y orden de Swagger está en `src/main/resources/application.properties`:

```properties
springdoc.swagger-ui.path=/swagger-ui.html
springdoc.swagger-ui.operations-sorter=method
springdoc.swagger-ui.tags-sorter=alpha
springdoc.api-docs.path=/v3/api-docs
```

## Dependencias Maven

`pom.xml` hereda las versiones de Spring del parent `spring-boot-starter-parent` 4.1.1. Las dependencias necesarias para la API están declaradas ahí:

| Dependencia | Para qué se usa |
| --- | --- |
| `spring-boot-starter-webmvc` | Controladores REST y Spring MVC. En este proyecto con Boot 4 es el starter MVC. |
| `spring-boot-starter-data-jpa` | Persistencia JPA, repositorios y auditoría de entidades. |
| `spring-boot-starter-validation` | Validar DTOs con Jakarta Validation y generar errores de validación uniformes. |
| `spring-boot-starter-security` | Cadena de filtros y protección de rutas con Spring Security. |
| `jjwt-api`, `jjwt-impl`, `jjwt-jackson` 0.13.0 | Crear y validar JWT firmados; `impl` y `jackson` se cargan en ejecución. |
| `mysql-connector-j` | Driver JDBC de MySQL. |
| `lombok` | Anotaciones como `@Getter`, `@Setter` y `@Slf4j`; el procesador de anotaciones está configurado en Maven. |
| `springdoc-openapi-starter-webmvc-ui` 3.1.1 | Generación OpenAPI y Swagger UI, compatible con Spring Boot 4. |

Dependencias principales agregadas para Swagger, validación y JWT:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>3.1.1</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.13.0</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.13.0</version>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.13.0</version>
    <scope>runtime</scope>
</dependency>
```

Validation permite validar DTOs, Spring Security protege rutas, springdoc integra Swagger y JJWT firma y valida los tokens. Spring Boot administra la versión de sus propios starters. El driver MySQL, JPA, MVC y Lombok ya estaban declarados en el `pom.xml`.

Al actualizar Spring Boot, vuelve a comprobar la compatibilidad y versión publicada de springdoc. La línea 3.x corresponde a Spring Boot 4; para Spring Boot 3 se usa springdoc 2.x. Después de cambiar dependencias, compila con:

```powershell
.\mvnw.cmd clean compile
```

## Convenciones para desarrollar un módulo

Mantén controller, DTOs, entidad, mapper, repository y service dentro del paquete de su funcionalidad. Evita poner clases de negocio en `shared`.

Flujo recomendado de una petición:

1. El controller recibe la solicitud y valida el DTO con `@Valid`.
2. El service aplica las reglas de negocio; si una regla falla, lanza una excepción de `shared.exception`.
3. El repository consulta o modifica la base de datos.
4. El mapper convierte entre entidades y DTOs; evita devolver entidades JPA directamente desde la API.
5. El controller devuelve `ApiResponse` con el mensaje y los datos correspondientes.

Ejemplo breve de validación en un DTO:

```java
public record ProductoCrearSolicitud(
        @NotBlank(message = "El nombre es obligatorio")
        String nombre,
        @Positive(message = "El precio debe ser mayor que cero")
        BigDecimal precio
) {
}
```

Y el controller puede recibirlo así:

```java
@PostMapping
public ResponseEntity<ApiResponse<ProductoRespuesta>> crear(
        @Valid @RequestBody ProductoCrearSolicitud solicitud) {
    ProductoRespuesta creado = productoService.crear(solicitud);
    return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.ok("Producto creado correctamente", creado));
}
```

Adapta los nombres y tipos al contrato real del módulo. Los errores de `@Valid` y `ConstraintViolationException` se convierten automáticamente en la respuesta estándar mediante `GlobalExceptionHandler`.

## Respuestas JSON compartidas

`shared/response/ApiResponse.java` define el formato de éxito, negocio y validación. Sus campos nulos no se serializan.

Éxito con datos:

```java
return ApiResponse.ok("Producto obtenido correctamente", productoRespuesta);
```

Éxito sin datos:

```java
return ApiResponse.ok("Producto eliminado correctamente");
```

Ejemplo JSON:

```json
{
  "success": true,
  "message": "Producto obtenido correctamente",
  "data": { "id": 12, "nombre": "Taza" }
}
```

Errores de negocio y validación tienen este formato:

```json
{
  "success": false,
  "message": "No hay stock suficiente",
  "error": "STOCK_INSUFICIENTE"
}
```

```json
{
  "success": false,
  "message": "Los datos enviados no son válidos",
  "error": "VALIDACION_FALLIDA",
  "errors": { "correo": "El correo no es válido" }
}
```

Los clientes deben tomar decisiones con el campo `error`, que es estable; el texto de `message` es para mostrar al usuario y puede cambiar.

## Excepciones compartidas

`shared/exception/ErrorCode.java` enumera códigos estables y su HTTP status. Si un módulo necesita un nuevo error de negocio reutilizable por clientes, agrega un código ahí con el status apropiado.

`BusinessException` representa una regla de negocio incumplida. Lánzala desde el service:

```java
throw new BusinessException(ErrorCode.STOCK_INSUFICIENTE,
        "Stock disponible: " + disponible);
```

`RecursoNoEncontradoException` es una especialización para recursos que no existen:

```java
Producto producto = productoRepository.findById(id)
        .orElseThrow(() -> new RecursoNoEncontradoException("Producto", id));
```

`GlobalExceptionHandler` transforma excepciones en `ApiResponse`:

- `BusinessException`: status definido en su `ErrorCode`.
- Errores de validación: HTTP 400 y mapa de campos en `errors`.
- Credenciales inválidas, usuario desactivado y acceso denegado: códigos y mensajes específicos.
- Otras excepciones: HTTP 500 con un mensaje genérico. El detalle se registra en el servidor; no se devuelve stack trace al cliente.

No captures una excepción genérica en cada controller. Deja que llegue al handler global, salvo que el módulo pueda recuperarse o deba traducirla a una regla de negocio concreta.

## Auditoría de entidades

`shared/audit/AuditableEntity.java` es una superclase `@MappedSuperclass` para las entidades que necesitan auditoría. Extiéndela en la entidad del módulo:

```java
@Entity
@Table(name = "productos")
public class Producto extends AuditableEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Campos propios del producto.
}
```

Con `@EnableJpaAuditing` en `JpaConfig`, JPA administra los campos heredados:

| Campo | Uso |
| --- | --- |
| `createdAt` | Fecha y hora de creación; no se actualiza después. |
| `updatedAt` | Fecha y hora de la última modificación. |
| `createdBy` | ID del usuario que creó el registro, si está autenticado. |
| `updatedBy` | ID del usuario que modificó el registro, si está autenticado. |

`AuditorAwareImpl` obtiene el usuario actual mediante `SecurityUtils`. En operaciones sin sesión, como el autorregistro, los campos de usuario pueden quedar nulos deliberadamente. Las columnas de fecha sí están declaradas no nulas. Extiende esta clase solo en entidades que requieran estos campos; no copies sus campos o listeners en cada entidad.

Al crear una entidad nueva, hereda `AuditableEntity` si necesita `createdAt`, `updatedAt`, `createdBy` y `updatedBy`. No declares de nuevo esas propiedades ni agregues las mismas columnas manualmente. El principal autenticado usa un ID `Long`; `AuditorAwareImpl` guarda ese ID como `created_by` y `updated_by`. El registro público ocurre sin principal, así que esos dos campos pueden ser nulos. `JpaConfig` activa los listeners de auditoría.

### Relación entre usuario y rol

El rol del usuario es una relación a la entidad `Rol`, no un campo enum directamente en `Usuario`. `Usuario.rol` es el lado dueño con `@ManyToOne` y `@JoinColumn(name = "rolId")`; `Rol.usuarios` es la colección inversa con `@OneToMany(mappedBy = "rol")`. `Rol.nombreRol` guarda el valor de `RolEnum` como texto (`EnumType.STRING`). `RolSeeder` crea los roles al iniciar.

Al desarrollar otra entidad relacionada con un usuario o rol, modela la clave foránea como una asociación JPA y usa DTOs para las entradas y salidas del API. No expongas directamente `Rol.usuarios` ni otras colecciones de entidades, porque podrías serializar relaciones de forma recursiva o cargar datos que el endpoint no necesita.

## Utilidades de seguridad compartidas

`shared/util/UsuarioAutenticado.java` define el principal que `JwtAuthenticationFilter` deja en `SecurityContext`: `id`, `correo` y `rol`. Los módulos pueden usar `SecurityUtils` sin depender del paquete `auth`.

`shared/util/SecurityUtils.java` evita que los módulos dependan directamente del módulo `auth` para conocer al usuario:

```java
Long id = SecurityUtils.usuarioActualId();
UsuarioAutenticado usuario = SecurityUtils.usuarioActual();
Optional<Long> idOpcional = SecurityUtils.usuarioActualIdOpcional();
boolean esAdmin = SecurityUtils.tieneRol("ADMINISTRADOR");
```

`usuarioActual()` y `usuarioActualId()` lanzan `BusinessException` con `NO_AUTENTICADO` si el principal no es `UsuarioAutenticado`. Usa la versión opcional para flujos que también pueden ocurrir sin sesión. `tieneRol` compara el nombre del enum sin prefijo: `ADMINISTRADOR`, `EMPLEADO` o `CLIENTE`. Spring Security recibe la autoridad con prefijo `ROLE_`; por ejemplo, en `hasRole` se escribe `hasRole("ADMINISTRADOR")`.

## Archivos comunes y ubicación

| Archivo | Responsabilidad / uso |
| --- | --- |
| `shared/audit/AuditableEntity.java` | Campos y listeners de auditoría que heredan las entidades. |
| `shared/audit/AuditorAwareImpl.java` | Proporciona a Spring Data el ID del usuario actual. |
| `shared/config/JpaConfig.java` | Activa la auditoría JPA. |
| `shared/config/OpenApiConfig.java` | Nombre, descripción, versión y esquema Bearer JWT de OpenAPI. |
| `shared/config/SecurityConfig.java` | Configura rutas públicas, rutas autenticadas, sesiones sin estado y el filtro JWT. |
| `auth/security/JwtAuthenticationFilter.java` | Lee el encabezado Bearer, valida el JWT y construye el principal y la autoridad del rol. |
| `auth/security/JwtService.java` | Firma JWT y valida firma, expiración e información del usuario. |
| `shared/exception/ApiSecurityErrorHandler.java` | Devuelve JSON uniforme para 401 (no autenticado) y 403 (sin permisos). |
| `shared/exception/ErrorCode.java` | Códigos de error y sus HTTP status. |
| `shared/exception/BusinessException.java` | Excepción para errores de negocio con código estable. |
| `shared/exception/RecursoNoEncontradoException.java` | Excepción común para recursos no encontrados. |
| `shared/exception/GlobalExceptionHandler.java` | Convierte errores de controllers/services en respuestas JSON uniformes. |
| `shared/response/ApiResponse.java` | Envoltorio común para respuestas de éxito y error. |
| `shared/util/UsuarioAutenticado.java` | Tipo del principal para el usuario autenticado. |
| `shared/util/SecurityUtils.java` | Acceso al usuario actual, su ID y su rol. |
| `shared/web/PingController.java` | Endpoint de prueba protegido `GET /api/v1/ping` para revisar respuestas sin token, con token válido y con token inválido. |

## Verificación manual

1. Configura y arranca MySQL, completa `application.properties` y ejecuta `mvnw.cmd spring-boot:run`.
2. Abre Swagger UI. Debe aparecer el tag **Sistema** con `GET /api/v1/ping`.
3. Sin token, el ping debe devolver HTTP 401, `success: false` y `error: "NO_AUTENTICADO"`.
4. Obtén un JWT con login, autoriza Swagger y vuelve a llamar el ping; debe devolver HTTP 200 y `message: "pong"`.
5. Prueba un token alterado o vencido: debe devolver HTTP 401. Para revisar una ruta inexistente, autentícate primero; la respuesta depende del manejo de rutas no encontradas de Spring MVC y del handler global.
6. Envía una solicitud inválida a un endpoint que use `@Valid` para comprobar el formato de validación cuando exista ese endpoint.

## Notas para desarrollar otros módulos

- Mantén cada entidad, repository, service, DTO y controller dentro de su módulo. `shared` es para comportamiento realmente transversal.
- Las rutas nuevas quedan protegidas por defecto. No agregues `permitAll` para un endpoint de módulo; si un caso de negocio debe ser público, acuerda explícitamente el acceso y añádelo a `SecurityConfig`.
- En una entidad con relación a `Usuario`, usa la asociación JPA adecuada (`@ManyToOne` o `@OneToOne`) en vez de duplicar una relación como `Long usuarioId` y objeto `Usuario` a la vez. Define el lado dueño con `@JoinColumn` y usa DTOs para evitar serializar grafos JPA.
- Para obtener el ID del usuario que crea o modifica un registro, usa `SecurityUtils.usuarioActualId()`. Para operaciones que legítimamente puedan ejecutarse sin sesión, usa `usuarioActualIdOpcional()` y define si el actor debe quedar nulo.
- Los errores de autenticación emitidos antes de entrar al controller los procesa `ApiSecurityErrorHandler`; errores de negocio y validación de controllers/services los procesa `GlobalExceptionHandler`.
- Al compartir cambios de base, revisa las columnas de auditoría heredadas y las claves foráneas. `ddl-auto=update` es solo una ayuda local, no reemplaza la revisión del esquema.
- Antes de entregar cambios, ejecuta `mvnw.cmd clean compile`. No cambies la clave JWT local de otra persona ni agregues `application.properties` al commit.
