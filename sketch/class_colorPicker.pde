public class ColorPicker {
  private class Color { public color c; Color(color c) { this.c = c; } }
  public ArrayList<Color> colors; // datatype <color> is in fact <int>
  public String name;

  ColorPicker(String name) {
    this.name = name;
    this.colors = new ArrayList<Color>();
  }

  // -------------------------------------------------------------------------

  public ColorPicker add(color c) {
    this.colors.add(new Color(c));
    return this;
  }

  public ColorPicker reset() {
    this.colors.clear();
    return this;
  }

  // -------------------------------------------------------------------------

  public float getAvgDistance(color c1) {
    if (this.colors.size() > 0) {
      float avg = 0;
      int counter = 0;
      for (Color c2 : this.colors) {
        float d = this.compare(c1, c2.c);
        avg += d;
      }
      avg /= this.colors.size();
      return avg;
    } else return -1;
  }

  public float getMinDistance(color c1) {
    if (this.colors.size() > 0) {
      float min = 9999999;
      for (Color c2 : this.colors) {
        float d = this.compare(c1, c2.c);
        if (d < min) min = d;
      }
      return min;
    } else return -1;
  }

  public float getMaxDistance(color c1) {
    if (this.colors.size() > 0) {
      float max = 0;
      for (Color c2 : this.colors) {
        float d = this.compare(c1, c2.c);
        if (d > max) max = d;
      }
      return max;
    } else return -1;
  }

  public float compare(color c1, color c2) {
    int currR = (c1 >> 16) & 0xFF;
    int currG = (c1 >> 8) & 0xFF;
    int currB = c1 & 0xFF;
    int currH = int(hue(c1));

    int currR2 = (c2 >> 16) & 0xFF;
    int currG2 = (c2 >> 8) & 0xFF;
    int currB2 = c2 & 0xFF;
    int currH2 = int(hue(c2));

    int distance  = 0;
    distance += sq(currR - currR2);
    distance += sq(currG - currG2);
    distance += sq(currB - currB2);
    distance += sq(currH - currH2);
    return distance;
  }

  public color getAverage() {
    color avg = color(0);
    if (this.colors.size() > 0) {
      avg = this.colors.get(0).c;
      for (Color c : this.colors) {
        avg = lerpColor(c.c, avg, 0.5);
      }
    }
    return avg;
  }

  // -------------------------------------------------------------------------

  public String getName() { return this.name; }
}