import 'file_mx.dart';
import 'bible_parser.dart';

class TestFunctions {

  String marvelData;
  FileMx fileMx;

  TestFunctions() {
    setup();
  }

  Future<void> setup() async {
    marvelData = await StorageMx.getUserDirectoryPath();
    fileMx = FileMx(marvelData);
    print("Main ui setup is ready!");
  }

  Future<void> testFileMx() async {
    if (marvelData.isNotEmpty) {
      Map<String, List<String>> resources = {
        "bibles": ["KJV.bible", "NET.bible"],
      };
      for (String resource in resources.keys) {
        resources[resource].forEach((filename) async {
          await fileMx.copyAssetsFileToUserDirectory(resource, filename);
        });
      }
      final String biblesFolder = await fileMx.getUserDirectoryFolder("bibles");
      print(fileMx.getDirectoryItems(biblesFolder));
    }
  }

  Future<void> testSqlite() async {
    // test sqlite DB
    String sqlStatement = "SELECT * FROM Verses WHERE Book = ? AND Chapter = ? ORDER BY Verse";
    List<dynamic> filter = [43, 3];
    print(await fileMx.querySqliteDB("bibles", "NET.bible", sqlStatement, filter));
  }

  void testBibleParser() {
    BibleParser parser = BibleParser("ENG");
    String testText = ";kja dfasdfkj; Rm 5:8 skjj Jn 3:16 ;lkjas;dkjf ";
    print(parser.extractAllReferences(testText));
  }

}