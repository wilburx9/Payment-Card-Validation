import 'package:payment_card_validation/my_strings.dart';
import 'package:flutter/material.dart';


class PaymentCard {
  CardType type;
  String number;
  String name;
  int month;
  int year;
  int cvv;

  PaymentCard(
      {this.type, this.number, this.name, this.month, this.year, this.cvv});

  @override
  String toString() {
    return '[Type: $type, Number: $number, Name: $name, Month: $month, Year: $year, CVV: $cvv]';
  }
}

enum CardType {
  Master,
  Visa,
  Verve,
  Discover,
  AmericanExpress,
  DinersClub,
  Jcb,
  Others,
  Invalid
}


class PaymentCardValidator {
  static String validateCVV(String value) {
    if (value.isEmpty) {
      return Strings.fieldReq;
    }

    if (value.length < 3 || value.length > 4) {
      return "CVV is invalid";
    }
    return null;
  }

  static String validateDate(String value) {
    if (value.isEmpty) {
      return Strings.fieldReq;
    }

    int year;
    int month;
    if (value.contains(new RegExp(r'(\/)'))) {
      var split = value.split(new RegExp(r'(\/)'));
      month = int.parse(split[0]);
      year = int.parse(split[1]);
    } else {
      month = int.parse(value.substring(0, (value.length)));
      year = -1;
    }

    if ((month < 1) || (month > 12)) {
      return 'Expiry month is invalid';
    }

    var normalizeY = normalizeYear(year);
    if ((normalizeY < 1) || (normalizeY > 2099)) {
      return 'Expiry year is invalid';
    }

    if (!validExpiryDate(month, year)) {
      return "Card has expired";
    }
    return null;
  }

  static String getEnteredNumLength(String text) {
    String numbers = getCleanedNumber(text);
    return '${numbers.length}/19';
  }

  static bool hasMonthPassed(int year, int month) {
    var now = DateTime.now();
    return hasYearPassed(year) ||
        normalizeYear(year) == now.year && (month < now.month + 1);
  }

  static bool hasYearPassed(int year) {
    int normalizedYear = normalizeYear(year);
    var now = DateTime.now();
    return normalizedYear < now.year;
  }

  // Convert two-digit year to full year if necessary
  static int normalizeYear(int year) {
    if (year < 100 && year >= 0) {
      var now = DateTime.now();
      String currentYear = now.year.toString();
      String prefix = currentYear.substring(0, currentYear.length - 2);
      year = int.parse('$prefix${year.toString().padLeft(2, '0')}');
    }
    return year;
  }

  static bool isNotExpired(int year, int month) {
    return !hasYearPassed(year) && !hasMonthPassed(year, month);
  }

  static bool validExpiryDate(int month, int year) {
    // I am supposed to check for a valid month but I have already done that
    return !(month == null || year == null) && isNotExpired(year, month);
  }

  static List<int> getExpiryDate(String value) {
    var split = value.split(new RegExp(r'(\/)'));
    return [int.parse(split[0]), int.parse(split[1])];
  }

  static String getCleanedNumber(String text) {
    RegExp regExp = new RegExp(r"[^0-9]");
    return text.replaceAll(regExp, '');
  }

  static bool _validCVV(String value) {
    if (value.isEmpty) {
      return false;
    }

    if (value.length < 3 || value.length > 4) {
      return false;
    }
    return true;
  }

  static bool _validCardNumWithLuhnAlgorithm(String value) {
    if (value.isEmpty) {
      return false;
    }

    String input = getCleanedNumber(value);

    int sum = 0;
    int length = input.length;
    for (var i = 0; i < length; i++) {
      // get digits in reverse order
      int digit = int.parse(input[length - i - 1]);

      // every 2nd number multiply with 2
      if (i % 2 == 1) {
        digit *= 2;
      }
      sum += digit > 9 ? (digit - 9) : digit;
    }

    if (sum % 10 == 0) {
      return true;
    }

    return false;
  }

