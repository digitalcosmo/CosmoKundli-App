class CreditTransaction {
  bool? status;
  String? remainingCredit;
  List<TransactionList>? list;

  CreditTransaction({this.status, this.remainingCredit, this.list});

  CreditTransaction.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    remainingCredit = json['Remaining_Credit'];
    if (json['list'] != null) {
      list = <TransactionList>[];
      json['list'].forEach((v) {
        list!.add(new TransactionList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['Remaining_Credit'] = this.remainingCredit;
    if (this.list != null) {
      data['list'] = this.list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TransactionList {
  String? date;
  String? details;
  String? type;
  String? qty;

  TransactionList({this.date, this.details, this.type, this.qty});

  TransactionList.fromJson(Map<String, dynamic> json) {
    date = json['Date'];
    details = json['Details'];
    type = json['Type'];
    qty = json['Qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Date'] = this.date;
    data['Details'] = this.details;
    data['Type'] = this.type;
    data['Qty'] = this.qty;
    return data;
  }
}
