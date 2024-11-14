import 'dart:convert';

import 'package:dart_conversion/dart_conversion.old.dart';
import 'package:dart_conversion/my_logger.dart';

/// A list of transformers for List instances
const listTransformer = <Type, ListTransformer>{
  List<int>: ListTransformer<int>(IntTransformer()),
  List<String>: ListTransformer<String>(StringTransformer()),
  List<double>: ListTransformer<double>(DoubleTransformer()),
  List<bool>: ListTransformer<bool>(BoolTransformer()),
  List<Map<dynamic, dynamic>>:
      ListTransformer(MapTransformer<dynamic, dynamic>()),
  List<Map<dynamic, String>>:
      ListTransformer(MapTransformer<dynamic, String>()),
  List<Map<dynamic, int>>: ListTransformer(MapTransformer<dynamic, int>()),
  List<Map<dynamic, double>>:
      ListTransformer(MapTransformer<dynamic, double>()),
  List<Map<dynamic, bool>>: ListTransformer(MapTransformer<dynamic, bool>()),

  List<Map<String, dynamic>>:
      ListTransformer(MapTransformer<String, dynamic>()),
  List<Map<String, String>>: ListTransformer(MapTransformer<String, String>()),
  List<Map<String, int>>: ListTransformer(MapTransformer<String, int>()),
  List<Map<String, double>>: ListTransformer(MapTransformer<String, double>()),
  List<Map<String, bool>>: ListTransformer(MapTransformer<String, bool>()),

  List<Map<int, dynamic>>: ListTransformer(MapTransformer<int, dynamic>()),
  List<Map<int, String>>: ListTransformer(MapTransformer<int, String>()),
  List<Map<int, int>>: ListTransformer(MapTransformer<int, int>()),
  List<Map<int, double>>: ListTransformer(MapTransformer<int, double>()),
  List<Map<int, bool>>: ListTransformer(MapTransformer<int, bool>()),

  List<Map<double, dynamic>>:
      ListTransformer(MapTransformer<double, dynamic>()),
  List<Map<double, String>>: ListTransformer(MapTransformer<double, String>()),
  List<Map<double, int>>: ListTransformer(MapTransformer<double, int>()),
  List<Map<double, double>>: ListTransformer(MapTransformer<double, double>()),
  List<Map<double, bool>>: ListTransformer(MapTransformer<double, bool>()),

  List<Map<bool, dynamic>>: ListTransformer(MapTransformer<bool, dynamic>()),
  List<Map<bool, String>>: ListTransformer(MapTransformer<bool, String>()),
  List<Map<bool, int>>: ListTransformer(MapTransformer<bool, int>()),
  List<Map<bool, double>>: ListTransformer(MapTransformer<bool, double>()),
  List<Map<bool, bool>>: ListTransformer(MapTransformer<bool, bool>()),

// List transformers
  List<Map<String, List<dynamic>>>:
      ListTransformer(MapTransformer<String, List<dynamic>>()),
  List<Map<String, List<String>>>:
      ListTransformer(MapTransformer<String, List<String>>()),
  List<Map<String, List<int>>>:
      ListTransformer(MapTransformer<String, List<int>>()),
  List<Map<String, List<double>>>:
      ListTransformer(MapTransformer<String, List<double>>()),
  List<Map<String, List<bool>>>:
      ListTransformer(MapTransformer<String, List<bool>>()),

  List<Map<int, List<dynamic>>>:
      ListTransformer(MapTransformer<int, List<dynamic>>()),
  List<Map<int, List<String>>>:
      ListTransformer(MapTransformer<int, List<String>>()),
  List<Map<int, List<int>>>: ListTransformer(MapTransformer<int, List<int>>()),
  List<Map<int, List<double>>>:
      ListTransformer(MapTransformer<int, List<double>>()),
  List<Map<int, List<bool>>>:
      ListTransformer(MapTransformer<int, List<bool>>()),

  List<Map<double, List<dynamic>>>:
      ListTransformer(MapTransformer<double, List<dynamic>>()),
  List<Map<double, List<String>>>:
      ListTransformer(MapTransformer<double, List<String>>()),
  List<Map<double, List<int>>>:
      ListTransformer(MapTransformer<double, List<int>>()),
  List<Map<double, List<double>>>:
      ListTransformer(MapTransformer<double, List<double>>()),
  List<Map<double, List<bool>>>:
      ListTransformer(MapTransformer<double, List<bool>>()),

  List<Map<bool, List<dynamic>>>:
      ListTransformer(MapTransformer<bool, List<dynamic>>()),
  List<Map<bool, List<String>>>:
      ListTransformer(MapTransformer<bool, List<String>>()),
  List<Map<bool, List<int>>>:
      ListTransformer(MapTransformer<bool, List<int>>()),
  List<Map<bool, List<double>>>:
      ListTransformer(MapTransformer<bool, List<double>>()),
  List<Map<bool, List<bool>>>:
      ListTransformer(MapTransformer<bool, List<bool>>()),

  List<Map<dynamic, List<dynamic>>>:
      ListTransformer(MapTransformer<dynamic, List<dynamic>>()),
  List<Map<dynamic, List<String>>>:
      ListTransformer(MapTransformer<dynamic, List<String>>()),
  List<Map<dynamic, List<int>>>:
      ListTransformer(MapTransformer<dynamic, List<int>>()),
  List<Map<dynamic, List<double>>>:
      ListTransformer(MapTransformer<dynamic, List<double>>()),
  List<Map<dynamic, List<bool>>>:
      ListTransformer(MapTransformer<dynamic, List<bool>>()),

// Nested Map transformers
  List<Map<String, Map<String, dynamic>>>:
      ListTransformer(MapTransformer<String, Map<String, dynamic>>()),
  List<Map<String, Map<String, String>>>:
      ListTransformer(MapTransformer<String, Map<String, String>>()),
  List<Map<String, Map<String, int>>>:
      ListTransformer(MapTransformer<String, Map<String, int>>()),
  List<Map<String, Map<String, double>>>:
      ListTransformer(MapTransformer<String, Map<String, double>>()),
  List<Map<String, Map<String, bool>>>:
      ListTransformer(MapTransformer<String, Map<String, bool>>()),

  List<Map<int, Map<int, dynamic>>>:
      ListTransformer(MapTransformer<int, Map<int, dynamic>>()),
  List<Map<int, Map<int, String>>>:
      ListTransformer(MapTransformer<int, Map<int, String>>()),
  List<Map<int, Map<int, int>>>:
      ListTransformer(MapTransformer<int, Map<int, int>>()),
  List<Map<int, Map<int, double>>>:
      ListTransformer(MapTransformer<int, Map<int, double>>()),
  List<Map<int, Map<int, bool>>>:
      ListTransformer(MapTransformer<int, Map<int, bool>>()),

  List<Map<double, Map<double, dynamic>>>:
      ListTransformer(MapTransformer<double, Map<double, dynamic>>()),
  List<Map<double, Map<double, String>>>:
      ListTransformer(MapTransformer<double, Map<double, String>>()),
  List<Map<double, Map<double, int>>>:
      ListTransformer(MapTransformer<double, Map<double, int>>()),
  List<Map<double, Map<double, double>>>:
      ListTransformer(MapTransformer<double, Map<double, double>>()),
  List<Map<double, Map<double, bool>>>:
      ListTransformer(MapTransformer<double, Map<double, bool>>()),

  List<Map<bool, Map<bool, dynamic>>>:
      ListTransformer(MapTransformer<bool, Map<bool, dynamic>>()),
  List<Map<bool, Map<bool, String>>>:
      ListTransformer(MapTransformer<bool, Map<bool, String>>()),
  List<Map<bool, Map<bool, int>>>:
      ListTransformer(MapTransformer<bool, Map<bool, int>>()),
  List<Map<bool, Map<bool, double>>>:
      ListTransformer(MapTransformer<bool, Map<bool, double>>()),
  List<Map<bool, Map<bool, bool>>>:
      ListTransformer(MapTransformer<bool, Map<bool, bool>>()),

  List<Map<dynamic, Map<dynamic, dynamic>>>:
      ListTransformer(MapTransformer<dynamic, Map<dynamic, dynamic>>()),
  List<Map<dynamic, Map<dynamic, String>>>:
      ListTransformer(MapTransformer<dynamic, Map<dynamic, String>>()),
  List<Map<dynamic, Map<dynamic, int>>>:
      ListTransformer(MapTransformer<dynamic, Map<dynamic, int>>()),
  List<Map<dynamic, Map<dynamic, double>>>:
      ListTransformer(MapTransformer<dynamic, Map<dynamic, double>>()),
  List<Map<dynamic, Map<dynamic, bool>>>:
      ListTransformer(MapTransformer<dynamic, Map<dynamic, bool>>()),

  List<Map<String, Map<int, dynamic>>>:
      ListTransformer(MapTransformer<String, Map<int, dynamic>>()),
  List<Map<String, Map<int, String>>>:
      ListTransformer(MapTransformer<String, Map<int, String>>()),
  List<Map<String, Map<int, int>>>:
      ListTransformer(MapTransformer<String, Map<int, int>>()),
  List<Map<String, Map<int, double>>>:
      ListTransformer(MapTransformer<String, Map<int, double>>()),
  List<Map<String, Map<int, bool>>>:
      ListTransformer(MapTransformer<String, Map<int, bool>>()),

  List<Map<int, Map<String, dynamic>>>:
      ListTransformer(MapTransformer<int, Map<String, dynamic>>()),
  List<Map<int, Map<String, String>>>:
      ListTransformer(MapTransformer<int, Map<String, String>>()),
  List<Map<int, Map<String, int>>>:
      ListTransformer(MapTransformer<int, Map<String, int>>()),
  List<Map<int, Map<String, double>>>:
      ListTransformer(MapTransformer<int, Map<String, double>>()),
  List<Map<int, Map<String, bool>>>:
      ListTransformer(MapTransformer<int, Map<String, bool>>()),

  List<Map<double, Map<int, dynamic>>>:
      ListTransformer(MapTransformer<double, Map<int, dynamic>>()),
  List<Map<double, Map<int, String>>>:
      ListTransformer(MapTransformer<double, Map<int, String>>()),
  List<Map<double, Map<int, int>>>:
      ListTransformer(MapTransformer<double, Map<int, int>>()),
  List<Map<double, Map<int, double>>>:
      ListTransformer(MapTransformer<double, Map<int, double>>()),
  List<Map<double, Map<int, bool>>>:
      ListTransformer(MapTransformer<double, Map<int, bool>>()),

  List<Map<bool, Map<int, dynamic>>>:
      ListTransformer(MapTransformer<bool, Map<int, dynamic>>()),
  List<Map<bool, Map<int, String>>>:
      ListTransformer(MapTransformer<bool, Map<int, String>>()),
  List<Map<bool, Map<int, int>>>:
      ListTransformer(MapTransformer<bool, Map<int, int>>()),
  List<Map<bool, Map<int, double>>>:
      ListTransformer(MapTransformer<bool, Map<int, double>>()),
  List<Map<bool, Map<int, bool>>>:
      ListTransformer(MapTransformer<bool, Map<int, bool>>()),

  List<Map<dynamic, Map<String, dynamic>>>:
      ListTransformer(MapTransformer<dynamic, Map<String, dynamic>>()),
  List<Map<dynamic, Map<String, String>>>:
      ListTransformer(MapTransformer<dynamic, Map<String, String>>()),
  List<Map<dynamic, Map<String, int>>>:
      ListTransformer(MapTransformer<dynamic, Map<String, int>>()),
  List<Map<dynamic, Map<String, double>>>:
      ListTransformer(MapTransformer<dynamic, Map<String, double>>()),
  List<Map<dynamic, Map<String, bool>>>:
      ListTransformer(MapTransformer<dynamic, Map<String, bool>>()),

  List<Map<String, Map<double, dynamic>>>:
      ListTransformer(MapTransformer<String, Map<double, dynamic>>()),
  List<Map<String, Map<double, String>>>:
      ListTransformer(MapTransformer<String, Map<double, String>>()),
  List<Map<String, Map<double, int>>>:
      ListTransformer(MapTransformer<String, Map<double, int>>()),
  List<Map<String, Map<double, double>>>:
      ListTransformer(MapTransformer<String, Map<double, double>>()),
  List<Map<String, Map<double, bool>>>:
      ListTransformer(MapTransformer<String, Map<double, bool>>()),

  List<Map<int, Map<double, dynamic>>>:
      ListTransformer(MapTransformer<int, Map<double, dynamic>>()),
  List<Map<int, Map<double, String>>>:
      ListTransformer(MapTransformer<int, Map<double, String>>()),
  List<Map<int, Map<double, int>>>:
      ListTransformer(MapTransformer<int, Map<double, int>>()),
  List<Map<int, Map<double, double>>>:
      ListTransformer(MapTransformer<int, Map<double, double>>()),
  List<Map<int, Map<double, bool>>>:
      ListTransformer(MapTransformer<int, Map<double, bool>>()),

  List<Map<double, Map<String, dynamic>>>:
      ListTransformer(MapTransformer<double, Map<String, dynamic>>()),
  List<Map<double, Map<String, String>>>:
      ListTransformer(MapTransformer<double, Map<String, String>>()),
  List<Map<double, Map<String, int>>>:
      ListTransformer(MapTransformer<double, Map<String, int>>()),
  List<Map<double, Map<String, double>>>:
      ListTransformer(MapTransformer<double, Map<String, double>>()),
  List<Map<double, Map<String, bool>>>:
      ListTransformer(MapTransformer<double, Map<String, bool>>()),

  List<Map<bool, Map<double, dynamic>>>:
      ListTransformer(MapTransformer<bool, Map<double, dynamic>>()),
  List<Map<bool, Map<double, String>>>:
      ListTransformer(MapTransformer<bool, Map<double, String>>()),
  List<Map<bool, Map<double, int>>>:
      ListTransformer(MapTransformer<bool, Map<double, int>>()),
  List<Map<bool, Map<double, double>>>:
      ListTransformer(MapTransformer<bool, Map<double, double>>()),
  List<Map<bool, Map<double, bool>>>:
      ListTransformer(MapTransformer<bool, Map<double, bool>>()),

  List<Map<dynamic, Map<int, dynamic>>>:
      ListTransformer(MapTransformer<dynamic, Map<int, dynamic>>()),
  List<Map<dynamic, Map<int, String>>>:
      ListTransformer(MapTransformer<dynamic, Map<int, String>>()),
  List<Map<dynamic, Map<int, int>>>:
      ListTransformer(MapTransformer<dynamic, Map<int, int>>()),
  List<Map<dynamic, Map<int, double>>>:
      ListTransformer(MapTransformer<dynamic, Map<int, double>>()),
  List<Map<dynamic, Map<int, bool>>>:
      ListTransformer(MapTransformer<dynamic, Map<int, bool>>()),

  List<Map<dynamic, Map<double, dynamic>>>:
      ListTransformer(MapTransformer<dynamic, Map<double, dynamic>>()),
  List<Map<dynamic, Map<double, String>>>:
      ListTransformer(MapTransformer<dynamic, Map<double, String>>()),
  List<Map<dynamic, Map<double, int>>>:
      ListTransformer(MapTransformer<dynamic, Map<double, int>>()),
  List<Map<dynamic, Map<double, double>>>:
      ListTransformer(MapTransformer<dynamic, Map<double, double>>()),
  List<Map<dynamic, Map<double, bool>>>:
      ListTransformer(MapTransformer<dynamic, Map<double, bool>>()),

  List<Map<String, Map<bool, dynamic>>>:
      ListTransformer(MapTransformer<String, Map<bool, dynamic>>()),
  List<Map<String, Map<bool, String>>>:
      ListTransformer(MapTransformer<String, Map<bool, String>>()),
  List<Map<String, Map<bool, int>>>:
      ListTransformer(MapTransformer<String, Map<bool, int>>()),
  List<Map<String, Map<bool, double>>>:
      ListTransformer(MapTransformer<String, Map<bool, double>>()),
  List<Map<String, Map<bool, bool>>>:
      ListTransformer(MapTransformer<String, Map<bool, bool>>()),

  List<Map<int, Map<bool, dynamic>>>:
      ListTransformer(MapTransformer<int, Map<bool, dynamic>>()),
  List<Map<int, Map<bool, String>>>:
      ListTransformer(MapTransformer<int, Map<bool, String>>()),
  List<Map<int, Map<bool, int>>>:
      ListTransformer(MapTransformer<int, Map<bool, int>>()),
  List<Map<int, Map<bool, double>>>:
      ListTransformer(MapTransformer<int, Map<bool, double>>()),
  List<Map<int, Map<bool, bool>>>:
      ListTransformer(MapTransformer<int, Map<bool, bool>>()),

  List<Map<double, Map<bool, dynamic>>>:
      ListTransformer(MapTransformer<double, Map<bool, dynamic>>()),
  List<Map<double, Map<bool, String>>>:
      ListTransformer(MapTransformer<double, Map<bool, String>>()),
  List<Map<double, Map<bool, int>>>:
      ListTransformer(MapTransformer<double, Map<bool, int>>()),
  List<Map<double, Map<bool, double>>>:
      ListTransformer(MapTransformer<double, Map<bool, double>>()),
  List<Map<double, Map<bool, bool>>>:
      ListTransformer(MapTransformer<double, Map<bool, bool>>()),

  List<Map<bool, Map<String, dynamic>>>:
      ListTransformer(MapTransformer<bool, Map<String, dynamic>>()),
  List<Map<bool, Map<String, String>>>:
      ListTransformer(MapTransformer<bool, Map<String, String>>()),
  List<Map<bool, Map<String, int>>>:
      ListTransformer(MapTransformer<bool, Map<String, int>>()),
  List<Map<bool, Map<String, double>>>:
      ListTransformer(MapTransformer<bool, Map<String, double>>()),
  List<Map<bool, Map<String, bool>>>:
      ListTransformer(MapTransformer<bool, Map<String, bool>>()),

  List<Map<dynamic, Map<bool, dynamic>>>:
      ListTransformer(MapTransformer<dynamic, Map<bool, dynamic>>()),
  List<Map<dynamic, Map<bool, String>>>:
      ListTransformer(MapTransformer<dynamic, Map<bool, String>>()),
  List<Map<dynamic, Map<bool, int>>>:
      ListTransformer(MapTransformer<dynamic, Map<bool, int>>()),
  List<Map<dynamic, Map<bool, double>>>:
      ListTransformer(MapTransformer<dynamic, Map<bool, double>>()),
  List<Map<dynamic, Map<bool, bool>>>:
      ListTransformer(MapTransformer<dynamic, Map<bool, bool>>()),
};

