package utez.edu.mx.ecommerceapi.carrito.entity;

import lombok.Data;
import utez.edu.mx.ecommerceapi.productos.entity.Producto;

@Data
public class CarritoItem {
    private Producto producto;
    private int cantidad;

    public CarritoItem(Producto producto, int cantidad) {
        this.producto = producto;
        this.cantidad = cantidad;
    }

    public CarritoItem() {
    }
}
