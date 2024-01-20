

import 'package:band_names/models/band_model.dart';
import 'package:flutter/material.dart';

class GlobalStates with ChangeNotifier {

  final List<Band> _bands = [];

  get allBands => _bands;

  set addBand(Band band) {
    _bands.add(band);
    notifyListeners();
  }

  set deleteBand(String id) {
    _bands.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  set addVote(String id) {
    final band = _bands.firstWhere((item) => item.id == id);
    band.votes ++;
    notifyListeners();
  }



}