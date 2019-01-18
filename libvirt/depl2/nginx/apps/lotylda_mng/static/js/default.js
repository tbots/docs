	$(document).ready(function() {
		$("#web2py_user_form table").addClass('table table-condensed');		
		$('#web2py_user_form input').addClass('form-control input-medium');
		$('input[value="Log In"]').removeClass('form-control input-medium').addClass('btn blue');
		
		if($('#flash h3').html() != '') {
			$('#flash').show(0);
			$('#flash').delay( 2000 ).hide(0);
		}
	});

	var  projectUsersChange = 0;
	var  projectGroupsChange = 0;
	
	function selProjects(){
		window.location.href="/"+serverApplicationName+"/default/index/"+$( "#domainId" ).val();
	}
	
	function projectGo(){
		window.location.href="/"+$( "#projectId" ).val()+"/"
	}
	
	//edit domain in administration index
	function editDomain(domainId){
		$.get("/"+serverApplicationName+"/default/editDomain/"+domainId, function(respons) {			
		    bootbox.dialog({
		    	title: "Edit domain",
		    	message:respons,
		    	buttons: {
		    		save: {
		    			label: "Save",
		    			className: "btn green",
		    			callback:saveDomain 
		    		},
		    		cancel: {
		    			label:"Cancel",
		    			className: "btn blue"
		    		}
		    	}		    	
		    });
		});
	}
 
	function saveDomain(){
		if($('#domain_name').val().length < 1){
			bootbox.alert("<h4>Please, fill domain name.</h4>");
			return false;
		}
		$.post( "/"+serverApplicationName+"/default/saveDomain/", $( "#domainForm" ).serialize(), function( data ) {
			if(data.length == 32)
				window.location.href="/"+serverApplicationName+"/default/indexAdmin/";
		});
	}
	
	function deleteDomain(domainId){
		bootbox.confirm("Are you sure you want to delete domain?", function(result) {
			if(result){
				$.get("/"+serverApplicationName+"/default/deleteDomain/"+domainId, function(respons) {
					ba = bootbox.alert("Domain was deleted.");
					window.setTimeout(function(){
						ba.modal('hide');
					}, 1000);
					window.location.href="/"+serverApplicationName+"/default/indexAdmin/";
				});
				
			}
		})
	}
	
	//project administration on index Administration page
	function editProject(domainId,projectId){
		bLabel = "Save project";
		bClass = "btn blue";
		if(projectId == 0){
			bLabel = "Create project";
			bClass = "btn green";			
		}
			
		$.get("/"+serverApplicationName+"/default/editProject/"+domainId+"/"+projectId, function(respons) {			
		    bootbox.dialog({
		    	title: "Edit project",
		    	message:respons,
		    	buttons: {
		    		save: {
		    			label: bLabel,
		    			className: bClass,
		    			callback:saveProject 
		    		},
		    		cancel: {
		    			label:"Cancel",
		    			className: "btn blue"
		    		}
		    	}		    	
		    });
		});		
	}

	function saveProject(){
		if($('#project_name').val().length < 1){
			bootbox.alert("<h4>Please, fill domain name.</h4>");
			return false;
		}
		if($('#main_node').val() == ''){
			bootbox.alert("<h4>Please, set up one node at last.</h4>");
			return false;
		}

		
		$('#relations').css('opacity','0.4').css('filter','alpha(opacity=40)');
		$('#relations').append('<div id="projectCreateLoader"><img src="/'+serverApplicationName+'/static/img/ajax-loader.gif" /></div>');
		
		$.post( "/"+serverApplicationName+"/default/saveProject/", $( "#projectForm" ).serialize(), function( data ) {
			if(data.length == 32){
				//bootbox.alert("Project was created.");
				window.location.href="/"+serverApplicationName+"/default/indexAdmin/";
			}
		});
	}
	

	function deleteProject(domainId,projectId){
		bootbox.confirm("Are you sure you want to delete project?", function(result) {
			if(result){
				$.get("/"+serverApplicationName+"/default/deleteProject/"+domainId+"/"+projectId, function(respons) {
					ba = bootbox.alert("Project was deleted.");
					window.setTimeout(function(){
						ba.modal('hide');
					}, 1000);
					window.location.href="/"+serverApplicationName+"/default/indexAdmin/";
				});
				
			}
		})
	}

	//helper to set up nodes on edit domain
	function setNode(id){
		$("input[name='projectNodes']").prop('disabled', false);
		$('#node'+id).prop('checked', false); 
		$('#node'+id).prop('disabled', true);
	}

	//seems to be not useless
	
	//javascript function for button Privileges on indexAdmin
	function groupsUserPrivileges(domainId,projectId){			
		$.get("/"+serverApplicationName+"/default/groupsUserPrivileges/"+domainId+"/"+projectId, function(respons) {			
		    bootbox.dialog({
		    	title: "Project privileges",
		    	message:respons,
		    	size: "large",
		    	className: "modalWide"		    			    
		    });
		});
		$('#projectUsers').multiSelect({
			 selectableHeader: "<input type='text' id='userSelectable' class='search-input' style='width:100%' autocomplete='off'>",
			 selectionHeader: "<input type='text' id='userSelection' class='search-input' style='width:100%' autocomplete='off'>"
		});
		$('#projectGroups').multiSelect({
			 selectableHeader: "<input type='text' id='groupSelectable' class='search-input' style='width:100%' autocomplete='off'>",
			 selectionHeader: "<input type='text' id='groupSelection' class='search-input' style='width:100%' autocomplete='off'>"
		});
		$('#projectAdmins').multiSelect();
	}

	var oldUserPrivilege = '';
	function usersPrivileges(){		
		if( projectUsersChange == 1){		
			bootbox.confirm("Privileges was changes! Save it?", function(result) {
				if(result){
					saveUserPrivileges(1);					
					/* reload changes */ 					
					privilegeId = $('#userPrivileges').val();
					$.get("/"+serverApplicationName+"/default/getUserPrivileges/"+privilegeId+"/"+$('#projectId').val(), function(respons) {
						//data = JSON.parse(respons);			
						usersList = JSON.parse(respons['users']);
						
						$('#projectUsersWrapper').empty().append('<select name="projectUsers" id="projectUsers" multiple rows="10" onchange="oldUserPrivilege=$(\'#userPrivileges\').val();projectUsersChange=1">');			
						for(item in usersList){
							sel = '';
							if(usersList[item][2] == privilegeId)
								sel = 'selected';
							dis = '';
							if(usersList[item][2] != '0' && usersList[item][2] != privilegeId)
								dis = 'disabled'
							$('#projectUsers').append('<option '+sel+' '+dis+' value="'+usersList[item][0]+'">'+usersList[item][1]+'</option>');
						}
						$('#projectUsers').multiSelect({
							 selectableHeader: "<input type='text' id='userSelectable' class='search-input' style='width:100%' autocomplete='off'>",
							 selectionHeader: "<input type='text' id='userSelection' class='search-input' style='width:100%' autocomplete='off'>"
						});				
					});
				}
				projectUsersChange = 0;
			});
		}
		else {
			privilegeId = $('#userPrivileges').val();
			$.get("/"+serverApplicationName+"/default/getUserPrivileges/"+privilegeId+"/"+$('#projectId').val(), function(respons) {
				//data = JSON.parse(respons);			
				usersList = JSON.parse(respons['users']);
				
				$('#projectUsersWrapper').empty().append('<select name="projectUsers" id="projectUsers" multiple rows="10" onchange="oldUserPrivilege=$(\'#userPrivileges\').val();projectUsersChange=1">');			
				for(item in usersList){
					sel = '';
					if(usersList[item][2] == privilegeId)
						sel = 'selected';
					dis = '';
					if(usersList[item][2] != '0' && usersList[item][2] != privilegeId)
						dis = 'disabled'
					$('#projectUsers').append('<option '+sel+' '+dis+' value="'+usersList[item][0]+'">'+usersList[item][1]+'</option>');
				}
				$('#projectUsers').multiSelect({
					 selectableHeader: "<input type='text' id='userSelectable' class='search-input' style='width:100%' autocomplete='off'>",
					 selectionHeader: "<input type='text' id='userSelection' class='search-input' style='width:100%' autocomplete='off'>"
				});			
			});
		}
		 $('#userSelectable,#userSelection').on('keyup', function(e){
			 sText = $(this).val();
			 wh = $(this).attr('id').split('user')[1];
			 $.each($('.ms-elem-'+wh.toLowerCase()).find('span'), function() {
				 if( $(this).html().toLowerCase().indexOf(sText.toLowerCase()) != -1 )
					 $(this).parent().show();
		         else
		             $(this).parent().hide();
			 });
		 });

	}
	
	function saveProjectAdmins(){
		userId = $('#projectAdmins').val();
		$.get("/"+serverApplicationName+"/default/setProjectAdmins/"+userId+"/"+$('#projectId').val(), function(respons) {
			ba = bootbox.alert("Privileges was saved.");
			window.setTimeout(function(){
				ba.modal('hide');
			}, 1000);
		});
	}
	
	function saveUserPrivileges(saveType){
		userId = $('#projectUsers').val();				
		
		if(saveType=0)
			privilegeId = $('#userPrivileges').val();
		else {
			privilegeId = oldUserPrivilege;
		}
				
		$.get("/"+serverApplicationName+"/default/setUserPrivileges/"+userId+"/"+$('#projectId').val()+"/"+privilegeId, function(respons) {
			ba = bootbox.alert("Privileges was saved.");
			window.setTimeout(function(){
				ba.modal('hide');
			}, 1000);
		});
		projectUsersChange = 0;
	}
	
	var oldGroupPrivilege = '';
	function groupPrivilegesf(){
		if( projectGroupsChange == 1){
			bootbox.confirm("Prvileges was changes! Save it?", function(result) {
				if(result){									
					saveGroupPrivileges(1);	
					groupPrivilegeId = $('#groupPrivileges').val();
					$.get("/"+serverApplicationName+"/default/getGroupPrivileges/"+groupPrivilegeId+"/"+$('#projectId').val(), function(respons) {
						//data = JSON.parse(respons);			
						groupList = JSON.parse(respons['groups']);
						$('#projectGroupsWrapper').empty().append('<select name="projectGroups" id="projectGroups" multiple rows="10" onchange="oldGroupPrivilege=$(\'#groupPrivileges\').val();projectGroupsChange=1">');
						for(item in groupList){
							sel = '';
							if(groupList[item][2] == groupPrivilegeId)
								sel = 'selected';
							dis = '';
							if(groupList[item][2] != '0' && groupList[item][2] != groupPrivilegeId)
								dis = 'disabled'
							$('#projectGroups').append('<option '+sel+' '+dis+' value="'+groupList[item][0]+'">'+groupList[item][1]+'</option>');
						}
						$('#projectGroups').multiSelect({
							 selectableHeader: "<input type='text' id='groupSelectable' class='search-input' style='width:100%' autocomplete='off'>",
							 selectionHeader: "<input type='text' id='groupSelection' class='search-input' style='width:100%' autocomplete='off'>"
						});						
					});		
				}
				projectGroupsChange = 0;
			});
		}
		else {
		groupPrivilegeId = $('#groupPrivileges').val();
			$.get("/"+serverApplicationName+"/default/getGroupPrivileges/"+groupPrivilegeId+"/"+$('#projectId').val(), function(respons) {
				//data = JSON.parse(respons);			
				groupList = JSON.parse(respons['groups']);
				$('#projectGroupsWrapper').empty().append('<select name="projectGroups" id="projectGroups" multiple rows="10" onchange="oldGroupPrivilege=$(\'#groupPrivileges\').val();projectGroupsChange=1">');
				for(item in groupList){
					sel = '';
					if(groupList[item][2] == groupPrivilegeId)
						sel = 'selected';
					dis = '';
					if(groupList[item][2] != '0' && groupList[item][2] != groupPrivilegeId)
						dis = 'disabled'
					$('#projectGroups').append('<option '+sel+' '+dis+' value="'+groupList[item][0]+'">'+groupList[item][1]+'</option>');
				}
				$('#projectGroups').multiSelect({
					 selectableHeader: "<input type='text' id='groupSelectable' class='search-input' style='width:100%' autocomplete='off'>",
					 selectionHeader: "<input type='text' id='groupSelection' class='search-input' style='width:100%' autocomplete='off'>"
				});				
			});		
		}
		 $('#groupSelectable,#groupSelection').on('keyup', function(e){
			 sText = $(this).val();
			 wh = $(this).attr('id').split('group')[1];
			 $.each($('.ms-elem-'+wh.toLowerCase()).find('span'), function() {
				 if( $(this).html().toLowerCase().indexOf(sText.toLowerCase()) != -1 )
					 $(this).parent().show();
		         else
		             $(this).parent().hide();
			 });
		 });
	}	
	
	function saveGroupPrivileges(saveType){
		groupId = $('#projectGroups').val();	
		
		if(saveType == 0)
			privilegeId = $('#groupPrivileges').val();
		else
			privilegeId = oldGroupPrivilege;
		
		$.get("/"+serverApplicationName+"/default/setGroupPrivileges/"+groupId+"/"+$('#projectId').val()+"/"+privilegeId[0], function(respons) {
			ba = bootbox.alert("Privileges was saved.");
			window.setTimeout(function(){
				ba.modal('hide');
			}, 1000);
		});
		projectGroupsChange = 0;
	}
	
	
	function readProjectUsers(){
		domainId = $('#domainId').val();
		$.get("/"+serverApplicationName+"/default/readProjectUsers/"+domainId+"/"+$('#projectId').val(), function(respons) {
			usersList = JSON.parse(respons['users']);
			$('#projectAdminsWrappers').empty().append('<select name="projectAdmins" id="projectAdmins" multiple rows="10">');
			
			for( item in usersList){
				sel = '';
				if(usersList[item][2] == true)
					sel = 'selected';
				$('#projectAdmins').append('<option value="'+usersList[item][0]+'" '+sel+'>'+usersList[item][1]+'</option>');
			} 
			$('#projectAdmins').multiSelect();
		});
	}
	
	function resetUsers(){
		$('#userPrivileges').val(null);
		$('#projectUsersWrapper').empty().append('<select name="projectUsers" id="projectUsers" multiple rows="10"></select>');
		$('#projectUsers').multiSelect({
			 selectableHeader: "<input type='text' id='userSelectable' class='search-input' style='width:100%' autocomplete='off'>",
			 selectionHeader: "<input type='text' id='userSelection' class='search-input' style='width:100%' autocomplete='off'>"
		});
	}
	
	function resetGroups(){
		$('#groupPrivileges').val(null);
		$('#projectGroupsWrapper').empty().append('<select name="projectGroups" id="projectGroups" multiple rows="10"></select>');
		$('#projectGroups').multiSelect({
			 selectableHeader: "<input type='text' id='groupSelectable' class='search-input' style='width:100%' autocomplete='off'>",
			 selectionHeader: "<input type='text' id='groupSelection' class='search-input' style='width:100%' autocomplete='off'>"
		});
	}
	