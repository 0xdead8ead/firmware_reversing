function initPage()
{
	var head_tag  = document.getElementsByTagName("h1");

	var connect_text = document.createTextNode(bh_connection_mode);
	head_tag[0].appendChild(connect_text);

	var choices_div = document.getElementById("choices_div");
	var choices = choices_div.getElementsByTagName("input");

	var choices_text = document.createTextNode(bh_ethernet_connection);
	insertAfter(choices_text, choices[0]);

	choices_text = document.createTextNode(bh_mobile_broadband_connection);
	insertAfter(choices_text, choices[1]);

	choices_text = document.createTextNode(bh_multi_wan_connection);
	insertAfter(choices_text, choices[2]);

	var btns_container_div = document.getElementById("btnsContainer_div");
	btns_container_div.onclick = function()
	{
		return connModeChoice();
	}

	var btn = document.getElementById("btn_div");
	var btn_text = document.createTextNode(bh_next_mark);
	btn.appendChild(btn_text);
}

function connModeChoice()
{
	var choices_div = document.getElementById("choices_div");
	var choices = choices_div.getElementsByTagName("input");

	var forms = document.getElementsByTagName("form");
	var cf = forms[0];
	if(choices[0].checked)
	{
		if( top.is_ru_version == 1)
			this.location.href="RU_check_wan_port.html";
		else
			cf.submit();
	}
	else if (choices[1].checked)
	{
		cf.action="/apply.cgi?/config_3g_wait_page.htm timestamp="+ts;
		cf.submit_flag.value="wizard_3g_detwan";
		cf.submit();
	}
	else if (choices[2].checked)
	{
		top.multi_wan_mode="multi";
		this.location.href="WIZ_failover_01.htm";
	}
	else
	{
		alert(bh_select_an_option);
		return false;
	}

	return true;
}

addLoadEvent(initPage);
