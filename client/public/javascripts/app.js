(function() {
  'use strict';

  var globals = typeof window === 'undefined' ? global : window;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};
  var has = ({}).hasOwnProperty;

  var aliases = {};

  var endsWith = function(str, suffix) {
    return str.indexOf(suffix, str.length - suffix.length) !== -1;
  };

  var unalias = function(alias, loaderPath) {
    var start = 0;
    if (loaderPath) {
      if (loaderPath.indexOf('components/' === 0)) {
        start = 'components/'.length;
      }
      if (loaderPath.indexOf('/', start) > 0) {
        loaderPath = loaderPath.substring(start, loaderPath.indexOf('/', start));
      }
    }
    var result = aliases[alias + '/index.js'] || aliases[loaderPath + '/deps/' + alias + '/index.js'];
    if (result) {
      return 'components/' + result.substring(0, result.length - '.js'.length);
    }
    return alias;
  };

  var expand = (function() {
    var reg = /^\.\.?(\/|$)/;
    return function(root, name) {
      var results = [], parts, part;
      parts = (reg.test(name) ? root + '/' + name : name).split('/');
      for (var i = 0, length = parts.length; i < length; i++) {
        part = parts[i];
        if (part === '..') {
          results.pop();
        } else if (part !== '.' && part !== '') {
          results.push(part);
        }
      }
      return results.join('/');
    };
  })();
  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function(name) {
      var absolute = expand(dirname(path), name);
      return globals.require(absolute, path);
    };
  };

  var initModule = function(name, definition) {
    var module = {id: name, exports: {}};
    cache[name] = module;
    definition(module.exports, localRequire(name), module);
    return module.exports;
  };

  var require = function(name, loaderPath) {
    var path = expand(name, '.');
    if (loaderPath == null) loaderPath = '/';
    path = unalias(name, loaderPath);

    if (has.call(cache, path)) return cache[path].exports;
    if (has.call(modules, path)) return initModule(path, modules[path]);

    var dirIndex = expand(path, './index');
    if (has.call(cache, dirIndex)) return cache[dirIndex].exports;
    if (has.call(modules, dirIndex)) return initModule(dirIndex, modules[dirIndex]);

    throw new Error('Cannot find module "' + name + '" from '+ '"' + loaderPath + '"');
  };

  require.alias = function(from, to) {
    aliases[to] = from;
  };

  require.register = require.define = function(bundle, fn) {
    if (typeof bundle === 'object') {
      for (var key in bundle) {
        if (has.call(bundle, key)) {
          modules[key] = bundle[key];
        }
      }
    } else {
      modules[bundle] = fn;
    }
  };

  require.list = function() {
    var result = [];
    for (var item in modules) {
      if (has.call(modules, item)) {
        result.push(item);
      }
    }
    return result;
  };

  require.brunch = true;
  globals.require = require;
})();
require.register("application", function(exports, require, module) {
var AlbumList, AppView, PlaylistList, TracksList, UploadQueue;

AppView = require('./views/app_view');

TracksList = require('./collections/tracks_list');

UploadQueue = require('./collections/upload_queue');

AlbumList = require('./collections/album_list');

PlaylistList = require('./collections/playlists_list');


/*
 * Represent the app, all global variables must be set in it and not in window
 */

module.exports = {
  initialize: function() {
    var Router, mainView;
    window.app = this;
    this.albumCollection = new AlbumList;
    this.baseCollection = new TracksList;
    this.playlistsCollection = new PlaylistList;
    this.playlistsCollection.fetch();
    mainView = new AppView;
    mainView.render();
    Router = require('router');
    this.router = new Router();
    Backbone.history.start();
    this.uploadQueue = new UploadQueue(this.baseCollection);
    if (typeof Object.freeze === 'function') {
      return Object.freeze(this);
    }
  }
};
});

;require.register("collections/album_list", function(exports, require, module) {
var Album, AlbumList,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Album = require('../models/album');

module.exports = AlbumList = (function(_super) {
  __extends(AlbumList, _super);

  function AlbumList() {
    this.upload = __bind(this.upload, this);
    this.fetchAlbumByName = __bind(this.fetchAlbumByName, this);
    return AlbumList.__super__.constructor.apply(this, arguments);
  }

  AlbumList.prototype.url = 'album';

  AlbumList.prototype.model = Album;

  AlbumList.ATTRIBUTES = ['name', 'genre', 'year', 'artist', 'feat'];

  AlbumList.prototype.initialize = function() {
    return this.albumQueue = async.queue(this.upload, 1);
  };

  AlbumList.prototype.fetchAlbumByName = function(albumName, callback) {
    return $.ajax({
      url: "album/name/" + albumName,
      type: 'GET',
      error: (function(_this) {
        return function(error) {
          return callback(error);
        };
      })(this),
      success: (function(_this) {
        return function(album) {
          _this.add(album);
          return callback(null, _this.get(album.id));
        };
      })(this)
    });
  };

  AlbumList.prototype.fetchAlbumById = function(albumId, callback) {
    return $.ajax({
      url: "album/" + albumId,
      type: 'GET',
      error: function(error) {
        return callback(error);
      },
      success: (function(_this) {
        return function(album) {
          _this.add(album);
          return callback(null, _this.get(album.id));
        };
      })(this)
    });
  };

  AlbumList.prototype.createAlbum = function(model, callback) {
    var album;
    album = new Album({
      name: model.get('album'),
      artist: model.get('artist'),
      year: model.get('year'),
      genre: model.get('genre')
    });
    return this.sync('create', album, {
      error: function(res) {
        return console.error(error);
      },
      success: (function(_this) {
        return function(newAlbum) {
          _this.add(newAlbum);
          model.unset('artist', 'silent');
          model.unset('year', 'silent');
          model.unset('genre', 'silent');
          model.set('album', newAlbum.id);
          return callback(null, model);
        };
      })(this)
    });
  };

  AlbumList.prototype.checkRemoteAlbum = function(model, callback) {
    return this.fetchAlbumByName(model.get('album'), (function(_this) {
      return function(err, album) {
        var track;
        if (err) {
          return console.error(err);
        }
        if (album != null ? album.name : void 0) {
          _this.add(album);
          album = _this.get(album.id);
          track = _this.mergeDataAlbum(album, model);
          return callback(null, track);
        } else {
          return _this.createAlbum(model, callback);
        }
      };
    })(this));
  };

  AlbumList.prototype.mergeDataAlbum = function(album, model) {
    AlbumList.ATTRIBUTES.forEach(function(elem) {
      var elemAlbum, elemModel;
      elemModel = model.get(elem);
      elemAlbum = album.get(elem);
      if (elemModel != null) {
        if (elemModel === elemAlbum) {
          return model.unset(elem, 'silent');
        } else if (elemAlbum == null) {
          elemAlbum = elemModel;
          return model.unset(elem, 'silent');
        }
      }
    });
    model.set('album', album.id);
    return model;
  };

  AlbumList.prototype.addTrackToAlbum = function(track, callback) {
    var album, tracks;
    album = this.get(track.get('album'));
    tracks = album.get('tracks');
    tracks.push(track.id);
    return album.sync('update', album, {
      error: function(xhr) {
        return console.error('ERROR: ', xhr);
      }
    });
  };

  AlbumList.prototype.lauchTrackUpload = function(track) {
    return window.app.uploadQueue.trackQueue.push(track);
  };

  AlbumList.prototype.upload = function(model, next) {
    var album, track;
    album = this.findWhere({
      name: model.get('album')
    });
    if (album == null) {
      return this.checkRemoteAlbum(model, (function(_this) {
        return function(err, track) {
          if (err) {
            return console.error(err);
          }
          _this.lauchTrackUpload(track);
          return next();
        };
      })(this));
    } else {
      track = this.mergeDataAlbum(album, model);
      this.lauchTrackUpload(track);
      return next();
    }
  };

  return AlbumList;

})(Backbone.Collection);
});

