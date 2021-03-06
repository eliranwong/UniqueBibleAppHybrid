import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

extension HexColor on Color {

  String toHex({bool leadingHashSign = true}) {
    final String colorString = toString();
    if (colorString == "null") return "${leadingHashSign ? '#' : ''}ffffff";
    return "${leadingHashSign ? '#' : ''}${colorString.substring(10, colorString.length - 1)}";
  }

  // Functions fromHex and toHexAlternative below are originally suggested at:
  // https://stackoverflow.com/questions/50081213/how-do-i-use-hexadecimal-color-strings-in-flutter
  // Please note that we use toHex above instead of toHexAlternative below.

  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write("ff");
    buffer.write(hexString.replaceFirst("#", ""));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /*
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHexAlternative({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      // Comment the following line to exclude 'ff' after '#'
      //'${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';*/

}

class HtmlElements {

  static JavascriptChannel ubaJsChannel() {
    return JavascriptChannel(
        name: "UBA",
        onMessageReceived: (JavascriptMessage message) {
          print(message.message);
        },
    );
  }

  static String defaultJs = r"""

function hl1(id, cl, sn) {
    if (cl != '') {
        w3.addStyle('.c'+cl,'background-color','PAPAYAWHIP');
    }
    if (sn != '') {
        w3.addStyle('.G'+sn,'background-color','#E7EDFF');
    }
    if (id != '') {
        var focalElement = document.getElementById('w'+id);
        if (focalElement != null) {
            document.getElementById('w'+id).style.background='#C9CFFF';
        }
    }
    if ((id != '') && (id.startsWith("l") != true)) {
        document.title = "_instantWord:::"+activeB+":::"+id;
    }
}

function textName(name) {
    UBA.postMessage("_bibleinfo:::"+name);
}

function commentaryName(name) {
    UBA.postMessage("_commentaryinfo:::"+name);
}

function bookName(name) {
    var fullname = getFullBookName(name);
    UBA.postMessage("_info:::"+fullname);
}

function getFullBookName(abbreviation) {
    var fullBookNameObject = {
        bGen: "Genesis",
        bExod: "Exodus",
        bLev: "Leviticus",
        bNum: "Numbers",
        bDeut: "Deuteronomy",
        bJosh: "Joshua",
        bJudg: "Judges",
        bRuth: "Ruth",
        b1Sam: "1 Samuel",
        b2Sam: "2 Samuel",
        b1Kgs: "1 Kings",
        b2Kgs: "2 Kings",
        b1Chr: "1 Chronicles",
        b2Chr: "2 Chronicles",
        bEzra: "Ezra",
        bNeh: "Nehemiah",
        bEsth: "Esther",
        bJob: "Job",
        bPs: "Psalms",
        bProv: "Proverbs",
        bEccl: "Ecclesiastes",
        bSong: "Song of Songs",
        bIsa: "Isaiah",
        bJer: "Jeremiah",
        bLam: "Lamentations",
        bEzek: "Ezekiel",
        bDan: "Daniel",
        bHos: "Hosea",
        bJoel: "Joel",
        bAmos: "Amos",
        bObad: "Obadiah",
        bJonah: "Jonah",
        bMic: "Micah",
        bNah: "Nahum",
        bHab: "Habakkuk",
        bZeph: "Zephaniah",
        bHag: "Haggai",
        bZech: "Zechariah",
        bMal: "Malachi",
        bMatt: "Matthew",
        bMark: "Mark",
        bLuke: "Luke",
        bJohn: "John",
        bActs: "Acts",
        bRom: "Romans",
        b1Cor: "1 Corinthians",
        b2Cor: "2 Corinthians",
        bGal: "Galatians",
        bEph: "Ephesians",
        bPhil: "Philippians",
        bCol: "Colossians",
        b1Thess: "1 Thessalonians",
        b2Thess: "2 Thessalonians",
        b1Tim: "1 Timothy",
        b2Tim: "2 Timothy",
        bTitus: "Titus",
        bPhlm: "Philemon",
        bHeb: "Hebrews",
        bJas: "James",
        b1Pet: "1 Peter",
        b2Pet: "2 Peter",
        b1John: "1 John",
        b2John: "2 John",
        b3John: "3 John",
        bJude: "Jude",
        bRev: "Revelation",
        bBar: "Baruch",
        bAddDan: "Additions to Daniel",
        bPrAzar: "Prayer of Azariah",
        bBel: "Bel and the Dragon",
        bSgThree: "Song of the Three Young Men",
        bSus: "Susanna",
        b1Esd: "1 Esdras",
        b2Esd: "2 Esdras",
        bAddEsth: "Additions to Esther",
        bEpJer: "Epistle of Jeremiah",
        bJdt: "Judith",
        b1Macc: "1 Maccabees",
        b2Macc: "2 Maccabees",
        b3Macc: "3 Maccabees",
        b4Macc: "4 Maccabees",
        bPrMan: "Prayer of Manasseh",
        bPs151: "Psalm 151",
        bSir: "Sirach",
        bTob: "Tobit",
        bWis: "Wisdom of Solomon",
        bPssSol: "Psalms of Solomon",
        bOdes: "Odes",
        bEpLao: "Epistle to the Laodiceans"
    };
    return fullBookNameObject["b"+abbreviation];
}

function bcvToVerseRefence(b,c,v) {
    var abbSBL = {
        ub1: "Gen",
        ub2: "Exod",
        ub3: "Lev",
        ub4: "Num",
        ub5: "Deut",
        ub6: "Josh",
        ub7: "Judg",
        ub8: "Ruth",
        ub9: "1Sam",
        ub10: "2Sam",
        ub11: "1Kgs",
        ub12: "2Kgs",
        ub13: "1Chr",
        ub14: "2Chr",
        ub15: "Ezra",
        ub16: "Neh",
        ub17: "Esth",
        ub18: "Job",
        ub19: "Ps",
        ub20: "Prov",
        ub21: "Eccl",
        ub22: "Song",
        ub23: "Isa",
        ub24: "Jer",
        ub25: "Lam",
        ub26: "Ezek",
        ub27: "Dan",
        ub28: "Hos",
        ub29: "Joel",
        ub30: "Amos",
        ub31: "Obad",
        ub32: "Jonah",
        ub33: "Mic",
        ub34: "Nah",
        ub35: "Hab",
        ub36: "Zeph",
        ub37: "Hag",
        ub38: "Zech",
        ub39: "Mal",
        ub40: "Matt",
        ub41: "Mark",
        ub42: "Luke",
        ub43: "John",
        ub44: "Acts",
        ub45: "Rom",
        ub46: "1Cor",
        ub47: "2Cor",
        ub48: "Gal",
        ub49: "Eph",
        ub50: "Phil",
        ub51: "Col",
        ub52: "1Thess",
        ub53: "2Thess",
        ub54: "1Tim",
        ub55: "2Tim",
        ub56: "Titus",
        ub57: "Phlm",
        ub58: "Heb",
        ub59: "Jas",
        ub60: "1Pet",
        ub61: "2Pet",
        ub62: "1John",
        ub63: "2John",
        ub64: "3John",
        ub65: "Jude",
        ub66: "Rev",
        ub70: "Bar",
        ub71: "AddDan",
        ub72: "PrAzar",
        ub73: "Bel",
        ub75: "Sus",
        ub76: "1Esd",
        ub77: "2Esd",
        ub78: "AddEsth",
        ub79: "EpJer",
        ub80: "Jdt",
        ub81: "1Macc",
        ub82: "2Macc",
        ub83: "3Macc",
        ub84: "4Macc",
        ub85: "PrMan",
        ub86: "Ps151",
        ub87: "Sir",
        ub88: "Tob",
        ub89: "Wis",
        ub90: "PssSol",
        ub91: "Odes",
        ub92: "EpLao"
    };
    var abb = abbSBL["ub"+String(b)];
    return abb+" "+c+":"+v;
}

function mbbcvToVerseRefence(b,c,v) {
    var abbSBL = {
        mb10: "Gen",
        mb20: "Exod",
        mb30: "Lev",
        mb40: "Num",
        mb50: "Deut",
        mb60: "Josh",
        mb61: "Josh",
        mb70: "Judg",
        mb71: "Judg",
        mb80: "Ruth",
        mb90: "1Sam",
        mb100: "2Sam",
        mb110: "1Kgs",
        mb120: "2Kgs",
        mb130: "1Chr",
        mb140: "2Chr",
        mb150: "Ezra",
        mb160: "Neh",
        mb190: "Esth",
        mb220: "Job",
        mb230: "Ps",
        mb240: "Prov",
        mb250: "Eccl",
        mb260: "Song",
        mb290: "Isa",
        mb300: "Jer",
        mb310: "Lam",
        mb330: "Ezek",
        mb340: "Dan",
        mb350: "Hos",
        mb360: "Joel",
        mb370: "Amos",
        mb380: "Obad",
        mb390: "Jonah",
        mb400: "Mic",
        mb410: "Nah",
        mb420: "Hab",
        mb430: "Zeph",
        mb440: "Hag",
        mb450: "Zech",
        mb460: "Mal",
        mb470: "Matt",
        mb480: "Mark",
        mb490: "Luke",
        mb500: "John",
        mb510: "Acts",
        mb520: "Rom",
        mb530: "1Cor",
        mb540: "2Cor",
        mb550: "Gal",
        mb560: "Eph",
        mb570: "Phil",
        mb580: "Col",
        mb590: "1Thess",
        mb600: "2Thess",
        mb610: "1Tim",
        mb620: "2Tim",
        mb630: "Titus",
        mb640: "Phlm",
        mb650: "Heb",
        mb660: "Jas",
        mb670: "1Pet",
        mb680: "2Pet",
        mb690: "1John",
        mb700: "2John",
        mb710: "3John",
        mb720: "Jude",
        mb730: "Rev",
        mb165: "1Esd",
        mb468: "2Esd",
        mb170: "Tob",
        mb171: "Tob",
        mb180: "Jdt",
        mb270: "Wis",
        mb280: "Sir",
        mb305: "PrAzar",
        mb315: "EpJer",
        mb320: "Bar",
        mb325: "Sus",
        mb326: "Sus",
        mb345: "Bel",
        mb346: "Bel",
        mb462: "1Macc",
        mb464: "2Macc",
        mb466: "3Macc",
        mb467: "4Macc",
        mb780: "EpLao",
        mb790: "PrMan",
        mb469: "PrMan",
        mb191: "AddEsth",
        mb231: "Ps151",
        mb232: "PssSol",
        mb235: "PssSol",
        mb800: "Odes",
        mb245: "Odes",
        mb341: "AddDan"
    };
    var abb = abbSBL["mb"+String(b)];
    return abb+" "+c+":"+v;
}

function bookAbbToNo(bookAbb) {
    var bookNo = {
        bGen: "1",
        bExod: "2",
        bLev: "3",
        bNum: "4",
        bDeut: "5",
        bJosh: "6",
        bJudg: "7",
        bRuth: "8",
        b1Sam: "9",
        b2Sam: "10",
        b1Kgs: "11",
        b2Kgs: "12",
        b1Chr: "13",
        b2Chr: "14",
        bEzra: "15",
        bNeh: "16",
        bEsth: "17",
        bJob: "18",
        bPs: "19",
        bProv: "20",
        bEccl: "21",
        bSong: "22",
        bIsa: "23",
        bJer: "24",
        bLam: "25",
        bEzek: "26",
        bDan: "27",
        bHos: "28",
        bJoel: "29",
        bAmos: "30",
        bObad: "31",
        bJonah: "32",
        bMic: "33",
        bNah: "34",
        bHab: "35",
        bZeph: "36",
        bHag: "37",
        bZech: "38",
        bMal: "39",
        bMatt: "40",
        bMark: "41",
        bLuke: "42",
        bJohn: "43",
        bActs: "44",
        bRom: "45",
        b1Cor: "46",
        b2Cor: "47",
        bGal: "48",
        bEph: "49",
        bPhil: "50",
        bCol: "51",
        b1Thess: "52",
        b2Thess: "53",
        b1Tim: "54",
        b2Tim: "55",
        bTitus: "56",
        bPhlm: "57",
        bHeb: "58",
        bJas: "59",
        b1Pet: "60",
        b2Pet: "61",
        b1John: "62",
        b2John: "63",
        b3John: "64",
        bJude: "65",
        bRev: "66",
        bBar: "70",
        bAddDan: "71",
        bPrAzar: "72",
        bBel: "73",
        bSus: "75",
        b1Esd: "76",
        b2Esd: "77",
        bAddEsth: "78",
        bEpJer: "79",
        bJdt: "80",
        b1Macc: "81",
        b2Macc: "82",
        b3Macc: "83",
        b4Macc: "84",
        bPrMan: "85",
        bPs151: "86",
        bSir: "87",
        bTob: "88",
        bWis: "89",
        bPssSol: "90",
        bOdes: "91",
        bEpLao: "92"
    };
    return bookNo["b"+bookAbb];
}

function bcv(b,c,v,opt1,opt2) {
    tbcv(activeText,b,c,v,opt1,opt2);
}

function tbcv(text,b,c,v,opt1,opt2) {
    var verseReference = bcvToVerseRefence(b,c,v);
    if ((opt1 != undefined) && (opt2 != undefined)) {
        if (c == opt1) {
            verseReference = verseReference+"-"+String(opt2);
        } else {
            verseReference = verseReference+"-"+String(opt1)+":"+String(opt2);
        }
    } else if (opt1 != undefined) {
        verseReference = verseReference+"-"+String(opt1);
    }
    UBA.postMessage("BIBLE:::"+text+":::"+verseReference);
}

function imv(b,c,v,opt1,opt2) {
    if ((opt1 != undefined) && (opt2 != undefined)) {
        UBA.postMessage("_imv:::"+b+"."+c+"."+v+"."+opt1+"."+opt2);
    } else {
        UBA.postMessage("_imv:::"+b+"."+c+"."+v);
    }
}

function ctbcv(text,b,c,v) {
    var verseReference = bcvToVerseRefence(b,c,v);
    UBA.postMessage("COMMENTARY:::"+text+":::"+verseReference);
}

function cbcv(b,c,v) {
    var verseReference = bcvToVerseRefence(b,c,v);
    UBA.postMessage("COMMENTARY:::"+verseReference);
}

function cr(b,c,v) {
    var verseReference = mbbcvToVerseRefence(b,c,v);
    UBA.postMessage("BIBLE:::"+activeText+":::"+verseReference);
}

function hl0(id, cl, sn) {
    if (cl != '') {
        w3.addStyle('.c'+cl,'background-color','');
    }
    if (sn != '') {
        w3.addStyle('.G'+sn,'background-color','');
    }
    if (id != '') {
        var focalElement = document.getElementById('w'+id);
        if (focalElement != null) {
            document.getElementById('w'+id).style.background='';
        }
    }
}

function w(book, wordID) {
    UBA.postMessage("WORD:::"+book+":::"+wordID);
}

function iw(book, wordID) {
    if (book != '' && wordID != '') {
        UBA.postMessage("_instantWord:::"+book+":::"+wordID);
    }
}

function qV(v) {
    UBA.postMessage("_instantVerse:::"+activeText+":::"+activeB+"."+activeC+"."+v);
}

function mV(v) {
    UBA.postMessage("_menu:::"+activeText+"."+activeB+"."+activeC+"."+v);
}

function nV(v) {
    UBA.postMessage("_openversenote:::"+activeB+"."+activeC+"."+v);
}

function nC() {
    UBA.postMessage("_openchapternote:::"+activeB+"."+activeC);
}

function luV(v) {
    var verseReference = bcvToVerseRefence(activeB,activeC,v);
    UBA.postMessage("_stayOnSameTab:::");
    UBA.postMessage("BIBLE:::"+activeText+":::"+verseReference);
}

function luW(v,wid,cl,lex,morph,bdb) {
    UBA.postMessage("WORD:::"+activeB+":::"+wid);
}

function checkCompare() {
    versionList.forEach(addCompare);
    if (compareList.length == 0) {
        alert("No version is selected for comparison.");
    } else {
        var compareTexts = compareList.join("_");
        compareList = [];
        var verseReference = bcvToVerseRefence(activeB,activeC,activeV);
        UBA.postMessage("COMPARE:::"+activeText+"_"+compareTexts+":::"+verseReference);
    }
}

function addCompare(value) {
    var checkBox = document.getElementById("compare"+value);
    if (checkBox.checked == true){
        compareList.push(value);
    }
}

function checkParallel() {
    versionList.forEach(addParallel);
    if (parallelList.length == 0) {
        alert("No version is selected for parallel reading.");
    } else {
        var parallelTexts = parallelList.join("_");
        parallelList = [];
        var verseReference = bcvToVerseRefence(activeB,activeC,activeV);
        UBA.postMessage("PARALLEL:::"+activeText+"_"+parallelTexts+":::"+verseReference);
    }
}

function addParallel(value) {
    var checkBox = document.getElementById("parallel"+value);
    if (checkBox.checked == true){
        parallelList.push(value);
    }
}

function checkDiff() {
    versionList.forEach(addDiff);
    if (diffList.length == 0) {
        alert("No version is selected for detailed comparison.");
    } else {
        var diffTexts = diffList.join("_");
        diffList = [];
        var verseReference = bcvToVerseRefence(activeB,activeC,activeV);
        UBA.postMessage("DIFF:::"+activeText+"_"+diffTexts+":::"+verseReference);
    }
}

function addDiff(value) {
    var checkBox = document.getElementById("diff"+value);
    if (checkBox.checked == true){
        diffList.push(value);
    }
}

function checkSearch(searchKeyword, searchText) {
    var searchString = document.getElementById("bibleSearch").value;
    if (searchString == "") {
        alert("Search field is empty!");
    } else {
        UBA.postMessage(searchKeyword+":::"+searchText+":::"+searchString);
    }
}

function checkMultiSearch(searchKeyword) {
    var searchString = document.getElementById("multiBibleSearch").value;
    if (searchString == "") {
        alert("Search field is empty!");
    } else {
        versionList.forEach(addMultiSearch);
        if (searchList.length == 0) {
            UBA.postMessage(searchKeyword+":::"+activeText+":::"+searchString);
        } else {
            var searchTexts = searchList.join("_");
            searchList = [];
            UBA.postMessage(searchKeyword+":::"+searchTexts+":::"+searchString);
        }
    }
}

function addMultiSearch(value) {
    var checkBox = document.getElementById("search"+value);
    if (checkBox.checked == true){
        searchList.push(value);
    }
}

function searchLexicalEntry(lexicalEntry) {
    UBA.postMessage("LEMMA:::"+lexicalEntry);
}

function searchCode(lexicalEntry, morphologyCode) {
    UBA.postMessage("MORPHOLOGYCODE:::"+lexicalEntry+","+morphologyCode);
}

function searchMorphologyCode(lexicalEntry, morphologyCode) {
    UBA.postMessage("MORPHOLOGYCODE:::"+lexicalEntry+","+morphologyCode);
}

function searchMorphologyItem(lexicalEntry, morphologyItem) {
    UBA.postMessage("MORPHOLOGY:::LexicalEntry LIKE '%"+lexicalEntry+",%' AND Morphology LIKE '%"+morphologyItem+"%'");
}

function searchBook(lexicalEntry, bookName) {
    bookNo = bookAbbToNo(bookName);
    UBA.postMessage("MORPHOLOGY:::LexicalEntry LIKE '%"+lexicalEntry+",%' AND Book = "+bookNo);
}

function lmCombo(lexicalEntry, morphologyModule, morphologyCode) {
    UBA.postMessage("LMCOMBO:::"+lexicalEntry+":::"+morphologyModule+":::"+morphologyCode);
}

function lexicon(module, entry) {
    UBA.postMessage("LEXICON:::"+module+":::"+entry);
}

function lex(entry) {
    UBA.postMessage("LEXICON:::"+entry);
}

function bdbid(entry) {
    UBA.postMessage("LEXICON:::BDB:::"+entry);
}

function lgntdf(entry) {
    UBA.postMessage("LEXICON:::LGNTDF:::"+entry);
}

function gk(entry) {
    var initial = entry[0];
    var number = entry.slice(1);
    if (number.length == 1) {
        number = "000"+number;
    } else if (number.length == 2) {
        number = "00"+number;
    } else if (number.length == 3) {
        number = "0"+number;
    }
    UBA.postMessage("LEXICON:::gk"+initial+"5"+number);
}

function ln(entry) {
    UBA.postMessage("LEXICON:::ln"+entry);
}

function encyclopedia(module, entry) {
    UBA.postMessage("ENCYCLOPEDIA:::"+module+":::"+entry);
}

function cl(entry) {
	if (typeof activeB !== 'undefined' || activeB !== null) {
    	var bcv = activeB+'.'+activeC+'.'+activeV;
    	clause(bcv, entry);
	}
}

function clause(bcv, entry) {
    UBA.postMessage("CLAUSE:::"+bcv+":::"+entry);
}

function bibleDict(entry) {
    UBA.postMessage("DICTIONARY:::"+entry);
}

function searchBibleBook(text, book, searchString) {
    UBA.postMessage("ADVANCEDSEARCH:::"+text+":::Book = "+book+" AND Scripture LIKE '%"+searchString+"%'");
}

function iSearchBibleBook(text, book, searchString) {
    UBA.postMessage("ADVANCEDISEARCH:::"+text+":::Book = "+book+" AND Scripture LIKE '%"+searchString+"%'");
}

function exlbl(entry) {
    UBA.postMessage("EXLB:::exlbl:::"+entry);
}

function exlbp(entry) {
    UBA.postMessage("EXLB:::exlbp:::"+entry);
}

function exlbt(entry) {
    UBA.postMessage("EXLB:::exlbt:::"+entry);
}

function openImage(module, entry) {
    UBA.postMessage("_image:::"+module+":::"+entry);
    UBA.postMessage("UniqueBible.app");
}

function searchResource(tool) {
    if (tool != "") {
        UBA.postMessage("_command:::SEARCHTOOL:::"+tool+":::");
    }
}

function searchDict(module) {
    searchResource(module);
}

function searchDictionary(module) {
    searchResource(module);
}

function searchEncyc(module) {
    searchResource(module);
}

function searchEncyclopedia(module) {
    searchResource(module);
}

function searchItem(module, entry) {
    UBA.postMessage("SEARCHTOOL:::"+module+":::"+entry);
}

function searchEntry(module, entry) {
    UBA.postMessage("SEARCHTOOL:::"+module+":::"+entry);
}

function rmac(entry) {
    searchItem("mRMAC", entry);
}

function etcbcmorph(entry) {
    searchItem("mETCBC", entry);
}

function lxxmorph(entry) {
    searchItem("mLXX", entry);
}

function listBookTopic(module) {
    UBA.postMessage("_book:::"+module);
}

function openHistoryRecord(recordNo) {
    UBA.postMessage("_historyrecord:::"+recordNo);
}

function openExternalRecord(recordNo) {
    UBA.postMessage("_openfile:::"+recordNo);
}

function openHtmlFile(filename) {
    UBA.postMessage("open:::htmlResources/"+filename);
}

function openHtmlImage(filename) {
    UBA.postMessage("_htmlimage:::"+filename);
}

function editExternalRecord(recordNo) {
    UBA.postMessage("_editfile:::"+recordNo);
}

function website(link) {
    UBA.postMessage("_website:::"+link);
}

function searchThirdDictionary(module, entry) {
    UBA.postMessage("SEARCHTHIRDDICTIONARY:::"+module+":::"+entry);
}

function openThirdDictionary(module, entry) {
    UBA.postMessage("THIRDDICTIONARY:::"+module+":::"+entry);
}

function uba(file) {
    UBA.postMessage("_uba:::"+file);
}

function bn(b, c, v, n) {
    UBA.postMessage("_biblenote:::"+b+"."+c+"."+v+"."+n);
}

function wordnote(module, wordID) {
    UBA.postMessage("_wordnote:::"+module+":::"+wordID);
}

function searchBible(module, item) {
    UBA.postMessage("SEARCH:::"+module+":::"+item);
}

function searchVerse(module, item, b, c, v) {
    UBA.postMessage("ADVANCEDSEARCH:::"+module+":::Book = "+b+" AND Chapter = "+c+" AND Verse = "+v+" AND Scripture LIKE '%"+item+"%'");
}

function searchWord(portion, wordID) {
    UBA.postMessage("_searchword:::"+portion+":::"+wordID);
}

function harmony(tool, number) {
    UBA.postMessage("_harmony:::"+tool+"."+number);
}

function promise(tool, number) {
    UBA.postMessage("_promise:::"+tool+"."+number);
}

function openMarvelFile(filename) {
    UBA.postMessage("_open:::"+filename);
}

function hiV(b,c,v,code) {
    spanId = "s" + b + "." + c + "." + v
    divEl = document.getElementById(spanId);
    curClass = divEl.className;
    if (code === "delete") {
        divEl.className = "";
    } else if (code === curClass) {
        divEl.className = "";
        code = "delete";
    } else {
        divEl.className = code;
    }
    verseReference = bcvToVerseRefence(b,c,v);
    UBA.postMessage("_HIGHLIGHT:::"+verseReference+":::"+code);
}
    """;

