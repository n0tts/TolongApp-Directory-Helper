class TimeFormatter {
  TimeFormatter();

  String getFormattedTime(int hour, int minute) {
    String clock = hour >= 12 ? ' PM' : ' AM';
    String addZeroFront = minute <= 9 ? '0' : '';
    String formattedHour = '';
    if (hour > 12) {
      formattedHour = (hour - 12).toString();
    } else if (hour < 12) {
      formattedHour = hour.toString();
    } else {
      formattedHour = hour.toString();
    }

    if (hour == 0) {
      formattedHour = '12';
    }

    return (formattedHour.length == 1 ? '0' : '') +
        formattedHour +
        ':' +
        addZeroFront +
        minute.toString() +
        clock;
  }

  String getWeekdayString(int weekday) {
    switch (weekday) {
      case 1:
        return 'MON';
        break;
      case 2:
        return 'TUES';
        break;
      case 3:
        return 'WED';
        break;
      case 4:
        return 'THURS';
        break;
      case 5:
        return 'FRI';
        break;
      case 6:
        return 'SAT';
        break;
      case 7:
        return 'SUN';
        break;
      default:
        return '-';
    }
  }

  String getMonthString(int month) {
    switch (month) {
      case 1:
        return 'JAN';
        break;
      case 2:
        return 'FEB';
        break;
      case 3:
        return 'MAR';
        break;
      case 4:
        return 'APR';
        break;
      case 5:
        return 'MAY';
        break;
      case 6:
        return 'JUN';
        break;
      case 7:
        return 'JUL';
        break;
      case 8:
        return 'AUG';
        break;
      case 9:
        return 'SEP';
        break;
      case 10:
        return 'NOV';
        break;
      case 11:
        return 'OCT';
        break;
      case 12:
        return 'DEC';
        break;
      default:
    }
  }
}

TimeFormatter timeFormatter = new TimeFormatter();
