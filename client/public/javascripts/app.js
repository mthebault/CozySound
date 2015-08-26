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
var AppView, TracksList, UploadQueue;

AppView = require('./views/app_view');

TracksList = require('./collections/tracks_list');

UploadQueue = require('./collections/upload_queue');

module.exports = {
  initialize: function() {
    var Router, mainView;
    window.app = this;
    this.baseCollection = new TracksList;
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

;require.register("collections/selected_list", function(exports, require, module) {
var SelectedTracksList, Track,
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

module.exports = SelectedTracksList = (function(_super) {
  __extends(SelectedTracksList, _super);

  function SelectedTracksList() {
    return SelectedTracksList.__super__.constructor.apply(this, arguments);
  }

  SelectedTracksList.prototype.model = Track;

  SelectedTracksList.prototype.url = 'tracks';

  SelectedTracksList.prototype._lastTrackSelected = null;

  SelectedTracksList.prototype.processingUpdate = 0;

  SelectedTracksList.prototype.initialize = function() {
    SelectedTracksList.__super__.initialize.apply(this, arguments);
    return window.selectedTracksList = this;
  };

  SelectedTracksList.prototype.onTrackClicked = function(model, isShiftPressed) {
    if (isShiftPressed == null) {
      isShiftPressed = false;
    }
    if (isShiftPressed === true && this._lastTrackSelected !== null) {
      this._manageListTracksSelection(model);
    } else {
      this._manageTrackSelection(model);
    }
    return this._lastTrackSelected = model;
  };

  SelectedTracksList.prototype._manageListTracksSelection = function(lastModel) {
    var endIndex, startIndex, _results;
    startIndex = this.baseCollection.indexOf(this._lastTrackSelected);
    endIndex = this.baseCollection.indexOf(lastModel);
    _results = [];
    while (true) {
      if (startIndex < endIndex) {
        startIndex++;
      } else {
        startIndex--;
      }
      this._manageTrackSelection(this.baseCollection.at(startIndex));
      if (startIndex === endIndex) {
        break;
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  SelectedTracksList.prototype._manageTrackSelection = function(model) {
    if (model.isSelected() === false) {
      this.add(model);
      return model.setAsSelected();
    } else {
      this.remove(model);
      return model.setAsNoSelected();
    }
  };

  SelectedTracksList.prototype.add = function(models, options) {
    if (this.length === 0) {
      this.trigger('selectionTracksState', true);
    }
    return SelectedTracksList.__super__.add.call(this, models, options);
  };

  SelectedTracksList.prototype.remove = function(models, options) {
    SelectedTracksList.__super__.remove.call(this, models, options);
    if (this.length === 0) {
      return this.trigger('selectionTracksState', false);
    }
  };

  SelectedTracksList.prototype.updateTracks = function(newAttrs) {
    var errorUpdating, setOfAttr, successUpdating, track, _results;
    console.log(newAttrs);
    errorUpdating = 0;
    successUpdating = 0;
    _results = [];
    while (true) {
      track = this.pop();
      track.setAsNoSelected();
      while (true) {
        setOfAttr = newAttrs.pop();
        if (track.get(setOfAttr[0]) !== setOfAttr[1]) {
          track.set(setOfAttr[0], setOfAttr[1]);
          this.processingUpdate++;
          console.log('send: ', track);
          track.sync('update', track, {
            error: function(data) {
              this.processingUpdate--;
              return errorUpdating++;
            },
            success: function(data) {
              this.processingUpdate--;
              return successUpdating++;
            }
          });
        }
        if (newAttrs.length === 0) {
          break;
        }
      }
      if (this.length === 0) {
        break;
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  return SelectedTracksList;

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

  TracksList.prototype.url = 'tracks';

  TracksList.prototype.sizeFrameDownload = 5;

  TracksList.prototype.cursorFrameDownload = 0;

  TracksList.prototype.isTrackStored = function(model) {
    var existingTrack;
    existingTrack = this.get(model.get('id'));
    return existingTrack || null;
  };

  TracksList.prototype.fetch = function() {
    return $.ajax({
      url: "tracks/" + this.cursorFrameDownload + "/" + this.sizeFrameDownload,
      type: 'GET',
      error: function(xhr) {
        return console.error(xhr);
      },
      success: (function(_this) {
        return function(data) {
          _this.cursorFrameDownload += data.length;
          return _this.add(data, {
            remove: false
          });
        };
      })(this)
    });
  };

  return TracksList;

})(Backbone.Collection);
});

;require.register("collections/upload_queue", function(exports, require, module) {
var Track, UploadQueue,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Track = require('./../models/track');


/*
 * The UploadQueue is a mix of async.queue & BackboneCollection
 * - Blobs are parsed and added to the queue and the base collection with the flag
 * uploading
 */

module.exports = UploadQueue = (function() {
  UploadQueue.prototype.model = Track;

  UploadQueue.prototype.loaded = 0;

  function UploadQueue(baseCollection) {
    this.baseCollection = baseCollection;
    this.completeUpload = __bind(this.completeUpload, this);
    this.uploadWorker = __bind(this.uploadWorker, this);
    this.uploadCollection = new Backbone.Collection();
    _.extend(this, Backbone.Events);
    this.asyncQueue = async.queue(this.uploadWorker, 5);
    this.asyncQueue.drain = this.completeUpload.bind(this);
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
          return _this.trigger('badFileType');
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
        tags: ["title", "artist", "album", "track", "year", "genre", "TLEN"],
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
    this.baseCollection.add(model);
    this.uploadCollection.add(model);
    return this.asyncQueue.push(model);
  };

  UploadQueue.prototype._processSave = function(model, done) {
    if (!model.isErrored() && !model.isConflict()) {
      return model.save(null, {
        success: (function(_this) {
          return function(model) {
            model.track = null;
            model.loaded = model.total;
            model.markAsUploaded();
            return done(null);
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
                return _this.asyncQueue.push(model);
              }
            }
          };
        })(this)
      });
    } else {
      return done();
    }
  };

  UploadQueue.prototype.uploadWorker = function(model, next) {
    if (model.error) {
      return setTimeout(next, 10);
    } else if (model.isConflict()) {
      return alert('CONFLICT');
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

  ViewCollection.prototype.views = {};

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
    this.views = {};
    this.listenTo(this.collection, "reset", this.onReset);
    this.listenTo(this.collection, "add", this.addItem);
    this.listenTo(this.collection, "remove", this.removeItem);
    if (this.collectionEl == null) {
      return collectionEl = el;
    }
  };

  ViewCollection.prototype.render = function() {
    var id, view, _ref;
    _ref = this.views;
    for (id in _ref) {
      view = _ref[id];
      view.$el.detach();
    }
    return ViewCollection.__super__.render.apply(this, arguments);
  };

  ViewCollection.prototype.afterRender = function() {
    var id, view, _ref;
    this.$collectionEl = $(this.collectionEl);
    _ref = this.views;
    for (id in _ref) {
      view = _ref[id];
      this.appendView(view.$el);
    }
    this.onReset(this.collection);
    return this.onChange(this.views);
  };

  ViewCollection.prototype.remove = function() {
    this.onReset([]);
    return ViewCollection.__super__.remove.apply(this, arguments);
  };

  ViewCollection.prototype.onReset = function(newcollection) {
    var id, view, _ref;
    _ref = this.views;
    for (id in _ref) {
      view = _ref[id];
      view.remove();
    }
    return newcollection.forEach(this.addItem);
  };

  ViewCollection.prototype.addItem = function(model) {
    var options, view;
    options = _.extend({}, {
      model: model
    }, this.itemViewOptions(model));
    view = new this.itemview(options);
    this.views[model.cid] = view.render();
    this.appendView(view);
    return this.onChange(this.views);
  };

  ViewCollection.prototype.removeItem = function(model) {
    this.views[model.cid].remove();
    delete this.views[model.cid];
    return this.onChange(this.views);
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

  Track.prototype._selectedStatus = false;


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

  Track.prototype.isSelected = function() {
    return this._selectedStatus;
  };

  Track.prototype.setAsSelected = function() {
    this._selectedStatus = true;
    return this.trigger('toggle-select', {
      cid: this.cid
    });
  };

  Track.prototype.setAsNoSelected = function() {
    this._selectedStatus = false;
    return this.trigger('toggle-select', {
      cid: this.cid
    });
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
var AppView, BaseView, ContentScreen, LeftMenu, PlayerScreen,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../lib/base_view');

LeftMenu = require('./left_menu');

ContentScreen = require('./content_screen');

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
    this.leftMenu = new LeftMenu;
    this.leftMenu.render();
    this.playerScreen = new PlayerScreen;
    this.playerScreen.render();
    this.contentScreen = new ContentScreen;
    return this.contentScreen.renderAllTracks();
  };

  return AppView;

})(BaseView);
});

;require.register("views/content/edition/edition_view", function(exports, require, module) {
var BaseView, EditionView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../../../lib/base_view');


/*
 * Edition View is the view manager of the tracks edition screen. It handle the
 * processing of the data's selectedTracksList tracks to merge it and in case of
 */

module.exports = EditionView = (function(_super) {
  __extends(EditionView, _super);

  function EditionView() {
    return EditionView.__super__.constructor.apply(this, arguments);
  }

  EditionView.prototype.template = require('./templates/edition');

  EditionView.prototype.el = '#edition-screen';

  EditionView.MERGED_ATTRIBUTES = ['title', 'artist', 'album', 'year', 'genre'];

  EditionView.prototype.processingUpdate = 0;

  EditionView.prototype.processedAttr = {};

  EditionView.prototype.events = function() {
    return {
      'click #edit-cancel': 'cancelEdition',
      'click #edit-submit': 'submitEdition'
    };
  };

  EditionView.prototype.initialize = function() {
    return this.collection = window.selectedTracksList;
  };

  EditionView.prototype.render = function() {
    this.mergeMetaData();
    this.cleanProcessedAttr();
    return this.$el.append(this.template({
      attr: this.processedAttr
    }));
  };

  EditionView.prototype.mergeMetaData = function() {
    return EditionView.MERGED_ATTRIBUTES.forEach((function(_this) {
      return function(attribute) {
        var isSimilar, lastAttribute;
        lastAttribute = void 0;
        isSimilar = true;
        _this.collection.models.forEach(function(track) {
          if (lastAttribute !== void 0 && track.get(attribute) !== lastAttribute) {
            isSimilar = false;
          }
          if (lastAttribute === void 0) {
            return lastAttribute = track.get(attribute);
          }
        });
        if (lastAttribute !== void 0 && isSimilar === true) {
          return _this.processedAttr[attribute] = lastAttribute;
        }
      };
    })(this));
  };

  EditionView.prototype.cleanProcessedAttr = function() {
    return EditionView.MERGED_ATTRIBUTES.forEach((function(_this) {
      return function(attr) {
        if (_this.processedAttr[attr] === void 0) {
          return _this.processedAttr[attr] = '';
        }
      };
    })(this));
  };

  EditionView.prototype.saveEditionChanges = function() {
    var newInputAttr;
    newInputAttr = new Array;
    EditionView.MERGED_ATTRIBUTES.forEach((function(_this) {
      return function(attr) {
        var attrValue, inputValue;
        attrValue = _this.processedAttr[attr];
        inputValue = _this.$("#edit-" + attr).val();
        if (inputValue !== '' && attrValue !== inputValue) {
          return newInputAttr.push([attr, inputValue]);
        }
      };
    })(this));
    return this.collection.updateTracks(newInputAttr);
  };

  EditionView.prototype.computeChangeAttr = function(attribute, inputValue) {
    return this.collection.models.forEach(function(track) {
      return track.set(attribute, inputValue);
    });
  };

  EditionView.prototype.cancelEdition = function() {
    this.freeSelectedTracksList();
    return this.trigger('edition-end');
  };

  EditionView.prototype.submitEdition = function() {
    this.saveEditionChanges();
    return this.trigger('edition-end');
  };

  EditionView.prototype.freeSelectedTracksList = function() {
    var track, _results;
    _results = [];
    while (true) {
      track = this.collection.pop();
      track.setAsNoSelected();
      if (this.collection.length === 0) {
        break;
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  return EditionView;

})(BaseView);
});

;require.register("views/content/edition/templates/edition", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
var locals_ = (locals || {}),attr = locals_.attr;
buf.push("<div class=\"form-group\"><label for=\"Edit-title\">Title</label><input id=\"edit-title\" type=\"text\"" + (jade.attr("value", "" + (attr['title']) + "", true, false)) + " class=\"form-control\"/><label for=\"Edit-artist\">Artist</label><input id=\"edit-artist\" type=\"text\"" + (jade.attr("value", "" + (attr['artist']) + "", true, false)) + " class=\"form-control\"/><label for=\"Edit-album\">Album</label><input id=\"edit-album\" type=\"text\"" + (jade.attr("value", "" + (attr['album']) + "", true, false)) + " class=\"form-control\"/><label for=\"Edit-year\">Year</label><input id=\"edit-year\" type=\"text\"" + (jade.attr("value", "" + (attr['year']) + "", true, false)) + " class=\"form-control\"/><label for=\"Edit-genre\">Genre</label><input id=\"edit-genre\" type=\"text\"" + (jade.attr("value", "" + (attr['genre']) + "", true, false)) + " class=\"form-control\"/></div><button id=\"edit-cancel\" class=\"btn btn-default\">Cancel</button><button id=\"edit-submit\" class=\"btn btn-default\">Change</button>");;return buf.join("");
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

;require.register("views/content/edition_skel", function(exports, require, module) {
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

;require.register("views/content/track/templates/track", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
var locals_ = (locals || {}),model = locals_.model;
buf.push("<td>" + (jade.escape((jade_interp = model.title) == null ? '' : jade_interp)) + "</td><td>" + (jade.escape((jade_interp = model.artist) == null ? '' : jade_interp)) + "</td><td>" + (jade.escape((jade_interp = model.album) == null ? '' : jade_interp)) + "</td><td>XX</td><td>" + (jade.escape((jade_interp = model.uploadStatus) == null ? '' : jade_interp)) + "</td>");;return buf.join("");
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

;require.register("views/content/track/templates/tracks", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<table class=\"table table-striped\"><thead><tr><th>Title</th><th>Artist</th><th>Album</th><th>#</th><th>status</th></tr></thead><tbody id=\"table-items-content\"></tbody></table>");;return buf.join("");
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

;require.register("views/content/track/track_view", function(exports, require, module) {
var BaseView, TrackView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../../../lib/base_view');


/*
 * Each TrackView represent a track in a collection
 */

module.exports = TrackView = (function(_super) {
  __extends(TrackView, _super);

  function TrackView() {
    return TrackView.__super__.constructor.apply(this, arguments);
  }

  TrackView.prototype.template = require('./templates/track');

  TrackView.prototype.className = 'track-row';

  TrackView.prototype.tagName = 'tr';

  TrackView.prototype.afterRender = function() {
    this.$el.data('cid', this.model.cid);
    if (this.model.isUploading()) {
      return this.$el.addClass('warning');
    } else {
      return this.$el.removeClass('warning');
    }
  };

  TrackView.prototype.refresh = function() {
    return this.render();
  };

  TrackView.prototype.onTrackClicked = function(event) {
    var isShiftPressed;
    isShiftPressed = event.shiftKey || false;
    return window.selectedTracksList.onTrackClicked(this.model, isShiftPressed);
  };

  TrackView.prototype.changeSelectStat = function() {
    if (this.model.isSelected()) {
      return this.$el.addClass('success');
    } else {
      return this.$el.removeClass('success');
    }
  };

  return TrackView;

})(BaseView);
});

;require.register("views/content/track/tracks_view", function(exports, require, module) {
var TrackView, TracksView, ViewCollection,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

ViewCollection = require('../../../lib/view_collection');

TrackView = require('./track_view');


/*
 * TracksView is the structure for put tracks in content view
 */

module.exports = TracksView = (function(_super) {
  __extends(TracksView, _super);

  function TracksView() {
    return TracksView.__super__.constructor.apply(this, arguments);
  }

  TracksView.prototype.template = require('./templates/tracks');

  TracksView.prototype.el = '#display-screen';

  TracksView.prototype.itemview = TrackView;

  TracksView.prototype.collectionEl = '#table-items-content';

  TracksView.prototype.events = {
    'click tr.track-row': function(e) {
      return this.viewProxy('onTrackClicked', e);
    }
  };

  TracksView.prototype.initialize = function(options) {
    TracksView.__super__.initialize.call(this, options);
    this.listenTo(this.collection, 'change', _.partial(this.viewProxy, 'refresh'));
    return this.listenTo(this.collection, 'toggle-select', _.partial(this.viewProxy, 'changeSelectStat'));
  };

  TracksView.prototype.viewProxy = function(methodName, object) {
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

  return TracksView;

})(ViewCollection);
});

;require.register("views/content/track_skel", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div id=\"context-menu\"></div><div id=\"display-screen\"></div>");;return buf.join("");
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

;require.register("views/content_screen", function(exports, require, module) {
var ContentScreen, ContextMenu, EditionView, SelectedTracksList, TracksView;

ContextMenu = require('./context_menu');

SelectedTracksList = require('../collections/selected_list');

TracksView = require('../views/content/track/tracks_view');

EditionView = require('../views/content/edition/edition_view');

module.exports = ContentScreen = (function() {
  ContentScreen.prototype.skeletonTrack = require('./content/track_skel');

  ContentScreen.prototype.skeletonEdition = require('./content/edition_skel');

  function ContentScreen() {
    _.extend(this, Backbone.Events);
    this.baseCollection = window.app.baseCollection;
    this.selectedTracksList = new SelectedTracksList;
    this.selectedTracksList.baseCollection = this.baseCollection;
    this.listenTo(this.selectedTracksList, 'selectionTracksState', this.updateSelectionTracksState);
    this._collection = this.baseCollection;
  }

  ContentScreen.prototype.renderAllTracks = function() {
    $('#content-screen').append(this.skeletonTrack);
    this._contextMenu = new ContextMenu({
      selectedTracksList: this.selectedTracksList
    });
    this._collectionView = new TracksView({
      collection: this.baseCollection
    });
    this._collectionView.render();
    this.listenTo(this._contextMenu, 'lauchTracksEdition', this.lauchTracksEdition);
    return this._contextMenu.render();
  };

  ContentScreen.prototype.removeAllTracks = function() {
    this._contextMenu.remove();
    return this._collectionView.remove();
  };

  ContentScreen.prototype.updateSelectionTracksState = function(isUsed) {
    return this._contextMenu.manageActionTrackMenu(isUsed);
  };

  ContentScreen.prototype.lauchTracksEdition = function() {
    this._contextMenu.manageActionTrackMenu(false);
    this.removeAllTracks();
    return this.renderTracksEdition();
  };

  ContentScreen.prototype.renderTracksEdition = function() {
    $('#content-screen').append(this.skeletonEdition);
    this.editionView = new EditionView;
    this.listenTo(this.editionView, 'edition-end', this.finishEdition);
    return this.editionView.render();
  };

  ContentScreen.prototype.finishEdition = function() {
    this.removeTracksEdition();
    return this.renderAllTracks();
  };

  ContentScreen.prototype.removeTracksEdition = function() {
    return this.editionView.remove();
  };

  return ContentScreen;

})();
});

;require.register("views/context_menu", function(exports, require, module) {
var BaseView, ContextMenu,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../lib/base_view');


/*
 * Context_menu represent the menu on the top of the app. His goal is to work
 * with tracks_display. It must display the dynamiques option when the user select
 * one or several song in the tracks display.
 */

module.exports = ContextMenu = (function(_super) {
  __extends(ContextMenu, _super);

  function ContextMenu() {
    return ContextMenu.__super__.constructor.apply(this, arguments);
  }

  ContextMenu.prototype.el = '#context-menu';

  ContextMenu.prototype.template = require('./templates/context_menu');

  ContextMenu.prototype.trackMenuActive = false;

  ContextMenu.prototype.events = {
    'change #upload-files': 'lauchUploadFiles',
    'click #edit-tracks': function(e) {
      return this.trigger('lauchTracksEdition');
    },
    'click #fetch': 'fetchBaseCollection'
  };

  ContextMenu.prototype.afterRender = function() {
    this.uploader = $('#uploader');
    return this.$('#edit-tracks').hide();
  };

  ContextMenu.prototype.fetchBaseCollection = function() {
    return window.app.baseCollection.fetch();
  };

  ContextMenu.prototype.lauchUploadFiles = function(event) {
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

  ContextMenu.prototype.manageActionTrackMenu = function(isUsed) {
    if (isUsed === true) {
      return this.$('#edit-tracks').show();
    } else {
      return this.$('#edit-tracks').hide();
    }
  };

  return ContextMenu;

})(BaseView);
});

;require.register("views/left_menu", function(exports, require, module) {
var BaseView, LeftMenu,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../lib/base_view');


/*
 * LefMenu represent the main panel option. His goal is trigger the changing
 * of content in the tracks screen
 */

module.exports = LeftMenu = (function(_super) {
  __extends(LeftMenu, _super);

  function LeftMenu() {
    return LeftMenu.__super__.constructor.apply(this, arguments);
  }

  LeftMenu.prototype.template = require('./templates/left_menu');

  LeftMenu.prototype.tagName = 'div';

  LeftMenu.prototype.className = 'left-menu';

  LeftMenu.prototype.el = '#left-menu';

  return LeftMenu;

})(BaseView);
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

;require.register("views/templates/context_menu", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<ul class=\"nav nav-tabs\"><input id=\"upload-files\" name=\"upload-files\" type=\"file\" multiple=\"multiple\" accept=\"audio/*\" role=\"presentation\" class=\"btn btn-default btn-file\"/><li id=\"fetch\" role=\"presentation\" class=\"btn btn-default\">FETCH</li><li id=\"edit-tracks\" role=\"presentation\" class=\"btn btn-default\">EDIT</li></ul>");;return buf.join("");
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

;require.register("views/templates/left_menu", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"demo-content-left\"><h1>Left menu</h1><p>content</p><p>content</p><p>content</p><p>content</p><p>content</p><p>content</p></div>");;return buf.join("");
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