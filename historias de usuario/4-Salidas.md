### HU-3.4-01
**Registrar salida por pérdida o merma**

**Como** administrador o empleado autorizado, **quiero** registrar pérdidas o mermas **para** actualizar las existencias y reflejar las pérdidas en los reportes financieros.

**CRITERIOS DE ACEPTACIÓN**

1. El sistema registra producto, cantidad, motivo, fecha y observaciones, asociando automáticamente el usuario y la fecha/hora del registro.
2. Los motivos disponibles son: dañado, vencido, robo/extravío, error de conteo y uso interno.
3. Al registrar una merma de 3 unidades para un producto con 10 unidades disponibles y sin reservas, el stock queda en 7.
4. Si la cantidad es cero, negativa o superior al stock disponible, o falta el motivo, el sistema informa el error y no registra la salida.
5. La merma se contabiliza como pérdida, sin clasificarse como venta ni gasto operativo.
6. El movimiento conserva su historial y el EMPLEADO no puede consultar su efecto financiero.
7. Los usuarios sin autorización no pueden registrar mermas.

---

### HU-3.4-02
**Generar salida automática por venta presencial**

**Como** administrador o empleado autorizado, **quiero** que al confirmar una venta presencial se genere automáticamente la salida de sus productos **para** actualizar el inventario sin registrar el movimiento dos veces.

**CRITERIOS DE ACEPTACIÓN**

1. Al confirmar la venta, se genera una salida por cada producto, vinculada a la venta, al usuario responsable y a la fecha/hora.
2. Al vender 2 unidades de un producto con 10 unidades disponibles y sin reservas, el stock queda en 8.
3. Si algún producto no tiene disponibilidad suficiente, considerando las reservas de otros pedidos, no se confirma la venta ni se aplican descuentos parciales.
4. Una venta con pago pendiente descuenta el stock al confirmarse; registrar posteriormente el pago no genera otra salida.
5. Repetir la confirmación de una venta ya registrada no duplica los movimientos.
6. Al anular la venta, se restituyen las cantidades y se revierte su efecto en las estadísticas, conservando el historial.

---

### HU-3.4-03
**Generar salida automática por entrega de pedido**

**Como** administrador o empleado autorizado, **quiero** que al entregar un pedido se genere automáticamente la salida de sus productos **para** actualizar el inventario y conservar la relación entre pedido, venta y entrega.

**CRITERIOS DE ACEPTACIÓN**

1. Crear un pedido no descuenta stock físico; confirmarlo reserva unidades y reduce su disponibilidad para otras compras.
2. Con 10 unidades físicas y sin otras reservas, confirmar un pedido de 3 unidades mantiene el stock físico en 10 y deja 7 disponibles.
3. Al entregar ese pedido, el stock físico queda en 7, se consume su reserva y la disponibilidad permanece en 7.
4. La entrega registra el método de pago, usuario y fecha/hora, y genera una venta y las salidas correspondientes vinculadas al pedido.
5. Si no hay existencias suficientes para completar la entrega, el sistema informa el problema y no marca el pedido como entregado.
6. Repetir la entrega de un pedido ya entregado no duplica la venta ni descuenta nuevamente el inventario.
7. Cancelar un pedido confirmado antes de entregarlo libera su reserva sin generar una salida física.
8. El rol CLIENTE no puede marcar pedidos como entregados.