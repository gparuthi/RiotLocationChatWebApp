
    loader = riot.observable();


API = {
  fetchOne: function(className, key, value){
    var promise = new Parse.Promise();
    var Class = Parse.Object.extend(className);
    var query = new Parse.Query(Class);
    query.equalTo(key, value);
    query.first().then(function(object) {
        if (object) {
          promise.resolve(object);
        } else {
          promise.reject();
        }
    }, function(err) {
        console.error('query failed: ' + JSON.stringify(err));
    });
    return promise;
  },

  getProfilePicture: function(user) {
    if (!user.get('profilePic')){
      if (user.get('profileImageURL')){
        return user.get('profileImageURL');
      }
      return '/images/default_profile.png';

    }else {
      profilePic = user.get('profilePic').url();
      if (profilePic){
        return profilePic;
      }
    }
  },

  getProfileThumbnail: function(user) {
    if (user.get('thumbnailUrl')) return user.get('thumbnailUrl');
    else return '/images/default_profile.png';
  },

  getCurrentUserProfilePicture: function() {
    var user = Parse.User.current();

    if (!user || user.get('type') == 'dummy')
      return '/images/default_profile.png';

    return API.getProfilePicture(user);
  },

  getCurrentUserThumbnail: function() {
    var user = Parse.User.current();

    if (!user || user.get('type')=='dummy')
      return '/images/default_profile.png';

    return API.getProfileThumbnail(user);
  },

  getObjectForTopic: function(topicTitle){
    var promise = new Parse.Promise();
    var topicQuery = new Parse.Query(Topic);
    topicQuery.equalTo('name', topicTitle);
    topicQuery.find().then(function(topic){
      if (topic){
        if (topic[0])
          promise.resolve(topic[0]);
      }
    });
    return promise;
  },
  getDetailsForPost: function(post_id, fn){

    loader.trigger('start');
    var promise = new Parse.Promise();

    var postQuery = new Parse.Query(Post);
    var foundPost;
    var foundTopicImageForPost;

    postQuery.include('author');
    postQuery.get(post_id).then(function(post) {
      if (post) {


      foundPost = post;


      var commentQuery = new Parse.Query("Answer");
      commentQuery.equalTo('post', post);
      commentQuery.ascending('createdAt');
      commentQuery.include('author');
      return commentQuery.find();


    } else {
      return [];
    }
  }).then(function(answers) {
    var topics = foundPost.get('topics');
    var topicQuery = new Parse.Query(Topic);
    topicQuery.containedIn('name', topics);
    topicQuery.find().then(function(topics){
      if (topics){
        foundTopicImageForPost = _.chain(topics)
        .filter(function(topic){return (typeof topic.get('image') != 'undefined')})
        .map(function(topic){return topic.get('image').url()})
        .value();
        foundTopicImageForPost.push('/images/header.jpg');
      }
      promise.resolve( {
        post: foundPost,
        topicImage: foundTopicImageForPost[0],
        answers: answers
      });

    });



  },
  function(err) {
    console.error("failed to query answers: " + JSON.stringify(err));
  });


  return promise;
},

getanswersforpost: function(post){
  loader.trigger('start');
  var promise = new Parse.Promise();

  var query = new Parse.Query("Answer");
  query.equalTo("post", post);
  query.include('author');
  query.find().then(function(answers) {
    loader.trigger('done');
    promise.resolve(answers);
  }, function(err) {
    console.error("failed to query answers: " + JSON.stringify(err));
  });
  return promise;
},
constructFeed: function(){
  loader.trigger('start');
  var promise = new Parse.Promise();
  Parse.Cloud.run("constructFeed").then(function(results){
    loader.trigger('done');
    promise.resolve(results);
  }, function(err) {
    console.error("failed to query posts: " + JSON.stringify(err));
  });
  return promise;
},

getallposts: function(limit){
  limit = limit || 1000;
  loader.trigger('start');
  var promise = new Parse.Promise();
  var query = new Parse.Query(Post);
  query.equalTo('group', containerTag.group);
  query.ascending('createdAt');
  query.include('author');
  query.limit(limit);
  query.find().then(function(results) {
    loader.trigger('done');
    promise.resolve(results);
  },
  function(err) {
    console.error("failed to query answers: " + JSON.stringify(err));
  });
  return promise;
},
constructQuestionsForTopic: function(topic){
  var promise = new Parse.Promise();
  var query = new Parse.Query(Post);
  query.equalTo("topic", topic);
  query.descending('wannaknowCount');
  query.find().then(function(results) {
    promise.resolve(results);
  },
  function(err) {
    console.error("failed to query answers: " + JSON.stringify(err));
  });

  return promise;
},
getallgroups: function(type, filter) {
  loader.trigger('start');
  var promise = new Parse.Promise();

  var query1 = new Parse.Query(Parse.Object.extend('Group'));
  if (type) query1.equalTo("type", type);
  if (filter) query1.contains('lowerName', filter.toLowerCase());
  query1.notEqualTo('deleted', true);

  var query2 = new Parse.Query(Parse.Object.extend('Group'));
  if (type) query2.equalTo("type", type);
  if (filter) query2.contains('keywords', filter.toLowerCase());
  query2.notEqualTo('deleted', true);

  var query = new Parse.Query.or(query1, query2);
  query.find().then(function(results) {
    loader.trigger('done');
    results = results.filter(function(event) { return API.distance(event.get('location'), USER_POSITION) <= 1600; });
    results.sort(API.comparedistance);
    promise.resolve(results);
  },
  function(err) {
    console.error("failed to query groups: " + JSON.stringify(err));
  });
  return promise;
},
getjoinedgroups: function(user) {
  var promise = new Parse.Promise();
  var query = new Parse.Query(Parse.Object.extend('UserGroup'));
  query.include('group');
  query.equalTo('user', user);
  query.descending('createdAt');

  query.find().then(function(results) {
    results = results.filter(function(result) { return !result.get('group').get('deleted')})
    promise.resolve(results);
  }, function(err) {
    console.error("failed to query joined groups: " + JSON.stringify(err));
  });
  return promise;
},
getusercity: function(userlocation) {
  var promise = new Parse.Promise();
  var geocoder = new google.maps.Geocoder;
  userlocation = {lat: userlocation.latitude, lng: userlocation.longitude};
  geocoder.geocode({'location': userlocation}, function(results, status) {
    if (status === google.maps.GeocoderStatus.OK) {
      for (var i = 0; i < results.length; i++)
        if (results[i].types[0] == 'locality') {
          promise.resolve(results[i].address_components[0].long_name);
        }
    }
  });
  return promise;
},
distance: function(p1, p2) {
  var R = 6371;
  var dLat = (p2.latitude - p1.latitude) * Math.PI / 180;
  var dLong = (p2.longitude - p1.longitude) * Math.PI / 180;
  var lat1 = p1.latitude * Math.PI / 180;
  var lat2 = p2.latitude * Math.PI / 180;

  var a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.sin(dLong/2) * Math.sin(dLong/2) * Math.cos(lat1) * Math.cos(lat2);
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
},
comparedistance: function(groupA, groupB) {
  if (API.distance(groupA.get('location'), USER_POSITION) > API.distance(groupB.get('location'), USER_POSITION)) return 1;
  else if (API.distance(groupA.get('location'), USER_POSITION) < API.distance(groupB.get('location'), USER_POSITION)) return -1;
  else return 0;
},
getActiveUsers: function(group, limit) {
  limit = limit || 5;
  var promise = new Parse.Promise();
  var query = new Parse.Query(Parse.Object.extend('UserGroup'));
  query.limit(limit);
  query.equalTo('group', group);
  query.descending('createdAt');
  query.find().then(function(results) {
    promise.resolve(results);
  },
  function(err) {
    console.error("failed to query most active users: " + JSON.stringify(err));
  });
  return promise;
},
getGroupImage: function(group) {
  if (!group.get('image')){
      if (group.get('imageUrl')){
        return group.get('imageUrl');
      }
      return '/images/default_image.jpg';

    }else {
      image = group.get('image').url();
      if (image){
        return image;
      }
    }
},
getGroupThumbnail: function(group) {
  if (group.get('thumbnailUrl')) return group.get('thumbnailUrl');
  else return '/images/default_image.jpg';
},
uploadImage: function(file) {
  var promise = new Parse.Promise();

  var serverUrl = 'https://api.parse.com/1/files/' + file.name;
  var image = new Image;
  image.onload = function() {
    $.ajax({
      type: "POST",
      beforeSend: function(request) {
        request.setRequestHeader("X-Parse-Application-Id", 'YDTZ5PlTlCy5pkxIUSd2S0RWareDqoaSqbnmNX11');
        request.setRequestHeader("X-Parse-REST-API-Key", 'TkCtS0607l5lfgiO65FbNc5zudsLcADDwPcQS1Va');
        request.setRequestHeader("Content-Type", file.type);
      },
      url: serverUrl,
      data: file,
      processData: false,
      contentType: false,
      success: function(data) {
        promise.resolve(data.url.replace("http", "https"));
      },
      error: function(data) {
        promise.resolve(false);
      }
    });
  };
  image.src = URL.createObjectURL(file);

  return promise;
},
resizeImage: function(file) {
  var promise = new Parse.Promise();

  var MAX_WIDTH = 150;
  var MAX_HEIGHT = 150;
  var image = new Image;
  image.onload = function() {
    var canvas = document.createElement('canvas');
    var ctx = canvas.getContext('2d');
    ctx.drawImage(image, 0, 0);

    var width = image.width;
    var height = image.height;
    if (width > height) {
      if (width > MAX_WIDTH) {
        height *= MAX_WIDTH / width;
        width = MAX_WIDTH;
      }
    } else {
      if (height > MAX_HEIGHT) {
        width *= MAX_HEIGHT / height;
        height = MAX_HEIGHT;
      }
    }
    canvas.width = width;
    canvas.height = height;
    var ctx = canvas.getContext("2d");
    ctx.drawImage(image, 0, 0, width, height);
    canvas.toBlob(function(blob) {
      promise.resolve(blob);
    });
  }
  image.src = URL.createObjectURL(file);

  return promise;
},
searchImage: function(query) {
  var promise = new Parse.Promise();

  $.ajax({
    url: '//sophus-web.herokuapp.com/search/' + query
  }).then(function(data){
    promise.resolve(data.results);
  });

  return promise;
},
getImageThroughProxy: function(image) {
  var promise = new Parse.Promise()

  var url = image.MediaUrl
  var xhr = API.createCORSRequest('GET', '//sophus-web.herokuapp.com/proxy/' + encodeURIComponent(url));
  if (!xhr) {
    console.log('cannot create XHR');
    promise.resolve(false);
  }

  xhr.onload = function() {
    var blob = new Blob([xhr.response], {type: 'image/png'});
    var url = (window.URL || window.webkitURL).createObjectURL(blob);
    promise.resolve({contentUrl: url, thumbnailUrl: image.Thumbnail.MediaUrl});
  }
  xhr.onerror = function(err) {
    promise.resolve(false);
  }

  xhr.send();
  return promise;
},
createCORSRequest: function(method, url) {
  var xhr = new XMLHttpRequest();
  xhr.responseType = 'arraybuffer';
  if ("withCredentials" in xhr) {
    // XHR for Chrome/Firefox/Opera/Safari.
    xhr.open(method, url, true);
  } else if (typeof XDomainRequest != "undefined") {
    // XDomainRequest for IE.
    xhr = new XDomainRequest();
    xhr.open(method, url);
  } else {
    // CORS not supported.
    xhr = null;
  }
  return xhr;
},
FacebookLogin: function() {
  var promise = new Parse.Promise();

  var checkUser = function(authResponse) {
    var User    = Parse.Object.extend('User');
    var query   = new Parse.Query(User);
    query.equalTo('facebookID', authResponse.userID);

    query.first().then(function(response) {
      if (response) login(response);
      else populateUser();
    });
  };
  var populateUser = function() {
    var user = Parse.User.current();
    FB.api('/me?fields=first_name, last_name, picture, email', function(response) {
      user.set('firstName', response.first_name);
      user.set('lastName', response.last_name);
      user.set('email', response.email);
      user.set('username', response.email);
      user.set('profileImageURL', response.picture.data.url);
      user.set('thumbnailUrl', response.picture.data.url);
      //user.set('friends', response.friends.data);
      user.set('facebookID', response.id);
      user.setPassword(response.id);
      user.set('type', 'actual');
      user.save(null, {
        success: function(user) {
          promise.resolve(true);
        },
        error: function(user, error) {
          promise.resolve(false);
        }
      })
    })
  };
  var login = function(user) {
    Parse.User.logOut().then(function() {
      Parse.User.logIn(user.get('email'), user.get('facebookID'), {
        success: function(user) { promise.resolve(true); },
        error: function(user, error) { promise.resolve(false); }
      })
    });
  }

  FB.getLoginStatus(function(response) {
    if (response.status == 'connected') {
      checkUser(response.authResponse);
    } else {
      FB.login(function(response) {
        if (response.status == 'connected') {
          checkUser(response.authResponse);
        } else {
          promise.resolve(false);
        }
      }, {scope: 'public_profile,email'});
    }
  });

  return promise;
}
};