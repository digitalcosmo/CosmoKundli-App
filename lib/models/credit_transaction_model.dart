class CreditTransaction {
  bool? status;
  String? remainingCredit;
  List<TransactionItem>? list;

  CreditTransaction({this.status, this.remainingCredit, this.list});

  CreditTransaction.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    remainingCredit = json['Remaining_Credit'];
    if (json['list'] != null) {
      list = <TransactionItem>[];
      json['list'].forEach((v) { list!.add(TransactionItem.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() => {
    'status': status, 'Remaining_Credit': remainingCredit,
    'list': list?.map((v) => v.toJson()).toList(),
  };
}

class TransactionItem {
  String? date;
  String? details;
  String? type;
  String? qty;

  TransactionItem({this.date, this.details, this.type, this.qty});

  TransactionItem.fromJson(Map<String, dynamic> json) {
    date = json['Date'];
    details = json['Details'];
    type = json['Type'];
    qty = json['Qty'];
  }

  Map<String, dynamic> toJson() => {'Date': date, 'Details': details, 'Type': type, 'Qty': qty};
}
