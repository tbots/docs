	var enabledSave = 0;

	$(document).ready(function() {
	});

		
	function updateStatus(userId) {
		
		status = $('#active-'+userId).is(":checked");
		
		$.get("/"+serverApplicationName+"/users/updateUserStatus/"+userId+"/"+status, function(respons) {
			bootbox.alert("User status was changed.");
		});
		if(status == 'true')
			$.get("/"+serverApplicationName+"/uzivatele/activeAccountMail/"+userId);
	}
	
	function deleteUser(userId) {
		bootbox.confirm("Are you sure to delete user?", function(result) {
			if(result){
				$.get("/"+serverApplicationName+"/users/deleteUser/"+$('#selDomain').val()+"/"+userId, function(respons) {
					bootbox.alert("User was deleted.");
					window.location.href="/"+serverApplicationName+"/users/index/"+$('#selDomain').val();
				});
				
			}
		});
	}

