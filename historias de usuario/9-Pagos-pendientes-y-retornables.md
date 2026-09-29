# Módulo 9: Control de gastos pendientes y retornables

### US-PE-01 · Actualizar una venta pendiente a "Pagada"
 
**Como** EMPLEADO, **quiero** actualizar el estado de pago de una venta pendiente a "Pagada" **para** reflejar que el cliente liquidó su deuda.
 
**Criterios de aceptación:**
1. Solo una venta en estado "Pendiente" puede actualizarse a "Pagada".
2. Al actualizar, el sistema registra fecha y hora de la actualización, el empleado que la realizó y el usuario con sesión activa.
3. La venta original no se duplica; se actualiza el mismo registro.
4. La información original de la venta (productos, montos, fecha) se conserva sin cambios.
5. El sistema conserva el historial completo de actualizaciones de estado de pago de esa venta.
---
 
### US-PE-02 · Consultar ventas con pago pendiente
 
**Como** ADMIN o EMPLEADO, **quiero** consultar las ventas con pago pendiente y su fecha estimada de pago **para** dar seguimiento a la cobranza.
 
**Criterios de aceptación:**
1. El listado muestra cliente asociado, monto original, monto pagado, saldo pendiente y fecha estimada de pago.
2. Se puede filtrar por cliente o por rango de fechas.
3. Una venta anulada no aparece en este listado.
4. Al tocar una venta se puede ver su historial de actualizaciones de pago.
---
 
### US-PE-03 · Registrar envases retornables en una venta
 
**Como** EMPLEADO, **quiero** registrar los envases retornables entregados en una venta, con su importe **para** llevar control de lo que el cliente debe devolver.
 
**Criterios de aceptación:**
1. Se puede registrar uno o varios tipos de envase por venta, indicando cantidad e importe asociado.
2. Cada registro queda vinculado a la venta y al cliente correspondiente.
3. El registro se crea en estado "Pendiente" de devolución.
4. El importe de los envases se muestra por separado del importe de los productos vendidos.
---
 
### US-PE-04 · Registrar devolución de envases
 
**Como** EMPLEADO, **quiero** registrar la devolución total o parcial de los envases prestados a un cliente **para** actualizar cuánto debe devolverse o descontarse.
 
**Criterios de aceptación:**
1. Se puede registrar una devolución parcial o total sobre un registro de envases existente.
2. No se permite registrar una devolución mayor a la cantidad pendiente.
3. La actualización registra cantidad devuelta, fecha y hora, y el empleado con sesión activa (automático, no editable).
4. El sistema calcula el importe a devolver o descontar según la cantidad devuelta.
5. Cuando la cantidad devuelta iguala a la entregada, el registro pasa a estado "Devuelto".
6. El sistema conserva el historial completo de actualizaciones de ese registro de envases.