  static String defaultCss = r"""
body {
    margin-left: 5px;
    margin-right: 5px;
}

/*
select:active, select:hover {
outline-color: none;
}
option:checked, option:hover, option:checked: after {
background: #ffb7b7;
}
*/

::selection {
    background: #ffb7b7;
    /* WebKit/Blink Browsers */
}

::-moz-selection {
    background: #ffb7b7;
    /* Gecko Browsers */
}

/* css for Greek data */

kgrk {
    font-family: 'KoineGreek';
}

kgrk, gu, grk {
    font-size: 110%;
}

/* css for Hebrew data */

bdbheb, bdbarc, hu, heb {
    font-family: 'Ezra SIL';
    font-size: 130%;
}

bdbheb, bdbarc {
    display: inline-block;
    direction: rtl;
}

rtl {
    display: inline-block;
    direction: rtl;
    font-family: 'Ezra SIL';
    font-size: 130%;
}

external {
    font-size: 80%;
}

red, z {
    color: red;
}

blu {
    color: blue;
    font-size: 80%;
}

points {
    color: gray;
    font-weight: bold;
    font-size: 80%;
}

bb {
    color: brown;
    font-weight: bold;
}

hp {
    color: brown;
    font-weight: bold;
    font-size: 80%;
}

highlight {
    font-style: italic;
}

transliteration {
    color: gray;
}

div.section, div.point {
    display: block;
    border: 1px solid green;
    border-radius: 5px;
    padding: 2px 5px;
    margin-top: 5px;
    margin-bottom: 5px;
}

div.remarks {
    display: block;
    border: 1px solid gray;
    border-radius: 5px;
    padding: 2px 5px;
    margin-top: 5px;
    margin-bottom: 5px;
}

div.bhs, div.hebch {
    direction: rtl;
}

div.info {
    margin-left: 5%;
    margin-right: 5%;
}

div.menu {
    margin-left: 2%;
    margin-right: 2%;
}

div.vword {
    border: 1px solid #F5B041;
    border-radius: 5px;
    padding: 2px 5px;
    margin-top: 3px;
    margin-bottom: 3px;
}

div.translation {
    border: 1px solid #9B59B6;
    border-radius: 5px;
    padding: 2px 5px;
    margin-top: 3px;
    margin-bottom: 3px;
}

div.ew {
    margin-left: 5%;
    margin-right: 5%;
    font-size: 110%;
    display: inline-block;
}

div.mr {
    margin-left: 100;
}

div.nav {
    margin-left: 5%;
    margin-right: 5%;
}

div.refList {
    display: inline;
}

/* css for linguistic annotations */

div.bhp, div.bhw, div.w, div.int {
    display: inline-block;
    text-align: center;
}

div.int {
    vertical-align: text-top;
}

div.bhc {
    direction: rtl;
    border: 1px solid #9B59B6;
    border-radius: 5px;
    padding: 2px 5px;
    margin-top: 3px;
    margin-bottom: 3px;
}

div.bhp {
    border: 1px solid gray;
    border-radius: 5px;
    padding: 2px 5px;
    margin-top: 3px;
    margin-bottom: 3px;
}

div.bhw {
    border: 1px solid #F5B041;
    border-radius: 5px;
    padding: 2px 5px;
    margin-top: 3px;
    margin-bottom: 3px;
}

clid {
    color: #641E16;
    font-weight: bold;
}

mclid {
    color: #641E16;
    font-style: italic;
}

connector {
    color: #9B59B6;
}

ckind, ctyp, crela {
    color: #EC407A;
    display: inline-block;
}

ptyp {
    text-decoration: underline;
    color: gray;
}

pfunction {
    color: #3498DB;
    font-size: 90%;
}

det {
    font-weight: bold;
}

undet {
    font-style: italic;
}

prela {
    display: none;
}

hbint, gntint, gloss {
    direction: ltr;
    vertical-align: super;
    display: inline-block;
    color: #D35400;
}

gntint, gloss {
    font-size: 90%;
}

cllevel {
    color: #9B59B6;
}

clinfo {
    color: #641E16;
    font-weight: bold;
}

subclinfo {
    color: #641E16;
    font-weight: bold;
    font-size: 80%;
}

funcinfo {
    color: #3498DB;
    font-size: 90%;
}

wordid {
    text-decoration: underline;
    font-size: 80%;
    color: gray;
}

wsbl, wphono {
    direction: ltr;
    display: inline-block;
    color: gray;
    font-size: 80%;
}

wmorph, wsn {
    direction: ltr;
    display: inline-block;
    font-size: 70%;
}

wgloss {
    direction: ltr;
    display: inline-block;
    font-size: 90%;
    color: #D35400;
}

wtrans {
    direction: ltr;
    display: inline-block;
    font-size: 90%;
    color: #641E16;
}

wlex {
    direction: ltr;
    display: inline-block;
    font-size: 90%;
    color: #3498DB;
}

cit, clt, cst, cbhs, cbsb, cleb {
    display: block;
}

clt, cbsb {
    color: #3498DB;
}

cst, cleb {
    color: #EC407A;
}

cbsb, cleb {
    direction: ltr;
}

div.cltrans {
    margin-left: 10px;
    margin-right: 10px;
    display: block;
    border: 1px solid #EC407A;
    border-radius: 5px;
    padding: 2px 5px;
    margin-top: 3px;
    margin-bottom: 3px;
}

div.wrap {
    display: inline-block;
}

cl {
    display: table;
}

div.c {
    vertical-align: top;
    text-align: left;
    border: 1px solid #9B59B6;
    border-radius: 5px;
    padding: 2px 5px;
    margin-top: 3px;
    margin-bottom: 3px;
}

div.p {
    display: inline-block;
    vertical-align: top;
    text-align: left;
    border: 1px solid gray;
    border-radius: 5px;
    padding: 2px 5px;
    margin-top: 3px;
    margin-bottom: 3px;
}

div.w, div.int {
    border: 1px solid #F5B041;
    border-radius: 5px;
    padding: 2px 5px;
    margin-top: 3px;
    margin-bottom: 3px;
}

/* css for clause segmentation */

div.bhsa {
    direction: rtl;
    border-right: 5px solid #F5B041;
    margin-left: 5%;
    margin-right: 5%;
    padding: 5px 10px 5px 10px;
}

div.e {
    border-left: 5px solid #F5B041;
    margin-left: 5%;
    margin-right: 5%;
    padding: 5px 10px 5px 10px;
}

/* general text formatting */

ref, entry {
    color: #515790;
}

red ref, red entry {
    color: #e86a6a;
}

ref:hover, entry:hover {
    color: red;
    cursor: pointer;
}

.alignCenter {
    text-align: center;
}

vid:hover, grk:hover, heb:hover, eng:hover {
    cursor: pointer;
}

ot {
    font-weight: bold;
    font-style: italic;
}

/* Add Zoom Animation */

.animate {
    -webkit-animation: animatezoom 0.6s;
    animation: animatezoom 0.6s
}

@-webkit-keyframes animatezoom {
    from {
        -webkit-transform: scale(0)
    }
    to {
        -webkit-transform: scale(1)
    }
}

@keyframes animatezoom {
    from {
        transform: scale(0)
    }
    to {
        transform: scale(1)
    }
}

/* End of Master Control */

vid {
    color: #515790;
    vertical-align: super;
    font-size: 70%;
}

/* unvisited link */

a:link {
    color: #515790;
    text-decoration: none;
}

/* visited link */

a:visited {
    color: #515790;
    text-decoration: none;
}

/* mouse over link */

a:hover, vid:hover {
    color: red;
    text-decoration: none;
    cursor: pointer;
}

/* selected link */

a:active {
    color: #515790;
    text-decoration: none;
}

/* chapter link */

ch {
    color: #515790;
}

/* chapter link - hover */

ch:hover {
    color: red;
    text-decoration: none;
    cursor: pointer;
}

table {
    width: 100%;
    font-size: 90%;
    border-collapse: collapse;
}

table, th, td {
    padding-left: 10px;
    border: 1px solid #D3D3D3;
}

text {
    color: #515790;
}

text:hover {
    color: red;
    cursor: pointer;
}

addon {
    color: #515790;
}

addon:hover {
    color: red;
    cursor: pointer;
}

.para1 {
    width: 50%;
}

.para2 {
    width: 50%;
}

f {
    color: #4f81b1;
    vertical-align: super;
    font-size: 70%;
}

m {
    font-size: 90%;
}

sym {
    color: #4f81b1;
}

dic {
    color: #d1ff92;
    font-size: 80%;
}

dic:hover {
    cursor: pointer;
    font-size: 80%;
}

untrans {
    color: #4f81b1;
    font-size: 70%;
}

grkorder {
    color: #4f81b1;
    font-size: 70%;
}

grkorder2 {
    color: #4f81b1;
    font-size: 70%;
}

vb {
    color: red;
}

pn {
    color: teal;
}

lin {
    font-style: italic;
}

qere {
    font-style: italic;
}

/* headings */

h1.window {
    text-align: center;
    font-size: 130%;
}

h1, h2, h3, h4 {
    color: #010740;
}

h4 {
    text-align: center;
}

h4 {
    text-align: center;
}

/* words of Jesus */

woj {
    color: #641E16;
}

/* css for clause segmentation */

wlexeme {
    display: block;
    text-align: center;
    border: 1px solid #F5B041;
    border-radius: 5px;
    padding: 2px 5px;
    margin-top: 3px;
    margin-bottom: 3px;
}

mlexeme {
    color: #641E16;
}

otgloss, ntgloss {
    display: inline-block;
    direction: ltr;
}

mentry {
    display: block;
    font-size: 90%;
    direction: ltr;
    text-align: left;
}

wform {
    color: #3498DB;
}

morphCode {
    color: gray;
}

morphContent {
    color: #9B59B6;
}

e {
    color: #641E16;
}

hl {
    color: #9B59B6;
}

hlb {
    color: #D35400;
    direction: ltr;
    display: inline-block;
}

hlr {
    color: #3498DB;
}

tlit {
    color: gray;
    direction: ltr;
    display: inline-block;
}

button.feature {
    font-size: 70%;
    cursor: pointer;
    background-color: #151B54;
    color: white;
}

button.feature:hover {
    background-color: #333972;
}

button.feature:active {
    background-color: #515790;
}

tag {
    cursor: pointer;
}

esblu {
    color: #357EC2;
}

mbe {
    color: #641E16;
}

mbn {
    color: gray;
}

testColor{
    color: #4f4c4c;
}

.hl1 {
    background: rgb(232, 232, 9);
}

.ohl1 {
    color: rgb(211, 211, 17);
}

.hl2 {
    background: rgb(79, 247, 250);
}
.ohl2 {
    color: rgb(79, 247, 250);
}

.ul1 {
    text-decoration: underline;
}
.oul1 {
    color: gray;
}

    """;

