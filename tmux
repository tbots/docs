 
 In tmux, a session is displayed on screen by a client and all sessions are managed by a single server. The server and each client are separate processes which communicate through a 
 socket in /tmp. 

 Usage: 	tmux [-2CluvV] [-c shell-command] [-f file] [-L socket-name] [-S socket-path] [command [flags]]

	-2			Force tmux to assume the terminal supports 256 colours. [PLEASE EXPLORE]

 Commands:

  attach 
		DESCRIBE_ME

  list-session     # same as `tmux ls'
		DESCRIBE_ME

  kill-pane 
		DESCRIBE_ME

  resize-pane [-DLMRUZ] [-t target-pane] [-x width] [-y height] [adjustment]
		DESCRIBE_ME

  join-pane [-bdhv] [-l size |-p percantage] [-s src_pane] [-t dst-pane]		(alias: joinp)
		DESCRIBE_ME

  swap-pane [-dDU][-s src-pane][-t dst-pane] (alias: swapp)
		DESCRIBE_ME

	 swap-window [-d] [-s src-window] [-t dst-window] 												(alias: swapw)
	 	DESCRIBE_ME

	 new-session [-AdDEP] [-c start-directory] [-F format] [-n window-name] [-s session-name] [-t target-session] [-x width] [-y height] [shell-command]
	 	(alias: new)

	 	Create a new session with name session-name. The new session is attached to the current terminal unless -d is given. window-name and shell-command are the name of and shell
	 	command to execute in the initial window. If -d is used, -x and -y specify the size of the initial window (80 by 24 if not given). <<< ???

		If run from a terminal, any termios(4) special characters are saved and used for new windows in the new session. <<< ???

		The -A flag makes new-session behave like attach-session if session-name already exists.
 	 new-window [-adkP] [-c start-directory] [-F format] [-n window-name] [-t target-window] [command]
		DESCRIBE_ME

	 kill-window 
	 	DESCRIBE_ME

	 select-layout
	  DESCRIBE_ME
		
	 split-window
		DESCRIBE_ME


 !				Break the current pane out of the window.
 "				Split the current pane into two, top and bottom.
 %				Split the current pane into two, left and right.

 $				Rename current session.
 ,				Rename the current window.

 '				Prompt for a window index to select.
 .				Prompt for an index to move the window (unused index)
 ;				Move to the previously active pane

 [0-9]		switch to the window under numbered index
 f[win]		switch to the window named win

 s				List all sessions
 w				List all windows

 x				Kill current pane
 &				Kill current window

 f				Prompt to search for a text in open windows
 space		Cycle between layouts

 ?				help

 
 When new tmux session has been created it can be listed with `(Ctrl+B)+s' command. 

 	(0) + 25: 1 windows (attached)
       /
 session
    name
 
 After creating a new window within the same session with `(Ctrl+B)+c', it can  window can be viewed with `(Ctrl+B)+s':

 	(0) + 25: 2 windows (attached)
            \
						 notice the change

 and `(Ctrl+B)+w' commands:

	window name
       /
 	(0) 0: bash* host
 	(1) 1: vi* host
      \
			 window name 

 To join pane (pane) from the window (window) from the session (session) with the current specify it as source (-s):

 	join-pane -s session:window.pane

 To join current pane to the pane (pane) from the window (window) from the session (session) specify it as target (-t):

 	join-pane -t session:window.pane
