class Ownership {
  const Ownership({
    required this.certificateNo,
    required this.artworkTitle,
    required this.artistName,
    required this.acquiredDate,
    required this.qrIssued,
  });

  final String certificateNo;
  final String artworkTitle;
  final String artistName;
  final String acquiredDate;
  final bool qrIssued;

  factory Ownership.fromJson(Map<String, dynamic> json) {
    return Ownership(
      certificateNo: json['certificateNo'] as String? ?? '',
      artworkTitle: json['artworkTitle'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
      acquiredDate: json['acquiredDate'] as String? ?? '',
      qrIssued: json['qrIssued'] as bool? ?? false,
    );
  }
}

class Certificate {
  const Certificate({
    required this.certificateNo,
    required this.artworkTitle,
    required this.artistName,
    required this.ownerName,
    required this.issuedDate,
    required this.verified,
    required this.note,
  });

  final String certificateNo;
  final String artworkTitle;
  final String artistName;
  final String ownerName;
  final String issuedDate;
  final bool verified;
  final String note;

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      certificateNo: json['certificateNo'] as String? ?? '',
      artworkTitle: json['artworkTitle'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? '',
      issuedDate: json['issuedDate'] as String? ?? '',
      verified: json['verified'] as bool? ?? false,
      note: json['note'] as String? ?? '',
    );
  }
}
