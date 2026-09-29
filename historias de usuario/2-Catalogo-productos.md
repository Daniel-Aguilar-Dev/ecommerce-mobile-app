# Módulo 2: Gestión de productos

### Gestión del catálogo de productos de la tienda y sus categorias

#### Versión 1.2

<h2> HU-2.1 Registrar producto - <span style="color:red"> ALTA</span></h2>

**Como** administrador, **quiero** dar de alta un nuevo producto en el catálogo **para** que los clientes puedan elegirlo y comprarlo.

<h4>Criterios de aceptación</h4>
<ul>
    <li>El formulario solicita nombre, descripción, SKU/código de barras, categoría, precio de compra, precio de venta, stock actual, stock mínimo, unidad de medida e imagen; todos son obligatorios.
    </li>
    <li>
    Si un campo obligatorio está vacío, se resalta el campo y se muestra su mensaje de error debajo, sin procesar el formulario.</li>
    <li>
    Si el nombre ya existe, muestra el error "Ya existe un producto con ese nombre".</li>
    <li>
    Si el SKU ya existe, muestra un error de SKU duplicado.</li>
    <li>
     El nombre admite máximo 50 caracteres y la descripción máximo 300.</li>
    <li>
     Los precios de compra y venta deben ser mayores a cero.</li>
    <li>
    El stock actual y el stock mínimo deben ser numéricos y mayores a cero; el stock actual debe ser mayor al mínimo.</li>
    <li>
      La imagen puede tomarse con la cámara o elegirse de la galería.</li>
    <li>
     Si no existen categorías registradas, el registro no puede continuar.</li>
    <li>
     Al guardar, el producto queda en estado "activo", aparece en la lista y se muestra "Producto registrado correctamente".</li>
    <li>
    Solo el ADMIN con sesión iniciada puede registrar productos.</li>
</ul>

<hr/>

<h2> HU-2.2 Consultar productos - <span style="color:red"> ALTA</span></h2>

**Como** usuario del sistema, **quiero** consultar los productos disponibles **para** añadirlos a mi carrito (cliente) o gestionarlos (empleado/administrador).

<h4>Criterios de aceptación</h4>
<ul>
    <li>Se muestra el listado de productos registrados.</li>
    <li>Se puede filtrar por nombre y por categoría.</li>
    <li>La vista del CLIENTE solo muestra productos activos y con stock disponible.</li>
    <li>La vista del personal permite además filtrar por stock bajo o sin stock.</li>
    <li>Si no hay productos o ninguno cumple los filtros, se muestra una pantalla de lista vacía.</li>
    <li>La vista del personal requiere sesión iniciada.</li>
</ul>

<hr/>

<h2> HU-2.3 Consultar detalle de un producto - <span style="color:red"> ALTA</span></h2>

**Como** usuario del sistema, **quiero** ver los datos de un producto **para** comprarlo (cliente) o administrarlo (empleado/administrador).

<h4>Criterios de aceptación</h4>
<ul>
    <li>Se muestra la información del producto seleccionado.</li>
    <li>Si el producto no se encuentra, se muestra una pantalla de registro no encontrado.</li>
    <li>El CLIENTE ve nombre, descripción, imagen, precio de venta y disponibilidad, y desde aquí puede agregarlo al carrito.</li>
    <li>Si el producto no tiene stock, al CLIENTE solo se le muestra la leyenda "Agotado".</li>
    <li>El personal ve además datos internos del producto, en una vista distinta a la del cliente.</li>
    <li>Cuando stock actual ≤ stock mínimo, se muestra la alerta de "stock bajo" solo a ADMIN/EMPLEADO.</li>
</ul>

<hr/>

<h2> HU-2.4 Buscar un producto por código de barras - <span style="color:yellow"> MEDIA</span></h2>

**Como** empleado, **quiero** escanear el código de barras/SKU de un producto **para** obtener su información en el sistema.

<h4>Criterios de aceptación</h4>
<ul>
    <li>Al escanear un código válido, se muestra el producto asociado.</li>
    <li> Si el código no corresponde a ningún producto, se muestra una pantalla de registro no encontrado.</li>
    <li>Tras escanear, el empleado puede asignar el producto a una venta o solo consultar su información.</li>
    <li> Para agregar un producto a una venta, debe haberse escaneado.</li>
    <li>Requiere sesión iniciada.</li>D
</ul>
    
<hr/>

<h2> HU-2.5 Modificar producto - <span style="color:red"> ALTA</span></h2>

**Como** administrador, **quiero** modificar los datos de un producto existente **para** mantener el catálogo correcto y actualizado.

<h4>Criterios de aceptación</h4>
<ul>
    <li>Se pueden editar nombre, descripción, SKU, categoría, precio de compra, precio de venta, stock mínimo, unidad de medida e imagen.</li>
    <li>Si el nombre pertenece a otro producto, muestra "Ya existe un producto con ese nombre".</li>
    <li>Si el SKU pertenece a otro producto, muestra un error de SKU duplicado.</li>
    <li>Se mantienen las mismas validaciones de longitud y valores mayores a cero que en el registro (US-2.1)</li>
    <li> Los errores se muestran debajo del campo correspondiente.</li>
    <li>El stock actual no es editable; solo cambia mediante movimientos de entrada o salida.</li>
    <li>Si no existen categorías registradas, la modificación no puede continuar.</li>
    <li>Al guardar, se muestra "Producto actualizado correctamente" y la lista refleja los cambios.</li>
    <li>Solo el ADMIN con sesión iniciada puede modificar productos.</li>
    </ul>

