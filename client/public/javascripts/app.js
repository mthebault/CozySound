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
var AlbumList, AppView, PlaylistList, QueueList, QueuePrevList, SelectionList, TracksList, UploadQueue;

AppView = require('./views/app_view');

TracksList = require('./collections/tracks_list');

UploadQueue = require('./collections/upload_queue');

AlbumList = require('./collections/album_list');

PlaylistList = require('./collections/playlists_list');

QueueList = require('./collections/queue_list');

QueuePrevList = require('./collections/queue_prev_list');

SelectionList = require('../collections/selection_list');


/*
 * Represent the app, all global variables must be set in it and not in window
 */

module.exports = {
  initialize: function() {
    var mainView;
    window.app = this;
    this.albumCollection = new AlbumList;
    this.baseCollection = new TracksList;
    this.playlistsCollection = new PlaylistList;
    this.playlistsCollection.fetch();
    this.soundManager = soundManager;
    this.selection = new SelectionList;
    this.selection.baseCollection = this.baseCollection;
    this.queue = new QueueList;
    this.queuePrev = new QueuePrevList;
    mainView = new AppView;
    mainView.render();
    this.baseCollection.fetch();
    this.soundManager.setup({
      debugMode: false,
      debugFlash: false,
      useFlashBlock: false,
      preferFlash: true,
      flashPollingInterval: 500,
      html5PollingInterval: 500,
      url: 'swf/',
      flashVersion: 9,
      onready: function() {
        return mainView.playerScreen.onReady();
      },
      ontimeout: function() {
        return mainView.playerScreen.onTimeout();
      }
    });
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

  PlaylistList.prototype.remove = function(model, options) {
    var listTracksId, modelDel, track, trackId;
    listTracksId = model.get('tracksId');
    while (true) {
      if (listTracksId.length === 0) {
        break;
      }
      trackId = listTracksId.pop();
      track = window.app.baseCollection.get(trackId);
      if (track != null) {
        track.removePlaylistId(model.id);
      }
    }
    modelDel = PlaylistList.__super__.remove.call(this, model, options);
    return modelDel.destroy({
      url: "playlist-list/" + modelDel.id,
      error: function(error) {
        return console.error(error);
      }
    });
  };

  return PlaylistList;

})(Backbone.Collection);
});

