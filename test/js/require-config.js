require.config({
  baseUrl: 'js',
  paths: {
    jquery: '//cdnjs.cloudflare.com/ajax/libs/jquery/2.1.1/jquery',
    json: '//cdnjs.cloudflare.com/ajax/libs/requirejs-plugins/1.0.3/json',
    threejs: '//cdnjs.cloudflare.com/ajax/libs/three.js/r68/three',
    text: '//cdnjs.cloudflare.com/ajax/libs/require-text/2.0.12/text',
    data: '../data',
    trackball: 'http://threejs.org/examples/js/controls/TrackballControls'
  },
  shim: {
    threejs: {
      exports: 'THREE'
    },
    trackball: {
      deps: ['threejs']
    }
  }
});
