import java.awt.Rectangle;
import java.awt.Polygon;

public class Blob {
  public int id;
  public String colorName;
  public color c;
  public Polygon polygon;
  public Rectangle boundingBox;

  public Blob(PApplet parent, int id, String colorName, int[] xpoints, int[] ypoints) {
    this.id = id;
    this.colorName = colorName;
    this.c = this.parseColorName(colorName);

    this.polygon = new Polygon(xpoints, ypoints, xpoints.length);
    this.boundingBox = this.polygon.getBounds();
  }

  public void display() {
    noFill();
    stroke(this.c);
    strokeWeight(4);
    beginShape();
    for (int i = 0; i < this.polygon.npoints; i++) {
      vertex(this.polygon.xpoints[i], this.polygon.ypoints[i]);
    }
    endShape();

    PVector center = new PVector(
                                 this.boundingBox.x + this.boundingBox.width / 2,
                                 this.boundingBox.y + this.boundingBox.height / 2);
    stroke(255);
    strokeWeight(3);
    point(center.x, center.y);

    noFill();
    strokeWeight(1);
    rect(this.boundingBox.x, this.boundingBox.y, this.boundingBox.width, this.boundingBox.height);

    text(this.id, this.boundingBox.x - 10, this.boundingBox.y - 10);
  }

  // -------------------------------------------------------------------------

  public color parseColorName(String name) {
    if (name.toLowerCase().equals("red")) return RED;
    else if (name.toLowerCase().equals("green")) return GREEN;
    else if (name.toLowerCase().equals("blue")) return BLUE;
    else return color(255);
  }

}