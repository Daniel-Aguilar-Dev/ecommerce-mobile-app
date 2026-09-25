# Módulo 2: Gestión de productos

### Gestión del catálogo de productos de la tienda y sus categorias

#### Versión 1.1

<h2> HU-2.1 Registrar producto</h2>

<h3>Usuario: Administrador</h3>

<h4>Descripción: Cómo administrador de la tienda, quiero dar de alta un nuevo producto en mi catálogo de productos para que los clientes puedan elegirlo y comprarlo.</h4>

<h4>Datos de entrada</h4>
<ul>
    <li>Nombre<b style="color:red">*</b> -Alfanumérico</li>
    <li>Descripción<b style="color:red">*</b> -Alfanumérico</li>
    <li>SKU/Código de barras<b style="color:red">*</b> -Alfanumérico</li>
    <li>Categoria<b style="color:red">*</b></li>
    <li>Precio de compra<b style="color:red">*</b> -Numérico</li>
    <li>Precio de venta<b style="color:red">*</b> -Numérico</li>
    <li>Stock actual<b style="color:red">*</b> -Numérico</li>
    <li>Stock mínimo<b style="color:red">*</b> -Alfanumérico</li>
    <li>Unidad de medida<b style="color:red">*</b> -Alfanumérico</li>
    <li>Imagen del producto<b style="color:red">*</b></li>
</ul>

<h4>Datos de salida</h4>
<ul>
    <li>Producto registrado visible en la vista de productos</li>
    <li>Alerta de confirmación 'Producto registrado correctamente'</li>
</ul>

<h4>Nota: <i>El símbolo (*) marca los datos que son obligatorios.
</i></h4>

<h4>Criterios de aceptación</h4>
<ul>
    <li>Si se registra una producto con un nombre que ya existe en el sistema, se mostrara una alerta de error 'Ya existe un producto con ese nombre'</li>
    <li>Por defecto al registrar un producto se registra con un estado 'activo' ya que se sobreentiende que al registrar un producto, se cuenta con existencias físicas para su venta</li>
    <li>La imagen del producto puede ser tomada en el momento del registro con la cámara del dispositivo o en su defecto ser seleccionada de la galeria </li>
    <li>Si hay errores de validación, estos mensajes de muestran debajo del campo correspondiente</li>
    <li>Si un campo obligatorio está vacío, el sistema resalta el campo y muestra el mensaje de error correspondiente sin procesar el formulario.</li>
    <li>Si no hay categorias registradas, el registro no podrá continuar</li>
</ul>

<h4>Reglas de negocio</h4>
<ul>
    <li>Se debe iniciar sesión previamente</li>
    <li>El nombre del prodcuto es único</li>
    <li>El código de barras/SKU es único por cada producto no por unidad</li>
    <li>Sólo el administrador puede registrar un producto nuevo</li>
    <li>El nombre del producto tiene una longitud máxima de 50 carácteres</li>
    <li>La descripción del producto tiene una longitud máxima de 300 carácteres</li>
    <li>Tanto el precio de compra como el de venta deben ser mayores a cero</li>
    <li>Tanto el stock actual como el stock mínimo deben ser mayores a cero</li>
    <li>El stock actual debe ser mayor al stock mínimo</li>
    <li>Debe existir al menos una categoria registrada antes del registro del producto <b>(ver HU-2.8)</b></li>
</ul>

<hr/>

<h2> HU-2.2 Consultar productos</h2>

<h3>Usuario: <span style="color:green;">Todos</span></h3>

<h4>Descripción: Cómo usuario del sistema, quiero consultar los productos disponibles para añadirlos a mi carrito (CLIENTE) o para gestionarlos (EMLEADO, ADMINISTRADOR).</h4>

<h4>Datos de entrada</h4>
<ul>
    <li>Nombre del producto -Alfanumérico</li>
    <li>Categoria</li>
    <li>Tiene stock bajo o no</li>
</ul>

<h4>Datos de salida</h4>
<ul>
    <li>Listado de productos registrados</li>
</ul>

<h4>Nota: <i>El símbolo (*) marca los datos que son obligatorios.
</i></h4>

<h4>Criterios de aceptación</h4>
<ul>
    <li>El sistema muestra los productos registrados</li>
    <li>El sistema muestra una pantalla de estado de  lista vacia en caso de no haber productos registrados o si no hay productos que no cumplan con los filtros especificados</li>
</ul>

<h4>Reglas de negocio</h4>
<ul>
    <li>Existe una vista diferente para los clientes en la cual  pueden consultar productos por categoria o buscando un producto por su nombre</li>
    <li>Existe otra vista diferente para el personal en el cual pueden además consultar solo los productos con stock bajo o sin stock</li>
    <li>Se debe iniciar sesión previamente para acceder a la vista para el personal</li>
