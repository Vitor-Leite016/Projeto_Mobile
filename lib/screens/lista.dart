import 'package:flutter/material.dart';
import '../models/pobrecom.dart';
import '../services/pobrecom_local_service.dart';

class TelaLista extends StatefulWidget {
  const TelaLista({super.key});

  @override
  State<TelaLista> createState() => _TelalistaState();
}

class _TelalistaState extends State<TelaLista> {
  final DespesaLocalService _DespesaLocalService = DespesaLocalService();
  List<Despesa> _despesas = [];
  List<Despesa> _filteredDespesas = [];
  bool _isLoading = false;
  String _currentFilter = 'Todos'; // 'Todos', 'Pagos', 'Pendentes'

  @override
  void initState() {
    super.initState();
    _loadDespesas();
  }

  Future<void> _loadDespesas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final despesas = await _DespesaLocalService.getDespesas();
      setState(() {
        _despesas = despesas;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        _showSnackBar('Erro ao carregar TODOs: $e', isError: true);
      }
    }
  }

  void _applyFilter() {
    switch (_currentFilter) {
      case 'Pagos':
        _filteredDespesas = _despesas.where((despesa) => despesa.pago).toList();
        break;
      case 'Pendentes':
        _filteredDespesas = _despesas.where((despesa) => !despesa.pago).toList();
        break;
      default:
        _filteredDespesas = List.from(_despesas);
    }
  }

  Future<void> _createDespesa(double valor, DateTime data, String descricao) async {
    try {
      final newDespesa = DespesaBuilder()
          .setValor(valor)
          .setData(data)
          .setDescricao(descricao)
          .build();

      await _DespesaLocalService.createDespesa(newDespesa);

      setState(() {
        _despesas.insert(0, newDespesa);
        _applyFilter();
      });

      _showSnackBar('Despesa criada com sucesso!');
    } catch (e) {
      _showSnackBar('Erro ao criar despesa: $e', isError: true);
    }
  }

  Future<void> _toggleDespesaPaga(Despesa despesa) async {
    try {
      final updatedDespesa = await _DespesaLocalService.updateDespesa(
        id: despesa.id,
        pago: !despesa.pago,
      );

      setState(() {
        final index = _despesas.indexWhere((d) => d.id == despesa.id);
        if (index != -1) {
          _despesas[index] = updatedDespesa;
          _applyFilter();
        }
      });

      _showSnackBar(
        updatedDespesa.pago
            ? 'Despesa marcada como paga!'
            : 'Despesa marcada como pendente!',
      );
    } catch (e) {
      _showSnackBar('Erro ao atualizar despesa: $e', isError: true);
    }
  }

  Future<void> _deleteDespesa(Despesa despesa) async {
    try {
      await _DespesaLocalService.deleteDespesa(despesa.id);

      setState(() {
        _despesas.removeWhere((d) => d.id == despesa.id);
        _applyFilter();
      });

      _showSnackBar('Despesa excluído com sucesso!');
    } catch (e) {
      _showSnackBar('Erro ao apagar Despesa: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddDespesaDialog() {
    final TextEditingController valorController = TextEditingController();
    final TextEditingController descricaoController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Despesa'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valorController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Digite o valor da despesa',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descricaoController,
                decoration: const InputDecoration(
                  hintText: 'Digite a descrição da despesa',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    selectedDate = pickedDate;
                  }
                },
                child: const Text('Selecionar Data'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final valor = double.tryParse(valorController.text.trim());
              final descricao = descricaoController.text.trim();

              if (valor != null && descricao.isNotEmpty && selectedDate != null) {
                _createDespesa(valor, selectedDate!, descricao);
                Navigator.pop(context);
              } else {
                _showSnackBar('Preencha todos os campos corretamente.', isError: true);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _changeFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Despesas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: _changeFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Todos',
                child: Text('Todos'),
              ),
              const PopupMenuItem(
                value: 'Pagos',
                child: Text('Pagos'),
              ),
              const PopupMenuItem(
                value: 'Pendentes',
                child: Text('Pendentes'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDespesas,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _filteredDespesas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma despesa encontrada',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Filtro: $_currentFilter',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filtro: $_currentFilter',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${_filteredDespesas.length} itens',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredDespesas.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final despesa = _filteredDespesas[index];
                          return _buildDespesaItem(despesa);
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDespesaDialog,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Despesa'),
      ),
    );
  }

  Widget _buildDespesaItem(Despesa despesa) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: despesa.pago ? Colors.green : Colors.orange,
          child: Icon(
            despesa.pago ? Icons.check : Icons.pending,
            color: Colors.white,
          ),
        ),
        title: Text(
          despesa.descricao,
          style: TextStyle(
            decoration: despesa.pago
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Valor: ${despesa.valor} • Data: ${despesa.data}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                despesa.pago
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: despesa.pago ? Colors.green : Colors.grey,
              ),
              onPressed: () => _toggleDespesaPaga(despesa),
              tooltip: despesa.pago
                  ? 'Marcar como pendente'
                  : 'Marcar como paga',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteDespesa(despesa),
              tooltip: 'Excluir',
            ),
          ],
        ),
      ),
    );
  }
}
