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

Desde la carpeta raíz del proyecto:

```powershell
.\mvnw.cmd spring-boot:run
```

En Linux o macOS:

```bash
./mvnw spring-boot:run
```

La aplicación necesita MySQL disponible. La configuración local actual está en `src/main/resources/application.properties`; revisa URL, base de datos, usuario y contraseña antes de iniciar. No publiques credenciales ni las incluyas en un commit.

## Swagger / OpenAPI

Con la aplicación ejecutándose, abre:

- Swagger UI: <http://localhost:8080/swagger-ui.html>
- Documento OpenAPI en JSON: <http://localhost:8080/v3/api-docs>
- Endpoint temporal de estado: <http://localhost:8080/api/v1/ping>

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

`OpenApiConfig` agrega el esquema HTTP Bearer JWT y el requisito de seguridad de OpenAPI. En Swagger, el botón **Authorize** permite pegar un token para incluirlo en las llamadas. El esquema documentado no valida por sí solo un token: `SecurityConfigTemporal` actualmente permite todas las solicitudes. Cuando se implemente `auth`, reemplaza esa configuración temporal por la definitiva y conserva acceso público para `/v3/api-docs/**`, `/swagger-ui/**`, `/swagger-ui.html`, `/api/v1/auth/login` y `/api/v1/auth/registro`.

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
| `spring-boot-starter-security` | Spring Security; hoy se combina con la configuración temporal abierta. |
| `mysql-connector-j` | Driver JDBC de MySQL. |
| `lombok` | Anotaciones como `@Getter`, `@Setter` y `@Slf4j`; el procesador de anotaciones está configurado en Maven. |
| `springdoc-openapi-starter-webmvc-ui` 3.1.1 | Generación OpenAPI y Swagger UI, compatible con Spring Boot 4. |

Bloque agregado para Swagger:

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
```

Las dos primeras agregan validación y Spring Security; la tercera integra Swagger. Spring Boot administra la versión de sus propios starters. El driver MySQL, JPA, MVC y Lombok ya estaban declarados en el `pom.xml`.

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

## Utilidades de seguridad compartidas

`shared/util/UsuarioAutenticado.java` define el principal esperado en `SecurityContext`: `id`, `correo` y `rol`. El futuro filtro JWT debe guardar este record como principal.

`shared/util/SecurityUtils.java` evita que los módulos dependan directamente del módulo `auth` para conocer al usuario:

```java
Long id = SecurityUtils.usuarioActualId();
UsuarioAutenticado usuario = SecurityUtils.usuarioActual();
Optional<Long> idOpcional = SecurityUtils.usuarioActualIdOpcional();
boolean esAdmin = SecurityUtils.tieneRol("ADMIN");
```

`usuarioActual()` y `usuarioActualId()` lanzan `BusinessException` con `NO_AUTENTICADO` si el principal no es `UsuarioAutenticado`. Usa la versión opcional para flujos que también pueden ocurrir sin sesión. `tieneRol` recibe el nombre sin prefijo, por ejemplo `ADMIN` o `CLIENTE`.

## Archivos comunes y ubicación

| Archivo | Responsabilidad / uso |
| --- | --- |
| `shared/audit/AuditableEntity.java` | Campos y listeners de auditoría que heredan las entidades. |
| `shared/audit/AuditorAwareImpl.java` | Proporciona a Spring Data el ID del usuario actual. |
| `shared/config/JpaConfig.java` | Activa la auditoría JPA. |
| `shared/config/OpenApiConfig.java` | Nombre, descripción, versión y esquema Bearer JWT de OpenAPI. |
| `shared/config/SecurityConfigTemporal.java` | Permite todas las solicitudes durante el desarrollo inicial; eliminar al integrar la seguridad real de `auth`. |
| `shared/exception/ErrorCode.java` | Códigos de error y sus HTTP status. |
| `shared/exception/BusinessException.java` | Excepción para errores de negocio con código estable. |
| `shared/exception/RecursoNoEncontradoException.java` | Excepción común para recursos no encontrados. |
| `shared/exception/GlobalExceptionHandler.java` | Convierte errores de controllers/services en respuestas JSON uniformes. |
| `shared/response/ApiResponse.java` | Envoltorio común para respuestas de éxito y error. |
| `shared/util/UsuarioAutenticado.java` | Tipo del principal para el usuario autenticado. |
| `shared/util/SecurityUtils.java` | Acceso al usuario actual, su ID y su rol. |
| `shared/web/PingController.java` | Endpoint temporal `GET /api/v1/ping`; eliminar o conservar como healthcheck cuando haya endpoints reales. |

## Verificación manual

1. Arranca MySQL y luego ejecuta `mvnw.cmd spring-boot:run`.
2. Abre Swagger UI y comprueba que aparece el tag **Sistema** con `GET /api/v1/ping`.
3. Llama al ping; debe devolver `success: true` y `message: "pong"`.
4. Envía una solicitud inválida a un endpoint que use `@Valid` para comprobar el formato de errores cuando exista ese endpoint.
5. Llama a una ruta inexistente y comprueba que la respuesta sea JSON, sin página HTML ni stack trace.

## Pendientes para la implementación de `auth`

- Reemplazar `SecurityConfigTemporal` por la configuración definitiva.
- Implementar el filtro JWT y guardar `UsuarioAutenticado(id, correo, rol)` en el `SecurityContext`, con autoridad `ROLE_` más el rol.
- Responder errores de autenticación y autorización desde `AuthenticationEntryPoint` y `AccessDeniedHandler` con `ApiResponse`.
- Decidir si `PingController` se elimina o se mantiene como healthcheck.
- Actualizar el ERD para reflejar que `created_by` y `updated_by` pueden ser nulos durante el autorregistro.
