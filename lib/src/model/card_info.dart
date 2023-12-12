class CardInfo {
  final String number;
  final String cvv;
  final String expiry;

  CardInfo({
    required this.number,
    required this.cvv,
    required this.expiry,
  });

  bool isValid() => number.isNotEmpty && number.length == 16;

  @override
  String toString() {
    return 'Card Info\nnumber: $number\ncvv: $cvv\nexpiry: $expiry';
  }

  @override
  bool operator ==(covariant CardInfo other) {
    if (identical(this, other)) return true;

    return other.number == number && other.cvv == cvv && other.expiry == expiry;
  }

  @override
  int get hashCode => number.hashCode ^ cvv.hashCode ^ expiry.hashCode;
}
