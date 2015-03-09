/*function setIP(cf)
{
	var dflag = cf.dyn_get_ip.checked;
	setDisabled(dflag,cf.APaddr1,cf.APaddr2,cf.APaddr3,cf.APaddr4,cf.APmask1,cf.APmask2,cf.APmask3,cf.APmask4,cf.APgateway1,cf.APgateway2,cf.APgateway3,cf.APgateway4);
	if(cf.dyn_get_ip.checked == false)
	{
		cf.dyn_get_dns.checked = false;
		setDNS(cf);
	}
}
//bug 24666 according to the page 128 of spec 2.0,add AP mode
function setDNS(cf)
{
	var dflag = cf.dyn_get_ip.checked;
	if(cf.dyn_get_ip.checked == false)
	{
		cf.dyn_get_dns.checked = false;
		dflag = false;
	}
	setDisabled(dflag,cf.APDAddr1,cf.APDAddr2,cf.APDAddr3,cf.APDAddr4,cf.APPDAddr1,cf.APPDAddr2,cf.APPDAddr3,cf.APPDAddr4);
}*/

function check_static_ip_mask_gtw()
{
	form=document.forms[0];
	form.hid_ap_ipaddr.value=form.APaddr1.value+'.'+form.APaddr2.value+'.'+form.APaddr3.value+'.'+form.APaddr4.value;
    form.hid_ap_subnet.value=form.APmask1.value+'.'+form.APmask2.value+'.'+form.APmask3.value+'.'+form.APmask4.value;
    form.hid_ap_gateway.value=form.APgateway1.value+'.'+form.APgateway2.value+'.'+form.APgateway3.value+'.'+form.APgateway4.value;
	
	if(checkipaddr(form.hid_ap_ipaddr.value)==false || is_sub_or_broad(form.hid_ap_ipaddr.value, form.hid_ap_ipaddr.value, form.hid_ap_subnet.value) == false)
	{
		alert("$invalid_ip");
		return false;
	}
	if(checksubnet(form.hid_ap_subnet.value, 0)==false)
	{
		alert("$invalid_mask");
		return false;
	}
	if(checkgateway(form.hid_ap_gateway.value)==false)
	{
		alert("$invalid_gateway");
		return false;
	}
	if(isGateway(form.hid_ap_ipaddr.value,form.hid_ap_subnet.value,form.hid_ap_gateway.value)==false)
	{
		alert("$invalid_gateway");
		return false;		
	}
	if( isSameIp(form.hid_ap_ipaddr.value, form.hid_ap_gateway.value) == true )
	{
		alert("$invalid_gateway");
		return false;
	}
	if(isSameSubNet(form.hid_ap_ipaddr.value,form.hid_ap_subnet.value,form.hid_ap_gateway.value,form.hid_ap_subnet.value) == false)
	{
		alert("$same_subnet_ip_gtw");
		return false;
	}
	return true;
}

function check_static_dns( wan_assign )
{
	var form=document.forms[0];
	form.ap_dnsaddr1.value=form.APDAddr1.value+'.'+form.APDAddr2.value+'.'+form.APDAddr3.value+'.'+form.APDAddr4.value;
    form.ap_dnsaddr2.value=form.APPDAddr1.value+'.'+form.APPDAddr2.value+'.'+form.APPDAddr3.value+'.'+form.APPDAddr4.value;
	form.hid_ap_ipaddr.value=form.APaddr1.value+'.'+form.APaddr2.value+'.'+form.APaddr3.value+'.'+form.APaddr4.value;

	if(form.ap_dnsaddr1.value=="...")
		form.ap_dnsaddr1.value="";

	if(form.ap_dnsaddr2.value=="...")
		form.ap_dnsaddr2.value="";
	if( check_DNS(form.ap_dnsaddr1.value,form.ap_dnsaddr2.value,wan_assign,form.hid_ap_ipaddr.value))
		return true;
	else
		return false;
}

