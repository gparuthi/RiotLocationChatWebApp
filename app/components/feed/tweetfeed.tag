<tweetfeed>

	<div class="postfeed">
		<!-- <postbar></postbar> -->

		<div class="update-feed" if={ newPost } onclick={ this.updateFeed }>
			Update feed
		</div>

		<div if={ !loading }>
			<div class="postitem" each={ tweet in tweets }>
				<tweetitem tweet={tweet} />
			</div>
		</div>
	</div>


<script>
	var self         = this
	tweetfeedtag      = this
	self.tweets = []
	
	init(){
		var keywords = "" || containerTag.group.get('keywords')
		var lat = containerTag.group.get('location').latitude
		var long = containerTag.group.get('location').longitude
		var keywords = containerTag.group.get('keywords') || ""
		$.getJSON("https://sophus.herokuapp.com/tweets?q="+keywords+"&lat="+lat+"&long="+long+"&dist=10000km&callback=?", function(data){
			console.log(data);
			self.tweets = data.statuses
			self.update()
		})
		
	}

	this.on('mount', function() {
		self.init()
	})


	updateFeed() {
		self.init()
	}

	

</script>
<style scoped>
	

	.update-feed {
		text-align: center;
		padding: 10px;
		background-color: #039be5;
		color: white;
		font-size: large;
	}

	<style scoped>
	.container {
		background-color: #f7f7f9;
	}

	:scope {
		font-family: helvetica, arial, sans-serif;
		font-size: 14px;
		color: black;
		font-weight: normal;

	}
	hr {
		margin: 0px;
		margin-bottom: 1rem;
	}

	.post-content{
		font-size: 14px;
		margin-top: 10px;
	}
	.postauthor{
		margin-bottom: 5px;
	}
	.author {
		padding-right: 8px;
	}
	.author-about{
		font-size: smaller;
	}
</style>
</tweetfeed>