;require.register("collections/playlist_items", function(exports, require, module) {
var PlaylistItems, Track,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Track = require('../models/track');

module.exports = PlaylistItems = (function(_super) {
  __extends(PlaylistItems, _super);

  function PlaylistItems() {
    return PlaylistItems.__super__.constructor.apply(this, arguments);
  }

  PlaylistItems.prototype.url = 'playlist';

  PlaylistItems.prototype.model = Track;

  return PlaylistItems;

})(Backbone.Collection);
});

;require.register("collections/playlists_list", function(exports, require, module) {
var Playlist, PlaylistList,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Playlist = require('../models/playlist');

module.exports = PlaylistList = (function(_super) {
  __extends(PlaylistList, _super);

  function PlaylistList() {
    return PlaylistList.__super__.constructor.apply(this, arguments);
  }

  PlaylistList.prototype.model = Playlist;

  PlaylistList.prototype.url = 'playlist-list';

  return PlaylistList;

})(Backbone.Collection);
});

;require.register("collections/selection_list", function(exports, require, module) {
var SelectionList, Track,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Track = require('./../models/track');


/*
 * SelectedList is a collection of Track model selected by the user. This Tracks
 * are references to Tracks models contains in the Base collection. So all action
 * on tracks must be handle by this list which update the Base Collection and the
 * view.It's the same collection for all content screen (playlist/all tracks/etc...)
 * which is refresh.
 */

module.exports = SelectionList = (function(_super) {
  __extends(SelectionList, _super);

  function SelectionList() {
    return SelectionList.__super__.constructor.apply(this, arguments);
  }

  SelectionList.prototype.model = Track;

  SelectionList.prototype.url = 'tracks';

  SelectionList.prototype.initialize = function() {
    SelectionList.__super__.initialize.apply(this, arguments);
    return window.selection = this;
  };

  SelectionList.prototype.emptySelection = function() {
    var _results;
    _results = [];
    while (true) {
      if (this.length === 0) {
        break;
      }
      _results.push(this.pop());
    }
    return _results;
  };

  return SelectionList;

})(Backbone.Collection);
});

;require.register("collections/tracks_list", function(exports, require, module) {
var Track, TracksList,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Track = require('./../models/track');


/*
 * Represents a collection of tracks
 * It acts as a cache when instanciate as the baseCollection
 * The base collection holds ALL tracks of the application
 */

module.exports = TracksList = (function(_super) {
  __extends(TracksList, _super);

  function TracksList() {
    return TracksList.__super__.constructor.apply(this, arguments);
  }

  TracksList.prototype.model = Track;

  TracksList.prototype.url = 'track';

  TracksList.prototype.sizeFrameDownload = 5;

  TracksList.prototype.cursorFrameDownload = 0;

  TracksList.prototype.isTrackStored = function(model) {
    var existingTrack;
    existingTrack = this.get(model.get('id'));
    return existingTrack || null;
  };

  TracksList.prototype.getAlbumId = function(model) {
    if (model instanceof Track) {
      return model.get('album');
    } else {
      return model.album;
    }
  };

  TracksList.prototype.setAlbum = function(model, album, options) {
    var allOptions;
    allOptions = _.extend({
      add: true,
      remove: false,
      silent: true
    }, options);
    model = this.set(model, allOptions);
    model.album = album;
    if (!((options != null ? options.silent : void 0) === true)) {
      return this.trigger('add', model);
    }
  };

  TracksList.prototype.newWorker = function(albumId, queue, options) {
    return window.app.albumCollection.fetchAlbumById(albumId, (function(_this) {
      return function(err, album) {
        if (err) {
          return console.error(err);
        }
        return queue.forEach(function(model) {
          return _this.setAlbum(model, album, options);
        });
      };
    })(this));
  };

  TracksList.prototype.add = function(models, options) {
    var album, albumId, model, newQueue, _results;
    if (!_.isArray(models)) {
      models = [models];
    }
    _results = [];
    while (true) {
      if (models.length === 0) {
        break;
      }
      model = models.pop();
      albumId = this.getAlbumId(model);
      album = window.app.albumCollection.get(albumId);
      if (album == null) {
        newQueue = [];
        newQueue.push(model);
        models.forEach((function(_this) {
          return function(modelQueue) {
            if (albumId === _this.getAlbumId(modelQueue)) {
              return newQueue.push(models.splice(models.indexOf(modelQueue), 1)[0]);
            }
          };
        })(this));
        _results.push(this.newWorker(albumId, newQueue, options));
      } else {
        _results.push(this.setAlbum(model, album, options));
      }
    }
    return _results;
  };

  TracksList.prototype.fetch = function() {
    return $.ajax({
      url: "track/" + this.cursorFrameDownload + "/" + this.sizeFrameDownload,
      type: 'GET',
      error: function(xhr) {
        return console.error(xhr);
      },
      success: (function(_this) {
        return function(data) {
          _this.cursorFrameDownload += data.length;
          return _this.add(data);
        };
      })(this)
    });
  };

  return TracksList;

})(Backbone.Collection);
});

;require.register("collections/upload_queue", function(exports, require, module) {
var Track, UploadQueue, app,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Track = require('./../models/track');

app = require('./../application');


/*
 * The UploadQueue is a mix of async.queue & BackboneCollection
 * - Blobs are parsed and added to the queue and the base collection with the flag
 * uploading
 */

module.exports = UploadQueue = (function() {
  UploadQueue.prototype.model = Track;

  UploadQueue.prototype.loaded = 0;

  UploadQueue.ATTRIBUTES = ["title", "artist", "album", "track", "year", "genre", "TLEN"];

  function UploadQueue(baseCollection) {
    this.baseCollection = baseCollection;
    this.completeUpload = __bind(this.completeUpload, this);
    this.uploadTrackWorker = __bind(this.uploadTrackWorker, this);
    _.extend(this, Backbone.Events);
    this.trackQueue = async.queue(this.uploadTrackWorker, 5);
    this.trackQueue.drain = this.completeUpload.bind(this);
  }

  UploadQueue.prototype.addBlobs = function(blobs) {
    var i, nonBlockingLoop;
    i = 0;
    return (nonBlockingLoop = (function(_this) {
      return function() {
        var blob;
        if (!(blob = blobs[i++])) {
          return;
        }
        if (!blob.type.match(/audio\/(mp3|mpeg)/)) {
          _this.trigger('badFileType');
          return console.log(blob.name, ' => BadFileType');
        } else {
          _this.retrieveMetaDataBlob(blob, function(model) {
            var existingModel;
            if ((existingModel = _this.isTrackStored(model) != null)) {
              if (!existingModel.inUploadCycle() || existingModel.isUploaded()) {
                existingModel.set({
                  size: blob.size,
                  lastModification: blob.lastModifiedDate
                });
                existingModel.track = blob;
                existingModel.loaded = 0;
                existingModel.total = blob.size;
                model = existingModel;
                model.markAsConflict();
                _this.trigger('conflict', model);
              } else {
                model = null;
              }
            }
            if (model != null) {
              return _this.add(model);
            }
          });
          return setTimeout(nonBlockingLoop, 2);
        }
      };
    })(this))();
  };

  UploadQueue.prototype.retrieveMetaDataBlob = function(blob, callback) {
    var model, reader;
    model = new Track({
      title: blob.name,
      lastModification: blob.lastModifiedDate,
      size: blob.size,
      docType: blob.type
    });
    model.track = blob;
    model.load = 0;
    model.total = blob.size;
    reader = new FileReader();
    reader.onload = function(event) {
      return ID3.loadTags(blob.name, (function() {
        var tags, _ref;
        tags = ID3.getAllTags(blob.name);
        console.log('TAGS UPLOAD: ', tags);
        model.set({
          title: tags.title != null ? tags.title : model.title,
          artist: tags.artist != null ? tags.artist : void 0,
          album: tags.album != null ? tags.album : void 0,
          trackNb: tags.track != null ? tags.track : void 0,
          year: tags.year != null ? tags.year : void 0,
          genre: tags.genre != null ? tags.genre : void 0,
          time: ((_ref = tags.TLEN) != null ? _ref.data : void 0) != null ? tags.TLEN.data : void 0
        });
        return callback(model);
      }), {
        tags: UploadQueue.ATTRIBUTES,
        dataReader: FileAPIReader(blob)
      });
    };
    reader.readAsArrayBuffer(blob);
    return reader.onabort = function(event) {
      this.trigger('metaDataError');
      return callback(model);
    };
  };

  UploadQueue.prototype.add = function(model) {
    window.pendingOperations.upload++;
    if (!model.isConflict()) {
      model.markAsUploading();
    }
    return window.app.albumCollection.albumQueue.push(model);
  };

  UploadQueue.prototype._processSave = function(model, done) {
    if (!model.isErrored() && !model.isConflict()) {
      model.save(null, {
        success: (function(_this) {
          return function(model) {
            model.track = null;
            window.app.albumCollection.addTrackToAlbum(model);
            model.loaded = model.total;
            model.markAsUploaded();
            return done();
          };
        })(this),
        error: (function(_this) {
          return function(_, err) {
            var body, defaultMessage, e, error, errorKey;
            model.track = null;
            body = (function() {
              try {
                return JSON.parse(err.responseText);
              } catch (_error) {
                e = _error;
                return {
                  msg: null
                };
              }
            })();
            if (err.status === 400 && body.code === 'ESTORAGE') {
              return model.markAsErrored(body);
            } else if (err.status === 0 && err.statusText === 'error') {

            } else {
              model.tries = 1 + (model.tries || 0);
              if (model.tries > 3) {
                defaultMessage = "modal error track upload";
                model.error = t(err.msg || defaultMessage);
                errorKey = err.msg || defaultMessage;
                error = t(errorKey);
                return model.markAsErrored(error);
              } else {
                return _this.trackQueue.push(model);
              }
            }
          };
        })(this)
      });
      return window.app.baseCollection.add(model);
    } else {
      return done();
    }
  };

  UploadQueue.prototype.uploadTrackWorker = function(model, next) {
    if (model.error) {
      return setTimeout(next, 10);
    } else {
      return this._processSave(model, next);
    }
  };

  UploadQueue.prototype.completeUpload = function() {
    window.pendingOperations.upload = 0;
    this.completed = true;
    return this.trigger('upload-complete');
  };

  UploadQueue.prototype.isTrackStored = function(model) {
    return this.baseCollection.isTrackStored(model);
  };

  return UploadQueue;

})();
});

