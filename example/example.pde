import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress serverLocation;

color RED = color(255, 0, 0);
color GREEN = color(0, 255, 0);
color BLUE = color(0, 0, 255);

BlobsManager blobs;

void settings() {
  size(800, 600);
}

void setup() {
  oscP5 = new OscP5(this, 32000);
  serverLocation = new NetAddress("127.0.0.1", 12000);
  blobs = new BlobsManager();
}

void draw() {
  surface.setTitle(int(frameRate) + "fps" + " ("+ blobs.blobs.size() +")");

  background(0);
  blobs.display();
}

public void oscEvent(OscMessage message) {
  if (message.checkAddrPattern("/blob")) {
    int id = message.get(0).intValue();
    String colorName = message.get(1).stringValue();

    int npoints = message.get(2).intValue();
    int[] xpoints = new int[npoints];
    int[] ypoints = new int[npoints];

    for (int i = 0; i < npoints; i++) {
      xpoints[i] = message.get(i + 3).intValue();
      ypoints[i] = message.get(i + 3 + npoints).intValue();
    }

    // blobs.add(new Blob(id, colorName, xpoints, ypoints));
    Blob blob = new Blob(this, id, colorName, xpoints, ypoints);
    blobs.add(id, blob);
  } else if (message.checkAddrPattern("/remove")) {
    int id = message.get(0).intValue();
    blobs.remove(id);
  }
}