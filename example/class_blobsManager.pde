public class BlobsManager {
  private ArrayList<Blob> blobs;

  public BlobsManager() {
    this.blobs = new ArrayList<Blob>();
  }

  // -------------------------------------------------------------------------

  public void display() {
    for (int i = this.blobs.size() - 1; i >= 0; i--) {
      Blob b = this.blobs.get(i);
      if (b != null) b.display();
    }
  }

  public void add(int index, Blob b) {
    if (index >= this.blobs.size()) this.blobs.add(b);
    else this.blobs.set(index, b);
  }

  public void clear() {
    this.blobs.clear();
  }

  public void remove(int index) {
    if (index < this.blobs.size()) this.blobs.remove(index);
    // this.blobs.remove(index);
  }

}