<creategroup>

	<div id="creategroupModal" class="modal fade" role="dialog">
		<div class="modal-dialog">

			<!-- Modal content -->
			<div class="modal-content">
				<div class="header modal-header" if={ info }><button type="button" class="close" data-dismiss="modal">&times;</button></div>
				<div class="header modal-header" if={ !info }><button type="button" class="close fa fa-chevron-left" onclick={ this.back }></button></div>

				<div if={loading} class="modal-body text-xs-center">
					<i class="fa fa-spinner fa-spin fa-3x fa-fw margin-bottom"></i>
					<span class="sr-only">Loading...</span>
				</div>

				<div if={!loading} class="modal-body">
					<div id="info-form">
						<div class="groupinfo-container" id="info">
							<div onclick={ showImageSearch }>
								<div class="add-photo" if={ !selectedImage }>Add Image</div>
								<img class="img-circle group-photo" if={ selectedImage } src={ selectedImage.thumbnailUrl }>
							</div>
							<div><input type="text" name="groupname" id="groupname" placeholder="What did you find?" size="100" maxlength="140"></div>
							<div if={false}><input type="text" name="keywords" id="keywords" placeholder="Keywords"></div>
							<textarea if={false} id="desc" class="form-control" placeholder="Short description" rows="3"></textarea>
							<!-- <div id="map"></div> -->
							<!-- <input if={showMapSearch} id="place-input" type="text" placeholder="Search for place"/> -->
							
						<!-- <input if={showMapSearch} id="place-input" type="text" placeholder="Search for place"/> -->
							
							<div id="map"></div>
							<input class={shown: showMapSearch, hidden: !showMapSearch} id="place-input" type="text" placeholder="Search for place"/>
							<!-- <div>Discoverability Radius</div> -->
							<input class="hidden" name="slider" type="range" value="10"></input>
						
						</div>



						<div class="address" onclick={ this.showMap }>{ address }</div>

						<div class="confirm-container"><button class="btn btn-primary" onclick={ this.submitGroup }>Create</button></div>
						<div class="confirm-container" if={ false }><button class="btn btn-default" onclick={ this.closeMap }>OK</button></div>
					</div>

					<imagesearch></imagesearch>

					<div class="error text-warning" if={ isError }>{ error }</div>
				</div>
			</div>

		</div>
	</div>

	<script>
		var self     = this
		self.address = ''
		self.isError = false
		self.error   = ''
		self.info    = true

		creategroupTag = this

		containerTag.on("showMap", function(){
			console.log("triggered");
			setTimeout(function(){
				google.maps.event.trigger(self.gmap, 'resize')
							self.gmap.panTo(self.marker.position)
						}, 1000)
			

		})

		this.on('mount', function() {
			self.initMap()
			$(document).ready(function(){
				self.getStreetAddress({lat: USER_POSITION.latitude, lng: USER_POSITION.longitude})

				$('#creategroupModal').on('shown.bs.modal', function() {
					$(document).bind("touchmove", function(e){
						e.preventDefault();
					});
					$('#groupname').focus()
					self.resetMap()
					self.getStreetAddress({lat: USER_POSITION.latitude, lng: USER_POSITION.longitude})
				})
				$('#creategroupModal').on('hidden.bs.modal', function() {
					$(document).unbind('touchmove');

					self.closeMap()
					self.tags.imagesearch.hide()

					self.info = true
					self.update()

					self.showInfo()
					self.isError         = false
					self.error           = ''
					self.groupname.value = ''
					self.desc.value      = ''
					self.keywords.value  = ''
					self.selectedImage   = undefined
					self.update()
				})

				self.slider.addEventListener('input', function() {
					self.groupCircle.setRadius(self.slider.value / 10 * 1609)
				})
			})
		})

		initMap() {
			self.gmap = new google.maps.Map(document.getElementById('map'), {
				center: {lat: USER_POSITION.latitude, lng: USER_POSITION.longitude},
				zoom: 13,
				disableDefaultUI: true,
				zoomControl: true,
				styles: [{ featureType: "poi", elementType: "labels", stylers: [{ visibility: "off" }]},
				{ featureType: "transit", elementType: "labels", stylers: [{ visibility: "off" }]}]
			})

			// pac is place autocomplete
			self.pac = new google.maps.places.Autocomplete(document.getElementById('place-input'))
			self.pac.bindTo('bounds', self.gmap)

			self.marker = new google.maps.Marker({
				map: self.gmap,
				position: {lat: USER_POSITION.latitude, lng: USER_POSITION.longitude},
				icon: '/images/marker-filled.png'
			})
			self.groupCircle = new google.maps.Circle({
				strokeColor: '#282A6A',
				strokeOpacity: 0.8,
				strokeWeight: 1,
				fillColor: '#A9A9C3',
				fillOpacity: 0.3,
				map: self.gmap,
				center: {lat: USER_POSITION.latitude, lng: USER_POSITION.longitude},
				radius: 1609,
				clickable: false
			})
			self.service = new google.maps.places.PlacesService(self.gmap);

			self.gmap.addListener('click', function(e) {
				self.marker.setPosition(e.latLng)
				self.gmap.panTo(e.latLng)
				self.getStreetAddress(e.latLng)
				self.groupCircle.setCenter(self.marker.position)
			})

			self.pac.addListener('place_changed', function() {
				var place = self.pac.getPlace()
				if (!place.geometry) return false

				self.gmap.setCenter(place.geometry.location)
				self.gmap.setZoom(15)
				self.marker.setPosition(place.geometry.location)
				self.groupCircle.setCenter(place.geometry.location)
				self.address = place.name
				self.update()
			})

			// $('#map-container').slideUp({duration:0})
		}

		resetMap() {
			self.gmap.setCenter({lat: USER_POSITION.latitude, lng: USER_POSITION.longitude})
			self.gmap.setZoom(13)
			self.marker.setPosition({lat: USER_POSITION.latitude, lng: USER_POSITION.longitude})
			self.groupCircle.setCenter({lat: USER_POSITION.latitude, lng: USER_POSITION.longitude})
			self.groupCircle.setRadius(1609)
			self.slider.value = 10
		}

		getStreetAddress(position) {
			var request = {
				location: position,
				radius: '5',
				types: 'administrative_area_level_2'
			}
			self.service.nearbySearch(request, function(results, status) {
				if (status == google.maps.places.PlacesServiceStatus.OK) {
					for (var i = 0; i < results.length && i < 4; i++) {
						if (results[i].name != 'United States' && results[i].name != results[i].vicinity) {
							self.address = results[i].name + ', ' + results[i].vicinity
						}
					}
					self.update()
				}
			})
		}

		submitGroup() {
			if (self.groupname.value.length < 3) {
				self.isError = true
				self.error   = "Groups' names must be at least 3-character long"
				self.update()
				return null
			}

			self.loading = true
			self.update()

			self.generateGroupId().then(function(results) {
				var groupId = results

				var GroupObject = Parse.Object.extend('Group')
				var newGroup    = new GroupObject()
				var groupType = "group";
				if (self.groupname.value.toLowerCase().indexOf("event")>= 0)
					groupType = "event";

				newGroup.save({
					location: new Parse.GeoPoint(self.marker.position.lat(), self.marker.position.lng()),
					name: self.groupname.value,
					lowerName: self.groupname.value.toLowerCase(),
					description: self.desc.value,
					keywords: self.keywords.value.toLowerCase(),
					creator: Parse.User.current(),
					imageUrl: self.selectedImage ? self.selectedImage.contentUrl : undefined,
					thumbnailUrl: self.selectedImage ? self.selectedImage.thumbnailUrl : undefined,
					groupId: groupId,
					radius: self.groupCircle.radius,
					memberCount: 1,
					type: groupType,
					deleted: false
				},{
					success: function(group) {
						var UserGroupObject = Parse.Object.extend('UserGroup')
						var newUserGroup = new UserGroupObject()
						newUserGroup.save({
							user: Parse.User.current(),
							group: group
						}, {
							success: function(userGroup) {

							}, error: function(userGroup, error) {
								self.isError = true
								self.error = error.message
								self.update()
							}
						})

						var newPostContent = '' + group.get('name')
						newPostContent += (group.get('description')) ? ', ' + group.get('description') : ''
						var PostObject = Parse.Object.extend('Post')
						var newPost = new PostObject()
						newPost.save({
							author: Parse.User.current(),
							group: group,
							content: newPostContent,
							newsFeedViewsBy: [],
							answerCount: 0,
							wannaknowCount: 0,
							anonymous: false
						}, {
							success: function(post) {
								// var Wannaknow = Parse.Object.extend('WannaKnow')
								// var wannaknow = new Wannaknow()
								// wannaknow.save({
								// 	post: post,
								// 	user: Parse.User.current()
								// }, {
								// 	success: function(wannaknow) {
								// 		self.loading = false
								// 		$('#creategroupModal').modal('hide')
								// 		containerTag.group = group
								// 		riot.route(encodeURI(group.get('groupId')))
								// 		self.update()
								// 	}
								// })
								self.loading = false
								$('#creategroupModal').modal('hide')
								containerTag.group = group
								riot.route(encodeURI(group.get('groupId')))
								self.update()
							}
						})
					}, error: function(group, error) {
						self.isError = true
						self.error = error.message
						self.update()
					}
				})
			})
		}

		generateGroupId() {
			var promise = new Parse.Promise()
			var groupId = self.groupname.value.toLowerCase().trim()
			groupId     = groupId.replace(new RegExp(' ','g'), '-')

			randomGroupId()

			function randomGroupId() {
				var randomId    = Math.round(Math.random() * 999 + 1)
				var tempGroupId = groupId + '-' + randomId
				var GroupObject = Parse.Object.extend('Group')
				var query       = new Parse.Query(GroupObject)
				query.equalTo('groupId', tempGroupId)
				query.find({
					success: function(groups) {
						if (groups.length == 0) promise.resolve(tempGroupId)
							else randomGroupId().then(function(results) { promise.resolve(results) })
						},
					error: function(error) {
						randomGroupId().then(function(results) { promise.resolve(results) })
					}
				})
			}

			return promise
		}

		showMap() {
			self.showMapSearch = true
			self.chooseLocation = true
			self.update()

							google.maps.event.trigger(self.gmap, 'resize')
							self.gmap.panTo(self.marker.position)


			// if (self.chooseLocation) return null;


			// $('#info').slideUp({
			// 	duration: 0,
			// 	complete: function() {
			// 		self.chooseLocation = true
			// 		self.update()

			// 		$('#map-container').slideDown({
			// 			duration: 0,
			// 			complete: function() {
			// 				google.maps.event.trigger(self.gmap, 'resize')
			// 				self.gmap.panTo(self.marker.position)
			// 			}
			// 		}).removeClass('hide')
			// 	}
			// })
		}

		closeMap() {
			$('#map-container').slideUp({
				duration: 0,
				complete: function() {
					if (self.address == '') self.address = 'Change Location'
						self.chooseLocation = false
					self.update()
					$('#info').slideDown({duration: 0})
				}
			}).addClass('hide')
		}

		showImageSearch() {
			self.tags.imagesearch.update({callback: self.returnImageSearch
			})
			self.tags.imagesearch.searchImage(self.groupname.value)
			$('#info-form').slideUp({
				duration: 0,
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

		showInfo() {
			$('#info-form').slideDown({duration: 500})
		}

		back() {
			self.tags.imagesearch.hide().then(function() {
				$('#info-form').slideDown({duration: 0})
				self.info = true
				self.update()
			})
		}
	</script>

	<style scoped>

		:scope {
			text-align: center;
		}

		.header {
			border: none;
			padding-bottom: 0;
		}

		.header .fa-chevron-left {
			padding-top: 5px;
		}

		.add-photo {
			margin: 0 auto;
			height: 100px;
			width: 100px;
			padding-top: 35px;
			-webkit-border-radius: 50%;
			-moz-border-radius: 50%;
			border-radius: 50%;
			border:1px dashed #00BFFF;
			color: #00BFFF;
		}
		.group-photo {
			height: 100px;
			width: 100px;
			object-fit: cover;
		}

		.groupinfo-container input {
			text-align: center;
			/*margin-bottom: 15px;*/
			border: none;
			margin: 0 auto;
		}

		#groupname {
			font-size: 20px;
			width: 100%;
			padding-top: 10px;
		}
		#groupname:focus, #desc:focus {
			outline: none;
		}

		#map-container {
			height: 100%;
		}

		#map {
			margin-top: 20px;
			/*margin-bottom: 20px;*/
		}

		.hide #map {
			margin: 0;
		}

		.address {
			/*margin-top: 20px;*/
			color: #00BFFF;
		}

		.confirm-container {
			margin-top: 10px;
			margin-bottom: 10px;
		}

		.options {
			padding-top: 30px;
			text-align: center;
			font-size: 26px;
			font-weight: 600;
			color: #bbb;
		}

		#image-search input {
			margin-bottom: 10px;
			text-align: center;
			font-size: large;
			border: none;
		}

		#image-search input:focus {
			outline: none;
		}

		.image-grid {
			padding-top: 10px;
			line-height: 1;
		}

		.arrows {
			width: 5%;
			vertical-align: top;
			margin-top: 50px;
		}

		.image-container {
			height: 110px;
			width: 25%;
			background-size: cover;
			margin: 5px;
			display: inline-block;
		}

		.uploaded-image label {
			width: 100%;
			height: 300px;
		}

		#image-edit {
			width: 100%;
			height: 300px;
		}

		.modal-body {
			padding: 0 10px;
		}

		@media screen and (max-width: 543px) {
			.image-container {
				height: 80px;
			}
		}

		@media screen and (min-height: 1000px) {
			#map {
				height: 500px;
			}
		}
		@media screen and (max-height: 1000px) {
			#map {
				height: 200px;
			}
		}

		.shown {
			display: block;
		}
		.hidden {
			display: none;
		}
	</style>
</creategroup>