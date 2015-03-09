function initPage()
{
	//head text
	var head_tag = document.getElementsByTagName("h1");
	var head_text = document.createTextNode(bh_pptp_connection);
	head_tag[0].appendChild(head_text);
	
	var paragraph = document.getElementsByTagName("p");
	var paragraph_text = document.createTextNode(bh_enter_info_below);
	paragraph[0].appendChild(paragraph_text);
	
	
	//main content items
	var login_name = document.getElementById("loginName");
	var login_text = document.createTextNode(bh_pptp_login_name);
	login_name.appendChild(login_text);

	var passwd = document.getElementById("passwd");
	var passwd_text = document.createTextNode(bh_ddns_passwd);
	passwd.appendChild(passwd_text);

	var idleTimeout = document.getElementById("idleTimeout");
	var idleTimeout_text = document.createTextNode(bh_basic_pppoe_idle);
	idleTimeout.appendChild(idleTimeout_text);
	
	var IP_addr_div = document.getElementById("IP_addr");
	var IP_addr_text = document.createTextNode(bh_info_mark_ip);
	IP_addr_div.appendChild(IP_addr_text);
	
	var serverIP_div = document.getElementById("serverIP");
        var serverIP_text = document.createTextNode(bh_basic_pptp_servip);
        serverIP_div.appendChild(serverIP_text);

	var Gateway_div = document.getElementById("Gateway");
	var Gateway_text = document.createTextNode(bh_sta_routes_gtwip);
	Gateway_div.appendChild(Gateway_text);
	
	var connectionID_div = document.getElementById("connectionID");
        var connectionID_text = document.createTextNode(bh_basic_pptp_connection_id);
        connectionID_div.appendChild(connectionID_text);


	//set input event action
	var name_input = document.getElementById("inputName");
	name_input.onkeypress = ssidKeyCode;

	var passwd_input = document.getElementById("inputPasswd");
	passwd_input.onkeypress = ssidKeyCode;

	var idle_input = document.getElementById("inputIdle");
	idle_input.onkeypress = numKeyCode;

	var IP_addr_input = document.getElementById("inputIPaddr");
	IP_addr_input.onkeypress = ipaddrKeyCode;
	
	var severIP_input = document.getElementById("inputServerIP");
	severIP_input.value = "10.0.0.138";
	severIP_input.disabled = true;

	var gateway_input = document.getElementById("inputGateway");
	gateway_input.onkeypress = ipaddrKeyCode;


	//buttons 
	var btns_container_div = document.getElementById("btnsContainer_div");
	btns_container_div.onclick = function()
	{
		return checkPPTP();
	}
	
	var btn = document.getElementById("btn_text_div");
	var btn_text = document.createTextNode(bh_next_mark);
	btn.appendChild(btn_text);

	//show firmware version
        showFirmVersion("none");
}

function checkPPTP()
{
	var forms = document.getElementsByTagName("form");
	var cf = forms[0];

	var pptp_username = document.getElementById("inputName");
	var pptp_passwd = document.getElementById("inputPasswd");
	var pptp_idletime = document.getElementById("inputIdle");

	if(pptp_username.value=="")
	{
		alert(bh_login_name_null);
		return false;
	}

	var i;
	for(i=0; i<pptp_passwd.value.length; i++)
	{
		if(isValidChar(pptp_passwd.value.charCodeAt(i))==false)
		{
			alert(bh_password_error);
			return false;
		}
	}
	if(pptp_idletime.value.length <= 0)
	{
		alert(bh_idle_time_null);
		return false;
	}
	else if(!_isNumeric(pptp_idletime.value))
	{
		alert(bh_invalid_idle_time);
		return false;
	}

	if(!checkIPaddr())
		return false;

	cf.submit();

	return true;
}

function checkIPaddr()
{
	var forms = document.getElementsByTagName("form");
        var cf = forms[0];

	var pptp_myip = document.getElementById("inputIPaddr");
        var pptp_gateway = document.getElementById("inputGateway");
	var pptp_serverip= document.getElementById("inputServerIP");

	if(pptp_myip.value != "")
	{
		cf.WANAssign.value = 1;

                /* To fix Bug27179: [New GUI][CD-less]DUT should pop up error message if Gateway IP Address
		 * and My IP Address are in different network.
		 */

		var pptp_myip1 = pptp_myip.value.split(".")[0];
		var pptp_mask="255.255.255.0";

		if( parseInt(pptp_myip1) < 128 )
			pptp_mask="255.0.0.0";
		else if( parseInt(pptp_myip1) < 192 )
			pptp_mask="255.255.0.0";
		else
			pptp_mask="255.255.255.0";

		cf.pptp_subnet.value=pptp_mask;


		if(checkipaddr(pptp_myip.value)==false)
		{
			alert(bh_invalid_myip);
			return false;
		}
		/*Bug 30115 - [GUI][CD-less/Setup Wizard]I can set My IP address as 10.0.0.138 when detected as PPTP mode*/
		if(isSameIp(pptp_myip.value,pptp_serverip.value) == true)
		{
			alert(bh_same_server_wan_ip);
			return false;
		}
		if(pptp_gateway.value != "" && checkgateway(pptp_gateway.value) == false)
		{
			alert(bh_invalid_gateway);
			return false;
		}
		if(pptp_gateway.value != "")
		{
			if(isSameIp(pptp_myip.value,pptp_gateway.value) == true)
			{
				alert(bh_invalid_gateway);
				return false;
			}
			if(isGateway(pptp_myip.value,cf.pptp_subnet.value,pptp_gateway.value) == false)
			{
				alert(bh_invalid_gateway);
				return false;
			}
		}
	}
	else
		cf.WANAssign.value=0;

	return true;
}

addLoadEvent(initPage);
