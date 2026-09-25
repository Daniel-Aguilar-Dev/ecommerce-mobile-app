# Módulo 5: Gestión de carrito de compras

### Gestión del carrito de compras personal de los clientes

#### Versión 1.1

<h2> HU-5.1 Agregar producto al carrito</h2>

<h3>Usuario: Cliente</h3>

<h4>Descripción: Cómo cliente, quiero agregar un producto a mi caarrito de compras para generar un pedido que lo contenga.</h4>

<h4>Datos de entrada</h4>
<ul>
    <li>Producto seleccionado<b style="color:red">*</b></li>
    <li>Cantidad<b style="color:red">*</b> -Numérico</li>
</ul>

<h4>Datos de salida</h4>
<ul>
    <li>Producto agregado al carrito de compras</li>
    <li>Alerta de confirmación 'Se agregó {nombre_del_producto}'</li>
</ul>

<h4>Nota: <i>El símbolo (*) marca los datos que son obligatorios.
</i></h4>

<h4>Criterios de aceptación</h4>
<ul>
    <li>El botón para aumentar la cantidad de unidades se bloqueará si la cantidad solicitada excede al stock actual</li>
    <li>El botón para disminuir la cantidad de unidades se bloqueará si la cantidad solicitada llega a 1</li>
    <li>Por defecto se agrega una unidad del producto solicitado al carrito, a menos que el usuario indique otra cantidad</li>
    <li>EL subtotal del carrito se recalcula agregando ese producto y su cantidad</li>
</ul>

<h4>Reglas de negocio</h4>
<ul>
    <li>El cliente no puede agregar una cantidad de unidades mayor al stock actual de ese producto</li>
    <li>No se pueden agregar productos agotados al carrito</li>
    <li>El carrito no reserva ni descuenta stock; es solo una selección temporal previa a generar el pedido.</li>
    <li>Deben haber productos registrados previamente<b>(ver HU-2.1)</b></li>
</ul>

<hr/>

<h2> HU-5.2 Consultar mi carrito de compras</h2>

<h3>Usuario: Cliente</h3>

<h4>Descripción: Cómo cliente, quiero consutlar mi carrito de compras junto al costo total del carrito para agregar/quitar productos o confirmar el carrito.</h4>

<h4>Datos de entrada</h4>
<ul>
    <li style="color:red">N/A</li>
</ul>

<h4>Datos de salida</h4>
<ul>
    <li>Carrito de compras almacenado en el dispositivo</li>
</ul>

<h4>Nota: <i>El símbolo (*) marca los datos que son obligatorios.
</i></h4>

<h4>Criterios de aceptación</h4>
<ul>
    <li>El sistema muestra los productos añadidos al carrito</li>
    <li>El sistema muestra el total estimado a pagar por el contenido del carrito</li>
    <li>Si el carrito está vacío, se mostrará una pantalla de estado de registro no encontrado</li>
</ul>

<h4>Reglas de negocio</h4>
<ul>
    <li>El cliente puede tener un carrito de compras sin tener sesión iniciada, pero necesita iniciar sesión para confirmarlo y generar un pedido</li>
    <li>El carrito no tiene expiración automática, pero se revalida contra el stock disponible cada vez que el cliente lo abre o intenta confirmarlo.</li>
    <li>  El carrito es único por sesión, es decir, no se comparte entre dispositivos, y solo está disponible localmente
    </li>
    <li>El subtotal del carrito se calcula al sumar el precio de cada producto multiplicandolo por la cantidad de unidades asignadas a ese producto</li>
    <li>El carrito es personal y solo lo puede ver y modificar el cliente dueño de la sesión.
    </li>
</ul>

<hr/>

<h2> HU-5.3 Ajustar cantidad de unidades de un producto</h2>

<h3>Usuario: Cliente</h3>

<h4>Descripción: Cómo cliente, quiero moodificar la cantidad de unidades de un producto guardado en mi carrito, para gestionar los productos que voy a comprar..</h4>

<h4>Datos de entrada</h4>
<ul>
    <li>Producto seleccionado</li>
    <li>Cantidad a ajustar -Numérico</li>
</ul>

<h4>Datos de salida</h4>
<ul>
    <li>Cantidad de unidades actualizada en el carrito</li>
</ul>

<h4>Nota: <i>El símbolo (*) marca los datos que son obligatorios.
</i></h4>

<h4>Criterios de aceptación</h4>
<ul>
    <li>El botón para aumentar la cantidad de unidades se bloqueará si la cantidad solicitada excede al stock actual</li>
    <li>El botón para disminuir la cantidad de unidades se bloqueará si la cantidad solicitada llega a 1</li>
    <li>EL subtotal del carrito se recalcula con la nueva cantidad de ese producto</li>
</ul>

<h4>Reglas de negocio</h4>
<ul>
    <li>El cliente no puede asignar una cantidad de unidades mayor al stock actual de ese producto</li>
</ul>

<hr/>

<h2> HU-5.4  Remover producto del carrito</h2>

<h3>Usuario: Cliente</h3>

<h4>Descripción: Cómo cliente, quiero quitar un producto de mi carrito para ya no comprarlo.</h4>

<h4>Datos de entrada</h4>
<ul>
    <li>Producto seleccionado</li>
</ul>

<h4>Datos de salida</h4>
<ul>
    <li>Lista del carrito actualizada sin el producto seleccionado</li>
</ul>

<h4>Nota: <i>El símbolo (*) marca los datos que son obligatorios.
</i></h4>

<h4>Criterios de aceptación</h4>
<ul>
    <li>El subtotal del carrito se recalcula sin ese producto</li>
    <li>La lista del carrito se actualiza</li>
</ul>

<h4>Reglas de negocio</h4>
<ul>
    <li>El cliente puede quitar un producto de su carrito si considera que ya no lo quiere comprar</li>
</ul>

<hr/>

<h2> HU-5.5 Confirmar carrito</h2>

<h3>Usuario: Cliente</h3>

<h4>Descripción: Cómo cliente quiero confirmar mi carrito de compras para generar un pedido en la tienda.</h4>

<h4>Datos de entrada</h4>
<ul>
    <li style="color:red">N/A</li>
</ul>

<h4>Datos de salida</h4>
<ul>
    <li>Pedido generado para la tienda</li>
    <li>Alerta de confirmación 'Pedido generado correctamente'</li>
    <li>Carrito de compras vaciado</li>
</ul>

<h4>Nota: <i>El símbolo (*) marca los datos que son obligatorios.
</i></h4>

<h4>Criterios de aceptación</h4>
<ul>
    <li>El pedido se genera a partir del contenido del carrito y con el estado 'pendiente', a la espera de que los empleados lo atiendan</li>
    <li>El carrito de compras se reestablece solo si el pedido fue generado completamente</li>
</ul>

<h4>Reglas de negocio</h4>
<ul>
    <li>Se debe iniciar sesión previamente</li>
    <li>Al intentar confirmar el carrito, el sistema valida la disponibilidad actual del producto; si la cantidad solicitada excede el stock disponible en ese momento, se notifica al cliente y se ajusta o bloquea la cantidad.</li>
    <li>Cuando el pedido se genera, el carrito se reestablece para un próximo pedido</li>
</ul>
