function check_all_read()
{
/*when click read all-no password, run this function.first to see if write all-no password checked.checked, then read all-no password must be checked and all the other items must not checked.write all-no password unchecked, then to see if read all-no password checked,if chenked,then all the other read items must be not checked.if unchecked, then to see if write items checked(all but all-no password),if checked, then according item must be checked.after the above step, to sum how many items are checked,if no items, then default read admin item checked and abled.*/
	var form = document.forms[0];
	var check_nub = 0;

	var objs = document.getElementsByName("readAccess_n");
	var objs_w = document.getElementsByName("writeAccess_n");
	var r_flag = 0;
	var w_flag  =0; //
	
	for(i =0; i < array_num; i++) // write users is checked or not
			if(objs_w[i].checked == true)
				w_flag = 1;
	for(i =0; i < array_num; i++) // read users is checked or not
			if(objs[i].checked == true)
				r_flag = 1;

	if(form.writeAccess_all.checked == true)
	{
		form.readAccess_all.checked = true;
		form.readAccess_ad.checked = false;
		form.readAccess_ad.disabled = false;
		
		for(i =0; i < array_num; i++)
			objs[i].checked = false;
	}
	else
	{
		if( form.readAccess_all.checked == true)
		{
			form.readAccess_ad.checked = false;
			form.readAccess_ad.disabled = false;
			
			for(i =0; i < array_num; i++)
				objs[i].checked = false;
		}
		else
		{
			for(i =0; i< array_num ; i++)
			{
				if( objs_w[i].checked == true )
				{
						objs[i].checked = true;
						form.readAccess_ad.checked = true;
						form.readAccess_ad.disabled = true;
				}
			}
			
			for(i =0; i < array_num; i++)
			{
				if( objs[i].checked == true )
					check_nub++;
			}
			
			if(check_nub == 0)
			{
				form.readAccess_all.checked = true;
				form.readAccess_ad.disabled = false;
			}
		}
	}
	
			/*if( form.readAccess_all.checked == true)
			{
				form.readAccess_ad.checked = false;
				form.readAccess_ad.disabled = false;
				
				for(i =0; i < array_num; i++)
					objs[i].checked = false;
			}
			else{
					for(i =0; i < array_num; i++)
					{
						if( objs[i].checked == true )
							check_nub++;
					}
					
					if(form.readAccess_ad.checked == false && check_nub ==0)
						form.readAccess_all.checked = true;
				}*/
}

function check_other_read()
{
/*when click read other items but all-no password, run this function.first to see if write all-no password checked.checked, then read all-no password must be checked and all the other items must not checked.write all-no password unchecked, then to see if write items checked(all but all-no password),if checked, then according item must be checked.after the above step, to sum how many items are checked,if have items checked,then read all-no password must unchecked, and read access admin must checked and disabled.if no items, to see read admin, checked ,then read all-no password not checked,if unchecked,then all-no passowrd checked. */
	var form = document.forms[0];
	var check_nub = 0;
	var objs = document.getElementsByName("readAccess_n");
	var objs_w = document.getElementsByName("writeAccess_n");
	
		for(i =0; i < array_num; i++)
	{
		if( objs[i].checked == true )
			check_nub++;
	}
	
	if(form.readAccess_ad.checked == true || check_nub != 0)
	{
		form.writeAccess_all.checked = false;
		form.writeAccess_ad.checked = true;
		
		for(i =0; i < array_num; i++)
			if( objs[i].checked == true )
				objs_w[i].checked = true;
		
		if( check_nub != 0 )
			form.writeAccess_ad.disabled = true;
	}
	
	if(form.writeAccess_all.checked == true)
	{
		form.readAccess_all.checked = true;
		form.readAccess_ad.checked = false;
		form.readAccess_ad.disabled = false;
		
		for(i =0; i < array_num; i++)
			objs[i].checked = false;
	}
	else
	{
		/*for(i =0; i< array_num ; i++)
		{
			if( objs_w[i].checked == true )
			{
					objs[i].checked = true;
					form.readAccess_ad.checked = true;
					form.readAccess_ad.disabled = true;
			}
		}
		
		for(i =0; i < array_num; i++)
		{
			if( objs[i].checked == true )
				check_nub++;
		}*/
		
		for(i =0; i< array_num ; i++)
		{
			if( objs[i].checked == true )
			{
					objs_w[i].checked = true;
					form.readAccess_ad.checked = true;
					//form.readAccess_ad.disabled = true;
			}
			else
				objs_w[i].checked = false;
		} 
		
		if(check_nub != 0)
		{
			form.readAccess_all.checked = false;
			form.readAccess_ad.checked = true;
			form.readAccess_ad.disabled = true;
		}
		else
		{
			form.writeAccess_ad.disabled = false;
			form.readAccess_ad.disabled = false;
			if(form.readAccess_ad.checked == false)
				form.readAccess_all.checked = true;
			else
			{
				form.readAccess_all.checked = false;
			}
		}
	}
	
	/*for(i =0; i < array_num; i++)
	{
		if( objs[i].checked == true )
		{
			objs_w[i].checked = true;
			check_nub++;
		}
	}
	
	if(check_nub != 0)
	{
		form.readAccess_all.checked = false;
		form.readAccess_ad.checked = true;
		form.readAccess_ad.disabled = true;
	}
	else
	{
		form.readAccess_ad.disabled = false;
		if(form.readAccess_ad.checked == false)
			form.readAccess_all.checked = true;
		else
		{
			form.readAccess_all.checked = false;
			form.writeAccess_ad.checked = true;
		}
	}*/
}

