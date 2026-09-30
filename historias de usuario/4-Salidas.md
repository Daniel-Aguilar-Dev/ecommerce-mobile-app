# Módulo 4: Gestión de salidas

### Registro de salidas y movimientos por venta o entrega

#### Versión 1.2

<h2> HU-4.1 Registrar salida por pérdida o merma - <span style="color:red"> ALTA</span></h2>

**Como** administrador o empleado autorizado, **quiero** registrar pérdidas o mermas **para** actualizar las existencias y reflejar las pérdidas en los reportes financieros.

<h4>Criterios de aceptación</h4>
<ul>
    <li>El sistema registra producto, cantidad, motivo, fecha y observaciones, asociando automáticamente el usuario y la fecha/hora del registro.</li>
    <li>Los motivos disponibles son: dañado, vencido, robo/extravío, error de conteo y uso interno.</li>
    <li>Al registrar una merma de 3 unidades para un producto con 10 unidades disponibles y sin reservas, el stock queda en 7.</li>
    <li>Si la cantidad es cero, negativa o superior al stock disponible, o falta el motivo, el sistema informa el error y no registra la salida.</li>
    <li>La merma se contabiliza como pérdida, sin clasificarse como venta ni gasto operativo.</li>
    <li>El movimiento conserva su historial y el EMPLEADO no puede consultar su efecto financiero.</li>
    <li>Los usuarios sin autorización no pueden registrar mermas.</li>
</ul>

<hr/>

<h2> HU-4.2 Generar salida automática por venta presencial - <span style="color:green"> AUTOMÁTICA</span></h2>

**Como** administrador o empleado autorizado, **quiero** que al confirmar una venta presencial se genere automáticamente la salida de sus productos **para** actualizar el inventario sin registrar el movimiento dos veces.

<h4>Criterios de aceptación</h4>
<ul>
    <li>Al confirmar la venta, se genera una salida por cada producto, vinculada a la venta, al usuario responsable y a la fecha/hora.</li>
    <li>Al vender 2 unidades de un producto con 10 unidades disponibles y sin reservas, el stock queda en 8.</li>
    <li>Si algún producto no tiene disponibilidad suficiente, considerando las reservas de otros pedidos, no se confirma la venta ni se aplican descuentos parciales.</li>
    <li>Una venta con pago pendiente descuenta el stock al confirmarse; registrar posteriormente el pago no genera otra salida.</li>
    <li>Repetir la confirmación de una venta ya registrada no duplica los movimientos.</li>
    <li>Al anular la venta, se restituyen las cantidades y se revierte su efecto en las estadísticas, conservando el historial.</li>
</ul>

<hr/>

<h2> HU-4.3 Generar salida automática por entrega de pedido - <span style="color:green"> AUTOMÁTICA</span></h2>

**Como** administrador o empleado autorizado, **quiero** que al entregar un pedido se genere automáticamente la salida de sus productos **para** actualizar el inventario y conservar la relación entre pedido, venta y entrega.

<h4>Criterios de aceptación</h4>
<ul>
    <li>Crear un pedido no descuenta stock físico; confirmarlo reserva unidades y reduce su disponibilidad para otras compras.</li>
    <li>Con 10 unidades físicas y sin otras reservas, confirmar un pedido de 3 unidades mantiene el stock físico en 10 y deja 7 disponibles.</li>
    <li>Al entregar ese pedido, el stock físico queda en 7, se consume su reserva y la disponibilidad permanece en 7.</li>
    <li>La entrega registra el método de pago, usuario y fecha/hora, y genera una venta y las salidas correspondientes vinculadas al pedido.</li>
    <li>Si no hay existencias suficientes para completar la entrega, el sistema informa el problema y no marca el pedido como entregado.</li>
    <li>Repetir la entrega de un pedido ya entregado no duplica la venta ni descuenta nuevamente el inventario.</li>
    <li>Cancelar un pedido confirmado antes de entregarlo libera su reserva sin generar una salida física.</li>
    <li>El rol CLIENTE no puede marcar pedidos como entregados.</li>
</ul>