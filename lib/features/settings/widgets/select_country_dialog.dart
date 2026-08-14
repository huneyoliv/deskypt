import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/country_model.dart';
import '../settings_notifier.dart';

class SelectCountryDialog extends ConsumerStatefulWidget {
  const SelectCountryDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const SelectCountryDialog(),
    );
  }

  @override
  ConsumerState<SelectCountryDialog> createState() => _SelectCountryDialogState();
}

class _SelectCountryDialogState extends ConsumerState<SelectCountryDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _countryCodeToEmoji(String code) {
    if (code.length != 2) return '🌐';
    final int firstLetter = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsNotifierProvider);
    final allCountries = settingsState.availableCountries;

    final filtered = allCountries.where((c) {
      final q = _query.toLowerCase().trim();
      if (q.isEmpty) return true;
      return c.name.toLowerCase().contains(q) ||
          c.code.toLowerCase().contains(q) ||
          c.continent.toLowerCase().contains(q);
    }).toList();

    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      title: const Text(
        'Selecionar Região / País',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 420,
        height: 480,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _query = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Pesquisar país ou código...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: settingsState.isLoadingCountries
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum país encontrado',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
                          itemBuilder: (context, index) {
                            final CountryModel country = filtered[index];
                            final isSelected = country.id == settingsState.selectedCountry.id;

                            return ListTile(
                              leading: Text(
                                _countryCodeToEmoji(country.code),
                                style: const TextStyle(fontSize: 24),
                              ),
                              title: Text(
                                country.name,
                                style: TextStyle(
                                  color: isSelected ? AppColors.primaryLight : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                '${country.code} • ${country.timezone}',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
                                  : null,
                              onTap: () {
                                ref.read(settingsNotifierProvider.notifier).selectCountry(country);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar', style: TextStyle(color: AppColors.textMuted)),
        ),
      ],
    );
  }
}
