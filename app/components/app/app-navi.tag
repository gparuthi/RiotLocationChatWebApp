<app-navi>

<nav class={navbar-gradient: home, navbar-nongradient: !home, navbar: true, navbar-static-top: containerTag.route!='groups', navbar-fixed-top: containerTag.route=='groups'}>
    <!-- <button class="navbar-toggler pull-xs-right hidden-sm-up" type="button" data-toggle="collapse" data-target="#exCollapsingNavbar2">
    &#9776;
    </button> -->
    <div class="navbar-toggleable-xs" id="exCollapsingNavbar2">
        <div class="navbar-brand" onclick={ goBack }>
            <a if={ containerTag.route!='groups' } class={pointer:true, fa:true, fa-chevron-left: true }><!-- <img id="arrow" alt="Logo" src="/images/back.png" > --></a>
            <span if={ containerTag.route!='groups' }>{ title }</span>
            <a if={ containerTag.route=='groups' } href="/groups"><img id="logo" alt="Logo" src="/images/app_icon.png" ></a>
            <span if={ containerTag.route=='groups' }>{ USER_LOCALE }</span>
        </div>

    <ul class="nav navbar-nav pull-xs-right">
      <!-- <li class={ nav-item: true, active: parent.selectedId === url }>
        <a class="nav-icon nav-link" onclick={ this.showSearch }><i class="fa fa-search fa-4"></i></a>
      </li>
      <li class={ nav-item: true, active: parent.selectedId === url }>
        <a class="nav-icon nav-link" onclick={ this.gotoSchedule }><i class="fa fa-calendar fa-4"></i></a>
      </li> -->

      <li class={ nav-item: true } onclick={ this.update } if={containerTag.route=='groups'}>
        <div class="btn-group profile-container ">
          <div class="notif-indicator" if={ notif && !signupAvail}></div>
          <img src={ API.getCurrentUserThumbnail() } class="img-circle dropdown-toggle profile-img pointer" data-toggle="dropdown"/>
          <ul class="dropdown-menu dropdown-menu-right">
            <li class="dropdown-item" if={ signupAvail } onclick={ this.showLogin }>
              <a class="nav-link" href="#">Log In</a>
            </li>
            <li class="dropdown-item" if={ signupAvail } onclick={ this.showSignup }>
              <a class="nav-link" href="#">Sign Up</a>
            </li>
            <li class="dropdown-item" if={ !signupAvail }>
              <a class="nav-link" href="#" onclick={ this.gotoNotification }>Notifications</a>
            </li>
            <li class="dropdown-item" if={ !signupAvail }>
              <a class="nav-link" href="#" onclick={ this.gotoProfile }>Profile</a>
            </li>
            <li class="dropdown-item" onclick={ this.sendfeedback }>
              <a class="nav-link" href="#">Feedback</a>
            </li>
            <li class="dropdown-item" if={ !signupAvail } onclick={ this.logout }>
              <a class="nav-link" href="#">Logout</a>
            </li>
          </ul>
        </div>
      </li>

      <li class="nav-item" if={containerTag.route=='posts'}>
        <div class="btn-group">
          <img class="btn dropdown-toggle ellipsis" data-toggle="dropdown" href="#" src="/images/settings.png" if={containerTag.route=='posts'}>
          <ul class="dropdown-menu dropdown-menu-right">
            <!-- <li class="dropdown-item" onclick={ this.showSearch }>
              <a class="nav-link" href="#">Search</a>
            </li> -->
            <li class="dropdown-item" onclick={ this.showShare }>
              <a class="nav-link" href="#">Share</a>
            </li>
            <li class="dropdown-item" if={ containerTag.group.get('creator').id == Parse.User.current().id } onclick={ this.showGroupInfo }>
              <a class="nav-link" href="#">Edit Group</a>
            </li>
          </ul>
        </div>
      </li>
    </ul>



    <!-- <form class="form-inline pull-xs-right">
      <input class="form-control" type="text" placeholder="Search">
      <button class="btn btn-success-outline" type="submit">Search</button>
    </form> -->
  </div>
</nav> <!-- /navbar -->




