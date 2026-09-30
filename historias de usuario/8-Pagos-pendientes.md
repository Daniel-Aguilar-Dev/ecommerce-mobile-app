# Módulo 8: Control de pagos pendientes

### Seguimiento y actualización de ventas pendientes de pago

#### Versión 1.2

<h2> HU-8.1 Actualizar una venta pendiente a “Pagada” - <span style="color:red"> ALTA</span></h2>

**Como** EMPLEADO, **quiero** actualizar el estado de pago de una venta pendiente a “Pagada” **para** reflejar que el cliente liquidó su deuda.

<h4>Criterios de aceptación</h4>
<ul>
    <li>Solo una venta en estado “Pendiente” puede actualizarse a “Pagada”.</li>
    <li>Al actualizar, el sistema registra fecha y hora de la actualización, el empleado que la realizó y el usuario con sesión activa.</li>
    <li>La venta original no se duplica; se actualiza el mismo registro.</li>
    <li>La información original de la venta (productos, montos, fecha) se conserva sin cambios.</li>
    <li>El sistema conserva el historial completo de actualizaciones de estado de pago de esa venta.</li>
</ul>

<hr/>

<h2> HU-8.2 Consultar ventas con pago pendiente - <span style="color:yellow"> MEDIA</span></h2>

**Como** ADMIN o EMPLEADO, **quiero** consultar las ventas con pago pendiente y su fecha estimada de pago **para** dar seguimiento a la cobranza.

<h4>Criterios de aceptación</h4>
<ul>
    <li>El listado muestra cliente asociado, monto original, monto pagado, saldo pendiente y fecha estimada de pago.</li>
    <li>Se puede filtrar por cliente o por rango de fechas.</li>
    <li>Una venta anulada no aparece en este listado.</li>
    <li>Al tocar una venta se puede ver su historial de actualizaciones de pago.</li>
</ul>