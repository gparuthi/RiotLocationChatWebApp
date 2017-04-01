<imagesearch>

<div id="outer-container">

	<div id="image-search-container">
		<loader if={ loading }></loader>

		<div if={ !loading }>
			<input id="imageQuery" type="text" placeholder="Search Web Images" oninput={ this.keyUp }>

			<div>
			<loader style="display: block" if={ searching }> </loader>
			</div>

			<div class="image-grid" if={ !searching && searchResults && searchResults.length > 0 }>
				<!-- <div class={ fa:true, fa-chevron-left:searchStart != 0, arrows:true } onclick={ this.shift(-1) }></div>
				<div class="image-container" onload="fadeIn(e)" each={ image in searchResults.slice(searchStart, searchEnd) } onclick={ this.selectImage(image) } style="background-image: url('{ image.thumbnailUrl }')">
				</div>
				<img class="image-container" onload="fadeIn(this)" each={ image in searchResults.slice(searchStart, searchEnd) } onclick={ this.selectImage(image) } src={ image.Thumbnail.MediaUrl }/>
				<div class={ fa:true, fa-chevron-right:searchEnd < searchResults.length, arrows:true } onclick={ this.shift(1) }></div> -->
				<div class="swiper-container">
					<div class="swiper-wrapper">
						<div class="swiper-slide" each={ image in searchResults }>
							<img class="search-results" src={ image.Thumbnail.MediaUrl } onclick={ this.selectImage(image) } />
						</div>
					</div>
				</div>
			</div>

			<div class="upload-container">
				<label for="imageFile"><span class="btn btn-primary">Upload your image</span></label>
				<input name="imageFile" id="imageFile" type="file" style="visibility: hidden; position: absolute;"></input>
			</div>
		</div>
	</div>

	<div id="image-edit-container">
		<loader if={ loading }></loader>

		<div if={ !loading }>
			<img id="image-edit" src={ selectedImage.contentUrl }>
			<button class="btn btn-default fa fa-rotate-left" onclick={ this.rotate(-90) }></button>
			<button class="btn btn-default fa fa-rotate-right" onclick={ this.rotate(90) }></button>
			<button class="btn btn-default" onclick={ this.cropAndUpload }>OK</button>
		</div>
	</div>
</div>

