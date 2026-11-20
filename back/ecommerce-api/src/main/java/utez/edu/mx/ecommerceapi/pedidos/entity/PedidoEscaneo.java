package utez.edu.mx.ecommerceapi.pedidos.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import utez.edu.mx.ecommerceapi.usuarios.entity.Usuario;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "pedido_escaneos")
public class PedidoEscaneo {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "codigo_qr", nullable = false, length = 255)
    private String codigoQr;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "pedido_id")
    private Pedido pedido;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;

    @Column(name = "resultado", nullable = false, length = 32)
    private String resultado;

    @Column(name = "fecha_hora", nullable = false)
    private LocalDateTime fechaHora;

    public PedidoEscaneo(String codigoQr, Pedido pedido, Usuario usuario,
                         String resultado, LocalDateTime fechaHora) {
        this.codigoQr = codigoQr;
        this.pedido = pedido;
        this.usuario = usuario;
        this.resultado = resultado;
        this.fechaHora = fechaHora;
    }
}
