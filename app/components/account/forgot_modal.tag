<forgot>

<!-- Modal -->
<div id="forgotModal" class="modal fade" role="dialog">
	<div class="modal-dialog">

		<!-- Modal content -->
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal">&times;</button>
				<h4 class="modal-title">Password Reset</h4>
			</div>

			<div class="modal-body">
				<div if={ loading }>
					<i class="fa fa-spinner fa-spin fa-3x fa-fw margin-bottom"></i>
					<span class="sr-only">Loading...</span>
				</div>

				<div if={ !loading }>
					<form if={ !success }>
						<div class="input-group">
							<span class="input-group-addon"><i class="fa fa-envelope-o fa-fw"></i></span>
							<input type="text" class="form-control" name="email" placeholder="Email" />
						</div>

						<br/>
						<button class="btn btn-sm" name="submit" onclick="{ this.submitForgot }">Submit</button>
						<div class="text-warning info" if={ isError }>{ error }</div>
					</form>
					<div class="text-muted" name="successMsg" if={ success }>
						Successfully reset your password, please check your email
					</div>
				</div>
			</div>
		</div>

	</div>
</div>


<script>

	var self     = this
	self.loading = false
	self.success = false
	self.isError = false
	self.error   = ""

	this.on('mount', function() {
		$('#forgotModal').on('shown.bs.modal', function() {
			$(document).bind("touchmove", function(e){
			    e.preventDefault();
			});
		})
		$('#forgotModal').on('hidden.bs.modal', function () {
			$(document).unbind('touchmove');
			self.success     = false
			self.isError     = false
			self.error       = ""
			self.email.value = ""

			self.update()
		})
	})

	submitForgot(){
		self.loading = true
		self.update()

		var userEmail = self.email.value
		Parse.User.requestPasswordReset(userEmail, {
			success: function(user) {
				self.loading = false
				self.success = true
				self.update()
			},
			error: function(error) {
				self.loading = false
				self.update()

				self.isError = true
				self.error   = "Invalid email"
				self.update()
			}
		})
	}

</script>

<style scoped>
	:scope{
		text-align: center;
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

	.info {
		margin-top: 7px;
	}
</style>

</forgot>