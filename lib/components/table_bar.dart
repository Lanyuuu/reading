import 'package:flutter/material.dart';
import '/utile/font_icons.dart';

class TableBar extends StatefulWidget {
  const TableBar({Key? key}) : super(key: key);

  @override
  TableBarState createState() => TableBarState();
}

class TableBarState extends State<TableBar> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BarItem(IconFont.iconShujia, '书架', 18),
        BarItem(IconFont.iconTuijian, '推荐'),
        BarItem(IconFont.iconTongji, '统计'),
        BarItem(IconFont.iconWode, '我的', 16),
      ],
      currentIndex: _selectedIndex,
      onTap: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}

class BarItem extends BottomNavigationBarItem {
  BarItem(IconData icon, String label, [double size = 20])
      : super(
            icon: Icon(icon, size: size, color: Colors.black),
            label: label,
            backgroundColor: const Color.fromARGB(255, 94, 92, 92),
            activeIcon: Icon(icon, size: size, color: Colors.blue));
}
