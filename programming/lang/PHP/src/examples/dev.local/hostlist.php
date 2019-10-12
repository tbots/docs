<!DOCTYPE html>

<?php require('db.php'); 
#							 ^ all the database operations handled here 
?>

<html>
	<head>
		<title>hosts</title>
		<link rel="stylesheet" type="text/css" href="css/index.css" />
	</head>
	<body>
		<div class="bg"></div>
		<div class="popup" id="popup" onclick="close_popup()"></div>
		<script src="js/onclick.js"></script>


		<!-- Show/Set/Remove user from server ACL -->
		<form>
			<table >
				<tr>
					<th class="first_col">Server</th>
					<th class="second_col">User</th>
					<th class="third_col">ACL</th>
				</tr>
				<tr>
					<td>
						<select class="first_col" id="server-form1">
						<?php
						$query = q($mysqli,"SELECT hostname FROM $hosts_table");
						while($host = $query->fetch_assoc())
							echo "<option value='$host[hostname]'>$host[hostname]</option>";
						?>
						</select>
					</td>
					<td>
						<select class="second_col" id="user-form1">
						<?php
						$query = q($mysqli,"SELECT `user` FROM `users`");
						while($user = $query->fetch_assoc()) 
							echo "<option value='$user[user]'>$user[user]</option>";
						?>
						</select>
					</td>
					<td>
						<select class="third_col" id="acl-form1">
						<?php
						$query = q($mysqli,"SELECT * FROM `acl`");
						while($acl = $query->fetch_assoc()) 
							echo "<option value='$acl[number]'>$acl[description]</option>";
						?>
						</select>
					</td>
				</tr>
				<tr>
					<td>
					</td>
					<td id="input">
						<button onclick="show_acl(event)">Show ACL</button>
						<button onclick="remove_acl(event)">Remove from ACL</button>
					</td>
					<td >
						<button onclick="set_acl(event)">Set ACL</button>
					</td>
				</tr>
			</table>
		</form>


		<!-- Show ACL users -->
		<hr />
		<form  >
			<table >
				<tr>
					<th class="first_column">Server</th>
					<th class="second_col">ACL</th>
				</tr>
				<tr>
					<td>
						<select class="first_col" id="server-form2">
						<?php
						$query = q($mysqli,"SELECT hostname FROM $hosts_table");
						while($host = $query->fetch_assoc())
							echo "<option value='$host[hostname]'>$host[hostname]</option>";
						?>
						</select>
					</td>
					<td>
						<select class="second_col" id="acl-form2">
						<?php
						$query = q($mysqli,"SELECT * FROM `acl`");
						while($acl = $query->fetch_assoc()) 
							echo "<option value='$acl[number]'>$acl[description]</option>";
						?>
						</select>
					</td>
				</tr>
				<tr>
					<td>
					</td>
					<td id="input">
						<button onclick="show_acl_users(event)">Show ACL Users</button>
					</td>
				</tr>
			</table>
		</form>

		<textarea id="show_acl_users"
							readonly="true"
				 			style="background-color:white;
				 			  		 padding:5px;
										 margin-top:30px;
										 height:130px;
										 width:400px;"></textarea>

		<!-- servers on which user has it's ACL set -->
		<hr />
		<form  >
			<table >
				<tr>
					<th class="first_column" style="width:100px;">User</th>
				</tr>
				<tr>
					<td>
						<select class="first_col" id="user-form3">
						<?php
						$query = q($mysqli,"SELECT `user` FROM `users`");
						while($user = $query->fetch_assoc()) 
							echo "<option value='$user[user]'>$user[user]</option>";
						?>
						</select>
					</td>
					<td id="input" style="width:120px;">
						<button onclick="show_hosts(event)">Show servers</button>
				</tr>
			</table>
		</form>

		<textarea id="show_hosts"
							readonly="true"
				 			style="background-color:white;
				 			  		 padding:5px;
										 margin-top:30px;
										 height:130px;
										 width:420px;"></textarea>


	</body>
</html>
