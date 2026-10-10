import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../utils/app_colors.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductProvider _provider = ProductProvider();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _processorController;
  late TextEditingController _ramController;
  late TextEditingController _storageController;
  late TextEditingController _gpuController;
  late TextEditingController _screenSizeController;
  late TextEditingController _osController;
  late TextEditingController _stockController;
  late TextEditingController _imageUrlController;
  late TextEditingController _descriptionController;

  late String _selectedBrand;
  late String _selectedCategory;
  bool _isSaving = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(
        text: p != null ? p.price.toStringAsFixed(0) : '');
    _processorController =
        TextEditingController(text: p?.processor ?? 'Intel Core i7 12th Gen');
    _ramController = TextEditingController(text: p?.ram ?? '16 GB');
    _storageController =
        TextEditingController(text: p?.storage ?? '512 GB SSD');
    _gpuController =
        TextEditingController(text: p?.gpu ?? 'Intel Iris Xe Graphics');
    _screenSizeController =
        TextEditingController(text: p?.screenSize ?? '15.6"');
    _osController = TextEditingController(text: p?.os ?? 'Windows 11 Home');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '10');
    _imageUrlController = TextEditingController(
      text: p?.imageUrl ??
          'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=600',
    );
    _descriptionController = TextEditingController(text: p?.description ?? '');

    _selectedBrand = p?.brand ?? _provider.brands.first;
    _selectedCategory = p?.category ??
        (_provider.categories.isNotEmpty
            ? _provider.categories.first.title
            : 'Business');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _processorController.dispose();
    _ramController.dispose();
    _storageController.dispose();
    _gpuController.dispose();
    _screenSizeController.dispose();
    _osController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final id = isEditing
        ? widget.product!.id
        : 'laptop_${DateTime.now().millisecondsSinceEpoch}';

    final updatedProduct = ProductModel(
      id: id,
      name: _nameController.text.trim(),
      brand: _selectedBrand,
      category: _selectedCategory,
      price: double.tryParse(_priceController.text.trim()) ?? 95000.0,
      imageUrl: _imageUrlController.text.trim(),
      images: [
        _imageUrlController.text.trim(),
        'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=600',
      ],
      processor: _processorController.text.trim(),
      ram: _ramController.text.trim(),
      storage: _storageController.text.trim(),
      gpu: _gpuController.text.trim(),
      screenSize: _screenSizeController.text.trim(),
      operatingSystem: _osController.text.trim(),
      stock: int.tryParse(_stockController.text.trim()) ?? 10,
      rating: widget.product?.rating ?? 4.5,
      reviewsCount: widget.product?.reviewsCount ?? 0,
      description: _descriptionController.text.trim(),
      isFeatured: widget.product?.isFeatured ?? false,
      isLatest: widget.product?.isLatest ?? true,
      popularity: widget.product?.popularity ?? 80,
    );

    if (isEditing) {
      _provider.updateProduct(updatedProduct);
    } else {
      _provider.addProduct(updatedProduct);
    }

    setState(() => _isSaving = false);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing
            ? '✅ Product "${updatedProduct.name}" updated successfully!'
            : '✅ Product "${updatedProduct.name}" added successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Product' : 'Add New Product',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Basic Information',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration:
                          _inputDeco('Laptop Name', Icons.laptop_chromebook),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Product name is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedBrand,
                            dropdownColor: AppColors.surface,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                            decoration:
                                _inputDeco('Brand', Icons.branding_watermark),
                            items: _provider.brands
                                .map((b) =>
                                    DropdownMenuItem(value: b, child: Text(b)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null)
                                setState(() => _selectedBrand = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            dropdownColor: AppColors.surface,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                            decoration:
                                _inputDeco('Category', Icons.category_rounded),
                            items: _provider.categories
                                .map((c) => DropdownMenuItem(
                                    value: c.title, child: Text(c.title)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null)
                                setState(() => _selectedCategory = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDeco(
                                'Price (Rs.)', Icons.monetization_on_outlined),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'Price is required'
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDeco(
                                'Stock Qty', Icons.inventory_2_outlined),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'Stock is required'
                                    : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _imageUrlController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco('Image URL', Icons.image_outlined),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Image URL is required'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Technical Specifications',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _processorController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco(
                          'Processor (e.g. Core i7 12th Gen)',
                          Icons.memory_rounded),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ramController,
                            style: const TextStyle(color: Colors.white),
                            decoration:
                                _inputDeco('RAM (e.g. 16 GB)', Icons.memory),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _storageController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDeco('Storage (e.g. 512 GB SSD)',
                                Icons.storage_rounded),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _gpuController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco('GPU (e.g. RTX 3050 4GB)',
                          Icons.videogame_asset_outlined),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _screenSizeController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDeco(
                                'Screen Size (e.g. 15.6")', Icons.laptop),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _osController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDeco('Operating System',
                                Icons.settings_system_daydream),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco(
                          'Product Description', Icons.description_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProduct,
                  icon: const Icon(Icons.check_circle_outline,
                      color: Colors.white),
                  label: Text(
                    isEditing ? 'Save Changes' : 'Add Laptop to Store',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
