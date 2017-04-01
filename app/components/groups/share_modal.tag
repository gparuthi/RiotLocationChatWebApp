<share>

<div id="shareModal" class="modal fade" role="dialog">
	<div class="modal-dialog">
		<div class="modal-content">

			<div class="modal-header"><button type="button" class="close" data-dismiss="modal">&times;</button></div>

			<div class="modal-body">
				<div class="link-container">
					Link to share
					<div class="link">{ window.location.href }</div>
				</div>

				<span class="text-muted">or</span>

				<div class="fb-options">
					<div class="btn btn-primary fb-btn" onclick={ fbShare }><span class="fa fa-facebook"></span>Share</div>
				</div>
			</div>

		</div>
	</div>

</div>


<script>
	var self = this

	fbShare() {
		FB.ui({
		    method: 'send',
		    link: window.location.href,
		}, function(response){});
	}
</script>

<style scoped>
	:scope {
		text-align: center;
	}

	.link-container {
		text-align: left;
		margin-bottom: 15px;
		padding-bottom: 10px;
	}

	.link {
		padding: 10px;
		background-color: #efefef;
		text-align: left;
	}

	.fb-options {
		margin-top: 15px;
	}

	.fb-btn {
		padding-left: 10px;
	}

	.fa-facebook {
		margin-right: 10px;
	}
</style>
</share>