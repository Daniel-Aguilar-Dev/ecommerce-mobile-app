# Módulo 8: Gestión de gastos operativos

### US-GO-01 · Registrar gasto operativo
 
**Como** ADMIN, **quiero** registrar un gasto operativo con concepto, monto, categoría y fecha **para** llevar el control de lo que cuesta operar el negocio.
 
**Criterios de aceptación:**
1. El formulario solicita concepto, monto, categoría y fecha; todos son obligatorios.
2. El monto debe ser mayor a 0; de lo contrario se muestra un error y no se guarda.
3. El gasto queda asociado automáticamente al usuario con sesión activa y a la fecha/hora de registro.
4. Un gasto operativo no modifica el stock ni genera una entrada de inventario.
---
 
### US-GO-02 · Gestionar categorías de gastos
 
**Como** ADMIN, **quiero** crear y editar categorías de gastos (renta, luz, agua, sueldos, mantenimiento, etc.) **para** clasificar los gastos de forma consistente.
 
**Criterios de aceptación:**
1. Se puede crear una categoría con nombre único.
2. Se puede editar el nombre de una categoría existente.
3. Una categoría con gastos asociados no se elimina; se desactiva y deja de aparecer al registrar gastos nuevos.
4. Los gastos históricos conservan su categoría aunque esta se desactive.
---
 
### US-GO-03 · Consultar historial de gastos con filtros
 
**Como** ADMIN, **quiero** ver el historial de gastos y filtrarlo por categoría y rango de fechas **para** revisar en qué se está gastando.
 
**Criterios de aceptación:**
1. El listado muestra concepto, categoría, monto, fecha y usuario que lo registró, ordenado del más reciente al más antiguo.
2. Se puede filtrar por categoría, por rango de fechas o por ambos a la vez.
3. Se muestra el total de los gastos que cumplen el filtro aplicado.
4. Si no hay resultados, se muestra un mensaje de "sin gastos" y no una pantalla vacía.
---
 
### US-GO-04 · Editar y anular un gasto
 
**Como** ADMIN, **quiero** corregir o anular un gasto mal registrado **para** mantener los reportes correctos sin perder trazabilidad.
 
**Criterios de aceptación:**
1. Se puede editar concepto, monto, categoría y fecha de un gasto existente.
2. Anular un gasto exige un motivo obligatorio.
3. Un gasto anulado no se borra: queda visible en el historial marcado como "Anulado".
4. Un gasto anulado no se contabiliza en los totales ni en el dashboard.
5. Se conserva el usuario y la fecha/hora de cada edición o anulación.
---
 
### US-GO-05 · Separar gastos operativos de compras de mercancía
 
**Como** ADMIN, **quiero** que los gastos operativos se contabilicen aparte de las entradas de inventario **para** que los reportes no dupliquen ni confundan ambos conceptos.
 
**Criterios de aceptación:**
1. El total de gastos operativos por periodo se calcula solo con gastos registrados en este módulo.
2. Las compras de mercancía (módulo 3.3) no aparecen en el historial de gastos operativos.
3. El total de gastos operativos se calcula al consultar, a partir de los registros; no se guarda como un número fijo editable.
4. El total puede consultarse por día, semana o mes para alimentar el dashboard (US-DB-01).
---