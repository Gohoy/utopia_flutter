import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/recognition_service.dart';

class RecognitionWidget extends StatefulWidget {
  final Function(ComprehensiveRecognitionResult)? onRecognitionComplete;
  final Function(String)? onDescriptionGenerated;
  final Function(List<String>)? onTagsGenerated;
  final bool showFullResults;
  final File? initialImage;

  const RecognitionWidget({
    Key? key,
    this.onRecognitionComplete,
    this.onDescriptionGenerated,
    this.onTagsGenerated,
    this.showFullResults = false,
    this.initialImage,
  }) : super(key: key);

  @override
  State<RecognitionWidget> createState() => _RecognitionWidgetState();
}

class _RecognitionWidgetState extends State<RecognitionWidget> {
  final RecognitionService _recognitionService = RecognitionService();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  bool _isLoading = false;
  ComprehensiveRecognitionResult? _recognitionResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialImage != null) {
      _selectedImage = widget.initialImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildImagePreview(),
            const SizedBox(height: 16),
            _buildActionButtons(),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              _buildLoadingIndicator(),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorMessage(),
            ],
            if (_recognitionResult != null) ...[
              const SizedBox(height: 16),
              _buildRecognitionResults(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.psychology,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        const Text(
          'AI 识别助手',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 120,
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
                width: double.infinity,
              ),
            )
          : InkWell(
              onTap: _pickImage,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 32,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '点击选择图片',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_library, size: 16),
            label: const Text('选择图片'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _selectedImage != null && !_isLoading
                ? _recognizeImage
                : null,
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: const Text('开始识别'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('正在识别中，请稍候...'),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecognitionResults() {
    final result = _recognitionResult!;
    final analysis = result.data?.recognition.analysis;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              const Text(
                '识别完成',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (analysis?.description.isNotEmpty == true) ...[
          _buildQuickResult(
            '图像描述',
            analysis!.description,
            Icons.description,
            () => widget.onDescriptionGenerated?.call(analysis.description),
          ),
          const SizedBox(height: 8),
        ],
        if (analysis?.suggestedTags.isNotEmpty == true) ...[
          _buildQuickResult(
            '建议标签',
            analysis!.suggestedTags.join(', '),
            Icons.local_offer,
            () => widget.onTagsGenerated?.call(analysis.suggestedTags),
          ),
          const SizedBox(height: 8),
        ],
        if (analysis?.objects.isNotEmpty == true) ...[
          _buildQuickResult(
            '检测到的物体',
            analysis!.objects.take(3).map((obj) => obj.name).join(', '),
            Icons.visibility,
            null,
          ),
          const SizedBox(height: 8),
        ],
        if (widget.showFullResults) ...[
          const SizedBox(height: 8),
          _buildViewDetailsButton(),
        ],
      ],
    );
  }

  Widget _buildQuickResult(String title, String content, IconData icon, VoidCallback? onApply) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              if (onApply != null)
                TextButton(
                  onPressed: onApply,
                  child: const Text('应用', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetailsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showDetailDialog(),
        icon: const Icon(Icons.info_outline, size: 16),
        label: const Text('查看详细结果'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  void _showDetailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('详细识别结果'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: _buildDetailedResults(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedResults() {
    final result = _recognitionResult!;
    final analysis = result.data?.recognition.analysis;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (analysis?.description.isNotEmpty == true) ...[
          const Text('图像描述', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(analysis!.description),
          const SizedBox(height: 16),
        ],
        if (analysis?.objects.isNotEmpty == true) ...[
          const Text('检测到的物体', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...analysis!.objects.map((obj) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('• ${obj.name} (${(obj.confidence * 100).toStringAsFixed(1)}%)'),
          )),
          const SizedBox(height: 16),
        ],
        if (analysis?.entities.isNotEmpty == true) ...[
          const Text('识别实体', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...analysis!.entities.map((entity) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('• ${entity.entity} (${entity.category})'),
          )),
          const SizedBox(height: 16),
        ],
        if (analysis?.suggestedTags.isNotEmpty == true) ...[
          const Text('建议标签', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: analysis!.suggestedTags.map((tag) => Chip(
              label: Text(tag, style: const TextStyle(fontSize: 12)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )).toList(),
          ),
        ],
      ],
    );
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
      
      // 调用回调函数
      widget.onRecognitionComplete?.call(result);
      
    } catch (e) {
      setState(() {
        _errorMessage = '识别失败6: $e';
        _isLoading = false;
      });
    }
  }
} 