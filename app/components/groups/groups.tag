<groups>

<landingloader if={FIRST_TIME && loading}></landingloader>
<div if={!loading}>
	<groupsmap name="groupsmap"></groupsmap>

	<div class="filter-container">
		<input type="text" placeholder="Filter by keywords" name="groupquery" oninput={ this.keyUp }>
	</div>

	<div class="outer-container" style="
	    margin-right: auto;
	    margin-left: auto;
	    max-width: 700px;">
		<!-- <div class="search-container row">
			<div class="col-sm-8 col-sm-offset-2">
				<textarea placeholder="Search Groups" class="search-groups" rows="1"></textarea>
			</div>
		</div> -->
		<!-- <h3 style="text-align: center; padding-top: 1em;">#Yoga</h3> -->
		<div class="groups-container">
			<groupslist name="groupslist"></groupslist>
		</div>

		<button class="btn mfb-component--br" name="submit" onclick={ showCreateModal }>
			<svg width="20px" height="20px" viewBox="0 0 20 20" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	    <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
	        <polygon id="Shape" fill="#FFFFFF" points="20 11.4285714 11.4285714 11.4285714 11.4285714 20 8.57142857 20 8.57142857 11.4285714 0 11.4285714 0 8.57142857 8.57142857 8.57142857 8.57142857 0 11.4285714 0 11.4285714 8.57142857 20 8.57142857"></polygon>
	    </g>
	</svg>
		</button>
	</div>
</div>

<script>
	var self     = this
	groupsTag    = this
	self.filter  = opts.filter
	self.loading = true

	this.on('mount', function() {

	})

	this.on('locationChanged', function() {
		self.sortGroupsByDistance()
		self.tags.groupsmap.resetMap()
		creategroupTag.getStreetAddress({lat: USER_POSITION.latitude, lng: USER_POSITION.longitude})
		console.log(USER_POSITION)
	})

	init() {
		var utime = new Date()

		containerTag.group = null
		self.tags.groupsmap.triggerResize()
		API.getjoinedgroups(Parse.User.current()).then(function(joinedGroups) {
			self.joinedGroups = joinedGroups
			API.getallgroups(null, self.filter).then(function(groups) {		//TODO Add another filter to get the groups in joinedGroups UserGroup object
				self.groups = groups.filter(function(group) {
					for (var i = 0; i < self.joinedGroups.length; i++)
						if (group.id == self.joinedGroups[i].get('group').id) return true
					return true
				})

				if (self.filter) {
					self.tags.groupsmap.update({joinedGroups: [], groups: self.groups})
					self.tags.groupslist.update({joinedGroups: [], groups: self.groups})
				} else {
					self.tags.groupsmap.update({joinedGroups: self.joinedGroups, groups: self.groups})
					self.tags.groupslist.update({joinedGroups: self.joinedGroups, groups: self.groups})
				}

				if (FIRST_TIME) {
					setTimeout(function() {
						self.loading = false
						FIRST_TIME = false
						self.parent.update()
						self.tags.groupsmap.trigger('groupsUpdated')
						self.tags.groupslist.createSwiper()
					}, Date.parse(utime) - Date.parse(new Date()) + 5000)
				} else {
					self.loading = false
					self.update()
				}

				self.tags.groupsmap.trigger('groupsUpdated')
				self.tags.groupslist.createSwiper()
			})
		})
	}

	sortGroupsByDistance() {
		if (self.groups) {
			self.groups.sort(API.comparedistance)
			self.update()
		}
	}

	showCreateModal() {
		$('#creategroupModal').modal('show')
		containerTag.trigger('showMap')
	}

	keyUp() {
		clearTimeout(self.searchTimer)
		self.searchTimer = setTimeout(self.searchGroup, 700)
	}

	searchGroup() {
		if (self.groupquery.value == '') riot.route('')
		else riot.route('/search/' + encodeURI(self.groupquery.value))
		self.update()
	}

</script>
<style scoped>
	.row > * {
		padding: 0;
	}

	.arrow {
		padding-top: 30px;
		padding-bottom: 70px;
	}

	.fa-chevron-right {
		text-align: center;
	}
	.fa-chevron-left {
		text-align: center;
	}

	.tile {
		vertical-align: top;
		text-align: center;
		display: inline-block;
	}

	.filter-container {
		margin-top: 20px;
		text-align: center;
	}

	.filter-container input {
		padding: 5px 16px;
		-webkit-border-radius: 18px;
		-moz-border-radius: 18px;
		border-radius: 18px;
		border: 1px solid #ccc;
	}

	.filter-container input:focus {
		outline: none;
	}

	.nearby li {
		padding-top: 24px;
	}

	.nearby li:last-child .info-box{
    	border: none;
	}

	.nearby li:last-child{
    	margin-bottom: 1rem;
	}

	.nearby ul {
		list-style: none;
		margin-bottom: 0;
		padding: 0;
	}

	.image-container {
		text-align: center;
	}

	.image-joined {
		height: 80px;
		width: 80px;
		object-fit: cover;
		border-radius: 50%;
	}

	.image-nearby {
		height: 100px;
		width: 100px;
		object-fit: cover;
		margin: auto 10px;
	}

	.gray {
		border: none;
		background-image: url('/images/default_image.jpg');
		background-size: cover;
	}

	.info-box{
		display: inline-block;
		vertical-align: middle;
		width: calc(100% - 140px);
		display: inline-block;
		border-bottom: 1px solid #ccc;
		height: 100px;
	}

	.group-title {
		margin-top: 10px;
		font-size: 15px;
	}

	.desc{
		font-size: 14px;
		overflow: hidden;
		height: 64px;
	}

	.groups-container{
		margin-top: 1rem;
	}

	@media (max-width: 480px) {
		.group-title > * {
			font-size: 12px;
		}
	}

	@media (min-width: 700px) {
		.groups-container{
			border: 2px solid #334067;
		}
	}

	.mfb-component--br {
		right: 0;
		bottom: 0;
		text-align: center;
	}
	.mfb-component--tl, .mfb-component--tr, .mfb-component--bl, .mfb-component--br {
		box-sizing: border-box;
		margin: 25px;
		position: fixed;
		white-space: nowrap;
		z-index: 30;
		list-style: none;
		border-radius: 50%;
		width: 55px;
		height: 55px;
		padding: 0px;
		background: #039be5;
		color: white;
		font-size: 1.6em;
		box-shadow: 0 2px 5px 0 rgba(0,0,0,0.16),0 2px 10px 0 rgba(0,0,0,0.12);
	}

</style>
</groups>