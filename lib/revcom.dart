class Revcom {
  Map<String, String> revcom = Map<String, String>();

  Revcom() {
    revcom["TTT"] = "AAA";
    revcom["TTC"] = "GAA";
    revcom["TTA"] = "TAA";
    revcom["TTG"] = "CAA";
    revcom["TCT"] = "AGA";
    revcom["TCC"] = "GGA";
    revcom["TCA"] = "TGA";
    revcom["TCG"] = "CGA";
    revcom["TAT"] = "ATA";
    revcom["TAC"] = "GTA";
    revcom["TAA"] = "TTA";
    revcom["TAG"] = "CTA";
    revcom["TGT"] = "ACA";
    revcom["TGC"] = "GCA";
    revcom["TGA"] = "TCA";
    revcom["TGG"] = "CCA";
    revcom["CTT"] = "AAG";
    revcom["CTC"] = "GAG";
    revcom["CTA"] = "TAG";
    revcom["CTG"] = "CAG";
    revcom["CCT"] = "AGG";
    revcom["CCC"] = "GGG";
    revcom["CCA"] = "TGG";
    revcom["CCG"] = "CGG";
    revcom["CAT"] = "ATG";
    revcom["CAC"] = "GTG";
    revcom["CAA"] = "TTG";
    revcom["CAG"] = "CTG";
    revcom["CGT"] = "ACG";
    revcom["CGC"] = "GCG";
    revcom["CGA"] = "TCG";
    revcom["CGG"] = "CCG";
    revcom["ATT"] = "AAT";
    revcom["ATC"] = "GAT";
    revcom["ATA"] = "TAT";
    revcom["ATG"] = "CAT";
    revcom["ACT"] = "AGT";
    revcom["ACC"] = "GGT";
    revcom["ACA"] = "TGT";
    revcom["ACG"] = "CGT";
    revcom["AAT"] = "ATT";
    revcom["AAC"] = "GTT";
    revcom["AAA"] = "TTT";
    revcom["AAG"] = "CTT";
    revcom["AGT"] = "ACT";
    revcom["AGC"] = "GCT";
    revcom["AGA"] = "TCT";
    revcom["AGG"] = "CCT";
    revcom["GTT"] = "AAC";
    revcom["GTC"] = "GAC";
    revcom["GTA"] = "TAC";
    revcom["GTG"] = "CAC";
    revcom["GCT"] = "AGC";
    revcom["GCC"] = "GGC";
    revcom["GCA"] = "TGC";
    revcom["GCG"] = "CGC";
    revcom["GAT"] = "ATC";
    revcom["GAC"] = "GTC";
    revcom["GAA"] = "TTC";
    revcom["GAG"] = "CTC";
    revcom["GGT"] = "ACC";
    revcom["GGC"] = "GCC";
    revcom["GGA"] = "TCC";
    revcom["GGG"] = "CCC";
  }

  String operator [](String key) {
    return revcom[key];
  }
}