/// A list of constant map transformers which aims to provide transformation ability from different Key and Value types to a specific and different one
const mapTransformers = <Type, MapTransformer>{
  Map<dynamic, dynamic>: MapTransformer<dynamic, dynamic>(),
  Map<dynamic, String>: MapTransformer<dynamic, String>(),
  Map<dynamic, int>: MapTransformer<dynamic, int>(),
  Map<dynamic, double>: MapTransformer<dynamic, double>(),
  Map<dynamic, bool>: MapTransformer<dynamic, bool>(),

  Map<String, dynamic>: MapTransformer<String, dynamic>(),
  Map<String, String>: MapTransformer<String, String>(),
  Map<String, int>: MapTransformer<String, int>(),
  Map<String, double>: MapTransformer<String, double>(),
  Map<String, bool>: MapTransformer<String, bool>(),

  Map<int, dynamic>: MapTransformer<int, dynamic>(),
  Map<int, String>: MapTransformer<int, String>(),
  Map<int, int>: MapTransformer<int, int>(),
  Map<int, double>: MapTransformer<int, double>(),
  Map<int, bool>: MapTransformer<int, bool>(),

  Map<double, dynamic>: MapTransformer<double, dynamic>(),
  Map<double, String>: MapTransformer<double, String>(),
  Map<double, int>: MapTransformer<double, int>(),
  Map<double, double>: MapTransformer<double, double>(),
  Map<double, bool>: MapTransformer<double, bool>(),

  Map<bool, dynamic>: MapTransformer<bool, dynamic>(),
  Map<bool, String>: MapTransformer<bool, String>(),
  Map<bool, int>: MapTransformer<bool, int>(),
  Map<bool, double>: MapTransformer<bool, double>(),
  Map<bool, bool>: MapTransformer<bool, bool>(),

// List transformers
  Map<String, List<dynamic>>: MapTransformer<String, List<dynamic>>(),
  Map<String, List<String>>: MapTransformer<String, List<String>>(),
  Map<String, List<int>>: MapTransformer<String, List<int>>(),
  Map<String, List<double>>: MapTransformer<String, List<double>>(),
  Map<String, List<bool>>: MapTransformer<String, List<bool>>(),

  Map<int, List<dynamic>>: MapTransformer<int, List<dynamic>>(),
  Map<int, List<String>>: MapTransformer<int, List<String>>(),
  Map<int, List<int>>: MapTransformer<int, List<int>>(),
  Map<int, List<double>>: MapTransformer<int, List<double>>(),
  Map<int, List<bool>>: MapTransformer<int, List<bool>>(),

  Map<double, List<dynamic>>: MapTransformer<double, List<dynamic>>(),
  Map<double, List<String>>: MapTransformer<double, List<String>>(),
  Map<double, List<int>>: MapTransformer<double, List<int>>(),
  Map<double, List<double>>: MapTransformer<double, List<double>>(),
  Map<double, List<bool>>: MapTransformer<double, List<bool>>(),

  Map<bool, List<dynamic>>: MapTransformer<bool, List<dynamic>>(),
  Map<bool, List<String>>: MapTransformer<bool, List<String>>(),
  Map<bool, List<int>>: MapTransformer<bool, List<int>>(),
  Map<bool, List<double>>: MapTransformer<bool, List<double>>(),
  Map<bool, List<bool>>: MapTransformer<bool, List<bool>>(),

  Map<dynamic, List<dynamic>>: MapTransformer<dynamic, List<dynamic>>(),
  Map<dynamic, List<String>>: MapTransformer<dynamic, List<String>>(),
  Map<dynamic, List<int>>: MapTransformer<dynamic, List<int>>(),
  Map<dynamic, List<double>>: MapTransformer<dynamic, List<double>>(),
  Map<dynamic, List<bool>>: MapTransformer<dynamic, List<bool>>(),

// Nested Map transformers
  Map<String, Map<String, dynamic>>:
      MapTransformer<String, Map<String, dynamic>>(),
  Map<String, Map<String, String>>:
      MapTransformer<String, Map<String, String>>(),
  Map<String, Map<String, int>>: MapTransformer<String, Map<String, int>>(),
  Map<String, Map<String, double>>:
      MapTransformer<String, Map<String, double>>(),
  Map<String, Map<String, bool>>: MapTransformer<String, Map<String, bool>>(),

  Map<int, Map<int, dynamic>>: MapTransformer<int, Map<int, dynamic>>(),
  Map<int, Map<int, String>>: MapTransformer<int, Map<int, String>>(),
  Map<int, Map<int, int>>: MapTransformer<int, Map<int, int>>(),
  Map<int, Map<int, double>>: MapTransformer<int, Map<int, double>>(),
  Map<int, Map<int, bool>>: MapTransformer<int, Map<int, bool>>(),

  Map<double, Map<double, dynamic>>:
      MapTransformer<double, Map<double, dynamic>>(),
  Map<double, Map<double, String>>:
      MapTransformer<double, Map<double, String>>(),
  Map<double, Map<double, int>>: MapTransformer<double, Map<double, int>>(),
  Map<double, Map<double, double>>:
      MapTransformer<double, Map<double, double>>(),
  Map<double, Map<double, bool>>: MapTransformer<double, Map<double, bool>>(),

  Map<bool, Map<bool, dynamic>>: MapTransformer<bool, Map<bool, dynamic>>(),
  Map<bool, Map<bool, String>>: MapTransformer<bool, Map<bool, String>>(),
  Map<bool, Map<bool, int>>: MapTransformer<bool, Map<bool, int>>(),
  Map<bool, Map<bool, double>>: MapTransformer<bool, Map<bool, double>>(),
  Map<bool, Map<bool, bool>>: MapTransformer<bool, Map<bool, bool>>(),

  Map<dynamic, Map<dynamic, dynamic>>:
      MapTransformer<dynamic, Map<dynamic, dynamic>>(),
  Map<dynamic, Map<dynamic, String>>:
      MapTransformer<dynamic, Map<dynamic, String>>(),
  Map<dynamic, Map<dynamic, int>>: MapTransformer<dynamic, Map<dynamic, int>>(),
  Map<dynamic, Map<dynamic, double>>:
      MapTransformer<dynamic, Map<dynamic, double>>(),
  Map<dynamic, Map<dynamic, bool>>:
      MapTransformer<dynamic, Map<dynamic, bool>>(),

  Map<String, Map<int, dynamic>>: MapTransformer<String, Map<int, dynamic>>(),
  Map<String, Map<int, String>>: MapTransformer<String, Map<int, String>>(),
  Map<String, Map<int, int>>: MapTransformer<String, Map<int, int>>(),
  Map<String, Map<int, double>>: MapTransformer<String, Map<int, double>>(),
  Map<String, Map<int, bool>>: MapTransformer<String, Map<int, bool>>(),

  Map<int, Map<String, dynamic>>: MapTransformer<int, Map<String, dynamic>>(),
  Map<int, Map<String, String>>: MapTransformer<int, Map<String, String>>(),
  Map<int, Map<String, int>>: MapTransformer<int, Map<String, int>>(),
  Map<int, Map<String, double>>: MapTransformer<int, Map<String, double>>(),
  Map<int, Map<String, bool>>: MapTransformer<int, Map<String, bool>>(),

  Map<double, Map<int, dynamic>>: MapTransformer<double, Map<int, dynamic>>(),
  Map<double, Map<int, String>>: MapTransformer<double, Map<int, String>>(),
  Map<double, Map<int, int>>: MapTransformer<double, Map<int, int>>(),
  Map<double, Map<int, double>>: MapTransformer<double, Map<int, double>>(),
  Map<double, Map<int, bool>>: MapTransformer<double, Map<int, bool>>(),

  Map<bool, Map<int, dynamic>>: MapTransformer<bool, Map<int, dynamic>>(),
  Map<bool, Map<int, String>>: MapTransformer<bool, Map<int, String>>(),
  Map<bool, Map<int, int>>: MapTransformer<bool, Map<int, int>>(),
  Map<bool, Map<int, double>>: MapTransformer<bool, Map<int, double>>(),
  Map<bool, Map<int, bool>>: MapTransformer<bool, Map<int, bool>>(),

  Map<dynamic, Map<String, dynamic>>:
      MapTransformer<dynamic, Map<String, dynamic>>(),
  Map<dynamic, Map<String, String>>:
      MapTransformer<dynamic, Map<String, String>>(),
  Map<dynamic, Map<String, int>>: MapTransformer<dynamic, Map<String, int>>(),
  Map<dynamic, Map<String, double>>:
      MapTransformer<dynamic, Map<String, double>>(),
  Map<dynamic, Map<String, bool>>: MapTransformer<dynamic, Map<String, bool>>(),

  Map<String, Map<double, dynamic>>:
      MapTransformer<String, Map<double, dynamic>>(),
  Map<String, Map<double, String>>:
      MapTransformer<String, Map<double, String>>(),
  Map<String, Map<double, int>>: MapTransformer<String, Map<double, int>>(),
  Map<String, Map<double, double>>:
      MapTransformer<String, Map<double, double>>(),
  Map<String, Map<double, bool>>: MapTransformer<String, Map<double, bool>>(),

  Map<int, Map<double, dynamic>>: MapTransformer<int, Map<double, dynamic>>(),
  Map<int, Map<double, String>>: MapTransformer<int, Map<double, String>>(),
  Map<int, Map<double, int>>: MapTransformer<int, Map<double, int>>(),
  Map<int, Map<double, double>>: MapTransformer<int, Map<double, double>>(),
  Map<int, Map<double, bool>>: MapTransformer<int, Map<double, bool>>(),

  Map<double, Map<String, dynamic>>:
      MapTransformer<double, Map<String, dynamic>>(),
  Map<double, Map<String, String>>:
      MapTransformer<double, Map<String, String>>(),
  Map<double, Map<String, int>>: MapTransformer<double, Map<String, int>>(),
  Map<double, Map<String, double>>:
      MapTransformer<double, Map<String, double>>(),
  Map<double, Map<String, bool>>: MapTransformer<double, Map<String, bool>>(),

  Map<bool, Map<double, dynamic>>: MapTransformer<bool, Map<double, dynamic>>(),
  Map<bool, Map<double, String>>: MapTransformer<bool, Map<double, String>>(),
  Map<bool, Map<double, int>>: MapTransformer<bool, Map<double, int>>(),
  Map<bool, Map<double, double>>: MapTransformer<bool, Map<double, double>>(),
  Map<bool, Map<double, bool>>: MapTransformer<bool, Map<double, bool>>(),

  Map<dynamic, Map<int, dynamic>>: MapTransformer<dynamic, Map<int, dynamic>>(),
  Map<dynamic, Map<int, String>>: MapTransformer<dynamic, Map<int, String>>(),
  Map<dynamic, Map<int, int>>: MapTransformer<dynamic, Map<int, int>>(),
  Map<dynamic, Map<int, double>>: MapTransformer<dynamic, Map<int, double>>(),
  Map<dynamic, Map<int, bool>>: MapTransformer<dynamic, Map<int, bool>>(),

  Map<dynamic, Map<double, dynamic>>:
      MapTransformer<dynamic, Map<double, dynamic>>(),
  Map<dynamic, Map<double, String>>:
      MapTransformer<dynamic, Map<double, String>>(),
  Map<dynamic, Map<double, int>>: MapTransformer<dynamic, Map<double, int>>(),
  Map<dynamic, Map<double, double>>:
      MapTransformer<dynamic, Map<double, double>>(),
  Map<dynamic, Map<double, bool>>: MapTransformer<dynamic, Map<double, bool>>(),

  Map<String, Map<bool, dynamic>>: MapTransformer<String, Map<bool, dynamic>>(),
  Map<String, Map<bool, String>>: MapTransformer<String, Map<bool, String>>(),
  Map<String, Map<bool, int>>: MapTransformer<String, Map<bool, int>>(),
  Map<String, Map<bool, double>>: MapTransformer<String, Map<bool, double>>(),
  Map<String, Map<bool, bool>>: MapTransformer<String, Map<bool, bool>>(),

  Map<int, Map<bool, dynamic>>: MapTransformer<int, Map<bool, dynamic>>(),
  Map<int, Map<bool, String>>: MapTransformer<int, Map<bool, String>>(),
  Map<int, Map<bool, int>>: MapTransformer<int, Map<bool, int>>(),
  Map<int, Map<bool, double>>: MapTransformer<int, Map<bool, double>>(),
  Map<int, Map<bool, bool>>: MapTransformer<int, Map<bool, bool>>(),

  Map<double, Map<bool, dynamic>>: MapTransformer<double, Map<bool, dynamic>>(),
  Map<double, Map<bool, String>>: MapTransformer<double, Map<bool, String>>(),
  Map<double, Map<bool, int>>: MapTransformer<double, Map<bool, int>>(),
  Map<double, Map<bool, double>>: MapTransformer<double, Map<bool, double>>(),
  Map<double, Map<bool, bool>>: MapTransformer<double, Map<bool, bool>>(),

  Map<bool, Map<String, dynamic>>: MapTransformer<bool, Map<String, dynamic>>(),
  Map<bool, Map<String, String>>: MapTransformer<bool, Map<String, String>>(),
  Map<bool, Map<String, int>>: MapTransformer<bool, Map<String, int>>(),
  Map<bool, Map<String, double>>: MapTransformer<bool, Map<String, double>>(),
  Map<bool, Map<String, bool>>: MapTransformer<bool, Map<String, bool>>(),

  Map<dynamic, Map<bool, dynamic>>:
      MapTransformer<dynamic, Map<bool, dynamic>>(),
  Map<dynamic, Map<bool, String>>: MapTransformer<dynamic, Map<bool, String>>(),
  Map<dynamic, Map<bool, int>>: MapTransformer<dynamic, Map<bool, int>>(),
  Map<dynamic, Map<bool, double>>: MapTransformer<dynamic, Map<bool, double>>(),
  Map<dynamic, Map<bool, bool>>: MapTransformer<dynamic, Map<bool, bool>>(),
};

