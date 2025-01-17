import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';

List<Map<String, dynamic>> myTransactionData = [
  {
    'icon': const FaIcon(
      FontAwesomeIcons.burger,
      color: Colors.white,
    ),
    'name': 'Food',
    'color': Colors.yellow[700],
    'totalAmount': '145',
    'date': 'Yesterday',
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.shop,
      color: Colors.white,
    ),
    'name': 'Shopping',
    'color': Colors.purple[600],
    'totalAmount': '55',
    'date': 'Today',
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.tractor,
      color: Colors.white,
    ),
    'name': 'Transportation',
    'color': Colors.blue[700],
    'totalAmount': '145',
    'date': 'Yesterday',
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.tent,
      color: Colors.white,
    ),
    'name': 'Equipments',
    'color': Colors.green[700],
    'totalAmount': '830',
    'date': 'Today',
  },
  {
    'icon': const FaIcon(
      FontAwesomeIcons.dragon,
      color: Colors.white,
    ),
    'name': 'Drinks',
    'color': Colors.red[700],
    'totalAmount': '530',
    'date': 'Today',
  }
];
