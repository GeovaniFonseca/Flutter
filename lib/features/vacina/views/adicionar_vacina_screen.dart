// views/adicionar_vacina_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../../services/storage_service.dart';
import '../model/vacina.dart';
import '../viewmodels/vacina_viewmodel.dart';

class AdicionarVacinaScreen extends StatefulWidget {
  final Vacina? vacinaParaEditar;

  const AdicionarVacinaScreen({super.key, this.vacinaParaEditar});

  @override
  _AdicionarVacinaScreenState createState() => _AdicionarVacinaScreenState();
}

class _AdicionarVacinaScreenState extends State<AdicionarVacinaScreen> {
  final TextEditingController _dateAplicacaoController =
      TextEditingController();
  final TextEditingController _dateReforcoController = TextEditingController();
  final TextEditingController _numeroLoteController = TextEditingController();
  final TextEditingController _efeitosColateraisController =
      TextEditingController();
  final FocusNode _dateAplicacaoFocusNode = FocusNode();
  final FocusNode _dateReforcoFocusNode = FocusNode();
  final FocusNode _numeroLoteFocusNode = FocusNode();
  final FocusNode _efeitosColateraisFocusNode = FocusNode();

  String? _tipoVacinaSelecionado;
  String? _selectedDependent;
  File? _selectedFile;
  bool _isLoading = false;
  List<String> _dependents = ['Sem dependente'];

  @override
  void initState() {
    super.initState();
    _populateFieldsWithExistingData();
    _loadDependents();
  }

  void _populateFieldsWithExistingData() {
    if (widget.vacinaParaEditar != null) {
      _dateAplicacaoController.text = widget.vacinaParaEditar!.dateAplicacao;
      _dateReforcoController.text = widget.vacinaParaEditar!.dateReforco ?? '';
      _tipoVacinaSelecionado = widget.vacinaParaEditar!.tipo;
      _numeroLoteController.text = widget.vacinaParaEditar!.numeroLote ?? '';
      _efeitosColateraisController.text =
          widget.vacinaParaEditar!.efeitosColaterais ?? '';
      _selectedDependent =
          widget.vacinaParaEditar!.dependentId ?? 'Sem dependente';
    }
  }

  Future<void> _loadDependents() async {
    // Carregue os dependentes aqui
  }

