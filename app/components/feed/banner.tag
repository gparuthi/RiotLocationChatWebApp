<banner>
<div class="banner-container">
	<div class="background-image" id="background">
	</div>

	<div class="row group-info">
		<div class="col-md-10 col-md-offset-1 col-lg-8 col-lg-offset-2">
			<div class="group-name">{ containerTag.group.get('name') }</div>
			<div class="members text-muted">{ locale } • { memberCount } joined</div>
			
			<div>
				<hr>
				<div class="group-desc">{ containerTag.group.get('description') }</div>
				<div class="join-group" onclick={ this.submitJoin } if={ !joined }>Follow</div>
				<div class="join-group" onclick={ this.removeJoin } if={ joined }>Unfollow</div>


			</div>

		</div>
	</div>
	<div class="row">
		<p if={containerTag.group.get('type')==='event'}><a onclick={showfeed}> Discuss </a> | <a onclick={showtweets}> Tweets </a> </p>
	</div>
</div>

<script>
	var self         = this
	bannerTag        = this
	self.joined      = false
	self.locale      = ''
	self.memberCount = 0

	this.on('mount', function() {
		self.init()

		self.on('signedUp', self.submitJoin)
	})

	showfeed(){
		riot.route(containerTag.group.get('groupId'))
	}
	showtweets(){
		riot.route(containerTag.group.get('groupId')+'/tweets')
	}

	init() {
		API.getActiveUsers(containerTag.group, 5).then(function(results) {
			self.mostActive = []
			for (var i = 0; i < results.length; i++) self.mostActive.push(results[i].get('user'))
			self.update()
		})
		API.getusercity(containerTag.group.get('location')).then(function(result) {
			self.locale = result
			self.update()
		})

		if (groupsTag.joinedGroups) {
			self.joined = true
			for (var i = 0; i < groupsTag.groups.length; i++) {
				if (groupsTag.groups[i].id == containerTag.group.id)
					self.joined = false
			}
			self.update()
		} else {
			API.getjoinedgroups(Parse.User.current()).then(function(groups) {
				groups = groups.filter(function(group) { return group.get('group').id == containerTag.group.id })
				if (groups.length == 0) self.joined = false
				else self.joined = true
				self.update()
			})
		}

		self.memberCount = containerTag.group.get('memberCount')
		$('#background').css("background-image", "url('" + API.getGroupImage(containerTag.group) + "')")
		self.update()
	}

	submitJoin() {
		if (Parse.User.current().get('type') == 'dummy') {
			$('#signupModal').modal('show')
			signupTag.update({needSignup: true, caller: this})
			return null
		}

		self.joined = true
		self.memberCount++
		self.update()

		var UserGroup = Parse.Object.extend('UserGroup')
		var userGroup = new UserGroup()
		userGroup.save({
			user: Parse.User.current(),
			group: containerTag.group
		},{
			success: function(userGroup) {
				if (self.mostActive.length < 5) self.mostActive.push(Parse.User.current())
				else self.mostActive[4] = Parse.User.current()
				self.update()
				containerTag.group.set('memberCount', containerTag.group.get('memberCount') + 1)
				containerTag.group.save()
			},
			error: function(userGroup, error) {
				console.error("Error saving UserGroup " + error.message)
				self.joined = false
				self.memberCount--
				self.update()
			}
		})
	}

	removeJoin() {
		self.joined = false
		self.memberCount--
		self.update()

		var UserGroup = Parse.Object.extend('UserGroup')
		var query     = new Parse.Query(UserGroup)
		query.equalTo('group', containerTag.group)
		query.equalTo('user', Parse.User.current())
		query.first().then(function(object) {
			if (object) {
				object.destroy()
				containerTag.group.set('memberCount', containerTag.group.get('memberCount') - 1)
				containerTag.group.save()
			}
		})
	}

</script>

<style scoped>
	.banner-container {
		margin-top: -57px;
	}

	.background-image {
		background-size: cover;
    	background-repeat: no-repeat;
    	background-position: 50% 50%;
		height: 160px;
	}

	.group-info {
		background-color: white;
		padding: 10px;
		margin-bottom: 5px;
		box-shadow: 0 2px 5px #cccccc;
	}

	.group-name {
		text-align: center;
		font-size: 20px;
	}

	.members {
		font-size: 14px;
		margin-bottom: 10px;
		text-align: center;
	}

	.join-group {
		margin: 0 auto; 
		text-align: center;
		padding: 8px 15px;
		font-size: large;
		color: white;
		background: #4e83ff;
		-webkit-border-radius: 5px;
    	-moz-border-radius: 5px;
    	border-radius: 5px;
    	max-width: 200px;
	}

	.most-active-container {
		padding-bottom: 10px;
	}

	.most-active {
		margin-right: 10px;
		display: inline-block;
	}

	.most-active-picture {
		width: 35px;
		height: 35px;
		border: 2px solid white;
	}

	.group-desc {
		padding: 16px 0;
		font-size: 14px;
	}

	.inline {
		display: inline-block;
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

	hr{
		margin: auto 0;
	}


	@media screen and (min-width: 534px) {
		.background-image {
			height: 300px;
		}
	}
</style>

</banner>