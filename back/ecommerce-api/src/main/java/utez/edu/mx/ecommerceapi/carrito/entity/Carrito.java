package utez.edu.mx.ecommerceapi.carrito.entity;

import java.util.List;

import lombok.Data;

//Clase que no será una entidad, sino un objeto que se utilizará para representar los productos en el carrito de compras.de un pedido, el cual se guardará en la base de datos como un JSON en la tabla de pedidos. Esta clase tendrá los atributos de producto y cantidad, y se utilizará para representar los productos en el carrito de compras.

@Data
public class Carrito {
    private List<CarritoItem> items;
    private int cantidad;

    public Carrito(List<CarritoItem> items, int cantidad) {
        this.items = items;
        this.cantidad = cantidad;
    }

    public Carrito() {
    }
}