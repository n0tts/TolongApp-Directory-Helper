class ListUtils {
  static String parseListToString(List<dynamic> items) {
    String positions = '';

    items.forEach((item) {
      positions +=
          item[0].toString().toUpperCase() + item.toString().substring(1);
      if (items.length > 1 && items.indexOf(item) != items.length - 1) {
        positions += ', ';
      }
    });

    return positions;
  }
}
