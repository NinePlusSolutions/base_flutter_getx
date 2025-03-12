class Regex {
  static bool isEmail(String email) {
    RegExp regExp = new RegExp(r'\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*');
    return regExp.hasMatch(email);
  }

  static bool isPhoneNumber(String phone) {
    RegExp regExp = new RegExp(r'^(?:[+0]9)?[0-9]{10}$');
    return regExp.hasMatch(phone);
  }

  static bool inCorrectPass(String password) {
    RegExp regExp = new RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return regExp.hasMatch(password);
  }
}
