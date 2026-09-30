# Módulo 7: Ventas

### Registro, consulta y control de ventas

#### Versión 1.2

<h2> HU-7.1 Registrar venta presencial - <span style="color:red"> ALTA</span></h2>

**Como** empleado, **quiero** registrar una venta presencial agregando los productos mediante el escaneo de su código de barras, **para** generar la venta física de manera rápida y evitar tener que buscar manualmente cada producto.

<h4>Criterios de aceptación</h4>

<ul>
    <li>El empleado puede iniciar una nueva venta presencial.</li>
    <li>El sistema permite escanear el código de barras de un producto utilizando la cámara del dispositivo.</li>
    <li>Al escanear un código de barras válido, el sistema identifica el producto correspondiente y lo agrega a la venta.</li>
    <li>El sistema muestra el producto agregado, su cantidad y su precio de venta.</li>
    <li>Si el mismo producto se escanea nuevamente, el sistema incrementa su cantidad en la venta.</li>
    <li>El empleado puede modificar la cantidad de los productos agregados.</li>
    <li>El sistema valida que exista stock disponible antes de agregar el producto a la venta.</li>
    <li>Si el código de barras no corresponde a ningún producto registrado, el sistema muestra un mensaje indicando que el producto no fue encontrado.</li>
    <li>El empleado puede agregar uno o varios productos a la misma venta.</li>
    <li>El empleado puede seleccionar el método de pago: efectivo, tarjeta o transferencia.</li>
    <li>El sistema calcula automáticamente el total de la venta de acuerdo con los productos, cantidades y precios registrados.</li>
    <li>La venta queda asociada al empleado responsable y registra la fecha y hora de realización.  </li>
</ul>

<hr/>

<h2> HU-7.2 Generar salida de inventario por venta - <span style="color:green"> AUTOMÁTICA</span></h2>

**Como** empleado, **quiero** que al confirmar una venta se genere automáticamente la salida de inventario **para** mantener actualizado el stock de los productos vendidos.

<h4>Criterios de aceptación</h4>

<ul>
    <li>Al confirmar una venta, el sistema genera una salida por cada producto vendido.</li>
    <li>La cantidad descontada corresponde con la cantidad vendida.</li>
    <li>El stock no puede modificarse manualmente desde la venta.</li>
    <li>El sistema no permite una salida superior al stock disponible.</li>
    <li>La salida queda asociada a la venta correspondiente.</li>
    <li>El movimiento conserva su historial para fines de trazabilidad.</li>
</ul>

<hr/>

<h2> HU-7.3 Consultar historial de ventas - <span style="color:blue"> CONSULTA</span></h2>

**Como** administrador o empleado, **quiero** consultar el historial de ventas **para** revisar las operaciones realizadas en el negocio.

<h4>Criterios de aceptación</h4>

<ul>
    <li>El sistema muestra las ventas registradas.</li>
    <li>El sistema permite filtrar las ventas por fecha.</li>
    <li>El sistema permite filtrar las ventas por usuario.</li>
    <li>El sistema permite filtrar las ventas por producto.</li>
    <li>El sistema permite filtrar las ventas por origen.</li>
    <li>Los orígenes distinguen entre "Venta directa" y "Pedido de cliente entregado".</li>
    <li>Las ventas permanecen disponibles en el historial.</li>
</ul>

<hr/>

<h2> HU-7.4 Anular venta - <span style="color:orange"> ACTUALIZACIÓN</span></h2>

**Como** empleado, **quiero** anular una venta indicando un motivo **para** corregir una operación que ya no debe considerarse válida.

<h4>Criterios de aceptación</h4>

<ul>
    <li>El sistema permite anular una venta.</li>
    <li>Para anular una venta se debe registrar un motivo.</li>
    <li>La venta no se elimina físicamente.</li>
    <li>La venta queda identificada como "Anulada".</li>
    <li>El stock correspondiente se revierte.</li>
    <li>La venta anulada no se contabiliza como ingreso.</li>
    <li>La salida de inventario asociada se revierte.</li>
    <li>El historial de la operación se conserva.</li>
</ul>

<hr/>

<h2> HU-7.5 Registrar venta a crédito - <span style="color:red"> ALTA</span></h2>

**Como** empleado, **quiero** registrar una venta con pago pendiente asociada a un cliente **para** permitir que el cliente pague la compra posteriormente.

<h4>Criterios de aceptación</h4>

<ul>
    <li>El EMPLEADO puede registrar una venta con estado de pago "Pendiente".</li>
    <li>La venta debe estar asociada a un CLIENTE.</li>
    <li>Debe registrarse el monto pendiente.</li>
    <li>Debe registrarse la fecha de la venta.</li>
    <li>Debe registrarse una fecha estimada de pago.</li>
    <li>La venta se registra una sola vez.</li>
    <li>La venta conserva toda su información original.</li>
</ul>

<hr/>

<h2> HU-7.6 Registrar pago de venta pendiente - <span style="color:orange"> ACTUALIZACIÓN</span></h2>

**Como** empleado, **quiero** registrar el pago total o parcial de una venta pendiente **para** actualizar el saldo que el cliente aún debe.

<h4>Criterios de aceptación</h4>

<ul>
    <li>El sistema permite registrar un pago sobre una venta pendiente.</li>
    <li>El pago puede ser total o parcial.</li>
    <li>El sistema actualiza automáticamente el saldo pendiente.</li>
    <li>Cuando el saldo llega a cero, la venta cambia a estado "Pagada".</li>
    <li>El sistema no crea una nueva venta al registrar el pago.</li>
    <li>El sistema conserva el historial de la venta y sus actualizaciones.</li>
    <li>Se registra la fecha y hora de la actualización.</li>
    <li>Se registra el empleado y usuario que realizó la actualización.</li>
</ul>

<hr/>

<h2> HU-7.7 Consultar ventas pendientes - <span style="color:blue"> CONSULTA</span></h2>

**Como** administrador o empleado, **quiero** consultar las ventas pendientes de pago **para** dar seguimiento a las deudas de los clientes.

<h4>Criterios de aceptación</h4>

<ul>
    <li>El sistema muestra las ventas que tienen pago pendiente.</li>
    <li>Se muestra el CLIENTE asociado.</li>
    <li>Se muestra el monto original.</li>
    <li>Se muestra el monto pagado.</li>
    <li>Se muestra el saldo pendiente.</li>
    <li>Se muestra la fecha estimada de pago.</li>
    <li>La información se actualiza después de registrar un pago.</li>
</ul>

