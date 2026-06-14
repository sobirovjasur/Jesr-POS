import 'dart:io';

import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_sizes.dart';
import '../../providers/account/account_notifier.dart';
import '../../providers/main/main_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';

/// Edit profile (Figma 20 — "Изменить данные").
class ProfileFormScreen extends ConsumerStatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final branchController = TextEditingController();
  final cashboxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(accountNotifierProvider.notifier).initProfileForm();

      final state = ref.read(accountNotifierProvider);
      nameController.text = state.name ?? '';
      emailController.text = state.email ?? '';
      phoneController.text = state.phone ?? '';
      branchController.text = state.branch ?? '';
      cashboxController.text = state.cashbox ?? '';
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    branchController.dispose();
    cashboxController.dispose();
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
      ref.read(accountNotifierProvider.notifier).onChangedImage(File(croppedFile.path));
    }
  }

  void updatedUser() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(accountNotifierProvider.notifier).updatedUser();
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop();
      AppSnackBar.show('Готово', message: 'Данные обновлены');
      ref.read(mainNotifierProvider.notifier).getAndSyncAllUserData();
    } else {
      AppDialog.showError(error: res.error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.read(accountNotifierProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    final isLoaded = ref.watch(accountNotifierProvider.select((s) => s.isLoaded));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Изменить данные', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                        Center(child: _AvatarPicker(onTap: onTapImage)),
                        const SizedBox(height: AppSizes.padding * 1.5),
                        AppTextField(
                          controller: nameController,
                          labelText: 'Имя',
                          hintText: 'Ваше имя',
                          onChanged: account.onChangedName,
                        ),
                        const SizedBox(height: AppSizes.padding),
                        AppTextField(
                          controller: emailController,
                          labelText: 'Почта',
                          hintText: 'Ваша почта',
                          keyboardType: TextInputType.emailAddress,
                          onChanged: account.onChangedEmail,
                        ),
                        const SizedBox(height: AppSizes.padding),
                        AppTextField(
                          controller: phoneController,
                          labelText: 'Телефон номер',
                          hintText: 'Номер телефона',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: account.onChangedPhone,
                        ),
                        const SizedBox(height: AppSizes.padding),
                        AppTextField(
                          controller: branchController,
                          labelText: 'Филиал',
                          hintText: 'Название вашего филиала',
                          onChanged: account.onChangedBranch,
                        ),
                        const SizedBox(height: AppSizes.padding),
                        AppTextField(
                          controller: cashboxController,
                          labelText: 'Касса',
                          hintText: 'Название кассы',
                          onChanged: account.onChangedCashbox,
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.padding),
                    child: AppButton(
                      text: 'Сохранить',
                      width: double.infinity,
                      height: 52,
                      fontSize: 18,
                      onTap: updatedUser,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _AvatarPicker extends ConsumerWidget {
  final VoidCallback onTap;

  const _AvatarPicker({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageFile = ref.watch(accountNotifierProvider.select((s) => s.imageFile));
    final imageUrl = ref.watch(accountNotifierProvider.select((s) => s.imageUrl));
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: AppImage(
              image: imageFile?.path ?? imageUrl ?? '',
              imgProvider: imageFile != null ? ImgProvider.fileImage : ImgProvider.networkImage,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              backgroundColor: AppColors.imageBackground,
              errorWidget: Icon(Icons.person_rounded, color: colorScheme.outline, size: 44),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 2),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
