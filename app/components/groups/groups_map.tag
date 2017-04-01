<groupsmap>
	<div class="map-container">

		<div id="groups-map">
			<div class="cs-loader" if={loading}>
				<label>	●</label>
				<label>	●</label>
				<label>	●</label>
				<label>	●</label>
				<label>	●</label>
				<label>	●</label>
			</div>
		</div>

		<div class="group-info" if={ selectedGroup } onclick={ gotoGroup }>
			<img class="image" src={ API.getGroupImage(selectedGroup) }>
			<div class="info">
				<div class="name">{ selectedGroup.get('name') }</div>
				<div class="desc">{ selectedGroup.get('description') }</div>
			</div>
		</div>
	</div>


	<script>
		var self           = this
		groupsmapTag       = this
		self.joinedGroups  = opts.joinedGroups
		self.groups        = opts.groups
		self.selectedGroup = undefined

		this.on('mount', function() {
			self.loading = true
			self.initMap()
			self.update()
		})

		this.on('groupsUpdated', function() {
			if (self.markers) {
				for (var i = 0; i < self.markers.length; i++) {
					self.markers[i].setMap(null);
				}
			}
			self.markers = []


			for (var i = 0; i < self.joinedGroups.length; i++) {
				var groupLocation = {lat: self.joinedGroups[i].get('group').get('location').latitude,
				lng: self.joinedGroups[i].get('group').get('location').longitude}

				var icon = {
				    url: API.getGroupThumbnail(self.joinedGroups[i]), // url
				    scaledSize: new google.maps.Size(30, 30), // scaled size
				    origin: new google.maps.Point(0,0), // origin
				    anchor: new google.maps.Point(0, 0) // anchor
				    
				}


				self.markers.push(new google.maps.Marker({
					map: self.gmap,
					position: groupLocation,
					title: self.joinedGroups[i].get('group').get('name'),
					group:self.joinedGroups[i].get('group'),
					opacity: self.getOpacityOfGroup(self.joinedGroups[i].get('group')),
				icon: icon
			}))
				self.markers[self.markers.length-1].addListener('click', function() {
					self.selectedGroup = this.group
					self.update()
				})
			}
			var shape = {
				coords: [1, 1, 1, 20, 18, 20, 18, 1],
				type: 'poly'
			};
			for (var i = 0; i < self.groups.length; i++) {
				var groupLocation = {lat: self.groups[i].get('location').latitude,
				lng: self.groups[i].get('location').longitude}
				var icon = {
				    url: API.getGroupThumbnail(self.groups[i]), // url
				    scaledSize: new google.maps.Size(30, 30), // scaled size
				    origin: new google.maps.Point(0,0), // origin
				    anchor: new google.maps.Point(0, 0) // anchor

				}
				self.markers.push(new google.maps.Marker({
					map: self.gmap,
					position: groupLocation,
					title: self.groups[i].get('name'),
					group: self.groups[i],
					opacity: self.getOpacityOfGroup(self.groups[i]),
					icon: icon
				}))
				self.markers[self.markers.length-1].addListener('click', function() {
					self.selectedGroup = this.group
					self.update()
				})
			}
		})

		getOpacityOfGroup(group) {
			var createdAt =  group.get('updatedAt')
			var t = Date.parse(new Date()) - Date.parse(createdAt)
			var seconds = Math.floor( (t/1000) )
			console.log(group.get('name') + seconds);
		if (seconds < 60*60*2){ // in the last 2 hour
			return 1
		} else {
			return 0.5
		}

	}

	getTime(createdAt) {
		var t = Date.parse(new Date()) - Date.parse(createdAt)
		var days = Math.floor( t/(1000*60*60*24) )
		if (days) return days == 1 ? days + ' day ago' : days + ' days ago'
			var hours = Math.floor( (t/(1000*60*60)) % 24 )
		if (hours) return hours == 1 ? hours + ' hour ago' : hours + ' hours ago'
			var minutes = Math.floor( (t/1000/60) % 60 )
		if (minutes) return minutes == 1 ? minutes + ' minute ago' : minutes + ' minutes ago'
			var seconds = Math.floor( (t/1000) % 60 )
		if (seconds) return seconds == 1 ? seconds + ' second ago' : seconds + ' seconds ago'
	}

