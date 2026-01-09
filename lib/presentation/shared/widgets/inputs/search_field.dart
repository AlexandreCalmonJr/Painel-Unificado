// File: lib/widgets/search_field.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

/// Campo de pesquisa com debounce para melhor performance
class SearchField extends StatefulWidget {

  const SearchField({
    super.key,
    required this.onSearch,
    this.hintText = 'Pesquisar...',
    this.debounceDuration = const Duration(milliseconds: 500),
    this.prefixIcon = Icons.search,
    this.suffixIcon,
  });
  final Function(String) onSearch;
  final String hintText;
  final Duration debounceDuration;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _searchController = TextEditingController();
  final _searchSubject = BehaviorSubject<String>();
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _searchSubject
        .debounceTime(widget.debounceDuration)
        .listen((query) => widget.onSearch(query));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _searchController.dispose();
    _searchSubject.close();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchSubject.add('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => _searchSubject.add(value),
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon)
            : null,
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearSearch,
              )
            : (widget.suffixIcon != null
                ? Icon(widget.suffixIcon)
                : null),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}

/// Campo de pesquisa compacto para uso em AppBar
class CompactSearchField extends StatefulWidget {

  const CompactSearchField({
    super.key,
    required this.onSearch,
    this.hintText = 'Pesquisar...',
    this.debounceDuration = const Duration(milliseconds: 500),
  });
  final Function(String) onSearch;
  final String hintText;
  final Duration debounceDuration;

  @override
  State<CompactSearchField> createState() => _CompactSearchFieldState();
}

class _CompactSearchFieldState extends State<CompactSearchField> {
  final _searchController = TextEditingController();
  final _searchSubject = BehaviorSubject<String>();
  StreamSubscription? _subscription;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _subscription = _searchSubject
        .debounceTime(widget.debounceDuration)
        .listen((query) => widget.onSearch(query));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _searchController.dispose();
    _searchSubject.close();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchSubject.add('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSearching) {
      return IconButton(
        icon: const Icon(Icons.search),
        onPressed: _toggleSearch,
      );
    }

    return Container(
      width: 250,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _searchSubject.add(value),
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _toggleSearch,
          ),
        ],
      ),
    );
  }
}
