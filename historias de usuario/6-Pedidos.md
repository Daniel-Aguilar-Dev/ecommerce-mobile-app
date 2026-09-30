# Módulo 6: Gestión de pedidos

### Gestión y seguimiento de pedidos de clientes

#### Versión 1.2

<h2> HU-6.1 Generar pedido - <span style="color:red"> ALTA</span></h2>

**Como** cliente, **quiero** generar un pedido a partir de mi carrito confirmado **para** solicitar los productos que deseo recoger en la tienda.

<h4>Criterios de aceptación</h4>

<ul>
    <li>El sistema permite generar un pedido a partir de un carrito confirmado.</li>
    <li>El pedido contiene los productos seleccionados y sus cantidades.</li>
    <li>El pedido conserva el precio de venta de cada producto al momento de generar el pedido.</li>
    <li>El pedido registra la fecha y hora de creación.</li>
    <li>El pedido queda asociado al CLIENTE que lo generó.</li>
    <li>El pedido se crea inicialmente con estado "Pendiente".</li>
    <li>La creación del pedido no descuenta el stock del producto.</li>
</ul>

<hr/>

<h2> HU-6.2 Consultar mis pedidos - <span style="color:blue"> CONSULTA</span></h2>

**Como** cliente, **quiero** consultar el historial de mis pedidos **para** conocer los pedidos que he realizado y su estado actual.

<h4>Criterios de aceptación</h4>

<ul>
    <li>El sistema muestra al CLIENTE sus pedidos realizados.</li>
    <li>El CLIENTE únicamente puede consultar sus propios pedidos.</li>
    <li>Cada pedido muestra los productos y cantidades solicitadas.</li>
    <li>Cada pedido muestra su estado actual.</li>
    <li>El sistema permite consultar pedidos en estado "Pendiente", "Confirmado", "Listo para recoger", "Entregado" o "Cancelado".</li>
    <li>Los pedidos conservan su historial y no se eliminan físicamente.</li>
</ul>

<hr/>

<h2> HU-6.3 Cancelar pedido pendiente - <span style="color:orange"> ACTUALIZACIÓN</span></h2>

**Como** cliente, **quiero** cancelar un pedido que se encuentre pendiente **para** detener la solicitud antes de que sea confirmada por la tienda.

<h4>Criterios de aceptación</h4>

<ul>
    <li>El CLIENTE puede cancelar únicamente sus propios pedidos.</li>
    <li>La opción de cancelar está disponible solamente cuando el pedido tiene estado "Pendiente".</li>
    <li>Al cancelar el pedido, su estado cambia a "Cancelado".</li>
    <li>El pedido cancelado permanece disponible en el historial.</li>
    <li>El CLIENTE no puede cancelar directamente un pedido que ya haya sido confirmado por la tienda.</li>
</ul>

<hr/>

<h2> HU-6.4 Consultar pedidos entrantes - <span style="color:blue"> CONSULTA</span></h2>

**Como** empleado, **quiero** consultar los pedidos realizados por los clientes **para** revisar y gestionar las solicitudes que debe preparar la tienda.

<h4>Criterios de aceptación</h4>

<ul>
    <li>El EMPLEADO puede consultar la lista de pedidos entrantes.</li>
    <li>La lista permite filtrar los pedidos por estado.</li>
    <li>Los estados disponibles son "Pendiente", "Confirmado", "Listo para recoger", "Entregado" y "Cancelado".</li>
    <li>El sistema muestra la información necesaria para identificar cada pedido.</li>
    <li>Cada pedido está asociado al CLIENTE que lo realizó.</li>
</ul>

<hr/>

<h2> HU-6.5 Confirmar pedido - <span style="color:orange"> ACTUALIZACIÓN</span></h2>

**Como** empleado, **quiero** confirmar un pedido pendiente **para** aceptar la solicitud y reservar las existencias necesarias para prepararlo.

<h4>Criterios de aceptación</h4>

<ul>
    <li>El EMPLEADO puede confirmar únicamente pedidos con estado "Pendiente".</li>
    <li>Antes de confirmar, el sistema valida que exista stock real disponible.</li>
    <li>Si existe disponibilidad, el estado cambia a "Confirmado".</li>
    <li>Al confirmarse, las cantidades del pedido quedan reservadas lógicamente.</li>
    <li>El stock reservado deja de considerarse disponible para otros clientes.</li>
    <li>La confirmación queda asociada al usuario que realizó la acción.</li>
</ul>

<hr/>

<h2> HU-6.6 Rechazar pedido - <span style="color:orange"> ACTUALIZACIÓN</span></h2>

**Como** empleado, **quiero** rechazar un pedido cuando no pueda ser atendido **para** evitar comprometer productos que no están realmente disponibles.

<h4>Criterios de aceptación</h4>

