import 'package:json_annotation/json_annotation.dart';

part 'crypto.g.dart';

@JsonSerializable()
class Crypto {
  final String? coin;
  final String? wallet;
  final String? network;

  const Crypto({this.coin, this.wallet, this.network});

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return _$CryptoFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CryptoToJson(this);

  Crypto copyWith({
    String? coin,
    String? wallet,
    String? network,
  }) {
    return Crypto(
      coin: coin ?? this.coin,
      wallet: wallet ?? this.wallet,
      network: network ?? this.network,
    );
  }

  @override
  List<Object?> get props => [coin, wallet, network];
}
