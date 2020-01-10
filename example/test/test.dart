import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
void main() {
  Map<String, int> map = Map<String, int> ();

  map["a"] = 0xa;
  map["b"] = 0xb;
  map["c"] = 0xc;
  map["d"] = 0xd;
  map["e"] = 0xe;
  map["f"] = 0xf;

  String str =
      "4441aabd2551da5bdd5e9c91e7f0940ee81d30304441212e93cc55a9e4427926f643d699c9cf30314441ed24d32f947d486df47a0c28f5771e4e30324441cd41608733632a514677e18224d2851730334441490aa503282e6a4aaff4e9430c1a5dfb30344441e9e6542f13d982bfccd2a6448efe21cb30354441e21c01bdeb6875e329a35a808efd9ea94646";

  List<int> ints = List<int>();
  for (int i = 0; i < str.length; i++) {
    String key = str[i];

    bool result = map.containsKey(key);

    if (result) {
      ints.add(map[key]);
    } else {
      ints.add(int.parse(key));
    }
  }
  print(str);

  print(jsonEncode(ints));
}


