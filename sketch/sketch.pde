/**
* Persistence algorithm by Daniel Shifmann:
* http://shiffman.net/2011/04/26/opencv-matching-faces-over-time/
*
* Based on openCV Image filtering by Jordi Tost
* https://github.com/jorditost/ImageFiltering/tree/master/ImageFilteringWithBlobPersistence
*/

// TODO : go full nodejs, because this sketch became ugly AF
import controlP5.*;
import gab.opencv.*;
import java.awt.Rectangle;
import javax.swing.JOptionPane;
import processing.video.*;

// public Input INPUT;
public Input[] INPUTS;
public BlobDetector BLOB_DETECTOR;
public BlobAnalysis BLOB_ANALYSIS;

public ArrayList<ColorPicker> PICKERS;
public OSCWrapper OSC;

public String[] CAPTURES;

public int
  OFFSET_X = 61,
  OFFSET_Y = 10;

public float
  contrast = 1.35,
  filter_cutoff = 3.0,
  filter_beta = 0.007,
  filter_threshold = 10;
public int
  VISIBLE_SNAPSHOT = 0,
  blob_size_min = 5,
  blob_size_max = 50,
  threshold = 75,
  thresholdBlockSize = 489,
  thresholdConstant = 45,
  blobSizeThreshold = 20,
  blurSize = 4;
public boolean
  invert = false,
  show_blobs = false,
  useAdaptiveThreshold = false;
public color
  WHITE = color(255),
  BLUE = color(14, 0, 132),
  RED = color(250, 0, 100);

// -------------------------------------------------------------------------

void settings () {
  size(821, 620);
  PJOGL.profile = 1;
}

void setup() {
  hint(DISABLE_TEXTURE_MIPMAPS);

  CAPTURES = Capture.list();
  INPUTS = new Input[2];

  initControls(0, 0);

  BLOB_DETECTOR = new BlobDetector(this, 400, 600);
  BLOB_ANALYSIS = new BlobAnalysis(this, BLOB_DETECTOR, graph);
  OSC = new OSCWrapper(this, 1000);

  PICKERS = new ArrayList<ColorPicker>();
  PICKERS.add(new ColorPicker("red"));
  PICKERS.add(new ColorPicker("green"));
  PICKERS.add(new ColorPicker("blue"));
  setLock(btn_picker_red, false);
  setLock(btn_picker_green, false);
  setLock(btn_picker_blue, false);

  load();
  // surface.setvisible(false);
}

// -------------------------------------------------------------------------

void draw() {
  background(255);

  if (INPUTS[0] != null || INPUTS[1] != null) {
    PGraphics mergedInputs = createGraphics(400, 600);
    mergedInputs.beginDraw();
    mergedInputs.background(0);
    if (INPUTS[0] != null) mergedInputs.image(INPUTS[0].getClippedImage(), 0, 0);
    if (INPUTS[1] != null) mergedInputs.image(INPUTS[1].getClippedImage(), 0, 300);
    mergedInputs.endDraw();

    BLOB_DETECTOR.detect(mergedInputs.get());
    BLOB_ANALYSIS.update();

    pushMatrix();
    translate(OFFSET_X, OFFSET_Y);
    String frame_name = "";

    switch (VISIBLE_SNAPSHOT) {
      case 0 :
        frame_name = " — [input]";

        image(mergedInputs, 0, 0);
        for (int i = 0; i < INPUTS.length; i++) INPUTS[i].drawClip(i > 0 ? 300 : 0);
        break;
      case 1 :
        frame_name = " — [pre-processed]";
        image(BLOB_DETECTOR.preProcessedImage, 0, 0);
        for (int i = 0; i < INPUTS.length; i++) INPUTS[i].drawClip(i > 0 ? 300 : 0);
        break;
      case 2 :
        frame_name = " — [processed]";
        image(BLOB_DETECTOR.processedImage, 0, 0);
        for (int i = 0; i < INPUTS.length; i++) INPUTS[i].drawClip(i > 0 ? 300 : 0);
        break;
      case 3 :
        frame_name = " — [contours]";
        image(BLOB_DETECTOR.contoursImage, 0, 0);
        for (int i = 0; i < INPUTS.length; i++) INPUTS[i].drawClip(i > 0 ? 300 : 0);
        break;
    }

    if (show_blobs) BLOB_DETECTOR.displayBlobs();
    popMatrix();
    surface.setTitle("osc-colored-blob-tracking — " +int(frameRate)+"fps" + frame_name);
  }

  cp5.draw();
  picking_draw();
}

// -------------------------------------------------------------------------

boolean dragging = false;

void mouseDragged() {
  if (!is_picking_red && !is_picking_green && !is_picking_blue) {
    int x = mouseX - OFFSET_X,
    y = mouseY - OFFSET_Y;

    for (int i = 0; i < INPUTS.length; i++) {
      Input input = INPUTS[i];
      y = y - int(i == 1) * 300;


      if (x > 0 && x < input.getWidth() && y > 0 && y < input.getHeight()) {
        Rectangle c = input.getClip();
        if (!dragging) {
          dragging = true;
          c.x = x;
          c.y = y;
        }
        c.width = x - c.x;
        c.height = y - c.y;
        break;
      }
    }
  }
}

void mouseReleased() {
  dragging = false;
  // for (Input input : INPUTS) input.update();
}