;require.register("collections/queue_list", function(exports, require, module) {
var QueueList, Track,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Track = require('./../models/track');

module.exports = QueueList = (function(_super) {
  __extends(QueueList, _super);

  function QueueList() {
    return QueueList.__super__.constructor.apply(this, arguments);
  }

  QueueList.prototype.model = Track;

  QueueList.name = null;

  QueueList.prototype.initialize = function() {
    this.selection = window.selection;
    return window.queue = this;
  };

  QueueList.prototype.addSelection = function() {
    var _results;
    _results = [];
    while (true) {
      if (this.selection.length === 0) {
        break;
      }
      _results.push(this.add(this.selection.shift()));
    }
    return _results;
  };

  QueueList.prototype.emptyQueue = function() {
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

  QueueList.prototype.populate = function(index, collectionName, collection) {
    var _results;
    this.name = collectionName;
    this.emptyQueue();
    _results = [];
    while (true) {
      if (index > collection.length) {
        break;
      }
      this.push(collection.at(index));
      _results.push(index++);
    }
    return _results;
  };

  QueueList.prototype.jumpInQueue = function(track) {
    var _results;
    this.name = 'queue';
    _results = [];
    while (true) {
      if (this.length === 0 || this.at(0) === track) {
        break;
      }
      _results.push(this.shift());
    }
    return _results;
  };

  return QueueList;

})(Backbone.Collection);
});

;require.register("collections/queue_prev_list", function(exports, require, module) {
var QueuePrevList, Track,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Track = require('./../models/track');

module.exports = QueuePrevList = (function(_super) {
  __extends(QueuePrevList, _super);

  function QueuePrevList() {
    return QueuePrevList.__super__.constructor.apply(this, arguments);
  }

  QueuePrevList.prototype.model = Track;

  return QueuePrevList;

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
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
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
    this.removeTracksFromSelection = __bind(this.removeTracksFromSelection, this);
    this.removeTrackFromPlaylists = __bind(this.removeTrackFromPlaylists, this);
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

  TracksList.prototype.setAlbum = function(model, album, options, callback) {
    var allOptions;
    allOptions = _.extend({
      add: true,
      remove: false,
      silent: true
    }, options);
    model = this.set(model, allOptions);
    model.album = album;
    if (!((options != null ? options.silent : void 0) === true)) {
      this.trigger('add', model);
    }
    if (callback != null) {
      return callback(model);
    }
  };

  TracksList.prototype.newWorker = function(albumId, queue, options, callback) {
    return window.app.albumCollection.fetchAlbumById(albumId, (function(_this) {
      return function(err, album) {
        if (err) {
          return console.error(err);
        }
        return queue.forEach(function(model) {
          return _this.setAlbum(model, album, options, callback);
        });
      };
    })(this));
  };

  TracksList.prototype.add = function(models, options, callback) {
    var album, albumId, isExist, model, newQueue, _results;
    if (!_.isArray(models)) {
      models = [models];
    }
    _results = [];
    while (true) {
      if (models.length === 0) {
        break;
      }
      model = models.pop();
      isExist = _.find(this.models, function(elem) {
        return elem === model;
      });
      if (!isExist && (model != null)) {
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
          _results.push(this.newWorker(albumId, newQueue, options, callback));
        } else {
          _results.push(this.setAlbum(model, album, options, callback));
        }
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  TracksList.prototype.removeTrackFromPlaylists = function(model) {
    var index, listIds, listPlaylists, playlist, _results;
    listIds = model.get('playlistsId');
    listPlaylists = window.app.playlistsCollection;
    index = 0;
    _results = [];
    while (true) {
      if (index >= listIds.length) {
        break;
      }
      playlist = listPlaylists.get(listIds[index]);
      playlist.removeTrackId(model.id);
      _results.push(index++);
    }
    return _results;
  };

  TracksList.prototype.removeTrackFromAlbum = function(model) {
    var album, albumId;
    albumId = model.get('album');
    album = window.app.albumCollection.get(albumId);
    return album.removeTrackId(model.id);
  };

  TracksList.prototype.remove = function(models, options) {
    var index, ret, _results;
    if (!_.isArray(models)) {
      models = [models];
    }
    index = 0;
    _results = [];
    while (true) {
      if (index >= models.length) {
        break;
      }
      this.removeTrackFromPlaylists(models[index]);
      this.removeTrackFromAlbum(models[index]);
      ret = TracksList.__super__.remove.call(this, models[index], options);
      ret.destroy({
        url: "track/" + ret.id,
        error: function(error) {
          return console.error(error);
        }
      });
      _results.push(index++);
    }
    return _results;
  };

  TracksList.prototype.removeTracksFromSelection = function() {
    var model, selection, _results;
    selection = window.selection;
    _results = [];
    while (true) {
      if (selection.length === 0) {
        break;
      }
      model = selection.pop();
      _results.push(this.remove(model));
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
      model: model,
      collection: this
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

  Album.prototype.removeTrackId = function(trackId) {
    var listIds, modelIndex;
    listIds = this.get('tracks');
    modelIndex = listIds.findIndex((function(_this) {
      return function(elem) {
        return elem === trackId;
      };
    })(this));
    listIds.splice(modelIndex, 1);
    return this.save({
      tracks: listIds
    });
  };

  return Album;

})(Backbone.Model);
});

;require.register("models/content_manager", function(exports, require, module) {
var AllTracksScreen, ContentManager, EditionScreen, PlaylistScreen, QueueScreen;

AllTracksScreen = require('../views/content/all_tracks_screen');

PlaylistScreen = require('../views/content/playlist_screen');

EditionScreen = require('../views/content/edition_screen');

QueueScreen = require('../views/content/queue_screen');


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
    window.app.contentManager = this;
    this.baseCollection = window.app.baseCollection;
    this.menu = window.app.menuScreen;
    this.selection = window.selection;
    this.loadedScreens = [];
    this.listenTo(this.menu, 'content-print-playlist', this.renderPlaylist);
    this.listenTo(this.menu, 'content-print-allTracks', this.renderAllTracks);
    this.listenTo(this.menu, 'content-print-queue', this.renderQueue);
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
      case 'queue':
        return this.removeQueue();
    }
  };

  ContentManager.prototype.renderAllTracks = function() {
    var allTracks;
    this.removeCurrentView();
    this.currentView = 'allTracks';
    if (this.loadedScreens['allTracks'] != null) {
      this.loadedScreens['allTracks'].attach();
      return;
    }
    allTracks = new AllTracksScreen({
      baseCollection: this.baseCollection
    });
    this.loadedScreens['allTracks'] = allTracks;
    allTracks.render();
    return this.listenTo(allTracks.menu, 'menu-trackEdition-lauch', this.renderTrackEdition);
  };

  ContentManager.prototype.removeAllTracks = function() {
    this.loadedScreens['allTracks'].detach();
    return this.currentView = null;
  };

  ContentManager.prototype.renderPlaylist = function(playlist) {
    var playlistId, view;
    playlistId = playlist.id;
    this.removeCurrentView();
    this.currentView = 'playlist';
    if (this.loadedScreens[playlistId]) {
      this.loadedScreens[playlistId].attach();
      this.playlistPrinted = this.loadedScreens[playlistId];
      return;
    }
    view = new PlaylistScreen({
      playlist: playlist
    });
    this.loadedScreens[playlistId] = view;
    this.listenTo(view, 'playlist-end', this.renderAllTracks);
    view.render();
    return this.playlistPrinted = view;
  };

  ContentManager.prototype.removePlaylist = function() {
    this.playlistPrinted.detach();
    this.playlistPrinted = null;
    return this.currentView = null;
  };

  ContentManager.prototype.renderTrackEdition = function() {
    var editionScreen;
    this.removeCurrentView();
    this.currentView = 'trackEdition';
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
    var _ref;
    if ((_ref = this.loadedScreens['trackEdition']) != null) {
      _ref.detach();
    }
    return this.currentView = null;
  };

  ContentManager.prototype.renderQueue = function() {
    var view;
    this.removeCurrentView();
    this.currentView = 'queue';
    if (this.loadedScreens['queue'] != null) {
      this.loadedScreens['queue'].attach();
      return;
    }
    view = new QueueScreen;
    this.loadedScreens['queue'] = view;
    return view.render();
  };

  ContentManager.prototype.removeQueue = function() {
    var _ref;
    if ((_ref = this.loadedScreens['queue']) != null) {
      _ref.detach();
    }
    return this.currentView = null;
  };

  ContentManager.prototype.getPrintedCollection = function() {
    switch (this.currentView) {
      case 'allTracks':
        return {
          collection: this.baseCollection,
          name: 'AllTracks'
        };
      case 'playlist':
        return {
          collection: this.playlistPrinted.playlist.collection,
          name: this.playlistPrinted.playlist.name
        };
      case 'queue':
        return {
          name: 'queue'
        };
    }
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
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

PlaylistItems = require('../collections/playlist_items');

PlaylistScreen = require('../views/content/playlist_screen');

module.exports = Playlist = (function(_super) {
  __extends(Playlist, _super);

  function Playlist() {
    this.removeTracksFromSelection = __bind(this.removeTracksFromSelection, this);
    return Playlist.__super__.constructor.apply(this, arguments);
  }

  Playlist.prototype.url = 'playlist-list';

  Playlist.prototype.defaults = {
    name: 'New Playlist'
  };

  Playlist.prototype.playlistView = null;

  Playlist.prototype.initialize = function() {
    this.collection = new PlaylistItems;
    this.baseCollection = window.app.baseCollection;
    return this.selection = window.selection;
  };

  Playlist.prototype.fetchTracks = function() {
    var listTracksId, remoteList;
    remoteList = [];
    listTracksId = this.get('tracksId');
    listTracksId.forEach((function(_this) {
      return function(id) {
        var track;
        track = _this.baseCollection.get(id);
        if (track) {
          return _this.collection.push(track);
        } else {
          return remoteList.push(id);
        }
      };
    })(this));
    if (remoteList.length > 0) {
      return this.fetchRemoteTracks(remoteList);
    }
  };

  Playlist.prototype.fetchRemoteTracks = function(listId) {
    return $.ajax({
      url: "tracks/fetch",
      data: {
        listId: listId
      },
      type: 'GET',
      error: function(xhr) {
        return console.error(xhr);
      },
      success: (function(_this) {
        return function(data) {
          return _this.baseCollection.add(data, null, function(tracks) {
            return _this.collection.add(tracks);
          });
        };
      })(this)
    });
  };

  Playlist.prototype.removeTrackId = function(trackId) {
    var modelIndex, playlistTracksId;
    playlistTracksId = this.get('tracksId');
    modelIndex = playlistTracksId.findIndex((function(_this) {
      return function(elem) {
        return elem === trackId;
      };
    })(this));
    playlistTracksId.splice(modelIndex, 1);
    this.save({
      tracksId: playlistTracksId
    });
    return this.collection.remove(trackId);
  };

  Playlist.prototype.addToPlaylist = function() {
    var listTracksId, track;
    listTracksId = this.get('tracksId');
    while (true) {
      if (this.selection.length === 0) {
        break;
      }
      track = this.selection.pop();
      if (!(_.find(listTracksId, function(elem) {
        return elem === track.id;
      }))) {
        this.collection.add(track);
        listTracksId.push(track.id);
        track.addPlaylist(this);
      }
    }
    return this.save('tracksId', listTracksId);
  };

  Playlist.prototype.remove = function(options) {
    var listTracksId, track, trackId;
    listTracksId = this.get('tracksId');
    while (true) {
      if (listTracksId.length === 0) {
        break;
      }
      trackId = listTracksId.pop();
      track = this.baseCollection.get(trackId);
      track.removePlaylistId(this.id);
    }
    return Playlist.__super__.remove.call(this, options);
  };

  Playlist.prototype.removeTracksFromSelection = function() {
    var track, _results;
    _results = [];
    while (true) {
      if (this.selection.length === 0) {
        break;
      }
      track = this.selection.pop();
      this.removeTrackId(track.id);
      _results.push(track.removePlaylistId(this.id));
    }
    return _results;
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

  Track.prototype.played = false;

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

  Track.prototype.isPlayed = function() {
    return this.played === true;
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

  Track.prototype.markAsPlayed = function() {
    this.played = true;
    return this.trigger('change', this);
  };

  Track.prototype.markAsNoPlayed = function() {
    this.played = false;
    return this.trigger('change', this);
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

  Track.prototype.addPlaylist = function(playlist) {
    var currentPlaylist, listPlaylist;
    listPlaylist = this.get('playlistsId');
    currentPlaylist = _.find(listPlaylist, function(elem) {
      return elem === playlist.id;
    });
    if (currentPlaylist == null) {
      listPlaylist.push(playlist.id);
      return this.save('playlistsId', listPlaylist);
    }
  };

  Track.prototype.removePlaylistId = function(playlistId) {
    var listIds, modelIndex;
    console.log('track: ', this.get('title'));
    console.log('playlist id: ', playlistId);
    listIds = this.get('playlistsId');
    modelIndex = listIds.findIndex((function(_this) {
      return function(elem) {
        return elem === playlistId;
      };
    })(this));
    listIds.splice(modelIndex, 1);
    return this.save({
      playlistsId: listIds
    });
  };

  return Track;

})(Backbone.Model);
});

;require.register("views/app_view", function(exports, require, module) {
var AppView, BaseView, ContentManager, MenuManager, PlayerScreen,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../lib/base_view');

MenuManager = require('../models/menu_manager');

ContentManager = require('../models/content_manager');

PlayerScreen = require('./player/player_screen');


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

  AppView.prototype.template = require('./home');

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
var AllTracksScreen, TracksListView, TracksMenuView;

TracksMenuView = require('./views/tracks_menu/tracks_menu_view');

TracksListView = require('./views/tracks_list_view');

module.exports = AllTracksScreen = (function() {
  AllTracksScreen.prototype.skeleton = require('./skeletons/all_tracks_skel');

  function AllTracksScreen(options) {
    _.extend(this, Backbone.Events);
    this.selection = window.selection;
    this.queue = window.app.queue;
    this.baseCollection = options.baseCollection;
    this.frame = $('#content-screen');
    this.frame.append(this.skeleton());
    this.menu = new TracksMenuView({
      selection: this.selection
    });
    this.listenTo(this.menu, 'track-management-remove', this.baseCollection.removeTracksFromSelection);
    this.listenTo(this.menu, 'track-add-queue', this.sendSelectionToQueue);
    this.tracks = new TracksListView({
      collection: this.baseCollection,
      selection: this.selection
    });
    this.listenTo(this.tracks, 'selection-menu-options', this.menu.manageOptionsMenu);
  }

  AllTracksScreen.prototype.sendSelectionToQueue = function() {
    this.queue.addSelection();
    return this.menu.manageOptionsMenu('empty');
  };

  AllTracksScreen.prototype.render = function() {
    this.selection.emptySelection();
    this.menu.render();
    return this.tracks.render();
  };

  AllTracksScreen.prototype.attach = function() {
    this.selection.emptySelection();
    this.menu.manageOptionsMenu('empty');
    this.frame.append(this.menu.el);
    return this.frame.append(this.tracks.el);
  };

  AllTracksScreen.prototype.detach = function() {
    this.menu.$el.detach();
    return this.tracks.$el.detach();
  };

  return AllTracksScreen;

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
var PlaylistMenuView, PlaylistScreen, PlaylistView, TracksListView;

PlaylistView = require('./views/playlist_view');

PlaylistMenuView = require('./views/playlist_menu_view');

TracksListView = require('./views/tracks_list_view');

module.exports = PlaylistScreen = (function() {
  PlaylistScreen.prototype.skeleton = require('./skeletons/playlist_skel');

  function PlaylistScreen(options) {
    _.extend(this, Backbone.Events);
    this.playlist = options.playlist;
    this.selection = window.selection;
    this.frame = $('#content-screen');
    this.frame.html(this.skeleton());
    this.header = new PlaylistView({
      playlist: this.playlist
    });
    this.menu = new PlaylistMenuView;
    this.listenTo(this.menu, 'remove-current-playlist', this.removePlaylist);
    this.listenTo(this.menu, 'remove-track-playlist', this.playlist.removeTracksFromSelection);
    this.tracks = new TracksListView({
      collection: this.playlist.collection,
      selection: this.selection
    });
    this.listenTo(this.tracks, 'selection-menu-options', this.menu.manageOptionsMenu);
  }

  PlaylistScreen.prototype.render = function() {
    this.selection.emptySelection();
    this.header.render();
    this.menu.render();
    this.tracks.render();
    return this.playlist.fetchTracks();
  };

  PlaylistScreen.prototype.attach = function() {
    this.selection.emptySelection();
    this.frame.append(this.header.el);
    this.frame.append(this.menu.el);
    return this.frame.append(this.tracks.el);
  };

  PlaylistScreen.prototype.detach = function() {
    this.header.$el.detach();
    this.menu.$el.detach();
    return this.tracks.$el.detach();
  };

  PlaylistScreen.prototype.removePlaylist = function() {
    window.app.playlistsCollection.remove(this.playlist);
    return this.trigger('playlist-end');
  };

  return PlaylistScreen;

})();
});

;require.register("views/content/queue_screen", function(exports, require, module) {
var QueueScreen, TracksListView;

TracksListView = require('./views/tracks_list_view');

module.exports = QueueScreen = (function() {
  QueueScreen.prototype.skeleton = require('./skeletons/queue_skel');

  function QueueScreen(options) {
    _.extend(this, Backbone.Events);
    this.queue = window.app.queue;
    this.queuePrev = window.app.queuePrev;
    this.selection = window.selection;
    this.player = window.app.player;
    this.frame = $('#content-screen');
    this.frame.append(this.skeleton());
    this.tracks = new TracksListView({
      collection: this.queue,
      selection: this.selection
    });
    console.log('queue Prev: ', this.queuePrev.models);
    this.queuePrevViews = new TracksListView({
      collection: this.queuePrev,
      selection: this.selection,
      el: '#table-screen-prev'
    });
  }

  QueueScreen.prototype.render = function() {
    this.selection.emptySelection();
    this.queuePrevViews.render();
    return this.tracks.render();
  };

  QueueScreen.prototype.attach = function() {
    this.selection.emptySelection();
    this.frame.append(this.tracks.el);
    return this.frame.append(this.queuePrevViews.el);
  };

  QueueScreen.prototype.detach = function() {
    this.tracks.$el.detach();
    return this.queuePrevViews.$el.detach();
  };

  return QueueScreen;

})();
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

buf.push("<div id=\"playlist-header\"></div><div id=\"playlist-menu\"></div><div id=\"table-screen\"></div>");;return buf.join("");
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

;require.register("views/content/skeletons/queue_skel", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div id=\"table-screen\"></div><div id=\"table-screen-prev\"></div>");;return buf.join("");
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

;require.register("views/content/templates/playlist", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
var locals_ = (locals || {}),playlist = locals_.playlist;
buf.push("<div class=\"page-header\"><h1>" + (jade.escape((jade_interp = playlist.name) == null ? '' : jade_interp)) + "</h1><div class=\"form-inline\"><div class=\"form-group\"><label for=\"playlist-change-name\" class=\"sr-only\">Playlist Name</label><input id=\"playlist-change-name\" type=\"text\" class=\"form-control\"/><button id=\"playlist-send-name\" class=\"btn btn-primary btn-log\">Change Name</button></div></div></div>");;return buf.join("");
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

;require.register("views/content/templates/playlist_menu", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div id=\"playlist-menu-button\" class=\"nav nav-tabs\"><button id=\"playlist-menu-remove-playlist\" role=\"presentation\" class=\"btn btn-default\">Remove Playlist</button><button id=\"playlist-menu-remove-track\" role=\"presentation\" class=\"btn btn-default\">Remove Track</button></div>");;return buf.join("");
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

;require.register("views/content/templates/queue", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

;return buf.join("");
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

;require.register("views/content/templates/tracks_menu/tracks_menu", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div id=\"tracks-menu-button\" class=\"nav nav-tabs\"><input id=\"tracks-menu-upload\" name=\"upload-files\" type=\"file\" multiple=\"multiple\" accept=\"audio/*\" role=\"presentation\" class=\"btn btn-default btn-file\"/><button id=\"tracks-menu-fetch\" role=\"presentation\" class=\"btn btn-default\">FETCH</button><div id=\"tracks-menu-playlist\" class=\"btn-group\"></div><button id=\"tracks-menu-remove\" role=\"presentation\" class=\"btn btn-default\">REMOVE</button><button id=\"tracks-menu-queue\" role=\"presentation\" class=\"btn btn-default\">Add to Up Next</button><button id=\"tracks-menu-edit\" role=\"presentation\" class=\"btn btn-default\">EDIT</button></div>");;return buf.join("");
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

;require.register("views/content/templates/tracks_menu/tracks_menu_list", function(exports, require, module) {
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

;require.register("views/content/templates/tracks_menu/tracks_menu_row", function(exports, require, module) {
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

;require.register("views/content/views/playlist_menu_view", function(exports, require, module) {
var BaseView, PlaylistMenuView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../../../../lib/base_view');

module.exports = PlaylistMenuView = (function(_super) {
  __extends(PlaylistMenuView, _super);

  function PlaylistMenuView() {
    this.manageOptionsMenu = __bind(this.manageOptionsMenu, this);
    return PlaylistMenuView.__super__.constructor.apply(this, arguments);
  }

  PlaylistMenuView.prototype.template = require('../templates/playlist_menu');

  PlaylistMenuView.prototype.el = '#playlist-menu';

  PlaylistMenuView.prototype.currentStatus = 'empty';

  PlaylistMenuView.prototype.events = {
    'click #playlist-menu-remove-playlist': function() {
      return this.trigger('remove-current-playlist');
    },
    'click #playlist-menu-remove-track': function() {
      return this.trigger('remove-track-playlist');
    }
  };

  PlaylistMenuView.prototype.afterRender = function() {
    this.menu = this.$('#playlist-menu-button');
    this.removeTrackButton = this.$('#playlist-menu-remove-track');
    return this.removeTrackButton.detach();
  };

  PlaylistMenuView.prototype.manageOptionsMenu = function(status) {
    if (status === 'empty') {
      if (this.currentStatus === 'several' || this.currentStatus === 'unique') {
        this.removeTrackButton.detach();
      }
      return this.currentStatus = status;
    } else if (status === 'several' || status === 'unique') {
      if (this.currentStatus === 'empty') {
        this.menu.append(this.removeTrackButton);
      }
      return this.currentStatus = status;
    }
  };

  return PlaylistMenuView;

})(BaseView);
});

;require.register("views/content/views/playlist_view", function(exports, require, module) {
var BaseView, PlaylistView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../../../../lib/base_view');

module.exports = PlaylistView = (function(_super) {
  __extends(PlaylistView, _super);

  function PlaylistView() {
    return PlaylistView.__super__.constructor.apply(this, arguments);
  }

  PlaylistView.prototype.template = require('../templates/playlist');

  PlaylistView.prototype.el = '#playlist-header';

  PlaylistView.prototype.events = function() {
    return {
      'click #playlist-send-name': 'changePlaylistName'
    };
  };

  PlaylistView.prototype.initialize = function(options) {
    this.playlist = options.playlist;
    return this.listenTo(this.playlist, 'change:name', this.render);
  };

  PlaylistView.prototype.getRenderData = function() {
    return {
      playlist: this.playlist.toJSON()
    };
  };

  PlaylistView.prototype.changePlaylistName = function() {
    var data;
    data = this.$('#playlist-change-name').val();
    this.playlist.set('name', data);
    return this.playlist.save();
  };

  return PlaylistView;

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

  TracksListView.prototype.selectTrack = function(view) {
    this.selection.emptySelection();
    this.selection.push(view.model);
    this._lastTrackSelected = view;
    return this.triggerMenuOption();
  };

  TracksListView.prototype.selectListTracks = function(view) {
    var endIndex, keys, startIndex, _results;
    this.selection.emptySelection();
    if (this._lastTrackSelected === null) {
      return this.selectTrack(view);
    }
    keys = _.keys(this.views);
    startIndex = keys.indexOf(this._lastTrackSelected.model.cid);
    endIndex = keys.indexOf(view.model.cid);
    _results = [];
    while (true) {
      this.selection.push(this.views[keys[startIndex]].model);
      if (startIndex === endIndex) {
        break;
      }
      if (startIndex < endIndex) {
        _results.push(startIndex++);
      } else {
        _results.push(startIndex--);
      }
    }
    return _results;
  };

  return TracksListView;

})(ViewCollection);
});

;require.register("views/content/views/tracks_menu/tracks_menu_list_view", function(exports, require, module) {
var MenuRowView, TracksMenuListView, ViewCollection,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

ViewCollection = require('../../../../../lib/view_collection');

MenuRowView = require('./tracks_menu_row_view');

module.exports = TracksMenuListView = (function(_super) {
  __extends(TracksMenuListView, _super);

  function TracksMenuListView() {
    return TracksMenuListView.__super__.constructor.apply(this, arguments);
  }

  TracksMenuListView.prototype.template = require('../../templates/tracks_menu/tracks_menu_list');

  TracksMenuListView.prototype.el = '#tracks-menu-playlist';

  TracksMenuListView.prototype.itemview = MenuRowView;

  TracksMenuListView.prototype.collectionEl = '#tracks-menu-playlist-content';

  TracksMenuListView.prototype.initialize = function() {
    this.collection = window.app.playlistsCollection;
    return TracksMenuListView.__super__.initialize.apply(this, arguments);
  };

  return TracksMenuListView;

})(ViewCollection);
});

;require.register("views/content/views/tracks_menu/tracks_menu_row_view", function(exports, require, module) {
var BaseView, TracksMenuRowView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../../../../../lib/base_view');

module.exports = TracksMenuRowView = (function(_super) {
  __extends(TracksMenuRowView, _super);

  function TracksMenuRowView() {
    return TracksMenuRowView.__super__.constructor.apply(this, arguments);
  }

  TracksMenuRowView.prototype.template = require('../../templates/tracks_menu/tracks_menu_row');

  TracksMenuRowView.prototype.className = 'tracks-menu-playlist-row';

  TracksMenuRowView.prototype.tagName = 'li';

  TracksMenuRowView.prototype.initialize = function() {
    this.$el.click((function(_this) {
      return function() {
        return _this.model.addToPlaylist();
      };
    })(this));
    return this.listenTo(this.model, 'change:name', this.render);
  };

  return TracksMenuRowView;

})(BaseView);
});

;require.register("views/content/views/tracks_menu/tracks_menu_view", function(exports, require, module) {
var BaseView, MenuListView, TracksMenuView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../../../../../lib/base_view');

MenuListView = require('./tracks_menu_list_view');


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

  TracksMenuView.prototype.template = require('../../templates/tracks_menu/tracks_menu');

  TracksMenuView.prototype.el = '#tracks-menu';

  TracksMenuView.prototype.currentStatus = 'empty';

  TracksMenuView.prototype.menu = null;

  TracksMenuView.prototype.uploader = null;

  TracksMenuView.prototype.editionButton = null;

  TracksMenuView.prototype.playlistButton = null;

  TracksMenuView.prototype.addQueueButton = null;

  TracksMenuView.prototype.removeButton = null;

  TracksMenuView.prototype.events = {
    'change #tracks-menu-upload': 'lauchUploadFiles',
    'click #tracks-menu-edit': function(e) {
      return this.trigger('menu-trackEdition-lauch');
    },
    'click #tracks-menu-remove': function(e) {
      return this.trigger('track-management-remove');
    },
    'click #tracks-menu-queue': function(e) {
      return this.trigger('track-add-queue');
    },
    'click #tracks-menu-fetch': 'fetchBaseCollection'
  };

  TracksMenuView.prototype.initialize = function(options) {
    return this.selection = options.selection;
  };

  TracksMenuView.prototype.afterRender = function() {
    this.menu = this.$('#tracks-menu-button');
    this.uploader = this.$('#tracks-menu-upload');
    this.editionButton = this.$('#tracks-menu-edit');
    this.playlistButton = this.$('#tracks-menu-playlist');
    this.addQueueButton = this.$('#tracks-menu-queue');
    this.removeButton = this.$('#tracks-menu-remove');
    this.listPlaylistsViews = new MenuListView;
    this.listPlaylistsViews.render();
    this.editionButton.detach();
    this.playlistButton.detach();
    this.removeButton.detach();
    return this.addQueueButton.detach();
  };

  TracksMenuView.prototype.fetchBaseCollection = function() {
    return window.app.baseCollection.fetch();
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
        this.menu.append(this.removeButton);
        this.menu.append(this.addQueueButton);
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
        this.addQueueButton.detach();
        this.removeButton.detach();
      } else if (this.currentStatus === 'several') {
        this.playlistButton.detach();
        this.addQueueButton.detach();
        this.removeButton.detach();
      }
      return this.currentStatus = status;
    } else if (status === 'several') {
      if (this.currentStatus === 'empty') {
        this.menu.append(this.removeButton);
        this.menu.append(this.addQueueButton);
        this.menu.append(this.playlistButton);
      } else if (this.currentStatus === 'unique') {
        this.editionButton.detach();
        this.menu.append(this.removeButton);
        this.menu.append(this.addQueueButton);
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

  TrackRowView.prototype.getRenderData = function() {
    var _ref, _ref1, _ref2;
    return {
      model: (_ref = this.model) != null ? _ref.toJSON() : void 0,
      album: (_ref1 = this.model) != null ? (_ref2 = _ref1.album) != null ? _ref2.toJSON() : void 0 : void 0
    };
  };

  TrackRowView.prototype.afterRender = function() {
    var clicks;
    this.$el.data('cid', this.model.cid);
    if (this.model.isUploading()) {
      this.$el.addClass('warning');
    } else if (this.model.isUploaded()) {
      this.$el.removeClass('warning');
    } else if (this.model.isErrored()) {
      this.$el.addClass('danger');
    } else if (this.model.isConflict()) {
      this.$el.addClass('info');
    }
    if (this.model.played === true) {
      this.$el.addClass('info');
    } else {
      this.$el.removeClass('info');
    }
    clicks = 0;
    return this.$el.click((function(_this) {
      return function(event) {
        clicks++;
        if (clicks === 1) {
          if (event.shiftKey) {
            clicks = 0;
            return _this.collection.selectListTracks(_this);
          }
          _this.collection.selectTrack(_this);
          return setTimeout(function() {
            if (clicks > 1) {
              window.app.player.onTrackDbClick(_this.model);
            }
            return clicks = 0;
          }, 300);
        }
      };
    })(this));
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

  TrackRowView.prototype.setAsSelected = function() {
    return this.$el.addClass('success');
  };

  TrackRowView.prototype.setAsNoSelected = function() {
    return this.$el.removeClass('success');
  };

  return TrackRowView;

})(BaseView);
});

;require.register("views/home", function(exports, require, module) {
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
    'click #menu-all-tracks': 'printAllTracks',
    'click #menu-queue': 'printQueue'
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

  MenuView.prototype.printQueue = function() {
    return this.trigger('content-print-queue');
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
    this.$el.click((function(_this) {
      return function() {
        return window.app.menuScreen.trigger('content-print-playlist', _this.model);
      };
    })(this));
    return this.listenTo(this.model, 'change:name', this.render);
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

buf.push("<label for=\"menu-section\">Section</label><ul id=\"menu-section\" class=\"nav nav-sidebar\"><li><a id=\"menu-all-tracks\">All Tracks</a></li><li><a id=\"menu-queue\">Up Next</a></li></ul><label for=\"menu-playlist\">Playlist</label><div id=\"menu-playlist\"></div>");;return buf.join("");
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

;require.register("views/player/player_screen", function(exports, require, module) {
var BaseView, PlayerScreen,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('../../lib/base_view');

module.exports = PlayerScreen = (function(_super) {
  __extends(PlayerScreen, _super);

  function PlayerScreen() {
    this.nextTrack = __bind(this.nextTrack, this);
    return PlayerScreen.__super__.constructor.apply(this, arguments);
  }

  PlayerScreen.prototype.template = require('./templates/player_screen');

  PlayerScreen.prototype.el = '#player-screen';

  PlayerScreen.prototype.volume = 50;

  PlayerScreen.prototype.currentSound = null;

  PlayerScreen.prototype.currentTrack = null;

  PlayerScreen.prototype.status = 'stop';

  PlayerScreen.prototype.initialize = function() {
    window.app.player = this;
    this.queue = window.app.queue;
    this.queuePrev = window.app.queuePrev;
    this.soundManager = window.app.soundManager;
    return this.allTracks = window.app.baseCollection;
  };

  PlayerScreen.prototype.events = {
    'click #player-play': 'onClickPlay',
    'click #player-next': 'nextTrack',
    'click #player-prev': 'prevTrack'
  };

  PlayerScreen.prototype.onReady = function() {
    return console.log('ready');
  };

  PlayerScreen.prototype.onTimeout = function() {
    return console.log('timeout');
  };

  PlayerScreen.prototype.onClickPlay = function() {
    if (this.currentTrack == null) {
      if (this.queue.length === 0) {
        this.queue.populate(0, 'allTracks', this.allTracks);
      }
      this.currentTrack = this.queue.shift();
      return this.lauchTrack();
    } else if (this.status === 'play') {
      return this.pauseTrack();
    } else if (this.status === 'pause') {
      this.currentSound.play();
      return this.status = 'play';
    }
  };

  PlayerScreen.prototype.onTrackDbClick = function(track) {
    var collection, index, name, _ref;
    if (this.currentTrack != null) {
      this.stopCurrentTrack();
      this.queuePrev.unshift(this.currentTrack);
    }
    _ref = window.app.contentManager.getPrintedCollection(), collection = _ref.collection, name = _ref.name;
    if (name === 'queue') {
      this.queue.jumpInQueue(track);
    } else {
      index = 0;
      while (true) {
        if (index > collection.length || collection.at(index) === track) {
          break;
        }
        index++;
      }
      this.queue.populate(index, name, collection);
    }
    this.currentTrack = this.queue.shift();
    return this.lauchTrack();
  };

  PlayerScreen.prototype.lauchTrack = function() {
    if (this.currentTrack == null) {
      console.log('no track');
      return;
    }
    this.status = 'play';
    this.currentTrack.markAsPlayed();
    return this.currentSound = this.soundManager.createSound({
      id: "sound-" + this.currentTrack.id,
      url: "track/binary/" + this.currentTrack.id,
      usePolicyFile: true,
      autoPlay: true,
      onfinish: this.nextTrack,
      onstop: this.stopCurrentTrack,
      multiShot: false
    });
  };

  PlayerScreen.prototype.pauseTrack = function() {
    this.currentSound.pause();
    return this.status = 'pause';
  };

  PlayerScreen.prototype.stopCurrentTrack = function() {
    var _ref;
    if ((_ref = this.currentTrack) != null) {
      _ref.markAsNoPlayed();
    }
    if ((this.status === 'play' || this.status === 'pause') && (this.currentSound != null)) {
      this.currentSound.destruct();
      this.currentSound = null;
    }
    return this.status = 'stop';
  };

  PlayerScreen.prototype.nextTrack = function() {
    this.stopCurrentTrack();
    this.queuePrev.unshift(this.currentTrack);
    this.currentTrack = this.queue.shift();
    return this.lauchTrack();
  };

  PlayerScreen.prototype.prevTrack = function() {
    this.stopCurrentTrack();
    this.queue.unshift(this.currentTrack);
    this.currentTrack = this.queuePrev.shift();
    return this.lauchTrack();
  };

  return PlayerScreen;

})(BaseView);
});

;require.register("views/player/templates/player_screen", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div role=\"group\" aria-label=\"...\" class=\"btn-group\"><button id=\"player-prev\" type=\"button\" class=\"btn btn-default\">PREV</button><button id=\"player-play\" type=\"button\" class=\"btn btn-default\">PLAY/PAUSE</button><button id=\"player-next\" type=\"button\" class=\"btn btn-default\">NEXT</button></div>");;return buf.join("");
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