function checkadv(form)
{
	/* To fix bug 33967 */
	if( wps_progress_status == "2" || wps_progress_status == "3" || wps_progress_status == "start" )
	{
		alert("$wps_in_progress");
		return false;
	}
	if(form.rts.value == "" || form.rts_an.value == "")
	{	
		alert("$rts_range");
		return false;
	}
        if(!(form.rts.value > 0 && form.rts.value <= 2347) || !(form.rts_an.value > 0 && form.rts_an.value <= 2347))
        {
                alert("$rts_range");
                return false;
        }
	//form.wl_rts.value = form.rts[0].value;
	//form.wla_rts.value = form.rts[1].value;

	if(form.frag.value == "" || form.frag_an.value == "")
	{
		alert("$fragmentation_range");
		return false;
	}
	if(!(form.frag.value > 255 && form.frag.value < 2347) || !(form.frag_an.value > 255 && form.frag_an.value < 2347))
	{
		alert("$fragmentation_range");
		return false;
	}

	if(form.ssid_bc.checked == true)
		form.wl_enable_ssid_broadcast.value="1";
	else
		form.wl_enable_ssid_broadcast.value="0";
	if(form.enable_isolation.checked == true)
		form.wlg_endis_wireless_isolation.value="1";
	else
		form.wlg_endis_wireless_isolation.value="0";
	if(form.ssid_bc_an.checked == true)
		form.wla_enable_ssid_broadcast.value="1";
	else
		form.wla_enable_ssid_broadcast.value="0";
	if(form.enable_isolation_an.checked == true)
		form.wla_endis_wireless_isolation.value="1";
	else
		form.wla_endis_wireless_isolation.value="0";
        if(form.wmm_enable.checked == true)
               	form.wladv_endis_wmm.value = "1";
        else
               	form.wladv_endis_wmm.value = "0";
        if(form.wmm_enable_a.checked == true)
                form.wladv_endis_wmm_a.value = "1";
        else
                form.wladv_endis_wmm_a.value = "0";

	if(form.enable_shortpreamble.selectedIndex == "2")
		form.wl_enable_shortpreamble.value = "2";
	else if(form.enable_shortpreamble.selectedIndex == "1")
                form.wl_enable_shortpreamble.value = "1";
	else if(form.enable_shortpreamble.selectedIndex == "0")
		form.wl_enable_shortpreamble.value = "0";
        if(form.enable_shortpreamble_an.selectedIndex == "2")
                form.wla_enable_shortpreamble.value = "2";
        else if(form.enable_shortpreamble_an.selectedIndex == "1")
                form.wla_enable_shortpreamble.value = "1";
        else if(form.enable_shortpreamble_an.selectedIndex == "0")
                form.wla_enable_shortpreamble.value = "0";
	//transmit power control
	wlan_txctrl(form, form.tx_power_ctrl.value, form.tx_power_ctrl_an.value, wla_channel, country);

	if(form.enable_ap.checked == true)
		form.wl_enable_router.value="1";
	else
		form.wl_enable_router.value="0";
	if(form.enable_ap_an.checked == true)
                form.wla_enable_router.value="1";
        else
                form.wla_enable_router.value="0";


	if( form.enable_coexist.checked == true)
		form.hid_enable_coexist.value="0";
	else
		form.hid_enable_coexist.value="1";

	if(wps_protect_pin_flag == 1)
	{
		if(form.pin_enable.checked == true )
			form.endis_pin.value="0";
		else
			form.endis_pin.value="1";
		if(form.protect_enable.checked == true)
			form.hid_protect_enable.value="1";
		else
			form.hid_protect_enable.value="0";
		if(form.wps_fail_count.value == "")
			form.wps_fail_count.value = "3";
		form.wps_fail_count.value = parseInt(form.wps_fail_count.value, 10);
	}
	else
	{
		if(form.pin_disable.checked == true )
			form.endis_pin.value="1";
		else
			form.endis_pin.value="0";
	}
	if(form.wsc_config.checked == true)
	{
		form.endis_wsc_config.value="5";
		form.endis_wsc_config_a.value="5";
	}
	else
	{
		form.endis_wsc_config.value="1";
		form.endis_wsc_config_a.value="1";
	}
	/*if(form.wsc_config_a.checked == true)
		form.endis_wsc_config_a.value="5";
	else
		form.endis_wsc_config_a.value="1";*/ //for 28582 missed. so show 38104 bug.
	if ( old_endis_wl_radio =="0" && form.wl_enable_router.value == "0")
		form.wds_change_ip.value="still_lanip"
	else if( old_endis_wl_radio =="0" && form.wl_enable_router.value == "1" )
	{
		if ( old_wds_endis_fun == "1" &&  old_wds_repeater_basic == "0" )
		{
			if(pr_wds_support_wpa !=1 && (security_mode=="3" ||  security_mode=="4" || security_mode == "5"))
			{
				if(!confirm("$wds_not_wpa"))
					return false;
				else
				{
					location.href="WLG_wireless.htm";
					return false;
				}
			}
			else if( security_mode == "6")
			{
				if(!confirm("$wds_not_Enterprise"))
					return false;
				else
				{
					location.href="WLG_wireless.htm";
					return false;
				}
			}
			else
			{
				top.enable_action=0;
				form.wds_change_ip.value="to_repeatip";
			}
		}
		else
			form.wds_change_ip.value="still_lanip"	
	}
	else if ( old_endis_wl_radio =="1" && form.wl_enable_router.value == "0")
	{
		if ( old_wds_endis_fun == "1" &&  old_wds_repeater_basic == "0" )
		{
			top.enable_action=0;
			form.wds_change_ip.value="to_lanip";
		}
		else
			form.wds_change_ip.value="still_lanip";
	}
	else
	{
		if ( old_wds_endis_fun == "1" &&  old_wds_repeater_basic == "0" )
			form.wds_change_ip.value="still_repeatip"
		else
			form.wds_change_ip.value="still_lanip"	
	}
	form.rts.value=port_range_interception(form.rts.value);
	form.rts_an.value=port_range_interception(form.rts_an.value);
	form.frag.value=port_range_interception(form.frag.value);
	form.frag_an.value=port_range_interception(form.frag_an.value);
	form.wl_rts.value = form.rts.value;
	form.wla_rts.value = form.rts_an.value;
	form.wl_frag.value = form.frag.value;
	form.wla_frag.value = form.frag_an.value;
	
	//wireless schedule
	if(form.wirless_schedule.checked)
		form.wladv_enable_schedule.value = "1";
	else
		form.wladv_enable_schedule.value = "0";

	if(form.wirless_schedule_an.checked)
		form.wladv_enable_schedule_a.value = "1";
	else
		form.wladv_enable_schedule_a.value = "0";

	form.submit();
	//return true;
}

