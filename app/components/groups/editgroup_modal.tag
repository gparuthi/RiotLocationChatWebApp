<editgroup>

	<div id="editgroupModal" class="modal fade" role="dialog">
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
							<div><input type="text" name="groupname" id="groupname" placeholder="New Group" size="140" maxlength="140"></div>
							<div><input type="text" name="desc" id="desc" placeholder="Short Description"></div>
						</div>

						<div id="map-container" class="hide">
							<input id="place-input" type="text" placeholder="Search for place"/>
							<div id="map"></div>
							<input name="slider" type="range" value="10"></input>
						</div>

						<div class="address" onclick={ this.showMap }>{ address }</div>

						<div class="confirm-container" if={ !chooseLocation }><button class="btn btn-primary" onclick={ this.submitGroup }>Done</button></div>
						<div class="confirm-container" if={ chooseLocation }><button class="btn btn-default" onclick={ this.closeMap }>OK</button></div>
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

		editgroupTag = this

		init() {
			$(document).ready(function(){
				self.initMap()

				$('#editgroupModal').on('shown.bs.modal', function() {
					$(document).bind("touchmove", function(e){
						e.preventDefault();
					});
					self.resetMap()
					self.selectedImage = {contentUrl: containerTag.group.get('imageUrl'), thumbnailUrl: containerTag.group.get('imageUrl')}
					self.groupname.value = containerTag.group.get('name')
					self.desc.value = containerTag.group.get('description')
					self.getStreetAddress({lat: containerTag.group.get('location').latitude, lng: containerTag.group.get('location').longitude})
					self.slider.value = containerTag.group.get('radius') / 1609 * 10
				})
				$('#editgroupModal').on('hidden.bs.modal', function() {
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
					self.selectedImage    = undefined
					self.update()
				})

				self.slider.addEventListener('input', function() {
					self.groupCircle.setRadius(self.slider.value / 10 * 1609)
				})
			})


			$(document).on('change', '#imageFile-edit', self.handleUploadedImage)
		}

		initMap() {
			self.gmap = new google.maps.Map(document.getElementById('map'), {
				center: {lat: containerTag.group.get('location').latitude, lng: containerTag.group.get('location').longitude},
				zoom: 13,
				disableDefaultUI: true,
				zoomControl: true,
				styles: [{ featureType: "poi", elementType: "labels", stylers: [{ visibility: "off" }]},
				{ featureType: "transit", elementType: "labels", stylers: [{ visibility: "off" }]}]
			})
			console.log(containerTag.group.get('location'))

			// pac is place autocomplete
			self.pac = new google.maps.places.Autocomplete(document.getElementById('place-input'))
			self.pac.bindTo('bounds', self.gmap)

			self.marker = new google.maps.Marker({
				map: self.gmap,
				position: {lat: containerTag.group.get('location').latitude, lng: containerTag.group.get('location').longitude},
				icon: '/images/marker-filled.png'
			})
			self.groupCircle = new google.maps.Circle({
				strokeColor: '#282A6A',
				strokeOpacity: 0.8,
				strokeWeight: 1,
				fillColor: '#A9A9C3',
				fillOpacity: 0.3,
				map: self.gmap,
				center: {lat: containerTag.group.get('location').latitude, lng: containerTag.group.get('location').longitude},
				radius: containerTag.group.get('radius'),
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

			$('#map-container').slideUp({duration:0})
		}

		resetMap() {
			self.gmap.setCenter({lat: containerTag.group.get('location').latitude, lng: containerTag.group.get('location').longitude})
			self.gmap.setZoom(13)
			self.marker.setPosition({lat: containerTag.group.get('location').latitude, lng: containerTag.group.get('location').longitude})
			self.groupCircle.setCenter({lat: containerTag.group.get('location').latitude, lng: containerTag.group.get('location').longitude})
			self.groupCircle.setRadius(containerTag.group.get('radius'))
			self.slider.value = containerTag.group.get('radius') / 1609 * 10
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

			var group = containerTag.group
			group.set('name', self.groupname.value)
			group.set('lowerName', self.groupname.value.toLowerCase())
			group.set('description', self.desc.value)
			group.set('imageUrl', self.selectedImage ? self.selectedImage.contentUrl : undefined)
			group.set('thumbnailUrl', self.selectedImage ? self.selectedImage.thumbnailUrl : undefined)
			group.set('location', new Parse.GeoPoint(self.marker.position.lat(), self.marker.position.lng()))
			group.set('radius', self.groupCircle.radius)

			group.save(null, {
				success: function(group) {
					self.loading = false
					$('#editgroupModal').modal('hide')
					groupinfoTag.update()
				}, error: function(group, error) {}
			})
		}

		showMap() {
			if (self.chooseLocation) return null;

			$('#info').slideUp({
				duration: 500,
				complete: function() {
					self.chooseLocation = true
					self.update()

					$('#map-container').slideDown({
						duration: 500,
						complete: function() {
							google.maps.event.trigger(self.gmap, 'resize')
							self.gmap.panTo(self.marker.position)
						}
					}).removeClass('hide')
				}
			})
		}

		closeMap() {
			$('#map-container').slideUp({
				duration: 500,
				complete: function() {
					if (self.address == '') self.address = 'Change Location'
						self.chooseLocation = false
					self.update()
					$('#info').slideDown({duration: 500})
				}
			}).addClass('hide')
		}

		showImageSearch() {
			self.tags.imagesearch.update({callback: self.returnImageSearch})
			$('#info-form').slideUp({
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

		showInfo() {
			$('#info-form').slideDown({duration: 500})
		}

		back() {
			self.tags.imagesearch.hide().then(function() {
				$('#info-form').slideDown({duration: 500})
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
			padding-top: 3px;
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
			margin-top: 15px;
			border: none;
		}

		#groupname {
			font-size: x-large;
			width: 100%;
		}
		#groupname:focus, #desc:focus {
			outline: none;
		}

		#desc {
			font-size: large;
			width: 100%
		}

		#map-container {
			height: 400px;
		}

		#map {
			margin-top: 20px;
			margin-bottom: 20px;
		}

		.hide #map {
			margin: 0;
		}

		.address {
			margin-top: 20px;
			color: #00BFFF;
		}

		.confirm-container {
			margin-top: 10px;
			margin-bottom: 10px;
		}

		.options {
			padding-top: 70px;
			padding-bottom: 50px;
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
			border-top: 1px solid #ddd;
			border-bottom: 1px solid #ddd;
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

		#imageEdit-edit {
			width: 100%;
			height: 300px;
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
				height: 300px;
			}
		}
	</style>
</editgroup>