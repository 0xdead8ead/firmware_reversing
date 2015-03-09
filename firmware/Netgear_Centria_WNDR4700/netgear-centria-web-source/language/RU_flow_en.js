
//Russian wan flow
RU_not_listed="--- Not listed here ---"
RU_choose_isp="Choose your city and ISP name:"
RU_city="City"
RU_isp="ISP"
RU_manual_conf_2="Manual configure"
RU_manual_conf_1="If your ISP is not listed, select "
RU_city_1="Moscow"
RU_city_2="Ekaterinburg"
RU_isp_1="BeeLine (L2TP)"
RU_isp_2="BeeLine (PPTP)"
RU_isp_3="Netbynet (PPTP)"
RU_isp_4="Netbynet (PPPoE)"
RU_isp_5="Starlink"
RU_isp_6="Onlime"
RU_isp_7="Akado (L2TP)"
RU_isp_8="Akado (PPTP)"
RU_login_string="Do you require to enter login and password for Internet access? Choose \"Yes\", if you need to start connection to the internet manually each type after turning on a PC. Otherwise choose \"No\"."
RU_login_yes_str="You have chosen \"Yes\". That means you have a VPN connection, which could be PPTP, L2TP or PPPoE type depending on the ISP. If you do not know what VPN type your ISP is using, you may call your ISP support or check it on a PC directly connected to Internet by clicking \"Details\" in the Status page of your VPN connection."
RU_choose_vpn_str="Choose your VPN type:"
RU_login_no_str="You have chosen \"No\". That means you have Dynamic IP(DHCP) or Static IP connection mode. You need to choose, whether your settings are received dynamically or assigned manually."
RU_service_optional="Service Name is normally optional, to be filled"
RU_pppoe_dual_head="Indicate whether your ISP provides Internet access except for access to local resources (eg, ftp servers, local torrent tracker, DC + + hubs, television and IPTV, etc.)? If you select \"Yes\" in response the router will use the dual access scheme, which is characteristic only of Russia (the so-called dual-access). Otherwise, all traffic will be transmitted only through the VPN-connection."
RU_vpn_dual_head1="Your ISP may provide you Dynamic IP(DHCP) or Static IP connection mode for your intranet interface. You need to choose, whther your settings are received dynamically or assigned manually. "
RU_vpn_dual_head2="Enter DNS servers manually only if your ISP provided you with such information."
RU_intra_ip="Intranet IP Address:"
RU_ip="IP Address:"
attention_static_ip="Attention! Your ISP have Static IP settings for you intranet interface. That means you might need to add static routes to ISP local resources working correctly. Please proceed to the Static routes page in router's GUI after CA finishes the setup process."
RU_finish_head="You have finished manual configuration process. Please go through your settings once again to see whether you've made any mistakes:"
RU_manual_fail_head="Router has failed connecting to the internet. The cause might be in the wrong input settings or ISP downtime. Choose \"Back\" to check your settings and try again or \"Quit wizard\" to close the wizard and proceed to router's GUI page. "
RU_finish_tail="Please click \"Check connection\" button to check your internet connection."
RU_manual_restart="Start Again"
RU_success="Congratulations! You have successfully connected to the Internet (Please proceed with wireless configuration, if no wireless pre-security)."
RU_check_connect="Check connection"
RU_pppoe_static_head="Please enter static IP address and / or DNS servers for your Internet interface if your ISP provided such information. In most cases you should skip this step keeping default values(Get dynamically from ISP)."
RU_router_mac="MAC-address of the router"
RU_mac_default="Use the default"
RU_mac_pc="Use MAC-address of my computer"
RU_vpn_type="VPN-type connection"
RU_pppoe_ip="PPPoE IP address:"
RU_pppoe_local="Indicate whether your ISP provides Internet access except for access to local resources"
RU_login_error="Please select one ..."
RU_manual_spoof_head="Some ISPs using MAC address binding for security reasons. Please specify, whether router should use his own MAC address, your current PC's MAC address or manually add MAC address required."
//For Russian CD-less installation :Tim
RU_isp_l2tp_head="Please enter the following settings (you may find it in the brochure your ISP provided):"
RU_isp_spoof_head="Your ISP is using MAC address binding for security reasons. If you configuring router from a PC previously connected to the Internet, please keep standard choice \"Use Computer MAC Address\". Otherwise enter MAC address manually."
RU_isp_fail_head="Router has failed connecting to the internet. The cause might be in the wrong input settings, ISP downtime, changes in settings from ISP side or wrong input settings. ISP downtime, changes in settings from ISP side or wrong choice of ISP connection type at the first step (if your ISP supports multiple connection types). Choose \"Manual configure\" to manually setup your internet connection or \"Quit Wizard\". "
RU_isp_cong_again="manual setting"
RU_isp_cong_later="configure Later"
RU_isp_alert_choose="Choose the city and ISP"
RU_isp_static_head="Your ISP using Static IP address connection type. You need to enter the following information: "
RU_isp_pptp_static_head="Your ISP is using Static IP address for ocal resources access. Please provide the following settings (DNS servers are optional and only filled when you received them from ISP):"
RU_CA_head="Configuration Wizard"
RU_isp_pppoe_static="Your ISP is using Static IP address for local resources access. Please enter intranet IP address and subnet mask. If you have a gateway specified, you can add it later during static routes configuration:"

lan_mark_subnet="IP Subnet Mask"
lan_mark_gateway="Gateway IP Address"
router_status_domain_ser="Domain name server"
basic_int_intip="Internet IP Address:"
basic_int_autoip="Get dynamically from ISP"
basic_pppoe_login="Login"
basic_pppoe_passwd="Password"
forward_service_name="Service name"
no_mark="No"
sec_off="None"
basic_int_dns="DNS Servers IP address:"
basic_dns="DNS Servers:"
basic_int_primary_dns="Primary DNS"
basic_int_second_dns="Secondary DNS"
basic_int_static_ip="Use Static IP Address:"
basic_int_autodns="Get dynamically from ISP"
basic_int_these="Use Static IP Address"
basic_int_default_mac="Use Default Address"
basic_int_computer_mac="Use Computer MAC Address"
basic_int_this_mac="Use This MAC Address"
basic_intserv_pppoe="PPPoE"
basic_intserv_pptp="PPTP"
basic_intserv_l2tp="L2TP"
quit_mark="Quit wizard"
Genie_18="Application settings for connecting to the Internet";
Genie_35="Finding an Internet connection";
Genie_158="This process may take a minute or two, please wait ...";
auto_mark="Auto";
RU_local_resources_string="Does your ISP provide you local resources? This might include local ftp server, trackers, DC++ hubs, IPTV, etc."
RU_back="<< Back "
RU_next=" Next >>"

login_name_null="Login name cannot be blank."
loginname_not_allowed="Invalid login name!"
password_not_allowed="Invalid password."
invalid_servip="Invalid server address. Please enter it again.\n";
invalid_myip="Invalid IP address. Please enter it again, or leave it blank.";
invalid_mask="Invalid subnet mask. Please enter it again.\n";
invalid_gateway="Invalid gateway IP address. Please enter it again.";
