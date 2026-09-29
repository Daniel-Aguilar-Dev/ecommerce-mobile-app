### HU-3.3-01
**Registrar entrada de mercancía**

**Como** administrador o empleado autorizado, **quiero** registrar la entrada de mercancía **para** actualizar las existencias y mantener un historial de compras y reabastecimiento.

**CRITERIOS DE ACEPTACIÓN**

1. El sistema registra producto, cantidad, costo unitario de compra, fecha y proveedor opcional, asociando automáticamente el usuario y la fecha/hora del registro.
2. Al registrar una entrada válida de 10 unidades para un producto con 20 unidades, el stock aumenta a 30.
3. Si falta un dato obligatorio o la cantidad es cero o negativa, el sistema informa el error y no modifica el inventario.
4. La entrada aparece en el historial y alimenta el cálculo del costo promedio y las estadísticas de compras, sin duplicarse como gasto operativo.
5. Los usuarios sin autorización no pueden registrar entradas y el EMPLEADO no puede consultar costos ni utilidades.
6. Se muestra el mensaje: “La entrada de mercancía se ha registrado correctamente”.

**Pendiente de definición:** cómo registra el EMPLEADO una entrada sin visualizar el costo de compra.

---

### HU-3.3-02
**Consultar historial de entradas**

**Como** administrador o empleado autorizado, **quiero** consultar las entradas por producto y fecha **para** revisar el reabastecimiento y conocer quién registró cada movimiento.

**CRITERIOS DE ACEPTACIÓN**

1. El listado muestra producto, cantidad, proveedor cuando exista, fecha y usuario responsable.
2. Al filtrar por producto, se muestran únicamente las entradas de ese producto.
3. Al filtrar por un rango de fechas, se muestran únicamente las entradas del periodo; ambos filtros pueden combinarse.
4. Si la fecha inicial es posterior a la final, el sistema solicita corregir el rango.
5. Si no hay coincidencias, se muestra: “No se encontraron entradas con los filtros seleccionados”.
6. Solo ADMIN puede consultar costos e importes de compra; EMPLEADO únicamente accede a la información operativa.
7. La consulta no modifica el inventario y no está disponible para CLIENTE.

---

### HU-3.3-03
**Gestionar proveedores**

**Como** administrador, **quiero** registrar, consultar y actualizar proveedores **para** identificarlos y asociarlos a las entradas de mercancía.

**CRITERIOS DE ACEPTACIÓN**

1. El sistema permite registrar un proveedor con nombre obligatorio y contacto opcional.
2. Si el nombre está vacío, se informa el error y no se guarda el registro.
3. El proveedor registrado aparece en el listado y puede seleccionarse al registrar una entrada.
4. Al actualizar sus datos, la consulta posterior muestra los cambios y las entradas anteriores conservan su asociación.
5. Registrar o actualizar un proveedor no modifica el stock ni genera gastos.
6. Un usuario sin autorización no puede registrar ni actualizar proveedores.

