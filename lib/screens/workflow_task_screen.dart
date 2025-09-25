import 'package:flutter/material.dart';

import '../models/workflow_task.dart';
import '../services/workflow_task_service.dart';

class WorkflowTaskScreen extends StatefulWidget {
  const WorkflowTaskScreen({super.key});

  @override
  State<WorkflowTaskScreen> createState() => _WorkflowTaskScreenState();
}

class _WorkflowTaskScreenState extends State<WorkflowTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderController = TextEditingController();
  final _ownerController = TextEditingController();
  final _statusController = TextEditingController();
  final _service = WorkflowTaskService();

  bool _isSaving = false;

  @override
  void dispose() {
    _orderController.dispose();
    _ownerController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _submitTask() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _service.createTask(
        orderNumber: _orderController.text.trim(),
        owner: _ownerController.text.trim(),
        status: _statusController.text.trim(),
      );
      _orderController.clear();
      _ownerController.clear();
      _statusController.clear();
      FocusScope.of(context).unfocus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orden guardada en Firebase.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la orden: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatCreatedAt(BuildContext context, DateTime createdAt) {
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(createdAt);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(createdAt),
      alwaysUse24HourFormat: true,
    );
    return '$date - $time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PROOFTRACK')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Registrar nueva orden',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _orderController,
                      decoration: const InputDecoration(
                        labelText: 'Numero de orden',
                        hintText: '',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa el numero de la orden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ownerController,
                      decoration: const InputDecoration(
                        labelText: 'Responsable',
                        hintText: '',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Indica quien es responsable';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _statusController,
                      decoration: const InputDecoration(
                        labelText: 'Estado de la orden',
                        hintText: '',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa el estado de la orden';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _submitTask(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _submitTask,
                        icon: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _isSaving ? 'Guardando...' : 'Guardar orden',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: StreamBuilder<List<WorkflowTask>>(
                  stream: _service.watchTasks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al cargar ordenes: ${snapshot.error}',
                        ),
                      );
                    }
                    final tasks = snapshot.data;
                    if (tasks == null || tasks.isEmpty) {
                      return const Center(
                        child: Text('Aun no hay ordenes registradas.'),
                      );
                    }
                    return ListView.separated(
                      itemCount: tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        final subtitle = [
                          'Estado: ${task.status}',
                          'Responsable: ${task.owner}',
                          _formatCreatedAt(context, task.createdAt),
                        ].join('\n');
                        return Card(
                          child: ListTile(
                            title: Text('Orden ${task.orderNumber}'),
                            subtitle: Text(subtitle),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _service.deleteTask(task.id),
                              tooltip: 'Eliminar orden',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
