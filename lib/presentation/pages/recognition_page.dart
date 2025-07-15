import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/recognition_service.dart';

class RecognitionPage extends StatefulWidget {
  const RecognitionPage({Key? key}) : super(key: key);

  @override
  State<RecognitionPage> createState() => _RecognitionPageState();
}

class _RecognitionPageState extends State<RecognitionPage> {
  final RecognitionService _recognitionService = RecognitionService();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  bool _isLoading = false;
  ComprehensiveRecognitionResult? _recognitionResult;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 识别'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageSelector(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
            if (_isLoading) _buildLoadingIndicator(),
            if (_errorMessage != null) _buildErrorMessage(),
            if (_recognitionResult != null) _buildRecognitionResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSelector() {
    return Card(
      elevation: 4,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              )
            : InkWell(
                onTap: _pickImage,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '点击选择图片',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_library),
            label: const Text('选择图片'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _selectedImage != null && !_isLoading
                ? _recognizeImage
                : null,
            icon: const Icon(Icons.psychology),
            label: const Text('开始识别'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在识别中，请稍候...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecognitionResult() {
    final result = _recognitionResult!;
    final analysis = result.data?.recognition.analysis;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '识别结果',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildImageDescription(analysis?.description ?? ''),
                const SizedBox(height: 16),
                _buildObjectsSection(analysis?.objects ?? []),
                const SizedBox(height: 16),
                _buildEntitiesSection(analysis?.entities ?? []),
                const SizedBox(height: 16),
                _buildTagsSection(analysis?.suggestedTags ?? []),
                const SizedBox(height: 16),
                _buildColorsSection(analysis?.dominantColors ?? []),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildTagSuggestions(),
      ],
    );
  }

  Widget _buildImageDescription(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '图像描述',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            description.isNotEmpty ? description : '无描述',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildObjectsSection(List<DetectedObject> objects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '检测到的物体',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (objects.isEmpty)
          const Text('未检测到物体', style: TextStyle(color: Colors.grey))
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: objects.map((obj) {
              return Chip(
                label: Text('${obj.name} (${(obj.confidence * 100).toStringAsFixed(1)}%)'),
                backgroundColor: _getConfidenceColor(obj.confidence),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildEntitiesSection(List<EntityInfo> entities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '识别实体',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (entities.isEmpty)
          const Text('未识别到实体', style: TextStyle(color: Colors.grey))
        else
          Column(
            children: entities.map((entity) {
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Text(entity.category.substring(0, 1).toUpperCase()),
                ),
                title: Text(entity.entity),
                subtitle: Text('${entity.category} - ${entity.description}'),
                trailing: Text(
                  '${(entity.confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: _getConfidenceColor(entity.confidence),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildTagsSection(List<String> tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '建议标签',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (tags.isEmpty)
          const Text('无标签建议', style: TextStyle(color: Colors.grey))
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: tags.map((tag) {
              return Chip(
                label: Text(tag),
                backgroundColor: Colors.purple.shade100,
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildColorsSection(List<String> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '主要颜色',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (colors.isEmpty)
          const Text('无颜色信息', style: TextStyle(color: Colors.grey))
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: colors.map((color) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _parseColor(color),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  color,
                  style: TextStyle(
                    color: _getTextColor(_parseColor(color)),
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildTagSuggestions() {
    final tagSuggestions = _recognitionResult?.data?.tagSuggestions;
    if (tagSuggestions == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '标签建议',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tagSuggestions.message,
              style: TextStyle(
                color: tagSuggestions.success ? Colors.green : Colors.red,
              ),
            ),
            if (tagSuggestions.success && tagSuggestions.tagIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '生成了 ${tagSuggestions.tagIds.length} 个标签',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.8) return Colors.green.shade100;
    if (confidence > 0.6) return Colors.orange.shade100;
    return Colors.red.shade100;
  }

  Color _parseColor(String colorString) {
    try {
      // 处理十六进制颜色
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) | 0xFF000000);
      }
      return Colors.grey.shade300;
    } catch (e) {
      return Colors.grey.shade300;
    }
  }

  Color _getTextColor(Color backgroundColor) {
    // 计算亮度来决定文字颜色
    final brightness = (backgroundColor.red * 299 + backgroundColor.green * 587 + backgroundColor.blue * 114) / 1000;
    return brightness > 128 ? Colors.black : Colors.white;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _recognitionResult = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '选择图片失败: $e';
      });
    }
  }

  Future<void> _recognizeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _recognitionResult = null;
    });

    try {
      final result = await _recognitionService.comprehensiveRecognition(_selectedImage!);
      setState(() {
        _recognitionResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '识别失败4: $e';
        _isLoading = false;
      });
    }
  }
} 