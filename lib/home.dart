import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:gold_scraper/push_notifications_service.dart';

import 'controller.dart';
import 'models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stream<QuerySnapshot<PriceUpdate>>? _latestPrice;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await PushNotificationService.initialize();
      final controller = context.read<MainController>();
      _latestPrice = controller.watchLatestPrice();
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gold Scraper'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: StreamBuilder<QuerySnapshot<PriceUpdate>>(
            stream: _latestPrice,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator.adaptive();
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) return const Text("No Data found");
              final priceUpdate = docs.first.data();
              return Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Text.rich(
                        TextSpan(
                          text: priceUpdate.price.formatted(),
                          children: [
                            const TextSpan(text: '\n'),
                            TextSpan(
                              text: 'EGP',
                              style: theme.textTheme.headline4,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headline1?.copyWith(
                          color: Colors.yellow.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Last Updated: ${priceUpdate.updatedAt.formatted()}",
                      style: theme.textTheme.headline6,
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

extension on num {
  String formatted() {
    return NumberFormat.currency(name: '').format(this);
  }
}

extension on DateTime {
  String formatted() {
    return DateTimeFormat.format(this, format: r'j/m/Y g:i a').toUpperCase();
  }
}
