import java.awt.Polygon;

public class Blob {
	private PApplet parent;
	public Contour contour;
  public Polygon polygon;
  private SignalFilter filter;

  public boolean available;
  public boolean delete, hover = false;
  public String color_name = "unknown";
  public color detected_color = color(255);

  private int initTimer = 15;
  public int timer;
  public int id;

  private PVector position, p_position, size, p_size;

  public Blob(PApplet parent, int id, Contour c) {
    this.parent = parent;
    this.id = id;
    this.contour = new Contour(parent, c.pointMat);
    this.polygon = this.computePolygon(c);

    this.available = true;
    this.delete = false;
    this.timer = initTimer;

    this.position = this.computePosition();
    this.p_position = new PVector(-999, -999);

    this.size = this.computeSize();
    this.p_size = this.size;
  }

	// -------------------------------------------------------------------------

  public void display() { this.display(-1); }
  public void display(int id) {
    Rectangle r = this.getBoundingBox();
    color c = this.getColor();

    // contour
    noFill();
    stroke(0);
    strokeWeight(5);
    beginShape();
    for (PVector point : this.contour.getPolygonApproximation().getPoints()) {
      vertex(point.x, point.y);
    }
    endShape();

    // polygon
    noFill();
    stroke(255);
    strokeWeight(2);
    beginShape();
    for (int i = 0; i < this.polygon.npoints; i++) {
      vertex(this.polygon.xpoints[i], this.polygon.ypoints[i]);
    }
    endShape();

    // // movement
    // stroke(250, 0, 100);
    // strokeWeight(10);
    // point(this.position.x, this.position.y);
    // strokeWeight(4);
    // line(this.p_position.x, this.p_position.y, this.position.x, this.position.y);

    if (this.hover) {
      // bounding box
      noFill();
      stroke(c);
      strokeWeight(10);
      rect(r.x, r.y, r.width, r.height);

      // text
      if (id >= 0) {
        fill(255);
        textSize(14);
        text("["+ this.getColorName() +"] " + id + " (" + this.id + ")", r.x+6, r.y+18);
      // text(this.getColorName(), r.x+6, r.y+18);
      }
    }
  }

	// -------------------------------------------------------------------------

  public void update(Contour newC) {
    this.contour = new Contour(parent, newC.pointMat);
    this.polygon = this.computePolygon(newC);
    this.p_position = this.position;
    this.position = this.computePosition();

    this.p_size = this.size;
    this.size = this.computeSize();
  }

  public void countDown() { this.timer--; }
  public boolean dead() { return (this.timer < 0); }

  public boolean checkHover(float x, float y) {
    Rectangle r = this.getBoundingBox();
    return this.hover = (
                         x >= r.x &&
                         x <= r.x + r.width &&
                         y >= r.y &&
                         y <= r.y + r.height);
  }

	// -------------------------------------------------------------------------

	public PVector computePosition() {
		Rectangle r = this.getBoundingBox();
		return new PVector( r.x + r.width * 0.5, r.y + r.height * 0.5, 0);
	}

	public PVector computeSize() {
		Rectangle r = this.getBoundingBox();
		return new PVector(r.width, r.height);
	}

  // compute the color of the Blob by taking the avarage of
  // the 5 dominant color contained by the Blob's polygon
  public color computeColor(PImage input) {
    Rectangle r = this.getBoundingBox();
    Polygon polygon = this.getPolygon();
    IntList colors = new IntList();

    int startX = max(0, int(r.x));
    int startY = max(0, int(r.y));
    int endX = min(int(r.x + r.width), input.width - 1);
    int endY = min(int(r.y + r.height), input.height -1);
    for (int x = startX; x < endX; x++) {
      for (int y = startY; y < endY; y++) {
        if (polygon.contains(x, y)) {
          int index = x + y * input.width;
          color c = input.pixels[index];
          colors.append(c);
        }
      }
    }

    if (colors.size() > 0) {
      color computed = dominantColor(colors, 3);
      this.color_name = this.computeColorName(computed);
      this.detected_color = lerpColor(this.detected_color, computed, 0.3);
      return computed;
    } else return -1;
  }

  public String computeColorName(color c) {
    String computedName = "unknown";

    float min = 999999;
    for (ColorPicker cp : PICKERS) {
      float d = cp.getMinDistance(c);
      if (d != -1 && d < min) {
        min = d;
        computedName = cp.getName();
      }
    }

    return computedName;
    // return
    //         computedName + "\n" +
    //         "\n" +
    //         "R: " + int(PICKERS.get(0).getMinDistance(c)) + "\n" +
    //         "G: " + int(PICKERS.get(1).getMinDistance(c)) + "\n" +
    //         "B: " + int(PICKERS.get(2).getMinDistance(c));
  }

  private Polygon computePolygon(Contour contour) {
    ArrayList<PVector> points = contour.getPolygonApproximation().getPoints();
    int npoints = points.size() + 1;
    int[] xpoints = new int[npoints];
    int[] ypoints = new int[npoints];

    for (int i = 0; i < npoints - 1; i++) {
      PVector p = points.get(i);
      xpoints[i] = int(p.x);
      ypoints[i] = int(p.y);
    }

    // force close the polygon
    xpoints[npoints - 1] = int(points.get(0).x);
    ypoints[npoints - 1] = int(points.get(0).y);

    return new Polygon(xpoints, ypoints, npoints);
  }

  // -------------------------------------------------------------------------

  public PVector getPosition() { return this.position; }
  public PVector getPrevPosition() { return this.p_position; }
  public float getDeltaPosition() { return this.position.dist(this.p_position); }

  public Rectangle getBoundingBox() { return this.contour.getBoundingBox(); }
  public Polygon getPolygon() { return this.polygon; }

  public PVector getSize() { return this.size; }
  public PVector getPrevSize() { return this.p_size; }
  public float getDeltaSize() { return this.size.dist(this.p_size); }

  public float getDelta() { return this.getDeltaSize() + this.getDeltaPosition(); }
  public color getColor() { return this.detected_color; }
  public String getColorName() { return this.color_name; }

  // -------------------------------------------------------------------------

  public MinifiedBlob minify() {
    return new MinifiedBlob(
                            this.id,
                            this.getColorName(),
                            this.getPolygon()
                            );
  }

  public class MinifiedBlob {
    public int id;
    public String colorName;
    public Rectangle box;
    public Polygon polygon;

    MinifiedBlob(int id, String colorName, Polygon polygon) {
      this.id = id;
      this.colorName = colorName;
      this.polygon = polygon;
    }
  }
}

