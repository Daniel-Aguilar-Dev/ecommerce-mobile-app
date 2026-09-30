# Módulo 9: Estadísticas y reportes (dashboard)

### Consulta de indicadores operativos y financieros

#### Versión 1.2

<h2> HU-9.1 Resumen financiero por periodo - <span style="color:red"> ALTA</span></h2>

**Como** ADMIN, **quiero** ver un resumen financiero por día, semana o mes **para** entender cómo va el negocio en cada periodo.

<h4>Criterios de aceptación</h4>
<ul>
    <li>Se puede cambiar el periodo entre día, semana y mes.</li>
    <li>El resumen muestra ingresos por ventas, compras de mercancía y pérdidas por mermas del periodo elegido.</li>
    <li>Los datos se recalculan cada vez que se consulta.</li>
    <li>Las ventas anuladas y los pedidos cancelados no se cuentan.</li>
    <li>Este resumen solo es visible para ADMIN.</li>
</ul>

<hr/>

<h2> HU-9.2 Utilidad estimada - <span style="color:yellow"> MEDIA</span></h2>

**Como** ADMIN, **quiero** ver la utilidad estimada del periodo **para** saber si el negocio está ganando o perdiendo dinero.

<h4>Criterios de aceptación</h4>
<ul>
    <li>La utilidad estimada se calcula como: ingresos por ventas − costo de mercancía vendida − pérdidas por mermas.</li>
    <li>El costo de mercancía vendida usa el costo promedio del producto.</li>
    <li>Si el resultado es negativo, se muestra visualmente diferenciado de una utilidad positiva.</li>
    <li>El valor no es editable manualmente.</li>
</ul>

<hr/>

<h2> HU-9.3 Alertas de stock bajo - <span style="color:yellow"> MEDIA</span></h2>

**Como** ADMIN, **quiero** ver la lista de productos con stock bajo desde el dashboard **para** saber qué necesito reabastecer.

<h4>Criterios de aceptación</h4>
<ul>
    <li>Aparece un producto en la lista cuando su stock actual es menor o igual a su stock mínimo.</li>
    <li>Cada elemento muestra nombre, stock actual y stock mínimo.</li>
    <li>Al registrar una entrada que supera el mínimo, el producto sale de la lista.</li>
    <li>Los productos descontinuados no aparecen en las alertas.</li>
</ul>

<hr/>

<h2> HU-9.4 Clientes con adeudos (pagos pendientes) - <span style="color:yellow"> MEDIA</span></h2>

**Como** ADMIN, **quiero** ver qué clientes tienen pagos pendientes y el monto total adeudado **para** dar seguimiento al cobro de las ventas fiadas.

<h4>Criterios de aceptación</h4>
<ul>
    <li>Se muestra el monto total pendiente sumando todos los clientes con saldo.</li>
    <li>Se lista por cliente: monto pendiente y fecha estimada de pago, ordenado por fecha.</li>
    <li>Las ventas con fecha estimada vencida se resaltan visualmente.</li>
    <li>Al registrarse un pago, total o parcial, los montos se actualizan automáticamente.</li>
    <li>Las ventas anuladas no cuentan como pendientes.</li>
</ul>

<hr/>

<h2> HU-9.5 Control de acceso y cálculo confiable del dashboard - <span style="color:green"> TRANSVERSAL</span></h2>

**Como** ADMIN, **quiero** que el dashboard respete los permisos por rol y calcule siempre desde datos confirmados **para** que la información sea segura y consistente.

<h4>Criterios de aceptación</h4>
<ul>
    <li>El CLIENTE no puede acceder al dashboard ni a sus datos.</li>
    <li>El EMPLEADO no ve este dashboard (queda reservado a ADMIN, dado que incluye costos, utilidades y adeudos).</li>
    <li>Todas las métricas se calculan al consultar a partir de los datos crudos, sin cifras guardadas y editables.</li>
    <li>Ninguna métrica cuenta ventas anuladas ni pedidos cancelados.</li>
</ul>