final transformers = <Type, Transformer>{
  bool: BoolTransformer(),
  int: IntTransformer(),
  String: StringTransformer(),
  double: DoubleTransformer(),
  ...listTransformer,
  ...mapTransformers
};

class BoolTransformer extends Transformer<bool> {
  const BoolTransformer();
  @override
  bool transformValue(dynamic value) {
    try {
      if (value is bool) {
        return value;
      } else if (value is num) {
        if (value.toInt() > 1 || value.toInt() < 0) {
          throw TransformerException(
              "Value $value of type ${value.runtimeType} is not a valid boolean representation as it is not 1 or 0",
              value);
        }
        return value.toInt() == 1;
      } else if (value is String) {
        if (value[0] == "1" || value[0] == "0") {
          return int.parse(value[0]) == 1;
        }

        if (value.toLowerCase() == 'true') {
          return true;
        } else if (value.toLowerCase() == 'false') {
          return false;
        }
        throw TransformerException(
            "Value $value of type String is not a valid bool representation.",
            value);
      }
    } catch (e, s) {
      myLogger.e(e, stackTrace: s, header: "Transformer.transform");
      throw TransformerException(
          "Value $value of type ${value.runtimeType} cannot be transformed to an bool",
          value);
    }
    throw TransformerException(
        "Value $value of type ${value.runtimeType} cannot be transformed to an bool",
        value);
  }
}

