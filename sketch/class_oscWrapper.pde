import oscP5.*;
import netP5.*;
import java.util.Timer;
import java.util.TimerTask;

public class OSCWrapper {
  private OscP5 oscP5;
  private NetAddress address;
  private Timer timer;

  // -------------------------------------------------------------------------

  public OSCWrapper(PApplet parent) {
    this.oscP5 = new OscP5(parent, 12000);
    this.address = new NetAddress("127.0.0.1", 32000);
  }

  public OSCWrapper(PApplet parent, long consolidateEveryMS) {
    this.oscP5 = new OscP5(parent, 12000);
    this.address = new NetAddress("127.0.0.1", 32000);

    this.timer = new Timer();
    timer.scheduleAtFixedRate(new TimerTask() {
      @Override
      public void run() {
        OSC.consolidate((ArrayList<Blob>) BLOB_DETECTOR.blobList);
      }
    }, consolidateEveryMS, consolidateEveryMS);
  }

  // -------------------------------------------------------------------------

  public OSCWrapper send(Blob.MinifiedBlob blob) {
    OscBundle bundle = new OscBundle();
    OscMessage message = new OscMessage("/blob");

    message.add(blob.id);
    message.add(blob.colorName);
    message.add(blob.polygon.npoints);
    message.add(blob.polygon.xpoints);
    message.add(blob.polygon.ypoints);


    bundle.add(message);
    bundle.setTimetag(bundle.now() + 10000);
    this.oscP5.send(bundle, this.address);
    return this;
  }

  public OSCWrapper remove(int index) {
    OscBundle bundle = new OscBundle();
    OscMessage message = new OscMessage("/remove");

    message.add(index);

    bundle.add(message);
    bundle.setTimetag(bundle.now() + 10000);
    this.oscP5.send(bundle, this.address);
    return this;
  }

  public OSCWrapper consolidate(ArrayList<Blob> blobs) {
    if (blobs != null) {
      OscBundle bundle = new OscBundle();
      OscMessage message = new OscMessage("/consolidate");

      message.add(blobs.size());
      for (Blob b : blobs) message.add(b.id);

      bundle.add(message);
      bundle.setTimetag(bundle.now() + 10000);
      this.oscP5.send(bundle, this.address);
    }
    return this;
  }

}