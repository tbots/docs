	var enabledSave = 0;
	var actualUserId = 0;

	$(document).ready(function() {
	});

	function changeDomain(domainId){
		window.location.href="/"+serverApplicationName+"/users/index/"+domainId;
	}
	
	function editUser(userId){
		actualUserId = userId;
		$.get("/"+serverApplicationName+"/users/editUser/"+userId+"/"+$('#selDomain').val(), function(respons) {			
		    bootbox.dialog({
		    	title: "Edit user",
		    	message:respons,
		    	buttons: {
		    		save: {
		    			label: "Save",
		    			className: "btn green",
		    			callback:saveUser 
		    		},
		    		cancel: {
		    			label:"Cancel",
		    			className: "btn blue"
		    		}
		    	}		    	
		    });
		});
	}
	
	function testUsername() {
		$.get("/"+serverApplicationName+"/users/testUsername/"+$('#username').val(), function(respons) {
			if(respons != '0') enabledSave = 1; 
			else enabledSave = 0;
		});
	}
	
	function saveUser() {
		
		
		if(actualUserId == 0)
			testUsername();
		
		if(!isEmail($('#email').val())) {
			bootbox.alert("Email is not correct.");
			return false;
		}

		
		if(enabledSave != 0){
			bootbox.alert("Username is used.");
			return false;
		}
		else{
			$.post( "/"+serverApplicationName+"/users/saveUser/", $( "#userForm" ).serialize(), function( data ) {
				if(data.length == 32){
					//bootbox.alert("User was changed.");
					window.location.href="/"+serverApplicationName+"/users/index/"+$('#selDomain').val();
				}
			});	
		}
		enabledSave = 0;
	}
	
	function updateStatus(userId) {
		
		status = $('#active-'+userId).is(":checked")		
		$.get("/"+serverApplicationName+"/users/updateUserStatus/"+userId+"/"+status, function(respons) {
			ba = bootbox.alert("User status was changed.");
			window.setTimeout(function(){
				ba.modal('hide');
			}, 1000);
		});
		
	}
	
	function deleteUser(userId) {
		bootbox.confirm("Are you sure you want to delete user?", function(result) {
			if(result){
				$.get("/"+serverApplicationName+"/users/deleteUser/"+$('#selDomain').val()+"/"+userId, function(respons) {
					//bootbox.alert("User was deleted.");
					window.location.href="/"+serverApplicationName+"/users/index/"+$('#selDomain').val();
				});
				
			}
		});
	}


	function userProject(userId){
		$.get("/"+serverApplicationName+"/users/userProject/"+userId+"/"+$('#selDomain').val(), function(respons) {			
		    bootbox.dialog({
		    	title: "User's project",
		    	message:respons,
		    	buttons: {
		    		save: {
		    			label: "Save",
		    			className: "btn green",
		    			callback:saveUserProject 
		    		},
		    		cancel: {
		    			label:"Cancel",
		    			className: "btn blue"
		    		}
		    	}		    	
		    });
		});
	}
	
	function saveUserProject(){
		$.post( "/"+serverApplicationName+"/users/saveUserProject/", $( "#projectForm" ).serialize(), function( data ) {
			if(data.length == 32){
				//bootbox.alert("Project was saved.");
				window.location.href="/"+serverApplicationName+"/users/index/"+$('#selDomain').val();
			}
		});
	}
	
	function userGroups(userId){
		$.get("/"+serverApplicationName+"/users/userGroups/"+userId+"/"+$('#selDomain').val(), function(respons) {			
		    bootbox.dialog({
		    	title: "User's groups",
		    	message:respons,
		    	buttons: {
		    		save: {
		    			label: "Save",
		    			className: "btn green",
		    			callback:saveUserGroups 
		    		},
		    		cancel: {
		    			label:"Cancel",
		    			className: "btn blue"
		    		}
		    	}		    	
		    });
		});
		$('#groupNodes').multiSelect();
	}
	
	function saveUserGroups(){
		$.post( "/"+serverApplicationName+"/users/saveUserGroups/", $( "#projectForm" ).serialize(), function( data ) {
		});
	}
	
	function isEmail(email) {
		  var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
		  return regex.test(email);
		}