class DoubleTransformer extends Transformer<double> {
  const DoubleTransformer();
  @override
  double transformValue(dynamic value) {
    if (value is double) {
      return value;
    } else if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.parse(value);
    }
    throw TransformerException(
        "Value $value of type ${value.runtimeType} cannot be transformed to an double",
        value);
  }
}

class IntTransformer extends Transformer<int> {
  const IntTransformer();
  @override
  int transformValue(dynamic value) {
    try {
      if (value is int) {
        return value;
      } else if (value is num) {
        return value.toInt();
      } else if (value is bool) {
        return value ? 1 : 0;
      } else if (value is String) {
        final isBool = value == "true" || value == "false";

        if (isBool) {
          return BoolTransformer().transform(value) ? 1 : 0;
        }
        return int.parse(value);
      }
    } catch (e, s) {
      myLogger.e(e, stackTrace: s, header: "Transformer.transform");
      throw TransformerException(
          "Value $value of type ${value.runtimeType} cannot be transformed to an double",
          value);
    }
    throw TransformerException(
        "Value $value of type ${value.runtimeType} cannot be transformed to an int",
        value);
  }
}

class ListTransformer<T> extends Transformer<List<T>> {
  final Transformer<T> transformer;

  const ListTransformer(this.transformer);

  @override
  List<T> transformValue(dynamic value) {
    try {
      if (value is List) {
        return value.map((e) => transformer.transform(e)).toList();
      }
    } catch (e, s) {
      if (e is TransformerException) {
        rethrow;
      }
      myLogger.e(e, stackTrace: s, header: "Transformer.transform");
      throw TransformerException(
          "Value $value of type ${value.runtimeType} cannot be transformed to an double",
          value);
    }

    throw TransformerException(
        "Value $value of type ${value.runtimeType} cannot be transformed to an double",
        value);
  }
}

