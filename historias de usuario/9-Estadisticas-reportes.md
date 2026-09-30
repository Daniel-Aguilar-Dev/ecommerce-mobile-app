# Módulo 10: Estadísticas y reportes (dashboard)

### US-DB-01 · Resumen financiero por periodo
 
**Como** ADMIN, **quiero** ver un resumen financiero por día, semana o mes **para** entender cómo va el negocio en cada periodo.
 
**Criterios de aceptación:**
1. Se puede cambiar el periodo entre día, semana y mes.
2. El resumen muestra ingresos por ventas, compras de mercancía y pérdidas por mermas del periodo elegido.
3. Los datos se recalculan cada vez que se consulta.
4. Las ventas anuladas y los pedidos cancelados no se cuentan.
5. Este resumen solo es visible para ADMIN.
---
 
### US-DB-02 · Utilidad estimada
 
**Como** ADMIN, **quiero** ver la utilidad estimada del periodo **para** saber si el negocio está ganando o perdiendo dinero.
 
**Criterios de aceptación:**
1. La utilidad estimada se calcula como: ingresos por ventas − costo de mercancía vendida − pérdidas por mermas.
2. El costo de mercancía vendida usa el costo promedio del producto.
3. Si el resultado es negativo, se muestra visualmente diferenciado de una utilidad positiva.
4. El valor no es editable manualmente.

⚠️ Señal para el equipo: sin restar gastos operativos, esto deja de ser una "utilidad neta" en sentido estricto (es más bien utilidad bruta operativa). Confirmar con el Product Owner si se debe renombrar la historia/métrica antes de cerrar el sprint.
---
 
### US-DB-03 · Alertas de stock bajo
 
**Como** ADMIN, **quiero** ver la lista de productos con stock bajo desde el dashboard **para** saber qué necesito reabastecer.
 
**Criterios de aceptación:**
1. Aparece un producto en la lista cuando su stock actual es menor o igual a su stock mínimo.
2. Cada elemento muestra nombre, stock actual y stock mínimo.
3. Al registrar una entrada que supera el mínimo, el producto sale de la lista.
4. Los productos descontinuados no aparecen en las alertas.
---
 
### US-DB-04 · Clientes con adeudos (pagos pendientes)
 
**Como** ADMIN, **quiero** ver qué clientes tienen pagos pendientes y el monto total adeudado **para** dar seguimiento al cobro de las ventas fiadas.
 
**Criterios de aceptación:**
1. Se muestra el monto total pendiente sumando todos los clientes con saldo.
2. Se lista por cliente: monto pendiente y fecha estimada de pago, ordenado por fecha.
3. Las ventas con fecha estimada vencida se resaltan visualmente.
4. Al registrarse un pago, total o parcial, los montos se actualizan automáticamente.
5. Las ventas anuladas no cuentan como pendientes.
---
 
### US-DB-06 · Control de acceso y cálculo confiable del dashboard *(tarea técnica, transversal)*
 
**Como** ADMIN, **quiero** que el dashboard respete los permisos por rol y calcule siempre desde datos confirmados **para** que la información sea segura y consistente.
 
**Criterios de aceptación:**
1. El CLIENTE no puede acceder al dashboard ni a sus datos.
2. El EMPLEADO no ve este dashboard (queda reservado a ADMIN, dado que incluye costos, utilidades y adeudos).
3. Todas las métricas se calculan al consultar a partir de los datos crudos, sin cifras guardadas y editables.
4. Ninguna métrica cuenta ventas anuladas ni pedidos cancelados.
---