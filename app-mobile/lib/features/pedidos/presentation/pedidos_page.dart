import 'package:ecommerce_app/core/layout/escaner_page.dart';
import 'package:ecommerce_app/features/auth/presentation/auth_view_model.dart';
import 'package:ecommerce_app/features/pedidos/domain/pedido_estado.dart';
import 'package:ecommerce_app/features/pedidos/domain/pedido_public.dart';
import 'package:ecommerce_app/features/pedidos/presentation/viewmodel/pedido_view_model.dart';
import 'package:ecommerce_app/ventas/domain/metodo_pago.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter_plus/qr_flutter_plus.dart';

class PedidosPage extends StatefulWidget {
  const PedidosPage({super.key});

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  PedidoEstado? _estado;
  bool _suscritoAlStream = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_esCliente(context)) {
        context.read<PedidoViewModel>().iniciarSuscripcionPersonal();
        _suscritoAlStream = true;
      }
      _cargar(context);
    });
  }

  @override
  void dispose() {
    if (_suscritoAlStream) {
      context.read<PedidoViewModel>().cerrarSuscripcionPersonal();
    }
    super.dispose();
  }

  bool _esCliente(BuildContext context) =>
      context.read<AuthViewModel>().session?.usuario.rol == 'CLIENTE';

  Future<void> _cargar(BuildContext context) {
    final vm = context.read<PedidoViewModel>();
    return _esCliente(context)
        ? vm.cargarMisPedidos(estado: _estado)
        : vm.cargarPedidosPersonal(estado: _estado);
  }

  Future<void> _escanearPedido() async {
    final codigo = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const EscanerPage(formatos: [BarcodeFormat.qrCode]),
      ),
    );
    if (codigo == null || !mounted) return;

    final vm = context.read<PedidoViewModel>();
    final pedido = await vm.buscarQr(codigo);
    if (!mounted) return;
    if (pedido == null) {
      _mostrarError(vm.errorMessage ?? 'El código no corresponde a un pedido válido.');
      return;
    }

    final confirmarRevision = await showDialog<bool>(
      context: context,
      builder: (_) => _PedidoEscaneadoDialog(pedido: pedido),
    );
    if (confirmarRevision != true || !mounted) return;
    if (pedido.estado != PedidoEstado.PED_LISTO) {
      _mostrarError(_mensajeEstadoNoEntregable(pedido.estado));
      return;
    }

    final metodo = await showDialog<MetodoPago>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Método de pago'),
        children: [
          for (final value in MetodoPago.values)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, value),
              child: Text(_metodoLabel(value)),
            ),
        ],
      ),
    );
    if (metodo == null || !mounted) return;

    final confirmarEntrega = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar entrega'),
        content: Text(
          '¿Confirmas la entrega del pedido ${pedido.textPedido} por '
          '\$${pedido.costo.toStringAsFixed(2)} con pago ${_metodoLabel(metodo)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar entrega'),
          ),
        ],
      ),
    );
    if (confirmarEntrega != true || !mounted) return;

    final entregado = await vm.entregarPorQr(codigo, metodo.name);
    if (!mounted) return;
    if (entregado == null) {
      _mostrarError(vm.errorMessage ?? 'No se pudo completar la entrega.');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido ${entregado.textPedido} entregado.')),
      );
      await _cargar(context);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PedidoViewModel>();
    final esCliente = _esCliente(context);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Text('Estado:'),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<PedidoEstado?>(
                    isExpanded: true,
                    value: _estado,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todos')),
                      for (final estado in PedidoEstado.values.where(
                        (estado) => estado != PedidoEstado.PED_RECHAZADO,
                      ))
                        DropdownMenuItem(
                          value: estado,
                          child: Text(_estadoLabel(estado)),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() => _estado = value);
                      _cargar(context);
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Actualizar pedidos',
                  onPressed: () => _cargar(context),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          if (!esCliente)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _escanearPedido,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Escanear QR para entregar'),
                ),
              ),
            ),
          if (vm.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                vm.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (vm.isFetching) const LinearProgressIndicator(),
          Expanded(
            child: vm.pedidos.isEmpty && !vm.isFetching
                ? const Center(child: Text('No hay pedidos para mostrar'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: vm.pedidos.length,
                    itemBuilder: (context, index) => _PedidoCard(
                      pedido: vm.pedidos[index],
                      esCliente: esCliente,
                      loading: vm.isLoading,
                      onAction: (action) async {
                        await action();
                        if (!context.mounted) return;
                        if (vm.errorMessage != null) {
                          _mostrarError(vm.errorMessage!);
                        } else {
                          _cargar(context);
                        }
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  static String _mensajeEstadoNoEntregable(PedidoEstado estado) => switch (estado) {
        PedidoEstado.PED_ENTREGADO => 'Este pedido ya fue entregado.',
        PedidoEstado.PED_CANCELADO => 'Este pedido fue cancelado y no puede entregarse.',
        _ => 'El pedido todavía no está listo para recoger.',
      };

  static String _estadoLabel(PedidoEstado estado) => switch (estado) {
        PedidoEstado.PED_PENDIENTE => 'Pendiente',
        PedidoEstado.PED_CONFIRMADO => 'Confirmado',
        PedidoEstado.PED_LISTO => 'Listo para recoger',
        PedidoEstado.PED_ENTREGADO => 'Entregado',
        PedidoEstado.PED_RECHAZADO => 'Rechazado',
        PedidoEstado.PED_CANCELADO => 'Cancelado',
      };

  static String _metodoLabel(MetodoPago value) => switch (value) {
        MetodoPago.M_EFECTIVO => 'Efectivo',
        MetodoPago.M_TARJETA => 'Tarjeta',
        MetodoPago.M_TRANSFERENCIA => 'Transferencia',
      };
}

class _PedidoCard extends StatelessWidget {
  const _PedidoCard({
    required this.pedido,
    required this.esCliente,
    required this.loading,
    required this.onAction,
  });

  final PedidoPublic pedido;
  final bool esCliente;
  final bool loading;
  final Future<void> Function(Future<void> Function()) onAction;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<PedidoViewModel>();
    final acciones = <Widget>[];
    if (esCliente && pedido.estado == PedidoEstado.PED_PENDIENTE) {
      acciones.add(
        TextButton(
          onPressed: loading ? null : () => onAction(() => vm.cancelar(pedido.id)),
          child: const Text('Cancelar'),
        ),
      );
    } else if (!esCliente) {
      switch (pedido.estado) {
        case PedidoEstado.PED_PENDIENTE:
          acciones.addAll([
            TextButton(
              onPressed: loading
                  ? null
                  : () => onAction(() async { await vm.confirmar(pedido.id); }),
              child: const Text('Confirmar'),
            ),
            TextButton(
              onPressed: loading ? null : () => _rechazar(context, vm),
              child: const Text('Rechazar'),
            ),
          ]);
          break;
        case PedidoEstado.PED_CONFIRMADO:
          acciones.add(
            TextButton(
              onPressed: loading
                  ? null
                  : () => onAction(() async { await vm.marcarListo(pedido.id); }),
              child: const Text('Marcar listo'),
            ),
          );
          break;
        default:
          break;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pedido ${pedido.textPedido}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(label: Text(pedido.estado.name.replaceFirst('PED_', '').toLowerCase())),
              ],
            ),
            if (!esCliente && pedido.clienteNombre != null)
              Text('Cliente: ${pedido.clienteNombre}'),
            for (final item in pedido.carrito)
              Text(
                '${item.cantidad} × ${item.nombre}  ·  '
                '\$${item.subtotal.toStringAsFixed(2)}',
              ),
            const SizedBox(height: 6),
            Text('Total: \$${pedido.costo.toStringAsFixed(2)}'),
            if (pedido.codigoQr != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _mostrarQr(context, pedido.codigoQr!),
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Mostrar código QR'),
                ),
              ),
            if (pedido.motivoRechazo != null)
              Text('Motivo: ${pedido.motivoRechazo}'),
            if (acciones.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(children: acciones),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _rechazar(BuildContext context, PedidoViewModel vm) async {
    final controller = TextEditingController();
    final motivo = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar pedido'),
        content: TextField(
          controller: controller,
          maxLength: 50,
          decoration: const InputDecoration(labelText: 'Motivo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (motivo != null && motivo.isNotEmpty) {
      await onAction(() async { await vm.rechazar(pedido.id, motivo); });
    }
  }

  Future<void> _mostrarQr(BuildContext context, String codigo) => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Pedido ${pedido.textPedido} listo para recoger'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: codigo,
                version: QrVersions.auto,
                size: 220,
                semanticsLabel: 'Código QR del pedido ${pedido.textPedido}',
              ),
              const SizedBox(height: 12),
              const Text('Muestra este código al empleado al recoger tu pedido.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
}

class _PedidoEscaneadoDialog extends StatelessWidget {
  const _PedidoEscaneadoDialog({required this.pedido});
  final PedidoPublic pedido;

  @override
  Widget build(BuildContext context) {
    final listo = pedido.estado == PedidoEstado.PED_LISTO;
    final estado = switch (pedido.estado) {
      PedidoEstado.PED_ENTREGADO => 'Ya fue entregado; no se puede entregar de nuevo.',
      PedidoEstado.PED_CANCELADO => 'Fue cancelado y no se puede entregar.',
      PedidoEstado.PED_LISTO => 'Listo para recoger.',
      _ => 'Todavía no está listo para recoger.',
    };
    return AlertDialog(
      title: Text('Pedido ${pedido.textPedido}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${pedido.clienteNombre ?? 'Sin nombre'}'),
            Text('Estado: $estado'),
            const Divider(),
            for (final item in pedido.carrito)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${item.cantidad} × ${item.nombre}  ·  '
                  '\$${item.subtotal.toStringAsFixed(2)}',
                ),
              ),
            const SizedBox(height: 8),
            Text('Total: \$${pedido.costo.toStringAsFixed(2)}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cerrar'),
        ),
        if (listo)
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar'),
          ),
      ],
    );
  }
}
