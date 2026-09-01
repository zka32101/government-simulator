import 'package:flutter/material.dart';
import 'package:government_simulator/models/policy_explanation.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// 経済学の基礎概念と政策の理論的根拠を学べるハンドブック。
/// 教育的価値を高め、政治家や学習者がシミュレーターを通じて
/// 経済政策の原理を理解できるようにする。
class EconomicsHandbookScreen extends StatefulWidget {
  const EconomicsHandbookScreen({Key? key}) : super(key: key);

  @override
  State<EconomicsHandbookScreen> createState() =>
      _EconomicsHandbookScreenState();
}

class _EconomicsHandbookScreenState extends State<EconomicsHandbookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  EconomicCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('📚 経済学ハンドブック'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // タブセレクター
          Container(
            color: AppTheme.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.gold,
              labelColor: AppTheme.gold,
              unselectedLabelColor: AppTheme.textSecondary,
              tabs: const [
                Tab(text: '🎯 政策解説'),
                Tab(text: '📖 経済概念'),
              ],
            ),
          ),
          // タブコンテンツ
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPoliciesTab(),
                _buildConceptsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoliciesTab() {
    final explanations =
        PolicyExplanationDatabase.getAllExplanations();

    if (explanations.isEmpty) {
      return Center(
        child: Text(
          '政策説明データを読み込み中...',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: explanations.length,
      itemBuilder: (context, index) {
        final explanation = explanations[index];
        return _PolicyCard(explanation: explanation);
      },
    );
  }

  Widget _buildConceptsTab() {
    final allConcepts =
        PolicyExplanationDatabase.getAllConcepts();

    if (allConcepts.isEmpty) {
      return Center(
        child: Text(
          '概念データを読み込み中...',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    // Filter concepts by selected category
    final filteredConcepts = _selectedCategory == null
        ? allConcepts
        : allConcepts
            .where((c) => c.category == _selectedCategory)
            .toList();

    return Column(
      children: [
        // Category filter chips
        Container(
          color: AppTheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 8,
              children: [
                // All categories chip
                FilterChip(
                  label: const Text('すべて'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = null);
                  },
                  backgroundColor: AppTheme.surface,
                  selectedColor: AppTheme.gold.withValues(alpha: 0.3),
                  labelStyle: TextStyle(
                    color: _selectedCategory == null
                        ? AppTheme.gold
                        : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Category chips
                ...EconomicCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(category.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                    backgroundColor: AppTheme.surface,
                    selectedColor: AppTheme.gold.withValues(alpha: 0.3),
                    labelStyle: TextStyle(
                      color:
                          isSelected ? AppTheme.gold : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        // Concepts list
        Expanded(
          child: filteredConcepts.isEmpty
              ? Center(
                  child: Text(
                    'この カテゴリーに概念がありません',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredConcepts.length,
                  itemBuilder: (context, index) {
                    final concept = filteredConcepts[index];
                    return _ConceptCard(concept: concept);
                  },
                ),
        ),
      ],
    );
  }
}

class _PolicyCard extends StatefulWidget {
  final PolicyExplanation explanation;

  const _PolicyCard({required this.explanation});

  @override
  State<_PolicyCard> createState() => _PolicyCardState();
}

class _PolicyCardState extends State<_PolicyCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.surface,
      child: Column(
        children: [
          // ヘッダー（常に表示）
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.explanation.policyName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '理論: ${widget.explanation.economicTheory}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.gold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 詳細（展開時のみ）
          if (_isExpanded)
            Container(
              color: Colors.black.withOpacity(0.2),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: '作用メカニズム'),
                  Text(
                    widget.explanation.mechanism,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: '期待される効果'),
                  Text(
                    widget.explanation.expectedOutcomes,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.good,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: 'リスク・副作用'),
                  Text(
                    widget.explanation.risks,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.danger,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: '歴史的事例'),
                  Text(
                    widget.explanation.historicalPrecedents,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: '学習ポイント'),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                    ),
                    child: Text(
                      widget.explanation.keyTakeaway,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.gold,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: widget.explanation.relatedConcepts
                        .map((concept) => Chip(
                          label: Text(concept),
                          backgroundColor:
                              AppTheme.gold.withOpacity(0.2),
                          labelStyle: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.gold,
                          ),
                        ))
                        .toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ConceptCard extends StatefulWidget {
  final EconomicConcept concept;

  const _ConceptCard({required this.concept});

  @override
  State<_ConceptCard> createState() => _ConceptCardState();
}

class _ConceptCardState extends State<_ConceptCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.surface,
      child: Column(
        children: [
          // ヘッダー
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Visual mnemonic
                  Text(
                    widget.concept.visualMnemonic,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name with category badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.concept.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.gold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.concept.category.label,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.concept.shortDefinition,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          // 詳細
          if (_isExpanded)
            Container(
              color: Colors.black.withValues(alpha: 0.2),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: '詳細説明'),
                  Text(
                    widget.concept.detailedExplanation,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: '実例'),
                  Text(
                    widget.concept.realWorldExample,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.gold,
                      height: 1.6,
                    ),
                  ),
                  if (widget.concept.keyEquations.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionTitle(title: '主要な公式・関係式'),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.concept.keyEquations
                            .map((eq) => Text(
                                  '• $eq',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textPrimary,
                                    fontFamily: 'monospace',
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _SectionTitle(title: '歴史的背景'),
                  Text(
                    widget.concept.historicalContext,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  if (widget.concept.relatedPolicies.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionTitle(title: '関連する政策'),
                    Wrap(
                      spacing: 8,
                      children: widget.concept.relatedPolicies
                          .map((policy) => Chip(
                                label: Text(policy),
                                backgroundColor:
                                    AppTheme.gold.withValues(alpha: 0.2),
                                labelStyle: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.gold,
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppTheme.gold,
        ),
      ),
    );
  }
}
