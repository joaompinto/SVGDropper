import 'dart:html';
import 'dart:svg';
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
  var canvasBoundingRect = null;
  final List<PlacedImage> placed_images = []; // Placed in the drawboard

  basedir([add_path]) {
    List pieces = window.location.href.split('/');
    pieces.removeLast();
    if(add_path != null)
      pieces.add(add_path);
    return pieces.join('/');
  }

  void main() {

    // Get initial size from css - http://stackoverflow.com/a/16113959/401041
    canvas = query("#canvas");
    canvas.width = int.parse(canvas.getComputedStyle().width.split('px')[0]);
    canvas.height = int.parse(canvas.getComputedStyle().height.split('px')[0]);

    // Cache it to make sure we don't trigger a reflow
    canvasBoundingRect = canvas.getBoundingClientRect();

    queryAll('.toolbutton').forEach((button) =>
        button.onClick.listen(toolbutton_OnClick));
    var x = basedir('blue_bird.svg');

    HttpRequest.getString(basedir("toolbox.txt")).then(load_default_svgs);

    canvas.onClick.listen(canvas_OnClick);
    canvas.onMouseMove.listen(canvas_OnMouseMove);
    canvas.onMouseOut.listen(canvas_OnMouseOut);
  }

  void load_default_svgs(String svgs) {
    for(var svg_name in svgs.split('\n')) {
      HttpRequest.getString(basedir(svg_name)).then(add_svg_to_pallete);
    }
  }

  void add_svg_to_pallete(String svg) {
    SvgElement element = new SvgElement.svg(svg);
    String svg_width = element.attributes['width'];
    String svg_height = element.attributes['height'];
    // Some svgs use "pt" units which are not properly parsed
    svg_width = svg_width.replaceAll("pt", '');
    svg_height = svg_height.replaceAll("pt", '');

    element.attributes['width'] = '50';
    element.attributes['height'] = '50';
    element.attributes['viewBox'] = '0 0 $svg_width $svg_height';
    query("#toolbar").children.add(element);
  }

  void toolbutton_OnClick(MouseEvent event) {
    active_toolbutton = new CanvasElement();
    active_toolbutton.width = 100;
    active_toolbutton.height = 100;
    var options = js.map({ 'ignoreMouse:': true,
      'ignoreAnimation': true,
      'ignoreDimensions': true,
      'scaleWidth': 100,
      'scaleHeight': 100});
    js.context.canvg(active_toolbutton, event.target.src, options);
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
