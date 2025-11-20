import 'package:flutter/material.dart';
import '../models/pobrecom.dart';


class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TodoService _todoService = TodoService();
  List<Todo> _todos = [];
  List<Todo> _filteredTodos = [];
  bool _isLoading = false;
  String _currentFilter = 'Todos'; // 'Todos', 'Concluídos', 'Pendentes'

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final todos = await _todoService.getTodos(limit: 10);
      setState(() {
        _todos = todos;
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
      case 'Concluídos':
        _filteredTodos = _todos.where((todo) => todo.completed).toList();
        break;
      case 'Pendentes':
        _filteredTodos = _todos.where((todo) => !todo.completed).toList();
        break;
      default:
        _filteredTodos = List.from(_todos);
    }
  }

  Future<void> _createTodo(String title) async {
    try {
      final newTodo = await _todoService.createTodo(
        title: title,
        completed: false,
      );

      // Adicionar o novo TODO na lista local
      setState(() {
        _todos.insert(0, newTodo);
        _applyFilter();
      });

      _showSnackBar('TODO criado com sucesso!');
    } catch (e) {
      _showSnackBar('Erro ao criar TODO: $e', isError: true);
    }
  }

  Future<void> _toggleTodoComplete(Todo todo) async {
    try {
      final updatedTodo = await _todoService.updateTodo(
        id: todo.id,
        completed: !todo.completed,
      );

      // Atualizar na lista local
      setState(() {
        final index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          _todos[index] = updatedTodo;
          _applyFilter();
        }
      });

      _showSnackBar(
        updatedTodo.completed
            ? 'TODO marcado como concluído!'
            : 'TODO marcado como pendente!',
      );
    } catch (e) {
      _showSnackBar('Erro ao atualizar TODO: $e', isError: true);
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    try {
      await _todoService.deleteTodo(todo.id);

      // Remover da lista local
      setState(() {
        _todos.removeWhere((t) => t.id == todo.id);
        _applyFilter();
      });

      _showSnackBar('TODO excluído com sucesso!');
    } catch (e) {
      _showSnackBar('Erro ao excluir TODO: $e', isError: true);
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

  void _showAddTodoDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar TODO'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Digite o título do TODO',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                _createTodo(title);
                Navigator.pop(context);
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
        title: const Text('Todo App'),
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
                value: 'Concluídos',
                child: Text('Concluídos'),
              ),
              const PopupMenuItem(
                value: 'Pendentes',
                child: Text('Pendentes'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTodos,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _filteredTodos.isEmpty
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
                        'Nenhum TODO encontrado',
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
                            '${_filteredTodos.length} itens',
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
                        itemCount: _filteredTodos.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final todo = _filteredTodos[index];
                          return _buildTodoItem(todo);
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTodoDialog,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Todo'),
      ),
    );
  }

  Widget _buildTodoItem(Todo todo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: todo.completed ? Colors.green : Colors.orange,
          child: Icon(
            todo.completed ? Icons.check : Icons.pending,
            color: Colors.white,
          ),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.completed
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'ID: ${todo.id} • User: ${todo.userId}',
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
                todo.completed
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: todo.completed ? Colors.green : Colors.grey,
              ),
              onPressed: () => _toggleTodoComplete(todo),
              tooltip: todo.completed
                  ? 'Marcar como pendente'
                  : 'Marcar como concluído',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTodo(todo),
              tooltip: 'Excluir',
            ),
          ],
        ),
      ),
    );
  }
}
