import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fetansuki_app/core/error/exceptions.dart';
import 'package:fetansuki_app/features/credit/data/datasources/credit_data_source.dart';
import 'package:fetansuki_app/features/credit/data/models/credit_item_model.dart';
import 'package:fetansuki_app/features/credit/domain/entities/credit_data.dart';
import 'package:fetansuki_app/features/credit/domain/entities/credit_filter.dart';

class CreditRemoteDataSource implements CreditDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  CreditRemoteDataSource({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<CreditData> getCreditData() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw UnauthorizedException('User not authenticated');
      }

      // Fetch credits for the current user
      final snapshot = await firestore
          .collection('credits')
          .where('user_id', isEqualTo: user.uid)
          .get();

      final allCredits = snapshot.docs
          .map((doc) => CreditItemModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Sort in-memory by created_at (we'd need to add created_at to the model if not there, but for now let's just use the list as is or assume doc order)
      // Actually, if we want them sorted, we should have a field.
      // For now, let's just remove the orderBy to get it running.

      // Separate into paid and recently added (pending)
      final paidCredit = allCredits.where((c) => c.status == 'paid').toList();
      final recentlyAdded = allCredits.where((c) => c.status != 'paid').toList();

      // Default filters
      final filters = [
        const CreditFilter(id: '1', label: 'All'),
        const CreditFilter(id: '2', label: 'Pending'),
        const CreditFilter(id: '3', label: 'Paid'),
      ];

      return CreditData(
        filters: filters,
        recentlyAdded: recentlyAdded,
        paidCredit: paidCredit,
      );
    } on FirebaseException catch (e, s) {
      debugPrint('CREDIT FIREBASE ERROR: ${e.message}');
      debugPrint('STACK TRACE: $s');
      throw ServerException(e.message ?? 'Firestore error');
    } catch (e, s) {
      if (e is UnauthorizedException) rethrow;
      debugPrint('CREDIT DATA SOURCE ERROR: $e');
      debugPrint('STACK TRACE: $s');
      throw ServerException('Failed to fetch credit data: ${e.toString()}');
    }
  }

  @override
  Future<void> updateCreditStatus(String id, String status) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw UnauthorizedException('User not authenticated');
      }

      await firestore.collection('credits').doc(id).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e, s) {
      debugPrint('UPDATE CREDIT FIREBASE ERROR: ${e.message}');
      debugPrint('STACK TRACE: $s');
      throw ServerException(e.message ?? 'Firestore error');
    } catch (e, s) {
      if (e is UnauthorizedException) rethrow;
      debugPrint('UPDATE CREDIT DATA SOURCE ERROR: $e');
      debugPrint('STACK TRACE: $s');
      throw ServerException('Failed to update credit status: ${e.toString()}');
    }
  }
}
