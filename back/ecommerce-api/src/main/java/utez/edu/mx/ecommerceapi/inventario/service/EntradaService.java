package utez.edu.mx.ecommerceapi.inventario.service;

import org.springframework.stereotype.Service;

import utez.edu.mx.ecommerceapi.inventario.repository.EntradaRepository;
import utez.edu.mx.ecommerceapi.productos.repository.ProductoRepository;
import utez.edu.mx.ecommerceapi.usuarios.repository.UsuarioRepository;

@Service 
public class EntradaService {
    private final EntradaRepository entradaRepository;
    private final ProductoRepository productoRepository;
    private final UsuarioRepository usuarioRepository;
 
    public EntradaService(EntradaRepository entradaRepository, ProductoRepository productoRepository, UsuarioRepository usuarioRepository) {
        this.entradaRepository = entradaRepository;
        this.productoRepository = productoRepository;
        this.usuarioRepository = usuarioRepository;
    }
}
