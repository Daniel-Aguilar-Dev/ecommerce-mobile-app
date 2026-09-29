# Módulo 1: Autenticación y usuarios

### US-AUTH-01 · Iniciar sesión
 
**Como** usuario (ADMIN, EMPLEADO o CLIENTE), **quiero** iniciar sesión con usuario y contraseña **para** acceder a las funciones de mi rol.
 
**Criterios de aceptación:**
1. El login solicita usuario y contraseña.
2. Si las credenciales son incorrectas, se muestra un error sin indicar si falló el usuario o la contraseña.
3. Un usuario desactivado no puede iniciar sesión, aunque su historial de acciones se conserva.
4. Tras iniciar sesión, el sistema identifica el rol y muestra únicamente las funciones permitidas para ese rol.
---
 
### US-AUTH-02 · Gestionar usuarios internos (ADMIN/EMPLEADO)
 
**Como** ADMIN, **quiero** crear, desactivar y cambiar el rol de usuarios internos **para** controlar quién tiene acceso al sistema y con qué permisos.
 
**Criterios de aceptación:**
1. Solo el ADMIN puede crear, desactivar o cambiar el rol de un usuario interno.
2. Al crear un usuario se le asigna rol ADMIN o EMPLEADO manualmente; nunca CLIENTE.
3. Desactivar un usuario le impide iniciar sesión, pero no elimina su historial de acciones.
4. Cambiar el rol de un usuario no afecta las acciones que ya registró con el rol anterior.
5. Un usuario no puede desactivarse ni cambiarse a sí mismo.
---
 
### US-AUTH-03 · Cambiar contraseña propia
 
**Como** usuario con sesión activa, **quiero** cambiar mi propia contraseña **para** mantener mi cuenta segura.
 
**Criterios de aceptación:**
1. Se solicita la contraseña actual antes de permitir el cambio.
2. La nueva contraseña debe cumplir con los requisitos mínimos de seguridad definidos (longitud mínima, etc.).
3. Al confirmar, el cambio aplica de inmediato para el siguiente inicio de sesión.
4. No se puede ver la contraseña actual en texto plano en ningún momento.
---
 
### US-AUTH-04 · Auto-registro de cuenta CLIENTE
 
**Como** visitante, **quiero** registrarme por mi cuenta con nombre, teléfono, correo y contraseña **para** poder comprar en la app sin depender de un administrador.
 
**Criterios de aceptación:**
1. El formulario solicita nombre, teléfono de contacto, correo y contraseña; todos son obligatorios.
2. El correo debe ser único en el sistema; si ya existe, se muestra un error.
3. La cuenta se crea con rol CLIENTE automáticamente y queda activa sin requerir aprobación de un ADMIN.
4. Al finalizar el registro, el CLIENTE puede iniciar sesión de inmediato.
5. Este flujo nunca permite seleccionar un rol distinto a CLIENTE.
---
 
### US-AUTH-05 · Recuperar contraseña
 
**Como** usuario de cualquier rol, **quiero** recuperar mi contraseña mediante mi correo registrado **para** volver a acceder si la olvido.
 
**Criterios de aceptación:**
1. Se solicita el correo registrado para iniciar la recuperación.
2. Si el correo existe, se envía un enlace o código de recuperación a esa dirección.
3. Si el correo no existe, el sistema no revela si la cuenta existe o no (mismo mensaje genérico).
4. El enlace o código de recuperación expira después de un tiempo definido.
5. Al completar la recuperación, la contraseña anterior deja de funcionar.
---