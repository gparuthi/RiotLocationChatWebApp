<tweetitem>
	<div class="card-block pointer">

		<div class="">

			<div class='postauthor text-muted'>
				<img src={tweet.user.profile_image_url_https} class="profile img-circle">
				<span class="author">{tweet.user.name}</span> <br/>

			</div>

			<p class="post-content" name="content">{this.getContent()}</p>
		</div>

	</div>



	<script>
		var self            = this
		self.tweet           = opts.tweet
		self.answers        = []
		self.sending        = false
		self.wannaknowCount = 0
		self.wannaknown     = false
		self.submitButton   = false
		self.anonymous      = false

		this.on('mount', function() {
			self.init()
		})

		init() {

		}

		getAuthorName() {
			if (this.post.get('anonymous'))
				return 'Anonymous'
			else
				return this.post.get('author').get('firstName') + ' ' + this.post.get('author').get('lastName')
		}
		getContent() {
			var content = self.tweet.text
			var regex = /(https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/ig
			var replacedContent = content.replace(regex, "<a href='$1' target='_blank'>$1</a>")
			self.content.innerHTML = replacedContent
			return self.tweet.text
		}

		submitWannaknow(){
			if (!self.wannaknown) {
			// Update UI before processing
			self.wannaknown     = true
			self.wannaknowCount += 1
			self.update()

			var WannaknowObject = Parse.Object.extend('WannaKnow')
			var wannaknowObject = new WannaknowObject()
			wannaknowObject.save({
				post: self.post,
				user: Parse.User.current()
			}, {
				success: function(wannaknowObject) {
				},
				error: function(wannaknowObject, error) {
					// Do something if there is an error
				}
			})
		} else {
			// Update UI before processing
			self.wannaknown     = false
			self.wannaknowCount -= 1
			self.update()

			var WannaknowObject = Parse.Object.extend('WannaKnow')
			var query           = new Parse.Query(WannaknowObject)
			query.equalTo('post', self.post)
			query.equalTo('user', Parse.User.current())
			query.find({
				success: function(wannaknows) {
					if (wannaknows.length > 0) {
						wannaknows[0].destroy({})
						self.update()
					}
				},
				error: function(error) {
				}
			})
		}
	}

	submitAnswer(){
		var answerContent = self.answerbox.value

		if (answerContent != '') {
			// Set UI before processing
			self.answerbox.value = ''
			self.sending         = true
			self.submitButton    = false
			self.update()

			var AnswerObject = Parse.Object.extend('Answer')
			var answerObject = new AnswerObject()
			answerObject.save({
				answer: answerContent,
				author: Parse.User.current(),
				likes: 0,
				post: self.post,
				anonymous: self.anonymous
			}, {
				success: function(answerObject) {
					self.post.set('answerCount', self.post.get('answerCount') + 1)
					self.post.save()
					Parse.User.current().set('answerCount', Parse.User.current().get('answerCount') + 1)
					Parse.User.current().save()
					self.answers.push(answerObject)
					self.sending = false
					self.update()
				},
				error: function(answerObject, error) {
					// Do something if error
				}
			})
		}
	}

	onInput() {
		if (self.answerbox.value.length >= 3) {
			self.submitButton = true
			self.update()
		} else {
			self.submitButton = false
			self.update()
		}
	}

	toggleAnonymous() {
		self.anonymous = !self.anonymous
		self.update()
	}

	goToPost(e){
		e = e || event;
		var el = e.target || e.srcElement;

		if (el.nodeName === 'A') {
			window.open(el.href, '_blank');
			el.click()
		}
		else {
			if (window.location.href.indexOf("/post/") == -1) {
				var routeTo = '/post/' + self.post.id
				riot.route(routeTo)
				self.update()
			}
		}

	}

	gotoTopic() {
		var routeTo = 'schedule/' + encodeURI(self.post.get('topic'))
		riot.route(routeTo)
		self.update()
	}

</script>

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
	.profile {
		width: 30px;
		height: 30px;
		margin-right: 10px;
	}

	.wannaknow{
		display: inline-block;
		font-size: small;

	}

	.answercount{
		display: inline-block;
		font-size: small;
		padding-right: 20px;
	}

	.comment-input {
		width: 100%
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

	.inline {
		display: inline-block;
	}

	.submit {
		right: 3%;
		padding-right:0.9rem;
		padding-bottom:0.9rem;
		color: #0275D8;
		text-align: center;
	}

	.submit:hover {
		color: #004784;
	}

	.topic {
		font-size: smaller;
		background-color: #EAEAEA;
		color: #787878;
		padding: 5px;
		padding-left: 10px;
		padding-right: 10px;
		-webkit-border-radius: 17px;
		-moz-border-radius: 17px;
		border-radius: 17px;
		white-space: nowrap;
		text-overflow: ellipsis;
		overflow: hidden;
	}
	.infodiv{
		padding: 0px;
	}

	.align-left {
		text-align: left;
		white-space: nowrap;
	}

	.align-right {
		text-align: right;
		white-space: nowrap;
	}

	.reply-container {
		padding-left: .45rem;
	}

	.reply-container  hr{
		margin: 0;
	}

	.answer-icon-container {
		background-color: #FFFFFF;
		border-right: 0;
	}

	.answer-icon {
		width: 25px;
		height: 25px;
	}

	.form-control {
		padding: .8rem;
		border: none;
	}

	.input-group {
		padding: 0px;
	}

	.input-group-addon {
		padding: .375rem;
		padding-left: .8rem;
		border: none;
	}

	.card-block{
		padding-bottom: 0;
	}

	.card {
		margin-bottom: .6rem;
	}

	textarea {
		width: 100%;
		font-size: large;
		resize: none;
		-webkit-border-radius: 5px;
		-moz-border-radius: 5px;
		border-radius: 5px;
		border: none;
	}

	@media (min-width: 480px) {
		:scope {
			/*margin-right: 200px;*/
			margin-bottom: 0;
		}
	}
</style>
</tweetitem>