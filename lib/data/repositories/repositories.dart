import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simple_paint/data/repositories/auth_repository_impl.dart';
import 'package:simple_paint/data/repositories/draws_repository_impl.dart';
import 'package:simple_paint/domain/repositories/auth_repository.dart';
import 'package:simple_paint/domain/repositories/draws_repository.dart';

import '../sources/sources.dart';

final authRepoProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(dataSource: ref.read(supabaseDbProvider)),
);

final drawsRepoProvider = Provider<DrawsRepository>(
  (ref) => DrawsRepositoryImpl(dataSource: ref.read(supabaseDbProvider)),
);
