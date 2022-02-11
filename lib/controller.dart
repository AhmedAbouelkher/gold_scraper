import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:gold_scraper/push_notifications_service.dart';

import 'models.dart';

class MainController {
  final Completer<String> _tokenCompleter;
  final FirebaseFirestore _firestore;

  MainController()
      : _tokenCompleter = Completer(),
        _firestore = FirebaseFirestore.instance {
    _init();
  }

  Future<void> _init() async {
    final token = await PushNotificationService.getToken();
    if (token == null) return;
    _tokenCompleter.complete(token);
    await _registerNewUser(token);
  }

  Future<void> _registerNewUser(String token) async {
    final doc = _firestore.collection("@users").doc(token.substring(0, 16));
    await doc.set({
      "id": doc.id,
      "token": token,
    });
  }

  CollectionReference<PriceUpdate> get pricesCollection {
    return _firestore.collection("@prices").withConverter(
          fromFirestore: (snapshot, options) {
            return PriceUpdate.fromMap(snapshot.data()!);
          },
          toFirestore: (_, __) => const {},
        );
  }

  Stream<QuerySnapshot<PriceUpdate>> watchLatestPrice() {
    return pricesCollection.orderBy('updated_at', descending: true).limit(1).snapshots();
  }
}
