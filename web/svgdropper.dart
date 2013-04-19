import 'dart:html';

class Test {
  ImageElement toolbar_selected_element = null;
  CanvasElement canvas;
  var loaded_image_toolbar = false;
  num mouseX = null, mouseY = null;

  void main() {
    canvas = query("#canvas");
    canvas.onClick.listen(canvas_OnClick);

    for (var toolbutton in queryAll('.toolbutton')) {
      toolbutton.onClick.listen(toolbar_button_OnClick);
    }
  }

  void toolbar_button_OnClick(MouseEvent event) {
    toolbar_selected_element = query("#${event.target.id}");
  }

  void canvas_OnClick(MouseEvent event) {
    num x,y;
    var clientBoundingRect = canvas.getBoundingClientRect();
    mouseX = event.clientX - clientBoundingRect.left;
    mouseY = event.clientY - clientBoundingRect.top;
    print("$mouseX,$mouseX");
    window.requestAnimationFrame(draw);
  }

  void draw(num _) {
    CanvasRenderingContext2D context = canvas.context2d;
    context.clearRect(0, 0, canvas.width, canvas.height);
    if(toolbar_selected_element!= null   && mouseX != null && mouseY != null) {
      context.drawImage(toolbar_selected_element, mouseX, mouseY);
    }
  }
}

void main() {
  new Test().main();
}