;require.register("initialize", function(exports, require, module) {
var app;

app = require('application');

$(function() {
  var err, locales;
  require('lib/app_helpers');
  this.locale = window.locale;
  delete window.locale;
  this.polyglot = new Polyglot();
  try {
    locales = require("locales/" + this.locale);
  } catch (_error) {
    err = _error;
    locales = require('locales/en');
  }
  this.polyglot.extend(this.locales);
  window.t = this.polyglot.t.bind(this.polyglot);
  window.pendingOperations = {
    upload: 0
  };
  return app.initialize();
});
});

;require.register("lib/app_helpers", function(exports, require, module) {
(function() {
  return (function() {
    var console, dummy, method, methods, _results;
    console = window.console = window.console || {};
    method = void 0;
    dummy = function() {};
    methods = 'assert,count,debug,dir,dirxml,error,exception, group,groupCollapsed,groupEnd,info,log,markTimeline, profile,profileEnd,time,timeEnd,trace,warn'.split(',');
    _results = [];
    while (method = methods.pop()) {
      _results.push(console[method] = console[method] || dummy);
    }
    return _results;
  })();
})();
});

;require.register("lib/base_view", function(exports, require, module) {
var BaseView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = BaseView = (function(_super) {
  __extends(BaseView, _super);

  function BaseView() {
    return BaseView.__super__.constructor.apply(this, arguments);
  }

  BaseView.prototype.template = function() {};

  BaseView.prototype.initialize = function() {};

  BaseView.prototype.getRenderData = function() {
    var _ref;
    return {
      model: (_ref = this.model) != null ? _ref.toJSON() : void 0
    };
  };

  BaseView.prototype.render = function() {
    this.beforeRender();
    this.$el.html(this.template(this.getRenderData()));
    this.afterRender();
    return this;
  };

  BaseView.prototype.beforeRender = function() {};

  BaseView.prototype.afterRender = function() {};

  BaseView.prototype.destroy = function() {
    this.undelegateEvents();
    this.$el.removeData().unbind();
    this.remove();
    return Backbone.View.prototype.remove.call(this);
  };

  return BaseView;

})(Backbone.View);
});

;require.register("lib/view_collection", function(exports, require, module) {
var BaseView, ViewCollection,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('lib/base_view');

module.exports = ViewCollection = (function(_super) {
  __extends(ViewCollection, _super);

  function ViewCollection() {
    this.removeItem = __bind(this.removeItem, this);
    this.addItem = __bind(this.addItem, this);
    return ViewCollection.__super__.constructor.apply(this, arguments);
  }

  ViewCollection.prototype.itemview = null;

  ViewCollection.prototype.views = [];

  ViewCollection.prototype.template = function() {
    return '';
  };

  ViewCollection.prototype.itemViewOptions = function() {};

  ViewCollection.prototype.collectionEl = null;

  ViewCollection.prototype.onChange = function() {
    return this.$el.toggleClass('empty', _.size(this.views) === 0);
  };

  ViewCollection.prototype.appendView = function(view) {
    return this.$collectionEl.append(view.el);
  };

  ViewCollection.prototype.initialize = function() {
    var collectionEl;
    ViewCollection.__super__.initialize.apply(this, arguments);
    this.views = [];
    this.listenTo(this.collection, "reset", this.onReset);
    this.listenTo(this.collection, "add", this.addItem);
    this.listenTo(this.collection, "remove", this.removeItem);
    if (this.collectionEl == null) {
      return collectionEl = el;
    }
  };

  ViewCollection.prototype.render = function() {
    this.views.forEach(function(view) {
      return view.$el.detach();
    });
    return ViewCollection.__super__.render.apply(this, arguments);
  };

  ViewCollection.prototype.afterRender = function() {
    this.$collectionEl = $(this.collectionEl);
    this.views.forEach((function(_this) {
      return function(view) {
        return _this.appendView(view.$el);
      };
    })(this));
    this.onReset(this.collection);
    return this.onChange(this.views);
  };

  ViewCollection.prototype.remove = function() {
    this.onReset([]);
    return ViewCollection.__super__.remove.apply(this, arguments);
  };

  ViewCollection.prototype.onReset = function(newcollection) {
    this.views.forEach(function(view) {
      return view.remove();
    });
    return newcollection.forEach(this.addItem);
  };

  ViewCollection.prototype.addItem = function(model) {
    var options, view;
    options = _.extend({}, {
      model: model
    }, this.itemViewOptions(model));
    view = new this.itemview(options);
    this.views.push(view.render());
    this.appendView(view);
    return this.onChange(this.views);
  };

  ViewCollection.prototype.removeItem = function(model) {
    this.views[model.cid].remove();
    delete this.views[model.cid];
    return this.onChange(this.views);
  };

  ViewCollection.prototype.viewProxy = function(methodName, object) {
    var args, cid, view;
    if (object.cid != null) {
      cid = object.cid;
    } else {
      cid = this.$(object.target).parents('tr').data('cid');
      if (cid == null) {
        cid = this.$(object.currentTarget).data('cid');
      }
    }
    view = _.find(this.views, function(view) {
      return view.model.cid === cid;
    });
    if (view != null) {
      args = [].splice.call(arguments, 1);
      return view[methodName].apply(view, args);
    }
  };

  return ViewCollection;

})(BaseView);
});

;require.register("locales/en", function(exports, require, module) {
module.exports = {
  'upload-files': 'Upload',
  'title': 'Title',
  'artist': 'Artist',
  '#': '#',
  'status': 'status'
};
});

;require.register("locales/fr", function(exports, require, module) {
module.exports = {
  'upload-files': 'Upload',
  'title': 'Title',
  'artist': 'Artist',
  '#': '#',
  'status': 'Status'
};
});

