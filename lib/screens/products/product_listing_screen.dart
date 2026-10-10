import 'package:flutter/material.dart';
import '../../providers/product_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/laptop_card.dart';

class ProductListingScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialBrand;

  const ProductListingScreen({
    super.key,
    this.initialCategory,
    this.initialBrand,
  });

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  final ProductProvider _provider = ProductProvider();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String? _selectedCategory;
  String _sortBy = 'popular';

  final Set<String> _selectedBrands = {};
  final Set<String> _selectedRams = {};
  final Set<String> _selectedStorages = {};
  final Set<String> _selectedProcessors = {};
  final Set<String> _selectedScreenSizes = {};
  RangeValues _priceRange = const RangeValues(0, 600000);
  double? _minRating;

  final List<String> _brandOptions = [
    'HP',
    'Dell',
    'Lenovo',
    'Apple',
    'Asus',
    'Acer',
    'MSI'
  ];
  final List<String> _ramOptions = ['8 GB', '16 GB', '32 GB', '64 GB'];
  final List<String> _storageOptions = ['256 GB', '512 GB', '1 TB', '2 TB'];
  final List<String> _processorOptions = [
    'Core i5',
    'Core i7',
    'Core i9',
    'Apple M-Series',
    'AMD Ryzen'
  ];
  final List<String> _screenSizeOptions = ['13" - 14"', '15" - 16"', '17"+'];

  final Map<String, String> _sortLabels = {
    'popular': 'Popular',
    'price_low_high': 'Price Low → High',
    'price_high_low': 'Price High → Low',
    'newest': 'Newest',
    'best_rated': 'Best Rated',
  };

  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  static const int _pageSize = 6;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    if (widget.initialBrand != null && widget.initialBrand != 'All') {
      _selectedBrands.add(widget.initialBrand!);
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    final totalFiltered = _provider.filterProducts(
      searchQuery: _searchQuery,
      category: _selectedCategory,
      selectedBrands: _selectedBrands,
      minPrice: _priceRange.start > 0 ? _priceRange.start : null,
      maxPrice: _priceRange.end < 600000 ? _priceRange.end : null,
      selectedRams: _selectedRams,
      selectedStorages: _selectedStorages,
      selectedProcessors: _selectedProcessors,
      selectedScreenSizes: _selectedScreenSizes,
      minRating: _minRating,
      sortBy: _sortBy,
    );

    if ((_currentPage * _pageSize) < totalFiltered.length) {
      setState(() => _isLoadingMore = true);
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          _currentPage++;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _resetPagination() {
    if (_currentPage != 1) {
      setState(() => _currentPage = 1);
    }
  }

  int get _activeFiltersCount {
    int count = 0;
    count += _selectedBrands.length;
    count += _selectedRams.length;
    count += _selectedStorages.length;
    count += _selectedProcessors.length;
    count += _selectedScreenSizes.length;
    if (_minRating != null) count++;
    if (_priceRange.start > 0 || _priceRange.end < 600000) count++;
    return count;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedBrands.clear();
      _selectedRams.clear();
      _selectedStorages.clear();
      _selectedProcessors.clear();
      _selectedScreenSizes.clear();
      _priceRange = const RangeValues(0, 600000);
      _minRating = null;
      _resetPagination();
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Filter Laptops',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setModalState(() {
                                    _clearAllFilters();
                                  });
                                  setState(() {});
                                },
                                child: const Text(
                                  'Reset All',
                                  style:
                                      TextStyle(color: AppColors.primaryLight),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: AppColors.border, height: 1),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        children: [
                          _buildSectionTitle('Brand'),
                          ..._brandOptions.map((brand) {
                            final isChecked = _selectedBrands.contains(brand);
                            return CheckboxListTile(
                              title: Text(brand,
                                  style: const TextStyle(color: Colors.white)),
                              value: isChecked,
                              activeColor: AppColors.primary,
                              checkColor: Colors.white,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              onChanged: (val) {
                                setModalState(() {
                                  if (val == true) {
                                    _selectedBrands.add(brand);
                                  } else {
                                    _selectedBrands.remove(brand);
                                  }
                                });
                                setState(() {});
                              },
                            );
                          }),
                          const SizedBox(height: 16),
                          _buildSectionTitle('RAM'),
                          ..._ramOptions.map((ram) {
                            final isChecked = _selectedRams.contains(ram);
                            return CheckboxListTile(
                              title: Text(ram,
                                  style: const TextStyle(color: Colors.white)),
                              value: isChecked,
                              activeColor: AppColors.primary,
                              checkColor: Colors.white,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              onChanged: (val) {
                                setModalState(() {
                                  if (val == true) {
                                    _selectedRams.add(ram);
                                  } else {
                                    _selectedRams.remove(ram);
                                  }
                                });
                                setState(() {});
                              },
                            );
                          }),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Storage'),
                          ..._storageOptions.map((storage) {
                            final isChecked =
                                _selectedStorages.contains(storage);
                            return CheckboxListTile(
                              title: Text(storage,
                                  style: const TextStyle(color: Colors.white)),
                              value: isChecked,
                              activeColor: AppColors.primary,
                              checkColor: Colors.white,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              onChanged: (val) {
                                setModalState(() {
                                  if (val == true) {
                                    _selectedStorages.add(storage);
                                  } else {
                                    _selectedStorages.remove(storage);
                                  }
                                });
                                setState(() {});
                              },
                            );
                          }),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Processor'),
                          ..._processorOptions.map((proc) {
                            final isChecked =
                                _selectedProcessors.contains(proc);
                            return CheckboxListTile(
                              title: Text(proc,
                                  style: const TextStyle(color: Colors.white)),
                              value: isChecked,
                              activeColor: AppColors.primary,
                              checkColor: Colors.white,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              onChanged: (val) {
                                setModalState(() {
                                  if (val == true) {
                                    _selectedProcessors.add(proc);
                                  } else {
                                    _selectedProcessors.remove(proc);
                                  }
                                });
                                setState(() {});
                              },
                            );
                          }),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Screen Size'),
                          ..._screenSizeOptions.map((size) {
                            final isChecked =
                                _selectedScreenSizes.contains(size);
                            return CheckboxListTile(
                              title: Text(size,
                                  style: const TextStyle(color: Colors.white)),
                              value: isChecked,
                              activeColor: AppColors.primary,
                              checkColor: Colors.white,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              onChanged: (val) {
                                setModalState(() {
                                  if (val == true) {
                                    _selectedScreenSizes.add(size);
                                  } else {
                                    _selectedScreenSizes.remove(size);
                                  }
                                });
                                setState(() {});
                              },
                            );
                          }),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Price Range'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rs. ${_priceRange.start.round()}',
                                style: const TextStyle(
                                    color: AppColors.primaryLight,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Rs. ${_priceRange.end.round()}',
                                style: const TextStyle(
                                    color: AppColors.primaryLight,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          RangeSlider(
                            values: _priceRange,
                            min: 0,
                            max: 600000,
                            divisions: 24,
                            activeColor: AppColors.primary,
                            inactiveColor: AppColors.border,
                            onChanged: (newRange) {
                              setModalState(() {
                                _priceRange = newRange;
                              });
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Rating'),
                          Wrap(
                            spacing: 8,
                            children: [
                              FilterChip(
                                label: const Text('⭐ 4.5 & above'),
                                selected: _minRating == 4.5,
                                selectedColor: AppColors.primary,
                                backgroundColor: AppColors.surfaceLight,
                                labelStyle: TextStyle(
                                  color: _minRating == 4.5
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                onSelected: (sel) {
                                  setModalState(() {
                                    _minRating = sel ? 4.5 : null;
                                  });
                                  setState(() {});
                                },
                              ),
                              FilterChip(
                                label: const Text('⭐ 4.0 & above'),
                                selected: _minRating == 4.0,
                                selectedColor: AppColors.primary,
                                backgroundColor: AppColors.surfaceLight,
                                labelStyle: TextStyle(
                                  color: _minRating == 4.0
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                onSelected: (sel) {
                                  setModalState(() {
                                    _minRating = sel ? 4.0 : null;
                                  });
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceLight,
                        border:
                            Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _currentPage = 1);
                            Navigator.pop(modalCtx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final categories = ['All', ..._provider.categories.map((c) => c.title)];

        final filteredProducts = _provider.filterProducts(
          searchQuery: _searchQuery,
          category: _selectedCategory,
          selectedBrands: _selectedBrands,
          minPrice: _priceRange.start > 0 ? _priceRange.start : null,
          maxPrice: _priceRange.end < 600000 ? _priceRange.end : null,
          selectedRams: _selectedRams,
          selectedStorages: _selectedStorages,
          selectedProcessors: _selectedProcessors,
          selectedScreenSizes: _selectedScreenSizes,
          minRating: _minRating,
          sortBy: _sortBy,
        );

        if (_provider.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              title: const Text('Browse Laptops',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            body: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Loading laptops...',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14)),
                ],
              ),
            ),
          );
        }

        final displayedProducts =
            filteredProducts.take(_currentPage * _pageSize).toList();
        final hasMore = displayedProducts.length < filteredProducts.length;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Text(
              _selectedCategory != null && _selectedCategory != 'All'
                  ? _selectedCategory!
                  : 'Browse Laptops',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list_rounded,
                        color: Colors.white),
                    onPressed: _showFilterModal,
                  ),
                  if (_activeFiltersCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$_activeFiltersCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort_rounded, color: Colors.white),
                color: AppColors.surfaceLight,
                initialValue: _sortBy,
                onSelected: (val) => setState(() {
                  _sortBy = val;
                  _currentPage = 1;
                }),
                itemBuilder: (context) => _sortLabels.entries.map((entry) {
                  return PopupMenuItem(
                    value: entry.key,
                    child: Row(
                      children: [
                        if (_sortBy == entry.key)
                          const Icon(Icons.check,
                              size: 16, color: AppColors.primary)
                        else
                          const SizedBox(width: 16),
                        const SizedBox(width: 8),
                        Text(entry.value,
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: Column(
            children: [
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {
                    _searchQuery = val;
                    _currentPage = 1;
                  }),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search: HP EliteBook, Dell Latitude, MacBook...',
                    hintStyle: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13),
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _currentPage = 1;
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Container(
                color: AppColors.surface,
                height: 44,
                padding: const EdgeInsets.only(bottom: 6),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final cat = categories[idx];
                    final isSelected =
                        (_selectedCategory == null && cat == 'All') ||
                            _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceLight,
                      labelStyle: TextStyle(
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = cat == 'All' ? null : cat;
                          _currentPage = 1;
                        });
                      },
                    );
                  },
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.background,
                child: Row(
                  children: [
                    Text(
                      hasMore
                          ? 'Showing ${displayedProducts.length} of ${filteredProducts.length} Laptops'
                          : '${filteredProducts.length} Laptops',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• Sorted by ${_sortLabels[_sortBy]}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    if (_activeFiltersCount > 0)
                      GestureDetector(
                        onTap: _clearAllFilters,
                        child: const Text(
                          'Clear Filters',
                          style: TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: filteredProducts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'No matching laptops found',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Try clearing some filters or searching for "HP EliteBook", "Dell Latitude", or "MacBook"',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _selectedCategory = null;
                                    _clearAllFilters();
                                  });
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reset All Filters'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return LaptopCard(
                                      product: displayedProducts[index]);
                                },
                                childCount: displayedProducts.length,
                              ),
                            ),
                          ),
                          if (_isLoadingMore)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Loading more laptops...',
                                        style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else if (hasMore)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: OutlinedButton.icon(
                                    onPressed: _loadMore,
                                    icon: const Icon(
                                        Icons.arrow_downward_rounded,
                                        size: 16),
                                    label: const Text('Load More Laptops'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primaryLight,
                                      side: const BorderSide(
                                          color: AppColors.border),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 20),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
