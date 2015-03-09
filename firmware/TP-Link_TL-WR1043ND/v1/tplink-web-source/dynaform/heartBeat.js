function request(url)
{
	var xhr = window.ActiveXObject?new ActiveXObject("Microsoft.XMLHTTP"):new XMLHttpRequest();	
	var setTime, isAsynTimeout = false, asynTimeout = 2000;
	var onreadStateChanged = function ()
	{
		if (isAsynTimeout == false)
		{
			/* 数据接收完毕,并且状态正确。 */
			if ((xhr.readyState == 4) && (xhr.status >=200 || xhr.status <300 || xhr == 304))		
			{
				clearTimeout(setTime);
			}
		}
	};
	
	var timeoutHandler = function ()
	{
		isAsynTimeout = true;
		clearTimeout(ret);
		heartBeat();
	}
	
	xhr.onreadystatechange = function (){
		if (xhr.readyState == 4)
		{
			onreadStateChanged();
		}
	};
	xhr.open("GET", url, true);
	
	try
	{
		if (navigator.userAgent.indexOf("MSIE") > 0)
		{
			xhr.setRequestHeader("If-Modified-Since","0");
		}
		xhr.send("");
		
	}catch(ex){}

	setTime = setTimeout(timeoutHandler, asynTimeout);
}
var heartBeatTime = 10*1000;
var ret;
function heartBeat()
{
	request("../userRpm/heartBeat.htm?heartBeat=1&cmp="+fileParaFS[0]+"&session="+fileParaFS[1]);
	ret = window.setTimeout(arguments.callee, heartBeatTime);
}
window.onload = function(){
	heartBeat();
};