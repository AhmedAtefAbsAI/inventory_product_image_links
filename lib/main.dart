import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:image_downloader/image_downloader.dart';
import 'package:inventory_product_image_links/services.dart';
import 'package:lecle_downloads_path_provider/constants/downloads_directory_type.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'dart:io' as io;

Future<void> main(List<String> args) async {
  runApp(MaterialApp(
    title: "Image Tool",
    home: Scaffold(
      body: Center(
        child: SuperButton(),
      ),
    ),
  ));
}

class SuperButton extends StatelessWidget {
  SuperButton({
    Key? key,
  }) : super(key: key);

  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () async {
          /*   
          //signing in to google and getting credentials
          var driveApi = await getDriveApi();

          //saving inventory
          var directory = await DownloadsPath.downloadsDirectory(
              dirType: DownloadDirectoryTypes.downloads);

<<<<<<< HEAD
          var storageFile = io.File(
              '${directory?.path}/StorageFileGeneralInventory[1]2.json');
=======
          var storageFile =
              io.File('${directory?.path}/StorageFileGeneralInventory.json');
>>>>>>> 669e693ab1598e7ef34f2efc12c75c71405f8052

          String data =
              await rootBundle.loadString("assets/generalInventory.json");
          var jsonResult = jsonDecode(data);
<<<<<<< HEAD

          var i = 0;

          //await downloadAndUploadAndSave(jsonResult, i, driveApi, storageFile, directory); */

          String OldData =
              await rootBundle.loadString("assets/oldGeneralInventory.json");
          var oldJson = jsonDecode(OldData);
          String newData =
              await rootBundle.loadString("assets/generalInventory.json");
          var newJson = jsonDecode(newData);

          //checkForDuplicates(newJson);
          checkForMissing(oldJson, newJson);
        },
        child: Text('$counter'));
  }

  void checkForDuplicates(newJson) {
    List<String> duplicateTestList = [];
    List<String> duplicatesList = [];

    for (Map map in newJson) {
      if (duplicateTestList.contains(map['barcode']))
        duplicatesList.add(map['barcode']);
      else
        duplicateTestList.add(map['barcode']);
    }

    for (var item in duplicatesList) print(item + '\n');
  }

  void checkForMissing(oldJson, newJson) {
    List<String> missingList = [];
    List<String> newJsonList = [];
    for (Map map in newJson) newJsonList.add(map['barcode']);

    for (Map map in oldJson) {
      if (!newJsonList.contains(map['barcode']))
        missingList.add(map['barcode']);
    }

    for (var item in missingList) print(item + '\n');
  }

  Future<void> downloadAndUploadAndSave(jsonResult, int i, DriveApi driveApi,
      io.File storageFile, io.Directory? directory) async {
    for (Map map in jsonResult) {
      if (i == -1) {
        break;
      }

      var oldLink = await map['productPhoto'];

      final file = await downloadImageToFile(oldLink);
      if (file == null) continue;

      //uploading a file to drive
      int length = await file.length();
      var media = Media(file.openRead(), length);

      //modify access permessions here
      var driveFile = drive.File();
      //modify file name
      driveFile.name = await map['productName'];

      String resultId = "";

      try {
        await driveApi.files
            .create(driveFile,
                uploadMedia: media,

                //specify the parameters you want to be able to retrieve here and down when using get
                $fields: 'id')
            .then((value) {
          resultId = value.id!;
        });
      } on Exception catch (e) {
        driveApi = await getDriveApi();
        await driveApi.files
            .create(driveFile,
                uploadMedia: media,

                //specify the parameters you want to be able to retrieve here and down when using get
                $fields: 'id')
            .then((value) {
          resultId = value.id!;
        });
      }
      try {
        //modify permissions for viewing here
        await driveApi.permissions.create(
          drive.Permission()
            ..type = 'anyone'
            ..role = 'reader',
          resultId,
        );
      } on Exception catch (e) {
        driveApi = await getDriveApi();
        //modify permissions for viewing here
        await driveApi.permissions.create(
          drive.Permission()
            ..type = 'anyone'
            ..role = 'reader',
          resultId,
        );
      }
      String modifiedLink = "";
      try {
        await driveApi.files.get(resultId, $fields: 'id ').then((value) {
          modifiedLink = "https://drive.google.com/uc?export=view&id=" +
              resultId; //3azamaaaaaaaaaaaaaaaaaaaaaaaaaa

          i++;
        });
      } on Exception catch (e) {
        driveApi = await getDriveApi();

        await driveApi.files.get(resultId, $fields: 'id').then((value) {
          modifiedLink = "https://drive.google.com/uc?export=view&id=" +
              resultId; //3azamaaaaaaaaaaaaaaaaaaaaaaaaaa

          i++;
        });
      }

      String newMap = jsonEncode({
            'barcode': map['barcode'],
            'productName': map['productName'],
            'numberOfPackageInsideTheCarton':
                map['numberOfPackageInsideTheCarton'],
            'productPhoto': modifiedLink,
            'purchaseUnit': map['purchaseUnit'],
            'saleUnit': map['saleUnit'],
            'section': map['section'],
          }) +
          ',';

      try {
        await storageFile.writeAsString(newMap, mode: io.FileMode.append);
      } on Exception catch (e) {
        storageFile =
            io.File('${directory?.path}/StorageFileGeneralInventory[1]2.json');
        await storageFile.writeAsString(newMap, mode: io.FileMode.append);
      }
    }
  }
}

