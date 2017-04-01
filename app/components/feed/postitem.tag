<postitem>
		<div class="card-block">

			<div class="">

				<div class='postauthor pointer'>
					<img if={ !post.get('anonymous') } src = "{ API.getProfileThumbnail(post.get('author')) }" class = "profile img-circle">
					<img if={ post.get('anonymous') } src="/images/default_profile.png" class="profile img-circle">
					<div style="display: inline-block;">
						<div class="author">{this.getAuthorName()}</div>
						<div class="time">{ this.getTime() }</div>
					</div>

					<div class="options">
						<div class="toggler fa fa-ellipsis-h dropdown-toggle" data-toggle="dropdown"></div>
						<ul class="dropdown-menu dropdown-menu-right">
							<li class="options-item" if={ Parse.User.current().id == post.get('author').id } onclick={ showEdit }>Edit</li>
							<li class="options-item" if={ Parse.User.current().id == post.get('author').id } onclick={ deletePost }>Delete</li>
							<li class="options-item" onclick={ submitWannaknow } if={ !wannaknown }>Like</li>
							<li class="options-item" onclick={ submitWannaknow } if={ wannaknown }>Unlike</li>
							<li class="options-item">Report</li>
						</ul>
					</div>
				</div>

				<div class="likes" if={ wannaknowCount > 0 }>
					<!-- { wannaknowCount } like<span if={ wannaknowCount!=1 }>s</span> -->
					+ { wannaknowCount }
				</div>

				<div class="post-content" name="content" if={!edit}>{this.getContent()}</div>
				<div class="edit-box" if={edit}>
					<textarea class="post-content edit-input" name="editcontent" rows="1"></textarea>
					<div class="btn-container">
						<button class="edit-btn btn btn-default" onclick={ submitEdit }>Done</button>
					</div>
				</div>
				<div class="image-container" if={ post.get('imageURL') }>
					<img class="post-image" src={ post.get('imageURL') }>
				</div>
			</div

			<!-- <a onclick={this.showSignup}> -->
			<!--
			<div class="pointer row">
				<div class="col-xs-5 text-muted infodiv">
					<div class='answercount' if={post.get('answerCount') >= 0} >{post.get('answerCount')} Repl<span if={post.get('answerCount')!=1}>ies</span><span if={ post.get('answerCount') == 1 }>y</span>
					</div>

					<div class='wannaknow text-muted' onclick={ this.submitWannaknow }>
						<!-- <img width="23px" src="/images/wannaknow_gray@2x.png">  -->
						<!--
						<i class={ fa: true, fa-heart-o: !wannaknown, fa-heart: wannaknown } name="wannaknowButton" aria-hidden="true"></i>
						<!-- {post.get('wannaknowCount')} -->
						<!--{ wannaknowCount }
					</div>
				</div>

				<div class="col-xs-7 align-right infodiv" onclick={ this.gotoTopic }>
					<span class="topic" if={ post.get('topic') }>
						{ post.get('topic').slice(0,20) } <span if={ post.get('topic').length > 20 }>...</span>
					</span>
				</div>
			</div>
		</div>

		<hr if={post.get('answerCount')>0}/>
		<div class="row">
			<div class="col-xs-12" >
				<div if={post.get('answerCount')>0}>

					<div each={ ans in answers }>
						<answeritem answer={ ans }></answeritem>
					</div>

				</div>
			</div>
		</div>

		<div class="reply-container">
			<hr/>
			<div class="form-container card-block input-group">
				<div class="input-group-addon answer-icon-container pointer" onclick={ this.toggleAnonymous }>
					<img src={ API.getCurrentUserProfilePicture() } class="answer-icon img-circle" if={ !anonymous }>
					<img src="/images/default_profile.png" class="answer-icon img-circle" if={ anonymous }>
				</div>
				<textarea class="form-control" name="answerbox" id="answerbox" oninput={ this.onInput } rows="1" placeholder="Add reply"></textarea>
			</div>
			<div class="submit pointer" onclick={ this.submitAnswer } if={ submitButton }>Send</div>
			<div class="card-block" if={ sending }>
				Sending your reply ...
			</div>
		</div>
		-->

		<!-- <ul class="list-group list-group-flush">
			<li class="list-group-item"><input class="comment-input" type="text" placeholder="Answer" /></li>
		</ul>
	-->
	</div>



