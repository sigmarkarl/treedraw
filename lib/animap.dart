class Animap {
  Map<String, String> amimap = Map<String, String>();

  Animap() {
    amimap["TTT"] = "F";
    amimap["TTC"] = "F";
    amimap["TTA"] = "L";
    amimap["TTG"] = "L";
    amimap["TCT"] = "S";
    amimap["TCC"] = "S";
    amimap["TCA"] = "S";
    amimap["TCG"] = "S";
    amimap["TAT"] = "Y";
    amimap["TAC"] = "Y";
    amimap["TAA"] = "1";
    amimap["TAG"] = "0";
    amimap["TGT"] = "C";
    amimap["TGC"] = "C";
    amimap["TGA"] = "0";
    amimap["TGG"] = "W";
    amimap["CTT"] = "L";
    amimap["CTC"] = "L";
    amimap["CTA"] = "L";
    amimap["CTG"] = "L";
    amimap["CCT"] = "P";
    amimap["CCC"] = "P";
    amimap["CCA"] = "P";
    amimap["CCG"] = "P";
    amimap["CAT"] = "H";
    amimap["CAC"] = "H";
    amimap["CAA"] = "Q";
    amimap["CAG"] = "Q";
    amimap["CGT"] = "R";
    amimap["CGC"] = "R";
    amimap["CGA"] = "R";
    amimap["CGG"] = "R";
    amimap["ATT"] = "I";
    amimap["ATC"] = "I";
    amimap["ATA"] = "I";
    amimap["ATG"] = "M";
    amimap["ACT"] = "T";
    amimap["ACC"] = "T";
    amimap["ACA"] = "T";
    amimap["ACG"] = "T";
    amimap["AAT"] = "N";
    amimap["AAC"] = "N";
    amimap["AAA"] = "K";
    amimap["AAG"] = "K";
    amimap["AGT"] = "S";
    amimap["AGC"] = "S";
    amimap["AGA"] = "R";
    amimap["AGG"] = "R";
    amimap["GTT"] = "V";
    amimap["GTC"] = "V";
    amimap["GTA"] = "V";
    amimap["GTG"] = "V";
    amimap["GCT"] = "A";
    amimap["GCC"] = "A";
    amimap["GCA"] = "A";
    amimap["GCG"] = "A";
    amimap["GAT"] = "D";
    amimap["GAC"] = "D";
    amimap["GAA"] = "E";
    amimap["GAG"] = "E";
    amimap["GGT"] = "G";
    amimap["GGC"] = "G";
    amimap["GGA"] = "G";
    amimap["GGG"] = "G";
  }

  String operator [](String key) {
    return amimap[key];
  }
}