<script>
	var self       = this
	imagesearchTag = this
	self.callback  = opts.callback
	self.searching = false
	self.loading   = false



	this.on('mount', function() {
		$('#outer-container').slideUp({duration: 0})
		$('#image-search-container').slideUp({duration: 0})
		$('#image-edit-container').slideUp({duration: 0})

		$(document).on('change', '#imageFile', self.handleUpload)
	})

	this.on('unmount', function() {
		console.log('called')
	})

	handleUpload() {
		var file = $('#imageFile')[0].files[0]
		var image = {contentUrl: URL.createObjectURL(file), thumbnailUrl: URL.createObjectURL(file)}
		self.selectedImage = image
		self.update()
		self.hideSearch().then(function(result) {
			self.showEdit().then(function(result) {
				if(!self.cropper) self.createCropper()
				else self.cropper.replace(self.selectedImage.contentUrl)
			})
		})
	}

	keyUp() {
		clearTimeout(self.searchTimer)
		if (self.imageQuery.value) {
			self.searchTimer = setTimeout(self.searchImage, 700)
		}
	}

	searchImage(query) {

		self.searchStart   = 0
		self.searchEnd     = 3
		self.searching     = true
		self.update()
		self.searchResults = []

		var query = query || self.imageQuery.value
		API.searchImage(query).then(function(data) {
			self.searchResults = data
			self.searching     = false
			self.update()
			self.createSwiper()
		})
	}

	createSwiper() {
		var swiper = new Swiper('.swiper-container', {
	        slidesPerView: 3.5,
	        spaceBetween: 20,
	        freeMode: true
	    });
	}

	shift(direction) {
		return function() {
			switch(direction) {
				case -1:
					self.searchEnd   = self.searchStart
					self.searchStart -= 3
					self.update()
					break
				case 1:
					self.searchStart = self.searchEnd
					self.searchEnd   += 3
					self.update()
					break
			}
		}
	}

	window.fadeIn = function(obj) {
		$(obj).fadeIn({duration: 200})
	}

	selectImage(image) {
		return function() {
			self.loading = true
			self.update()
			API.getImageThroughProxy(image).then(function(data) {
				self.selectedImage = data
				self.update()

				self.hideSearch().then(function(result) {
					self.loading = false
					self.update()
					self.showEdit().then(function(result) {
						if (!self.cropper) self.createCropper()
						else self.cropper.replace(self.selectedImage.contentUrl)
					})
				})
			})
		}
	}

	createCropper() {
		self.cropper = new Cropper(document.getElementById('image-edit'), {
			viewMode: 3,
			aspectRatio: 16/9,
			cropBoxResizable: false
		})
	}

	rotate(deg) {
		return function() {
			self.cropper.rotate(deg)
		}
	}
	cropAndUpload() {
		console.log(self.cropper.getCroppedCanvas({width: 200}))
		self.cropper.getCroppedCanvas({
			width: 800
		}).toBlob(function(blob) {
			self.loading = true
			self.update()
			var imageUrl     = undefined
			var thumbnailUrl = undefined

			API.uploadImage(blob).then(function(result) {
				if (result) {
					imageUrl = result
					if (thumbnailUrl) {
						self.callback({contentUrl: imageUrl, thumbnailUrl: thumbnailUrl})
						self.loading = false
					}
				}
			})

			API.resizeImage(blob).then(function(resized) {
				API.uploadImage(resized).then(function(result) {
					thumbnailUrl = result
					if (imageUrl) {
						self.callback({contentUrl: imageUrl, thumbnailUrl: thumbnailUrl})
						self.loading = false
					}
				})
			})
		})
	}

	show() {
		var promise = new Parse.Promise()
		$('#outer-container').slideDown({duration: 0})
		self.showSearch().then(function(result) { 
			promise.resolve(true)
			$('#imageQuery').focus()

		})

		return promise
	}

	hide() {
		var promise  = new Parse.Promise()

		$('#outer-container').slideUp({
			duration: 0,
			complete: function() { promise.resolve(true) }
		})

		self.loading = false
		self.update()
		$('#image-search-container').slideUp({duration: 0})
		$('#image-edit-container').slideUp({duration: 0})

		self.searchResults    = undefined
		self.selectedImage    = undefined
		self.imageQuery.value = ''
		self.update()

		return promise
	}

	showSearch() {
		var promise = new Parse.Promise()
		$('#image-search-container').slideDown({
			duration: 0,
			complete: function() { promise.resolve(true) }
		})

		return promise
	}

	hideSearch() {
		var promise = new Parse.Promise()
		$('#image-search-container').slideUp({
			duration: 0,
			complete: function() { promise.resolve(true) }
		})

		return promise
	}

	showEdit() {
		var promise = new Parse.Promise()
		$('#image-edit-container').slideDown({
			duration: 0,
			complete: function() { promise.resolve(true) }
		})

		return promise
	}

	hideEdit() {
		var promise = new Parse.Promise()
		$('#image-edit-container').slideUp({
			duration: 0,
			complete: function() { promise.resolve(true) }
		})

		return promise
	}
</script>

<style scoped>
	:scope {
		text-align: center;
	}

	#image-search-container input {
		margin-bottom: 10px;
		text-align: center;
		font-size: large;
		border: none;
	}


	#image-search-container input:focus {
		outline: none;
	}

	#outer-container{
		margin-bottom: 1rem;
	}

	#imageQuery{
		border-bottom: 1px solid #fafafa !important;
	}

	.image-edit-container{
		padding-bottom: 16px;
	}

	.cropper-container{
		margin: 1rem 0;
	}

	.search-results {
		height: 110px;
		object-fit: cover;
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
		display: none;
	}

	.uploaded-image label {
		width: 100%;
		height: 300px;
	}

	#image-edit {
		width: 100%;
		height: 300px;
	}

	.options {
		padding-bottom: 10px;
		text-align: center;
		font-size: 26px;
		font-weight: 600;
		color: #bbb;
	}

	.upload-container {
		padding-top: 20px;
	}

	@media screen and (max-width: 543px) {
		.image-container {
			height: 80px;
		}
	}
</style>
</imagesearch>