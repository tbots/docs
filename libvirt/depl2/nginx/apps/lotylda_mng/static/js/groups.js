	var enabledSave = 0;

	$(document).ready(function() {
	});

	function changeDomain(domainId){
		window.location.href="/"+serverApplicationName+"/groups/index/"+domainId;
	}
	
	function editGroup(groupId){
		$.get("/"+serverApplicationName+"/groups/editGroup/"+groupId+"/"+$("#selDomain").val(), function(respons) {			
		    bootbox.dialog({
		    	title: "Edit group",
		    	message:respons,
/*		    	size: "large",
		    	className: "modalWide",*/
		    	buttons: {
		    		save: {
		    			label: "Save",
		    			className: "btn green",
		    			callback:saveGroup 
		    		},
		    		cancel: {
		    			label:"Close",
		    			className: "btn blue"
		    		}
		    	}		    	
		    });
		});
	}

	function saveGroup(){
		$.post( "/"+serverApplicationName+"/groups/saveGroup/", $( "#domainForm" ).serialize(), function( data ) {	
			//bootbox.alert("Groups was saved.");
			window.location.href="/"+serverApplicationName+"/groups/index/"+$("#selDomain").val();
		});
	}
	
	function deleteGroup(groupId){
		bootbox.confirm("Are you sure you want to delete group?", function(result) {
			if(result){
				$.get("/"+serverApplicationName+"/groups/deleteGroup/"+groupId, function(respons) {
					window.location.href="/"+serverApplicationName+"/groups/index/"+$("#selDomain").val();
				});
				
			}
		})
	}
	
	function editGroupUsers(groupId){
		$.get("/"+serverApplicationName+"/groups/editGroupUsers/"+groupId+"/"+$("#selDomain").val(), function(respons) {			
		    bootbox.dialog({
		    	title: "Edit group",
		    	message:respons,
/*		    	size: "large",
		    	className: "modalWide",*/
		    	buttons: {
		    		save: {
		    			label: "Save",
		    			className: "btn green",
		    			callback:saveUserGroup 
		    		},
		    		cancel: {
		    			label:"Close",
		    			className: "btn blue"
		    		}
		    	}		    	
		    });
		});
		$('#userGroup').multiSelect();
		$('#userGroup').multiSelect('select',usersInGroup.split(','));
	}
	
	function saveUserGroup(){
		$.post( "/"+serverApplicationName+"/groups/saveUserGroup/", $( "#domainForm" ).serialize(), function( data ) {	
			//bootbox.alert("Groups users was saved.");			
		});		
	}
	
	function editGroupProjects(groupId){
		$.get("/"+serverApplicationName+"/groups/editGroupProjects/"+groupId+"/"+$("#selDomain").val(), function(respons) {			
		    bootbox.dialog({
		    	title: "Edit group projects",
		    	message:respons,
		    	buttons: {
		    		save: {
		    			label: "Save",
		    			className: "btn green",
		    			callback:saveGroupProjects 
		    		},
		    		cancel: {
		    			label:"Close",
		    			className: "btn blue"
		    		}
		    	}		    	
		    });
		});		
	}
	
	function saveGroupProjects(){
		$.post( "/"+serverApplicationName+"/groups/saveGroupProjects/", $( "#domainForm" ).serialize(), function( data ) {	
			//bootbox.alert("Groups projects was saved.");			
		});
	}