function check_all_write()
{
/*when click write all-no password, run this function.if all-no password checked, then read all-no password must be checked and the other items about read access must not checked,and read access admin must be abled*/
	var form = document.forms[0];
	var check_nub = 0;
	var objs = document.getElementsByName("readAccess_n");
	var objs_w = document.getElementsByName("writeAccess_n");
	var r_flag = 0;
	var w_flag  =0; //
	
	for(i =0; i < array_num; i++) // write users is checked or not
			if(objs_w[i].checked == true)
				w_flag = 1;
	for(i =0; i < array_num; i++) // read users is checked or not
			if(objs[i].checked == true)
				r_flag = 1;

	if( form.writeAccess_all.checked == true)
	{		
		form.writeAccess_ad.checked = false;
		form.writeAccess_ad.disabled = false;
		
		for(i =0; i < array_num; i++)
		{
			objs_w[i].checked = false;
			objs[i].checked = false;
		}
		
		form.readAccess_all.checked = true;
		form.readAccess_ad.checked = false;
		form.readAccess_ad.disabled = false;
	}
	else
	{
		if(form.writeAccess_ad.checked == false && w_flag ==0)
			form.writeAccess_all.checked = true;
	}
}

function check_other_write()
{
/*when click write access item but write all-no password, run this function.if user item checked,then check read access all-no password is checked or not,checked,do nothing, not checked,then the according read access item must be checked and the read access admin item must be checked abd disabled.if no user item checked,see if write admin item checked, checked, then make write all-no password unchecked, if unchecked, then make write all-no password checked*/
	var form = document.forms[0];
	var check_nub = 0;
	var read_num = 0;
	var objs = document.getElementsByName("readAccess_n");
	var objs_w = document.getElementsByName("writeAccess_n");
	
	for(i =0; i < array_num; i++)
	{
		if( objs_w[i].checked == true )
		{
			if(form.readAccess_all.checked == false)
			{
				objs[i].checked = true;
				form.readAccess_ad.checked = true;
				form.readAccess_ad.disabled = true;
			}
			check_nub++;
		}
		/*else //as jake's request, when the write uncheck, the read hoes't have to uncheck.
			objs[i].checked = false;*/
	}
	
	for(i =0; i < array_num; i++)
			if( objs[i].checked == true )
				read_num++;
				
	if( read_num == 0 )
			form.readAccess_ad.disabled = false;
	
	if(check_nub != 0)
	{
		form.writeAccess_all.checked = false;
		form.writeAccess_ad.checked = true;
		form.writeAccess_ad.disabled = true;
	}
	else
	{
		form.writeAccess_ad.disabled = false;
		if(form.writeAccess_ad.checked == false)
		{
			form.writeAccess_all.checked = true;
			form.readAccess_all.checked = true;
			form.readAccess_ad.checked = false;
			form.readAccess_ad.disabled = false;
			for(i =0; i < array_num; i++)
				objs[i].checked = false;
		}
		else
			form.writeAccess_all.checked = false;
	}
}

function check_value()
{
/* when apply USB_Folder_edit.htm and USB_Folder_creat.htm,invoke this function to chenk the users value, 0 not exist, 1 exist, 2 read auth, 3 read and write auth.*/

    var form = document.forms[0];
    var objs = document.getElementsByName("readAccess_n");
	var objs_w = document.getElementsByName("writeAccess_n");
	if(form.writeAccess_all.checked == true)
	{
		//form.hid_readAccess_all.value = 1;
		//form.hid_readAccess_ad.value = 0;
		  form.hid_read_a.value = 0;
		//form.hid_writeAccess_all.value = 1;
		//form.hid_writeAccess_ad.value = 0;
		  form.hid_write_a.value = 0;
		
		for(i = 0; i < objs_w.length ; i++)
		{
			var user_num = "hid_user"+i;
			document.getElementById(user_num).value = 3;
		}
		/* form.hid_user0.value = 3;
		 form.hid_user1.value = 3;
		 form.hid_user2.value = 3;
		 form.hid_user3.value = 3;*/
	}
	else
	{
		form.hid_write_a.value = 1;

		for(i = 0; i < objs_w.length ; i++)
		{
			var user_num = "hid_user"+i;
			//alert( user_num);
			if( objs_w[i].checked == true )
			{
				
				document.getElementById(user_num).value = 3; //3 r&w, 2 r, 1,exist. 0 not exist 
				//form.hid_useri.value = 3;
				//if( form.hid_writeAccess.value == 0 )
					//form.hid_writeAccess.value = objs_w[i].value;
				//else
				//form.hid_writeAccess.value = form.hid_writeAccess.value + " " + objs_w[i].value;
			}
			else if( objs[i].checked == true || form.readAccess_all.checked == true)
				document.getElementById(user_num).value = 2;
				//form.hid_writeAccess.value = form.hid_writeAccess.value + " " + 0;
			else
			{
				document.getElementById(user_num).value = 1;
			//	alert( user_num);
			}
		}
		
		if(form.readAccess_all.checked == true)
		{
			/*form.hid_readAccess_all.value = 1;
			form.hid_readAccess_ad.value = 0;
			form.hid_readAccess.value = 0;*/
			form.hid_read_a.value = 0;
		}
		else
		{
			form.hid_read_a.value = 1;
			/*form.hid_readAccess_all.value = 0;
			if(form.readAccess_ad.checked == true)
				form.hid_readAccess_ad.value = 1;
			else
				form.hid_readAccess_ad.value = 0;
				for(i = 0; i < objs.length ; i++)
			{	
				if( objs[i].checked == true )
				{
					//if( form.hid_readAccess.value == 0 )
						//form.hid_readAccess.value = objs[i].value;
					//else
						form.hid_readAccess.value = form.hid_readAccess.value + " " + objs[i].value;
				}
				else
					form.hid_readAccess.value = form.hid_readAccess.value + " " + 0;
			}*/
		}
	}

}