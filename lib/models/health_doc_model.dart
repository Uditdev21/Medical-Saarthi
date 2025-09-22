class healthDocModel {
  String? fileUrl;
  String? aiContext;
  String? summary;
  String? sId;

  healthDocModel({this.fileUrl, this.aiContext, this.summary, this.sId});

  healthDocModel.fromJson(Map<String, dynamic> json) {
    fileUrl = json['file_url'];
    aiContext = json['ai_context'];
    summary = json['summary'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['file_url'] = this.fileUrl;
    data['ai_context'] = this.aiContext;
    data['summary'] = this.summary;
    data['_id'] = this.sId;
    return data;
  }
}
