<posts>
	<div if={loading} class="loader-container">
		<i class="fa fa-spinner fa-spin fa-3x fa-fw margin-bottom"></i>
		<span class="sr-only">Loading...</span>
	</div>
	<div if={this.posts.length==0 && profile!=true} class="zero-post">
		Be the first to post
	</div>
	<div if={this.posts.length==0 && profile==true} class="zero-post">
		No posts yet
	</div>
	<div if={ !loading }>
		<div class="postitem" each={ post in posts }>
			<postitem post={post}></postitem>
		</div>
	</div>


	<script>
		var self          = this
		postsTag          = this
		self.profile      = opts.profile
		self.posts        = opts.posts
		self.postsVisible = true
		self.loading      = false

		this.on('postsLoaded', function() {
			var WannaKnow = Parse.Object.extend('WannaKnow')
			var query     = new Parse.Query(WannaKnow)
			query.equalTo('user', Parse.User.current())
			query.equalTo('post', self.posts[0])

			for (var i = 1; i < self.posts.length; i++) {
				var subQuery = new Parse.Query(WannaKnow)
				subQuery.equalTo('user',Parse.User.current())
				subQuery.equalTo('post', self.posts[i])

				query = Parse.Query.or(query, subQuery)
			}

			query.find().then(function(results) {
				self.wannaknows = results
				if (Array.isArray(self.tags.postitem)) for (var i = 0; i < self.posts.length; i++) self.tags.postitem[i].init()
				else if (self.tags.postitem) self.tags.postitem.init()
				self.loading = false
				self.update()
			})
		})


	</script>

	<style scoped>
		:scope{
			/*font-family: Source Sans Pro,sans-serif;*/
			/*font-weight: 300;*/
			/*font-size: 24px;*/


		}

		.loader-container {
			text-align: center;
		}

		.zero-post {
			padding-top: 150px;
			text-align: center;
			font-size: 30px;
			font-weight: 600;
			color: #bbb;
		}
		div.postitem:last-child {
			margin-bottom: 16px;
		}


		@media (min-width: 480px) {
			:scope {
				/*margin-right: 200px;*/
				margin-bottom: 0;
			}
		}
	</style>
</posts>