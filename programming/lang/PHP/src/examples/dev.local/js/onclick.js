
function close_popup(){
	var popup = document.getElementById("popup");
	popup.classList.remove("active");
}


/* * *  FORM  1  * * */


/* Display acl description set on the particular server. */
function show_acl(e) {		
	e.preventDefault();

	var server = document.getElementById("server-form1").value;		/* Get form variables */
	var user   = document.getElementById("user-form1").value;
	
	var xhttp = new XMLHttpRequest();		/* Prepare the request */
		xhttp.onreadystatechange = function () {
		if (xhttp.readyState == 4 && xhttp.status == 200) {
			var popup = document.getElementById("popup");		/* Return is popup */
			popup.innerHTML = xhttp.responseText;	
			popup.classList.add("active");
		}
	}
	xhttp.open("POST", "/show_acl.php", true);

	var data = new FormData();

	/* Populate form data */
	data.append("server", server);	/* $_POST['server'] */
	data.append("user",user);				/* $_POST['user']   */

	xhttp.send(data);
	return false;
}

/* Remove user from the server ACL */
function remove_acl(e) {
	e.preventDefault();

	/* Get form variable values and assign them accordingly */
	var server = document.getElementById("server-form1").value;
	var user = document.getElementById("user-form1").value;

	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (xhttp.readyState == 4 && xhttp.status == 200) {
			var popup = document.getElementById("popup");			/* Return in popup */
			popup.innerHTML = xhttp.responseText;
			popup.classList.add("active");
		}
	}
			
	xhttp.open("POST", "/remove_acl.php", true);

	var data = new FormData();
	data.append("server",server);			/* $_POST['server'] */
	data.append("user",user);					/* $_POST['user']   */
			
	xhttp.send(data);
	return false;
}

/* Set user ACL on the server */
function set_acl(e) {
	e.preventDefault();

	/* Get form variable values and assign them accordingly */
	var server = document.getElementById("server-form1").value;
	var user 	 = document.getElementById("user-form1").value;
	var acl 	 = document.getElementById("acl-form1").value;

	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (xhttp.readyState == 4 && xhttp.status == 200) {
			var popup = document.getElementById("popup");		/* Return in popup */
			popup.innerHTML = xhttp.responseText; 
			popup.classList.add("active");
		}
	}
			
	xhttp.open("POST", "/set_acl.php", true);

	var data = new FormData();
	data.append("server",server);
	data.append("user",user);
	data.append("acl",acl);
			
	xhttp.send(data);
	return false;
}


function show_acl_users(e) {
	e.preventDefault();

	var server = document.getElementById("server-form2").value;
	var acl   = document.getElementById("acl-form2").value;
		
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (xhttp.readyState == 4 && xhttp.status == 200) {
			console.log("text");
			var response = document.getElementById("show_acl_users");
			response.innerHTML = xhttp.responseText;
		}
	}

	xhttp.open("POST", "/show_acl_users.php", true);

	var data = new FormData();
	data.append("server", server);
	data.append("acl", acl);

	xhttp.send(data);
	return false;
}

/* Display servers on which requested user has it's ACL set. */
function show_hosts(e) {
	e.preventDefault();

	/* Get form variable values and assign them accordingly */
	var user 	 = document.getElementById("user-form3").value;

	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (xhttp.readyState == 4 && xhttp.status == 200) {
			var popup = document.getElementById("show_hosts");		/* Return in textbox */
			popup.innerHTML = xhttp.responseText; 
			popup.classList.add("active");
		}
	}
			
	xhttp.open("POST", "/show_hosts.php", true);

	var data = new FormData();
	data.append("user",user);
			
	xhttp.send(data);
	return false;
}
