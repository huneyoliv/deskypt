import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_translation.dart';
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
  String _selectedContinent = 'Todos';

  static const List<String> _continents = [
    'Todos',
    'South America',
    'North America',
    'Europe',
    'Asia',
    'Africa',
    'Oceania',
    'Middle East',
    'Central Asia',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _countryCodeToEmoji(String code) {
    if (code.length != 2) return '🌐';
    final int firstLetter = code.toUpperCase().codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = code.toUpperCase().codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  String _formatContinentLabel(String continent, AppTranslation t) {
    switch (continent) {
      case 'Todos':
        return t.tr('all', fallback: 'Todos');
      case 'South America':
        return 'América do Sul';
      case 'North America':
        return 'América do Norte';
      case 'Europe':
        return 'Europa';
      case 'Asia':
        return 'Ásia';
      case 'Africa':
        return 'África';
      case 'Oceania':
        return 'Oceania';
      case 'Middle East':
        return 'Oriente Médio';
      case 'Central Asia':
        return 'Ásia Central';
      default:
        return continent;
    }
  }

  void _confirmCountrySelection(BuildContext context, CountryModel country) {
    final t = ref.read(appTranslationProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: [
            Text(_countryCodeToEmoji(country.code), style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Alterar Região / País',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deseja alterar sua região para ${country.formattedName} (${country.code})?',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Fuso Horário: ${country.timezone} (${country.gmtDisplay})',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('• Reinício do dia de estudo: ${country.startTime ?? "5:00 AM"}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text('• As matérias e rankings serão sincronizados com esta região.',
                      style: TextStyle(color: AppColors.primaryLight, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.tr('cancel', fallback: 'Cancelar'), style: const TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              await ref.read(settingsNotifierProvider.notifier).selectCountry(country);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Região alterada para ${country.formattedName} com sucesso! 🌍'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(t.tr('confirm', fallback: 'Confirmar'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsNotifierProvider);
    final allCountries = settingsState.availableCountries;
    final selectedCountry = settingsState.selectedCountry;
    final t = ref.watch(appTranslationProvider);

    final filtered = allCountries.where((c) {
      final q = _query.toLowerCase().trim();
      final matchesQuery = q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.code.toLowerCase().contains(q) ||
          c.continent.toLowerCase().contains(q) ||
          c.timezone.toLowerCase().contains(q);

      final matchesContinent = _selectedContinent == 'Todos' ||
          c.continent.toLowerCase() == _selectedContinent.toLowerCase();

      return matchesQuery && matchesContinent;
    }).toList();

    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            t.tr('region', fallback: 'Região & País'),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '${allCountries.length} Países',
              style: const TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        height: 560,
        child: Column(
          children: [
            // Current Region Active Banner
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Text(_countryCodeToEmoji(selectedCountry.code), style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              selectedCountry.formattedName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                selectedCountry.code,
                                style: const TextStyle(color: AppColors.primaryLight, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${selectedCountry.timezone} (${selectedCountry.gmtDisplay}) • Reset: ${selectedCountry.startTime ?? "5 AM"}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                ],
              ),
            ),

            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _query = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Pesquisar país, código (BR, US) ou fuso horário...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
            const SizedBox(height: 10),

            // Continent Filter Chips
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _continents.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final continent = _continents[index];
                  final isSelected = continent == _selectedContinent;

                  return ChoiceChip(
                    label: Text(_formatContinentLabel(continent, t)),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedContinent = continent);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Country List
            Expanded(
              child: settingsState.isLoadingCountries
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum país encontrado para esta busca',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
                          itemBuilder: (context, index) {
                            final CountryModel country = filtered[index];
                            final isSelected = country.id == selectedCountry.id;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              leading: Text(
                                _countryCodeToEmoji(country.code),
                                style: const TextStyle(fontSize: 26),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      country.formattedName,
                                      style: TextStyle(
                                        color: isSelected ? AppColors.primaryLight : Colors.white,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  if (country.gmtDisplay.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: Text(
                                        country.gmtDisplay,
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  '${country.timezone} • Reset: ${country.startTime ?? "5 AM"}',
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.radio_button_checked, color: AppColors.primary, size: 20)
                                  : const Icon(Icons.radio_button_off, color: AppColors.border, size: 20),
                              onTap: () => _confirmCountrySelection(context, country),
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
          child: Text(t.tr('close', fallback: 'Fechar'), style: const TextStyle(color: AppColors.textMuted)),
        ),
      ],
    );
  }
}
