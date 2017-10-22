tmr.alarm(0, 1000, 1, function()
   if wifi.sta.getip() == nil then
      print("Connecting to AP...\n")
   else
      ip, nm, gw=wifi.sta.getip()
      print("IP Info: \nIP Address: ",ip)
      print("Netmask: ",nm)
      print("Gateway Addr: ",gw,'\n')
      tmr.stop(0)
   end
end)



srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
		
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
		buf = buf.."HTTP/1.1 200 OK\n\n";
		buf = buf.."<!DOCTYPE HTML>";
		buf = buf.."<html>";
        buf = buf.."<p> <a href=\"?txval=0\"><button>ResetBot</button></a></p>";
		buf = buf.."<p> <a href=\"?txval=N\"><button>Speed=NORMAL</button></a> <a href=\"?txval=S\"><button>Speed=SLOW</button></a></p>";
		buf = buf.."<p> <a href=\"?txval=9\"><button>Turn_ON_Blinkers</button></a> <a href=\"?txval=0\"><button>Turn_OFF_Blinkers</button></a></p>";
		--buf = buf.."<p> <a href=\"?txval=1\"><button>ON_L_Blinker</button></a> <a href=\"?txval=3\"><button>OFF_L_Blinker</button></a></p>";
		--buf = buf.."<p> <a href=\"?txval=2\"><button>ON_R_Blinker</button></a> <a href=\"?txval=4\"><button>OFF_R_Blinker</button></a></p>";		
		buf = buf.."<p> <a href=\"?txval=5\"><button>Motor_L0R0</button></a> <a href=\"?txval=8\"><button>Motor_L1R1</button></a></p>";
		buf = buf.."<p> <a href=\"?txval=6\"><button>Motor_L0R1</button></a> <a href=\"?txval=7\"><button>Motor_L1R0</button></a></p>";
		buf = buf.."</html>";
	    local _on,_off = "",""
		if(_GET.txval == "0")then
			uart.write( 0, "0")
		elseif(_GET.txval == "1")then
			uart.write( 0, "1")
		elseif(_GET.txval == "2")then
			uart.write( 0, "2")
		elseif(_GET.txval == "3")then
			uart.write( 0, "3")
		elseif(_GET.txval == "4")then
			uart.write( 0, "4")
		elseif(_GET.txval == "5")then
			uart.write( 0, "5")
		elseif(_GET.txval == "6")then
			uart.write( 0, "6")
			tmr.delay(10000)
			tmr.delay(10000)
			tmr.delay(10000)			
			tmr.delay(10000)
			tmr.delay(10000)
			tmr.delay(10000)
			uart.write( 0, "8")
		elseif(_GET.txval == "7")then
			uart.write( 0, "7")
			tmr.delay(10000)
			tmr.delay(10000)
			tmr.delay(10000)
			tmr.delay(10000)
			tmr.delay(10000)
			tmr.delay(10000)
			uart.write( 0, "8")
		elseif(_GET.txval == "8")then
			uart.write( 0, "8")
		elseif(_GET.txval == "N")then
			uart.write( 0, "N")
		elseif(_GET.txval == "S")then
			uart.write( 0, "S")
		elseif(_GET.txval == "9")then
			uart.write( 0, "1")
			uart.write( 0, "2")
		elseif(_GET.txval == "L")then
			uart.write( 0, "7")
		elseif(_GET.txval == "R")then
			uart.write( 0, "6")
		end
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