;require.register("models/album", function(exports, require, module) {
var Album,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = Album = (function(_super) {
  __extends(Album, _super);

  function Album() {
    return Album.__super__.constructor.apply(this, arguments);
  }

  Album.prototype.url = 'album';

  Album.prototype.set = function(attr, options) {
    var tracks;
    tracks = this.get('tracks');
    if (tracks != null) {
      tracks.forEach(function(trackId) {
        var track;
        track = window.app.baseCollection.get(trackId);
        return track != null ? track.set(attr) : void 0;
      });
    }
    return Album.__super__.set.call(this, attr, options);
  };

  return Album;

})(Backbone.Model);
});

;require.register("models/content_manager", function(exports, require, module) {
var AllTracksScreen, ContentManager, EditionScreen, PlaylistScreen, SelectionList;

AllTracksScreen = require('../views/content/all_tracks_screen');

PlaylistScreen = require('../views/content/playlist_screen');

EditionScreen = require('../views/content/edition_screen');

SelectionList = require('../collections/selection_list');


/*
 * ContenScreen is the main screen where all tracks are printed. This is a
 * generique class to print any collection of tracks with an optional skeleton.
 * The collection must contain only Track models set int /models/track.coffee.
 * All track must be a reference to a track in @baseCollection which is a sort of
 * cache
 *
 * # Rendering
 * All content must have a method named "render<content name>" which in order:
 * - Call removeCurrentView()
 * - Call renderSkeleton(skeleton, data) (optional)
 * - set @currentcollection
 * - set custom things
 * - Call renderTracks()
 *
 * # Skeleton
 * You can render a Skeleton with the function renderSkeleton(skeleton, data).
 * The argument skeleton must be a jade file. The argument data is all data
 * accessible in the jade file. You can reach theme by the methode "data". The
 * template must contain a div with the id "display-screen" where the track
 * screen will be print
 *
 * # Contents
 * - All tracks: print @baseCollection
 * - Playlist: trigger by the event "content-print-playlist" with the collection
 * in argument
 *
 */

module.exports = ContentManager = (function() {
  ContentManager.prototype.currentView = null;

  ContentManager.prototype.playlistPrinted = null;

  function ContentManager() {
    _.extend(this, Backbone.Events);
    window.app.contentScreen = this;
    this.baseCollection = window.app.baseCollection;
    this.menu = window.app.menuScreen;
    this.selection = new SelectionList;
    this.selection.baseCollection = this.baseCollection;
    this.loadedScreens = [];
    this.listenTo(this.menu, 'content-print-playlist', this.renderPlaylist);
    this.listenTo(this.menu, 'content-print-allTracks', this.renderAllTracks);
  }

  ContentManager.prototype.renderSkeleton = function(skeleton, data) {
    var dataParsed;
    if (data != null) {
      dataParsed = {
        data: data != null ? data.toJSON() : void 0
      };
    }
    return $('#content-screen').append(skeleton(dataParsed));
  };

  ContentManager.prototype.removeCurrentView = function() {
    switch (this.currentView) {
      case 'allTracks':
        return this.removeAllTracks();
      case 'trackEdition':
        return this.removeTrackEdition();
      case 'playlist':
        return this.removePlaylist();
    }
  };

  ContentManager.prototype.renderAllTracks = function() {
    this.removeCurrentView();
    this.currentView = 'allTracks';
    return this.renderTracks();
  };

  ContentManager.prototype.removeAllTracks = function() {
    this.currentView = null;
    return this.removeTracks();
  };

  ContentManager.prototype.renderTracks = function() {
    var allTracks;
    if (this.loadedScreens['allTracks'] != null) {
      this.loadedScreens['allTracks'].attach();
      return;
    }
    allTracks = new AllTracksScreen({
      selection: this.selection,
      baseCollection: this.baseCollection
    });
    this.loadedScreens['allTracks'] = allTracks;
    allTracks.render();
    return this.listenTo(allTracks.menu, 'menu-trackEdition-lauch', this.renderTrackEdition);
  };

  ContentManager.prototype.removeTracks = function() {
    return this.loadedScreens['allTracks'].detach();
  };

  ContentManager.prototype.renderPlaylist = function(playlist) {
    this.removeCurrentView();
    this.currentView = 'playlist';
    playlist.render();
    return this.playlistPrinted = playlist;
  };

  ContentManager.prototype.removePlaylist = function() {
    this.playlistPrinted.remove();
    return this.playlistPrinted = null;
  };

  ContentManager.prototype.renderTrackEdition = function() {
    this.removeCurrentView();
    this.currentView = 'trackEdition';
    return this.renderEdition();
  };

  ContentManager.prototype.renderEdition = function() {
    var editionScreen;
    if (this.loadedScreens['trackEdition'] != null) {
      this.loadedScreens['trackEdition'].attach();
      return;
    }
    editionScreen = new EditionScreen;
    this.loadedScreens['trackEdition'] = editionScreen;
    editionScreen.render();
    return this.listenTo(editionScreen.view, 'edition-end', this.renderAllTracks);
  };

  ContentManager.prototype.removeTrackEdition = function() {
    var _ref, _ref1;
    this.selection.emptySelection();
    if ((_ref = this.loadedScreens['trackEdition']) != null) {
      _ref.detach();
    }
    return (_ref1 = this.loadedScreens['allTracks']) != null ? _ref1.clearSelection() : void 0;
  };

  return ContentManager;

})();
});

;require.register("models/menu_manager", function(exports, require, module) {
var MenuManager, MenuView, Playlist;

MenuView = require('../views/menu/menu_view');

Playlist = require('./playlist');


/*
 * Menu represent the left menu section. It manage the view (MenuView) and the
 * playlist collection (PlaylistList)
 * Menu communicate with the content section by events which trigger some action
 * as print playlist / print all tracks / etc...
 */

module.exports = MenuManager = (function() {
  MenuManager.prototype.currentPlaylist = null;

  function MenuManager() {
    _.extend(this, Backbone.Events);
    this.playlistsCollection = window.app.playlistsCollection;
    window.app.menuScreen = this;
    this.menuView = new MenuView;
    this.listenTo(this.menuView, 'playlist-create', this.createNewPlaylist);
  }

  MenuManager.prototype.render = function() {
    return this.menuView.render();
  };

  MenuManager.prototype.createNewPlaylist = function() {
    return this.playlistsCollection.create();
  };

  return MenuManager;

})();
});

;require.register("models/playlist", function(exports, require, module) {
var Playlist, PlaylistItems, PlaylistScreen,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

PlaylistItems = require('../collections/playlist_items');

PlaylistScreen = require('../views/content/playlist_screen');

module.exports = Playlist = (function(_super) {
  __extends(Playlist, _super);

  function Playlist() {
    return Playlist.__super__.constructor.apply(this, arguments);
  }

  Playlist.prototype.url = 'playlist-list';

  Playlist.prototype.defaults = {
    name: 'New Playlist'
  };

  Playlist.prototype.playlistView = null;

  Playlist.prototype.initialize = function() {
    return this.collection = new PlaylistItems;
  };

  Playlist.prototype.fetchTracks = function() {
    return console.log('tracks: ', this.get('tracks'));
  };

  Playlist.prototype.render = function() {
    if (this.playlistView != null) {
      $('playlist-header').append(this.playlistView.el);
      return;
    }
    this.playlistView = new PlaylistScreen({
      model: this
    });
    this.playlistView.render();
    return this.fetchTracks();
  };

  Playlist.prototype.addToPlaylist = function() {
    var listTracksId, selection, track;
    selection = window.selection;
    listTracksId = this.get('tracks');
    while (true) {
      if (selection.length === 0) {
        break;
      }
      track = selection.pop();
      this.collection.add(track);
      listTracksId.push(track.id);
    }
    return this.save();
  };

  return Playlist;

})(Backbone.Model);
});

