import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Registo extends StatefulWidget {
  final String? disciplina;
  final String? tipoAvaliacao;
  final String? dataHora;
  final String? dificuldade;
  final String? observacoes;

  const Registo({
    Key? key,
    this.disciplina,
    this.tipoAvaliacao,
    this.dataHora,
    this.dificuldade,
    this.observacoes,
  }) : super(key: key);

  @override
  _RegistoState createState() => _RegistoState();
}

class _RegistoState extends State<Registo> {
  final _formKey = GlobalKey<FormState>();
  final _disciplinaController = TextEditingController();
  final _avaliacaoController = TextEditingController();
  final _dataHoraController = TextEditingController();
  final _dificuldadeController = TextEditingController();
  final _observacoesController = TextEditingController();

  List<Map<String, dynamic>> _registos = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _guardarRegisto(bool isNew) async {
    final preferences = await SharedPreferences.getInstance();
    final disciplina = _disciplinaController.text;
    final avaliacao = _avaliacaoController.text;
    final dataHora = _dataHoraController.text;
    final dificuldade = _dificuldadeController.text;
    final observacoes = _observacoesController.text;

    // Validar o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Guarda a disciplina e seus valores nas SharedPreferences
    await preferences.setStringList(
        disciplina, [avaliacao, dataHora, dificuldade, observacoes]);

    // Limpar os campos
    _disciplinaController.clear();
    _avaliacaoController.clear();
    _dataHoraController.clear();
    _dificuldadeController.clear();
    _observacoesController.clear();
    // Limpar os campos e mostrar a mensagem

    if (isNew) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A avaliação foi registada com sucesso.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A avaliação foi editada com sucesso.'),
        ),
      );
      await Future.delayed(Duration(seconds: 3));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    _disciplinaController.text = widget.disciplina ?? '';
    _avaliacaoController.text = widget.tipoAvaliacao ?? '';
    _dataHoraController.text = widget.dataHora ?? '';
    _dificuldadeController.text = widget.dificuldade ?? '';
    _observacoesController.text = widget.observacoes ?? '';

    final bool isNew = widget.disciplina == null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.blue,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      'Registo de avaliação',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _disciplinaController,
                        decoration: InputDecoration(
                          labelText: 'Nome da disciplina (ex:. LP2)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Faltar colocar o nome da disciplina';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _avaliacaoController,
                        decoration: InputDecoration(
                          labelText:
                              'Tipo de avaliação (ex:. frequencia, mini-teste)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Falta colocar o tipo de avaliação';
                          }
                          List<String> tiposAvaliacao = [
                            'frequencia',
                            'mini-teste',
                            'projeto',
                            'defesa'
                          ];
                          if (!tiposAvaliacao.contains(value.toLowerCase())) {
                            return 'Tipo de avaliação inválido.';
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _dataHoraController,
                        decoration: InputDecoration(
                          labelText: 'Data e hora da realização',
                          border: OutlineInputBorder(),
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2023),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              DateTime pickedDateTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );

                              // data e hora igual ou posterior à atual - Validação
                              if (pickedDateTime
                                      .isAtSameMomentAs(DateTime.now()) ||
                                  pickedDateTime.isAfter(DateTime.now())) {
                                String formattedDate =
                                    DateFormat('yyyy/MM/dd HH:mm')
                                        .format(pickedDateTime);
                                _dataHoraController.text = formattedDate;
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Data e hora inválidas'),
                                      content: Text(
                                          'Seleccione uma data e hora posterior ou igual à atual.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          }
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Falta colocar a Data e Hora da realização da avaliação';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _dificuldadeController,
                        decoration: InputDecoration(
                          labelText:
                              ' Nível de dificuldade esperado pelo aluno (Entre 1 e 5)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Falta colocar o nível de dificuldade esperado';
                          }

                          if (int.tryParse(value) == null) {
                            return 'Por favor, insira um número válido';
                          }

                          List<int> dificuldadeRange = [1, 2, 3, 4, 5];

                          if (!dificuldadeRange.contains(int.parse(value))) {
                            return 'Dificuldade inválida. Por favor, insira um valor entre 1 e 5';
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _observacoesController,
                        decoration: InputDecoration(
                          labelText: 'Observações (opcional)',
                        ),
                        keyboardType: TextInputType.text,
                        maxLength: 200,
                        validator: (value) {
                          // não tem código, pois é opcional
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _guardarRegisto(isNew),
                        child: Text('Guardar o registo da avaliação'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