void mousePressed() {
  if (is_picking_red) pick(mouseX, mouseY, PICKERS.get(0));
  if (is_picking_green) pick(mouseX, mouseY, PICKERS.get(1));
  if (is_picking_blue) pick(mouseX, mouseY, PICKERS.get(2));
}

void keyPressed() {
  if (keyCode == LEFT) {
    VISIBLE_SNAPSHOT = (VISIBLE_SNAPSHOT > 0) ? VISIBLE_SNAPSHOT - 1 : 3;
    VISIBLE_SNAPSHOT_toggle.activate(VISIBLE_SNAPSHOT);
  }
  else if (keyCode == RIGHT) VISIBLE_SNAPSHOT_toggle.activate(VISIBLE_SNAPSHOT=++VISIBLE_SNAPSHOT%4);
  else if (key == 's') save();
  else if (key == 'r') reset();
  else if (key == 'l') load();
}

void reset() { setup(); }

void save() {
  cp5.saveProperties(("cp5.properties"));
  println("properties saved.");

  println("saving config.xml");
  XML config = new XML("config");

  // saving color pickers
  for (ColorPicker picker : PICKERS) {
    XML picker_xml = config.addChild("picker");
    picker_xml.setString("name", picker.getName());
    for (ColorPicker.Color c : picker.colors) {
      XML color_xml = picker_xml.addChild("color");
      color_xml.setInt("r", int(red(c.c)));
      color_xml.setInt("g", int(green(c.c)));
      color_xml.setInt("b", int(blue(c.c)));
    }
  }

  // saving inputs clip
  for (Input input : INPUTS) {
    Rectangle clip = input.getClip();
    XML clip_xml = config.addChild("clip");
    clip_xml.setString("name", CAPTURES[input.id]);
    clip_xml.setInt("x", clip.x);
    clip_xml.setInt("y", clip.y);
    clip_xml.setInt("width", clip.width);
    clip_xml.setInt("height", clip.height);
  }

  saveXML(config, "config.xml");
  println("config.xml saved.");
}

void load() {
  if (cp5 != null) {
    try {
      cp5.loadProperties(sketchPath("cp5.properties"));
    } catch(NullPointerException e) {
      println(e);
    }
  }

  try {
    XML config = loadXML("config.xml");

    // loading color pickers
    XML[] pickers_xml = config.getChildren("picker");
    PICKERS.clear();
    for (XML picker_xml : pickers_xml) {
      ColorPicker picker = new ColorPicker(picker_xml.getString("name"));
      XML[] colors_xml = picker_xml.getChildren("color");
      for (XML color_xml : colors_xml) {
        int r = color_xml.getInt("r");
        int g = color_xml.getInt("g");
        int b = color_xml.getInt("b");
        picker.add(color(r, g, b));
      }
      PICKERS.add(picker);
    }

    // loading inputs clip
    for (Input input : INPUTS) {
      if (input != null) {
        XML clip_xml = config.getChild("clip");

        Rectangle clip = input.getClip();
        clip.x = clip_xml.getInt("x");
        clip.y = clip_xml.getInt("y");
        clip.width = clip_xml.getInt("width");
        clip.height = clip_xml.getInt("height");;
      }
    }

    println("config.xml config loaded.");
  } catch (NullPointerException e) {
    println(e);
  }
}

// -------------------------------------------------------------------------

void reset_pick_red() { PICKERS.get(0).reset(); }
void reset_pick_green() { PICKERS.get(1).reset(); }
void reset_pick_blue() { PICKERS.get(2).reset(); }

void pick(int x, int y, ColorPicker picker) {
  // accounting for image(INPUT, OFFSET_X, OFFSET_Y);
  x -= OFFSET_X;
  y -= OFFSET_Y;
  for (int i = 0; i < INPUTS.length; i++) {
    Input input = INPUTS[i];
    y = y - int(i == 1) * 300;

    if (x > 0 && y > 0 && x < input.getWidth() && y < input.getHeight()) {
      int index = x + y * input.getWidth();
      input.loadPixels();
      picker.add(input.get(index));
    }
  }
}

void picking_draw() {
  setLock(btn_picker_red, !is_picking_red && (is_picking_green || is_picking_blue));
  setLock(btn_picker_green, !is_picking_green && (is_picking_red || is_picking_blue));
  setLock(btn_picker_blue, !is_picking_blue && (is_picking_red || is_picking_green));

  if (is_picking_red || is_picking_green || is_picking_blue) {
    int x = 21 + 10 + 400 + OFFSET_Y;
    noStroke();
    fill(255, 255 * 0.8);
    rect(x, 0, width - x, height);

    if (is_picking_red) {
      int y = 0;
      for (ColorPicker.Color _c : PICKERS.get(0).colors) {
        fill(_c.c); rect(x, y += 30, width - x, 30);
      }
    }

    if (is_picking_green) {
      int y = 0;
      for (ColorPicker.Color _c : PICKERS.get(1).colors) {
        fill(_c.c); rect(x, y += 30, width - x, 30);
      }
    }

    if (is_picking_blue) {
      int y = 0;
      for (ColorPicker.Color _c : PICKERS.get(2).colors) {
        fill(_c.c); rect(x, y += 30, width - x, 30);
      }
    }
  }

}