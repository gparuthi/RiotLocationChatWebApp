<groupslist>

<!-- <div if={ joinedGroups.length > 0 }>
	<div class="title">
		Joined
	</div>

	<div class="swiper-container">
	    <div class="swiper-wrapper">
	        <div class="swiper-slide" each={ group in joinedGroups} onclick={ this.chooseGroup(group.get('group')) }>
					<img src={ API.getGroupThumbnail(group.get('group')) } class="image-joined">
					<div class="joined-title">
						{ group.get('group').get('name').slice(0,20) }
						<span if={ group.get('group').get('name').length > 20 }>...</span>
					</div>
				</div>
	    </div>
	</div>

</div> -->
<div if={ joinedGroups.length > 0 }>

</div>
<div class="title">
	Nearby
</div>
<div class="nearby">
	<ul>
		<li each={ group in groups } onclick={ this.chooseGroup(group) }>
			<div class="pointer">
				<img src={ API.getGroupImage(group) } class="image-nearby">
				<div class="info-box">
					<div class="nearby-title">
						{ group.get('name') }
					</div>
					<div class="time">{ this.getTime(group.get('updatedAt')) }</div>
					<div class="desc">{ group.get('description') }</div>
				</div>
			</div>
		</li>
	</ul>
</div>


<script>
	var self = this
	self.joinedGroups = opts.joinedGroups
	self.groups = opts.groups

	this.on('mount', function() {
	})

	createSwiper() {
		var swiper = new Swiper('.swiper-container', {
	        slidesPerView: 3.5,
	        spaceBetween: 20,
	        freeMode: true
	    });
	}

	chooseGroup(group) {
		return function() {
			containerTag.group = group
			riot.route(encodeURI(group.get('groupId')))
			self.update()
		}
	}

	shiftLeft() {
		self.joinedEnd = self.joinedStart
		self.joinedStart -= self.joinedLength
		self.update()
	}

	shiftRight() {
		self.joinedStart = self.joinedEnd
		self.joinedEnd += self.joinedLength
		self.update()
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
</script>

<style scoped>
	.row > * {
		padding: 0;
	}

	.title {
		font-size: 18px;
		font-weight: lighter;
		padding: 10px 16px;
		background-color: #334067;
		color: white;
	}

	.time{
		font-size: 12px;
	}

	.joined-title {
		font-size: 15px;
		padding-top: 15px;
	}

	.nearby-title {
		font-size: 18px;
		overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
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

	.nearby ul {
		list-style: none;
		margin-bottom: 0;
		padding: 0;
	}

	.image-container {
		text-align: center;
	}

	.gray {
		border: none;
		background-image: url('/images/default_image.jpg');
		background-size: cover;
	}

	@media (max-width: 480px) {
		.group-title > * {
			font-size: 12px;
		}
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

	.swiper-container {
		height: initial;
        margin: 20px auto;
    }
    .swiper-slide {
        text-align: center;
        font-size: 18px;
        background: #fff;

        /* Center slide text vertically */

        -webkit-box-pack: center;
        -ms-flex-pack: center;
        -webkit-justify-content: center;
        justify-content: center;
        -webkit-box-align: center;
        -ms-flex-align: center;
        -webkit-align-items: center;
        align-items: center;
    }

</style>
</groupslist>