<ul>
    <li>El EMPLEADO puede rechazar un pedido cuando corresponda.</li>
    <li>El sistema solicita obligatoriamente un motivo de rechazo.</li>
    <li>El pedido cambia a estado "Cancelado".</li>
    <li>Si el pedido tenía stock reservado, este se libera automáticamente.</li>
    <li>El pedido cancelado permanece disponible en el historial.</li>
    <li>El sistema registra el usuario que realizó la acción.</li>
</ul>

<hr/>

<h2> HU-6.7 Marcar pedido como listo para recoger - <span style="color:orange"> ACTUALIZACIÓN</span></h2>

**Como** empleado, **quiero** marcar un pedido confirmado como "Listo para recoger" **para** indicar que la tienda ya preparó físicamente el pedido.

<h4>Criterios de aceptación</h4>

<ul>
    <li>Solo puede marcarse como "Listo para recoger" un pedido que se encuentre en estado "Confirmado".</li>
    <li>El estado del pedido cambia a "Listo para recoger".</li>
    <li>El sistema conserva el historial del cambio de estado.</li>
    <li>El cambio queda asociado al usuario que lo realizó.</li>
</ul>

<hr/>

<h2> HU-6.8 Generar código QR para pedido listo para recoger - <span style="color:green"> AUTOMÁTICA</span></h2>

**Como** cliente, **quiero** obtener un código QR cuando mi pedido esté listo para recoger **para** identificar mi pedido al momento de recogerlo en la tienda.

<h4>Criterios de aceptación</h4>

<ul>
    <li>El sistema genera un código QR asociado al pedido cuando este cambia al estado "Listo para recoger".</li>
    <li>El código QR debe estar asociado únicamente al pedido correspondiente.</li>
    <li>El CLIENTE puede visualizar el código QR desde el detalle de su pedido.</li>
    <li>El código QR no debe mostrarse mientras el pedido se encuentre en estado "Pendiente" o "Confirmado".</li>
    <li>El código QR debe permanecer disponible mientras el pedido se encuentre en estado "Listo para recoger".</li>
    <li>El código QR no debe permitir identificar ni consultar pedidos pertenecientes a otros clientes.</li>
    <li>El pedido conserva su código QR durante todo su historial.</li>
</ul>

<hr/>

<h2> HU-6.9 Escanear código QR del pedido - <span style="color:orange"> ACTUALIZACIÓN</span></h2>

**Como** empleado, **quiero** escanear el código QR presentado por el cliente **para** identificar rápidamente el pedido que va a recoger.

<h4>Criterios de aceptación</h4>

<ul>
    <li>El EMPLEADO puede acceder a la función para escanear códigos QR.</li>
    <li>El sistema permite utilizar la cámara del dispositivo para escanear el código QR.</li>
    <li>Al escanear un código válido, el sistema identifica el pedido asociado.</li>
    <li>El sistema muestra los datos necesarios del pedido para que el EMPLEADO pueda verificarlo.</li>
    <li>El sistema muestra el CLIENTE asociado al pedido.</li>
    <li>El sistema muestra los productos y cantidades incluidos en el pedido.</li>
    <li>El sistema muestra el estado actual del pedido.</li>
    <li>Si el código QR no es válido, el sistema muestra un mensaje indicando que el código no corresponde a un pedido válido.</li>
    <li>Si el pedido ya fue entregado o cancelado, el sistema informa que el pedido no puede ser entregado nuevamente.</li>
    <li>El escaneo queda asociado al usuario que realizó la acción.</li>
</ul>

<hr/>

<h2> HU-6.10 Confirmar entrega mediante código QR - <span style="color:orange"> ACTUALIZACIÓN</span></h2>

**Como** empleado, **quiero** confirmar la entrega del pedido después de escanear su código QR **para** asegurar que estoy entregando el pedido correcto al cliente.

<h4>Criterios de aceptación</h4>

<ul>
    <li>El EMPLEADO puede confirmar la entrega después de identificar correctamente el pedido mediante el código QR.</li>
    <li>El sistema verifica que el pedido se encuentre en estado "Listo para recoger".</li>
    <li>El sistema muestra la información del pedido antes de solicitar la confirmación de entrega.</li>
    <li>El EMPLEADO debe confirmar la entrega de forma explícita.</li>
    <li>Al confirmar la entrega, el pedido cambia a estado "Entregado".</li>
    <li>El sistema solicita y registra el método de pago utilizado por el cliente.</li>
    <li>Al completar la entrega, se genera automáticamente la venta asociada al pedido.</li>
    <li>Al completar la entrega, se genera automáticamente la salida de inventario correspondiente.</li>
    <li>La venta generada queda vinculada al pedido original.</li>
    <li>El sistema registra el usuario y la fecha y hora en que se confirmó la entrega.</li>
</ul>

