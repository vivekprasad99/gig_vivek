class PanAndBeneficiaryNameMatcher {
  // static bool panAndBeneficiaryNameMatcher(
  //     String? panName, String? beneficiaryName) {
  //   if (panName.isNullOrEmpty || beneficiaryName.isNullOrEmpty) {
  //     return false;
  //   }
  //
  //   String panNameLowerCase =
  //       removeTitleFromString(panName!.toLowerCase()).trim();
  //   String beneficiaryNameLowerCase =
  //       removeTitleFromString(beneficiaryName!.toLowerCase()).trim();
  //
  //   if (panNameLowerCase == beneficiaryNameLowerCase) {
  //     return true;
  //   }
  //
  //   List<String> panNameStrings = panNameLowerCase.split(" ");
  //   List<String> beneficiaryNameStrings = beneficiaryNameLowerCase.split(" ");
  //
  //   if (panNameStrings.length == 1) {
  //     for (String beneficiary in beneficiaryNameStrings) {
  //       if (beneficiary.length == 1) continue;
  //       if (panNameStrings[0].contains(beneficiary)) return true;
  //     }
  //   } else if (beneficiaryNameStrings.length == 1) {
  //     for (String pan in panNameStrings) {
  //       if (pan.length == 1) continue;
  //       if (beneficiaryNameStrings[0].contains(pan)) return true;
  //     }
  //   } else {
  //     var isContainACharString = false;
  //     for (String s in panNameStrings) {
  //       if (s.length <= 2) {
  //         isContainACharString = true;
  //         break;
  //       }
  //     }
  //     if (!isContainACharString) {
  //       for (String s in beneficiaryNameStrings) {
  //         if (s.length <= 2) {
  //           isContainACharString = true;
  //           break;
  //         }
  //       }
  //     }
  //     if (!isContainACharString &&
  //         panNameStrings.length == beneficiaryNameStrings.length) {
  //       var matchCount = 0;
  //       for (String s in beneficiaryNameStrings) {
  //         for (String s1 in panNameStrings) {
  //           if (s1.contains(s)) matchCount++;
  //         }
  //       }
  //       if (matchCount != beneficiaryNameStrings.length) {
  //         var matchCount = 0;
  //         for (String s in panNameStrings) {
  //           for (String s1 in beneficiaryNameStrings) {
  //             if (s1.contains(s)) matchCount++;
  //           }
  //         }
  //         return matchCount == panNameStrings.length;
  //       } else {
  //         return true;
  //       }
  //     }
  //     var matchCount = 0;
  //     for (String pan in panNameStrings) {
  //       for (String beneficiary in beneficiaryNameStrings) {
  //         if (beneficiary.substring(0, 1) == pan.substring(0, 1)) {
  //           matchCount++;
  //           break;
  //         }
  //       }
  //     }
  //     return matchCount == panNameStrings.length ||
  //         matchCount == beneficiaryNameStrings.length;
  //   }
  //   return false;
  // }

  // static String removeTitleFromString(String string) {
  //   return string.replaceAll(RegExp("\\s{2,}"), " ").replaceFirst(
  //       RegExp('^\\s*(?:m(?:|is|iss|rs?|s)|dr|rev)\\b[\\s.]*'), "");
  // }
  //
  // static matcher() {
  //   assert(panAndBeneficiaryNameMatcher("BADU UZAIR AHMED", "B UZAIR AHMED"),
  //       true);
  //   assert(panAndBeneficiaryNameMatcher("rajesh kumar", "kumar rajesh"), true);
  //   assert(panAndBeneficiaryNameMatcher("Mrs.Rajesh kumar", "rajesh k"), true);
  //   // assert(panAndBeneficiaryNameMatcher("Aman kumar", "Amar kumar"), false);
  //   assert(
  //       panAndBeneficiaryNameMatcher(
  //           "mis LOPAMUDRA PRIYADARSINI", "Miss LOPAMUDRA PRIYADARSINI"),
  //       true);
  //   assert(
  //       panAndBeneficiaryNameMatcher(
  //           "mis. LOPAMUDRA PRIYADARSINI", "Miss LOPAMUDRA PRIYADARSINI"),
  //       true);
  //   assert(panAndBeneficiaryNameMatcher("Rajeshkumar", "rajesh k"), true);
  //   assert(panAndBeneficiaryNameMatcher("Rajesh kumar", "rajesh kumar"), true);
  //   // assert(panAndBeneficiaryNameMatcher("mukesh kumar", "rajesh kumar"), false);
  //   assert(panAndBeneficiaryNameMatcher("Rajesh kumar", "rajeshkumar"), true);
  //   assert(panAndBeneficiaryNameMatcher("Mr.Rajesh kumar", "rajesh k"), true);
  //   assert(panAndBeneficiaryNameMatcher("Mrs.Rajesh kumar", "rajesh k"), true);
  //   assert(panAndBeneficiaryNameMatcher("Miss Mrhesh kumar", "Mrhesh"), true);
  //   assert(
  //       panAndBeneficiaryNameMatcher(
  //           "MOHAMMADTAUSEEFANSARI", "MOHAMMAD TAUSEEF ANSARI"),
  //       true);
  //   // assert(
  //   //     panAndBeneficiaryNameMatcher(
  //   //         "P H JOSEPH JAYARAJ", "HILLARI RAJ JOSEPH JAYARAJ"),
  //   //     false);
  //   assert(panAndBeneficiaryNameMatcher("Anurag D M", "DA MAA Anurag"), true);
  //   assert(
  //       panAndBeneficiaryNameMatcher(
  //           "LOPAMUDRA PRIYADARSINI", "Miss LOPAMUDRA PRIYADARSINI"),
  //       true);
  //   assert(panAndBeneficiaryNameMatcher("KAPIL", "KAPIL SO RAMESH"), true);
  //   assert(panAndBeneficiaryNameMatcher("AARTI RANI", "AARTI RANI D/O KAND"),
  //       true);
  //   assert(
  //       panAndBeneficiaryNameMatcher("DEVENDRA KUMAR", "DEVENDRA KUMAR SO SA"),
  //       true);
  //   assert(panAndBeneficiaryNameMatcher("MUKESH KUMAR", "Mr MR MUKESH KUMAR"),
  //       true);
  //   assert(panAndBeneficiaryNameMatcher("komal", "KOMAL W/O MONU"), true);
  //   assert(panAndBeneficiaryNameMatcher("NAGENDIRAN SARAN", "n SARAN"), true);
  // }
}