  static String w3Js = r"""
/* W3.JS 1.01 Jan 2017 by w3schools.com */
"use strict";
var w3 = {};
w3.hide = function (sel) {
  w3.hideElements(w3.getElements(sel));
};
w3.hideElements = function (elements) {
  var i, l = elements.length;
  for (i = 0; i < l; i++) {
    w3.hideElement(elements[i]);
  }
};
w3.hideElement = function (element) {
  w3.styleElement(element, "display", "none");
};
w3.show = function (sel, a) {
  var elements = w3.getElements(sel);
  if (a) {w3.hideElements(elements);}
  w3.showElements(elements);
};
w3.showElements = function (elements) {
  var i, l = elements.length;
  for (i = 0; i < l; i++) {
    w3.showElement(elements[i]);
  }
};
w3.showElement = function (element) {
  w3.styleElement(element, "display", "block");
};
w3.addStyle = function (sel, prop, val) {
  w3.styleElements(w3.getElements(sel), prop, val);
};
w3.styleElements = function (elements, prop, val) {
  var i, l = elements.length;
  for (i = 0; i < l; i++) {    
    w3.styleElement(elements[i], prop, val);
  }
};
w3.styleElement = function (element, prop, val) {
  element.style.setProperty(prop, val);
};
w3.toggleShow = function (sel) {
  var i, x = w3.getElements(sel), l = x.length;
  for (i = 0; i < l; i++) {    
    if (x[i].style.display == "none") {
      w3.styleElement(x[i], "display", "block");
    } else {
      w3.styleElement(x[i], "display", "none");
    }
  }
};
w3.addClass = function (sel, name) {
  w3.addClassElements(w3.getElements(sel), name);
};
w3.addClassElements = function (elements, name) {
  var i, l = elements.length;
  for (i = 0; i < l; i++) {
    w3.addClassElement(elements[i], name);
  }
};
w3.addClassElement = function (element, name) {
  var i, arr1, arr2;
  arr1 = element.className.split(" ");
  arr2 = name.split(" ");
  for (i = 0; i < arr2.length; i++) {
    if (arr1.indexOf(arr2[i]) == -1) {element.className += " " + arr2[i];}
  }
};
w3.removeClass = function (sel, name) {
  w3.removeClassElements(w3.getElements(sel), name);
};
w3.removeClassElements = function (elements, name) {
  var i, l = elements.length, arr1, arr2, j;
  for (i = 0; i < l; i++) {
    w3.removeClassElement(elements[i], name);
  }
};
w3.removeClassElement = function (element, name) {
  var i, arr1, arr2;
  arr1 = element.className.split(" ");
  arr2 = name.split(" ");
  for (i = 0; i < arr2.length; i++) {
    while (arr1.indexOf(arr2[i]) > -1) {
      arr1.splice(arr1.indexOf(arr2[i]), 1);     
    }
  }
  element.className = arr1.join(" ");
};
w3.toggleClass = function (sel, c1, c2) {
  w3.toggleClassElements(w3.getElements(sel), c1, c2);
};
w3.toggleClassElements = function (elements, c1, c2) {
  var i, l = elements.length;
  for (i = 0; i < l; i++) {    
    w3.toggleClassElement(elements[i], c1, c2);
  }
};
w3.toggleClassElement = function (element, c1, c2) {
  var t1, t2, t1Arr, t2Arr, j, arr, allPresent;
  t1 = (c1 || "");
  t2 = (c2 || "");
  t1Arr = t1.split(" ");
  t2Arr = t2.split(" ");
  arr = element.className.split(" ");
  if (t2Arr.length == 0) {
    allPresent = true;
    for (j = 0; j < t1Arr.length; j++) {
      if (arr.indexOf(t1Arr[j]) == -1) {allPresent = false;}
    }
    if (allPresent) {
      w3.removeClassElement(element, t1);
    } else {
      w3.addClassElement(element, t1);
    }
  } else {
    allPresent = true;
    for (j = 0; j < t1Arr.length; j++) {
      if (arr.indexOf(t1Arr[j]) == -1) {allPresent = false;}
    }
    if (allPresent) {
      w3.removeClassElement(element, t1);
      w3.addClassElement(element, t2);          
    } else {
      w3.removeClassElement(element, t2);        
      w3.addClassElement(element, t1);
    }
  }
};
w3.getElements = function (id) {
  if (typeof id == "object") {
    return [id];
  } else {
    return document.querySelectorAll(id);
  }
};
w3.filterHTML = function(id, sel, filter) {
  var a, b, c, i, ii, iii, hit;
  a = w3.getElements(id);
  for (i = 0; i < a.length; i++) {
    b = w3.getElements(sel);
    for (ii = 0; ii < b.length; ii++) {
      hit = 0;
      if (b[ii].innerHTML.toUpperCase().indexOf(filter.toUpperCase()) > -1) {
        hit = 1;
      }
      c = b[ii].getElementsByTagName("*");
      for (iii = 0; iii < c.length; iii++) {
        if (c[iii].innerHTML.toUpperCase().indexOf(filter.toUpperCase()) > -1) {
          hit = 1;
        }
      }
      if (hit == 1) {
        b[ii].style.display = "";
      } else {
        b[ii].style.display = "none";
      }
    }
  }
};
w3.sortHTML = function(id, sel, sortvalue) {
  var a, b, i, ii, y, bytt, v1, v2, cc, j;
  a = w3.getElements(id);
  for (i = 0; i < a.length; i++) {
    for (j = 0; j < 2; j++) {
      cc = 0;
      y = 1;
      while (y == 1) {
        y = 0;
        b = a[i].querySelectorAll(sel);
        for (ii = 0; ii < (b.length - 1); ii++) {
          bytt = 0;
          if (sortvalue) {
            v1 = b[ii].querySelector(sortvalue).innerHTML.toLowerCase();
            v2 = b[ii + 1].querySelector(sortvalue).innerHTML.toLowerCase();
          } else {
            v1 = b[ii].innerHTML.toLowerCase();
            v2 = b[ii + 1].innerHTML.toLowerCase();
          }
          if ((j == 0 && (v1 > v2)) || (j == 1 && (v1 < v2))) {
            bytt = 1;
            break;
          }
        }
        if (bytt == 1) {
          b[ii].parentNode.insertBefore(b[ii + 1], b[ii]);
          y = 1;
          cc++;
        }
      }
      if (cc > 0) {break;}
    }
  }
};
w3.slideshow = function (sel, ms, func) {
  var i, ss, x = w3.getElements(sel), l = x.length;
  ss = {};
  ss.current = 1;
  ss.x = x;
  ss.ondisplaychange = func;
  if (!isNaN(ms) || ms == 0) {
    ss.milliseconds = ms;
  } else {
    ss.milliseconds = 1000;
  }
  ss.start = function() {
    ss.display(ss.current)
    if (ss.ondisplaychange) {ss.ondisplaychange();}
    if (ss.milliseconds > 0) {
      window.clearTimeout(ss.timeout);
      ss.timeout = window.setTimeout(ss.next, ss.milliseconds);
    }
  };
  ss.next = function() {
    ss.current += 1;
    if (ss.current > ss.x.length) {ss.current = 1;}
    ss.start();
  };
  ss.previous = function() {
    ss.current -= 1;
    if (ss.current < 1) {ss.current = ss.x.length;}
    ss.start();
  };
  ss.display = function (n) {
    w3.styleElements(ss.x, "display", "none");
    w3.styleElement(ss.x[n - 1], "display", "block");
  }
  ss.start();
  return ss;
};
w3.includeHTML = function() {
  var z, i, elmnt, file, xhttp;
  z = document.getElementsByTagName("*");
  for (i = 0; i < z.length; i++) {
    elmnt = z[i];
    file = elmnt.getAttribute("w3-include-html");
    if (file) {
      xhttp = new XMLHttpRequest();
      xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
          elmnt.innerHTML = this.responseText;
          elmnt.removeAttribute("w3-include-html");
          w3.includeHTML();
        }
      }      
      xhttp.open("GET", file, true);
      xhttp.send();
      return;
    }
  }
};
w3.getHttpData = function (file, func) {
  w3.http(file, function () {
    if (this.readyState == 4 && this.status == 200) {
      func(this.responseText);
    }
  });
};
w3.getHttpObject = function (file, func) {
  w3.http(file, function () {
    if (this.readyState == 4 && this.status == 200) {
      func(JSON.parse(this.responseText));
    }
  });
};
w3.displayHttp = function (id, file) {
  w3.http(file, function () {
    if (this.readyState == 4 && this.status == 200) {
      w3.displayObject(id, JSON.parse(this.responseText));
    }
  });
};
w3.http = function (target, readyfunc, xml, method) {
  var httpObj;
  if (!method) {method = "GET"; }
  if (window.XMLHttpRequest) {
    httpObj = new XMLHttpRequest();
  } else if (window.ActiveXObject) {
    httpObj = new ActiveXObject("Microsoft.XMLHTTP");
  }
  if (httpObj) {
    if (readyfunc) {httpObj.onreadystatechange = readyfunc;}
    httpObj.open(method, target, true);
    httpObj.send(xml);
  }
};
w3.getElementsByAttribute = function (x, att) {
  var arr = [], arrCount = -1, i, l, y = x.getElementsByTagName("*"), z = att.toUpperCase();
  l = y.length;
  for (i = -1; i < l; i += 1) {
    if (i == -1) {y[i] = x;}
    if (y[i].getAttribute(z) !== null) {arrCount += 1; arr[arrCount] = y[i];}
  }
  return arr;
};  
w3.dataObject = {},
w3.displayObject = function (id, data) {
  var htmlObj, htmlTemplate, html, arr = [], a, l, rowClone, x, j, i, ii, cc, repeat, repeatObj, repeatX = "";
  htmlObj = document.getElementById(id);
  htmlTemplate = init_template(id, htmlObj);
  html = htmlTemplate.cloneNode(true);
  arr = w3.getElementsByAttribute(html, "w3-repeat");
  l = arr.length;
  for (j = (l - 1); j >= 0; j -= 1) {
    cc = arr[j].getAttribute("w3-repeat").split(" ");
    if (cc.length == 1) {
      repeat = cc[0];
    } else {
      repeatX = cc[0];
      repeat = cc[2];
    }
    arr[j].removeAttribute("w3-repeat");
    repeatObj = data[repeat];
    if (repeatObj && typeof repeatObj == "object" && repeatObj.length != "undefined") {
      i = 0;
      for (x in repeatObj) {
        i += 1;
        rowClone = arr[j];
        rowClone = w3_replace_curly(rowClone, "element", repeatX, repeatObj[x]);
        a = rowClone.attributes;
        for (ii = 0; ii < a.length; ii += 1) {
          a[ii].value = w3_replace_curly(a[ii], "attribute", repeatX, repeatObj[x]).value;
        }
        (i === repeatObj.length) ? arr[j].parentNode.replaceChild(rowClone, arr[j]) : arr[j].parentNode.insertBefore(rowClone, arr[j]);
      }
    } else {
      console.log("w3-repeat must be an array. " + repeat + " is not an array.");
      continue;
    }
  }
  html = w3_replace_curly(html, "element");
  htmlObj.parentNode.replaceChild(html, htmlObj);
  function init_template(id, obj) {
    var template;
    template = obj.cloneNode(true);
    if (w3.dataObject.hasOwnProperty(id)) {return w3.dataObject[id];}
    w3.dataObject[id] = template;
    return template;
  }
  function w3_replace_curly(elmnt, typ, repeatX, x) {
    var value, rowClone, pos1, pos2, originalHTML, lookFor, lookForARR = [], i, cc, r;
    rowClone = elmnt.cloneNode(true);
    pos1 = 0;
    while (pos1 > -1) {
      originalHTML = (typ == "attribute") ? rowClone.value : rowClone.innerHTML;
      pos1 = originalHTML.indexOf("{{", pos1);
      if (pos1 === -1) {break;}
      pos2 = originalHTML.indexOf("}}", pos1 + 1);
      lookFor = originalHTML.substring(pos1 + 2, pos2);
      lookForARR = lookFor.split("||");
      value = undefined;
      for (i = 0; i < lookForARR.length; i += 1) {
        lookForARR[i] = lookForARR[i].replace(/^\s+|\s+$/gm, ''); //trim
        if (x) {value = x[lookForARR[i]];}
        if (value == undefined && data) {value = data[lookForARR[i]];}
        if (value == undefined) {
          cc = lookForARR[i].split(".");
          if (cc[0] == repeatX) {value = x[cc[1]]; }
        }
        if (value == undefined) {
          if (lookForARR[i] == repeatX) {value = x;}
        }
        if (value == undefined) {
          if (lookForARR[i].substr(0, 1) == '"') {
            value = lookForARR[i].replace(/"/g, "");
          } else if (lookForARR[i].substr(0,1) == "'") {
            value = lookForARR[i].replace(/'/g, "");
          }
        }
        if (value != undefined) {break;}
      }
      if (value != undefined) {
        r = "{{" + lookFor + "}}";
        if (typ == "attribute") {
          rowClone.value = rowClone.value.replace(r, value);
        } else {
          w3_replace_html(rowClone, r, value);
        }
      }
      pos1 = pos1 + 1;
    }
    return rowClone;
  }
  function w3_replace_html(a, r, result) {
    var b, l, i, a, x, j;
    if (a.hasAttributes()) {
      b = a.attributes;
      l = b.length;
      for (i = 0; i < l; i += 1) {
        if (b[i].value.indexOf(r) > -1) {b[i].value = b[i].value.replace(r, result);}
      }
    }
    x = a.getElementsByTagName("*");
    l = x.length;
    a.innerHTML = a.innerHTML.replace(r, result);
  }
};
  """;

}