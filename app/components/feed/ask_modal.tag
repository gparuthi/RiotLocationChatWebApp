<ask>
  <!-- <button type="button" class="btn btn-info btn-lg" data-toggle="modal" data-target="#askModal">Ask a new Question</button> -->
  <!-- Modal -->

  <div id="askModal" class="modal fade" role="dialog">

    <div  class="modal-dialog">

      <!-- Modal content-->
      <div class="modal-content" id="ask-modal">
        <div if={loading} class="modal-body text-xs-center">
          <i class="fa fa-spinner fa-spin fa-3x fa-fw margin-bottom"></i>
          <span class="sr-only">Loading...</span>
        </div>

        <div class="header modal-header">
          <button type="button" class="close" data-dismiss="modal">&times;</button>
        </div>

        <div if={!loading} class="modal-body">

          <div class="row">
            <div class="profile-container">
              <img class="profile-image img-circle pointer" if={ !anonymous } src={ API.getCurrentUserProfilePicture() } onclick={ this.toggleAnonymous }>
              <img class="profile-image img-circle pointer" if={ anonymous } src="/images/default_profile.png" onclick={ this.toggleAnonymous } >
              <div class="user-name text-muted" if={ !loggedIn }>
                <div class="handle-container">
                  <input class="handle" type="text" name="handle" placeholder= "Handle" if={ !loggedIn }></input>
                </div>
              </div>
              <div class="user-name text-muted" if={ loggedIn && anonymous }>Anonymous</div>
              <div class="user-name text-muted" if={ loggedIn && !anonymous }>{ Parse.User.current().get('firstName') } { Parse.User.current().get('lastName') }</div>
            </div>

            <div class="post-container">
              <div class="info-btns">
                <textarea rows="3" autofocus id="searchField" name="searchField" placeholder="Add reply" class="searchbox"></textarea>
                <div class="text-muted" id="topic" if={ topic!='' }>#{topic}</div>

              </div>
            </div>

            <div if={chosenImage}>
            <img id="chosen-image" src={ URL.createObjectURL(chosenImage) }>
            </div>

            <label for="post-image" class="btn btn-primary">Upload an image</label>
            <input type="file" id="post-image" style="display:none;">

            <div class="go text-xs-center">
              <button type="button" class="btn btn-primary go-btn" onclick={createQuestion}>Post</button>
              <div class="error text-warning" if={ isError }>{ error }</div>
            </div>
          </div>
        </div>

      </div>


    </div>
  </div>

  <script>
    askModalTag    = this
    var self       = this
    self.anonymous = false
    self.loggedIn  = false
    self.loading   = false
    self.isError   = false
    self.error     = ""
    self.topic     = ""

    this.on('mount', function(){
      $('#askModal').on('shown.bs.modal', function() {
        $(document).bind("touchmove", function(e){
            e.preventDefault();
        });
        if ($(window).width() >= 544) {
          $('#searchField').focus()
        } else {
          $('#searchField').blur()
        }

        if (Parse.User.current().get('type') == 'dummy') self.loggedIn = false
        else self.loggedIn = true

        if (self.parent.route == "topicsfeed")
          self.topic = topicsfeedtag.topicName

        self.update()
      })
      $('#askModal').on('hidden.bs.modal', function() {
        $(document).unbind('touchmove');
        self.isError           = false
        self.error             = ""
        self.loading           = false
        self.searchField.value = ""
        self.topic             = ""
        self.handle.value      = ""
        self.chosenImage       = undefined
        self.update()
      })

      $(document).on('change', '#post-image', self.handleUpload)
    })

    init(){
      self.topic             = ""
      self.searchField.value = ""
      self.update()
    }

    handleUpload() {
      self.chosenImage = $('#post-image')[0].files[0]
      self.update()
    }

    show(){
      $('#askModal').modal('show')
    }

    hide(){
      $('#askModal').modal('hide')
    }

    toggleAnonymous() {
      if (self.loggedIn) {
        self.anonymous = !self.anonymous
        self.update()
      }
    }

    createQuestion(){
      self.loading = true
      self.update()

      var content = self.searchField.value
      if (content.length < 5) {
        self.isError = true
        self.error = "Posts must be at least 5 characters long"
        self.loading = false
        self.update()
        return
      }

      var post = new Post()

      var currentUser = Parse.User.current()

      if (!self.loggedIn && self.handle.value != '') {
        var userFirstname = self.handle.value.split(" ")[0]
        var userLastname  = self.handle.value.indexOf(" ")==-1 ? '' : self.handle.value.substring(self.handle.value.indexOf(" ") + 1)
        currentUser.set('firstName', userFirstname)
        currentUser.set('lastName', userLastname)
        currentUser.save()
      }

      post.set("content",content)
      post.set("author",currentUser)
      post.set("newsFeedViewsBy",[])
      post.set("answerCount",0)
      post.set("viewcount",0)
      post.set("wannaknowCount",0)
      post.set("topic", self.topic)
      post.set("anonymous", self.anonymous)
      post.set("group", containerTag.group)

      if (self.chosenImage) {
        API.uploadImage(self.chosenImage).then(function(result) {
          post.set("imageURL", result)
          post.save().then(function() {
            self.loading=false
            homefeedTag.init()
            self.hide()
            self.init()
          })
        })
      } else {
        post.save().then(function() {
          self.loading=false
          homefeedTag.init()
          self.hide()
          self.init()
        })
      }

      // .then(function(){
      //   var Wannaknow = Parse.Object.extend('WannaKnow')
      //   var wannaknow = new Wannaknow()
      //   wannaknow.save({
      //     post: post,
      //     user: Parse.User.current()
      //   },{
      //     success: function(post) {
      //       //self.trigger('posted')
      //     },
      //     error: function(post, error) {
      //       self.isError = true
      //       self.error = error.message
      //       self.update()
      //     }
      //   })
      // })
    }

  </script>

  <style scoped>
    :scope{
      text-align: center;
    }

    #ask-modal {
      min-height: 250px;
    }

    .modal-content {
      background-color: #F5F5F5;
      min-height: 300px
    }

    .header {
      border: none;
      padding-right: 10px;
      padding-top: 10px;
      padding-bottom: 0;
    }

    .user-name {
      color: #616161;
      margin-top:15px;
    }

    .searchbox{
      overflow:hidden;
      resize: none;
      text-align: left;
      min-height: 45px!important;
      margin-bottom: 10px;
      width: 100%;
      font-size: 24px;
      padding: 7px 15px;
      padding-right: 0;
      border: none;
      background-color: #F5F5F5;
    }

    .searchbox:focus {
      outline: none;
    }

    #chosen-image {
      max-height: 100px;
      -webkit-border-radius: 5px;
      -moz-border-radius: 5px;
      border-radius: 5px;
    }

    #topic {
      text-align: left;
      padding-left: 10px;
      margin-bottom: 10px;
    }

    .handle-container {
      text-align: center;
      margin-top: 10px;
    }

    .handle {
      border: none;
      border-bottom: 1px solid #BBBBBB;
      background-color: #F5F5F5;
      text-align: center;
    }

    .handle:focus {
      outline: none;
    }

    .go{
      margin-top: 20px;
      margin-bottom: 10px;
    }

    .go-btn {
      padding: 5px 20px;
    }

    .error {
      margin-top: 10px;
    }

    .pointer:hover {
      cursor: pointer;
      -webkit-touch-callout: none;
      -webkit-user-select: none;
      -khtml-user-select: none;
      -moz-user-select: none;
      -ms-user-select: none;
      user-select: none;
    }

    @media screen and (min-width: 544px) {
      .profile-image {
        height: 70px;
        width: 70px;
      }
      .post-container {
        margin-top: 40px;
      }
      .user-name {
        font-size: large;
      }
      .searchbox {
        font-size: 24px;
      }
    }

    @media screen and (max-width: 543px) {
      .profile-image {
        height: 35px;
        width: 35px;
      }
      .post-container {
        margin-top: 0px;
      }
      .profile-container {
        padding: .2rem;
      }
      .user-name {
        font-size: small;
      }
      .searchbox {
        font-size: 20px;
      }
    }
  </style>

</ask>