;require.register("models/track", function(exports, require, module) {

/*
 * Represent a track element contained in the base collection
 *
 *
 * # uploadStatus Flag:
 *       In case of upload, the upload queue parse the metadata, and push it to
 *       the queue and the base collection so it is directly prompt to the user.
 *       The upload flag permit to the user to follow the uploading process and
 *       cancel it. Each modification of this flag is warn by the triggering of
 *       the 'change'.
 */
var Track,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

module.exports = Track = (function(_super) {
  __extends(Track, _super);

  function Track() {
    this.sync = __bind(this.sync, this);
    return Track.__super__.constructor.apply(this, arguments);
  }

  Track.prototype.url = 'track';

  Track.prototype.uploadStatus = null;

  Track.prototype.error = null;

  Track.VALID_STATUSES = [null, 'uploading', 'uploaded', 'errored'];


  /*
   * Getters for the local states.
   */

  Track.prototype.isUploading = function() {
    return this.uploadStatus === 'uploading';
  };

  Track.prototype.isUploaded = function() {
    return this.uploadStatus === 'uploaded';
  };

  Track.prototype.isErrored = function() {
    return this.uploadStatus === 'errored';
  };

  Track.prototype.isConflict = function() {
    return this.uploadStatus === 'conflict';
  };


  /*
   * Setters for the local state. Semantic wrapper for _setUploadStatus.
   */

  Track.prototype.markAsUploading = function() {
    return this._setUploadStatus('uploading');
  };

  Track.prototype.markAsUploaded = function() {
    return this._setUploadStatus('uploaded');
  };

  Track.prototype.markAsConflict = function() {
    return this._setUploadStatus('conflict');
  };

  Track.prototype.markAsErrored = function(error) {
    return this._setUploadStatus('errored', error);
  };


  /*
      Trigger change for each status update because Backbone only triggers
      `change` events for model's attributes.
      The `change` events allow the projection to be updated.
      @param `status` must be in Track.VALID_STATUSES
   */

  Track.prototype._setUploadStatus = function(status, error) {
    var message;
    if (error == null) {
      error = null;
    }
    if (__indexOf.call(Track.VALID_STATUSES, status) < 0) {
      message = ("Invalid upload status " + status + " not ") + ("in " + Track.VALID_STATUSES);
      throw new Error(message);
    } else {
      this.error = error;
      this.uploadStatus = status;
      return this.trigger('change', this);
    }
  };

  Track.prototype.isTrackStored = function(model) {
    var existingTrack;
    existingTrack = this.get(model.get('id'));
    return existingTrack || null;
  };

  Track.prototype.sync = function(method, model, options) {
    var formdata, progress;
    if (model.track) {
      method = 'create';
      this.id = "";
      formdata = new FormData();
      formdata.append('title', model.get('title'));
      formdata.append('artist', model.get('artist'));
      formdata.append('album', model.get('album'));
      formdata.append('trackNb', model.get('trackNb'));
      formdata.append('year', model.get('year'));
      formdata.append('genre', model.get('genre'));
      formdata.append('time', model.get('time'));
      formdata.append('docType', model.get('docType'));
      formdata.append('lastModification', model.get('lastModification'));
      if (this.overwrite) {
        formdata.append('overwrite', true);
      }
      formdata.append('track', model.track);
      progress = function(e) {
        model.loaded = e.loaded;
        return model.trigger('progress', e);
      };
      _.extend(options, {
        contentType: false,
        data: formdata,
        xhr: (function(_this) {
          return function() {
            var xhr;
            xhr = $.ajaxSettings.xhr();
            if (xhr.upload) {
              xhr.upload.addEventListener('progress', progress, false);
              _this.uploadXhrRequest = xhr;
            }
            return xhr;
          };
        })(this)
      });
    }
    return Backbone.sync.apply(this, arguments);
  };

  return Track;

})(Backbone.Model);
});

;require.register("router", function(exports, require, module) {
var Router, app,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

app = require('application');

module.exports = Router = (function(_super) {
  __extends(Router, _super);

  function Router() {
    return Router.__super__.constructor.apply(this, arguments);
  }

  Router.prototype.routes = {
    '': 'main'
  };

  Router.prototype.main = function() {
    if (!app.baseCollection.lenght > 0) {
      return app.baseCollection.fetch({
        error: function(error) {
          return console.log(error);
        }
      });
    }
  };

  return Router;

})(Backbone.Router);
});

;require.register("views/app_view", function(exports, require, module) {
var AppView, BaseView, ContentManager, MenuManager, PlayerScreen,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../lib/base_view');

MenuManager = require('../models/menu_manager');

ContentManager = require('../models/content_manager');

PlayerScreen = require('./player_screen');


/*
 *  Represent the app context. It contain and lauch the four big parts:
 *  - context menu
 *  - left menu
 *  - content screen
 *  - player screen
 */

module.exports = AppView = (function(_super) {
  __extends(AppView, _super);

  function AppView() {
    return AppView.__super__.constructor.apply(this, arguments);
  }

  AppView.prototype.el = 'body.application';

  AppView.prototype.template = require('./templates/home');

  AppView.prototype.afterRender = function() {
    this.menuScreen = new MenuManager;
    this.menuScreen.render();
    this.playerScreen = new PlayerScreen;
    this.playerScreen.render();
    this.contentScreen = new ContentManager;
    return this.contentScreen.renderAllTracks();
  };

  return AppView;

})(BaseView);
});

;require.register("views/content/all_tracks_screen", function(exports, require, module) {
var AllTracksView, TracksListView, TracksMenuView;

TracksMenuView = require('./views/tracks_menu_view');

TracksListView = require('./views/tracks_list_view');

module.exports = AllTracksView = (function() {
  AllTracksView.prototype.skeleton = require('./skeletons/all_tracks_skel');

  function AllTracksView(options) {
    _.extend(this, Backbone.Events);
    this.selection = options.selection;
    this.baseCollection = options.baseCollection;
    this.frame = $('#content-screen');
    this.frame.append(this.skeleton());
    this.menu = new TracksMenuView({
      selection: this.selection
    });
    this.tracks = new TracksListView({
      collection: this.baseCollection,
      selection: this.selection
    });
    this.listenTo(this.tracks, 'selection-menu-options', this.menu.manageOptionsMenu);
  }

  AllTracksView.prototype.render = function() {
    this.menu.render();
    return this.tracks.render();
  };

  AllTracksView.prototype.attach = function() {
    this.frame.append(this.menu.el);
    return this.frame.append(this.tracks.el);
  };

  AllTracksView.prototype.detach = function() {
    this.menu.$el.detach();
    return this.tracks.$el.detach();
  };

  AllTracksView.prototype.clearSelection = function() {
    this.selection.emptySelection();
    return this.menu.manageOptionsMenu('empty');
  };

  return AllTracksView;

})();
});

;require.register("views/content/edition_screen", function(exports, require, module) {
var EditionScreen, EditionView;

EditionView = require('./views/edition_view');

module.exports = EditionScreen = (function() {
  EditionScreen.prototype.skeleton = require('./skeletons/edition_skel');

  function EditionScreen() {
    _.extend(this, Backbone.Events);
    this.frame = $('#content-screen');
    this.frame.html(this.skeleton());
    this.view = new EditionView;
  }

  EditionScreen.prototype.render = function() {
    return this.view.render();
  };

  EditionScreen.prototype.attach = function() {
    this.view.render();
    return this.frame.append(this.view.el);
  };

  EditionScreen.prototype.detach = function() {
    return this.view.$el.detach();
  };

  return EditionScreen;

})();
});

;require.register("views/content/playlist_screen", function(exports, require, module) {
var PlaylistScreen, PlaylistView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

PlaylistView = require('./views/playlist_view');

module.exports = PlaylistScreen = (function(_super) {
  __extends(PlaylistScreen, _super);

  PlaylistScreen.prototype.skeleton = require('./skeletons/playlist_skel');

  PlaylistScreen.prototype.el = '#playlist-header';

  function PlaylistScreen() {
    _.extend(this, Backbone.Events);
    this.frame = $('#content-screen');
    this.frame.html(this.skeleton());
    this.view = new PlaylistView;
  }

  return PlaylistScreen;

})(Backbone.View);
});

