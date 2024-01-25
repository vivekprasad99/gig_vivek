class LoggingData {
  String? event;
  String? action;
  String? pageName;
  String? sectionName;
  Map<String, String>? otherProperty;

  LoggingData(
      {this.event,
      this.action,
      this.pageName,
      this.sectionName,
      this.otherProperty});
}
