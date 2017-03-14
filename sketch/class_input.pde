public class Input {
  private PApplet parent;
	private Rectangle clip;
  private PImage src;

  public Capture stream;
  public int id;

	// -------------------------------------------------------------------------

	public Input(PApplet parent, Capture stream, int captureID) {
		this.parent = parent;
    this.id = captureID;

		this.stream = stream;
		this.stream.start();

    this.src = new PImage(this.stream.width, this.stream.height);
		this.clip = new Rectangle(0, 0, this.stream.width, this.stream.height);
	}

	// -------------------------------------------------------------------------

	private PImage update() {
		if (this.stream.available()) this.stream.read();
    this.src = this.stream;
    return this.src;
	}

	// -------------------------------------------------------------------------

	public int getWidth() { return this.src.width; }
  public int getHeight() { return this.src.height; }

  public void loadPixels() { this.src.loadPixels(); }
  public color get(int index) { return this.src.pixels[index]; }

  public PImage getSrc() { return this.src; }
  public PImage getClippedImage() {
		Rectangle c = this.getAbsoluteClip();
		return this.update().get(c.x, c.y, c.width-c.x, c.height-c.y);
	}

	public Rectangle getClip() { return this.clip; }
	public Rectangle getAbsoluteClip() {
		Rectangle c = this.getClip();
		return new Rectangle(
			min(c.x, c.width + c.x),
			min(c.y, c.height + c.y),
			max(c.x, c.x + c.width),
			max(c.y, c.y + c.height)
		);
	}

	// -------------------------------------------------------------------------

	public void drawClip() {
		pushStyle();
		noFill();
		strokeWeight(4);
		stroke(250, 0, 100);

		Rectangle c = this.getClip();
		rect(c.x, c.y, c.width, c.height);

		popStyle();
	}
}