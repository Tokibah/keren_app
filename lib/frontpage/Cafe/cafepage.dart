import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keren_app/frontpage/Cafe/addcafe.dart';
import 'package:keren_app/frontpage/Cafe/cafecard_CP.dart';
import 'package:keren_app/frontpage/ModalFront/cafe_repo.dart';
import 'package:keren_app/frontpage/Cafe/cafesheet_CP.dart';

class CafePush extends StatelessWidget {
  const CafePush({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        onGenerateRoute: (settings) =>
            MaterialPageRoute(builder: (context) => const CafePage()),
      ),
    );
  }
}

class CafePage extends StatefulWidget {
  const CafePage({super.key});

  @override
  State<CafePage> createState() => _CafePageState();
}

class _CafePageState extends State<CafePage> {
  Cafe? _selectedCafe;
  bool _showCafeDetails = false;
  List<Cafe> _filteredCafes = [];
  Set<String> _selectedFilters = {'All'};
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCafes();
  }

  void _loadCafes() async {
    final cafes = await Cafe.getAllCafes();
    setState(() {
      _filteredCafes = cafes;
    });
  }

  void _updateSelectedCafe(Cafe newSelectedCafe) {
    setState(() {
      _selectedCafe = newSelectedCafe;
      _showCafeDetails = true;
    });
    _applyFilters();
  }

  void _applyFilters() async {
    var cafes = await Cafe.getAllCafes();
    setState(() {
      if (!_selectedFilters.contains('All')) {
        bool isReadFilter = _selectedFilters.contains('Read');
        cafes = cafes.where((cafe) => cafe.isRead == isReadFilter).toList();
      }
      if (_searchController.text.isNotEmpty) {
        cafes = cafes
            .where((cafe) => cafe.title
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      }
      _filteredCafes = cafes;
    });
  }

  Future<void> _refreshCafes() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _filteredCafes.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        RefreshIndicator(
          onRefresh: _refreshCafes,
          child: CustomScrollView(slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 250.r,
              flexibleSpace: FlexibleSpaceBar(
                background: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset("assets/gambar/kerenicon.png"),
                ),
              ),
            ),
///////////////////////////////////////////////////////////////////
            SliverToBoxAdapter(
              child: Column(children: [
                SizedBox(
                  width: 410.w,
                  child: SegmentedButton(
                    multiSelectionEnabled: false,
                    segments: const [
                      ButtonSegment(value: 'All', label: Text('All')),
                      ButtonSegment(value: 'New', label: Text('NEW')),
                      ButtonSegment(value: 'Read', label: Text('READ'))
                    ],
                    selected: _selectedFilters,
                    onSelectionChanged: (selection) {
                      setState(() {
                        _selectedFilters = selection;
                        _applyFilters();
                      });
                    },
                  ),
                ),
///////////////////////////////////////////////////////////////////
                Autocomplete<Cafe>(
                  optionsBuilder: (TextEditingValue textValue) {
                    if (textValue.text.isEmpty) {
                      return const Iterable<Cafe>.empty();
                    }
                    return _filteredCafes.where((cafe) => cafe.title
                        .toLowerCase()
                        .contains(textValue.text.toLowerCase()));
                  },
                  displayStringForOption: (cafe) => cafe.title,
                  onSelected: (selectedCafe) {
                    _searchController.text = selectedCafe.title;
                    _applyFilters();
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50.r),
                      child: TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.search),
                            hintText: 'search cafe..'),
                        onSubmitted: (value) {
                          _searchController.text = value;
                          _applyFilters();
                        },
                      ),
                    );
                  },
                ),
///////////////////////////////////////////////////////////////////
                Text('PROMOTION',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 28.sp)),
                CafeCard(
                    isPromoType: true,
                    cafes: _filteredCafes,
                    onCardTapped: _updateSelectedCafe),
                const Divider(indent: 20, endIndent: 20),
                Text('Recommendation', style: TextStyle(fontSize: 25.sp)),
                CafeCard(
                    isPromoType: false,
                    cafes: _filteredCafes,
                    onCardTapped: _updateSelectedCafe),
              ]),
            ),
          ]),
        ),
///////////////////////////////////////////////////////////////////
        if (_showCafeDetails) CafeSheet(cafe: _selectedCafe!),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddCafe()));
          _applyFilters();
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
