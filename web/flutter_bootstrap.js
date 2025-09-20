// Flutter Bootstrap Configuration
window.flutterConfiguration = {
  renderer: "html",
  useColorEmoji: false,
  debugShowCheckedModeBanner: false
};

// Override any CanvasKit attempts
if (typeof window.flutterConfiguration === 'undefined') {
  window.flutterConfiguration = {};
}
window.flutterConfiguration.renderer = "html";
