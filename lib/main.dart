import 'dart:convert';
import 'dart:io';

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
  runApp(const MaterialApp(
    title: "Image Tool",
    home: Scaffold(
      body: Center(
        child: SuperButton(),
      ),
    ),
  ));
}

class SuperButton extends StatelessWidget {
  const SuperButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () async {
          //signing in to google and getting credentials
          final driveApi = await getDriveApi();
          //saving index
          final indexDirectory = await DownloadsPath.downloadsDirectory(
              dirType: DownloadDirectoryTypes.downloads);

          final indexFile = io.File('${indexDirectory?.path}/index.txt');
          int i = 0;

          //saving inventory
          final directory = await DownloadsPath.downloadsDirectory(
              dirType: DownloadDirectoryTypes.downloads);

          final storageFile =
              io.File('${directory?.path}/UpdatedGeneralInventory.json');

          String data =
              await rootBundle.loadString("assets/generalInventory.json");
          final jsonResult = jsonDecode(data);

          for (var map in jsonResult) {
            try {
              var oldLink = map['productPhoto'];

              final file = await downloadImageToFile(oldLink);

              //uploading a file to drive
              int length = await file.length();
              var media = Media(file.openRead(), length);

              //modify access permessions here
              var driveFile = drive.File();
              //modify file name
              driveFile.name = map['productName'];

              String resultId = "";

              await driveApi.files
                  .create(driveFile,
                      uploadMedia: media,

                      //specify the parameters you want to be able to retrieve here and down when using get
                      $fields: 'id , webContentLink , webViewLink')
                  .then((value) {
                resultId = value.id!;
              });

              //modify permissions for viewing here
              await driveApi.permissions.create(
                drive.Permission()
                  ..type = 'anyone'
                  ..role = 'reader',
                resultId,
              );

              driveApi.files
                  .get(resultId, $fields: 'id , webContentLink , webViewLink')
                  .then((value) {
                final link = (value as drive.File).webViewLink;
                final modifiedLink =
                    "https://drive.google.com/uc?export=view&id=$resultId"; //3azamaaaaaaaaaaaaaaaaaaaaaaaaaa

                map['productPhoto'] = modifiedLink;

                print('\n\n  ');
                print('Laaaaaaaaaaaaaaaaaaaaaaaaast index is $i');
                print('\n\n  ');
              });
              await indexFile.writeAsString("$i");

              await storageFile.writeAsString(jsonEncode(map),
                  mode: FileMode.append);
              i++;
            } on Exception catch (e) {
              print(e);
              final tdirectory = await DownloadsPath.downloadsDirectory(
                  dirType: DownloadDirectoryTypes.downloads);

              final tstorageFile =
                  io.File('${tdirectory?.path}/damagedItems.json');
              await tstorageFile.writeAsString(jsonEncode(map),
                  mode: FileMode.append);
              i++;
              await indexFile.writeAsString(
                "$i",
              );
              continue;
            }
          }
        },
        child: Icon(Icons.start));
  }
}

Future<io.File> downloadImageToFile(String url) async {
  var imageId = await ImageDownloader.downloadImage(url);

  // ha

  var path = await ImageDownloader.findPath(imageId!);
  return io.File(path!);
}

Future<DriveApi> getDriveApi() async {
  final googleSignIn = GoogleSignIn(scopes: [DriveApi.driveScope]);
  final GoogleSignInAccount? account = await googleSignIn.signIn();
  final authHeaders = await account?.authHeaders;
  final authenticateClient = GoogleAuthClient(authHeaders!);
  return DriveApi(authenticateClient);
}
