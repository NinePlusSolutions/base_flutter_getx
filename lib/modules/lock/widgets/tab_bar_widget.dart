import 'package:flutter/material.dart';

class TabBarWidget extends StatelessWidget {
  const TabBarWidget({
    super.key,
    required this.currentTabIndex,
    required this.tabs,
    required this.onTabChanged,
  });

  final int currentTabIndex;
  final List<TabItemData> tabs;
  final Function(int) onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final int index = entry.key;
          final TabItemData tab = entry.value;

          return TabItemWidget(
            index: index,
            currentTabIndex: currentTabIndex,
            title: tab.title,
            icon: tab.icon,
            count: tab.count ?? 0,
            onTabChanged: () => onTabChanged(index),
          );
        }).toList(),
      ),
    );
  }
}

class TabItemWidget extends StatelessWidget {
  const TabItemWidget({
    super.key,
    required this.index,
    required this.currentTabIndex,
    required this.title,
    required this.icon,
    required this.count,
    required this.onTabChanged,
  });

  final int index;
  final int currentTabIndex;
  final String title;
  final IconData icon;
  final int count;
  final VoidCallback onTabChanged;

  @override
  Widget build(BuildContext context) {
    final bool isActive = currentTabIndex == index;

    return Expanded(
      child: InkWell(
        onTap: onTabChanged,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 4),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TabItemData {
  final String title;
  final IconData icon;
  final int? count;

  const TabItemData({
    required this.title,
    required this.icon,
    this.count,
  });
}