  static List<String> getIssuesWithCard(PaymentCard card) {
    List<String> issues = [];
    if (!_validCardNumWithLuhnAlgorithm(card.number)) {
      issues.add('Card number is not complete or invalid');
    }

    if (!validExpiryDate(card.month, card.year)) {
      issues.add('Expiry date is invalid or expired');
    }

    if(!_validCVV(card.cvv.toString())) {
      issues.add('CVV is incomplete');
    }

    return issues;
  }

  static List<Color> getColorsFrmCardType(CardType cardType) {
    List<Color> colors = [];
    switch (cardType) {
      case CardType.Master:
        colors.add(Colors.deepPurple[800]);
        colors.add(Colors.deepPurple[900]);
        break;
      case CardType.Visa:
        colors.add(Colors.grey[300]);
        colors.add(Colors.grey[400]);
        break;
      case CardType.AmericanExpress:
        colors.add(Colors.red[700]);
        colors.add(Colors.red[900]);
        break;
      case CardType.Discover:
        colors.add(Colors.grey[900]);
        colors.add(Colors.grey[800]);
        break;
      case CardType.Verve:
        colors.add(Colors.grey[400]);
        colors.add(Colors.grey[600]);
        break;
      case CardType.Others:
        colors.add(Colors.black);
        colors.add(Colors.grey[900]);
        break;
      case CardType.Invalid:
        colors.add(Colors.brown[400]);
        colors.add(Colors.brown[600]);
        break;
      case CardType.DinersClub:
        colors.add(Colors.grey[100]);
        colors.add(Colors.grey[500]);
        break;
      case CardType.Jcb:
        colors.add(Colors.green[600]);
        colors.add(Colors.green[800]);
        break;
    }
    return colors;
  }

  static Color getTextColorFrmCardType(CardType cardType) {
    Color color;
    switch (cardType) {
      case CardType.Master:
        color = Colors.white;
        break;
      case CardType.Visa:
        color = Colors.grey[850];
        break;
      case CardType.AmericanExpress:
        color = Colors.grey[300];
        break;
      case CardType.Discover:
        color = Colors.white;
        break;
      case CardType.Verve:
        color = Colors.black;
        break;
      case CardType.Others:
        color = Colors.white;
        break;
      case CardType.Invalid:
        color = Colors.white;
        break;
      case CardType.DinersClub:
        color = Colors.black;
        break;
      case CardType.Jcb:
        color = Colors.grey[200];
        break;
    }
    return color;
  }

  static Widget getCardIcon(CardType cardType) {
    String img = "";
    Icon icon;
    switch (cardType) {
      case CardType.Master:
        img = 'mastercard.png';
        break;
      case CardType.Visa:
        img = 'visa.png';
        break;
      case CardType.Verve:
        img = 'verve.png';
        break;
      case CardType.AmericanExpress:
        img = 'american_express.png';
        break;
      case CardType.Discover:
        img = 'discover.png';
        break;
      case CardType.DinersClub:
        img = 'dinners_club.png';
        break;
      case CardType.Jcb:
        img = 'jcb.png';
        break;
      case CardType.Others:
        icon = new Icon(
          Icons.help,
          size: 30.0,
          color: Colors.green,
        );
        break;
      case CardType.Invalid:
        icon = new Icon(
          Icons.warning,
          size: 30.0,
          color: Colors.red,
        );
        break;
    }
    Widget widget;
    if (img.isNotEmpty) {
      widget = new Image.asset(
        'assets/images/$img',
        height: 30.0,
        width: 60.0,
      );
    } else {
      widget = icon;
    }
    return widget;
  }

  static String getObscuredNumberWithSpaces(String string) {
    assert(
    !(string.length < 8),
    'Card Number $string must be more than 8 '
        'characters and above');
    var length = string.length;
    var buffer = new StringBuffer();
    for (int i = 0; i < string.length; i++) {
      if (i < (length - 4)) {
        // The numbers before the last digits is changed to X
        buffer.write('X');
      } else {
        // The last four numbers are spared
        buffer.write(string[i]);
      }
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != string.length) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  static String getObscuredCVV(String cvv) {
    var buffer = new StringBuffer();
    for (var i = 0; i < cvv.length; i++) {
      buffer.write('x');
    }
    return buffer.toString();
  }
}