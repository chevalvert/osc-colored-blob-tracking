/**
 * Dominant Color Sort III (v1.03)
 * GoToLoop (2016-Jan-11)
 *
 * forum.Processing.org/two/discussion/14393/getting-the-dominant-color-of-an-image
 * JavaRevisited.BlogSpot.com/2012/12/how-to-sort-hashmap-java-by-key-and-value.html
 */

import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import java.util.Map;
import java.util.Map.Entry;
import java.util.LinkedHashMap;

color dominantColor(IntList colors) { return dominantColor(colors, 5); }
color dominantColor(IntList colors, int quantity) {
  color[] dominantArr = new color[quantity];
  Map<Integer, Integer> dominantMap = new LinkedHashMap<Integer, Integer>(quantity, 1.0);
  Map<Integer, Integer> map, sortedMap;

  map = countColorsIntoMap(colors);
  sortedMap = sortMapByValues(map);

  dominantMap.clear();
  java.util.Arrays.fill(dominantArr, 0);

  int index = 0;
  for (Entry<Integer, Integer> c : sortedMap.entrySet()) {
    dominantMap.put(dominantArr[index] = c.getKey(), c.getValue());
    if (++index == quantity) break;
  }

  color avg = dominantArr[0];
  for (color c : dominantArr) avg = lerpColor(avg, color(c), 0.5);
  return avg;
}

// -------------------------------------------------------------------------

Map<Integer, Integer> countColorsIntoMap(IntList colors) {
  Map<Integer, Integer> map = new HashMap<Integer, Integer>();

  for (color c : colors) {
    // Integer count = map.get(c &= ~#000000); // c |= #000000
    Integer count = map.get(c |= #000000); // c |= #000000
    map.put(c, count == null? 1 : count + 1);
  }

  return map;
}

<K extends Comparable<K>, V extends Comparable<V>> Map<K, V> sortMapByValues(Map<K, V> map) {
  int len = map.size(), capacity = ceil(len/.75) + 1;
  List<Entry<K, V>> entries = new ArrayList<Entry<K, V>>(map.entrySet());

  Collections.sort(entries, new Comparator<Entry<K, V>>() {
    @ Override public int compare(Entry<K, V> e1, Entry<K, V> e2) {
      int sign = e2.getValue().compareTo(e1.getValue());
      return sign != 0? sign : e1.getKey().compareTo(e2.getKey());
    }
  });

  Map<K, V> sortedMap = new LinkedHashMap<K, V>(capacity);
  for (Entry<K, V> entry : entries)
    sortedMap.put(entry.getKey(), entry.getValue());

  return sortedMap;
}