script "inv_tweaks";
notify yoioy;

void smash(int qty, item i) {
	//print("");
	//print("smashing a " + i);
	visit_url("craft.php?action=pulverize&mode=smith&smashitem=" + to_int(i) + "&qty=" + qty + "&pwd=" + my_hash());
}
void mail_list_helper(string rec, item[int] list) {

	string url = "sendmessage.php?action=send";
	url += "&towho=" + rec;
	url += "&contact=0";
	url += "&message=";
	
	foreach i, it in list
		url += "&howmany" + (i+1) + "=" + item_amount(it) + "&whichitem" + (i+1) + "=" + to_int(it);
		
	url += "&sendmeat=0";
	url += "&pwd=" + my_hash();
	visit_url(url, true);
}
void mail_list(string rec, item[int] list) {
	item[int] t_list = {};
	int tru_i = 0;
	for(int i = 0; i < list.count(); i++) {
		if(list[i].item_amount() != 0) {
			t_list[tru_i++ % 11] = list[i];
			if(t_list.count() == 11) {
				mail_list_helper(rec, t_list);
				t_list = {};
			}
		}
	}
	if(t_list.count() != 0)
		mail_list_helper(rec, t_list);
}
void run_all_lists() {
	//print("ok bub");
	string[int] t = {};
	file_to_map("inv_tweaks/sell_list.txt", t);
	foreach i,id in t
		autosell(item_amount(to_item(to_int(id))), to_item(to_int(id)));
		
	t = {};
	file_to_map("inv_tweaks/sellbot_list.txt", t);
	item[int] t_it_list = {};
	int i = 0;
	foreach i,id in t
		t_it_list[i++] = to_item(to_int(id));
	if(t_it_list.count() > 0)
		mail_list("sellbot", t_it_list);
		
	t = {};
	file_to_map("inv_tweaks/smash_list.txt", t);
	foreach i,id in t
		smash(item_amount(to_item(to_int(id))), to_item(to_int(id)));
	
	t = {};
	file_to_map("inv_tweaks/smashbot_list.txt", t);
	t_it_list = {};
	i = 0;
	foreach i,id in t
		t_it_list[i++] = to_item(to_int(id));
	if(t_it_list.count() > 0)
		mail_list("smashbot", t_it_list);
	
	t = {};
	file_to_map("inv_tweaks/use_list.txt", t);
	foreach i,id in t
		use(item_amount(to_item(to_int(id))), to_item(to_int(id)));
	
	t = {};
	file_to_map("inv_tweaks/display_list.txt", t);
	foreach i,id in t
		put_display(item_amount(to_item(to_int(id))), to_item(to_int(id)));
	
	t = {};
	file_to_map("inv_tweaks/closet_list.txt", t);
	foreach i,id in t
		put_closet(item_amount(to_item(to_int(id))), to_item(to_int(id)));
	
	t = {};
	file_to_map("inv_tweaks/mall_list.txt", t);
	foreach i,id in t
		put_shop(0, 0, to_item(to_int(id)));
}
void main() {	
	string[int] opts = {"sell","sellbot","smash","smashbot","use","display","closet","mall"};
	string[string] fields = form_fields();
	if(!(fields contains "which")) {
		visit_url().write();
		return;
	}
	string ele_color = "rgba(0,255,0,.4)";
	string sel_color = "rgba(0,0,255,255)";
	string url_base = "inventory.php?which=" + fields["which"];
	remove fields["which"];
	

	if(fields contains "opt") {
		int opt = to_int(fields["opt"]);
		
		if(opt == 8) {
			run_all_lists();
		}
		else {
			boolean imm = to_boolean(fields["imm"]);
			boolean list = to_boolean(fields["list"]);
			set_property("inv_tweaks_imm", imm);
			set_property("inv_tweaks_list", list);
			remove fields["opt"];
			remove fields["imm"];
			remove fields["list"];
			
			item[int] it_list;
			int i = 0;
			foreach k,v in fields 
				it_list[i++] = to_item(to_int(v));
				
			if(imm) {
				switch(opt) {
					case 0:
						foreach i, it in it_list
							autosell(item_amount(it), it);
						break;
					case 1:
						mail_list("sellbot", it_list);
						break;
					case 2:
						foreach i, it in it_list
							smash(item_amount(it), it);
						break;
					case 3:
						mail_list("smashbot", it_list);
						break;
					case 4:
						foreach i, it in it_list
							use(item_amount(it), it);
						break;
					case 5:
						foreach i, it in it_list
							put_display(item_amount(it), it);
						break;
					case 6:
						foreach i, it in it_list
							put_closet(item_amount(it), it);
						break;
					case 7:
						foreach i, it in it_list
							put_shop(0, 0, it);
						break;
				}
			}
			if(list) {
				string[int] t;
				file_to_map("inv_tweaks/" + opts[opt] + "_list.txt", t);
				int[int] t_int;
				foreach i,s in t
					t_int[i] = to_int(s);
				foreach i,it in it_list
					if(!(t_int contains to_int(it)))
						t_int[t_int.count()] = to_int(it);
				t_int.map_to_file("inv_tweaks/" + opts[opt] + "_list.txt");
			}
		}
	}
	
	string def_imm = (get_property("inv_tweaks_imm")=="true")?"checked":"";
	string def_list = (get_property("inv_tweaks_list")=="true")?"checked":"";
	
	string inv_tweaks_ctrl_panel = "<style>*{-webkit-user-select:none;-ms-user-select:none;user-select:none;}a.active{color:black;}a.inv_disabled{color:grey;pointer-events:none;}</style><table id=\"inv_tweaks_control_panel\"><tr><td align=\"right\"><labelfor=\"imm_box\" style=\"font-size:8px\">imm</label><input type=\"checkbox\" id=\"imm_box\" %1$ /><br><label for=\"list_box\" style=\"font-size:8px\">list</label><input type=\"checkbox\" id=\"list_box\" %2$ /></td><td><font size=2><a href=# class=\"inv_disabled\" onclick=\"dispatch(0)\">[sell</a><a href=# class=\"inv_disabled\" onclick=\"dispatch(1)\">(bot)]</a><a href=# class=\"inv_disabled\" onclick=\"dispatch(2)\">[smash</a><a href=# class=\"inv_disabled\" onclick=\"dispatch(3)\">(bot)]</a><a href=# class=\"inv_disabled\" onclick=\"dispatch(4)\">[use]</a><a href=# class=\"inv_disabled\" onclick=\"dispatch(5)\">[display]</a><a href=# class=\"inv_disabled\" onclick=\"dispatch(6)\">[closet]</a><a href=# class=\"inv_disabled\" onclick=\"dispatch(7)\">[mall]</a></font></td></tr><tr><td></td><td style=\"text-align: center;\"><a href=# onclick=\"dispatch(8)\">[run all lists]</a></td></tr></table>".replace_string("%1$", def_imm).replace_string("%2$", def_list);
	
	string inv_tweaks_code = "<script>window.addEventListener(\"mousedown\",dn);window.addEventListener(\"mouseup\",up);window.addEventListener(\"mousemove\",mv);window.addEventListener(\"keyup\",((e)=>{if(e.key==\"Control\")k_a=false;}));window.addEventListener(\"keydown\",((e)=>{if(e.key==\"Control\")k_a=true;}));window.addEventListener(\"resize\",init_c);var c=document.createElement(\"canvas\");var i_x,i_y;var m_a=false;var c_a=false;var k_a=false;var es=[];init_c();function init_c(){c.height=window.innerHeight;c.width=window.innerWidth;c.style=\"position:fixed;top:0px;left:0px;z-index:1;border:1pxsolid#000000;\";ctx=c.getContext(\"2d\");ctx.strokeStyle=\"%1$s\";ctx.lineWidth=3;ctx.clearRect(0,0,c.width,c.height);}function dn(e){if(e.buttons%2!=1)return;if(in_e(document.body.getElementsByTagName(\"table\")[0],e.x,e.y,0,0))return;if(k_a){tog_e(e.x,e.y);return;}clear_es();m_a=true;i_x=e.x;i_y=e.y;dis_pan();}function up(e){m_a=false;c_a=false;c.remove();if(es.length>0)en_pan();}function mv(e){if(!m_a)return;if(!c_a)document.body.appendChild(c);c_s=true;ctx.clearRect(0,0,c.width,c.height);ctx.strokeRect(i_x,i_y,e.x-i_x,e.y-i_y);set_es(Math.min(e.x,i_x),Math.min(e.y,i_y),Math.abs(e.x-i_x),Math.abs(e.y-i_y));}function r_i(x1,y1,w1,h1,x2,y2,w2,h2){return (y1<=y2+h2&&y2<=y1+h1&&x1<=x2+w2&&x2<=x1+w1);}function set_es(x,y,w,h){clear_es();Array.from(document.body.getElementsByClassName(\"i\")).forEach((e)=>{if(in_e(e,x,y,w,h)){es.push(e);e.style=\"background:%2$s\";}});}function in_e(e,x,y,w,h){const r=e.getBoundingClientRect();return r_i(x,y,w,h,r.x,r.y,r.width,r.height);}function tog_e(x,y){for(var i=0;i<es.length;i++)if(in_e(es[i],x,y,0,0)){es[i].style=\"background:#ffffff\";es.splice(i,1);if(es.length<1)dis_pan();return;}Array.from(document.body.getElementsByClassName(\"i\")).some((e)=>{if(in_e(e,x,y,0,0)){es.push(e);e.style=\"background:%2$s\";return true;}});}function clear_es(){es.forEach((e)=>{e.style=\"background:#ffffff\"});es=[];}function dispatch(opt){var ids=[];es.forEach((e)=>{ids.push(/i([0-9]+)/.exec(e.getElementsByTagName(\"table\")[0].getElementsByTagName(\"tbody\")[0].getElementsByTagName(\"tr\")[0].getElementsByTagName(\"td\")[1].id)[1]);});var url=\"%3$s\";url+=\"&opt=\"+opt;if(!(opt==8)){url+=\"&imm=\"+document.getElementById(\"imm_box\").checked;url+=\"&list=\"+document.getElementById(\"list_box\").checked;for(var i=0;i<ids.length;i++)url+=\"&id\"+i+\"=\"+ids[i];}window.location.replace(url);}function en_pan(){Array.from(document.getElementsByClassName(\"inv_disabled\")).forEach((e)=>{e.classList.remove(\"inv_disabled\");e.classList.add(\"inv_enabled\");});}function dis_pan(){Array.from(document.getElementsByClassName(\"inv_enabled\")).forEach((e)=>{e.classList.remove(\"inv_enabled\");e.classList.add(\"inv_disabled\");});}</script>".replace_string("%1$s",sel_color).replace_string("%2$s",ele_color).replace_string("%3$s",url_base);
	
	
	string split_str = "sell&nbsp;stuff</a>]<br /></font>";
	string base_res = visit_url(url_base);
	
	string[int] parts = base_res.split_string(split_str);
	if(parts.count() != 2) {
		print("inv structure has changed", "red");
		base_res.write();
		return;
	}
	write(parts[0] + split_str + inv_tweaks_ctrl_panel + parts[1] + inv_tweaks_code);
}