<script>
  var self         = this
  self.signupAvail = true
  self.home        = true
  self.title       = opts.title

  var r = riot.route.create()
  r(highlightCurrent)

  this.on('mount', function() {
    $(document).bind('scroll', function() {
      $('[data-toggle="dropdown"]').parent().removeClass('open')
    })
    $(document).bind('touchmove', function() {
      $('[data-toggle="dropdown"]').parent().removeClass('open')
    })

    self.checkNotification()
    self.notifCheck = setInterval(self.checkNotification, 30000)
  })

  function highlightCurrent(id) {
    self.selectedId = id
    self.update()
  }

  checkNotification() {
    var Notifications = Parse.Object.extend('Notifications')
    var query = new Parse.Query(Notifications)
    query.equalTo('pushedTo', Parse.User.current())
    query.equalTo('seen', false)
    query.first().then(function(notif) {
      if (notif) self.notif = true
      else self.notif = false
      self.update()
    })
  }

  sendfeedback(){
    window.location.href = "mailto:team@sophusapp.com"
  }

  this.on('update', function() {
    self.signupAvail = !Parse.User.current() || Parse.User.current().get('type') === 'dummy'

    if (self.parent.route == 'posts') self.home = true
    else self.home = false
  })

  getProfilePic(){
    var user = Parse.User.current()
    var profilePic = user.get('profileImageURL')
    if (profilePic){
      return profilePic
    }
  }

  showSignup() {
    $('#signupModal').modal('show')
  }

  showLogin() {
    $('#loginModal').modal('show')
  }

  showSearch() {
    $('#searchModal').modal('show')
  }

  showShare() {
    $('#shareModal').modal('show')
  }

  showGroupInfo() {
    riot.route('group/' + containerTag.group.get('groupId'))
    self.update()
  }

  gotoSchedule() {
    riot.route('schedule')
    self.update()
  }

  gotoProfile() {
    riot.route('profile')
    self.update()
  }

  gotoNotification() {
    self.notif = false
    riot.route('notif')
    self.update()
  }

  goBack() {

    if (containerTag.route=='posts')
      riot.route('/')
    else if (containerTag.route=='groupinfo')
      riot.route(containerTag.group.get('groupId'))
    else if (containerTag.route=='groups')
      return null
    else
      window.history.back()
  }

  logout() {
    Parse.User.logOut()
    self.update()
    riot.route('')
    window.location.reload()
  }
</script>

<style scoped>
  :scope {
    display: block;
    font-family: sans-serif;
    /*margin-right: 0;*/
    /*margin-bottom: 30px;*/
    /*margin-left: 50px;*/
    /*padding: 1em;*/
    /*text-align: center;*/
    color: white;
  }

  .home-brand {
    margin-top: 10px;
    margin-bottom: -5px;
  }

  .profile-container {
    border-radius: 50%;
    position: relative;
  }

  .notif-indicator {
    position: absolute;
    top: 0;
    right: 0;
    background-color: #47FF4A;
    width: 7px;
    height: 7px;
    -webkit-border-radius: 50%;
    -moz-border-radius: 50%;
    border-radius: 50%;
  }

  .navbar-gradient {
    background: -webkit-linear-gradient(rgba(0,0,0,0.9), rgba(0,0,0,0));
    background: -o-linear-gradient(rgba(0,0,0,0.9), rgba(0,0,0,0));
    background: -moz-linear-gradient(rgba(0,0,0,0.9), rgba(0,0,0,0));
    background: linear-gradient(rgba(0,0,0,0.9), rgba(0,0,0,0));
  }

  .navbar-nongradient {
    background: #2C3E50;
    box-shadow: 0px -3px 12px #888888;
  }

  .navbar{
    /*position: absolute;*/
/*    top: 0px;
    width: 100%;
    left: 0px;
    -webkit-border-radius: 0;
    -moz-border-radius: 0;*/
    border-radius: 0;
  }

  .navbar-brand {
    padding: 5px;
  }

  .navbar-brand a {
    color: white;
    text-decoration: none;
  }

  .nav {
    padding-top: 0.4rem;
  }

  .navbar-nav .nav-link {
    padding-top: .1rem;
    padding-bottom: 0;
  }

  .nav-item {
    color: black;
  }

  .nav-icon {
    font-size: large;
    color: black;
  }

  .ellipsis {
    padding: 0;
  }

  .profile-img{
    width: 38px;
    height: 38px;
    object-fit: cover;
  }

  .dropdown-item {
    padding-top: .425rem;
    padding-bottom: .425rem;
    color: #EEEEEE;
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

  #logo {
    height: 35px;
    display: inline-block;
  }

  #arrow {
    height: 25px;
  }


  @media (min-width: 480px) {
    :scope {
      /*margin-right: 200px;*/
      margin-bottom: 0;
    }
  }
</style>

</app-navi>