</ul>

<hr/>

<h2> HU-2.3 Consulta individual de un producto</h2>

<h3>Usuario: <span style="color:green;">Todos</span></h3>

<h4>Descripción: Cómo usuario del sistema, quiero consultar los datos de un producto ya sea para comprarlo (CLIENTE) o para administrarlo (EMPLEADO, ADMINISTRADOR).</h4>

<h4>Datos de entrada</h4>
<ul>
    <li>Id del  producto<b style="color:red">*</b> -Númerico</li>
</ul>

<h4>Datos de salida</h4>
<ul>
    <li>Producto asociado</li>
</ul>

<h4>Nota: <i>El símbolo (*) marca los datos que son obligatorios.
</i></h4>

<h4>Criterios de aceptación</h4>
<ul>
    <li>El sistema muestra el producto solicitado</li>
    <li>Si el producto no se encuentra, se mostrará una pantalla de estado de registro no encontrado</li>
</ul>

<h4>Reglas de negocio</h4>
<ul>
    <li>El cliente puede consultar un producto para agregarlo a su carrito</li>
    <li>El personal del sistema puede ver datos internos del producto en una vista similar a la vista para clientes, pero diferente</li>
    <li>
    Se marca "stock bajo" cuando stock actual <= stock mínimo definido por producto → dispara alerta visual en la app (visible solo para ADMIN/EMPLEADO).</li>
    <li>
    Para los clientes, si el producto no tiene stock, solo se mostrará la leyenda 'Agotado'
    </li>
</ul>

<hr/>

<h2> HU-2.4 Buscar un producto por código de barras</h2>

<h3>Usuario: Empleado</h3>

<h4>Descripción: Cómo empleado de la tienda, quiero escanear el código de barras/SKU de un producto para obtener la información asociada al mismo dentro del sistema.</h4>

<h4>Datos de entrada</h4>
<ul>
    <li>Código de barras/SKU del producto escaneado<b style="color:red">*</b></li>
</ul>

<h4>Datos de salida</h4>
<ul>
    <li>Producto asociado</li>
</ul>

<h4>Nota: <i>El símbolo (*) marca los datos que son obligatorios.
</i></h4>

<h4>Criterios de aceptación</h4>
<ul>
    <li>El sistema muestra el producto asociado al códgio escaneado</li>
    <li>Si el código escaneado no está asociado a ningún producto del sistema, se mostrará una pantalla de estado de registro no encontrado</li>
</ul>

<h4>Reglas de negocio</h4>
<ul>
    <li>Se debe iniciar sesión previamente</li>
    <li>El producto debe ser escaneado para poder agregarlo a la lista de una venta</li>
    <li>Cuando el empleado escanea el código del producto, puede asignar el producto a una venta, o solo consultar su información</li>
</ul>

<hr/>

<h2> HU-2.5 Modificar producto</h2>

<h3>Usuario: Administrador</h3>

<h4>Descripción: Cómo administrador de la tienda, quiero dar de alta un nuevo producto en mi catálogo de productos para que los clientes puedan elegirlo y comprarlo.</h4>

<h4>Datos de entrada</h4>
<ul>
    <li>Nombre -Alfanumérico</li>
    <li>Descripción -Alfanumérico</li>
    <li>SKU/Código de barras -Alfanumérico</li>
    <li>Categoria</li>
    <li>Precio de compra -Numérico</li>
    <li>Precio de venta -Numérico</li>
    <li>Stock mínimo -Alfanumérico</li>
    <li>Unidad de medida -Alfanumérico</li>
    <li>Imagen del producto</li>
</ul>

<h4>Datos de salida</h4>
<ul>
    <li>Producto actualizado visible en la vista de productos</li>
    <li>Alerta de confirmación 'Producto actualizado  correctamente'</li>
</ul>

<h4>Nota: <i>El símbolo (*) marca los datos que son obligatorios.
</i></h4>

<h4>Criterios de aceptación</h4>
<ul>
    <li>Si se actualiza el producto con un nombre que ya existe en el sistema, pero que no pertenezca a este, se mostrara una alerta de error 'Ya existe un producto con ese nombre'</li>
    <li>Si se actualiza SKU de un producto con uno que ya existe en el sistema, pero que no pertenezca a este, se mostrara una alerta de error 'Ya existe una categoria con ese código/SKU'</li>
    <li>La imagen del producto puede ser tomada en el momento del registro con la cámara del dispositivo o en su defecto ser seleccionada de la galeria </li>
    <li>Si hay errores de validación, estos mensajes de muestran debajo del campo correspondiente</li>
    <li>Si no hay categorias registradas, la modificación no podrá continuar</li>
