class FileFormat {
  String name, title, fileLink;
  var timeMillis;

  FileFormat(this.name, this.title, this.fileLink,  this.timeMillis);

  Map<String, dynamic> fileToMap() {
    return {
      'name': this.name,
      'title': this.title,
      'fileLink': this.fileLink,
      'timeMillis': this.timeMillis,
    };
  }
}