<hr/>

<h2> HU-2.6 Cambiar estado de un producto - <span style="color:yellow"> MEDIA</span></h2>

**Como** administrador, **quiero** cambiar el estado de un producto (activo/descontinuado) **para** limitar su disponibilidad según lo siga distribuyendo o no.

<h4>Criterios de aceptación</h4>
<ul>
    <li> El administrador puede alternar un producto entre "activo" y "descontinuado".</li>
    <li>Al cambiar el estado se muestra "Producto descontinuado correctamente" o "Producto disponible nuevamente".</li>
    <li>Un producto descontinuado o sin stock no aparece como comprable en el catálogo del CLIENTE.</li>
    <li>El producto descontinuado se conserva en el sistema para el historial.</li>
    <li>Requiere sesión iniciada como ADMIN.</li>
</ul>

<hr/>

<h2> HU-2.7 Eliminar producto - <span style="color:orange"> BAJA</span></h2>

**Como** administrador, **quiero** eliminar un producto **para** que ya no aparezca en el catálogo.

<h4>Criterios de aceptación</h4>
<ul>
    <li>Si el producto no tiene movimientos asociados, se elimina y se muestra "Producto eliminado correctamente".</li>
    <li>Si el producto está asociado a algún movimiento (venta, entrada, salida, etc.), el sistema no permite eliminarlo e indica que debe descontinuarse.</li>
    <li>Antes de eliminar se solicita confirmación al administrador.</li>
    <li> Solo el ADMIN con sesión iniciada puede eliminar productos; el EMPLEADO no.</li>
</ul>

<hr/>

<h2> HU-2.8 Registrar categoria de productos - <span style="color:red"> ALTA</span></h2>

**Como** administrador, **quiero** dar de alta una categoría **para** agrupar los productos y facilitar su búsqueda y gestión.

<h4>Criterios de aceptación</h4>
<ul>
    <li>El formulario solicita nombre y descripción; ambos son obligatorios.</li>
    <li>Si un campo obligatorio está vacío, se resalta y se muestra su error sin procesar el formulario.</li>
    <li>Si el nombre ya existe, muestra "Ya existe una categoría con ese nombre".</li>
    <li>El nombre solo puede contener letras y tiene máximo 50 caracteres; la descripción, máximo 300.</li>
    <li>Los errores se muestran debajo del campo correspondiente.</li>
    <li>Al guardar, la categoría aparece en la lista y se muestra "Categoría registrada correctamente".</li>
    <li>Solo el ADMIN con sesión iniciada puede registrar categorías.</li>
</ul>

<hr/>

<h2> HU-2.9 Consultar categorias de productos - <span style="color:yellow"> MEDIA</span></h2>

**Como** administrador o empleado, **quiero** ver las categorías registradas **para** conocer cómo está organizado el catálogo.

<h4>Criterios de aceptación</h4>
<ul>
    <li>Se muestra la lista de categorías registradas.</li>
    <li>Si no hay categorías, se muestra una pantalla de lista vacía.</li>
    <li>Requiere sesión iniciada como ADMIN o EMPLEADO.</li>
</ul>

<hr/>

<h2> HU-2.10 Modificar categoria de productos - <span style="color:yellow"> MEDIA</span></h2>

**Como** administrador, **quiero** modificar los datos de una categoría **para** corregir información ingresada incorrectamente.

<h4>Criterios de aceptación</h4>
<ul>
    <li>Se pueden editar el nombre y la descripción.</li>
    <li>Si el nombre pertenece a otra categoría, muestra "Ya existe una categoría con ese nombre".</li>
    <li>El nombre solo puede contener letras y tiene máximo 50 caracteres; la descripción, máximo 300.</li>
    <li>Los errores se muestran debajo del campo correspondiente.</li>
    <li>Al guardar, la lista refleja el cambio y se muestra "Categoría actualizada correctamente".</li>
    <li>Solo el ADMIN con sesión iniciada puede modificar categorías.</li>
</ul>

<hr/>

<h2> HU-2.11 Eliminar categorias de productos - <span style="color:orange"> BAJA</span></h2>

**Como** administrador, **quiero** eliminar una categoría que ya no utilizo **para** que deje de aparecer en la lista.

<h4>Criterios de aceptación</h4>
<ul>
    <li>Si la categoría no tiene productos asociados, se elimina y se muestra "Categoría eliminada correctamente".</li>
    <li>Si la categoría está asociada a uno o más productos, el sistema no permite eliminarla.</li>
    <li>Antes de eliminar se solicita confirmación.</li>
    <li>Requiere sesión iniciada como ADMIN.</li>
</ul>