class MapTransformer<KeyType, ValueType>
    extends Transformer<Map<KeyType, ValueType>> {
  const MapTransformer();
  @override
  Map<KeyType, ValueType> transformValue(dynamic value) {
    try {
      if (value is String) {
        myLogger.d(
            "Value $value of type ${value.runtimeType} will be interpreted as an json map",
            header: "MapTransformer<$KeyType, $ValueType>");

        final map = jsonDecode(value);
        if (map is Map) {
          return transformValue(map);
        } else {
          throw TransformerException(
              "Value $value of type ${value.runtimeType} cannot be transformed to an Map<$KeyType, $ValueType>",
              value);
        }
      }
      if (value is Map) {
        if (value.runtimeType == Map<KeyType, ValueType>) {
          return value.cast<KeyType, ValueType>();
        }
        if (KeyType != dynamic) {
          myLogger.w(KeyType.toString());
          final keyTransformer = transformers[KeyType];
          if (keyTransformer == null) {
            throw TransformerException(
                "No transformer found for key type $KeyType", value);
          }
          if (ValueType != dynamic) {
            myLogger.w(ValueType.toString());

            final valueTransformer = transformers[ValueType];
            if (valueTransformer == null) {
              throw TransformerException(
                  "No transformer found for value type $ValueType", value);
            }

            return value.map((key, value) => MapEntry<KeyType, ValueType>(
                keyTransformer.transform(key),
                valueTransformer.transform(value)));
          } else {
            return value.map((key, value) => MapEntry<KeyType, ValueType>(
                keyTransformer.transform(key), value));
          }
        } else if (ValueType != dynamic) {
          final valueTransformer = transformers[ValueType];
          if (valueTransformer == null) {
            throw TransformerException(
                "No transformer found for value type $ValueType", value);
          }
          return value.map((key, value) => MapEntry<KeyType, ValueType>(
              key, valueTransformer.transform(value)));
        } else {
          myLogger.w(
              "No KeyType and ValueType found for MapTransformer. Returning value $value of type ${value.runtimeType} as it is.",
              header: "MapTransformer<$KeyType, $ValueType>");
          return value.cast<KeyType, ValueType>();
        }
      }
    } catch (e, s) {
      myLogger.e(e, stackTrace: s, header: "Transformer.transform");
      throw TransformerException(
          "Value $value of type ${value.runtimeType} cannot be transformed to an double",
          value);
    }
    throw TransformerException(
        "Value $value of type ${value.runtimeType} cannot be transformed to an double",
        value);
  }
}

