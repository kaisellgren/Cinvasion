library cinvasion.server;

import 'dart:async';
import 'dart:io';

import 'package:http_server/http_server.dart';

class Server {
  Server() {
    HttpServer.bind('0.0.0.0', 80).then((server) {
      var vd = new VirtualDirectory('web/');
      vd.allowDirectoryListing = true;
      vd.followLinks = true;
      vd.jailRoot = false;
      vd.serve(server);

      print('> Server started.');
    });
  }
}