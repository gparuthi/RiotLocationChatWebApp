<signup>

<!-- Modal -->
<div id="signupModal" class="modal fade" role="dialog">
	<div class="modal-dialog">

		<!-- Modal content -->
		<div class="modal-content">
			<div class="modal-body" if={ loading }>
				<i class="fa fa-spinner fa-spin fa-3x fa-fw margin-bottom"></i>
				<span class="sr-only">Loading...</span>
			</div>

			<div if={!loading}>
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">&times;</button>
					<!-- <div class="updated text-muted" if={ needSignup }>You need to sign up first</div> -->
					<div class="facebook-option">
						<button class="btn btn-default btn-primary" onclick={ this.submitFacebook }>
							<i class="fa fa-facebook-f" id="facebook-logo"></i> Log in with Facebook
						</button>
					</div>
				</div>
				<div class="divider">
					<strong class="divider-title ng-binding">or</strong>
				</div>
				<div class="modal-body">
					<form>
						<div class="input-group">
							<span class="input-group-addon"><i class="fa fa-user fa-fw"></i></span>
							<input type="text" class="form-control" name="fullname" placeholder="Full name" />
						</div>
						<div class="input-group">
							<span class="input-group-addon"><i class="fa fa-envelope-o fa-fw"></i></span>
							<input type="email" class="form-control" name="email" placeholder="Email" />
						</div>
						<div class="input-group">
							<span class="input-group-addon"><i class="fa fa-key fa-fw"></i></span>
							<input type="password" class="form-control" name="password" placeholder="Password" />
						</div>

						<br/>
						<button class="btn btn-sm" name="submit" onclick={ this.submitSignup }>Join</button>
						<div class="text-warning info" if={ isError }>{ error }</div>
					</form>
						<div class="info">
							Already have an Account?
							<div class="text-info pointer inline" onclick={ this.showLogin }>Log In</div>
						</div>
				</div>
			</div>
		</div>

	</div>
</div>

<script>
	var self         = this
	signupTag        = this
	self.stayUpdated = opts.stayUpdated
	self.needSignup  = opts.needSignup
	self.caller      = opts.caller
	self.loading     = false
	self.isError     = false
	self.error       = ""

	this.on('mount', function(){
		self.stayUpdated = false

		$('#signupModal').on('shown.bs.modal', function() {
	    	$(document).bind("touchmove", function(e){
			    e.preventDefault();
			});
			self.track()
		})

		$('#signupModal').on('hidden.bs.modal', function () {
			$(document).unbind('touchmove');
			self.isError        = false
			self.error          = ""
			self.email.value    = ""
			self.password.value = ""
			self.fullname.value = ""
			self.stayUpdated    = false

			self.update()
		})
	})

	submitSignup(){
		if (self.checkValidity())
			self.showError(self.checkValidity())
		else {
			self.loading = true
			self.update()

			var user          = Parse.User.current()
			var userEmail     = self.email.value
			var userPassword  = self.password.value
			var userFullname  = self.fullname.value

			var userFirstname = userFullname.split(" ")[0]
			var userLastname  = userFullname.indexOf(" ")==-1 ? '' : userFullname.substring(userFullname.indexOf(" ") + 1)

			user.set('username', userEmail)
			user.set('password', userPassword)
			user.set('email', userEmail)
			user.set('firstName', userFirstname)
			user.set('lastName', userLastname)
			user.set("type", "actual")
			user.set("profileImageURL", undefined)
			user.set("needsWelcome", true)
			user.save(null, {
				success: function(user) {
					self.loading = false
					self.signupSuccess()
				},
				error: function(user, error) {
					self.loading = false
					self.update()

					self.isError = true
					self.error   = error.message
					self.update()
				}
			})
		}
	}

	submitFacebook() {
		self.loading = true
		self.update()

		API.FacebookLogin().then(function(response) {
			if (response) {
				self.loading = false
				self.signupSuccess()
			} else {
				self.loading = false
				self.update()
			}
		})
	}

	showLogin(){
		$('#signupModal').modal('hide')
		$('#loginModal').modal('show')
		loginTag.update({needSignup: self.needSignup, caller: self.caller})
	}

	checkValidity() {
		if (!self.validateEmail(self.email.value)) return 1
		if (self.password.value.length < 4) return 2
		if (self.password.value.length > 32) return 2
		if (self.fullname.value.length < 1) return 3
		return 0
	}

	validateEmail(email) {
    	var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    	return re.test(email);
	}

	signupSuccess() {
		$('#signupModal').modal('hide')
		if (self.needSignup) {
			self.caller.trigger('signedUp')
		} else {
			riot.route('')
		    window.location.reload()
		}
	}

	showError(errorCode) {
		self.isError = true
		switch(errorCode) {
			case 1:
				self.error = "Email is not valid. Please enter a valid email"
				break
			case 2:
				self.error = "Password should be from 4 to 32 characters of length"
				break
			case 3:
				self.error = "Fullname cannot be empty"
				break
			default:
				self.isError = false
				self.error   = ""
				break
		}

		self.update()
	}

</script>

<style scoped>
	:scope{
		text-align: center;
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

	.updated {
		margin-top: 0px;
		margin-bottom: 12px;
	}

	.inline {
		display: inline-block;
	}

	.input-group {
		margin-top: 7px;
	}

	.info {
		margin-top: 20px;
		margin-bottom: 10px;
	}

	.facebook-option {
		margin-top: 20px;
	}

	#facebook-logo {
		margin-right: 5px
	}

	.divider {
	    border-top: 1px solid #d9dadc;
	    display: block;
	    line-height: 1px;
	    margin: 15px 0;
	    position: relative;
	    text-align: center;
	}

	.divider .divider-title {
	    background: #fff;
	    font-size: 12px;
	    letter-spacing: 1px;
	    padding: 0 20px;
	    text-transform: uppercase;
	}

	.modal-header{
		border-bottom:0px;
	}

</style>

</signup>