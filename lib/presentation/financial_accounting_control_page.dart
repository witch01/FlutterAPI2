import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../model/finance_record.dart';
import '../screen_arguments.dart';
import '../shared_preferences_control.dart';

class FinancialAccountingControlPage extends StatefulWidget {
  const FinancialAccountingControlPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FinancialAccountingControlPageState();
}

class _FinancialAccountingControlPageState
    extends State<FinancialAccountingControlPage> {
  final _formKey = GlobalKey<FormState>();
  final _record = FinanceRecord();

  late int? _currentIdController;
  final _transactionNumberController = TextEditingController();
  final _transactionNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _transactionDateController = TextEditingController();
  final _transactionAmountController = TextEditingController();

  void _onRecordTap(FinanceRecord record) {
    setState(() {
      _currentIdController = record.id;
      _transactionNumberController.text = record.transactionNumber.toString();
      _transactionNameController.text = record.transactionName!;
      _descriptionController.text = record.description ?? '';
      _categoryController.text = record.category!;
      _transactionDateController.text =
          record.transactionDate!.toIso8601String();
      _transactionAmountController.text = record.transactionAmount.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Accounting Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('This is financial accounting'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String refreshToken = args.refreshToken;
                SharedPreferencesControl.saveData(refreshToken);
                SharedPreferencesControl.loadData().then((String value) {
                  setState(() {
                    refreshToken = value;
                  });
                });

                Navigator.pushNamed(context, '/profile',
                    arguments: ScreenArguments(refreshToken));
              },
              child: const Text('Go to Profile'),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _transactionNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Transaction Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter transaction number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _record.transactionNumber = int.parse(value!);
                    },
                  ),
                  TextFormField(
                    controller: _transactionNameController,
                    decoration:
                        const InputDecoration(labelText: 'Transaction Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter transaction name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _record.transactionName = value!;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    onSaved: (value) {
                      _record.description = value;
                    },
                  ),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter category';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _record.category = value!;
                    },
                  ),
                  TextFormField(
                    controller: _transactionDateController,
                    decoration:
                        const InputDecoration(labelText: 'Transaction Date'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter transaction date';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _record.transactionDate = DateTime.parse(value!);
                    },
                  ),
                  TextFormField(
                    controller: _transactionAmountController,
                    decoration:
                        const InputDecoration(labelText: 'Transaction Amount'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter transaction amount';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _record.transactionAmount = double.parse(value!);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _addRecord,
                        child: const Text('Add'),
                      ),
                      ElevatedButton(
                        onPressed: _updateRecord,
                        child: const Text('Update'),
                      ),
                      ElevatedButton(
                        onPressed: _deleteHere,
                        child: const Text('Delete here'),
                      ),
                      ElevatedButton(
                        onPressed: _delete,
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<FinanceRecord>>(
                future: _getRecords(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final records = snapshot.data!;
                    return ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return InkWell(
                          onTap: () => _onRecordTap(record),
                          child: ListTile(
                            title: Text(record.transactionName ?? ''),
                            subtitle:
                                Text(record.transactionDate?.toString() ?? ''),
                            trailing: Text(
                                record.transactionAmount?.toString() ?? ''),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final url = Uri.parse('http://localhost:8888/finance-record');
    final headers = <String, String>{
      'Content-Type': 'application/json', // use the saved refresh token here
    };
    final body = json.encode({
      'transactionNumber': _record.transactionNumber,
      'transactionName': _record.transactionName,
      'description': _record.description,
      'category': _record.category,
      'transactionDate': _record.transactionDate!.toIso8601String(),
      'transactionAmount': _record.transactionAmount,
      'is_deleted': false
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record added successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error adding record. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding record: $e')),
      );
    }

    setState(() {
      _formKey.currentState!.reset();
    });
  }

  void _updateRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final url =
        Uri.parse('http://localhost:8888/finance-record/$_currentIdController');
    final headers = <String, String>{
      'Content-Type': 'application/json', // use the saved refresh token here
    };
    final body = json.encode({
      'transactionNumber': _record.transactionNumber,
      'transactionName': _record.transactionName,
      'description': _record.description,
      'category': _record.category,
      'transactionDate': _record.transactionDate!.toIso8601String(),
      'transactionAmount': _record.transactionAmount,
      'is_deleted': false
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record updated successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error updating record. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating record: $e')),
      );
    }

    setState(() {
      _formKey.currentState!.reset();
    });
  }

  Future<List<FinanceRecord>> _getRecords() async {
    final response = await http.get(
      Uri.parse('http://localhost:8888/finance-record'),
      headers: {'Content-Type': 'application/json'},
    );
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    final records = parsed
        .map<FinanceRecord>((json) => FinanceRecord.fromJson(json))
        .where((record) => record.is_deleted != true) // фильтрация
        .toList(); // преобразование обратно в список

    return records;
  }

  void _deleteHere() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final url = Uri.parse(
        'http://localhost:8888/finance-record/by-id/go-deleted?id=$_currentIdController');
    final headers = <String, String>{
      'Content-Type': 'application/json', // use the saved refresh token here
    };

    try {
      final response = await http.put(url, headers: headers);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Record logical deleting successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error logical deleting record. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logical deleting record: $e')),
      );
    }

    setState(() {
      _formKey.currentState!.reset();
    });
  }

  void _delete() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final url =
        Uri.parse('http://localhost:8888/finance-record/$_currentIdController');
    final headers = <String, String>{
      'Content-Type': 'application/json', // use the saved refresh token here
    };

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record deleting successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error deleting record. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting record: $e')),
      );
    }

    setState(() {
      _formKey.currentState!.reset();
    });
  }
}