<script>
	var self            = this
	self.post           = opts.post
	self.answers        = []
	self.sending        = false
	self.wannaknowCount = 0
	self.wannaknown     = false
	self.submitButton   = false
	self.anonymous      = false
	self.edit           = false

	this.on('mount', function() {
	})

	init() {
		if (this.post.get('answerCount')>0)
			API.getanswersforpost(this.post).then(function(answers){
				self.answers = answers
				self.update()
			})

		self.wannaknowCount = self.post.get('wannaknowCount')

		for (var i = 0; i < self.parent.wannaknows.length; i++) {
			if (self.parent.wannaknows[i].get('post').id == self.post.id) {
				self.wannaknown = true
				self.update()
				break
			}
		}
	}

	getAuthorName() {
		if (this.post.get('anonymous'))
			return 'Anonymous'
		else
			return this.post.get('author').get('firstName') + ' ' + this.post.get('author').get('lastName')
	}
	getContent() {
		var content = self.post.get('content')
		var regex = /(https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/ig
		var replacedContent = content.replace(regex, "<a href='$1' target='_blank'>$1</a>")
		self.content.innerHTML = replacedContent
		return self.post.get('content')
	}
	getTime() {
		var t = Date.parse(new Date()) - Date.parse(self.post.get('createdAt'))
		var days = Math.floor( t/(1000*60*60*24) )
		if (days) return days == 1 ? days + ' day ago' : days + ' days ago'
		var hours = Math.floor( (t/(1000*60*60)) % 24 )
		if (hours) return hours == 1 ? hours + ' hour ago' : hours + ' hours ago'
		var minutes = Math.floor( (t/1000/60) % 60 )
		if (minutes) return minutes == 1 ? minutes + ' minute ago' : minutes + ' minutes ago'
		var seconds = Math.floor( (t/1000) % 60 )
		if (seconds) return seconds == 1 ? seconds + ' second ago' : seconds + ' seconds ago'
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

	submitEdit() {
		self.post.save({
			content: self.editcontent.value
		},{
			success: function(post) {
				self.edit = false
				self.update()
			}, error: function(post, error) {}
		})
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

	showEdit() {
		self.edit              = true
		self.editcontent.value = self.post.get('content')
		self.update()
		self.editcontent.focus()
	}

	deletePost() {
		deletepostTag.update({post: self.post})
		$('#deletepostModal').modal('show')
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

	.postauthor {
		position: relative;
	}
	.postauthor img{
		vertical-align: text-bottom;
	}

	.options {
		position: absolute;
		top: 0;
		right: 0;
	}

	.toggler {
		font-size: 16px;
		color: #e2e2e2;
	}

	.options-item {
		padding: 2px 10px;
	}
	.options-item:hover {
		background-color: #eee;
	}

	.btn-container {
		text-align: right;
	}

	.edit-btn {
		font-size: 14px;
		padding: 3px 10px;
	}

	.likes {
		display: inline-block;
		font-size: 16px;
		margin-top: 8px;
		padding-left: 5px;
		color: #00C392;
	}

	.post-content{
		font-size: 14px;
		margin-top: 8px;
		margin-bottom: 0px;
		padding-left: 15px;
		width: calc(100% - 35px);
		display: inline-block;
	}
	.post-content:focus {
		outline: none;
	}

	.author {
		padding-right: 8px;
		font-weight: 600;
		color: #2b2d31;
	}
	.time{
		font-size: 12px;
		color: #93969d;
	}
	.author-about{
		font-size: smaller;
	}
	.profile {
		width: 35px;
		height: 35px;
		margin-right: 6px;
		border-radius: 4px;
		object-fit: cover;
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

	.post-image {
		padding-left: 45px;
		max-width: 100%;
		-webkit-border-radius: 5px;
    	-moz-border-radius: 5px;
    	border-radius: 5px;
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
		padding: 1rem;
	}

	.card {
		margin-bottom: .6rem;
	}

	.dropdown-toggle::after {
		border: none;
		content: none;
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
</postitem>