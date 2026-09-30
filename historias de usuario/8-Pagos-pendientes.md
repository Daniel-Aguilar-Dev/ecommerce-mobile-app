# Módulo 9: Control de pagos pendientes

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