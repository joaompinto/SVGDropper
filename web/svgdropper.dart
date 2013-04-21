import 'dart:html';
import 'package:js/js.dart' as js;

class PlacedImage {
  CanvasElement img;
  num x, y;
  PlacedImage(this.img, this.x, this.y);
}

class SVGDropper {
  var active_toolbutton = null;
  var prev_active_toolbutton = null; // previous toolbutton
  CanvasElement canvas;
  num mouseX = null, mouseY = null;
  Rect canvasBoundingRect = null;
  final List<PlacedImage> placed_images = []; // Placed in the drawboard

  void main() {

    // Get initial size from css - http://stackoverflow.com/a/16113959/401041
    canvas = query("#canvas");
    canvas.width = int.parse(canvas.getComputedStyle().width.split('px')[0]);
    canvas.height = int.parse(canvas.getComputedStyle().height.split('px')[0]);

    // Cache it to make sure we don't trigger a reflow
    canvasBoundingRect = canvas.getBoundingClientRect();

    for (var toolbutton in queryAll('.toolbutton')) {
      toolbutton.onClick.listen(toolbutton_OnClick);

    }
    canvas.onClick.listen(canvas_OnClick);
    canvas.onMouseMove.listen(canvas_OnMouseMove);
    canvas.onMouseOut.listen(canvas_OnMouseOut);
  }

  void toolbutton_OnClick(MouseEvent event) {
    //active_toolbutton = query("#${event.target.id}").clone(true);
    //print('${event.target.href}');
    active_toolbutton = new CanvasElement();
    active_toolbutton.width = 100;
    active_toolbutton.height = 100;
    var options = js.map({ 'ignoreMouse:': true,
      'ignoreAnimation': true,
      'ignoreDimensions': true,
      'scaleWidth': 100,
      'scaleHeight': 100});
    js.context.canvg(active_toolbutton, event.target.src, options);

    //active_toolbutton
  }

  void canvas_OnMouseMove(MouseEvent event) {
    mouseX = event.clientX - canvasBoundingRect.left;
    mouseY = event.clientY - canvasBoundingRect.top;
    window.requestAnimationFrame(draw);
  }

  void canvas_OnMouseOut(MouseEvent event) {
    active_toolbutton = null;
    window.requestAnimationFrame(draw);
  }


  void canvas_OnClick(MouseEvent event) {
    if(active_toolbutton == null)
      active_toolbutton = prev_active_toolbutton;
    if(active_toolbutton != null) {
      final placeX = mouseX - active_toolbutton.width/2;
      final placeY = mouseY - active_toolbutton.height/2;
      placed_images.add(new PlacedImage(active_toolbutton, placeX, placeY));
      prev_active_toolbutton = active_toolbutton;
      window.requestAnimationFrame(draw);
    }
  }

  void draw(num _) {
    final CanvasRenderingContext2D context = canvas.context2d;
    context.clearRect(0, 0, canvas.width, canvas.height);

    // Draw all images already placed in the board
    placed_images.forEach((e) =>
      context.drawImage(e.img, e.x, e.y)
    );

    if(active_toolbutton != null) {
      final placeX = mouseX - active_toolbutton.width/2;
      final placeY = mouseY - active_toolbutton.height/2;
      if(mouseX != null && mouseY != null) {
        context.drawImage(active_toolbutton, placeX, placeY);
      }
    }
  }
}

void main() {
  new SVGDropper().main();
}