;require.register("views/content/skeletons/all_tracks_skel", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div id=\"tracks-menu\"></div><div id=\"table-screen\"></div>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/content/skeletons/edition_skel", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div id=\"edition-screen\"></div>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/content/skeletons/playlist_skel", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div id=\"playlist-header\"></div><div id=\"display-screen\"></div>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/content/templates/edition", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
var locals_ = (locals || {}),track = locals_.track,album = locals_.album;
var trackAttributes = ['title', 'artist', 'year', 'genre', 'trackNb']
var albumAttributes = ['name', 'artist', 'year', 'genre']
buf.push("<div class=\"panel panel-default\"><div class=\"panel-heading\">TRACK - data specific to the track</div><div class=\"panel-body\"><div class=\"form-group\">");
// iterate trackAttributes
;(function(){
  var $$obj = trackAttributes;
  if ('number' == typeof $$obj.length) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var attribute = $$obj[$index];

if ( track[attribute])
{
buf.push("<label" + (jade.attr("for", 'edit-track-' + (attribute) + '', true, false)) + ">" + (jade.escape((jade_interp = attribute) == null ? '' : jade_interp)) + "</label><input" + (jade.attr("id", 'edit-track-' + (attribute) + '', true, false)) + " type=\"text\"" + (jade.attr("value", "" + (track[attribute]) + "", true, false)) + (jade.cls(['form-control track-edition ' + (attribute) + ''], [true])) + "/>");
}
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj) {
      $$l++;      var attribute = $$obj[$index];

if ( track[attribute])
{
buf.push("<label" + (jade.attr("for", 'edit-track-' + (attribute) + '', true, false)) + ">" + (jade.escape((jade_interp = attribute) == null ? '' : jade_interp)) + "</label><input" + (jade.attr("id", 'edit-track-' + (attribute) + '', true, false)) + " type=\"text\"" + (jade.attr("value", "" + (track[attribute]) + "", true, false)) + (jade.cls(['form-control track-edition ' + (attribute) + ''], [true])) + "/>");
}
    }

  }
}).call(this);

buf.push("<label for=\"plays\">Plays</label><p id=\"plays\">" + (jade.escape((jade_interp = track['plays']) == null ? '' : jade_interp)) + "</p></div></div></div><div class=\"panel panel-default\"><div class=\"panel-heading\">" + (jade.escape((jade_interp = album.name) == null ? '' : jade_interp)) + "</div><div class=\"panel-body\"><div class=\"form-group\">");
// iterate albumAttributes
;(function(){
  var $$obj = albumAttributes;
  if ('number' == typeof $$obj.length) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var attribute = $$obj[$index];

if ( album[attribute])
{
buf.push("<label" + (jade.attr("for", 'Edit-album-' + (attribute) + '', true, false)) + ">" + (jade.escape((jade_interp = attribute) == null ? '' : jade_interp)) + "</label><input" + (jade.attr("id", 'edit-album-' + (attribute) + '', true, false)) + " type=\"text\"" + (jade.attr("value", "" + (album[attribute]) + "", true, false)) + (jade.cls(['form-control album-edition ' + (attribute) + ''], [true])) + "/>");
}
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj) {
      $$l++;      var attribute = $$obj[$index];

if ( album[attribute])
{
buf.push("<label" + (jade.attr("for", 'Edit-album-' + (attribute) + '', true, false)) + ">" + (jade.escape((jade_interp = attribute) == null ? '' : jade_interp)) + "</label><input" + (jade.attr("id", 'edit-album-' + (attribute) + '', true, false)) + " type=\"text\"" + (jade.attr("value", "" + (album[attribute]) + "", true, false)) + (jade.cls(['form-control album-edition ' + (attribute) + ''], [true])) + "/>");
}
    }

  }
}).call(this);

