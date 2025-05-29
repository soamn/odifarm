import 'package:odifarm/models/payment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentService {
  final supabase = Supabase.instance.client;

  Future<void> createPayment({required Payment payment}) async {
    await supabase.from('Payment').insert(payment.toJson());
  }
}
