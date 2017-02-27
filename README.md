<h1 align="center">osc-colored-blob-tracking</h1>
<h3 align="center">blob tracking w/ color support via OSC</h3>
<div align="center">
  <!-- License -->
  <a href="https://raw.githubusercontent.com/arnaudjuracek/xy/master/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square" alt="License" />
  </a>
</div>

## Installation

Either build the sources from `sketch/` or download the latest [release](https://github.com/chevalvert/osc-co:ored-blob-tracking/releases).

<!-- ## Configuration
![preview.png](preview.png) -->

## Usage

Launch the _.app_ then listen to the port `32000`. 

When a blob is tracked, an OSC message is sent on `/blob`, with the following data structure :

|position|datatype|description|
|:-:|---|---|
|0|`int`|`blob.ID`
|1|`String`|`blob.color_name`
|2|`int`|`blob.polygon.npoints`
|3 to `npoints`|`float`|`blob.polygon.xpoints[]`
|`npoints + 4` to `npoints * 2 + 4`|`float`|`blob.polygon.ypoints[]`

When a blob is lost, an OSC message is sent on `/remove` with the following data structure :

|position|datatype|description|
|:-:|---|---|
|0|`int`|`blob.ID`

In order to consolidate serv/client syncing, an OSC message is sent every X millis (see [class_oscWrapper:26](https://github.com/chevalvert/osc-colored-blob-tracking/blob/master/sketch/class_oscWrapper.pde#L26)) on `/consolidate` with the following data structure : 

|position|datatype|description|
|:-:|---|---|
|0|`int`|`blobs.length`
|1 to `blobs.length`|`int`|`blobs_id[]`

#### Example with Processing
```processing
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress serverLocation;

void setup() {
  oscP5 = new OscP5(this, 32000);
  serverLocation = new NetAddress("127.0.0.1", 12000);
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

    // Blob blob = new Blob(this, id, colorName, xpoints, ypoints);

  } else if (message.checkAddrPattern("/remove")) {
    int id = message.get(0).intValue();
    // blobs.remove(id);
  }
}
```

## Development
#### Requirements
###### Hardware
- Webcam

###### Libraries
- [ControlP5](http://www.sojamo.de/libraries/controlP5/)
- [OpenCV for Processing](https://github.com/atduskgreg/opencv-processing)
- [Signal Filter](https://github.com/SableRaf/signalfilter)

#### Ressources

- [Persistence algorithm, Daniel Shifmann](http://shiffman.net/2011/04/26/opencv-matching-faces-over-time/)
- [OpenCV Image filtering, Jordi Tost](https://github.com/jorditost/ImageFiltering/tree/master/ImageFilteringWithBlobPersistence)

## License

[MIT](https://tldrlegal.com/license/mit-license).
