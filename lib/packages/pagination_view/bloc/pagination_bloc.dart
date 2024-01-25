import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'pagination_state.dart';

class PaginationCubit<T> extends Cubit<PaginationState<T>> {
  PaginationCubit(
      this.preloadedItems, this.callback, this.pageIndex, this.searchTerm)
      : super(PaginationInitial<T>());
  late int pageIndex;
  String? searchTerm;
  final List<T> preloadedItems;
  final Future<List<T>?> Function(int, String? searchTerm) callback;

  void setPageIndex(int pageIndex) {
    this.pageIndex = pageIndex;
  }

  void setSearchTerm(String? searchTerm) {
    this.searchTerm = searchTerm;
  }

  void fetchPaginatedList() {
    if (state is PaginationInitial) {
      _fetchAndEmitPaginatedList(previousList: preloadedItems);
    } else if (state is PaginationLoaded<T>) {
      final loadedState = state as PaginationLoaded;
      if (loadedState.hasReachedEnd) return;
      _fetchAndEmitPaginatedList(previousList: loadedState.items as List<T>);
    }
  }

  Future<void> refreshPaginatedList(String? searchTerm) async {
    pageIndex = 1;
    this.searchTerm = searchTerm;
    await _fetchAndEmitPaginatedList(previousList: preloadedItems);
  }

  Future<void> _fetchAndEmitPaginatedList({
    List<T> previousList = const [],
  }) async {
    try {
      final newList = await callback(pageIndex, searchTerm);
      if (newList != null) {
        pageIndex++;
        emit(PaginationLoaded(
          items: List<T>.from(previousList + newList),
          hasReachedEnd: newList.isEmpty,
        ));
        // pageIndex++;
      }
    } on Exception catch (error) {
      emit(PaginationError(error: error));
    }
  }

  List<dynamic>? getAllItems() {
    if(state is PaginationLoaded) {
      final loadedState = state as PaginationLoaded;
      return loadedState.items;
    }
    return null;
  }

  int _getAbsoluteOffset(int offset) => offset - preloadedItems.length;
}
