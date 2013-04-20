import 'dart:html';

class PlacedImage {
  ImageElement img;
  num x, y;
  PlacedImage(this.img, this.x, this.y);
}

class SVGDropper {
  ImageElement active_toolbutton = null;
  ImageElement prev_active_toolbutton = null; // previous toolbutton
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
    // We clone the elements because we want to store it and we may need to
    // resize the clone
    active_toolbutton = query("#${event.target.id}").clone(false);

    active_toolbutton.width = 100;
    active_toolbutton.height = 100;
  }

  void canvas_OnMouseMove(MouseEvent event) {
    // We clone the elements because we want to store it and we may need to
    // resize the clone
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
      context.drawImageScaled(e.img, e.x, e.y,
          e.img.width, e.img.height)
    );
    if(active_toolbutton != null) {
      final placeX = mouseX - active_toolbutton.width/2;
      final placeY = mouseY - active_toolbutton.height/2;
      if(mouseX != null && mouseY != null) {
        context.drawImageScaled(active_toolbutton, placeX, placeY,
            active_toolbutton.width, active_toolbutton.height);
      }
    }
  }
}

void main() {
  new SVGDropper().main();
}