function checkap(form) //for bug 30286
{
     form.hid_ap_ipaddr.value=form.APaddr1.value+'.'+form.APaddr2.value+'.'+form.APaddr3.value+'.'+form.APaddr4.value;
    form.hid_ap_subnet.value=form.APmask1.value+'.'+form.APmask2.value+'.'+form.APmask3.value+'.'+form.APmask4.value;
    form.hid_ap_gateway.value=form.APgateway1.value+'.'+form.APgateway2.value+'.'+form.APgateway3.value+'.'+form.APgateway4.value;
	form.ap_dnsaddr1.value=form.APDAddr1.value+'.'+form.APDAddr2.value+'.'+form.APDAddr3.value+'.'+form.APDAddr4.value;
    form.ap_dnsaddr2.value=form.APPDAddr1.value+'.'+form.APPDAddr2.value+'.'+form.APPDAddr3.value+'.'+form.APPDAddr4.value;

       /*if(form.enable_apmode.checked == true)
       {
               if(form.device_name.value=="")
               {
                       alert("$device_name_null");
                      return false;
              }
              for(i=0;i<form.device_name.value.length;i++)
               {
                      if(isValidChar_space(form.device_name.value.charCodeAt(i))==false)
                       {
                               alert("$device_name_error");
                              return false;
                      }
               }
       }*/

        if( wps_progress_status == "2" || wps_progress_status == "3" || wps_progress_status == "start" )
       {
                alert("$wps_in_progress");
                return false;
        }

       if(form.enable_apmode.checked == true)
       {
               form.hid_enable_apmode.value="1";
			   
               if(form.dyn_get_ip[1].checked == true)
               {
                       if(check_static_ip_mask_gtw()==false)
                               return false;			
                       if(check_static_dns(!(form.dyn_get_ip.checked)) == false)
                                return false;	
                       form.hid_dyn_get_ip.value="0";//for static
				}
               else
                       form.hid_dyn_get_ip.value="1"; //for dynamic
			   }
       else
       {
               form.hid_enable_apmode.value="0"; //when ap mode is off 
			   form.hid_dyn_get_ip.value="1"; //for dynamic
       }

       form.submit();
}