buf.push("</div></div></div><button id=\"edit-cancel\" class=\"btn btn-default\">Cancel</button><button id=\"edit-submit\" class=\"btn btn-default\">Change</button>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/content/templates/menu_list", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<button type=\"button\" data-toggle=\"dropdown\" aria-haspopup=\"true\" aria-expanded=\"false\" class=\"btn btn-default dropdown-toggle\"><Add>TO PLAYLIST</Add><span class=\"caret\"></span></button><ul id=\"tracks-menu-playlist-content\" class=\"dropdown-menu\"></ul>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/content/templates/menu_row", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
var locals_ = (locals || {}),model = locals_.model;
buf.push("<a>" + (jade.escape((jade_interp = model.name) == null ? '' : jade_interp)) + "</a>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/content/templates/playlist", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
var locals_ = (locals || {}),model = locals_.model;
buf.push("<h1>" + (jade.escape((jade_interp = model.name) == null ? '' : jade_interp)) + "</h1>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/content/templates/track_row", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
var locals_ = (locals || {}),model = locals_.model,album = locals_.album;
buf.push("<td>" + (jade.escape((jade_interp = model.title) == null ? '' : jade_interp)) + "</td>");
if ( model.artist)
{
buf.push("<td>" + (jade.escape((jade_interp = model.artist) == null ? '' : jade_interp)) + "</td>");
}
else
{
buf.push("<td>" + (jade.escape((jade_interp = album.artist) == null ? '' : jade_interp)) + "</td>");
}
if ( album)
{
buf.push("<td>" + (jade.escape((jade_interp = album.name) == null ? '' : jade_interp)) + "</td>");
}
else
{
buf.push("<td></td>");
}
buf.push("<td>" + (jade.escape((jade_interp = model.plays) == null ? '' : jade_interp)) + "</td><td>" + (jade.escape((jade_interp = model.time) == null ? '' : jade_interp)) + "</td>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/content/templates/tracks_list", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<table class=\"table table-striped\"><thead><tr><th>Title</th><th>Artist</th><th>Album</th><th>#</th><th>Time</th></tr></thead><tbody id=\"table-items-content\"></tbody></table>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/content/templates/tracks_menu", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div id=\"tracks-menu-button\" class=\"nav nav-tabs\"><input id=\"tracks-menu-upload\" name=\"upload-files\" type=\"file\" multiple=\"multiple\" accept=\"audio/*\" role=\"presentation\" class=\"btn btn-default btn-file\"/><button id=\"tracks-menu-fetch\" role=\"presentation\" class=\"btn btn-default\">FETCH</button><div id=\"tracks-menu-playlist\" class=\"btn-group\"></div><button id=\"tracks-menu-edit\" role=\"presentation\" class=\"btn btn-default\">EDIT</button></div>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/content/views/edition_view", function(exports, require, module) {
var BaseView, EditionView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../../../lib/base_view');


/*
 * Edition View is the view manager of the tracks edition screen. It handle the
 * processing of the data's selection tracks to merge it and in case of
 */

module.exports = EditionView = (function(_super) {
  __extends(EditionView, _super);

  function EditionView() {
    return EditionView.__super__.constructor.apply(this, arguments);
  }

  EditionView.prototype.template = require('../templates/edition');

  EditionView.prototype.el = '#edition-screen';

  EditionView.MERGED_ATTRIBUTES = ['title', 'artist', 'year', 'genre', 'name'];

  EditionView.prototype.processedAttr = {
    track: {},
    album: {}
  };

  EditionView.prototype.events = function() {
    return {
      'click #edit-cancel': function() {
        return this.trigger('edition-end');
      },
      'click #edit-submit': 'submitEdition'
    };
  };

  EditionView.prototype.initialize = function() {
    return this.selection = window.selection;
  };

  EditionView.prototype.beforeRender = function() {
    return this.processeAttr();
  };

  EditionView.prototype.getRenderData = function() {
    return {
      album: this.processedAttr.album,
      track: this.processedAttr.track
    };
  };

  EditionView.prototype.processeAttr = function() {
    var album, model;
    model = this.selection.models[0];
    album = model.album;
    return EditionView.MERGED_ATTRIBUTES.forEach((function(_this) {
      return function(attr) {
        var albumAttr, modelAttr;
        modelAttr = model.get(attr);
        albumAttr = album.get(attr);
        _this.processedAttr.track[attr] = modelAttr ? modelAttr : '';
        return _this.processedAttr.album[attr] = albumAttr ? albumAttr : '';
      };
    })(this));
  };

  EditionView.prototype.saveTrackChanges = function() {
    var newInputAttr, track, _results;
    _results = [];
    while (true) {
      if (this.selection.length === 0) {
        break;
      }
      track = this.selection.pop();
      newInputAttr = null;
      EditionView.MERGED_ATTRIBUTES.forEach((function(_this) {
        return function(attr) {
          var inputValue;
          inputValue = _this.$("#edit-track-" + attr).val();
          if (inputValue !== '' && track.get(attr) !== inputValue) {
            if (newInputAttr === null) {
              newInputAttr = {};
            }
            return newInputAttr[attr] = inputValue;
          }
        };
      })(this));
      this.saveAlbumChanges(track);
      if (newInputAttr != null) {
        _results.push(track.save(newInputAttr));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  EditionView.prototype.saveAlbumChanges = function(track) {
    var album, newInputAttr;
    newInputAttr = null;
    album = track.album;
    EditionView.MERGED_ATTRIBUTES.forEach((function(_this) {
      return function(attr) {
        var inputValue;
        inputValue = _this.$("#edit-album-" + attr).val();
        if (inputValue !== '' && album.get(attr) !== inputValue) {
          if (newInputAttr === null) {
            newInputAttr = {};
          }
          return newInputAttr[attr] = inputValue;
        }
      };
    })(this));
    if (newInputAttr != null) {
      return album.save(newInputAttr);
    }
  };

  EditionView.prototype.submitEdition = function() {
    this.saveTrackChanges();
    return this.trigger('edition-end');
  };

  return EditionView;

})(BaseView);
});

;require.register("views/content/views/menu_list_view", function(exports, require, module) {
var MenuListView, MenuRowView, ViewCollection,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

ViewCollection = require('../../../../lib/view_collection');

MenuRowView = require('./menu_row_view');

module.exports = MenuListView = (function(_super) {
  __extends(MenuListView, _super);

  function MenuListView() {
    return MenuListView.__super__.constructor.apply(this, arguments);
  }

  MenuListView.prototype.template = require('../templates/menu_list');

  MenuListView.prototype.el = '#tracks-menu-playlist';

  MenuListView.prototype.itemview = MenuRowView;

  MenuListView.prototype.collectionEl = '#tracks-menu-playlist-content';

  MenuListView.prototype.initialize = function() {
    this.collection = window.app.playlistsCollection;
    return MenuListView.__super__.initialize.apply(this, arguments);
  };

  return MenuListView;

})(ViewCollection);
});

;require.register("views/content/views/menu_row_view", function(exports, require, module) {
var BaseView, MenuRowView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../../../../lib/base_view');

module.exports = MenuRowView = (function(_super) {
  __extends(MenuRowView, _super);

  function MenuRowView() {
    return MenuRowView.__super__.constructor.apply(this, arguments);
  }

  MenuRowView.prototype.template = require('../templates/menu_row');

  MenuRowView.prototype.className = 'tracks-menu-playlist-row';

  MenuRowView.prototype.tagName = 'li';

  MenuRowView.prototype.initialize = function() {
    return this.$el.click((function(_this) {
      return function() {
        return _this.model.addToPlaylist();
      };
    })(this));
  };

  return MenuRowView;

})(BaseView);
});

;require.register("views/content/views/tracks_list_view", function(exports, require, module) {
var TracksListView, TracksRowView, ViewCollection,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

ViewCollection = require('../../../../lib/view_collection');

TracksRowView = require('./tracks_row_view');


/*
 * TracksView is the structure for put tracks in content view
 */

module.exports = TracksListView = (function(_super) {
  __extends(TracksListView, _super);

  function TracksListView() {
    return TracksListView.__super__.constructor.apply(this, arguments);
  }

  TracksListView.prototype.template = require('../templates/tracks_list');

  TracksListView.prototype.el = '#table-screen';

  TracksListView.prototype.itemview = TracksRowView;

  TracksListView.prototype.collectionEl = '#table-items-content';

  TracksListView.prototype.events = {
    'click tr.track-row': 'manageSelectionEvent'
  };

  TracksListView.prototype._lastTrackSelected = null;

  TracksListView.prototype.initialize = function(options) {
    this.selection = options.selection;
    this.collection = options.collection;
    TracksListView.__super__.initialize.apply(this, arguments);
    this.listenTo(this.selection, 'remove', _.partial(this.viewProxy, 'setAsNoSelected'));
    this.listenTo(this.selection, 'add', _.partial(this.viewProxy, 'setAsSelected'));
    return this.listenTo(this.collection, 'change', _.partial(this.viewProxy, 'refresh'));
  };

  TracksListView.prototype.triggerMenuOption = function() {
    switch (this.selection.length) {
      case 0:
        return this.trigger('selection-menu-options', 'empty');
      case 1:
        return this.trigger('selection-menu-options', 'unique');
      default:
        return this.trigger('selection-menu-options', 'several');
    }
  };

  TracksListView.prototype.manageSelectionEvent = function(event) {
    var cid, view, _manageListTracksSelection;
    cid = this.$(event.target).parents('tr').data('cid');
    view = _.find(this.views, function(view) {
      return view.model.cid === cid;
    });
    _manageListTracksSelection = (function(_this) {
      return function(lastView) {
        var endIndex, startIndex, _results;
        startIndex = _this.views.indexOf(_this._lastTrackSelected);
        endIndex = _this.views.indexOf(lastView);
        _results = [];
        while (true) {
          if (startIndex < endIndex) {
            startIndex++;
          } else {
            startIndex--;
          }
          _this.selection.push(_this.views[startIndex].model);
          if (startIndex === endIndex) {
            break;
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };
    })(this);
    if (event.shiftKey && this._lastTrackSelected !== null) {
      _manageListTracksSelection(view);
    } else {
      this.selection.emptySelection();
      this.selection.push(view.model);
    }
    this._lastTrackSelected = view;
    return this.triggerMenuOption();
  };

  return TracksListView;

})(ViewCollection);
});

;require.register("views/content/views/tracks_menu_view", function(exports, require, module) {
var BaseView, MenuListView, TracksMenuView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../../../../lib/base_view');

MenuListView = require('./menu_list_view');


/*
 * Context_menu represent the menu on the top of the app. His goal is to work
 * with tracks_display. It must display the dynamiques option when the user select
 * one or several song in the tracks display.
 */

module.exports = TracksMenuView = (function(_super) {
  __extends(TracksMenuView, _super);

  function TracksMenuView() {
    this.manageOptionsMenu = __bind(this.manageOptionsMenu, this);
    return TracksMenuView.__super__.constructor.apply(this, arguments);
  }

  TracksMenuView.prototype.template = require('../templates/tracks_menu');

  TracksMenuView.prototype.el = '#tracks-menu';

  TracksMenuView.prototype.currentStatus = 'empty';

  TracksMenuView.prototype.events = {
    'change #tracks-menu-uploadfiles': 'lauchUploadFiles',
    'click #tracks-menu-edit': function(e) {
      return this.trigger('menu-trackEdition-lauch');
    },
    'click #tracks-menu-fetch': 'fetchBaseCollection'
  };

  TracksMenuView.prototype.initialize = function(options) {
    return this.selection = options.selection;
  };

  TracksMenuView.prototype.afterRender = function() {
    this.menu = $('#tracks-menu-button');
    this.uploader = $('#tracks-menu-upload');
    this.editionButton = $('#tracks-menu-edit');
    this.playlistButton = $('#tracks-menu-playlist');
    this.listPlaylistsViews = new MenuListView;
    this.listPlaylistsViews.render();
    this.editionButton.detach();
    return this.playlistButton.detach();
  };

  TracksMenuView.prototype.fetchBaseCollection = function() {
    return window.app.baseCollection.fetch();
  };

  TracksMenuView.prototype.addToPlaylist = function(event) {
    var cid;
    console.log('event: ', event);
    cid = this.$(event.target).parents('li').data('cid');
    return console.log('cid: ', cid);
  };

  TracksMenuView.prototype.lauchUploadFiles = function(event) {
    var files, target, _ref;
    files = ((_ref = event.dataTransfert) != null ? _ref.files : void 0) || event.target.files;
    if (files.length) {
      window.app.uploadQueue.addBlobs(files);
      if (event.target != null) {
        target = $(event.target);
        return target.replaceWith(target.clone(true));
      }
    }
  };

  TracksMenuView.prototype.manageOptionsMenu = function(status) {
    if (status === 'unique') {
      if (this.currentStatus === 'empty') {
        this.menu.append(this.playlistButton);
        this.menu.append(this.editionButton);
      } else if (this.currentStatus === 'several') {
        this.menu.append(this.editionButton);
      }
      return this.currentStatus = status;
    } else if (status === 'empty') {
      if (this.currentStatus === 'unique') {
        this.editionButton.detach();
        this.playlistButton.detach();
      } else if (this.currentStatus === 'several') {
        this.playlistButton.detach();
      }
      return this.currentStatus = status;
    } else if (status === 'several') {
      if (this.currentStatus === 'empty') {
        this.menu.append(this.playlistButton);
      } else if (this.currentStatus === 'unique') {
        this.editionButton.detach();
        this.menu.append(this.playlistButton);
      }
      return this.currentStatus = status;
    }
  };

  return TracksMenuView;

})(BaseView);
});

;require.register("views/content/views/tracks_row_view", function(exports, require, module) {
var BaseView, TrackRowView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../../../../lib/base_view');


/*
 * Each TrackView represent a track in a collection
 */

module.exports = TrackRowView = (function(_super) {
  __extends(TrackRowView, _super);

  function TrackRowView() {
    return TrackRowView.__super__.constructor.apply(this, arguments);
  }

  TrackRowView.prototype.template = require('../templates/track_row');

  TrackRowView.prototype.className = 'track-row';

  TrackRowView.prototype.tagName = 'tr';

  TrackRowView.prototype._selectedStatus = false;

  TrackRowView.prototype.getRenderData = function() {
    var _ref, _ref1, _ref2;
    return {
      model: (_ref = this.model) != null ? _ref.toJSON() : void 0,
      album: (_ref1 = this.model) != null ? (_ref2 = _ref1.album) != null ? _ref2.toJSON() : void 0 : void 0
    };
  };

  TrackRowView.prototype.afterRender = function() {
    this.$el.data('cid', this.model.cid);
    if (this.model.isUploading()) {
      return this.$el.addClass('warning');
    } else if (this.model.isUploaded()) {
      return this.$el.removeClass('warning');
    } else if (this.model.isErrored()) {
      return this.$el.addClass('danger');
    } else if (this.model.isConflict()) {
      return this.$el.addClass('info');
    }
  };

  TrackRowView.prototype.refresh = function() {
    return this.render();
  };

  TrackRowView.prototype.setAsSelected = function() {
    return this.$el.addClass('success');
  };

  TrackRowView.prototype.setAsNoSelected = function() {
    return this.$el.removeClass('success');
  };

  TrackRowView.prototype.changeSelectStat = function() {
    if (this.isTrackSelected()) {
      this.setTrackAsNoSelected();
    } else {
      this.setTrackAsSelected();
    }
    return this._selectedStatus;
  };

  TrackRowView.prototype.isSelected = function() {
    return this._selectedStatus;
  };

  TrackRowView.prototype.setAsSelected = function() {
    this.$el.addClass('success');
    return this._selectedStatus = true;
  };

  TrackRowView.prototype.setAsNoSelected = function() {
    this.$el.removeClass('success');
    return this._selectedStatus = false;
  };

  return TrackRowView;

})(BaseView);
});

;require.register("views/menu/menu_view", function(exports, require, module) {
var BaseView, MenuView, PlaylistsListView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../../lib/base_view');

PlaylistsListView = require('./playlist/playlists_list_view');


/*
 * MenuView represent the main panel view. His goal is trigger the changing
 * of content in the tracks screen
 *
 * The playlists names a handle by a collection of view (PlaylistView)
 */

module.exports = MenuView = (function(_super) {
  __extends(MenuView, _super);

  function MenuView() {
    return MenuView.__super__.constructor.apply(this, arguments);
  }

  MenuView.prototype.template = require('./templates/menu_screen');

  MenuView.prototype.el = '#left-menu';

  MenuView.prototype.events = {
    'click #menu-playlist-new': 'createNewPlaylist',
    'click #menu-all-tracks': 'printAllTracks'
  };

  MenuView.prototype.initialize = function() {
    this.playlistsCollection = window.app.playlistsCollection;
    return window.app.menuScreen = this;
  };

  MenuView.prototype.afterRender = function() {
    this.playlistsViews = new PlaylistsListView({
      collection: this.playlistsCollection
    });
    return this.playlistsViews.render();
  };

  MenuView.prototype.createNewPlaylist = function() {
    return this.trigger('playlist-create');
  };

  MenuView.prototype.printAllTracks = function() {
    return this.trigger('content-print-allTracks');
  };

  return MenuView;

})(BaseView);
});

;require.register("views/menu/playlist/playlists_list_view", function(exports, require, module) {
var PlaylistRowView, PlaylistsListView, ViewCollection,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

ViewCollection = require('../../../lib/view_collection');

PlaylistRowView = require('./playlists_row_view');

module.exports = PlaylistsListView = (function(_super) {
  __extends(PlaylistsListView, _super);

  function PlaylistsListView() {
    return PlaylistsListView.__super__.constructor.apply(this, arguments);
  }

  PlaylistsListView.prototype.template = require('./templates/playlists');

  PlaylistsListView.prototype.el = '#menu-playlist';

  PlaylistsListView.prototype.itemview = PlaylistRowView;

  PlaylistsListView.prototype.collectionEl = '#menu-playlist-list';

  return PlaylistsListView;

})(ViewCollection);
});

;require.register("views/menu/playlist/playlists_row_view", function(exports, require, module) {
var BaseView, PlaylistRowView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../../../lib/base_view');

module.exports = PlaylistRowView = (function(_super) {
  __extends(PlaylistRowView, _super);

  function PlaylistRowView() {
    return PlaylistRowView.__super__.constructor.apply(this, arguments);
  }

  PlaylistRowView.prototype.template = require('./templates/playlist');

  PlaylistRowView.prototype.className = 'playlist-row';

  PlaylistRowView.prototype.tagName = 'li';

  PlaylistRowView.prototype.initialize = function() {
    return this.$el.click((function(_this) {
      return function() {
        return window.app.menuScreen.trigger('content-print-playlist', _this.model);
      };
    })(this));
  };

  return PlaylistRowView;

})(BaseView);
});

;require.register("views/menu/playlist/templates/playlist", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
var locals_ = (locals || {}),model = locals_.model;
buf.push("<a>" + (jade.escape((jade_interp = model.name) == null ? '' : jade_interp)) + "</a>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/menu/playlist/templates/playlists", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<ul id=\"menu-playlist-list\" class=\"nav nav-sidebar\"></ul><li id=\"menu-playlist-new\"><a>Create a Playlist</a></li>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/menu/templates/menu_screen", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<label for=\"menu-section\">Section</label><ul id=\"menu-section\" class=\"nav nav-sidebar\"><li><a id=\"menu-all-tracks\">All Tracks</a></li></ul><label for=\"menu-playlist\">Playlist</label><div id=\"menu-playlist\"></div>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/player_screen", function(exports, require, module) {
var BaseView, PlayerScreen,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../lib/base_view');

module.exports = PlayerScreen = (function(_super) {
  __extends(PlayerScreen, _super);

  function PlayerScreen() {
    return PlayerScreen.__super__.constructor.apply(this, arguments);
  }

  PlayerScreen.prototype.template = require('./templates/player_screen');

  PlayerScreen.prototype.el = '#player-screen';

  PlayerScreen.prototype.tagName = 'div';

  PlayerScreen.prototype.className = 'player-screen';

  return PlayerScreen;

})(BaseView);
});

;require.register("views/templates/home", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"container-fluid\"><div id=\"left-menu\" class=\"sidebar\"></div><div id=\"content-screen\" class=\"content container-fluid\"></div></div><div id=\"player-screen\" class=\"footer player\"></div>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/templates/player_screen", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<h1>Player screen</h1>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;
//# sourceMappingURL=app.js.map