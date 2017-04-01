<deletepost>

<div id="deletepostModal" class="modal fade" role="dialog">
	<div class="modal-dialog">

		<div class="modal-content">
			<div class="header modal-header"><button type="button" class="close" data-dismiss="modal">&times;</button></div>

			<div class="modal-body" if={ loading }>
				<i class="fa fa-spinner fa-spin fa-3x fa-fw margin-bottom"></i>
				<span class="sr-only">Loading...</span>
			</div>

			<div class="modal-body" if={ !loading }>
				<div class="text">Are you sure you want to delete the post?</div>
				<div class="buttons">
					<button class="btn btn-default" onclick={ deletepost }>Yes</button>
					<button class="btn btn-default" data-dismiss="modal">No</button>
				</div>
			</div>
		</div>

	</div>

</div>

<script>
	var self      = this
	deletepostTag = this
	self.post     = opts.post
	self.loading  = false

	deletepost() {
		self.loading = true
		self.update()

		self.post.destroy({
			success: function() {
				self.loading = false
				homefeedTag.init()
				$('#deletepostModal').modal('hide')
				self.update()
			}, error: function(error) {
				self.loading = false
				self.update()
			}
		})
	}
</script>

<style scoped>

</style>
</deletepost>