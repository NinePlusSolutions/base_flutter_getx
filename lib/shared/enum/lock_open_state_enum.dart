import 'package:json_annotation/json_annotation.dart';

enum LockOpenState {
  @JsonValue(0)
  locked,

  @JsonValue(1)
  unlocked,

  @JsonValue(2)
  unknow,
}

extension LockOpenStateExtension on LockOpenState {
  int get value {
    switch (this) {
      case LockOpenState.locked:
        return 0;
      case LockOpenState.unlocked:
        return 1;
      case LockOpenState.unknow:
        return 2;
    }
  }
}
