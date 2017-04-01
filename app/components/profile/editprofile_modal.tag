<editprofile>

<div id="editprofileModal" class="modal fade" role="dialog">
	<div class="modal-dialog">

		<div class="modal-content">
			<div class="header modal-header" if={ info }><button type="button" class="close" data-dismiss="modal">&times;</button></div>
			<div class="header modal-header" if={ !info }><button type="button" class="close fa fa-chevron-left" onclick={ this.back }></button></div>

			<div class="modal-body">
				<div if={loading} class="modal-body text-xs-center">
					<i class="fa fa-spinner fa-spin fa-3x fa-fw margin-bottom"></i>
					<span class="sr-only">Loading...</span>
				</div>

				<div id="info" if={!loading}>
					<div class="profile-image-container">
						<img src={ API.getCurrentUserProfilePicture() } class="img-circle profile-image" onclick={ this.showImageSearch } if={ !selectedImage }>
						<img src={ selectedImage.thumbnailUrl } class="img-circle profile-image" onclick={ this.showImageSearch } if={ selectedImage }>
					</div>
					<input type="text" name="fullname" id="fullname" placeholder="What's your name?" class="form-control"></input>
					<input type="text" name="about" id="about" placeholder="Tell us something about yourself" class="form-control"></input>
					<button class="edit-btn btn btn-primary" onclick={ submitEdit }>Done</button>
				</div>

				<imagesearch></imagesearch>

			</div>
		</div>

	</div>
</div>

<script>
	var self       = this
	editprofileTag = this
	self.info      = true
	self.loading   = false

	this.on('mount', function() {
		$('#editprofileModal').on('shown.bs.modal', function() {
			self.fullname.value = Parse.User.current().get('firstName') + ' ' + Parse.User.current().get('lastName')
			self.about.value    = Parse.User.current().get('about') ? Parse.User.current().get('about') : ''
			self.update()
		})
		$('#editprofileModal').on('hidden.bs.modal', function() {
			self.tags.imagesearch.hide()
			self.selectedImage = undefined
			self.info          = true
			self.loading       = false
			self.update()
		})
	})

	submitEdit() {
		self.loading = true
		self.update()

		var user          = Parse.User.current()
		var userFirstname = self.fullname.value.split(" ")[0]
		var userLastname  = self.fullname.value.indexOf(" ")==-1 ? '' : self.fullname.value.substring(self.fullname.value.indexOf(" ") + 1)

		user.set('firstName', userFirstname)
		user.set('lastName', userLastname)
		user.set('about', self.about.value)
		if (self.selectedImage) {
			user.set('profileImageURL', self.selectedImage.contentUrl)
			user.set('thumbnailUrl', self.selectedImage.thumbnailUrl)
		}
		user.save(null, {
			success: function(user) {
				profileTag.update()
				$('#editprofileModal').modal('hide')
				self.loading = true
				self.update()
			}, error: function(user, err) {}
		})
	}

	showImageSearch() {
		self.tags.imagesearch.update({callback: self.returnImageSearch})
		$('#info').slideUp({
			duration: 500,
			complete: function() {
				self.tags.imagesearch.show()
				self.info = false
				self.update()
			}
		})
	}

	returnImageSearch(result) {
		self.selectedImage = result
		self.update()
		self.back()
	}

	back() {
		self.tags.imagesearch.hide().then(function() {
			$('#info').slideDown({duration: 500})
			self.info = true
			self.update()
		})
	}
</script>

<style scoped>
	:scope {
		text-align: center;
	}

	.profile-image {
		width: 100px;
		height: 100px;
		object-fit: cover;
	}

	#info input {
		text-align: left;
		margin-top: 10px;
		border: none;
		border-bottom: 1px dashed #bbb;
	}

	#info input:focus {
		outline: none;
	}

	#fullname {
		font-size: x-large;
	}

	.edit-btn {
		margin-top: 10px;
	}
</style>
</editprofile>