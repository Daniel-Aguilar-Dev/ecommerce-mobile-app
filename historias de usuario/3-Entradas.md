# Módulo 3: Entradas de inventario

## 3.3 Entradas de inventario

**Descripción:** Registro de compras y reabastecimiento de mercancía, actualización de existencias, consulta del historial de entradas y gestión opcional de proveedores.

### HU-3.3-01 — Registrar entrada de mercancía

**Usuario:** Administrador / Empleado.

**Descripción:** Como usuario con permiso **inventario.entradas.registrar**, quiero registrar la entrada de mercancía para incrementar las existencias del producto y mantener un historial de las compras y del reabastecimiento.

**Datos de entrada:**

- Producto* — Selección de un producto del catálogo.
- Cantidad* — Numérico, de acuerdo con la unidad de medida del producto.
- Costo unitario de compra* — Numérico decimal; sujeto a las restricciones de acceso del rol.
- Proveedor — Selección opcional.
- Fecha de entrada* — Fecha.
- Usuario que registra* — Obtenido automáticamente de la sesión activa.
- Fecha y hora del registro* — Generadas automáticamente por el sistema.

**Datos de salida:**

- Entrada registrada y disponible en el historial.
- Stock del producto incrementado según la cantidad recibida.
- Información de compra disponible para calcular el costo promedio del producto.
- Importe de la compra incorporado a las estadísticas de compras de mercancía.
- Mensaje de confirmación: “La entrada de mercancía se ha registrado correctamente”.

**Nota:**

- El símbolo (*) indica los datos obligatorios.
- El usuario y la fecha/hora de auditoría no se capturan manualmente.
- El proveedor es opcional.
- Está pendiente definir cómo registra una entrada el EMPLEADO sin visualizar el costo de compra. No se debe eliminar esa restricción ni asumir un costo automáticamente sin una regla aprobada.

**Reglas de negocio:**

- El usuario debe iniciar sesión y contar con el permiso correspondiente.
- El rol CLIENTE no puede registrar entradas.
- El producto debe existir en el catálogo.
- La cantidad debe ser mayor que cero y compatible con la unidad de medida.
- Como validación propuesta, el costo unitario debe ser numérico y no negativo.
- El stock se incrementa mediante el movimiento de entrada; no se modifica directamente.
- El costo registrado alimenta el cálculo del costo promedio.
- La compra se contabiliza como compra de mercancía, separada de los gastos operativos.
- La entrada debe conservar el usuario responsable y su fecha/hora de registro.
- Los movimientos no se eliminan físicamente; se conserva su historial.

**Criterios de aceptación:**

- Al registrar una entrada válida de 10 unidades para un producto con 20 unidades, el stock queda en 30.
- Al guardar la entrada, esta aparece en el historial con producto, cantidad, fecha y usuario responsable.
- El sistema permite registrar la entrada sin seleccionar un proveedor.
- Si falta un dato obligatorio o la cantidad es cero o negativa, el sistema informa el error y no modifica el stock.
- Los datos de la entrada se consideran en el cálculo del costo promedio y de las compras de mercancía, sin duplicarlos como gasto operativo.
- Un usuario sin autorización no puede acceder al registro ni ejecutar la operación.
- El EMPLEADO no puede consultar costos de compra ni utilidades; su flujo de captura queda sujeto a la aclaración indicada en la nota.

### HU-3.3-02 — Consultar historial de entradas

**Usuario:** Administrador / Empleado.

**Descripción:** Como usuario con permiso **inventario.entradas.consultar**, quiero consultar y filtrar las entradas por producto y fecha para revisar el reabastecimiento y conocer quién registró cada movimiento.

**Datos de entrada:**

- Producto — Filtro opcional.
- Fecha inicial — Filtro opcional.
- Fecha final — Filtro opcional.
- Usuario autenticado* — Obtenido de la sesión activa para validar el acceso.

**Datos de salida:**

- Listado de entradas que coinciden con los filtros.
- Información de producto, cantidad, proveedor cuando exista, fecha de entrada y usuario responsable.
- Costos unitarios e importes de compra visibles únicamente para ADMIN.
- Mensaje cuando no existan resultados: “No se encontraron entradas con los filtros seleccionados”.

**Nota:**

- El símbolo (*) indica los datos obligatorios.
- Los filtros son opcionales.
- La información financiera se muestra según el rol del usuario.

**Reglas de negocio:**

- Se requiere una sesión activa y el permiso de consulta.
- El rol CLIENTE no puede acceder al historial interno de entradas.
- Los filtros de producto y fecha pueden utilizarse individualmente o en conjunto.
- Si se proporciona un rango de fechas, la fecha inicial no debe ser posterior a la final.
- El EMPLEADO puede consultar la información operativa, pero no costos de compra, importes que los revelen ni utilidades.
- Consultar el historial no modifica existencias ni movimientos.
- El historial conserva la identificación de los responsables, aunque posteriormente sus cuentas sean desactivadas.

**Criterios de aceptación:**

- Al seleccionar un producto, el sistema muestra únicamente sus entradas.
- Al indicar un rango de fechas, el sistema muestra las entradas comprendidas en ese periodo.
- Al combinar producto y fechas, los resultados cumplen ambos filtros.
- Si la fecha inicial es posterior a la final, el sistema solicita corregir el rango.
- Si no existen coincidencias, se muestra el mensaje correspondiente.
- Al consultar como EMPLEADO, no se muestran ni se entregan datos de costos o utilidades.
- La consulta no cambia el stock de ningún producto.

### HU-3.3-03 — Gestionar proveedores

**Usuario:** Administrador.

**Descripción:** Como administrador con permiso **proveedores.gestionar**, quiero registrar, consultar y actualizar los datos básicos de los proveedores para identificarlos y asociarlos a las entradas de mercancía.

**Datos de entrada:**

- Nombre del proveedor* — Texto.
- Contacto — Texto opcional, como teléfono o correo.
- Identificador del proveedor* — Requerido al consultar un registro específico o actualizarlo.
- Usuario responsable* — Obtenido de la sesión activa.

**Datos de salida:**

- Proveedor registrado o actualizado.
- Listado de proveedores disponibles.
- Proveedor disponible para seleccionarse al registrar una entrada.
- Mensaje de confirmación: “El proveedor se ha registrado correctamente” o “Los datos del proveedor se han actualizado correctamente”.

**Nota:**

- El símbolo (*) indica los datos obligatorios.
- La gestión de proveedores es opcional para el MVP.
- Se propone que ADMIN gestione los proveedores; el documento no define un permiso específico para EMPLEADO.
- Se propone que el contacto sea opcional.

**Reglas de negocio:**

- El usuario debe iniciar sesión y contar con el permiso correspondiente.
- El nombre del proveedor no puede estar vacío.
- Para actualizar un proveedor, el registro debe existir.
- La modificación de sus datos no debe romper las asociaciones con entradas anteriores.
- Registrar o actualizar un proveedor no modifica el inventario ni genera un gasto.
- Las entradas pueden registrarse sin proveedor, incluso si esta funcionalidad no se implementa en el MVP.

**Criterios de aceptación:**

- Al capturar un nombre válido, el sistema registra el proveedor y lo muestra en el listado.
- Si el nombre está vacío, el sistema indica que es obligatorio y no guarda el registro.
- El proveedor registrado aparece entre las opciones disponibles al registrar una entrada.
- Al actualizar el contacto, la consulta posterior muestra el nuevo dato.
- Las entradas previamente asociadas conservan su relación con el proveedor.
- Un usuario sin autorización no puede registrar ni actualizar proveedores.