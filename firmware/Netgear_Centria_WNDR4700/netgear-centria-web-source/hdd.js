function hdd_user_add(cf, flag)
{

		if(cf.sh_name.value == "")
		{
			alert("$device_name_null");
			return false;
		}
		for(i=0;i<cf.sh_name.value.length;i++)
		{ 
			if(isValidChar(cf.sh_name.value.charCodeAt(i))==false)
			{
				alert("$device_name_error");
				return false;
			}
		}
		
			
		for(i=0;i<cf.hddNewPasswd.value.length;i++)
		{       
			if(isValidChar_space(cf.hddNewPasswd.value.charCodeAt(i))==false)
			{
				alert("$password_error");
				return false;
			}
		}
	if ( flag== 'add' )
	{
		if (cf.hddNewPasswd.value.length == 33 || cf.hddConfirmPasswd.value.length == 33)
		{
			alert("$max_password_length");
			return false;
		}
		if(cf.hddNewPasswd.value != cf.hddConfirmPasswd.value)
		{ 
			alert("$newpas_notmatch");
			return false;	
		}
   }	
	
		if( cf.hddNewPasswd.value == "")
		{
			alert("$password_null");
			return false;
		}
		
		cf.hddNewPasswd.value = cf.hddNewPasswd.value.replace(/&/g, "&#38;").replace(/\s/g, "&nbsp;");

	for(i=1;i<=array_num;i++)
	{
		var str = eval ( 'userhddArray' + i );
		var each_info=str.split(' ');
		if(flag == 'edit')
		{
			if(sel_editnum!=i)
			{
				if( each_info[0]==cf.sh_name.value )
				{
					if( cf.duplicated_num.value == 0 )
					{
						if( confirm("$reservation_dup") )
						{
							cf.duplicated_num.value=1;
							cf.duplicated_shname.value=i.toString();
						}
						else
							return false;	
					}
					else
					{
						cf.duplicated_num.value++;
						cf.duplicated_shname.value=cf.duplicated_shname.value+" "+i.toString();	
					}
				}
			}
		}
		else
		{
			if( each_info[0]==cf.sh_name.value )
			{
				if( cf.duplicated_num.value == 0 )
				{
						if( confirm("$reservation_dup") )
					{
							cf.duplicated_num.value=1;
								cf.duplicated_shname.value=i.toString();
					}
					else
							return false;
				}
				else
				{
						cf.duplicated_num.value++;
						cf.duplicated_shname.value=cf.duplicated_shname.value+" "+i.toString();
				}
			}	
		}
	}
	
	//form.submit();
	return true;
}

function hdd_user_editnum(cf)
{
	//alert(array_num);
	if (array_num == 0)
	{
		alert("$port_edit");
		return false;
	}
	var count_select=0;
	var select_num;
	if( array_num == 1)
	{
		if(cf.name_Select[1].checked == true)
		{
			//alert("only one item");
			count_select++;
			select_num=1;
		}
	}
	else for(i=1;i<=array_num;i++)
		if(cf.name_Select[i].checked == true)
		{
			//alert("more then one item");
			count_select++;
			select_num=i;
		}
	if(count_select==0)
	{
		alert("$port_edit");
		return false;
	}
	else
	{
		//alert("direct edit page");
		cf.select_edit.value=select_num;
		cf.submit_flag.value="shname_editnum";
		cf.action="/apply.cgi?/hdd_edit_user.htm timestamp="+ts;
		return true;
	}	
}

function hdd_usr_del(cf)
{
	if(array_num == 0)
	{
		alert("$port_del");
		return false;
	}
	var count_select=0;
	var select_num;
	if( array_num == 1)
	{
		if(cf.name_Select[1].checked == true)
		{
			count_select++;
			select_num=1;
		}
	}
	else for(i=1;i<=array_num;i++)
		if(cf.name_Select[i].checked == true)
		{
			count_select++;
			select_num=i;
		}
	if(count_select==0)
	{
		alert("$port_del");
		return false;
	}
	else
	{
		//alert("delete item");
		cf.select_del.value=select_num;
		cf.submit_flag.value="shname_del";
		return true;
	}	
}