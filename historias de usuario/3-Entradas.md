# Módulo 3: Gestión de entradas

### Registro y consulta de entradas de mercancía

#### Versión 1.2

<h2> HU-3.1 Registrar entrada de mercancía - <span style="color:red"> ALTA</span></h2>

**Como** administrador o empleado autorizado, **quiero** registrar la entrada de mercancía **para** actualizar las existencias y mantener un historial de compras y reabastecimiento.

<h4>Criterios de aceptación</h4>
<ul>
    <li>El sistema registra producto, cantidad, costo unitario de compra, fecha y proveedor opcional, asociando automáticamente el usuario y la fecha/hora del registro.</li>
    <li>Al registrar una entrada válida de 10 unidades para un producto con 20 unidades, el stock aumenta a 30.</li>
    <li>Si falta un dato obligatorio o la cantidad es cero o negativa, el sistema informa el error y no modifica el inventario.</li>
    <li>La entrada aparece en el historial y alimenta el cálculo del costo promedio y las estadísticas de compras, sin duplicarse como gasto operativo.</li>
    <li>Los usuarios sin autorización no pueden registrar entradas y el EMPLEADO no puede consultar costos ni utilidades.</li>
    <li>Se muestra el mensaje: “La entrada de mercancía se ha registrado correctamente”.</li>
</ul>

**Pendiente de definición:** cómo registra el EMPLEADO una entrada sin visualizar el costo de compra.

<hr/>

<h2> HU-3.2 Consultar historial de entradas - <span style="color:yellow"> MEDIA</span></h2>

**Como** administrador o empleado autorizado, **quiero** consultar las entradas por producto y fecha **para** revisar el reabastecimiento y conocer quién registró cada movimiento.

<h4>Criterios de aceptación</h4>
<ul>
    <li>El listado muestra producto, cantidad, proveedor cuando exista, fecha y usuario responsable.</li>
    <li>Al filtrar por producto, se muestran únicamente las entradas de ese producto.</li>
    <li>Al filtrar por un rango de fechas, se muestran únicamente las entradas del periodo; ambos filtros pueden combinarse.</li>
    <li>Si la fecha inicial es posterior a la final, el sistema solicita corregir el rango.</li>
    <li>Si no hay coincidencias, se muestra: “No se encontraron entradas con los filtros seleccionados”.</li>
    <li>Solo ADMIN puede consultar costos e importes de compra; EMPLEADO únicamente accede a la información operativa.</li>
    <li>La consulta no modifica el inventario y no está disponible para CLIENTE.</li>
</ul>