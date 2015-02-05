/*
 *			              IP: 192.168.42.148
 *			             MAC: e8:de:27:09:06:20  
 *					|        |
 *			          ------| Gate 1 |-----------
 *			         |      |        |          |        |         |
 *		|	 |-------                           ---------|  Server |
 *		| Client |-------                           ---------|         |
 *		|	 |       |                          |
 *	   IP: 192.168.42.100	 -------|        |-----------    IP: 192.168.42.5
 *	  MAC: c4:6e:1f:11:c1:e9	| Gate 2 |              MAC: e8:94:f6:26:25:a5
 *					|        |
 *			           IP: 192.168.42.149
 *			          MAC: c0:4a:00:23:ba:bd 
 *
 *
 *   All the egress traffic generated by the client is split on per flow basis and forwarded via Gate1 or Gate2
 *   to the server. The responses to requests send from a gate are received back from the same gate. 
 *
 *   When gates forward the clients traffic to the server, the mac headers are changed with src set as the Gate's MAC
 *   and dst as the server.
 *   When the gates receive the responses from the server, the mac headers are changed with src set as the Gate's MAC
 *   and dst as the client.
 */


fd::FromDevice(mesh0, SNIFFER false) 	-> Print(X, MAXLENGTH  100)
					-> Strip(14)
					-> CheckIPHeader(0)
					-> ipc :: IPClassifier(dst 192.168.42.5, dst 192.168.42.100, -) 
					-> Queue() 
					-> EtherEncap(0x0800, e8:de:27:09:06:20, e8:94:f6:26:25:a5) 
					-> Print(Y, MAXLENGTH 100)
					-> [0]rrs

ipc[1] 	-> Queue 
	-> EtherEncap(0x0800, e8:de:27:09:06:20, c4:6e:1f:11:c1:e9) 
	-> Print (Z,MAXLENGTH 100)
	-> [1]rrs

rrs	-> td

ipc[2]	-> Discard
