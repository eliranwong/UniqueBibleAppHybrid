import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:chunked_stream/chunked_stream.dart';

class StorageMx {

  // Check if storage permission is granted.
  static Future<bool> checkStoragePermission() async {
    final PermissionStatus permissionResult = await Permission.storage.request();
    return (permissionResult.isGranted);
  }

  // get user directory
  static Future<String> getUserDirectoryPath() async {
    if (await checkStoragePermission()) {
      final Directory userDirectory = (Platform.isAndroid)
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      return userDirectory.path;
    } else {
      // Return an empty path if storage permission is not granted.
      return "";
    }
  }

}

class FileMx {

  final String userDirectory;

  FileMx(this.userDirectory);

  // Get the full path of a file located in user directory.
  String getFullPath(String feature, String filename) => join(userDirectory, feature, filename);

  // Get path of a json file in bundle.
  String getAssetsJsonPath(String feature, [String module]) => "assets/$feature/$module.json";

  // Open a sqlite database in user directory.
  Future<Database> openSqliteDB(String feature, String filename) async => (feature == "FULLPATH") ? await openDatabase(filename) : await openDatabase(join(userDirectory, feature, filename));

  // Query an already opened database.
  Future<List<Map<String, dynamic>>> queryOpenedSqliteDB(Database db, String sqlStatement, List<dynamic> filer) async => await db.rawQuery(sqlStatement, filer);

  // Open a database and perform a single query.
  Future<List<Map<String, dynamic>>> querySqliteDB(String feature, String filename, String sqlStatement, List<dynamic> filer) async {
    final Database db = await openSqliteDB(feature, filename);
    List<Map<String, dynamic>> queryResults = await queryOpenedSqliteDB(db, sqlStatement, filer);
    db.close();
    return queryResults;
  }

  // Functions related to operations on directories:

  // Get the path of a folder in user directory.
  Future<String> getUserDirectoryFolder(String folderName) async {
    // Create folder in user directory if it does not exist.
    final String folderPath = join(userDirectory, folderName);
    await createDirectory(folderPath);
    return folderPath;
  }

  Future<Map<String, String>> checkInstalledResources(String folder, String filter) async {
    final String resourceFolder = await getUserDirectoryFolder(folder);
    return getDirectoryItems(resourceFolder, filter: filter);
  }

  // Create directory if it doesn't exist.
  // Reference: https://api.flutter.dev/flutter/dart-io/Directory-class.html
  Future<void> createDirectory(String folderPath) async {
    final Directory targetDirectory = Directory(folderPath);
    final bool targetDirectoryExists = await targetDirectory.exists();
    if (!targetDirectoryExists) await targetDirectory.create(recursive: true);
  }

  // Note that "list" and "listSync" are different.
  // list: https://api.flutter.dev/flutter/dart-io/Directory/list.html
  // listSync: https://api.flutter.dev/flutter/dart-io/Directory/listSync.html
  Map<String, String> getDirectoryItems(String folderPath, {String filter = ""}) {
    Map<String, String> directoryItems = {};
    final Directory targetDirectory = Directory(folderPath);
    final List<FileSystemEntity> directoryItemList = targetDirectory.listSync(followLinks: false);
    for (FileSystemEntity item in directoryItemList) {
      if (item is File) {
        final String filePath = item.path;
        if (filter.isEmpty) {
          directoryItems[basename(filePath)] = filePath;
        } else if (filter.contains("|")) {
          final List<String> filterList = filter.split("|");
          for (String f in filterList) {
            if (filePath.endsWith(f)) {
              final String fileBasename = basename(filePath);
              directoryItems[fileBasename.substring(0, (fileBasename.length - f.length))] = filePath;
            }
          }
        } else if (filePath.endsWith(filter)) {
          final String fileBasename = basename(filePath);
          directoryItems[fileBasename.substring(0, (fileBasename.length - filter.length))] = filePath;
        }
        // The following does not work with extended extension, like .dct.mybible.
        /*} else if (extension(filePath) == filter) {
          directoryItems[basenameWithoutExtension(filePath)] = filePath;
        }*/
      }
    }
    return directoryItems;
  }

  // Functions related to file operations:

  // Copy a file from assets folder to user directory.
  // e.g. FileMx().copyAssetsFileToUserDirectory("bibles", "KJV.bible");
  Future<String> copyAssetsFileToUserDirectory(
      String folderName, String filename) async {

    // Get the path of user directory folder
    final String folderPath = await getUserDirectoryFolder(folderName);

    // Write a file from the copied data.
    final filePath = join(folderPath, filename);
    final File targetFile = File(filePath);
    final bool targetFileExists = await targetFile.exists();
    if (!targetFileExists) {
      // Load whole file in memory before copying.  This may not work with large-size file in low-memory devices.
      final ByteData data = await rootBundle.load("assets/$folderName/$filename");
      writeByteDataToFile(data, filePath);
    }
    return filePath;
  }

  // Write byte data to a file.
  // Note that "writeAsBytes" and "writeAsBytesSync" are different.
  // writeAsBytes: https://api.flutter.dev/flutter/dart-io/File/writeAsBytes.html
  // writeAsBytesSync: https://api.flutter.dev/flutter/dart-io/File/writeAsBytesSync.html
  void writeByteDataToFile(ByteData data, String path) {
    final buffer = data.buffer;
    //final Uint8List dataUint8List = buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    File(path).writeAsBytesSync(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes)); // Do not set flush to true.
  }

  Future<void> copyLargeFile(String sourcePath, String copyPath, {int byteSize = 512}) async {
    final streamReader = ChunkedStreamIterator(File(sourcePath).openRead());
    IOSink sink = File(copyPath).openWrite(mode: FileMode.append);
    while (true) {
      // Write 512 bytes by default each time.
      final lengthBytes = await streamReader.read(byteSize);
      if (lengthBytes.isEmpty) break;
      sink.add(lengthBytes);
    }
    //sink.flush();
    sink.close();
  }

}