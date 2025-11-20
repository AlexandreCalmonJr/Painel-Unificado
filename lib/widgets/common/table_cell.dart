// File: lib/widgets/common/table_cell.dart
import 'package:flutter/material.dart';

/// Widget reutilizável para células de tabela
class DataTableCellWidget extends StatelessWidget {
  final dynamic value;
  final bool isClickable;
  final VoidCallback? onTap;
  final TextAlign alignment;
  final TextStyle? textStyle;
  final Widget? trailing;
  final int? maxLines;

  const DataTableCellWidget({
    super.key,
    required this.value,
    this.isClickable = false,
    this.onTap,
    this.alignment = TextAlign.left,
    this.textStyle,
    this.trailing,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    if (isClickable && onTap != null) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: content,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: content,
    );
  }

  Widget _buildContent(BuildContext context) {
    // Se o valor já é um Widget, retorna direto
    if (value is Widget) {
      return value as Widget;
    }

    final textWidget = Text(
      value?.toString() ?? '-',
      textAlign: alignment,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      style: textStyle ??
          TextStyle(
            color: isClickable ? Colors.blue : Colors.black87,
            decoration: isClickable ? TextDecoration.underline : null,
          ),
    );

    if (trailing != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: textWidget),
          const SizedBox(width: 8),
          trailing!,
        ],
      );
    }

    return textWidget;
  }
}

/// Widget para cabeçalho de tabela
class TableHeader extends StatelessWidget {
  final String text;
  final TextAlign alignment;
  final bool sortable;
  final bool isSorted;
  final bool isAscending;
  final VoidCallback? onSort;

  const TableHeader({
    super.key,
    required this.text,
    this.alignment = TextAlign.left,
    this.sortable = false,
    this.isSorted = false,
    this.isAscending = true,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          textAlign: alignment,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        if (sortable) ...[
          const SizedBox(width: 4),
          Icon(
            isSorted
                ? (isAscending ? Icons.arrow_upward : Icons.arrow_downward)
                : Icons.unfold_more,
            size: 16,
            color: isSorted ? Colors.blue : Colors.grey,
          ),
        ],
      ],
    );

    if (sortable && onSort != null) {
      return InkWell(
        onTap: onSort,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: content,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: content,
    );
  }
}