  @override
  Widget build(BuildContext context) {
    final vacinaViewModel = context.read<VacinaViewModel>();

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            _buildTitle(),
            _buildDateAplicacaoField(),
            const SizedBox(height: 8),
            _buildDateReforcoField(),
            const Padding(padding: EdgeInsets.all(8)),
            _buildTipoVacinaDropdown(),
            const Padding(padding: EdgeInsets.all(8)),
            _buildDependentDropdown(),
            const Padding(padding: EdgeInsets.all(8)),
            _buildNumeroLoteField(),
            const Padding(padding: EdgeInsets.all(8)),
            _buildEfeitosColateraisField(),
            const Padding(padding: EdgeInsets.all(9)),
            _buildFilePickerButton(),
            const SizedBox(height: 8),
            _buildSubmitButton(vacinaViewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: const Text(
        'Inserir as informações da vacina',
        style: TextStyle(
          fontSize: 23,
          color: Color(0xFF265797),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDateAplicacaoField() {
    return TextField(
      controller: _dateAplicacaoController,
      focusNode: _dateAplicacaoFocusNode,
      decoration: InputDecoration(
        label: Text(
          'Data de Aplicação',
          style: TextStyle(color: _getIconColor(_dateAplicacaoFocusNode)),
        ),
        suffixIcon: const Icon(Icons.calendar_today),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF265797),
            width: 2,
          ),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
      ),
      onTap: () async {
        DateTime? date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          _dateAplicacaoController.text =
              "${date.day}/${date.month}/${date.year}";
        }
      },
    );
  }

  Widget _buildDateReforcoField() {
    return TextField(
      controller: _dateReforcoController,
      focusNode: _dateReforcoFocusNode,
      decoration: InputDecoration(
        label: Text(
          'Data de Reforço (opcional)',
          style: TextStyle(color: _getIconColor(_dateReforcoFocusNode)),
        ),
        suffixIcon: const Icon(Icons.calendar_today),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF265797),
            width: 2,
          ),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
      ),
      onTap: () async {
        DateTime? date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          _dateReforcoController.text =
              "${date.day}/${date.month}/${date.year}";
        }
      },
    );
  }

  Widget _buildTipoVacinaDropdown() {
    return DropdownButtonFormField<String>(
      value: _tipoVacinaSelecionado,
      hint: const Text('Selecione o tipo de vacina'),
      onChanged: (String? newValue) {
        setState(() {
          _tipoVacinaSelecionado = newValue;
        });
      },
      items: <String>['BCG', 'Hepatite B', 'Pentavalente', 'Rotavírus']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: (value) => value == null ? 'Campo obrigatório' : null,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFF265797),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildDependentDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDependent,
      hint: const Text('Selecione o dependente (opcional)'),
      onChanged: (String? newValue) {
        setState(() {
          _selectedDependent = newValue;
        });
      },
      items: _dependents.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFF265797),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildNumeroLoteField() {
    return TextFormField(
      controller: _numeroLoteController,
      focusNode: _numeroLoteFocusNode,
      decoration: InputDecoration(
        label: Text(
          'Número/Lote de Sequência',
          style: TextStyle(color: _getIconColor(_numeroLoteFocusNode)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFF265797),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildEfeitosColateraisField() {
    return TextFormField(
      controller: _efeitosColateraisController,
      focusNode: _efeitosColateraisFocusNode,
      decoration: InputDecoration(
        label: Text(
          'Efeitos Colaterais',
          style: TextStyle(color: _getIconColor(_efeitosColateraisFocusNode)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFF265797),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      keyboardType: TextInputType.multiline,
      maxLines: null,
    );
  }

  Widget _buildFilePickerButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 50,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(const Color(0xFF265797)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
          padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
        ),
        onPressed: _pickFile,
        child: const Text(
          'Adicionar comprovante',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(VacinaViewModel vacinaViewModel) {
    return SizedBox(
      width: 150,
      height: 50,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(const Color(0xFF265797)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
          padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
        ),
        onPressed: _isLoading ? null : () => _submitForm(vacinaViewModel),
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Text(
                "Adicionar Vacina",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  void _submitForm(VacinaViewModel vacinaViewModel) async {
    setState(() {
      _isLoading = true;
    });

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    String errorMessage = _validateInputs(userId);

    if (errorMessage.isEmpty) {
      String? uploadedFileUrl = await _uploadFile();
      if (uploadedFileUrl != null ||
          widget.vacinaParaEditar?.arquivoUrl != null) {
        await _saveVacina(userId!, uploadedFileUrl, vacinaViewModel);
        _showSuccessMessage();
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        errorMessage = 'Falha no upload do arquivo.';
      }
    }

    if (errorMessage.isNotEmpty) {
      _showErrorMessage(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _validateInputs(String? userId) {
    if (userId == null) {
      return 'Você precisa estar logado para adicionar uma vacina.';
    } else if (_dateAplicacaoController.text.isEmpty) {
      return 'Por favor, preencha a data de aplicação da vacina.';
    } else if (_tipoVacinaSelecionado == null) {
      return 'Por favor, selecione o tipo de vacina.';
    } else if (_selectedFile == null &&
        widget.vacinaParaEditar?.arquivoUrl == null) {
      return 'Por favor, selecione um arquivo para a vacina.';
    }
    return '';
  }

  Future<String?> _uploadFile() async {
    if (_selectedFile != null) {
      return await StorageService().uploadFile(_selectedFile!);
    }
    return widget.vacinaParaEditar?.arquivoUrl;
  }

  Future<void> _saveVacina(String userId, String? uploadedFileUrl,
      VacinaViewModel vacinaViewModel) async {
    final Vacina novaVacina = Vacina(
      id: widget.vacinaParaEditar?.id ?? '',
      dateAplicacao: _dateAplicacaoController.text,
      dateReforco: _dateReforcoController.text.isNotEmpty
          ? _dateReforcoController.text
          : null,
      tipo: _tipoVacinaSelecionado!,
      userId: userId,
      numeroLote: _numeroLoteController.text.isNotEmpty
          ? _numeroLoteController.text
          : null,
      efeitosColaterais: _efeitosColateraisController.text.isNotEmpty
          ? _efeitosColateraisController.text
          : null,
      arquivoUrl: uploadedFileUrl ?? '',
      dependentId:
          _selectedDependent == 'Sem dependente' ? null : _selectedDependent,
    );

    if (widget.vacinaParaEditar == null) {
      await vacinaViewModel.addVacina(novaVacina);
    } else {
      await vacinaViewModel.updateVacina(novaVacina);
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Vacina adicionada com sucesso!'),
      backgroundColor: Colors.green,
    ));
  }

  void _showErrorMessage(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(errorMessage),
      backgroundColor: Colors.red,
    ));
  }

  Color _getIconColor(FocusNode focusNode) {
    return focusNode.hasFocus ? const Color(0xFF265797) : Colors.grey;
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }
}