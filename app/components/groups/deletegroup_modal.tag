<deletegroup>

<div id="deletegroupModal" class="modal fade" role="dialog">
	<div class="modal-dialog">

		<div class="modal-content">
			<div class="header modal-header"><button type="button" class="close" data-dismiss="modal">&times;</button></div>

			<div class="modal-body" if={ loading }>
				<i class="fa fa-spinner fa-spin fa-3x fa-fw margin-bottom"></i>
				<span class="sr-only">Loading...</span>
			</div>

			<div class="modal-body" if={ !loading }>
				<div class="text">Are you sure you want to delete {containerTag.group.get('name')}?</div>
				<div class="buttons">
					<button class="btn btn-default" onclick={ deleteGroup }>Yes</button>
					<button class="btn btn-default" data-dismiss="modal">No</button>
				</div>
			</div>
		</div>

	</div>

</div>

<script>
	var self     = this
	self.loading = false

	deleteGroup() {
		self.loading = true
		self.update()

		containerTag.group.save({
			deleted: true,
			groupId: ''
		}, {
			success: function(group) {
				self.loading = false
				$('#deletegroupModal').modal('hide')
				riot.route('/')
				riot.update()
			}, error: function(group, error) {
				self.loading = false
				self.update()
			}
		})
	}
</script>

<style scoped>

</style>
</deletegroup>