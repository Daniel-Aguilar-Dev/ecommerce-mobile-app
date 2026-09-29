# Módulo 4: Salidas de inventario

## 3.4 Salidas de inventario

**Descripción:** Registro de disminuciones de mercancía por ventas, entrega de pedidos y pérdidas o mermas, conservando la trazabilidad y diferenciando su efecto financiero.

### HU-3.4-01 — Registrar salida por pérdida o merma

**Usuario:** Administrador / Empleado.

**Descripción:** Como usuario con permiso **inventario.salidas.registrar_merma**, quiero registrar las pérdidas o mermas de productos para mantener las existencias actualizadas y reflejar su efecto en los reportes financieros.

**Datos de entrada:**

- Producto* — Selección de un producto del catálogo.
- Cantidad* — Numérico, de acuerdo con la unidad de medida.
- Motivo* — Selección: dañado, vencido, robo/extravío, error de conteo o uso interno.
- Fecha de la salida* — Fecha.
- Observaciones — Texto.
- Usuario que registra* — Obtenido automáticamente de la sesión activa.
- Fecha y hora del registro* — Generadas automáticamente por el sistema.

**Datos de salida:**

- Movimiento registrado como salida por pérdida o merma.
- Stock del producto reducido según la cantidad registrada.
- Movimiento asociado al motivo, fecha y usuario responsable.
- Pérdida considerada en los reportes financieros de ADMIN.
- Mensaje de confirmación: “La salida por pérdida o merma se ha registrado correctamente”.

**Nota:**

- El símbolo (*) indica los datos obligatorios.
- Se propone que las observaciones sean opcionales, ya que el documento no establece su obligatoriedad.
- El EMPLEADO registra la cantidad y el motivo, sin acceder a costos ni utilidades.

**Reglas de negocio:**

- Se requiere una sesión activa y el permiso correspondiente.
- El rol CLIENTE no puede registrar mermas.
- El producto debe existir en el catálogo.
- La cantidad debe ser mayor que cero y no superar el stock disponible.
- El motivo debe corresponder a una de las opciones definidas.
- La salida reduce automáticamente el stock; no se permite editar las existencias directamente.
- La merma se contabiliza como pérdida y afecta negativamente la utilidad.
- La pérdida se distingue de un gasto operativo y de una salida por venta.
- Se conserva el movimiento con su usuario y fecha/hora, sin eliminación física.

**Criterios de aceptación:**

- Al registrar una merma de 3 unidades para un producto con 10 unidades disponibles y sin reservas, el stock queda en 7.
- Si la cantidad supera el stock disponible, el sistema muestra “La cantidad supera el stock disponible” y no registra la salida.
- Si la cantidad es cero o negativa, o falta el motivo, el sistema solicita corregir los datos.
- La salida registrada conserva producto, cantidad, motivo, fecha, usuario y observaciones cuando se proporcionen.
- La operación se refleja como pérdida en los reportes financieros, sin clasificarse como gasto operativo ni venta.
- Un CLIENTE o usuario sin autorización no puede ejecutar la operación.

### HU-3.4-02 — Generar salida automática por venta presencial

**Usuario:** Administrador / Empleado.

**Descripción:** Como usuario autorizado para registrar ventas, quiero que al confirmar una venta presencial se genere automáticamente la salida de los productos vendidos para mantener actualizado el inventario sin capturar el movimiento dos veces.

**Datos de entrada:**

- Identificador de la venta* — Generado por el módulo de ventas.
- Productos vendidos* — Obtenidos del detalle de la venta.
- Cantidad de cada producto* — Numérico.
- Fecha y hora de confirmación* — Generadas por el sistema.
- Usuario responsable* — Obtenido de la sesión que confirma la venta.

**Datos de salida:**

- Salida de inventario por cada producto vendido.
- Stock actualizado de los productos.
- Movimientos vinculados a la venta y al usuario responsable.
- Confirmación de que la venta y sus salidas se registraron correctamente.

**Nota:**

- El símbolo (*) indica los datos obligatorios.
- Los datos se reciben del módulo de ventas; no se capturan en un formulario independiente de salidas.
- El permiso propuesto para la operación de origen es **ventas.registrar**.
- Esta historia se integra con el módulo 3.8 Ventas.

**Reglas de negocio:**