Future<io.File?> downloadImageToFile(String url) async {
=======

          var i = 0;

          for (Map map in jsonResult) {
            if (i == -1) {
              break;
            }

            var oldLink = await map['productPhoto'];

            final file = await downloadImageToFile(oldLink);

            //uploading a file to drive
            int length = await file.length();
            var media = Media(file.openRead(), length);

            //modify access permessions here
            var driveFile = drive.File();
            //modify file name
            driveFile.name = await map['productName'];

            String resultId = "";

            try {
              await driveApi.files
                  .create(driveFile,
                      uploadMedia: media,

                      //specify the parameters you want to be able to retrieve here and down when using get
                      $fields: 'id')
                  .then((value) {
                resultId = value.id!;
              });
            } on Exception catch (e) {
              driveApi = await getDriveApi();
              await driveApi.files
                  .create(driveFile,
                      uploadMedia: media,

                      //specify the parameters you want to be able to retrieve here and down when using get
                      $fields: 'id')
                  .then((value) {
                resultId = value.id!;
              });
            }
            try {
              //modify permissions for viewing here
              await driveApi.permissions.create(
                drive.Permission()
                  ..type = 'anyone'
                  ..role = 'reader',
                resultId,
              );
            } on Exception catch (e) {
              driveApi = await getDriveApi();
              //modify permissions for viewing here
              await driveApi.permissions.create(
                drive.Permission()
                  ..type = 'anyone'
                  ..role = 'reader',
                resultId,
              );
            }
            String modifiedLink = "";
            try {
              await driveApi.files.get(resultId, $fields: 'id ').then((value) {
                modifiedLink = "https://drive.google.com/uc?export=view&id=" +
                    resultId; //3azamaaaaaaaaaaaaaaaaaaaaaaaaaa

                i++;
              });
            } on Exception catch (e) {
              driveApi = await getDriveApi();

              await driveApi.files.get(resultId, $fields: 'id').then((value) {
                modifiedLink = "https://drive.google.com/uc?export=view&id=" +
                    resultId; //3azamaaaaaaaaaaaaaaaaaaaaaaaaaa

                i++;
              });
            }

            String newMap = jsonEncode({
                  'barcode': map['barcode'],
                  'productName': map['productName'],
                  'numberOfPackageInsideTheCarton':
                      map['numberOfPackageInsideTheCarton'],
                  'productPhoto': modifiedLink,
                  'purchaseUnit': map['purchaseUnit'],
                  'saleUnit': map['saleUnit'],
                  'section': map['section'],
                }) +
                ',';
            await storageFile.writeAsString(newMap, mode: io.FileMode.append);
          }
        },
        child: Text('$counter'));
  }
}

Future<io.File> downloadImageToFile(String url) async {
>>>>>>> 669e693ab1598e7ef34f2efc12c75c71405f8052
  while (true) {
    try {
      var imageId = await ImageDownloader.downloadImage(url,
          outputMimeType: "image/png",
          destination: AndroidDestinationType.directoryDownloads);

      // ha

      String? path = await ImageDownloader.findPath(imageId!);
      if (path == null) continue;
      return io.File(path!);
    } catch (e) {
<<<<<<< HEAD
      return null;
=======
      var directory = await DownloadsPath.downloadsDirectory(
          dirType: DownloadDirectoryTypes.downloads);

      var imageId = await ImageDownloader.downloadImage(url,
          outputMimeType: "image/png",
          destination: AndroidDestinationType.directoryDownloads);

      // ha

      String? path = await ImageDownloader.findPath(imageId!);
      if (path == null) continue;
      return io.File(path);
>>>>>>> 669e693ab1598e7ef34f2efc12c75c71405f8052
    }
  }
}

Future<DriveApi> getDriveApi() async {
  final googleSignIn = GoogleSignIn(scopes: [DriveApi.driveScope]);
  final GoogleSignInAccount? account = await googleSignIn.signIn();
  final authHeaders = await account?.authHeaders;
  final authenticateClient = GoogleAuthClient(authHeaders!);
  return DriveApi(authenticateClient);
}