class StringTransformer extends Transformer<String> {
  const StringTransformer();
  @override
  String transformValue(dynamic value) {
    try {
      if (value is String) {
        return value;
      } else if (value is Map || value is List) {
        return jsonEncode(value);
      }
      return value.toString();
    } catch (e, s) {
      myLogger.e(e, stackTrace: s, header: "Transformer.transform");
      throw TransformerException(
          "Value $value of type ${value.runtimeType} cannot be transformed to an double",
          value);
    }
  }
}

abstract class Transformer<TransformTo> {
  const Transformer();
  TransformTo transform(dynamic value) {
    final transformation = transformValue(value);
    ConversionService.logger.i(
        'Transformed $value of type ${value.runtimeType} to $transformation of type ${transformation.runtimeType}',
        header: runtimeType.toString());
    return transformation;
  }

  TransformTo transformValue(dynamic value);
}

class TransformerException extends FormatException {
  TransformerException(super.message, super.source);
  @override
  String toString() => message;
}

Transformer? getTransformer(dynamic value) {
  if (value is String) {
    return StringTransformer();
  } else if (value is int) {
    return IntTransformer();
  } else if (value is double) {
    return DoubleTransformer();
  } else if (value is bool) {
    return BoolTransformer();
  } else if (value is List<int>) {
    return transformers[List<int>];
  } else if (value is List<String>) {
    return transformers[List<String>];
  } else if (value is List<double>) {
    return transformers[List<double>];
  } else if (value is List<bool>) {
    return transformers[List<bool>];
  } else if (value is List<Map<dynamic, dynamic>>) {
    return transformers[List<Map<dynamic, dynamic>>];
  } else if (value is List<Map<dynamic, String>>) {
    return transformers[List<Map<dynamic, String>>];
  } else if (value is List<Map<dynamic, int>>) {
    return transformers[List<Map<dynamic, int>>];
  } else if (value is List<Map<dynamic, double>>) {
    return transformers[List<Map<dynamic, double>>];
  } else if (value is List<Map<dynamic, bool>>) {
    return transformers[List<Map<dynamic, bool>>];
  } else if (value is List<Map<String, dynamic>>) {
    return transformers[List<Map<String, dynamic>>];
  } else if (value is List<Map<String, String>>) {
    return transformers[List<Map<String, String>>];
  } else if (value is List<Map<String, int>>) {
    return transformers[List<Map<String, int>>];
  } else if (value is List<Map<String, double>>) {
    return transformers[List<Map<String, double>>];
  } else if (value is List<Map<String, bool>>) {
    return transformers[List<Map<String, bool>>];
  } else if (value is List<Map<int, dynamic>>) {
    return transformers[List<Map<int, dynamic>>];
  } else if (value is List<Map<int, String>>) {
    return transformers[List<Map<int, String>>];
  } else if (value is List<Map<int, int>>) {
    return transformers[List<Map<int, int>>];
  } else if (value is List<Map<int, double>>) {
    return transformers[List<Map<int, double>>];
  } else if (value is List<Map<int, bool>>) {
    return transformers[List<Map<int, bool>>];
  } else if (value is List<Map<double, dynamic>>) {
    return transformers[List<Map<double, dynamic>>];
  } else if (value is List<Map<double, String>>) {
    return transformers[List<Map<double, String>>];
  } else if (value is List<Map<double, int>>) {
    return transformers[List<Map<double, int>>];
  } else if (value is List<Map<double, double>>) {
    return transformers[List<Map<double, double>>];
  } else if (value is List<Map<double, bool>>) {
    return transformers[List<Map<double, bool>>];
  } else if (value is List<Map<bool, dynamic>>) {
    return transformers[List<Map<bool, dynamic>>];
  } else if (value is List<Map<bool, String>>) {
    return transformers[List<Map<bool, String>>];
  } else if (value is List<Map<bool, int>>) {
    return transformers[List<Map<bool, int>>];
  } else if (value is List<Map<bool, double>>) {
    return transformers[List<Map<bool, double>>];
  } else if (value is List<Map<bool, bool>>) {
    return transformers[List<Map<bool, bool>>];
  }
  // Basic Map types
  if (value is Map<dynamic, dynamic>) {
    return transformers[Map<dynamic, dynamic>];
  } else if (value is Map<dynamic, String>) {
    return transformers[Map<dynamic, String>];
  } else if (value is Map<dynamic, int>) {
    return transformers[Map<dynamic, int>];
  } else if (value is Map<dynamic, double>) {
    return transformers[Map<dynamic, double>];
  } else if (value is Map<dynamic, bool>) {
    return transformers[Map<dynamic, bool>];
  } else if (value is Map<String, dynamic>) {
    return transformers[Map<String, dynamic>];
  } else if (value is Map<String, String>) {
    return transformers[Map<String, String>];
  } else if (value is Map<String, int>) {
    return transformers[Map<String, int>];
  } else if (value is Map<String, double>) {
    return transformers[Map<String, double>];
  } else if (value is Map<String, bool>) {
    return transformers[Map<String, bool>];
  } else if (value is Map<int, dynamic>) {
    return transformers[Map<int, dynamic>];
  } else if (value is Map<int, String>) {
    return transformers[Map<int, String>];
  } else if (value is Map<int, int>) {
    return transformers[Map<int, int>];
  } else if (value is Map<int, double>) {
    return transformers[Map<int, double>];
  } else if (value is Map<int, bool>) {
    return transformers[Map<int, bool>];
  } else if (value is Map<double, dynamic>) {
    return transformers[Map<double, dynamic>];
  } else if (value is Map<double, String>) {
    return transformers[Map<double, String>];
  } else if (value is Map<double, int>) {
    return transformers[Map<double, int>];
  } else if (value is Map<double, double>) {
    return transformers[Map<double, double>];
  } else if (value is Map<double, bool>) {
    return transformers[Map<double, bool>];
  } else if (value is Map<bool, dynamic>) {
    return transformers[Map<bool, dynamic>];
  } else if (value is Map<bool, String>) {
    return transformers[Map<bool, String>];
  } else if (value is Map<bool, int>) {
    return transformers[Map<bool, int>];
  } else if (value is Map<bool, double>) {
    return transformers[Map<bool, double>];
  } else if (value is Map<bool, bool>) {
    return transformers[Map<bool, bool>];
  }

  // Map with List values
  else if (value is Map<String, List<dynamic>>) {
    return transformers[Map<String, List<dynamic>>];
  } else if (value is Map<String, List<String>>) {
    return transformers[Map<String, List<String>>];
  } else if (value is Map<String, List<int>>) {
    return transformers[Map<String, List<int>>];
  } else if (value is Map<String, List<double>>) {
    return transformers[Map<String, List<double>>];
  } else if (value is Map<String, List<bool>>) {
    return transformers[Map<String, List<bool>>];
  } else if (value is Map<int, List<dynamic>>) {
    return transformers[Map<int, List<dynamic>>];
  } else if (value is Map<int, List<String>>) {
    return transformers[Map<int, List<String>>];
  } else if (value is Map<int, List<int>>) {
    return transformers[Map<int, List<int>>];
  } else if (value is Map<int, List<double>>) {
    return transformers[Map<int, List<double>>];
  } else if (value is Map<int, List<bool>>) {
    return transformers[Map<int, List<bool>>];
  } else if (value is Map<double, List<dynamic>>) {
    return transformers[Map<double, List<dynamic>>];
  } else if (value is Map<double, List<String>>) {
    return transformers[Map<double, List<String>>];
  } else if (value is Map<double, List<int>>) {
    return transformers[Map<double, List<int>>];
  } else if (value is Map<double, List<double>>) {
    return transformers[Map<double, List<double>>];
  } else if (value is Map<double, List<bool>>) {
    return transformers[Map<double, List<bool>>];
  } else if (value is Map<bool, List<dynamic>>) {
    return transformers[Map<bool, List<dynamic>>];
  } else if (value is Map<bool, List<String>>) {
    return transformers[Map<bool, List<String>>];
  } else if (value is Map<bool, List<int>>) {
    return transformers[Map<bool, List<int>>];
  } else if (value is Map<bool, List<double>>) {
    return transformers[Map<bool, List<double>>];
  } else if (value is Map<bool, List<bool>>) {
    return transformers[Map<bool, List<bool>>];
  } else if (value is Map<dynamic, List<dynamic>>) {
    return transformers[Map<dynamic, List<dynamic>>];
  } else if (value is Map<dynamic, List<String>>) {
    return transformers[Map<dynamic, List<String>>];
  } else if (value is Map<dynamic, List<int>>) {
    return transformers[Map<dynamic, List<int>>];
  } else if (value is Map<dynamic, List<double>>) {
    return transformers[Map<dynamic, List<double>>];
  } else if (value is Map<dynamic, List<bool>>) {
    return transformers[Map<dynamic, List<bool>>];
  }

  // Nested Map transformers
  else if (value is Map<String, Map<String, dynamic>>) {
    return transformers[Map<String, Map<String, dynamic>>];
  } else if (value is Map<String, Map<String, String>>) {
    return transformers[Map<String, Map<String, String>>];
  } else if (value is Map<String, Map<String, int>>) {
    return transformers[Map<String, Map<String, int>>];
  } else if (value is Map<String, Map<String, double>>) {
    return transformers[Map<String, Map<String, double>>];
  } else if (value is Map<String, Map<String, bool>>) {
    return transformers[Map<String, Map<String, bool>>];
  } else if (value is Map<int, Map<int, dynamic>>) {
    return transformers[Map<int, Map<int, dynamic>>];
  } else if (value is Map<int, Map<int, String>>) {
    return transformers[Map<int, Map<int, String>>];
  } else if (value is Map<int, Map<int, int>>) {
    return transformers[Map<int, Map<int, int>>];
  } else if (value is Map<int, Map<int, double>>) {
    return transformers[Map<int, Map<int, double>>];
  } else if (value is Map<int, Map<int, bool>>) {
    return transformers[Map<int, Map<int, bool>>];
  } else if (value is Map<double, Map<double, dynamic>>) {
    return transformers[Map<double, Map<double, dynamic>>];
  } else if (value is Map<double, Map<double, String>>) {
    return transformers[Map<double, Map<double, String>>];
  } else if (value is Map<double, Map<double, int>>) {
    return transformers[Map<double, Map<double, int>>];
  } else if (value is Map<double, Map<double, double>>) {
    return transformers[Map<double, Map<double, double>>];
  } else if (value is Map<double, Map<double, bool>>) {
    return transformers[Map<double, Map<double, bool>>];
  } else if (value is Map<bool, Map<bool, dynamic>>) {
    return transformers[Map<bool, Map<bool, dynamic>>];
  } else if (value is Map<bool, Map<bool, String>>) {
    return transformers[Map<bool, Map<bool, String>>];
  } else if (value is Map<bool, Map<bool, int>>) {
    return transformers[Map<bool, Map<bool, int>>];
  } else if (value is Map<bool, Map<bool, double>>) {
    return transformers[Map<bool, Map<bool, double>>];
  } else if (value is Map<bool, Map<bool, bool>>) {
    return transformers[Map<bool, Map<bool, bool>>];
  } else if (value is Map<bool, Map<bool, bool>>) {
    return transformers[Map<bool, Map<bool, bool>>];
  }

  // If no matching transformer is found, return null
  return null;
}
