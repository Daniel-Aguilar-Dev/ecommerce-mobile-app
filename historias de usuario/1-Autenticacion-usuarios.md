# Módulo 1: Autenticación y usuarios

### Gestión de acceso y cuentas de usuario

#### Versión 1.2

<h2> HU-1.1 Iniciar sesión - <span style="color:red"> ALTA</span></h2>

**Como** usuario (ADMIN, EMPLEADO o CLIENTE), **quiero** iniciar sesión con usuario y contraseña **para** acceder a las funciones de mi rol.

<h4>Criterios de aceptación</h4>
<ul>
	<li>El login solicita usuario y contraseña.</li>
	<li>Si las credenciales son incorrectas, se muestra un error sin indicar si falló el usuario o la contraseña.</li>
	<li>Un usuario desactivado no puede iniciar sesión, aunque su historial de acciones se conserva.</li>
	<li>Tras iniciar sesión, el sistema identifica el rol y muestra únicamente las funciones permitidas para ese rol.</li>
</ul>

<hr/>

<h2> HU-1.2 Gestionar usuarios internos (ADMIN/EMPLEADO) - <span style="color:red"> ALTA</span></h2>

**Como** ADMIN, **quiero** crear, desactivar y cambiar el rol de usuarios internos **para** controlar quién tiene acceso al sistema y con qué permisos.

<h4>Criterios de aceptación</h4>
<ul>
	<li>Solo el ADMIN puede crear, desactivar o cambiar el rol de un usuario interno.</li>
	<li>Al crear un usuario se le asigna rol ADMIN o EMPLEADO manualmente; nunca CLIENTE.</li>
	<li>Desactivar un usuario le impide iniciar sesión, pero no elimina su historial de acciones.</li>
	<li>Cambiar el rol de un usuario no afecta las acciones que ya registró con el rol anterior.</li>
	<li>Un usuario no puede desactivarse ni cambiarse a sí mismo.</li>
</ul>

<hr/>

<h2> HU-1.3 Cambiar contraseña propia - <span style="color:yellow"> MEDIA</span></h2>

**Como** usuario con sesión activa, **quiero** cambiar mi propia contraseña **para** mantener mi cuenta segura.

<h4>Criterios de aceptación</h4>
<ul>
	<li>Se solicita la contraseña actual antes de permitir el cambio.</li>
	<li>La nueva contraseña debe cumplir con los requisitos mínimos de seguridad definidos (longitud mínima, etc.).</li>
	<li>Al confirmar, el cambio aplica de inmediato para el siguiente inicio de sesión.</li>
	<li>No se puede ver la contraseña actual en texto plano en ningún momento.</li>
</ul>

<hr/>

<h2> HU-1.4 Auto-registro de cuenta CLIENTE - <span style="color:red"> ALTA</span></h2>

**Como** visitante, **quiero** registrarme por mi cuenta con nombre, teléfono, correo y contraseña **para** poder comprar en la app sin depender de un administrador.

<h4>Criterios de aceptación</h4>
<ul>
	<li>El formulario solicita nombre, teléfono de contacto, correo y contraseña; todos son obligatorios.</li>
	<li>El correo debe ser único en el sistema; si ya existe, se muestra un error.</li>
	<li>La cuenta se crea con rol CLIENTE automáticamente y queda activa sin requerir aprobación de un ADMIN.</li>
	<li>Al finalizar el registro, el CLIENTE puede iniciar sesión de inmediato.</li>
	<li>Este flujo nunca permite seleccionar un rol distinto a CLIENTE.</li>
</ul>
 