- La salida se genera al confirmar la venta presencial.
- Las cantidades deben ser mayores que cero y no superar el stock disponible.
- La disponibilidad debe considerar las unidades reservadas para pedidos, evitando venderlas a otra persona.
- Cada salida conserva la relación con la venta, el producto y el usuario responsable.
- Una venta con pago pendiente también genera su salida de inventario al confirmarse.
- Registrar posteriormente un pago no genera otra salida.
- La misma confirmación no debe duplicar movimientos ni descuentos de stock.
- Al anular una venta, se revierte su efecto sobre el inventario y las estadísticas, conservando el historial.
- Las salidas por venta se distinguen de las pérdidas por merma.

**Criterios de aceptación:**

- Al confirmar una venta de 2 unidades para un producto con 10 unidades disponibles y sin reservas, el stock queda en 8.
- Una venta con varios productos genera una salida vinculada por cada producto.
- Si algún producto no tiene disponibilidad suficiente, el sistema informa el problema y no confirma la venta ni aplica descuentos parciales.
- Al confirmar una venta con pago pendiente, el stock se descuenta una sola vez.
- Al registrar posteriormente el pago, las existencias permanecen sin otro descuento.
- Repetir la solicitud de confirmación de una venta ya registrada no duplica sus salidas.
- Al anular la venta, se restituyen las cantidades correspondientes y se conserva el registro de la anulación.

### HU-3.4-03 — Generar salida automática por entrega de pedido

**Usuario:** Administrador / Empleado.

**Descripción:** Como usuario autorizado para entregar pedidos, quiero que al marcar un pedido como entregado se genere automáticamente la salida de sus productos para actualizar el inventario y conservar la relación entre pedido, venta y entrega.

**Datos de entrada:**

- Identificador del pedido* — Selección de un pedido listo para recoger.
- Productos y cantidades* — Obtenidos del pedido.
- Método de pago* — Efectivo, tarjeta o transferencia; capturado en el flujo de entrega.
- Usuario que entrega* — Obtenido automáticamente de la sesión activa.
- Fecha y hora de entrega* — Generadas automáticamente.

**Datos de salida:**

- Pedido actualizado al estado “Entregado”.
- Venta generada y vinculada al pedido.
- Salida de inventario por cada producto entregado.
- Stock físico reducido y reserva del pedido consumida.
- Registro del usuario y de la fecha/hora de entrega.
- Mensaje de confirmación: “El pedido se ha entregado y el inventario se ha actualizado correctamente”.

**Nota:**

- El símbolo (*) indica los datos obligatorios.
- El permiso propuesto para la operación de origen es **pedidos.entregar**.
- Esta historia se integra con los módulos 3.6 Pedidos de clientes y 3.7 Gestión de pedidos entrantes.
- La reserva de existencias y la salida física son operaciones diferentes.

**Reglas de negocio:**

- Se requiere una sesión activa de ADMIN o EMPLEADO y autorización para entregar pedidos.
- Crear el pedido no descuenta existencias físicas.
- Confirmar el pedido reserva unidades y reduce su disponibilidad para otras compras.
- El descuento físico ocurre cuando el pedido pasa a “Entregado”.
- La entrega genera una venta y una salida por cada producto del pedido.
- La validación de la entrega debe reconocer la reserva del propio pedido, sin tratarla como stock reservado para otro cliente.
- Las reservas de otros pedidos no pueden utilizarse para completar esta entrega.
- La entrega no debe descontar nuevamente la disponibilidad que ya se había reservado.
- Un pedido entregado no puede generar una segunda venta ni nuevas salidas por repetir la operación.
- Cancelar un pedido antes de entregarlo libera su reserva, cuando exista, y no genera una salida por entrega.
- Se conserva la relación entre pedido, venta, movimientos y usuario responsable.

**Criterios de aceptación:**

- Al crear un pedido, el stock físico permanece sin cambios.
- Con 10 unidades físicas y sin otras reservas, confirmar un pedido de 3 unidades mantiene el stock físico en 10 y deja 7 disponibles.
- Al entregar ese pedido, el stock físico queda en 7, su reserva queda consumida y la disponibilidad permanece en 7.
- La entrega genera una venta y las salidas correspondientes, todas vinculadas al mismo pedido.
- Si no se puede completar la entrega por falta de existencias, el sistema informa el problema y no marca el pedido como entregado.
- Repetir la solicitud de entrega de un pedido ya entregado no duplica la venta ni descuenta nuevamente el inventario.
- Si el pedido confirmado se cancela antes de entregarse, se libera su reserva sin registrar una salida física.
- Un CLIENTE no puede marcar su pedido como entregado.