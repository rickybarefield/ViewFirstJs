require.config({
  baseUrl: 'js',
  shim: {
    underscore: {
      exports: '_'
    },
    backbone: {
      deps: ["underscore", "jquery"],
      exports: "Backbone"
    },
    'backbone.localStorage' : {
    	deps: ["underscore", "backbone"],
    	exports: "Backbone-LocalStorage"
    },
    'backbone-relational': {
      deps: ["underscore", "backbone"],
      exports: "Backbone-Relational"
    },
    sinon : {
      exports : "sinon"
    }
  }
});

require(['ViewFirst'], function(ViewFirst) {
	
	new ViewFirst;
});