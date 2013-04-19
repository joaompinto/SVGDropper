import 'dart:html';

class Test {
  ImageElement toolbar_selected_element = null;
  CanvasElement canvas;
  num mouseX = null, mouseY = null;

  void main() {
    canvas = query("#canvas");
    canvas.width = 1200;
    canvas.height = 800;
    canvas.onClick.listen(canvas_OnClick);

    for (var toolbutton in queryAll('.toolbutton')) {
      toolbutton.onClick.listen((e) => toolbar_selected_element = query("#${e.target.id}"));
    }
  }

  void canvas_OnClick(MouseEvent event) {
    num x,y;
    var clientBoundingRect = canvas.getBoundingClientRect();
    mouseX = event.clientX - clientBoundingRect.left;
    mouseY = event.clientY - clientBoundingRect.top;
    window.requestAnimationFrame(draw);
  }

  void draw(num _) {
    CanvasRenderingContext2D context = canvas.context2d;
    num placeX = mouseX - toolbar_selected_element.width/2;
    num placeY = mouseY - toolbar_selected_element.height/2;
    context.clearRect(0, 0, canvas.width, canvas.height);
    if(toolbar_selected_element!= null   && mouseX != null && mouseY != null) {
      context.drawImageScaled(toolbar_selected_element, placeX, placeY, toolbar_selected_element.width, toolbar_selected_element.height);
    }
  }
}

void main() {
  new Test().main();
}