</ul>

<h4>Reglas de negocio</h4>
<ul>
    <li>Se debe iniciar sesión previamente</li>
    <li>El nombre del prodcuto es único</li>
    <li>El código de barras/SKU es único por cada producto no por unidad</li>
    <li>Sólo el administrador puede actualizar los datos de un producto </li>
    <li>El nombre del producto tiene una longitud máxima de 50 carácteres</li>
    <li>La descripción del producto tiene una longitud máxima de 300 carácteres</li>
    <li>Tanto el precio de compra como el de venta deben ser mayores a cero</li>
    <li>El stock mínimo debe ser mayor a cero</li>
    <li>Si se actualiza el stock mínimo, se tomara como rango mínimo el stock actual del producto</li>
    <li>Debe existir al menos una categoria registrada antes de la modificación del producto <b>(ver HU-2.8)</b></li>
    <li>El stock actual no se edita manualmente de forma directa; se modifica únicamente a través de movimientos de entrada o salida (para mantener el historial completo y evitar descuadres).</li>
</ul>

<hr/>

<h2> HU-2.6 Cambiar estado de un producto</h2>

<h3>Usuario: Administrador</h3>

<h4>Descripción: Cómo administrador de la tienda, quiero cambiar el estado de un producto (activo, descontinuado) para limitiar su disponibilidad dependiendo si lo distribuyo o ya no.</h4>

<h4>Datos de entrada</h4>
<ul>
    <li>Producto seleccionado</li>
</ul>

<h4>Datos de salida</h4>
<ul>
    <li>Alerta de confirmación 'Producto descontinuado correctamente'/'Producto disponible nuevamente'</li>
</ul>

<h4>Nota: <i>El símbolo (*) marca los datos que son obligatorios.
</i></h4>

<h4>Criterios de aceptación</h4>
<ul>
    <li>Si un producto está asociado a algún movimiento (venta, entrada, salida etc.), el sistema no permitirá eliminarla</li>
    <li>Un producto descontinuado o sin stock disponible no aparece como comprable en el catálogo del CLIENTE, aunque siga existiendo en el sistema para fines de historial.</li>
</ul>

<h4>Reglas de negocio</h4>
<ul>
    <li>Se debe iniciar sesión previamente</li>
    <li>Un producto no puede eliminarse si tiene movimientos asociados (se descontinúa en su lugar, no se borra)</li>
</ul>

<hr/>

<h2> HU-2.7 Eliminar producto</h2>

<h3>Usuario: Administrador</h3>

<h4>Descripción: Cómo administrador de la tienda, quiero eliminar un producto de forma definitiva para que ya no aparezca en el catalogo de productos.</h4>

<h4>Datos de entrada</h4>
<ul>
    <li>Producto seleccionado</li>
</ul>

<h4>Datos de salida</h4>
<ul>
    <li>Alerta de confirmación 'Producto elimminado correctamente'</li>
</ul>

<h4>Nota: <i>El símbolo (*) marca los datos que son obligatorios.
</i></h4>

<h4>Criterios de aceptación</h4>
<ul>
    <li>Si un producto está asociado a algún movimiento (venta, entrada, salida etc.), el sistema no permitirá eliminarla</li>
</ul>

<h4>Reglas de negocio</h4>
<ul>
    <li>Se debe iniciar sesión previamente</li>
    <li>Un producto no puede eliminarse si tiene movimientos asociados (se descontinúa en su lugar, no se borra)</li>
</ul>

<hr/>

<h2> HU-2.8 Registrar categoria de productos</h2>

<h4>Descripción: Cómo administrador de la tienda, quiero dar de alta una nueva categoria para agrupar los productos registrados, optimizando la búsqueda y gestión de los mismos.</h4>

<h4>Datos de entrada</h4>
<ul>
    <li>Nombre<b style="color:red">*</b> -Alfanumérico</li>
    <li>Descripción<b style="color:red">*</b> -Alfanumérico</li>
</ul>

<h4>Datos de salida</h4>
<ul>
    <li>Categoria registrada visible en la vista de catregorias de productos</li>
    <li>Alerta de confirmación 'Categoria registrada correctamente'</li>
</ul>

<h4>Nota: <i>El símbolo (*) marca los datos que son obligatorios.
</i></h4>

