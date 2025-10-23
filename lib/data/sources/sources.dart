import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'supabase_datasource.dart';

final supabaseDbProvider = Provider<SupabaseDataSource>(
  (ref) => SupabaseDataSource(),
);
