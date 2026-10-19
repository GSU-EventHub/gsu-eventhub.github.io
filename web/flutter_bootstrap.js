{{flutter_js}}
{{flutter_build_config}}
// Keep the renderer and any fallback-font requests on this origin, including offline.
_flutter.loader.load({config: {
  canvasKitBaseUrl: 'canvaskit/',
  fontFallbackBaseUrl: 'assets/fonts/fallback/'
}});