<h4>Criterios de aceptación</h4>
<ul>
    <li>Si hay errores de validación, estos mensajes de muestran debajo del campo correspondiente</li>
    <li>Si se registra una categoria con un nombre que ya existe en el sistema, se mostrara una alerta de error 'Ya existe una categoria con ese nombre'</li>
    <li>Si un campo obligatorio está vacío, el sistema resalta el campo y muestra el mensaje de error correspondiente sin procesar el formulario.</li>
</ul>

<h4>Reglas de negocio</h4>
<ul>
    <li>Se debe iniciar sesión previamente</li>
    <li>Sólo el administrador puede registrar una categoria nueva</li>
    <li>El nombre de la categoria tiene una longitud máxima de 50 carácteres</li>
    <li>La descripción de la categoria tiene una longitud máxima de 300 carácteres</li>
    <li>El nombre de la categoria es úncio</li>
    <li>El nombre de la categoria solo puede incluir letras</li>
</ul>

<hr/>

<h2> HU-2.9 Consultar categorias de productos</h2>

<h3>Usuario: Administrador y Empleado</h3>

<h4>Descripción: Cómo administrador del sistema, quiero dar de alta un nuevo producto en mi catálogo de productos para que los clientes puedan elegirlo y comprarlo.</h4>

<h4>Datos de entrada</h4>
<ul>
    <li style="color:red">N/A</li>
</ul>

<h4>Datos de salida</h4>
<ul>
    <li>Categorias registradas en el sistema</li>
</ul>

<h4>Nota: <i>El símbolo (*) marca los datos que son obligatorios.
</i></h4>

<h4>Criterios de aceptación</h4>
<ul>
    <li>El sistema muestra las categorias registradas</li>
    <li>El sistema muestra una pantalla de estado de  lista vacia en caso de no haber categorias registradas</li>
</ul>

<h4>Reglas de negocio</h4>
<ul>
    <li>Se debe iniciar sesión previamente</li>
</ul>

<hr/>

<h2> HU-2.10 Modificar categoria de productos</h2>

<h3>Usuario: Administrador</h3>

<h4>Descripción: Cómo administrador de la tienda, quiero modificar los datos de una categoria existente para asegurar que los datos sean correctos en caso de haber ingresado mal algún dato.</h4>

<h4>Datos de entrada</h4>
<ul>
    <li>Nombre -Alfanumérico</li>
    <li>Descripción -Alfanumérico</li>
</ul>

<h4>Datos de salida</h4>
<ul>
    <li>Categoria modificada visible en la vista de catregorias de productos</li>
    <li>Alerta de confirmación 'Categoria actualizada correctamente'</li>
</ul>

<h4>Nota: <i>El símbolo (*) marca los datos que son obligatorios.
</i></h4>

<h4>Criterios de aceptación</h4>
<ul>
    <li>Si se actualiza la categoria con un nombre que ya existe en el sistema, pero que no pertenezca a esta, se mostrara una alerta de error 'Ya existe una categoria con ese nombre'</li>
    <li>Si hay errores de validación, estos mensajes de muestran debajo del campo correspondiente</li>
</ul>

<h4>Reglas de negocio</h4>
<ul>
    <li>Se debe iniciar sesión previamente</li>
    <li>Sólo el administrador puede modificar los datos de una categoria</li>
    <li>El nombre de la categoria tiene una longitud máxima de 50 carácteres</li>
    <li>La descripción de la categoria tiene una longitud máxima de 300 carácteres</li>
    <li>El nombre de la categoria es único</li>
    <li>El nombre de la categoria solo puede contener letras</li>
    <li>El nuevo nombre de la categoria no puede ser el mismo que el de una categoria ya existente</li>
</ul>

<hr/>

<h2> HU-2.11 Eliminar categorias de productos</h2>

<h3>Usuario: Administrador</h3>

<h4>Descripción: Cómo administrador de la tienda, quiero eliminar una categoria de productos que ya no ocupo para que ya no aparezca en la lista.</h4>

<h4>Datos de entrada</h4>
<ul>
    <li>Caregoria seleccionada</li>
</ul>

<h4>Datos de salida</h4>
<ul>
    <li>Alerta de confirmación 'Categoria elimminada correctamente'</li>
</ul>

<h4>Nota: <i>El símbolo (*) marca los datos que son obligatorios.
</i></h4>

<h4>Criterios de aceptación</h4>
<ul>
    <li>Si la categoria seleccionada está asociada a un producto, el sistema no permitirá eliminarla</li>
</ul>

<h4>Reglas de negocio</h4>
<ul>
    <li>Se debe iniciar sesión previamente</li>
    <li>No se pueden eliminar categorias que hayan sido asociadas a uno o más productos</li>
</ul>
