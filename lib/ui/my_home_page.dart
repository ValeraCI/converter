import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cipher_algorithm.dart';
import '../services/file_service.dart';
import '../utils/EncryptionUtils.dart';
import '../utils/TextUtils.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  String _convertedText = '';
  String _selectedAlgorithm = 'Цезарь';
  final FileService _fileService = FileService();
  CipherAlgorithm? _cipherAlgorithm;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _textController.text = prefs.getString('inputText') ?? '';
      _keyController.text = prefs.getString('key') ?? '';
      _selectedAlgorithm = prefs.getString('selectedAlgorithm') ?? 'Цезарь';
      _convertedText = prefs.getString('convertedText') ?? '';
    });
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('inputText', _textController.text);
    await prefs.setString('key', _keyController.text);
    await prefs.setString('selectedAlgorithm', _selectedAlgorithm);
    await prefs.setString('convertedText', _convertedText);
  }

  bool _hasUnsupportedCharacters(String text) {
    final unsupportedChars = RegExp(r'[^a-zA-Z\s]'); // Допускаются только латинские буквы и пробелы
    return unsupportedChars.hasMatch(text);
  }

  void _convertText() {
    setState(() {
      final inputText = _textController.text;

      if (inputText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введите текст для шифрования')),
        );
        return;
      }

      // Проверка на наличие неподдерживаемых символов
      if (TextUtils.hasUnsupportedCharacters(inputText)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Текст содержит неподдерживаемые символы! Они будут проигнорированы.'),
          ),
        );
      }

      // Выбор алгоритма шифрования
      _cipherAlgorithm = EncryptionUtils.getAlgorithm(
        _selectedAlgorithm,
        key: _keyController.text,
      );

      if (_cipherAlgorithm == null && _selectedAlgorithm == 'Вижинер') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введите ключ для Вижинера')),
        );
        return;
      }

      // Шифрование текста
      _convertedText = _cipherAlgorithm?.encrypt(inputText) ?? '';
      _savePreferences();  // Сохраняем после шифрования
    });
  }

  Future<void> _importText() async {
    try {
      final text = await _fileService.importText();
      if (text != null) {
        setState(() {
          _textController.text = text;
          _convertText();
        });
        _savePreferences();  // Сохраняем импортированный текст
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось загрузить файл')),
      );
    }
  }

  Future<void> _exportText() async {
    if (_convertedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет текста для экспорта')),
      );
      return;
    }
    try {
      final path = await _fileService.exportText(_convertedText);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Файл сохранен в: $path')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить файл')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Конвертер текста')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Введите текст'),
              onChanged: (value) => _savePreferences(), // Сохраняем при изменении текста
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedAlgorithm,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedAlgorithm = newValue!;
                  _keyController.clear();
                  _savePreferences(); // Сохраняем выбор алгоритма
                });
              },
              items: ['Цезарь', 'Атбаш', 'Морзе', 'Вижинер']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            if (_selectedAlgorithm == 'Вижинер')
              TextField(
                controller: _keyController,
                decoration: const InputDecoration(labelText: 'Введите ключ'),
                onChanged: (value) => _savePreferences(), // Сохраняем ключ
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convertText,
              child: const Text('Зашифровать'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  _convertedText,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _exportText,
              child: const Text('Экспортировать'),
            ),
            FloatingActionButton(
              onPressed: _importText,
              tooltip: 'Импортировать',
              child: const Icon(Icons.upload_file),
            ),
          ],
        ),
      ),
    );
  }
}
