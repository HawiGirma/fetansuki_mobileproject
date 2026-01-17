import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fetansuki_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_item.dart';
import 'package:fetansuki_app/features/stock/presentation/providers/stock_providers.dart';
import 'package:fetansuki_app/common/widgets/custom_button.dart';
import 'package:fetansuki_app/common/widgets/custom_text_field.dart';

class CreateStockItemDialog extends ConsumerStatefulWidget {
  const CreateStockItemDialog({super.key});

  @override
  ConsumerState<CreateStockItemDialog> createState() => _CreateStockItemDialogState();
}

class _CreateStockItemDialogState extends ConsumerState<CreateStockItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _imagePath;
  bool _isQuickEntry = false;
  StockItem? _selectedBaseItem;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Use low quality/small size for demo persistence in Firestore (1MB limit)
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 200,
      maxHeight: 200,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);
      final dataUrl = 'data:image/jpeg;base64,$base64String';
      
      setState(() {
        _imagePath = pickedFile.path;
        _imageUrlController.text = dataUrl;
      });
    }
  }

  void _reuseItem(StockItem item) {
    setState(() {
      _selectedBaseItem = item;
      _nameController.text = item.name;
      _imageUrlController.text = item.imageUrl;
      _descriptionController.text = item.description ?? '';
      // We don't reuse price/quantity as those are usually what's being updated
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final item = StockItem(
      id: '',
      name: _nameController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      price: _priceController.text.isNotEmpty ? double.tryParse(_priceController.text.trim()) : null,
      quantity: _quantityController.text.trim(),
      description: _isQuickEntry ? _selectedBaseItem?.description : _descriptionController.text.trim(),
    );

    debugPrint('CREATING STOCK ITEM: ${item.name}, IMAGE URL LENGTH: ${item.imageUrl.length}');
    if (item.imageUrl.startsWith('data:')) {
      debugPrint('STOCK ITEM HAS DATA URL');
    }

    final success = await ref.read(stockCreationProvider.notifier).createStockItem(item);

    if (success && mounted) {
      ref.invalidate(stockDataProvider);
      ref.invalidate(dashboardDataProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock item created successfully!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(stockCreationProvider);
    final stockItemsAsync = ref.watch(stockDataProvider);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Add Stock Item', style: Theme.of(context).textTheme.titleLarge),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Quick Entry Toggle
                SwitchListTile(
                  title: const Text('Quick Entry (Price & Quantity Only)'),
                  value: _isQuickEntry,
                  activeColor: const Color(0xFF0F3C7E),
                  onChanged: (v) => setState(() => _isQuickEntry = v),
                ),
                const SizedBox(height: 16),

                // Reuse Existing Item Dropdown
                stockItemsAsync.when(
                  data: (items) => DropdownButtonFormField<StockItem>(
                    decoration: const InputDecoration(
                      labelText: 'Reuse Details From...',
                      prefixIcon: Icon(Icons.history),
                    ),
                    value: _selectedBaseItem,
                    items: items.recentlyAdded.map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.name),
                    )).toList(),
                    onChanged: (v) => v != null ? _reuseItem(v) : null,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),

                if (!_isQuickEntry) ...[
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Item Name',
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: _imageUrlController.text.isNotEmpty 
                            ? (_imageUrlController.text.startsWith('data:') 
                                ? Image.memory(base64Decode(_imageUrlController.text.split(',').last), fit: BoxFit.cover, width: double.infinity)
                                : Image.network(_imageUrlController.text, fit: BoxFit.cover, width: double.infinity))
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  const Text('Tap to Upload Image', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                        ),
                      ),
                      if (_imageUrlController.text.isNotEmpty)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _imagePath = null;
                              _imageUrlController.clear();
                            }),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _priceController,
                        hintText: 'Price',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _quantityController,
                        hintText: 'Quantity',
                      ),
                    ),
                  ],
                ),
                
                if (!_isQuickEntry) ...[
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _descriptionController,
                    hintText: 'Description',
                    maxLines: 3,
                  ),
                ],

                const SizedBox(height: 32),
                CustomButton(
                  text: 'Create Item',
                  isLoading: creationState.isLoading,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
