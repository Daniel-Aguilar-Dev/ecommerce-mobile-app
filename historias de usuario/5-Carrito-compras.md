# Módulo 5: Gestión de carrito de compras

### Gestión del carrito de compras personal de los clientes

#### Versión 1.2

<h2> HU-5.1 Agregar producto al carrito - <span style="color:red"> ALTA</span></h2>

**Como** cliente, **quiero** agregar un producto a mi carrito **para** generar un pedido que lo contenga.

<h4>Criterios de aceptación</h4>
<ul>
    <li>Por defecto se agrega una unidad del producto, salvo que el cliente indique otra cantidad.</li>
    <li>El botón para aumentar la cantidad se bloquea si la cantidad solicitada excede el stock actual.</li>
    <li>El botón para disminuir la cantidad se bloquea cuando la cantidad llega a 1.</li>
    <li>No se pueden agregar productos agotados al carrito.</li>
    <li>Al agregar, se muestra la alerta "Se agregó {nombre_del_producto}" y el subtotal del carrito se recalcula.</li>
    <li>El carrito no reserva ni descuenta stock; es solo una selección temporal.</li>
</ul>

<hr/>

<h2> HU-5.2 Consultar mi carrito de compras - <span style="color:red"> ALTA</span></h2>

**Como** cliente, **quiero** consultar mi carrito y su costo total **para** agregar o quitar productos, o confirmarlo.

<h4>Criterios de aceptación</h4>
<ul>
    <li>Se muestran los productos del carrito con su cantidad y subtotal por producto.</li>
    <li>Se muestra el total estimado a pagar (suma de precio × cantidad de cada producto).</li>
    <li>Si el carrito está vacío, se muestra una pantalla de registro no encontrado.</li>
    <li>El carrito se guarda localmente en el dispositivo y no se comparte entre dispositivos.</li>
    <li>El cliente puede tener un carrito sin sesión iniciada, pero necesita iniciar sesión para confirmarlo.</li>
    <li>El carrito no expira, pero se revalida contra el stock disponible cada vez que se abre.</li>
    <li>Solo el cliente dueño de la sesión puede ver y modificar su carrito.</li>
</ul>

<hr/>

<h2> HU-5.3 Ajustar cantidad de unidades de un producto - <span style="color:yellow"> MEDIA</span></h2>

**Como** cliente, **quiero** modificar la cantidad de unidades de un producto en mi carrito **para** gestionar lo que voy a comprar.

<h4>Criterios de aceptación</h4>
<ul>
    <li>El botón para aumentar la cantidad se bloquea si la cantidad excede el stock actual.</li>
    <li>El botón para disminuir la cantidad se bloquea cuando la cantidad llega a 1.</li>
    <li>Al cambiar la cantidad, el subtotal del carrito se recalcula.</li>
</ul>

<hr/>

<h2> HU-5.4  Remover producto del carrito - <span style="color:yellow"> MEDIA</span></h2>

**Como** cliente, **quiero** quitar un producto de mi carrito **para** ya no comprarlo.

<h4>Criterios de aceptación</h4>
<ul>
    <li>Al quitar el producto, la lista del carrito se actualiza sin él.</li>
    <li>El subtotal del carrito se recalcula sin ese producto.</li>
</ul>

<hr/>

<h2> HU-5.5 Confirmar carrito - <span style="color:red"> ALTA</span></h2>

**Como** cliente, **quiero** confirmar mi carrito **para** generar un pedido en la tienda.

<h4>Criterios de aceptación</h4>
<ul>
    <li>Para confirmar se requiere sesión iniciada.</li>
    <li>Al confirmar, el sistema valida la disponibilidad actual de cada producto; si una cantidad excede el stock, notifica al cliente y ajusta o bloquea la cantidad.</li>
    <li>El pedido se genera con el contenido del carrito y con estado "Pendiente", en espera de que un empleado lo atienda.</li>
    <li>Al generarse, se muestra "Pedido generado correctamente".</li>
    <li>El carrito se vacía solo si el pedido se generó por completo.</li>
    <li></li>
</ul>
