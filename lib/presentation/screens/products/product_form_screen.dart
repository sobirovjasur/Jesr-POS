import 'dart:io';

import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/image/background_removal_service.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_sizes.dart';
import '../../providers/products/product_form_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';

/// Product create/edit form (Figma 13 — "Товары" / Create Product).
class ProductFormScreen extends ConsumerStatefulWidget {
  final int? id;

  const ProductFormScreen({super.key, this.id});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final installmentController = TextEditingController();
  final specsController = TextEditingController();
  final descController = TextEditingController();

  bool get _isEdit => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(productFormNotifierProvider.notifier).initProductForm(widget.id);

      final state = ref.read(productFormNotifierProvider);
      nameController.text = state.name ?? '';
      priceController.text = state.price?.toString() ?? '';
      stockController.text = state.stock?.toString() ?? '';
      installmentController.text = state.installmentMonths?.toString() ?? '';
      specsController.text = state.specifications ?? '';
      descController.text = state.description ?? '';
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    installmentController.dispose();
    specsController.dispose();
    descController.dispose();
    super.dispose();
  }

  void onTapImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile == null) return;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [AndroidUiSettings(toolbarTitle: 'Crop Photo'), IOSUiSettings(title: 'Crop Photo')],
    );

    if (croppedFile != null) {
      final file = File(croppedFile.path);

      // Best-effort background removal -> transparent PNG. Falls back to the
      // original image if no API key is set or the request fails.
      final noBgFile = await AppDialog.showProgress(() => BackgroundRemovalService.removeBackground(file));

      ref.read(productFormNotifierProvider.notifier).onChangedImage(noBgFile ?? file);
    }
  }

  void createProduct() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(productFormNotifierProvider.notifier).createProduct();
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.go('/products');
      AppSnackBar.show('Ваш продукт', message: 'Успешно добавлен в систему!');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  void updatedProduct() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(productFormNotifierProvider.notifier).updatedProduct(widget.id!);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop();
      AppSnackBar.show('Ваш продукт', message: 'Успешно обновлён!');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  void deleteProduct() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(productFormNotifierProvider.notifier).deleteProduct(widget.id!);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.go('/products');
      AppSnackBar.showWarning('Товар удалён', message: 'Продукт удалён из системы');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  void _confirmDelete() {
    AppDialog.show(
      title: 'Внимание',
      text: 'Хотите удалить этот товар?',
      leftButtonText: 'Нет',
      rightButtonText: 'Да',
      rightButtonColor: Theme.of(context).colorScheme.errorContainer,
      rightButtonTextColor: Theme.of(context).colorScheme.error,
      onTapRightButton: (context) {
        context.pop();
        deleteProduct();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(productFormNotifierProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    final isLoaded = ref.watch(productFormNotifierProvider.select((s) => s.isLoaded));
    final isFormValid = ref.watch(
      productFormNotifierProvider.select((s) => (s.name?.isNotEmpty ?? false) && (s.price ?? 0) > 0 && (s.stock ?? 0) > 0),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_isEdit ? 'Изменить товар' : 'Товары', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: !isLoaded
          ? const AppProgressIndicator()
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Фото товара', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSizes.padding / 2),
                        _PhotoPicker(onTap: onTapImage),
                        const SizedBox(height: AppSizes.padding),
                        AppTextField(
                          controller: nameController,
                          labelText: 'Название товара',
                          hintText: 'Название вашего продукта',
                          onChanged: notifier.onChangedName,
                        ),
                        const SizedBox(height: AppSizes.padding),
                        AppTextField(
                          controller: priceController,
                          labelText: 'Цена',
                          hintText: 'Цена товара',
                          type: AppTextFieldType.currency,
                          onChanged: notifier.onChangedPrice,
                        ),
                        const SizedBox(height: AppSizes.padding),
                        AppTextField(
                          controller: stockController,
                          labelText: 'Кол-во / Шт',
                          hintText: 'Количество',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: notifier.onChangedStock,
                        ),
                        const SizedBox(height: AppSizes.padding),
                        AppTextField(
                          controller: installmentController,
                          labelText: 'В рассрочку',
                          hintText: 'на 6 месяцев',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: notifier.onChangedInstallmentMonths,
                        ),
                        const SizedBox(height: AppSizes.padding),
                        AppTextField(
                          controller: specsController,
                          labelText: 'Характеристики',
                          hintText: 'Напишите',
                          maxLines: 4,
                          onChanged: notifier.onChangedSpecifications,
                        ),
                        const SizedBox(height: AppSizes.padding),
                        AppTextField(
                          controller: descController,
                          labelText: 'Описание товара',
                          hintText: 'Напишите',
                          maxLines: 4,
                          onChanged: notifier.onChangedDesc,
                        ),
                        if (_isEdit) ...[
                          const SizedBox(height: AppSizes.padding),
                          AppButton(
                            text: 'Удалить товар',
                            width: double.infinity,
                            height: 50,
                            textColor: Theme.of(context).colorScheme.error,
                            buttonColor: Theme.of(context).colorScheme.surface,
                            borderColor: Theme.of(context).colorScheme.error,
                            onTap: _confirmDelete,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.padding),
                    child: AppButton(
                      text: _isEdit ? 'Сохранить' : 'Добавить',
                      width: double.infinity,
                      height: 52,
                      fontSize: 18,
                      enabled: isFormValid,
                      disabledButtonColor: Theme.of(context).colorScheme.surfaceContainerLow,
                      onTap: _isEdit ? updatedProduct : createProduct,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _PhotoPicker extends ConsumerWidget {
  final VoidCallback onTap;

  const _PhotoPicker({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageFile = ref.watch(productFormNotifierProvider.select((p) => p.imageFile));
    final imageUrl = ref.watch(productFormNotifierProvider.select((p) => p.imageUrl));
    final hasImage = imageFile != null || (imageUrl?.isNotEmpty ?? false);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 110,
        height: 110,
        child: hasImage
            ? AppImage(
                image: imageFile?.path ?? imageUrl ?? '',
                imgProvider: imageFile != null ? ImgProvider.fileImage : ImgProvider.networkImage,
                width: 110,
                height: 110,
                fit: BoxFit.contain,
                borderRadius: AppRadius.cardAll,
                backgroundColor: AppColors.imageBackground,
                errorWidget: Icon(Icons.image, color: Theme.of(context).colorScheme.surfaceDim, size: 32),
              )
            : CustomPaint(
                painter: _DashedBorderPainter(color: AppColors.primary, radius: AppRadius.card),
                child: const Center(
                  child: Icon(Icons.add_rounded, color: AppColors.primary, size: 36),
                ),
              ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    const dash = 6.0;
    const gap = 4.0;

    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = dist + dash;
        canvas.drawPath(metric.extractPath(dist, next.clamp(0, metric.length)), paint);
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) => old.color != color || old.radius != radius;
}