initMap() {
	self.gmap = new google.maps.Map(document.getElementById('groups-map'), {
		center: {lat: USER_POSITION.latitude, lng: USER_POSITION.longitude},
		zoom: 12,
		disableDefaultUI: true,
		zoomControl: true,
		styles: [{ featureType: "poi", elementType: "labels", stylers: [{ visibility: "off" }]},
		{ featureType: "transit", elementType: "labels", stylers: [{ visibility: "off" }]}]
	})

	self.userMarker = new google.maps.Marker({
		map: self.gmap,
		position: {lat: USER_POSITION.latitude, lng: USER_POSITION.longitude},
		icon: '/images/marker-user.png',
		zIndex: 1000,
		opacity: 1
	})

	google.maps.event.addListenerOnce(self.gmap, 'idle', function(){
		self.loading = false
		self.update()
	});
}

triggerResize() {
	if (self.gmap) google.maps.event.trigger(self.gmap, 'resize')
}

resetMap() {
	if (self.gmap) {
		self.gmap.setCenter({lat: USER_POSITION.latitude, lng: USER_POSITION.longitude})
		self.gmap.setZoom(12)
		self.userMarker.setPosition({lat: USER_POSITION.latitude, lng: USER_POSITION.longitude})
	}
}

gotoGroup() {
	containerTag.group = self.selectedGroup
	riot.route(encodeURI(self.selectedGroup.get('groupId')))
	self.selectedGroup = undefined
	self.update()
}

</script>

<style scoped>
	.cs-loader {
		color: lightgray;
		text-align: center;
		padding-top: 200px;
	}

	@media (max-width: 480px) {
		.cs-loader {
			padding-top: 100px;
		}
	}

	.cs-loader label {
		font-size: 20px;
		opacity: 0;
		display:inline-block;
	}

	@keyframes lol {
		0% {
			opacity: 0;
			transform: translateX(-300px);
		}
		33% {
			opacity: 1;
			transform: translateX(0px);
		}
		66% {
			opacity: 1;
			transform: translateX(0px);
		}
		100% {
			opacity: 0;
			transform: translateX(300px);
		}
	}

	@-webkit-keyframes lol {
		0% {
			opacity: 0;
			-webkit-transform: translateX(-300px);
		}
		33% {
			opacity: 1;
			-webkit-transform: translateX(0px);
		}
		66% {
			opacity: 1;
			-webkit-transform: translateX(0px);
		}
		100% {
			opacity: 0;
			-webkit-transform: translateX(300px);
		}
	}

	.cs-loader label:nth-child(6) {
		-webkit-animation: lol 3s infinite ease-in-out;
		animation: lol 3s infinite ease-in-out;
	}

	.cs-loader label:nth-child(5) {
		-webkit-animation: lol 3s 100ms infinite ease-in-out;
		animation: lol 3s 100ms infinite ease-in-out;
	}

	.cs-loader label:nth-child(4) {
		-webkit-animation: lol 3s 200ms infinite ease-in-out;
		animation: lol 3s 200ms infinite ease-in-out;
	}

	.cs-loader label:nth-child(3) {
		-webkit-animation: lol 3s 300ms infinite ease-in-out;
		animation: lol 3s 300ms infinite ease-in-out;
	}

	.cs-loader label:nth-child(2) {
		-webkit-animation: lol 3s 400ms infinite ease-in-out;
		animation: lol 3s 400ms infinite ease-in-out;
	}

	.cs-loader label:nth-child(1) {
		-webkit-animation: lol 3s 500ms infinite ease-in-out;
		animation: lol 3s 500ms infinite ease-in-out;
	}


	.map-container{
		margin-top: 60px;
	}

	#groups-map{
		height: 400px;
	}

	@media (max-width: 480px) {
		#groups-map{
			height: 200px;
		}
	}

	#map {
		width: 100%;
	}

	.group-info {
		padding: 10px 25%;
		background-color: #eeeeee;
	}

	@media (max-width: 480px) {
		.group-info {
			padding: 0;
		}
	}

	.image {
		width: 100px;
		height: 100px;
		object-fit: cover;
	}

	.info {
		display: inline-block;
		padding-left: 10px;

		vertical-align: middle;
		width: calc(100% - 110px);
		display: inline-block;
		padding-top: 20px;
		padding-bottom: 20px;
	}

	.name {
		font-size: 18px;
	}
	.desc {
		font-size: 14px;
	}
</style>
</groupsmap>