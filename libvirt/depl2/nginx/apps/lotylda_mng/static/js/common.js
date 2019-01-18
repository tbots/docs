	function logoutCookie(){
		var cookies = document.cookie.split(";");
		for (ii = 0; ii < cookies.length; ii++)	{		
			var cookie = cookies[ii].trim();
	    	var eqPos = cookie.indexOf("=");
	    	var name = eqPos > -1 ? cookie.substr(0, eqPos) : cookie;
	    	document.cookie = name + "=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/";		
		}
		location.href="/"+serverApplicationName+"/default/user/cas/logout";
	}