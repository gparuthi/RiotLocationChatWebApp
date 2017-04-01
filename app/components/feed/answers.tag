<answers>
	<div if={loading}>
		<span class="glyphicon glyphicon-refresh glyphicon-refresh-animate"></span> Loading...
	</div>
		<div if={this.answers.length==0 }>
		 No one has answered yet. 
	</div>
	<div if={ !loading }>
		<div each={ post in answers }>
			<postitem post={post}></postitem>
		</div>
	</div>
	

	<script>
		var self = this
		answersTag = this
		this.answers = opts.answers
		this.answersVisible = true
		this.loading = false


		getAuthorName(post) {
			if (post.get('anonymous'))
				return 'anonymous'
			else 
				return post.get('author').get('firstName') + ' ' + post.get('author').get('lastName')
		}
	</script>

	<style scoped>
	:scope{
		    font-family: Source Sans Pro,sans-serif;
    font-weight: 300;
    font-size: 24px;

	}
		a {
			display: block;
			text-decoration: none;
			width: 100%;
			height: 100%;
			/*line-height: 150px;*/
			color: inherit;

		}
		a:hover {
			background: #eee;
			color: #000;
			text-decoration: none;
		}

		ul {
			padding: 10px;
			list-style: none;
		}
		li {
			display: block;
			margin: 5px;
		}


		@media (min-width: 480px) {
			:scope {
				/*margin-right: 200px;*/
				margin-bottom: 0;
			}
		}
	</style>
</answers>