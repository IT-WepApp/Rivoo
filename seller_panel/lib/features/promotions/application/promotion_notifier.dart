// 📁 seller_panel/lib/features/promotions/application/promotion_notifier.dart

import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/models/promotion.dart';
import 'package:shared_libs/services/product_service_provider.dart';
import 'package:shared_libs/services/services.dart';

class PromotionState {
  final Promotion? promotion;
  final bool isLoading;
  final String? error;
  final Map<String, String> validationErrors;

  PromotionState({
    this.promotion,
    this.isLoading = false,
    this.error,
    this.validationErrors = const {},
  });

  PromotionState copyWith({
    Object? promotion,
    bool? isLoading,
    String? error,
    Map<String, String>? validationErrors,
    bool clearError = false,
    bool clearValidationErrors = false,
  }) {
    return PromotionState(
      promotion: promotion is Promotion? ? promotion : this.promotion,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      validationErrors: clearValidationErrors
          ? {}
          : validationErrors ?? this.validationErrors,
    );
  }
}

class PromotionNotifier extends StateNotifier<PromotionState> {
  final ProductService _productService;
  final String productId;

  PromotionNotifier(this._productService, this.productId)
      : super(PromotionState()) {
    loadPromotion();
  }

  Future<void> loadPromotion() async {
    state = state.copyWith(
        isLoading: true, clearError: true, clearValidationErrors: true);
    try {
      final product = await _productService.getProduct(productId);
      Promotion? loadedPromotion;
      if (product != null &&
          product.promotionType != null &&
          product.promotionValue != null) {
        loadedPromotion = Promotion(
          type: product.promotionType!,
          value: product.promotionValue!,
          startDate: product.promotionStartDate,
          endDate: product.promotionEndDate,
        );
      }
      state = state.copyWith(promotion: loadedPromotion, isLoading: false);
    } catch (e, stacktrace) {
      log('Error loading promotion',
          error: e, stackTrace: stacktrace, name: 'PromotionNotifier');
      state = state.copyWith(
          isLoading: false, error: 'Failed to load promotion: $e');
    }
  }

  Future<bool> savePromotion(Promotion promotion) async {
    state = state.copyWith(
        isLoading: true, clearError: true, clearValidationErrors: true);
    final validationErrors = promotion.validate();
    if (validationErrors.isNotEmpty) {
      state =
          state.copyWith(isLoading: false, validationErrors: validationErrors);
      return false;
    }
    try {
      await _productService.updatePromotion(
        productId: productId,
        type: promotion.type,
        value: promotion.value,
        startDate: promotion.startDate,
        endDate: promotion.endDate,
      );
      state = state.copyWith(promotion: promotion, isLoading: false);
      return true;
    } catch (e, stacktrace) {
      log('Error saving promotion',
          error: e, stackTrace: stacktrace, name: 'PromotionNotifier');
      state = state.copyWith(
          isLoading: false, error: 'Failed to save promotion: $e');
      return false;
    }
  }

  Future<bool> deletePromotion() async {
    state = state.copyWith(
        isLoading: true, clearError: true, clearValidationErrors: true);
    try {
      await _productService.deletePromotion(productId);
      state = state.copyWith(promotion: null, isLoading: false);
      return true;
    } catch (e, stacktrace) {
      log('Error deleting promotion',
          error: e, stackTrace: stacktrace, name: 'PromotionNotifier');
      state = state.copyWith(
          isLoading: false, error: 'Failed to delete promotion: $e');
      return false;
    }
  }
}

final promotionProvider = StateNotifierProvider.autoDispose
    .family<PromotionNotifier, PromotionState, String>((ref, productId) {
  final productService = ref.watch(productServiceProvider);
  return PromotionNotifier(productService, productId);
});
