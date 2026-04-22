-- Manual: http://unanimated.hostfree.pw/ts/scripts-manuals.htm#hydra

script_name="HYDRA汉化版"
script_description="A multi-headed typesetting beast. Scary as Hell./自用汉化版"
script_author="unanimated"
script_url1="http://unanimated.hostfree.pw/ts/hydra.lua"
script_url2="https://raw.githubusercontent.com/unanimated/luaegisub/master/hydra.lua"
script_version="6.1"
script_namespace="ua.HYDRA"

re=require'aegisub.re'
clipboard=require'aegisub.clipboard'

order="\\r\\fad\\fade\\an\\q\\blur\\be\\bord\\xbord\\ybord\\shad\\xshad\\yshad\\fn\\fs\\fsp\\fscx\\fscy\\frx\\fry\\frz\\fax\\fay\\c\\2c\\3c\\4c\\alpha\\1a\\2a\\3a\\4a\\pos\\move\\org\\clip\\iclip\\b\\i\\u\\s\\p"
noneg2="|bord|shad|xbord|ybord|fs|blur|be|fscx|fscy|"

--	HYDRA HEAD 9	--
function hh9(subs,sel)
	-- get colours + tags from input
	getcolours()
	if res.italix or res.bolt or res.under or res.strike then styleget(subs) end
	local shft=res.int or 0
	tags=""
	tags=gettags(tags)
	transform=tags
	ortags=tags
	ortrans=transform
	retags=tags:gsub("\\","\\\\")
	z0=-1
	
	-- tag position
	pl1,pl2,pl3=nil,nil,nil
	place=res.linetext or ""
	if place=="*" then t_error("标签位置不能仅有 \"*\".",1) end
	if place:match("*") then pl1,pl2,pl3=place:match("(.*)(%*)(.*)") pla=1 else pla=0 end
	if res.tagpres~="--- presets ---" and res.tagpres~=nil then pla=1 end

    for z,i in ipairs(sel) do
	progress("正在处理行: "..z.."/"..#sel)
	prog=math.floor((z+0.5)/#sel*100)	aegisub.progress.set(prog)
	line=subs[i]
	text=line.text
	visible=nobrea(text)
	linecheck()
	
	if not text:match("^{\\") then text="{\\HYDRA}"..text end
	if visible:match("*") and res.tagpres=="--- presets ---" then pla=0 end
	
    -- transforms
    if trans==1 and GO then z0=z0+1
	tin=res.trin or 0
	tout=res.trout or 0
	if res.tend then
	tin=line.end_time-line.start_time-res.trin
	tout=line.end_time-line.start_time-res.trout
	end
	
	if tmode==1 then
	    if res.int~=0 then TF=shft*z0 else TF=0 end
	    tnorm="\\t("..tin+TF..","..tout+TF..","..res.accel..",\\alltagsgohere)}"
	    if place:match("*") and pla==1 then
		initags=text:match("^{\\[^}]-}") or ""
		orig=text
		replace=place:gsub("%*","{"..tnorm)
		v1=nobra(text)
		v2=nobra(replace)
		if v1==v2 then text=initags..textmod(orig,replace) end
	    else
		text=text:gsub("^({\\[^}]*)}","%1"..tnorm)
	    end
	end
	if tmode==2 then text=text:gsub("^(.-\\t%b())",function(t) return t:gsub("%)$","\\alltagsgohere)") end) end
	if tmode==3 then text=text:gsub("(\\t%b())",function(t) return t:gsub("%)$","\\alltagsgohere)") end) end
	if tmode==4 then
	  if res.int~=0 then
    	    tagtab={}
	    for tt in text:gmatch(".-{\\[^}]*}") do table.insert(tagtab,tt) end
	    END=text:match("^.*{\\[^}]*}(.-)$")
	    for t=1,#tagtab do sf=t-1
	      tagtab[t]=tagtab[t]:gsub("({\\[^}]*)}","%1\\t("..tin+shft*sf..","..tout+shft*sf..","..res.accel..",\\alltagsgohere)}")
	    end
	    nt=END
	    for a=#tagtab,1,-1 do nt=tagtab[a]..nt end
	    text=nt
	  else text=text:gsub("({\\[^}]*)}","%1\\t("..tin..","..tout..","..res.accel..",\\alltagsgohere)}")
	  end
	end
	
	if res.add and res.add~=0 then transform=addbyline(transform,ortrans) end
	
	if tmode<4 and res.relative then
	    stags=text:match(STAG) or ""
	    for tag,val in transform:gmatch("(\\%a+)([%d%.%-]+)") do
		if stags:match(tag) then oldval=stags:match(tag.."([%d%.%-]+)")
		    transform=transform:gsub(tag..esc(val),tag..oldval+val)
		end
	    end
	end
	text=text:gsub("\\alltagsgohere",transform)
	if tmode==4 and res.relative then
	    text=text:gsub(ATAG,function(tg)
	      for tag,val in transform:gmatch("(\\%a+)([%d%.%-]+)") do
		if tg:match(tag) then oldval=tg:match(tag.."([%d%.%-]+)")
		    transform2=transform:gsub(tag..esc(val),tag..oldval+val)
		    tg=tg:gsub("(.*\\t.-)"..transform,"%1"..transform2)
		end
	      end
	    return tg end)
	end
	text=text:gsub("\\t%(0,0,1,","\\t(")
	:gsub("\\t(%b())",function(tr) return "\\t"..duplikill(tr) end)
	:gsub(ATAG,function(tg) return cleantr(tg) end)
	
    -- non transform, ie. the regular stuff
    elseif GO then z0=z0+1
	-- temporarily block transforms
	text=text:gsub(ATAG,function(tg) return duplikill(tg) end)
	:gsub("\\t(%b())",function(t) return "\\tra"..t:gsub("\\","/") end)
	
	if res.add and res.add~=0 then tags=addbyline(tags,ortags) end
	
	if pla==1 and z==1 then
		if res.strike then tags=tags.."\\s1" end
		if res.under then tags=tags.."\\u1" end
		if res.bolt then tags=tags.."\\b1" end
		if res.italix then tags=tags.."\\i1" end
	end
	if tags~="" then
	  drawing=text:match("\\p1")
	  if drawing then fail("某些行包含绘图。") end
	  if visible=="" then fail("没有可见文本。") end
	  if pla==1 and not drawing and visible~="" then
		initags=text:match(STAG) or ""
		text=text:gsub("(\\[Nh])","{%1}")
		orig=text
		v1=nobra(orig)
		-- BEFORE LAST CHARACTER
		if res.tagpres=="before last char." then
			com_dump=''
			repeat
				end_com=text:match("(%b{})$")
				if end_com then
					com_dump=end_com..com_dump
					text=text:gsub("%b{}$","")
				else break end
			until not end_com
			text=re.sub(text,"(.)$","{§}\\1")
			text=text:gsub("{§}",wrap(tags))..com_dump
		-- SOMEWHERE IN THE MIDDLE
		elseif res.tagpres=="in the middle" or res.tagpres:match("of text") then
			clean=nobrea1(text)
			char=re.find(clean,'.')
			lngth=math.floor(#char*fak)
			text="{·}"..text
			text=text:gsub("{·}({\\[^}]-})","%1{·}")
			m=0
			if lngth>0 then
			  repeat text=text:gsub("{·}(%b{})","%1{·}") text=re.sub(text,"{·}([^{])","\\1{·}") m=m+1 until m==lngth
			end
			text=text:gsub("{(·)}",wrap(tags)) :gsub("({"..esc(tags).."})(%b{})","%2%1")
		-- PATTERN
		elseif res.tagpres=="custom pattern" then
			if place=="" then t_error("自定义模式预设: 未在标签位置输入文本。",1) end
			if not pl1 then t_error("标签位置缺少星号。 ("..place..")",1) end
			pl1=esc(pl1)	pl3=esc(pl3)
			text=nobrea(text):gsub(pl1..pl3,pl1.."{"..tags.."}"..pl3)
			text=initags..retextmod(orig,text)
			if text==orig then fail("未找到模式 '"..place.."'。") end
		-- SECTION
		elseif res.tagpres=="section" then
			if place=="" then t_error("分段预设: 未在标签位置输入文本。",1) end
			tgs2=""
			for tg in tags:gmatch("\\%d?%a+") do
			  txt1=text:match("^%b{}.-"..esc(place)) or text:match("^.-"..esc(place)) or ""
			  local tg2=txt1:match("^.*("..tg.."[^\\}]+).-$") or tg
			  if tg=='\\fs' then tg2=txt1:match("^.*(\\fs%d+).-$") or tg end
			  tg2=tg2:gsub("(\\[ibus])%d","%10")
			  tgs2=tgs2..tg2
			end
			text=nobrea(text):gsub("^(.-)("..esc(place).."%s*)(.*)$","%1{"..tags.."}%2{"..tgs2.."}%3")
			text=initags..retextmod(orig,text)
			if text==orig then fail("未找到模式 '"..place.."'。") end
		-- CHARACTER
		elseif res.tagpres=="every char." then
			replace=re.sub(nobra(text),"(.)","{"..retags.."}\\1")
			v2=nobra(replace)
			if visible=="" then fail("没有可见文本。")
			elseif v1==v2 then text=initags..retextmod(orig,replace) end
			text=text:gsub("({\\HYDRA})%1","%1")
		-- WORD
		elseif res.tagpres=="every word" then
			replace=nobra(text):gsub("%S+","{"..tags.."}%1"):gsub("(%b{})\\N","\\N%1")
			v2=nobra(replace)
			if v1==v2 then text=initags..retextmod(orig,replace) end
			text=text:gsub("({\\HYDRA})%1","%1")
		-- TEXT POSITION
		elseif res.tagpres=="text position" then
			v2=nobra(text)
			pmax=re.find(v2,".") or {}
			krktrz=#pmax
			pos=tonumber(place:match("^%-?%d+")) or 0
			addpos=tonumber(place:match(".([%+%-]%d+)")) or 0
			if pos<0 then pos=krktrz+pos end
			split=pos+addpos*z0
			if split<0 then split=0 end
			if split<krktrz then
				be4=re.sub(v2,"^(.{"..split.."}).*","\\1")
				aft=re.sub(v2,"^.{"..split.."}","")
				text=be4..wrap(tags)..aft
				if v1==v2 then text=initags..retextmod(orig,text) end
			end
			if text==orig then fail("该行的可见字符少于 "..place.." 个。") end
		-- REPLACE BELL
		elseif res.tagpres=="replace {•}" then
			repeat text,r=text:gsub("{•}({[^}]*})","%1{•}") until r==0
			text,r=text:gsub("{•}",wrap(tags))
			if r==0 then fail("文本中不存在 {•}。") end
		-- REPLACE WAVE
		elseif res.tagpres=="replace {~}" then
			repeat text,r=text:gsub("{~}({[^}]*})","%1{~}") until r==0
			text,r=text:gsub("{~}",wrap(tags))
			if r==0 then fail("文本中不存在 {~}。") end
		-- REPLACE LINE BREAK
		elseif res.tagpres=="replace \\N" then
			text,r=text:gsub("\\N",tags)
			if r==0 then fail("文本中不存在 \\N。") end
		-- AT ASTERISK POINT
		else
			replace=place:gsub("%*",wrap(tags)):gsub("\\N","")
			v2=nobra(replace)
			if v1==v2 then text=initags..retextmod(orig,replace) else fail("文本不一致。") end
		end
		text=text:gsub("{(\\[Nh])}","%1")
		text=tagmerge(text)
	  
	  elseif pla==0 then
		-- REGULAR START TAGS
		for t in tags:gmatch("\\%d?%a[^\\]*") do text=addtag3(t,text) end
		text=text:gsub(STAG,function(a) repeat a,r=a:gsub("(\\[1234]a%b&&)(.-)(\\alpha%b&&)","%2%3%1") until r==0 return a end)
	  end
	  text=text:gsub(ATAG,function(tg) return duplikill(tg) end)
	  repeat text,r=text:gsub("{([^}]-)(\\[Nh])([^}]-)}","%2{%1%3}") until r==0
	  text=text:gsub("{}","")
	end
	
	-- non-transformable tags
	if pla==0 then
		-- strikeout/underline/bold/italics
		if res.strike then text=bolts(text,"\\s","strikeout") end
		if res.under then text=bolts(text,"\\u","underline") end
		if res.bolt then text=bolts(text,"\\b","bold") end
		if res.italix then text=bolts(text,"\\i","italic") end
		-- \fad
		if res.fade then
		    IN=res.fadin OUT=res.fadout fGO=1
		    if res.glo then
			if z<#sel then OUT=0 end
			if z>1 then IN=0 end
			if IN==0 and OUT==0 then fGO=0 end
		    end
		    text=text:gsub("\\fad%([%d%.%,]-%)","")
		    if fGO==1 then text=text:gsub("^{\\","{\\fad("..IN..","..OUT..")\\") end
		end
		-- \q2
		if res.q2 then
		    if text:match("\\q2") then text=text:gsub("\\q2","") else text=text:gsub("^{\\","{\\q2\\") end
		end
		-- \an
		if res.an1 then
		    if text:match("\\an%d") then text=text:gsub("\\an(%d)","\\an"..res.an2) else text=text:gsub("^{\\","{\\an"..res.an2.."\\") end
		end
		
		if text==line.text then fail("标签很可能已存在。") end
	end
	
	-- unblock transforms
	text=text:gsub("\\tra(%b())",function(t) return "\\t"..t:gsub("/","\\") end)
    end
    -- the end
	
	text=text:gsub("\\HYDRA","") :gsub("\\t%([^\\%)]-%)","") :gsub("{}","")
	if line.text~=text then success=success+1 end
	line.text=text
	subs[i]=line
	end
	summary()
end

function bolts(text,ttype,srtype)
	if text:match("^{[^}]-"..ttype.."[01]") then text=text:gsub(ttype.."([01])",function(a) return ttype..(1-a) end)
	else
		local t_val=text:match(ttype.."([01])")
		if not t_val then
			if stylechk(sty)[srtype] then t_val="0" else t_val="1" end
		end
		text=text:gsub(ttype.."([01])",function(a) return ttype..(1-a) end)	:gsub("^({\\[^}]*)}","%1"..ttype..t_val.."}")
	end
	return text
end

function vis_replace(t,r1,r2)
	local nt=''
	repeat
		seg,t2=t:match("^(%b{})(.*)") --tags/comms
		if not seg then seg,t2=t:match("^([^{]+)(.*)") --text
			if not seg then break end
			seg=seg:gsub(r1,r2)
		end
		nt=nt..seg
		t=t2
	until t==''
	return nt
end

function getcolours()
col={} alfalfa={}
    for c=1,4 do
    local colur=res["c"..c]:gsub("#(%x%x)(%x%x)(%x%x).*","&H%3%2%1&")
    table.insert(col,colur)
      if res.alfas then
      local alpa=res["c"..c]:match("#%x%x%x%x%x%x(%x%x)")
	if alpa then
          table.insert(alfalfa,alpa)
          if res["k"..c] then res["arf"..c]=true res["alph"..c]=alfalfa[c] end
	end
      end
      if res.aonly then res["k"..c]=false end
    end
end

function gettags(tags)
	if res.reuse then
		if lastags then
			if res.show then showtags(lastags) end
			return lastags
		else t_error("没有可复用的标签",1) end
	end
	if res.fsc1 then res.fscx1=true res.fscy1=true res.fscx2=res.fsc2 res.fscy2=res.fsc2 end
	if res["blur1"] then tags=tags.."\\blur"..res["blur2"] end
	if res["be1"] then tags=tags.."\\be"..res["be2"] end
	if res["bord1"] then tags=tags.."\\bord"..res["bord2"] end
	if res["shad1"] then tags=tags.."\\shad"..res["shad2"] end
	if res["fs1"] then tags=tags.."\\fs"..res["fs2"] end
	if res["spac1"] then tags=tags.."\\fsp"..res["spac2"] end
	if res["fscx1"] then tags=tags.."\\fscx"..res["fscx2"] end
	if res["fscy1"] then tags=tags.."\\fscy"..res["fscy2"] end
	if res["xbord1"] then tags=tags.."\\xbord"..res["xbord2"] end
	if res["ybord1"] then tags=tags.."\\ybord"..res["ybord2"] end
	if res["xshad1"] then tags=tags.."\\xshad"..res["xshad2"] end
	if res["yshad1"] then tags=tags.."\\yshad"..res["yshad2"] end
	if res["frz1"] then tags=tags.."\\frz"..res["frz2"] end
	if res["frx1"] then tags=tags.."\\frx"..res["frx2"] end
	if res["fry1"] then tags=tags.."\\fry"..res["fry2"] end
	if res["fax1"] then tags=tags.."\\fax"..res["fax2"] end
	if res["fay1"] then tags=tags.."\\fay"..res["fay2"] end
	if res["k1"] then tags=tags.."\\c"..col[1] end
	if res["k2"] then tags=tags.."\\2c"..col[2] end
	if res["k3"] then tags=tags.."\\3c"..col[3] end
	if res["k4"] then tags=tags.."\\4c"..col[4] end
	if res["arfa"] then tags=tags.."\\alpha&H"..res["alpha"].."&" end
	if res["arf1"] then tags=tags.."\\1a&H"..res["alph1"].."&" end
	if res["arf2"] then tags=tags.."\\2a&H"..res["alph2"].."&" end
	if res["arf3"] then tags=tags.."\\3a&H"..res["alph3"].."&" end
	if res["arf4"] then tags=tags.."\\4a&H"..res["alph4"].."&" end
	lastags=tags
	if res.show then showtags(tags) end
	if res["moretags"] and res["moretags"]~="\\" then tags=tags..res["moretags"] end
	return tags
end

function addbyline(tags,ortags)
	tags=ortags:gsub("\\(%a%a+)([%d%.%-]+)",function(t,v)
		if t~="an" and t~="fn" then
			local nv=round(v+res.add*z0,2)
			if nv<0 and noneg2:match("|"..t.."|") then nv=0 end
			return "\\"..t..nv
		else return "\\"..t..v end
		end)
	return tags
end

function linecheck()
	lay=line.layer	sty=line.style	act=line.actor	eff=line.effect
	if not res.appltx then res.appltx="" end
	GO=nil local lGO,sGO,aGO,eGO,tGO
	if res.applay=="全部图层" or not res.exc and tonumber(res.applay)==lay or res.exc and tonumber(res.applay)~=lay then lGO=true end
	if res.applst=="全部样式" or not res.exc and res.applst==sty or res.exc and res.applst~=sty then sGO=true end
	if res.applac=="全部Actors" or not res.exc and res.applac==act or res.exc and res.applac~=act then aGO=true end
	if res.applef=="全部效果" or not res.exc and res.applef==eff or res.exc and res.applef~=eff then eGO=true end
	if res.appltx=="文本..." or res.appltx=="" or line.text:match(esc(res.appltx)) then tGO=true end
	if lGO and sGO and aGO and eGO and tGO then GO=true end
	if loaded<3 then GO=true end
	if not GO then fail("已设置某些 '应用到' 限制。") end
end

--	GRADIENTS	--
function hydradient(subs,sel)
	local GT=res.gtype:match("^....")
	local strip=res.stripe
	local acc=res.accel
	styleget(subs)
	getcolours()
	tags=""
	tags=gettags(tags)
	if tags=="" then ak() end
	ortags=tags
	local gcpos=res.linetext gcl=nil
	if res.middle and gcpos:match("*") then gc1,gc2=gcpos:match("^(.-)%*(.-)$") gcl=gc1:len() end
	local GBCn=tonumber(gcpos:match("^%d$")) or 1
	text1=subs[sel[1]].text
	tags_1=text1:match(STAG) or ""
	tags_1=detra(tags_1)
	if GT=="by l" then GBL=0 z1=0
		for z,i in ipairs(sel) do line=subs[i] linecheck() if GO then GBL=GBL+1 end end
		-- GBL: values from last line
		if res.last then
			local l=subs[sel[#sel]]
			local st=l.text:match(STAG) or ""
			for tg in tags:gmatch("\\[^\\]+") do
				local tag=tg:match '\\%d?%a+'
				local tv=st:match(tag.."([^\\})]+)")
				if tv then tg2=tag..tv tags=tags:gsub(esc(tg),tg2) end
			end
		end
		table.sort(sel,function(a,b) return a>b end)
	end
	local bra={}
    for z=#sel,1,-1 do
	i=sel[z]
	progress("渐变处理行 #"..i-line0.." ["..#sel+1-z.."/"..#sel.."]")
	line=subs[i]
        text=line.text
	orig=text
	visible=nobrea(text)
	text=text:gsub("\\t(%b())",function(t) return "\\tra"..t:gsub("\\","/") end) :gsub("\\1c","\\c")
	initags=text:match(STAG) or ""
	sr=stylechk(line.style)
	linecheck()
	
	-- hori/vert
	if GO and GT:match("r") then
	  x1,y1,x2,y2=initags:match("clip%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)")
	  if not x1 then
		local note=''
		if #sel>1 then note='\n(Note: Lines are processed from last to first.)' end
		t_error(res.gtype.." gradient:\nMissing rectangular clip on line #"..i-line0..note.."\nAborting.",1)
	  end
	  x1=math.floor(x1) y1=math.floor(y1) x2=math.ceil(x2) y2=math.ceil(y2) local c_s
	  if GT=="vert" then total=math.ceil((y2-y1)/strip) c_s=y2-y1 else total=math.ceil((x2-x1)/strip) c_s=x2-x1 end
	  if total<2 then t_error("第 "..i-line0.." 行出错。\n无法创建任何渐变。\n请减小 像素/条纹 设置。\n条纹: "..strip.."; 裁切尺寸: "..c_s.."\n中止。",1) end
	  if not initags:match("\\pos") and not initags:match("\\move") then initags=getpos(subs,initags) end
	  
	  for l=1,total do
	    LN=l count=total
	    half=math.ceil(total/2)
	    if res.middle then count=half
		if LN>half then LN=total-LN+1 end
	    end
	    stags=initags
	    text2=text
	    for tg,V2 in tags:gmatch("(\\%d?%a+)([^\\]+)") do
		if tg:match("fr") and res.short then V2=shortrot(V2) end
		V1=initags:match("^{[^}]-"..tg.."([%d%-&][^\\}]*)") or tag2style(tg,sr)
		if tg:match("fr") and res.short then V1=shortrot(V1) end
		if tg:match("\\[fbsxy]") then VC=numgrad(V1,V2,count,LN,acc) end
		if tg:match("\\%d?a") then VC=agrad(V1,V2,count,LN,acc) end
		if tg:match("\\%d?c") then
				if res.hsl then VC=acgradhsl(V1,V2,count,LN,acc) else VC=acgrad(V1,V2,count,LN,acc) end				
			end
		stags=addtag3(tg..VC,stags)
		stags=stags:gsub("clip%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)",function(a,b,c,d)
			if GT=="vert" then b=y1+(l-1)*strip d=b+strip a=x1 c=x2 end
			if GT=="hori" then a=x1+(l-1)*strip c=a+strip b=y1 d=y2 end
			return "clip("..a..","..b..","..c..","..d end)
		text2=text2:gsub("(.)("..ATAG..")",function(a,tblok)
			V1i=tblok:match("^{[^}]-"..tg.."([%d%-&][^\\}]*)")
			if V1i and tg:match("\\[fbsxy]") then VC=numgrad(V1i,V2,count,LN,acc) end
			if V1i and tg:match("\\%d?a") then VC=agrad(V1i,V2,count,LN,acc) end
			if V1i and tg:match("\\%d?c") then
				if res.hsl then VC=acgradhsl(V1i,V2,count,LN,acc) else VC=acgrad(V1i,V2,count,LN,acc) end				
			end
			tblok=addtag3(tg..VC,tblok)
			return a..tblok end)
	    end
	    l2=line
	    l2.text=text2:gsub(STAG,stags) :gsub("\\tra(%b())",function(t) return "\\t"..t:gsub("/","\\") end)
	    if l==1 then text=l2.text
	    else subs.insert(i+l-1,l2) end
	  end
	  if z<#sel then for s=z+1,#sel do sel[s]=sel[s]+total-1 end end
	  for s=1,total-1 do table.insert(sel,i+s) end
	end
	
	-- by character
	letrz0=re.find(visible,".") or {}
	if GT=="by c" and text:match '\\p1' then GO=nil fail("某些行包含绘图。") end
	if GT=="by c" and GBCn>#letrz0 then GO=nil end
	if GO and GT=="by c" and #letrz0>1 then
	    orig=orig:gsub("(\\[Nh])","{%1}")
	    if text:match "{[^}]*{" or text:match "}[^{]*}" or text:match "^[^{]*}" or text:match "{[^}]*$" then brackets=true table.insert(bra,1,i-line0) end
	    re_check=0
	    repeat
		LTR={}
		TAG={}
		letrz=re.find(visible,".{"..GBCn.."}")
		rest=re.sub(visible,".{"..GBCn.."}","")
		for l=1,#letrz do
			table.insert(LTR,letrz[l].str)
			table.insert(TAG,"")
		end
		if rest~="" then table.insert(LTR,rest) table.insert(TAG,"") end
		for tg,V2 in tags:gmatch("(\\%d?%a+)([^\\]+)") do
			if tg:match("fr") and res.short then V2=shortrot(V2) end
			V1=text:match("^{[^}]-"..tg.."([%d%-&][^\\}]*)") or tag2style(tg,sr)
			if tg:match("fr") and res.short then V1=shortrot(V1) end
			initags=addtag3(tg..V1,initags)
			for l=2,#LTR do
				LN=l count=#LTR
				half=math.ceil(#LTR/2)
				if gcl and gc1..gc2==visible then
					if l<=gcl then count=gcl else count=#LTR-gcl LN=#LTR-l+1 end
				elseif res.middle then count=half
					if LN>half then LN=#LTR-LN+1 end
				end
				if tg:match("\\[fbsxy]") then VC=numgrad(V1,V2,count,LN,acc) end
				if tg:match("\\%d?a") then VC=agrad(V1,V2,count,LN,acc) end
				if tg:match("\\%d?c") then
					if res.hsl then VC=acgradhsl(V1,V2,count,LN,acc) else VC=acgrad(V1,V2,count,LN,acc) end
				end
				TAG[l]=TAG[l]..tg..VC
			end
		end
		nt=LTR[1]
		for l=2,#LTR do nt=nt.."{"..TAG[l].."}"..LTR[l] end
		text=initags..textmod(orig,nt)
		text=text:gsub(ATAG,function(tg) return duplikill(tg) end)
		repeat text,r=text:gsub("{([^}]-)(\\[Nh])([^}]-)}","%2{%1%3}") until r==0
		text=text:gsub("{}","")
		visible2=nobrea(text)
		if visible~=visible2 then re_check=re_check+1 end
	    until visible==visible2 or re_check>=100
	end
	
	-- by line
	if GO and GT=="by l" then z1=z1+1
		LN=z1 total=GBL count=GBL
		half=math.ceil(total/2)
		if res.middle then count=half
			if LN>half then LN=total-LN+1 end
		end
		stags=initags
		for tg,V2 in tags:gmatch("(\\%d?%a+)([^\\]+)") do
			if tg:match("fr") and res.short then V2=shortrot(V2) end
			V1=tags_1:match("^{[^}]-"..tg.."([%d%-&][^\\}]*)") or tag2style(tg,sr)
			if tg:match("fr") and res.short then V1=shortrot(V1) end
			if tg:match("\\[fbsxy]") then VC=numgrad(V1,V2,count,LN,acc) end
			if tg:match("\\%d?a") then VC=agrad(V1,V2,count,LN,acc) end
			if tg:match("\\%d?c") then
				if res.hsl then VC=acgradhsl(V1,V2,count,LN,acc) else VC=acgrad(V1,V2,count,LN,acc) end
			end
			stags=addtag3(tg..VC,stags)
		end
		text=text:gsub(STAG,stags) :gsub("\\tra(%b())",function(t) return "\\t"..t:gsub("/","\\") end)
		if line.text==text then fail("目标值可能已存在。") end
	end
	
	text=text:gsub("\\tra(%b())",function(t) return "\\t"..t:gsub("/","\\") end)
	visible2=nobrea(text)
	txt_check(visible,visible2,i)
	if line.text~=text and visible==visible2 then success=success+1 end
        line.text=text
	subs[i]=line
    end
    if brackets then
	local l=''
	for k,v in ipairs(bra) do l=l..v..', ' end
	l=l:gsub(', $','')
	t_error("某些行包含错误的大括号组合。\n这可能无法正常应用渐变。\n行号: "..l)
	brackets=nil
    end
    summary()
    return sel
end

--	SPECIAL FUNCTIONS	--
function special(subs,sel)
  SF=res.spec
  if res.spec=="往复变换" and res.int==0 then
	BAFT={{class="label",label="缺少往复变换的间隔。\n请输入毫秒值。"},
	{y=1,name="int2",class="intedit",min=0}}
	pres,rez=ADD(BAFT,{"OK","Cancel"},{ok='OK',close='Cancel'})
	if pres=="Cancel" or rez.int2==0 then ak() end
	res.int=rez.int2
  end
  if res.spec:match"transform" or res.spec:match"strikeout" then
    getcolours()
    transphorm=""
    transphorm=gettags(transphorm)
  end
  if res.spec=="将行分割为3部分" then
	if res.trin==0 and res.trout==0 then t_error("未提供分割行的时间。\n请使用变换 t1 和 t2 字段。",1) end
	nsel={} for z,i in ipairs(sel) do table.insert(nsel,i) end
  end
  styleget(subs)
  if res.spec=="选择重叠行" then sel=selover(subs)
  else
    for z=#sel,1,-1 do
        i=sel[z]
	progress(res.spec..": "..#sel-z.."/"..#sel)
	prog=math.floor((#sel-z+0.5)/#sel*100)
 	aegisub.progress.set(prog)
	line=subs[i]
        text=line.text
	layer=line.layer
	linecheck()
	if GO then res.spec=SF else res.spec="nope" end
	text=text:gsub("\\1c","\\c")
	
	if res.spec=="fscx -> fscy" then text=text:gsub("\\fscy[%d%.]+",""):gsub("\\fscx([%d%.]+)","\\fscx%1\\fscy%1") end
	if res.spec=="fscy -> fscx" then text=text:gsub("\\fscx[%d%.]+",""):gsub("\\fscy([%d%.]+)","\\fscx%1\\fscy%1") end
	if res.spec=="shad -> xshad+yshad" then
		text=text:gsub("\\shad([%d%.]+)","\\xshad%1\\yshad%1"):gsub(ATAG,function(tg) return duplikill(tg) end)
		if text==line.text then fail("缺少 \\shad 标签。") end
	end
	
	if res.spec=="移动颜色标签到首块" then
		tags=text:match(STAG) or ""
		text=text:gsub(STAG,"")
		klrs=""
		for klr in text:gmatch("\\[1234]?c&H%x+&") do klrs=klrs..klr end
		text=text:gsub("(\\[1234]?c&H%x+&)","") :gsub("{}","")
		text=tags.."{"..klrs.."}"..text
		text=tagmerge(text):gsub("{}","")
		:gsub(ATAG,function(tg) return duplikill(tg) end)
	end
	
	if res.spec=="clip <-> iclip" then
		text=text:gsub("\\(i?)clip",function(k) if k=="" then return "\\iclip" else return "\\clip" end end)
		if text==line.text then fail("未找到 (i)clip。") end
	end
	
	-- CLEAN UP TAGS
	if res.spec=="清理标签" then
		text=text:gsub("{\\\\k0}",""):gsub(">\\","\\"):gsub("{(\\[^}]-)} *\\N *{(\\[^}]-)}","\\N{%1%2}")
		text=tagmerge(text)
		text=text:gsub("({\\[^}]-){(\\[^}]-})","%1%2"):gsub("{.-\\r","{\\r"):gsub("^{\\r([\\}])","{%1")
		text=text:gsub("\\fad%(0,0%)",""):gsub(ATAG.."$",""):gsub("^({\\[^}]-)\\frx0\\fry0","%1")
		text=text:gsub(ATAG,function(tgs)
			tgs2=tgs
			:gsub("\\+([\\}])","%1")
			:gsub("(\\[^\\})]+)",function(a) if not a:match'clip' and not a:match'\\fn' and not a:match'\\r' then a=a:gsub(' ','') end return a end)
			:gsub("(\\%a+)([%d%-]+%.%d+)",function(a,b) if not a:match("\\fn") then b=round(b,2) end return a..b end)
			:gsub("(\\%a+)%(([%d%.%-]+),([%d%.%-]+)%)",function(a,b,c) b=round(b,2) c=round(c,2) return a.."("..b..","..c..")" end)
			:gsub("(\\%a+)%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)",function(a,b,c,d,e)
				b=round(b,2) c=round(c,2) d=round(d,2) e=round(e,2) return a.."("..b..","..c..","..d..","..e end)
			tgs2=duplikill(tgs2)
			tgs2=extrakill(tgs2)
			tgs2=cleantr(tgs2)
			return tgs2
			end)
	end
	
	-- SORT TAGS
	if res.spec=="按设定顺序排序标签" then
		text=text:gsub("\\a6","\\an8") :gsub("\\1c","\\c")
		-- run for each set of tags
		for tags in text:gmatch(ATAG) do
			orig=tags
			tags=tags:gsub("{.-\\r","{\\r")
			-- save & nuke transforms
			trnsfrm=""
			for t in tags:gmatch("\\t%b()") do trnsfrm=trnsfrm..t end
			tags=tags:gsub("\\t%b()","")
			ord=""
			-- go through tags, save them in order, and delete from tags
			for tg in order:gmatch("\\[%a%d]+") do
				tag=tags:match("("..tg.."[^\\}]-)[\\}]")
				if tg=="\\fs" then tag=tags:match("(\\fs%d[^\\}]-)[\\}]") end
				if tg=="\\fad" then tag=tags:match("(\\fad%([^\\}]-)[\\}]") end
				if tg=="\\c" then tag=tags:match("(\\c&[^\\}]-)[\\}]") end
				if tg=="\\i" then tag=tags:match("(\\i[^%a\\}]-)[\\}]") end
				if tg=="\\s" then tag=tags:match("(\\s[^%a\\}]-)[\\}]") end
				if tg=="\\p" then tag=tags:match("(\\p[^%a\\}]-)[\\}]") end
				if tag then ord=ord..tag etag=esc(tag) tags=tags:gsub(etag,"") end
			end
			-- attach whatever got left
			if tags~="{}" then ord=ord..tags:match("{(.-)}") end
			ordered="{"..ord..trnsfrm.."}"
			text=text:gsub(esc(orig),ordered)
		end
	end
	
	-- CLIP TO DRAWING
	if res.spec=="clip转绘图" and text:match("\\i?clip%(m [%d%a%s%-]+") then
		text=text:gsub("\\(i?)clip%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)%)",function(ii,a,b,c,d) 
			return string.format("\\"..ii.."clip(m %d %d l %d %d %d %d %d %d)",round(a),round(b),round(c),round(b),round(c),round(d),round(a),round(d)) end) -- rect.2vector
		text=text:gsub("^({\\[^}]-}).*","%1")
		text=text:gsub("^({[^}]*)\\i?clip%(m(.-)%)([^}]*)}","%1%3\\p1}m%2")
		if text:match("\\pos") or text:match("\\move") then
			ctext=text:match("}m ([%d%a%s%-]+)")
			local xx,yy=text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)")
			if not xx then xx,yy=text:match("\\move%(([%d%.%-]+),([%d%.%-]+)") end
			xx=round(xx) yy=round(yy)
			ctext2=ctext:gsub("([%d%-]+)%s([%d%-]+)",function(a,b) return a-xx.." "..b-yy end)
			ctext=ctext:gsub("%-","%%-")
			text=text:gsub(ctext,ctext2)
		end
		if not text:match("\\pos") and not text:match("\\move") then text=text:gsub("^{","{\\pos(0,0)") end
		text=text:gsub("\\fsc[xy][%d%.]+",""):gsub("\\f[ar][xyz][^\\}]*",""):gsub("\\p1","\\fscx100\\fscy100%1"):gsub("\\an%d",""):gsub("^{","{\\an7")
	end
	
	-- DRAWING TO CLIP
	if res.spec=="绘图转clip" and text:match("\\p1") then
		draw=text:match("}m ([^{]+)")
		rota=text:match("^{[^}]-\\frz([-%d.]+)")
		if rota then sr=stylechk(line.style) text=frz_redraw(text,rota,draw,sr) end
		text=text:gsub("^({[^}]*)\\p1([^}]-})(m [^{]*)","%1\\clip(%3)%2")
		scx=text:match("\\fscx([%d%.]+)") or 100
		scy=text:match("\\fscy([%d%.]+)") or 100
		if text:match("\\pos") or text:match("\\move") then
			local xx,yy=text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)")
			if not xx then xx,yy=text:match("\\move%(([%d%.%-]+),([%d%.%-]+)") end
			xx=round(xx) yy=round(yy)
			ctext=text:match("\\clip%(m ([^%)]+)%)")
			ctext2=ctext:gsub("([%d%-]+) ([%d%-]+)",function(a,b) return round(a*scx/100+xx).." "..round(b*scy/100+yy) end)
			text=text:gsub(esc(ctext),ctext2)
		end
		if not text:match("\\pos") and not text:match("\\move") then text=text:gsub("^{","{\\pos(0,0)") end
	end
	
	-- STRIKEOUT TO SELECTED
	if res.spec=="删除线转选中标签" then
		selcheck()
		ST1=transphorm ST2=transphorm:gsub("(\\%d?%a+)[^\\]+","%1")
		text=text:gsub("\\s1",ST1):gsub("\\s0",ST2)
		if text==line.text then fail("未找到 \\s1 标签。") end
		text=text:gsub(ATAG,function(tg) return duplikill(tg) end)	
	end
	
	-- CREATE SHADOW FROM CLIP
	if res.spec=="从clip创建阴影" then
		local KX1,KY1,KX2,KY2=text:match("\\i?clip%(m (%-?[%d%.]+) (%-?[%d%.]+) l (%-?[%d%.]+) (%-?[%d%.]+)")
		if not KX1 then t_error("第 "..i-line0.." 行: 未检测到矢量clip。\n请使用clip的两个点来设定阴影方向。)",1) end
		sr=stylechk(line.style)
		stag=text:match(STAG) or "{}"
		sha=stag:match("\\shad([%d%.]+)")
		if not sha then
			sx=stag:match("\\xshad%-?([%d%.]+)")
			sy=stag:match("\\yshad%-?([%d%.]+)")
			if sx and sy then sha=math.sqrt((sx^2+sy^2)/2) end
			if not sha then sha=sr.shadow end
		end
		if tonumber(sha)==0 then t_error("第 "..i-line0.." 行: 阴影似乎为 0。已设置为 4。\n(建议先设置 \\shad 值。)") sha=4 end
		eks=KX2-KX1
		wai=KY2-KY1
		pyth=math.sqrt(eks^2+wai^2)
		shratio=pyth/math.sqrt(2*sha^2)
		shX=round(eks/shratio,1)
		shY=round(wai/shratio,1)
		stag=stag:gsub("\\.?shad([%d%.]+)",""):gsub("\\i?clip%b()",""):gsub("}","\\xshad"..shX.."\\yshad"..shY.."}")
		text=stag..text:gsub(STAG,"")
	end
	
	-- 3D SHADOW
	if res.spec=="从阴影创建3D效果" then
		if not text:match("\\[xy]shad") then
			text,c=text:gsub("\\shad([%d.]+)","\\xshad%1\\yshad%1")
			if c==0 then
				sr=stylechk(line.style)
				text="{\\xshad"..sr.shadow.."\\yshad"..sr.shadow.."}"..text
				text=text:gsub("^({.*)}{","%1")
			end
		end
		xshad=tonumber(text:match("^{[^}]-\\xshad([%d%.%-]+)"))	or 0	ax=math.abs(xshad)
		yshad=tonumber(text:match("^{[^}]-\\yshad([%d%.%-]+)"))	or 0	ay=math.abs(yshad)
		if ax>ay then lay=math.floor(ax) else lay=math.floor(ay) end
		
		text2=text:gsub("^({\\[^}]-)}","%1\\3a&HFF&}")	:gsub("\\3a&H%x%x&([^}]-)(\\3a&H%x%x&)","%1%2")
		
		for l=lay,1,-1 do
			line2=line	    f=l/lay
			text2=addtag3('\\1a&HFE&',text2)
			txt=text2	    if l==1 then txt=text end
			line2.text=txt
			:gsub("\\xshad([%d%.%-]+)",function(a) xx=tostring(f*a) xx=xx:gsub("([%d%-]+%.%d%d)%d+","%1") return "\\xshad"..xx end)
			:gsub("\\yshad([%d%.%-]+)",function(a) yy=tostring(f*a) yy=yy:gsub("([%d%-]+%.%d%d)%d+","%1") return "\\yshad"..yy end)
			line2.layer=layer+(lay-l)
			subs.insert(i+1,line2)
		end
		
		if math.abs(xshad)>=1 or math.abs(yshad)>=1 then
			subs.delete(i)
			for s=z+1,#sel do
				sel[s]=sel[s]+lay-1
			end
			success=success+1
		else fail("没有可用的阴影。")
		end
	end
	
	-- CLIP GRID
	if res.spec=="棋盘格clip" then
		cbklip="\\clip(m 100 100 l 140 100 l 140 180 l 180 180 l 180 140 l 100 140 m 180 100 l 220 100 l 220 180 l 260 180 l 260 140 l 180 140 m 260 100 l 300 100 l 300 180 l 340 180 l 340 140 l 260 140 m 340 100 l 380 100 l 380 180 l 420 180 l 420 140 l 340 140 m 420 100 l 460 100 l 460 180 l 500 180 l 500 140 l 420 140 m 500 100 l 540 100 l 540 180 l 580 180 l 580 140 l 500 140 m 580 100 l 620 100 l 620 180 l 660 180 l 660 140 l 580 140 m 660 100 l 700 100 l 700 180 l 740 180 l 740 140 l 660 140 m 740 100 l 780 100 l 780 180 l 820 180 l 820 140 l 740 140 m 820 100 l 860 100 l 860 180 l 900 180 l 900 140 l 820 140 m 900 100 l 940 100 l 940 180 l 980 180 l 980 140 l 900 140 m 980 100 l 1020 100 l 1020 180 l 1060 180 l 1060 140 l 980 140 m 100 180 l 140 180 l 140 260 l 180 260 l 180 220 l 100 220 m 180 180 l 220 180 l 220 260 l 260 260 l 260 220 l 180 220 m 260 180 l 300 180 l 300 260 l 340 260 l 340 220 l 260 220 m 340 180 l 380 180 l 380 260 l 420 260 l 420 220 l 340 220 m 420 180 l 460 180 l 460 260 l 500 260 l 500 220 l 420 220 m 500 180 l 540 180 l 540 260 l 580 260 l 580 220 l 500 220 m 580 180 l 620 180 l 620 260 l 660 260 l 660 220 l 580 220 m 660 180 l 700 180 l 700 260 l 740 260 l 740 220 l 660 220 m 740 180 l 780 180 l 780 260 l 820 260 l 820 220 l 740 220 m 820 180 l 860 180 l 860 260 l 900 260 l 900 220 l 820 220 m 900 180 l 940 180 l 940 260 l 980 260 l 980 220 l 900 220 m 980 180 l 1020 180 l 1020 260 l 1060 260 l 1060 220 l 980 220 m 100 260 l 140 260 l 140 340 l 180 340 l 180 300 l 100 300 m 180 260 l 220 260 l 220 340 l 260 340 l 260 300 l 180 300 m 260 260 l 300 260 l 300 340 l 340 340 l 340 300 l 260 300 m 340 260 l 380 260 l 380 340 l 420 340 l 420 300 l 340 300 m 420 260 l 460 260 l 460 340 l 500 340 l 500 300 l 420 300 m 500 260 l 540 260 l 540 340 l 580 340 l 580 300 l 500 300 m 580 260 l 620 260 l 620 340 l 660 340 l 660 300 l 580 300 m 660 260 l 700 260 l 700 340 l 740 340 l 740 300 l 660 300 m 740 260 l 780 260 l 780 340 l 820 340 l 820 300 l 740 300 m 820 260 l 860 260 l 860 340 l 900 340 l 900 300 l 820 300 m 900 260 l 940 260 l 940 340 l 980 340 l 980 300 l 900 300 m 980 260 l 1020 260 l 1020 340 l 1060 340 l 1060 300 l 980 300 m 100 340 l 140 340 l 140 420 l 180 420 l 180 380 l 100 380 m 180 340 l 220 340 l 220 420 l 260 420 l 260 380 l 180 380 m 260 340 l 300 340 l 300 420 l 340 420 l 340 380 l 260 380 m 340 340 l 380 340 l 380 420 l 420 420 l 420 380 l 340 380 m 420 340 l 460 340 l 460 420 l 500 420 l 500 380 l 420 380 m 500 340 l 540 340 l 540 420 l 580 420 l 580 380 l 500 380 m 580 340 l 620 340 l 620 420 l 660 420 l 660 380 l 580 380 m 660 340 l 700 340 l 700 420 l 740 420 l 740 380 l 660 380 m 740 340 l 780 340 l 780 420 l 820 420 l 820 380 l 740 380 m 820 340 l 860 340 l 860 420 l 900 420 l 900 380 l 820 380 m 900 340 l 940 340 l 940 420 l 980 420 l 980 380 l 900 380 m 980 340 l 1020 340 l 1020 420 l 1060 420 l 1060 380 l 980 380 m 100 420 l 140 420 l 140 500 l 180 500 l 180 460 l 100 460 m 180 420 l 220 420 l 220 500 l 260 500 l 260 460 l 180 460 m 260 420 l 300 420 l 300 500 l 340 500 l 340 460 l 260 460 m 340 420 l 380 420 l 380 500 l 420 500 l 420 460 l 340 460 m 420 420 l 460 420 l 460 500 l 500 500 l 500 460 l 420 460 m 500 420 l 540 420 l 540 500 l 580 500 l 580 460 l 500 460 m 580 420 l 620 420 l 620 500 l 660 500 l 660 460 l 580 460 m 660 420 l 700 420 l 700 500 l 740 500 l 740 460 l 660 460 m 740 420 l 780 420 l 780 500 l 820 500 l 820 460 l 740 460 m 820 420 l 860 420 l 860 500 l 900 500 l 900 460 l 820 460 m 900 420 l 940 420 l 940 500 l 980 500 l 980 460 l 900 460 m 980 420 l 1020 420 l 1020 500 l 1060 500 l 1060 460 l 980 460 m 100 500 l 140 500 l 140 580 l 180 580 l 180 540 l 100 540 m 180 500 l 220 500 l 220 580 l 260 580 l 260 540 l 180 540 m 260 500 l 300 500 l 300 580 l 340 580 l 340 540 l 260 540 m 340 500 l 380 500 l 380 580 l 420 580 l 420 540 l 340 540 m 420 500 l 460 500 l 460 580 l 500 580 l 500 540 l 420 540 m 500 500 l 540 500 l 540 580 l 580 580 l 580 540 l 500 540 m 580 500 l 620 500 l 620 580 l 660 580 l 660 540 l 580 540 m 660 500 l 700 500 l 700 580 l 740 580 l 740 540 l 660 540 m 740 500 l 780 500 l 780 580 l 820 580 l 820 540 l 740 540 m 820 500 l 860 500 l 860 580 l 900 580 l 900 540 l 820 540 m 900 500 l 940 500 l 940 580 l 980 580 l 980 540 l 900 540 m 980 500 l 1020 500 l 1020 580 l 1060 580 l 1060 540 l 980 540)"
		text=text:gsub("^({[^}]-)\\i?clip%([^%)]+%)","%1")
		:gsub("^({\\[^}]-)}","%1"..cbklip.."}")
		if not text:match("^{") then text=wrap(cbklip)..text end
	end
	
	-- size transform from clip
	if res.spec=="从clip获取尺寸变换" then
		local klip=text:match("\\i?clip%(m %-?[%d%.]+ %-?[%d%.]+ l %-?[%d%.]+ %-?[%d%.]+ %-?[%d%.]+ %-?[%d%.]+ %-?[%d%.]+ %-?[%d%.]+")
		if not klip then t_error("第 "..i-line0.." 行: 需要带有 4 个点的矢量clip。",1) end
		local K1x,K1y,K2x,K2y,K3x,K3y,K4x,K4y=klip:match("m (%-?[%d%.]+) (%-?[%d%.]+) l (%-?[%d%.]+) (%-?[%d%.]+) (%-?[%d%.]+) (%-?[%d%.]+) (%-?[%d%.]+) (%-?[%d%.]+)")
		if defaref and line.style=="Default" then sr=defaref
		else sr=stylechk(line.style) end
		-- clean up existing transforms
		if text:match("^{[^}]*\\t") then text=text:gsub(STAG,function(tg) return cleantr(tg) end) end
		startags=text:match(STAG) or ""
		scx=startags:match("\\fscx([%d%.]+)") or sr.scale_x
		scy=startags:match("\\fscy([%d%.]+)") or sr.scale_y
		xdist1=math.abs(K1x-K2x)
		xdist2=math.abs(K3x-K4x)
		ydist1=math.abs(K1y-K2y)
		ydist2=math.abs(K3y-K4y)
		dist1=math.sqrt(xdist1^2+ydist1^2)
		dist2=math.sqrt(xdist2^2+ydist2^2)
		size_ratio=dist2/dist1
		rescx=round(scx*size_ratio,2)
		rescy=round(scy*size_ratio,2)
		local trans="\\t(\\fscx"..rescx.."\\fscy"..rescy..")"
		startags=startags:gsub("}",trans.."}")
		startags=cleantr(startags)
		text=text:gsub(STAG,startags):gsub("\\i?clip%b()","")
	end
	
	-- BACK AND FORTH TRANSFORM
	if res.spec=="往复变换" and res.int>0 then
	    selcheck()
	    if defaref and line.style=="Default" then sr=defaref
	    else sr=stylechk(line.style) end
	    -- clean up existing transforms
	    if text:match("^{[^}]*\\t") then text=text:gsub(STAG,function(tg) return cleantr(tg) end) end
	    startags=text:match(STAG) or ""
	    tags_1=""
	    for tg in transphorm:gmatch("\\[1234]?%a+") do
	      val1=nil
	      if not startags:match(tg.."[%d%-&%(]") then
		if tg=="\\clip" then val1="(0,0,1280,720)" else val1=tag2style(tg,sr) end
		if val1 then tags_1=tags_1..tg..val1 text=text:gsub("^({\\[^}]-)}","%1"..tg..val1.."}") end
	      else
	      val1=startags:match(tg.."([^\\}]+)")
	      tags_1=tags_1..tg..val1
	      end
	    end
	    int=res.int
	    tgs2=transphorm
	    dur=line.end_time-line.start_time
	    count=math.ceil(dur/int)
	    t=1		tin=0		tout=tin+int
	    if not text:match("^{\\") then text="{\\}"..text end
	    -- main function
	    while t<=math.ceil(count/2) do
		text=text:gsub("^({\\[^}]*)}","%1\\t("..tin..","..tout..","..tgs2..")}")
		if tin+int<dur then text=text:gsub("^({\\[^}]*)}","%1\\t("..tin+int..","..tout+int..","..tags_1..")}") end
		tin=tin+int+int
		tout=tin+int
		t=t+1
	    end
	    text=text:gsub("\\([\\}])","%1")
	end
	
	-- SPLIT LINE IN 3 PARTS
	if res.spec=="将行分割为3部分" then
		start=line.start_time
		endt=line.end_time
		dur=line.end_time-line.start_time
		-- Split Times
		ST1=res.trin
		ST2=res.trout
		if ST1+ST2>=dur then fail("某些行的分割时间超过了行时长。")
		else
			effect=line.effect
			-- line 3
			if ST2>0 then
				line3=line
				line3.start_time=endt-ST2
				line3.effect=effect.." pt.3"
				subs.insert(i+1,line3)
				nsel=shiftsel2(nsel,i,1)
			end
			-- line 2
			line2=line
			line2.start_time=start+ST1
			line2.end_time=endt-ST2
			line2.effect=effect.." pt.2"
			subs.insert(i+1,line2)
			nsel=shiftsel2(nsel,i,1)
			-- line 1
			if ST1>0 then
				line.start_time=start
				line.end_time=start+ST1
				line.effect=effect.." pt.1"
			else
				subs.delete(i)
				for s=#nsel,z,-1 do
					if nsel[s]==i then table.remove(nsel,s) end
					if nsel[s]>i then nsel[s]=nsel[s]-1 end
				end
			end
			success=success+1
		end
	end
	
	
	if res.spec~="create 3D effect from shadow" then
		if line.text~=text then
			success=success+1 
			line.text=text
			subs[i]=line
		end
	end
    end
  end
  if res.spec=="将行分割为3部分" then sel=nsel end
  summary()
  return sel
end

function frz_redraw(t,rota,draw,sr)
	local X,Y,x,y,width,height
	local ox,oy,xmx,xmn,ymx,ymn,addx,addy=0,0,0,999999,0,999999,0,0
	draw1=draw
	-- deal with align other than 7
	if align~=7 then
		for px,py in draw:gmatch("([-%d.]+) ([-%d.]+)") do
			px=tonumber(px)
			py=tonumber(py)
			if px>xmx then xmx=px end
			if px<xmn then xmn=px end
			if py>ymx then ymx=py end
			if py<ymn then ymn=py end
		end
		width=xmx-xmn
		height=ymx-ymn
		align=tonumber(t:match'\\an(%d)') or sr.align
		hal=align%3
		val=math.ceil(align/3)
		if hal==2 then addx=width/2 elseif hal==0 then addx=width end
		if val==2 then addy=height/2 elseif val==1 then addy=height end
		-- change to an7 + adjust coordinates
		draw1=draw1:gsub("([-%d.]+) ([-%d.]+)",function(px,py)
			return px-addx..' '..py-addy
			end)
		t,c=t:gsub("\\an%d","\\an7")
		if c==0 then t=t:gsub("^{","{\\an7") end
	end
	
	-- recalculate coordinates without frz
	draw2=draw1:gsub("([-%d.]+) ([-%d.]+)",function(px,py)
		h=math.sqrt((ox-px)^2+(oy-py)^2)
		pox=ox-px
		poy=oy-py
		tang=poy/pox
		ang1=math.deg(math.atan(tang))
		ang=ang1-rota
		X=math.cos(math.rad(ang))*h
		Y=math.sin(math.rad(ang))*h
		if pox<0 then X=0-X Y=0-Y end
		x=round(ox-X)
		y=round(oy-Y)
		return x..' '..y
		end)
	
	-- replace drawing
	t=t:gsub(esc(draw),draw2):gsub("\\frz[-%d.]+","")
	return t
end

function selover(subs,sel)
	local dialogue={}
	for i,line in ipairs(subs) do
		if line.class=="dialogue" then line.i=i table.insert(dialogue,line) end
	end
	table.sort(dialogue,function(a,b) return a.start_time<b.start_time or (a.start_time==b.start_time and a.i<b.i) end)
	local end_time=0
	local overlaps={}
	for i=1,#dialogue do
		local line=dialogue[i]
		if line.start_time>=end_time then
			end_time=line.end_time
		else
			table.insert(overlaps,line.i)
		end
	end
	sel=overlaps
	return sel
end


--	reanimatools	-----------------------------------------------------------------------
function addtag3(tg,txt)
	no_tf=txt:gsub("\\t%b()","")
	tgt=tg:match("(\\%d?%a+)[%d%-&]") val="[%d%-&]"
	if not tgt then tgt=tg:match("(\\%d?%a+)%b()") val="%b()" end
	if not tgt then tgt=tg:match("\\fn") val="" end
	if not tgt then t_error("添加标签 '"..tg.."' 失败。") end
	if tgt:match("clip") then txt,r=txt:gsub("^({[^}]-)\\i?clip%b()","%1"..tg)
		if r==0 then txt=txt:gsub("^({\\[^}]-)}","%1"..tg.."}") end
	elseif no_tf:match("^({[^}]-)"..tgt..val) then txt=txt:gsub("^({[^}]-)"..tgt..val.."[^\\}]*","%1"..tg)
	elseif not txt:match("^{\\") then txt="{"..tg.."}"..txt
	elseif txt:match("^{[^}]-\\t") then txt=txt:gsub("^({[^}]-)\\t","%1"..tg.."\\t")
	else txt=txt:gsub("^({\\[^}]-)}","%1"..tg.."}") end
	return txt
end

function esc(str) str=str:gsub("[%%%(%)%[%]%.%-%+%*%?%^%$]","%%%1") return str end
function round(n,dec) dec=dec or 0 n=math.floor(n*10^dec+0.5)/10^dec return n end
function wrap(str) return "{"..str.."}" end
function logg(m) m=tf(m) or "nil" aegisub.log("\n "..m) end
function loggtab(m) m=tf(m) or "nil" aegisub.log("\n {"..table.concat(m,', ').."}") end
function tagmerge(t) repeat t,r=t:gsub("({\\[^}]-)}{(\\[^}]-})","%1%2") until r==0 return t end
function detra(t) return t:gsub("\\t%b()","") end
function nobra(t) return t:gsub("%b{}","") end
function nobrea(t) return t:gsub("%b{}",""):gsub("\\[Nh]","") end
function nobrea1(t) return t:gsub("%b{}",""):gsub(" *\\[Nh] *"," ") end
function progress(msg) if aegisub.progress.is_cancelled() then ak() end aegisub.progress.title(msg) end
function t_error(message,cancel) ADD({{class="label",label=message}},{"OK"},{close='OK'}) if cancel then ak() end end

function tag2style(tg,sr)
	noneg="\\bord\\shad\\xbord\\ybord\\fs\\blur\\be\\fscx\\fscy"
	val=0
	if tg=="\\fs" then val=sr.fontsize end
	if tg=="\\fsp" then val=sr.spacing end
	if tg=="\\fscx" then val=sr.scale_x end
	if tg=="\\fscy" then val=sr.scale_y end
	if tg:match"\\[xy]?bord" then val=sr.outline end
	if tg:match"\\[xy]?shad" then val=sr.shadow end
	if tg=="\\frz" then val=sr.angle end
	if val<0 and noneg:match(tg) then val=0 end
	if tg=="\\c" then val=sr.color1:gsub("H%x%x","H") end
	if tg=="\\2c" then val=sr.color2:gsub("H%x%x","H") end
	if tg=="\\3c" then val=sr.color3:gsub("H%x%x","H") end
	if tg=="\\4c" then val=sr.color4:gsub("H%x%x","H") end
	if tg=="\\1a" then val=sr.color1:match("H%x%x") end
	if tg=="\\2a" then val=sr.color2:match("H%x%x") end
	if tg=="\\3a" then val=sr.color3:match("H%x%x") end
	if tg=="\\4a" then val=sr.color4:match("H%x%x") end
	if tg=="\\alpha" then val="&H00&" end
return val
end

function numgrad(V1,V2,total,l,acc)
	acc=acc or 1
	acc_fac=(l-1)^acc/(total-1)^acc
	VC=round(acc_fac*(V2-V1)+V1,2)
return VC
end

function agrad(C1,C2,total,l,acc)
	acc=acc or 1
	acc_fac=(l-1)^acc/(total-1)^acc
	A1=C1:match("(%x%x)")
	A2=C2:match("(%x%x)")
	nA1=(tonumber(A1,16))  nA2=(tonumber(A2,16))
	A=acc_fac*(nA2-nA1)+nA1
	A=tohex(round(A))
	CC="&H"..A.."&"
return CC
end

function acgrad(C1,C2,total,l,acc)
	acc=acc or 1
	acc_fac=(l-1)^acc/(total-1)^acc
	B1,G1,R1=C1:match("(%x%x)(%x%x)(%x%x)")
	B2,G2,R2=C2:match("(%x%x)(%x%x)(%x%x)")
	A1=C1:match("(%x%x)") R1=R1 or A1
	A2=C2:match("(%x%x)") R2=R2 or A2
	nR1=(tonumber(R1,16))  nR2=(tonumber(R2,16))
	R=acc_fac*(nR2-nR1)+nR1
	R=tohex(round(R))
	CC="&H"..R.."&"
	if B1 then
	nG1=(tonumber(G1,16))  nG2=(tonumber(G2,16))
	nB1=(tonumber(B1,16))  nB2=(tonumber(B2,16))
	G=acc_fac*(nG2-nG1)+nG1
	B=acc_fac*(nB2-nB1)+nB1
	G=tohex(round(G))
	B=tohex(round(B))
	CC="&H"..B..G..R.."&"
	end
return CC
end

function acgradhsl(C1,C2,total,l,acc)
	acc=acc or 1
	acc_fac=(l-1)^acc/(total-1)^acc
	B1,G1,R1=C1:match("(%x%x)(%x%x)(%x%x)")
	B2,G2,R2=C2:match("(%x%x)(%x%x)(%x%x)")
	H1,S1,L1=RGB_to_HSL(R1,G1,B1)
	H2,S2,L2=RGB_to_HSL(R2,G2,B2)
	if res.short then
		if H2>H1 and H2-H1>0.5 then H1=H1+1 end
		if H2<H1 and H1-H2>0.5 then H2=H2+1 end
	end
	Hdiff=(H2-H1)/(total-1)	H=H1+Hdiff*(l-1)
	Sdiff=(S2-S1)/(total-1)	S=S1+Sdiff*(l-1)
	Ldiff=(L2-L1)/(total-1)	L=L1+Ldiff*(l-1)
	R,G,B=HSL_to_RGB(H,S,L)
	R=tohex(round(R))
	G=tohex(round(G))
	B=tohex(round(B))
	NC="&H"..B..G..R.."&"
return NC
end

function RGB_to_HSL(Red,Green,Blue)
    R=(tonumber(Red,16)/255)
    G=(tonumber(Green,16)/255)
    B=(tonumber(Blue,16)/255)
    
    Min=math.min(R,G,B)
    Max=math.max(R,G,B)
    del_Max=Max-Min
    
    L=(Max+Min)/2
    
    if del_Max==0 then H=0 S=0
    else
      if L<0.5 then S=del_Max/(Max+Min)
      else S=del_Max/(2-Max-Min)
      end
      
      del_R=(((Max-R)/6)+(del_Max/2))/del_Max
      del_G=(((Max-G)/6)+(del_Max/2))/del_Max
      del_B=(((Max-B)/6)+(del_Max/2))/del_Max
      
      if R==Max then H=del_B-del_G
      elseif G==Max then H=(1/3)+del_R-del_B
      elseif B==Max then H=(2/3)+del_G-del_R
      end
      
      if H<0 then H=H+1 end
      if H>1 then H=H-1 end
    end
    return H,S,L
end

function HSL_to_RGB(H,S,L)
    if S==0 then
	R=L*255
	G=L*255
	B=L*255
    else
	if L<0.5 then var_2=L*(1+S)
	else var_2=(L+S)-(S*L)
	end
	var_1=2*L-var_2
	R=255*Hue_to_RGB(var_1,var_2,H+(1/3))
	G=255*Hue_to_RGB(var_1,var_2,H)
	B=255*Hue_to_RGB(var_1,var_2,H-(1/3))
    end
    return R,G,B
end

function Hue_to_RGB(v1,v2,vH)
    if vH<0 then vH=vH+1 end
    if vH>1 then vH=vH-1 end
    if (6*vH)<1 then return(v1+(v2-v1)*6*vH) end
    if (2*vH)<1 then return(v2) end
    if (3*vH)<2 then return(v1+(v2-v1)*((2/3)-vH)*6) end
    return(v1)
end

function tohex(num)
n1=math.floor(num/16)
n2=math.floor(num%16)
num=tohex1(n1)..tohex1(n2)
return num
end

function tohex1(num)
HEX={"1","2","3","4","5","6","7","8","9","A","B","C","D","E"}
if num<1 then num="0" elseif num>14 then num="F" else num=HEX[num] end
return num
end

function shortrot(v)
	if tonumber(v)>180 then v=v-360 end
	return v
end

function trem(tags)
	trnsfrm=""
	for t in tags:gmatch("\\t%b()") do trnsfrm=trnsfrm..t end
	tags=tags:gsub("\\t%b()","")
	return tags
end

function cleantr(tags)
	trnsfrm=""
	zerotf=""
	for t in tags:gmatch("\\t%b()") do
		if t:match("\\t%(\\") then
			zerotf=zerotf..t:match("\\t%((.*)%)$")
		else
			trnsfrm=trnsfrm..t
		end
	end
	zerotf="\\t("..zerotf..")"
	tags=tags:gsub("\\t%b()",""):gsub("^({[^}]*)}","%1"..zerotf..trnsfrm.."}"):gsub("\\t%(%)","")
	return tags
end

function duplikill(tagz)
	local tags1={"blur","be","bord","shad","xbord","xshad","ybord","yshad","fs","fsp","fscx","fscy","frz","frx","fry","fax","fay"}
	local tags2={"c","2c","3c","4c","1a","2a","3a","4a","alpha"}
	tagz=tagz:gsub("\\t%b()",function(t) return t:gsub("\\","|") end)
	for i=1,#tags1 do
	    tag=tags1[i]
	    repeat tagz,c=tagz:gsub("|"..tag.."[%d%.%-]+([^}]-)(\\"..tag.."[%d%.%-]+)","%1%2") until c==0
	    repeat tagz,c=tagz:gsub("\\"..tag.."[%d%.%-]+([^}]-)(\\"..tag.."[%d%.%-]+)","%2%1") until c==0
	end
	tagz=tagz:gsub("\\1c&","\\c&")
	for i=1,#tags2 do
	    tag=tags2[i]
	    repeat tagz,c=tagz:gsub("|"..tag.."&H%x+&([^}]-)(\\"..tag.."&H%x+&)","%1%2") until c==0
	    repeat tagz,c=tagz:gsub("\\"..tag.."&H%x+&([^}]-)(\\"..tag.."&H%x+&)","%2%1") until c==0
	end
	repeat tagz,c=tagz:gsub("\\fn[^\\}]+([^}]-)(\\fn[^\\}]+)","%2%1") until c==0
	repeat tagz,c=tagz:gsub("(\\[ibusq])%d(.-)(%1%d)","%2%3") until c==0
	repeat tagz,c=tagz:gsub("(\\an)%d(.-)(%1%d)","%3%2") until c==0
	tagz=tagz:gsub("(|i?clip%(%A-%))(.-)(\\i?clip%(%A-%))","%2%3")
	:gsub("(\\i?clip%b())(.-)(\\i?clip%b())",function(a,b,c)
	    if a:match("m") and c:match("m") or not a:match("m") and not c:match("m") then return b..c else return a..b..c end end)
	tagz=tagz:gsub("|","\\"):gsub("\\t%([^\\%)]-%)","")
	return tagz
end

function extrakill(text,o)
	local tags3={"pos","move","org","fad"}
	for i=1,#tags3 do
	    tag=tags3[i]
	    if o==2 then
	    repeat text,c=text:gsub("(\\"..tag.."[^\\}]+)([^}]-)(\\"..tag.."[^\\}]+)","%3%2") until c==0
	    else
	    repeat text,c=text:gsub("(\\"..tag.."[^\\}]+)([^}]-)(\\"..tag.."[^\\}]+)","%1%2") until c==0
	    end
	end
	repeat text,c=text:gsub("(\\pos[^\\}]+)([^}]-)(\\move[^\\}]+)","%1%2") until c==0
	repeat text,c=text:gsub("(\\move[^\\}]+)([^}]-)(\\pos[^\\}]+)","%1%2") until c==0
	return text
end

function retextmod(orig,text)
	local v1,v2,c,t2
	v1=nobrea(orig)
	c=0
	repeat
		t2=textmod(orig,text)
		v2=nobrea(text)
		c=c+1
	until v1==v2 or c==666
	if v1~=v2 then logg("文本处理出现问题...") logg(v1) logg(v2) end
	return t2
end

function textmod(orig,text)
if text=="" then return orig end
    tk={}
    tg={}
	text=text:gsub("{\\\\k0}","")
	text=tagmerge(text)
	vis=nobra(text)
	ltrmatches=re.find(vis,".")
	if not ltrmatches then logg("文本: "..text..'\n可见: '..vis)
		logg("如果你看到此消息，说明 re 模块发生了非常奇怪的问题。\n请重试或重新扫描自动加载目录。")
	end
	  for l=1,#ltrmatches do
	    table.insert(tk,ltrmatches[l].str)
	  end
	stags=text:match(STAG) or ""
	text=text:gsub(STAG,"") :gsub("{[^\\}]-}","")
	orig=orig:gsub("{([^\\}]+)}",function(c) return wrap("\\\\"..c.."|||") end)
	count=0
	for seq in orig:gmatch("[^{]-{%*?\\[^}]-}") do
	    chars,as,tak=seq:match("([^{]-){(%*?)(\\[^}]-)}")
	    pos=re.find(chars,".")
	    if pos==nil then ps=0+count else ps=#pos+count end
	    tgl={p=ps,t=tak,a=as}
	    table.insert(tg,tgl)
	    count=ps
	end
	count=0
	for seq in text:gmatch("[^{]-{%*?\\[^}]-}") do
	    chars,as,tak=seq:match("([^{]-){(%*?)(\\[^}]-)}")
	    pos=re.find(chars,".")
	    if pos==nil then ps=0+count else ps=#pos+count end
	    tgl={p=ps,t=tak,a=as}
	    table.insert(tg,tgl)
	    count=ps
	end
    newline=""
    for i=1,#tk do
	newline=newline..tk[i]
	newt=""
	for n,t in ipairs(tg) do
	    if t.p==i then newt=newt..t.a..t.t end
	end
	if newt~="" then newline=newline.."{"..as..newt.."}" end
    end
    newtext=stags..newline:gsub("(|||)(\\\\)","%1}{%2"):gsub("({[^}]-)\\\\([^\\}]-)|||","{%2}%1")
    text=newtext:gsub("{}","")
    return text
end

function fail(msg)
	local q=1
	for i=1,#failures do
		if msg==failures[i] then q=0 end
	end
	if q==1 then table.insert(failures,msg) end
end

function summary()
	if res.show then
		local MSG='未发现问题。'
		if success<seln then
			MSG=seln-success.." / "..seln.." 行未修改。\n\n"
			if #failures>0 then MSG=MSG.."可能的原因:" end
			for i=1,#failures do
				MSG=MSG.."\n> "..failures[i]
			end
			MSG=MSG.."\n\n点击的按钮: "..P
			if P=="应用" and res.tagpres~="--- presets ---" then MSG=MSG.." (预设: \""..res.tagpres.."\")" end
			MSG=MSG:gsub("\n\n+","\n\n")
		end
		msgbox(tags_used,MSG)
	end
end

function showtags(tagc) tags_used=tagc end

function msgbox(msg1,msg2,h,w)
	pres,rez=ADD({
	{width=w or 24,height=1,name='msg',class="edit",value=msg1},
	{y=1,width=w or 24,height=h or 8,class="textbox",value=msg2},
	},{"确定","复制到剪贴板","~"},{ok='确定',close='~'})
	if pres=="复制到剪贴板" then clipboard.set(rez.msg) end
end


function styleget(subs)
    styles={}
    for i=1,#subs do
        if subs[i].class=="style" then
	    table.insert(styles,subs[i])
	end
	if subs[i].class=="dialogue" then break end
    end
end

function stylechk(sn)
    for i=1,#styles do
	if sn==styles[i].name then
	    sr=styles[i]
	    if sr.name=="Default" then defaref=styles[i] end
	    break
	end
    end
    if sr==nil then t_error("样式 '"..sn.."' 不存在。",1) end
    return sr
end

function tf(val)
    if val==true then ret="true"
    elseif val==false then ret="false"
    else ret=val end
    return ret
end

function detf(txt)
    if txt=="true" then ret=true
    elseif txt=="false" then ret=false
    else ret=txt end
    return ret
end

function selcheck()
	SC=0
	for k,v in ipairs(hh_gui) do
	  if v.class=="checkbox" and v.y<10 and res[v.name] then SC=1 end
	  if v.name=="reuse" and res.reuse then SC=1 end
	  if v.name=="moretags" and res.moretags:len()>1 then SC=1 end
	end
	if SC==0 then t_error("未选择标签",1) end
end

function shiftsel2(sel,i,mode)
	if i<sel[#sel] then
		for s=1,#sel do
			if sel[s]>i then sel[s]=sel[s]+1 end
		end
	end
	if mode==1 then table.insert(sel,i+1) end
	table.sort(sel)
return sel
end

function txt_check(t1,t2,i)
	if t1~=t2 then
		fail("似乎有字符丢失或增加。\n    请查看日志获取更多详情。")
		logg("第 "..i-line0.." 行: 似乎有字符丢失或增加。\n 如果以下两行没有明显问题，可能是 re 模块故障。\n 请撤销 (Ctrl+Z) 后重试 (重复上次操作可能有效)。如果问题持续存在，请重新扫描自动加载目录。\n>> "..t1.."\n--> "..t2.."\n")
	end
end

function getpos(subs,text)
    st=nil defst=nil
    for g=1,#subs do
        if subs[g].class=="info" then
	    local k=subs[g].key
	    local v=subs[g].value
	    if k=="PlayResX" then resx=v end
	    if k=="PlayResY" then resy=v end
        end
	if resx==nil then resx=0 end
	if resy==nil then resy=0 end
        if subs[g].class=="style" then
            local s=subs[g]
	    if s.name==line.style then st=s break end
	    if s.name=="Default" then defst=s end
        end
	if subs[g].class=="dialogue" then
		if defst then st=defst else t_error("未找到样式 '"..line.style.."'。\n未找到样式 'Default'。 ",1) end
		break
	end
    end
    if st then
	acleft=st.margin_l	if line.margin_l>0 then acleft=line.margin_l end
	acright=st.margin_r	if line.margin_r>0 then acright=line.margin_r end
	acvert=st.margin_t	if line.margin_t>0 then acvert=line.margin_t end
	acalign=st.align	if text:match("\\an%d") then acalign=text:match("\\an(%d)") end
	aligntop="789" alignbot="123" aligncent="456"
	alignleft="147" alignright="369" alignmid="258"
	if alignleft:match(acalign) then horz=acleft
	elseif alignright:match(acalign) then horz=resx-acright
	elseif alignmid:match(acalign) then horz=resx/2 end
	if aligntop:match(acalign) then vert=acvert
	elseif alignbot:match(acalign) then vert=resy-acvert
	elseif aligncent:match(acalign) then vert=resy/2 end
    end
    if horz>0 and vert>0 then 
	if not text:match("^{\\") then text="{\\rel}"..text end
	text=text:gsub("^({\\[^}]-)}","%1\\pos("..horz..","..vert..")}") :gsub("\\rel","")
    end
    return text
end

--	Config Stuff	--
function saveconfig()
hydraconf="Hydra 4+ Config\n\n"
  for key,v in ipairs(hh_gui) do
    if v.class:match"edit" or v.class=="dropdown" or v.class=="coloralpha" then
      if v.name~="linetext" and v.name~="herp" and v.name~="lastags" and v.name~="exc" and not v.name:match"app" then
	hydraconf=hydraconf..v.name..":"..res[v.name].."\n"
      end
    end
    if v.class=="checkbox" and v.name~="save" then
      hydraconf=hydraconf..v.name..":"..tf(res[v.name]).."\n"
    end
  end
file=io.open(hydrakonfig,"w")
file:write(hydraconf)
file:close()
ADD({{class="label",label="配置已保存至:\n"..hydrakonfig}},{-"确定"},{close='确定'})
end

function loadconfig()
file=io.open(hydrakonfig)
    if file~=nil then
	konf=file:read("*all")
	sm=tonumber(konf:match("smode:(.-)\n"))
	io.close(file)
	for k,v in ipairs(hh1) do
	  if v.class:match"edit" or v.class=="checkbox" or v.class=="coloralpha" then
	    if konf:match(v.name) then v.value=detf(konf:match(v.name..":(.-)\n")) end
	    if hydralast and res.rem then v.value=hydralast[v.name] end
	    if v.name=="lastags" then v.value=ortags end
	  end
	end
	for k,v in ipairs(hh2) do
	  if v.class:match"edit" or v.class=="checkbox" or v.class=="dropdown" then
	    if konf:match(v.name) then v.value=detf(konf:match(v.name..":(.-)\n")) end
	    if hydralast and res.rem and tf(hydralast[v.name]) then v.value=hydralast[v.name] end
	    
	  end
	end
	for k,v in ipairs(hh3) do
	  if v.class:match"edit" or v.class=="checkbox" or v.class=="dropdown" then
	    if konf:match(v.name) then v.value=detf(konf:match(v.name..":(.-)\n")) end
	    if hydralast then 
	      if v.name=="gtype" and res.gtype then v.value=hydralast.gtype end
	      if v.name=="accel" and res.accel then v.value=hydralast.accel end
	      if v.name=="stripe" and res.stripe then v.value=hydralast.stripe end
	      if v.name=="spec" and res.spec then v.value=hydralast.spec end
	      if v.name=="middle" and tf(res.middle) then v.value=hydralast.middle end
	      if v.name=="short" and tf(res.short) then v.value=hydralast.short end
	      if v.name=="hsl" and tf(res.hsl) then v.value=hydralast.hsl end
	      if res.rem and tf(hydralast[v.name]) then v.value=hydralast[v.name] end
	    end
	  end
	end
    else sm=1
    end
end

hydraulics={"A multi-headed typesetting tool","Nine heads typeset better than one.","Eliminating the typing part of typesetting","Mass-production of typesetting tags","Hydraulic typesetting machinery","Making sure your subtitles aren't dehydrated","Making typesetting so easy that even you can do it!","A monstrous typesetting tool","A deadly typesetting beast","Building monstrous scripts with ease","For irrational typesetting wizardry","Building a Wall of Tags","The Checkbox Onslaught","HYperactively DRAstic","HYperdimensional DRAma","I can has moar tagz?","Transforming the subtitle landscape"}

function hydrahelp()
H_H=[[
For more detailed info, check http://unanimated.hostfree.pw/ts/scripts-manuals.htm#hydra

标准模式: 勾选标签，设置数值，点击 '应用'。

变换模式 'normal': 勾选标签，设置数值，按需设置 t1/t2/加速，点击 '变换'。
变换模式 'add2first': 变换将被添加到行中第一个已有的变换中。
变换模式 'add2all': 变换将被添加到行中所有已有的变换中。
变换模式 'all tag blocks': 变换将被添加到所有标签块中，无论它们是否已有变换。
从末尾计算时间: 这将从行末尾开始计算变换时间，
	因此 "500,200" 表示变换将在行结束前 500ms 开始，200ms 结束。
时间偏移/间隔: 'normal' 变换 - 每行偏移 \t 时间; 'all tag blocks' - 每个标签块偏移 \t 时间。
相对变换: 如果当前 frz30 并设置变换为 frz60，则得到 \t(\frz90)，即按 60 变换。
	这可以让不同 frz 的图层保持同步。 (对透明度/颜色无效。)

颜色的透明度可以通过两种方式设置。一种是在右侧直接设置，非常直观。另一种是使用颜色选择器。
颜色选择器同时包含颜色和透明度值，你可以只应用颜色、只应用透明度，或两者都应用。
默认情况下只使用颜色。如果你也需要透明度，请勾选 "包含透明度"。
如果你只想应用透明度而不应用颜色，请勾选旁边的 "仅透明度" 复选框。

附加标签: 你可以输入任何想要添加的额外标签。

标签位置: 这里显示第一行的文本。在需要插入标签的位置输入 * 。

标签位置预设: 这会将标签放置在指定位置，并对每行按比例处理。
自定义模式: 与基本模式一样使用星号，但可以使用更短的模式，而非整行文本。
	例如你可以使用模式 "*and"，标签将被放置在包含该模式的行中 "and" 之前的位置，
	无论其余文本是什么，也无论该词在文中出现多少次。
分段: 这允许你在给定模式之前放置标签，然后在其后恢复标签。只需输入一个模式，例如 "and"。
	你将得到类似 {\bord5}and{\bord} 的效果，或恢复到起始标签中的值。每行仅匹配第一个模式。
	自定义模式和分段可能与内联标签不能 100% 正确配合。
文本位置: 使用此选项，在标签位置字段输入数字，标签将被设置在该位置。
	0 表示行首，计数包括标点符号和空格在内的可见字符。 ("\N" 计为 2 个字符。)
	因此如果你输入 12，标签将被放置在所有选中行的前 12 个字符之后，无论文本内容。
	如果该行有 12 个或更少字符，则不会对其进行任何操作。
	更有趣的是，你可以输入负数从末尾开始计数，因此 "-1" 将放置在最后一个字符之前。
	更多信息请查看在线手册。

每行递增: '2' 表示对于每一行，所有勾选的可适用标签的值都额外增加 2。

渐变: 当前状态是起点。给定的标签是终点。加速对此有效。垂直/水平渐变需要clip。

居中渐变: '去而复返。' 给定状态将位于中间。最后一行/字符将与第一行/字符相同。
	更多关于渐变的信息，请查看在线手册。

末行: 如可能，逐行渐变的结束值将从最后选中行的起始标签中获取


特殊功能: 选择一个功能，点击 '特殊'。

fscx -> fscy: 将 fscx 的值应用到 fscy，使两者相同。

fscy -> fscx: 同上，但方向相反。

移动颜色标签到首块: 如果你使用颜色选择器的快捷键，颜色有时会被应用到行中间或末尾，因为那是文本框区域中光标所在的位置。这会将不在行首的颜色标签移动到行首。如果发现多个，它会删除所有颜色标签并使用行中的最后一个。
如果设置为快捷键会更有用，现在可以这样做。

clip <-> iclip: 在clip和iclip之间切换。 (可设为快捷键。)

清理标签: 与脚本清理中的功能相同。

按设定顺序排序标签: 这会根据设定顺序对每个标签块中的标签进行排序。

往复变换: 这将在行的当前状态和你选择的标签之间往复变换。
例如，你选择 \bord 10 和 \frz 20 并运行脚本。它会从行或样式中读取当前的 bord 和 frz 值，并根据给定间隔（时间偏移/间隔字段）创建变换。数值 500 表示将用 500ms 变换到 \bord10\frz20，然后 500ms 变换回来，再 500ms 向前变换，如此反复，持续整行的时长。这样你可以创建摇摆效果等。

选择重叠行: 这曾经是 Aegisub 自带的功能。我不知道它是否还在，但有人希望把它加入 HYDRA，所以就在这里了。它会选择与其他行有重叠的行。

clip转绘图: 使用clip的坐标创建绘图。

绘图转clip: 同上，但方向相反。

从clip获取尺寸变换: 基于矢量clip创建 \t(\fscx\fscy)。clip前两个点之间的距离标记原始尺寸；第 3 和第 4 个点之间的距离标记最终尺寸。这样你可以在理论上无需 Mocha 就能匹配视频中的线性缩放。如果你需要在绘图时看到文本，复制该行可能会有帮助。在视频中选取某个对象，在第一帧用 2 个clip点匹配其尺寸，在最后一帧再用另外 2 个点匹配。

删除线转选中标签: 将 \s1 转换为你选择的标签，并将 \s0 恢复为原始状态。这允许你同时使用多个标签的快速开/关触发器。你在编辑框中将 \s 应用于某个词或文本段落，然后可以将其转换为任何你想要的标签。

棋盘格clip: 这会创建一个棋盘格clip。不是很有用，但你可以用上面的工具将其转换为绘图。这也允许你使用缩放工具调整其大小后再转换回来，从而获得各种尺寸。

shad -> xshad+yshad: 将 \shadX 转换为 \xshadX\yshadX。 (可设为快捷键。)

从clip创建阴影: 要获得正确的阴影方向，请用矢量clip在阴影方向上标记 2 个点。距离将使用当前阴影值。阴影使用 \xshad\yshad 创建。 (可设为快捷键。)

从阴影创建3D效果: 这是此菜单中更有用的功能之一。文字和阴影之间的空间将被阴影颜色"填充"。

将行分割为3部分: 使用 '变换时间' 字段来设置第 1 行和第 3 行的时长。例如，如果你设置为 200 和 300，你的行将被复制为三段，第一段长 200ms，最后一段长 300ms，中间一段是原始时长剩余的部分。
如果你将其中任一值设为 0，你将只得到 2 行。
这在歌曲排版时很有用，例如当你想仅对前 500ms 或后 500ms 应用某些变换时，因为将变换应用于整行时可能会非常卡顿，而变换过多的行看起来也会太混乱，难以处理。


复用: 与 "重复上次" 不同，这会记住 (可变换的) 标签，但允许你使用不同的功能和限制。
如果你之前只是应用了标签，你现在可以将这些标签复用于其他行，以创建变换或渐变，
或应用到不同的图层等。例如，你可能有 5 个图层，想对第 3 和第 4 层应用某些操作。
如果你不记得上次使用了什么标签，或者不确定是否是你想要复用的标签，
同时勾选 "显示" 会告诉你。
"复用" 在你做变换或渐变时非常有用，你设置好了标签，但其他设置弄错了。
你可以修正设置然后复用这些标签。 

应用到:
你可以基于 4 个限制条件选择要将更改应用到的选中行。
当处理多层标记时，不同图层可能需要不同的标签，因此这可以简化操作，无需更改选择。
最后一个带有 "文本..." 的选项会根据你输入的任何文本模式进行限制。这是字面匹配，可以包含标签和注释，因此例如你可以仅对包含 \frz 的行应用标签。 ("文本..." 选项无效。)

"记忆" = 记住上次设置。

"重复上次" 将使用上次使用的设置运行上次使用的功能。

"保存配置" 将当前配置保存到 APPDATA 文件夹中名为 "hydra4.conf" 的文件。
]]
Pr=aegisub.dialog.display({{width=55,height=20,class="textbox",value=H_H}},{-"知道了"},{close='知道了'})
end

function cuts()
ADD=aegisub.dialog.display
ADP=aegisub.decode_path
ak=aegisub.cancel
ATAG="{[*>]?\\[^}]-}"
STAG="^{>?\\[^}]-}"
COMM="{[^\\}]-}"
end

function hydra(subs,sel)
if #sel==0 then t_error("未选择任何行",1) end
cuts()
hydrakonfig=ADP("?user").."\\hydra4.conf"
failures={}
success=0
seln=#sel
app_lay={}
app_sty={"全部样式"}
app_act={"全部Actors"}
app_eff={"全部效果"}
for i=1,#subs do
	if subs[i].class=="dialogue" then line0=i-1 break end
end
for z,i in ipairs(sel) do
	L=subs[i]
	layr=L.layer
	stl=L.style
	akt=L.actor
	eph=L.effect
	local asdf=0
	for a=1,#app_lay do if layr==app_lay[a] then asdf=1 end end
	if asdf==0 then table.insert(app_lay,layr) end
	asdf=0
	for a=1,#app_sty do if stl==app_sty[a] then asdf=1 end end
	if asdf==0 then table.insert(app_sty,stl) end
	asdf=0
	for a=1,#app_act do if akt==app_act[a] then asdf=1 end end
	if asdf==0 then table.insert(app_act,akt) end
	asdf=0
	for a=1,#app_eff do if eph==app_eff[a] then asdf=1 end end
	if asdf==0 then table.insert(app_eff,eph) end
	table.sort(app_lay,function(a,b) return a<b end)
end
table.insert(app_lay,1,"全部图层")

hr=math.random(1,#hydraulics)
oneline=subs[sel[1]]
local linetext=nobrea(oneline.text)
local alfas={"00","10","20","30","40","50","60","70","80","90","A0","B0","C0","D0","E0","F0","F8","FF"}
local preset_list={"replace \\N","replace {~}","replace {•}","--- presets ---","before last char.","custom pattern","section","every char.","every word","text position","in the middle","1/4 of text","3/4 of text","1/8 of text","3/8 of text","5/8 of text","7/8 of text"}
local spec_list={"清理标签","按设定顺序排序标签","fscx -> fscy","fscy -> fscx","clip <-> iclip","clip转绘图","绘图转clip","从clip获取尺寸变换","从clip创建阴影","shad -> xshad+yshad","从阴影创建3D效果","删除线转选中标签","移动颜色标签到首块","往复变换","棋盘格裁切","选择重叠行","将行分割为3部分"}
hh1={
	{x=0,y=0,class="label",label="      HYDRA "..script_version},
	
	{x=0,y=1,class="checkbox",name="k1",label="主要颜色:"},
	{x=1,y=1,class="coloralpha",name="c1"},
	{x=0,y=2,class="checkbox",name="k3",label="边框颜色:"},
	{x=1,y=2,class="coloralpha",name="c3"},
	{x=0,y=3,class="checkbox",name="k4",label="阴影颜色:"},
	{x=1,y=3,class="coloralpha",name="c4"},
	{x=0,y=4,class="checkbox",name="k2",label="次要颜色 (2c):"},
	{x=1,y=4,class="coloralpha",name="c2"},
	{x=0,y=5,class="checkbox",name="alfas",label="包含透明度",
	hint="从颜色选择器包含透明度。\n需要 Aegisub r7993 或更高版本。"},
	{x=1,y=5,class="checkbox",name="aonly",label="仅透明度",hint="仅使用透明度，不使用颜色"},
	{x=0,y=6,class="checkbox",name="italix",label="斜体"},
	{x=1,y=6,class="checkbox",name="bolt",label="粗体"},
	{x=0,y=7,class="checkbox",name="under",label="下划线"},
	{x=1,y=7,class="checkbox",name="strike",label="删除线"},
	
	{x=2,y=0,class="checkbox",name="bord1",label="\\bord"},
	{x=3,y=0,width=2,class="floatedit",name="bord2",value=0},
	{x=2,y=1,class="checkbox",name="shad1",label="\\shad"},
	{x=3,y=1,width=2,class="floatedit",name="shad2",value=0},
	{x=2,y=2,class="checkbox",name="fs1",label="\\fs"},
	{x=3,y=2,width=2,class="floatedit",name="fs2",value=50},
	{x=2,y=3,class="checkbox",name="spac1",label="\\f&sp"},
	{x=3,y=3,width=2,class="floatedit",name="spac2",value=1},
	{x=2,y=4,class="checkbox",name="blur1",label="\\&blur"},
	{x=3,y=4,width=2,class="floatedit",name="blur2",value=0.5},
	{x=2,y=5,class="checkbox",name="be1",label="\\be"},
	{x=3,y=5,width=2,class="floatedit",name="be2",value=1},
	{x=2,y=6,class="checkbox",name="fscx1",label="\\fscx"},
	{x=3,y=6,width=2,class="floatedit",name="fscx2",value=100},
	{x=2,y=7,class="checkbox",name="fscy1",label="\\fscy"},
	{x=3,y=7,width=2,class="floatedit",name="fscy2",value=100},
	{x=2,y=8,class="checkbox",name="fsc1",label="\\&fsc",hint="同时设置 fscx 和 fscy"},
	{x=3,y=8,width=2,class="floatedit",name="fsc2",value=100},
	
	{x=5,y=0,class="checkbox",name="xbord1",label="\\xbord"},
	{x=6,y=0,width=2,class="floatedit",name="xbord2"},
	{x=5,y=1,class="checkbox",name="ybord1",label="\\ybord"},
	{x=6,y=1,width=2,class="floatedit",name="ybord2"},
	{x=5,y=2,class="checkbox",name="xshad1",label="\\&xshad"},
	{x=6,y=2,width=2,class="floatedit",name="xshad2"},
	{x=5,y=3,class="checkbox",name="yshad1",label="\\&yshad"},
	{x=6,y=3,width=2,class="floatedit",name="yshad2"},
	{x=5,y=4,class="checkbox",name="fax1",label="\\fax"},
	{x=6,y=4,width=2,class="floatedit",name="fax2",value=0.05},
	{x=5,y=5,class="checkbox",name="fay1",label="\\fay"},
	{x=6,y=5,width=2,class="floatedit",name="fay2",value=0.05},
	{x=5,y=6,class="checkbox",name="frx1",label="\\frx"},
	{x=6,y=6,width=2,class="floatedit",name="frx2"},
	{x=5,y=7,class="checkbox",name="fry1",label="\\fry"},
	{x=6,y=7,width=2,class="floatedit",name="fry2"},
	{x=5,y=8,class="checkbox",name="frz1",label="\\fr&z"},
	{x=6,y=8,width=2,class="floatedit",name="frz2"},
	
	{x=1,y=8,class="checkbox",name="q2",label="\\&q2"},
	{x=0,y=8,class="checkbox",name="glo",label="全局淡入淡出",hint="全局淡入淡出 - 首行淡入，末行淡出"},
	{x=0,y=9,class="checkbox",name="fade",label="\\fad (淡入,淡出)"},
	{x=1,y=9,width=2,class="floatedit",name="fadin",min=0,hint="淡入时长"},
	{x=3,y=9,width=2,class="floatedit",name="fadout",min=0,hint="淡出时长"},

	{x=0,y=10,class="label",label="附加标签:"},
	{x=1,y=10,width=5,class="edit",name="moretags",value="\\"},
	{x=6,y=10,class="checkbox",name="show",label="显示  ",hint="显示正在应用的标签。\n注意: 仅显示可变换标签。"},
	{x=7,y=10,class="checkbox",name="reuse",label="复用(&u)  ",hint="复用上一次的(可变换)标签。\n可以与不同的按钮或\n'应用到'限制配合使用。"},
	{x=1,y=0,class="checkbox",name="rem",label="记忆",hint="记住上次设置"},
	{x=5,y=9,width=3,class="edit",name="lastags",value=ortags or "",hint="上次使用的标签将显示在此处"},
}

hh2={
	{x=8,y=0,class="label",name="startmode",label="启动模式"},
	{x=9,y=0,class="dropdown",name="smode",items={"1","2","3"},value="1"},
	{x=8,y=1,class="checkbox",name="arfa",label="\\&alpha"},
	{x=9,y=1,class="dropdown",name="alpha",items=alfas,value="00"},
	{x=8,y=2,class="checkbox",name="arf1",label="\\1a"},
	{x=9,y=2,class="dropdown",name="alph1",items=alfas,value="00"},
	{x=8,y=3,class="checkbox",name="arf2",label="\\2a"},
	{x=9,y=3,class="dropdown",name="alph2",items=alfas,value="00"},
	{x=8,y=4,class="checkbox",name="arf3",label="\\3a"},
	{x=9,y=4,class="dropdown",name="alph3",items=alfas,value="00"},
	{x=8,y=5,class="checkbox",name="arf4",label="\\4a"},
	{x=9,y=5,class="dropdown",name="alph4",items=alfas,value="00"},
	{x=8,y=6,class="checkbox",name="an1",label="\\an"},
	{x=9,y=6,class="dropdown",name="an2",items={"1","2","3","4","5","6","7","8","9"},value="5"},
	{x=8,y=7,width=2,class="label",label="每行递增:"},
	{x=8,y=8,width=2,class="floatedit",name="add",hint="每行递增\n适用于常规标签，\n即中间两列"},
}

hh2b={
	{x=8,y=0,class="label",name="startmode",label="启动模式"},
	{x=9,y=0,class="dropdown",name="smode",items={"1","2","3"},value="1"},
	{x=8,y=1,class="checkbox",name="arfa",label="\\&alpha"},
	{x=9,y=1,class="dropdown",name="alpha",items=alfas,value="00"},
	{x=8,y=7,width=2,class="label",label="每行递增:"},
	{x=8,y=8,width=2,class="floatedit",name="add",hint="每行递增\n适用于常规标签，\n即中间两列"},
}

hh3={
	{x=0,y=11,class="label",label="标签位置*:"},
	{x=1,y=11,width=5,class="edit",name="linetext",value=linetext,hint="在需要插入标签的位置输入 * 。"},
	{x=6,y=11,width=2,class="dropdown",name="tagpres",items=preset_list,value="--- presets ---",hint="标签位置的预设/选项"},
	
	{x=0,y=12,class="label",label="变换 t1,t2:"},
	{x=1,y=12,width=2,class="floatedit",name="trin"},
	{x=3,y=12,width=2,class="floatedit",name="trout"},
	{x=5,y=12,width=3,class="checkbox",name="tend",label="从末尾计算时间"},
	
	{x=0,y=13,class="label",label="变换模式:"},
	{x=1,y=13,width=2,class="dropdown",name="tmode",items={"normal","add2first","add2all","all tag blocks"},value="normal",hint="新建 \\t  |  添加到首个 \\t  |  添加到全部 \\t  |  添加到所有 {\\标签块}"},
	{x=3,y=13,width=2,class="checkbox",name="relative",label="相对变换",
	hint="示例:\n标签: \\frz30\n输入: 60\n结果: \\t(\\frz90)"},
	{x=5,y=13,class="label",label="       加速:"},
	
	{x=0,y=14,class="label",label="时间偏移/间隔:"},
	{x=1,y=14,width=2,class="floatedit",name="int",value=0,hint="'normal' 变换: 每行偏移 \\t 时间\n'all tag blocks': 每个标签块偏移 \\t 时间\n'back and forth transform': 间隔"},
	{x=6,y=13,width=2,class="floatedit",name="accel",value=1,min=0,hint="<1 先快后慢, >1 先慢后快"},
	
	{x=3,y=14,class="label",label="特殊功能:"},
	{x=4,y=14,width=4,class="dropdown",name="spec",items=spec_list,value="convert clip <-> iclip"},
	
	{x=0,y=15,class="label",label="渐变:"},
	{x=1,y=15,width=2,class="dropdown",name="gtype",items={"垂直渐变","水平渐变","按字符渐变","按行渐变"},value="按字符渐变",
	hint="从当前值渐变到选中值\n垂直/水平渐变需要裁切\n可与加速配合使用"},
	{x=3,y=15,width=2,class="floatedit",name="stripe",value=2,min=0,hint="垂直/水平渐变的裁切条纹宽度"},
	{x=5,y=15,class="label",label="像素/条纹"},
	{x=6,y=15,class="checkbox",name="short",label="短路径",hint="沿较短方向旋转;\n沿较短方向渐变色调"},
	{x=7,y=15,class="checkbox",name="last",label="末行",hint="如可能，从最后一行获取逐行渐变的结束值"},
	{x=8,y=15,class="checkbox",name="middle",label="居中",hint="选中标签将位于中间;\n结束将与开始相同"},
	{x=9,y=15,class="checkbox",name="hsl",label="HSL"},
	
	{x=8,y=9,class="label",label="应用到:"},
	{x=9,y=9,class="checkbox",name="exc",label="除外",hint="除选中项外全部应用\n\n('全部' 仍然应用于全部)"},
	{x=8,y=10,width=2,class="dropdown",name="applay",items=app_lay,value="全部图层"},
	{x=8,y=11,width=2,class="dropdown",name="applst",items=app_sty,value="全部样式"},
	{x=8,y=12,width=2,class="dropdown",name="applac",items=app_act,value="全部Actors"},
	{x=8,y=13,width=2,class="dropdown",name="applef",items=app_eff,value="全部效果"},
	{x=8,y=14,width=2,class="edit",name="appltx",value="文本..."},
}
	B3={"应用","变换","渐变","重复上次","特殊","保存配置","帮助","取消"}
	B4={"应用","变换","渐变","重复上次","特殊","保存配置","切换","取消"}
	B5={"应用","变换","渐变","裁切转尺寸(clip2size)","shad2xyshad","裁切转阴影(clip2shad)","删除线转标签(strike2tags)","取消"}
	buttons={{"应用","变换","重复上次","加载Medium","加载Full","取消"},
	{"应用","变换","重复上次","加载Medium","加载Full","取消"},B3,B4}
	loadconfig()
	local heads=sm*2+1
	hh_gui=hh1	loaded=sm
	progress(string.format("正在加载 Hydra 界面 1-"..heads))
	if sm==2 then for i=1,#hh2 do l=hh2[i] table.insert(hh_gui,l) end loaded=2 end
	if sm==3 then for i=1,#hh2 do l=hh2[i] table.insert(hh_gui,l) end for i=1,#hh3 do l=hh3[i] table.insert(hh_gui,l) end end
	if sm==4 then for i=1,#hh2b do l=hh2b[i] table.insert(hh_gui,l) end for i=1,#hh3 do l=hh3[i] table.insert(hh_gui,l) end end
	hh_buttons=buttons[sm]
	P,res=ADD(hh_gui,hh_buttons,{ok='应用',cancel='取消'})
	
	if P=="加载Medium" then progress("加载界面 4-5")
		for key,val in ipairs(hh_gui) do val.value=res[val.name] end
		for i=1,#hh2 do l=hh2[i] table.insert(hh_gui,l) end loaded=2
		P,res=ADD(hh_gui,buttons[2],{ok='应用',cancel='取消'})
	end
	
	if P=="加载Full" then progress("加载界面 "..(loaded+1)*2 .."-7")
		for key,val in ipairs(hh_gui) do val.value=res[val.name] end
		if loaded<2 then  for i=1,#hh2 do l=hh2[i] table.insert(hh_gui,l) end  end
		for i=1,#hh3 do l=hh3[i] table.insert(hh_gui,l) end loaded=3
		P,res=ADD(hh_gui,buttons[3],{ok='应用',cancel='取消'})
	end
	
	if P=="帮助" then progress("加载帮助界面")
		for key,val in ipairs(hh_gui) do val.value=res[val.name] end
		hhh={x=0,y=16,width=10,class="dropdown",name="herp",items={"帮助 (滚动/点击查看)",
		"标准模式: 勾选标签，设置数值，点击 '应用'。",
		"变换模式 normal: 勾选标签，设置数值，按需设置 t1/t2/加速，点击 '变换'。",
		"变换模式 add2first: 变换将被添加到行中第一个已有的变换中。",
		"变换模式 add2all: 变换将被添加到行中所有已有的变换中。",
		"变换模式 'all tag blocks': 变换将被添加到所有标签块中，无论它们是否已有变换。",
		"时间偏移/间隔: 'normal' 变换 - 每行偏移 \\t 时间; 'all tag blocks' - 每个标签块偏移 \\t 时间。",
		"相对变换: 如果当前 frz30 并设置变换为 frz60，则得到 \\t(\\frz90)，即按 60 变换。",
		"相对变换: 这可以让不同 frz 的图层保持同步。 (对透明度/颜色无效。)",
		"附加标签: 你可以输入任何想要添加的额外标签。",
		"每行递增: '2' 表示对于每一行，所有勾选的可适用标签的值都额外增加 2。",
		"标签位置: 这里显示第一行的文本。在需要插入标签的位置输入 * 。",
		"标签位置预设: 这会将标签放置在指定位置，并对每行按比例处理。",
		"渐变: 当前状态是起点。给定的标签是终点。加速对此有效。垂直/水平渐变需要裁切。",
		"居中渐变: '去而复返。' 给定状态将位于中间。最后一行/字符将与第一行/字符相同。",
		"特殊功能: 选择一个功能，点击 '特殊'。",
		"特殊功能 - 往复变换: 选择标签，设置 '间隔'。缺失的初始标签从样式中获取。",
		"特殊功能 - 从阴影创建3D效果: 使用图层创建3D效果。需要 xshad/yshad。",
		"特殊功能 - 将行分割为3部分: 使用 t1 和 t2 作为时间标记。",
		},value="帮助 (滚动/点击查看)"}
		table.insert(hh_gui,hhh)
		P,res=ADD(hh_gui,{"应用","变换","渐变","重复上次","特殊","保存配置","更多帮助","取消"},{ok='应用',cancel='取消'})
	end
	
	if P=="切换" then
		for key,val in ipairs(hh_gui) do val.value=res[val.name] end
		P,res=ADD(hh_gui,B5,{ok='应用',cancel='取消'})
		if P=="裁切转尺寸(clip2size)" then res.spec="从clip获取尺寸变换" P="特殊" end
		if P=="shad2xyshad" then res.spec="shad -> xshad+yshad" P="特殊" end
		if P=="裁切转阴影(clip2shad)" then res.spec="从clip创建阴影" P="特殊" end
		if P=="删除线转标签(strike2tags)" then res.spec="删除线转选中标签" P="特殊" end
	end
	
	if res.tmode=="normal" then tmode=1 end
	if res.tmode=="add2first" then tmode=2 end
	if res.tmode=="add2all" then tmode=3 end
	if res.tmode=="all tag blocks" then tmode=4 end
	if not tmode then tmode=1 end
	res.accel=res.accel or 1
	if res.tagpres=="in the middle" then fak=0.5 end
	if loaded>2 and res.tagpres:match("of text") then fa,fb=res.tagpres:match("(%d)/(%d)") fak=fa/fb end
	if res.aonly then res.alfas=true end
	
	if P~="重复上次" then hydralast=res Plast=P end
	if P=="更多帮助" then hydrahelp() end
	if P=="应用" then selcheck() trans=0 hh9(subs,sel) end
	if P=="变换" then selcheck() trans=1 hh9(subs,sel) end
	if P=="渐变" then selcheck() hydradient(subs,sel) end
	if P=="特殊" then sel=special(subs,sel) end
	if P=="保存配置" then saveconfig() end
	if P=="重复上次" then res=hydralast
		if not res then t_error("没有可重复的操作",1) end
		if Plast=="渐变" then hydradient(subs,sel)
		elseif Plast=="特殊" then sel=special(subs,sel)
		else hh9(subs,sel) end 
	end
	return sel
end

function col2first(subs,sel)
res=res or {}
res.spec="移动颜色标签到首块"
spec_macros(subs,sel)
end

function sortags(subs,sel)
res=res or {}
res.spec="按设定顺序排序标签"
spec_macros(subs,sel)
end

function i_clip(subs,sel)
res=res or {}
res.spec="clip <-> iclip"
spec_macros(subs,sel)
end

function shad2xy(subs,sel)
res=res or {}
res.spec="shad -> xshad+yshad"
spec_macros(subs,sel)
end

function clip2shad(subs,sel)
res=res or {}
res.spec="从clip创建阴影"
spec_macros(subs,sel)
end

function clip2mask(subs,sel)
res=res or {}
res.spec="clip转绘图"
spec_macros(subs,sel)
end

function mask2clip(subs,sel)
res=res or {}
res.spec="绘图转clip"
spec_macros(subs,sel)
end

function spec_macros(subs,sel)
cuts()
loaded=1
failures={}
success=0
special(subs,sel)
return sel
end

function arrowshift(subs,sel)
    for x,i in ipairs(sel) do
        local l=subs[i]
        local t=l.text
	local back
	if t:match'{switch}$' then back=true else back=false end
	t=t:gsub("(\\t)(%b())",function(a,b) return a..b:gsub("\\","/") end):gsub("\\([Nnh])","/%1")
	if t:match('>\\') then
		if back then t=t:gsub("^([^\\]*)>","%1"):gsub("(\\[^\\]*)>",">%1")
		else t=t:gsub(">(\\[^\\]*)","%1>"):gsub(">$","") end
	else
		if back then t=t:gsub("(\\[^\\]+)$",">%1"):gsub("^>","")
		else t=t:gsub("^([^\\]*)","%1>"):gsub(">$","") end
	end
	t=t:gsub("(\\t)(%b())",function(a,b) return a..b:gsub("/","\\") end):gsub("/([Nnh])","\\%1")
	if t~=l.text then
		l.text=t
		subs[i]=l
	end
    end
end

function shapeshifter(subs,sel,sh)
    Sh="{"..sh.."}"
    for x,i in ipairs(sel) do
        local l=subs[i]
        local t=l.text
	local mark="( *%S+ *)"
	if l.effect:match(sh) or l.comment or t:match'{switch}$' then mark="(.)" end
	if not t:match '\\p1' then
		t=t:gsub("%b{}",function(b) return b:gsub(" ","_SP_") end)
		if t:match(Sh) then
			t=t:gsub(Sh.."(%b{})","%1"..Sh):gsub(Sh..mark,"%1"..Sh):gsub(Sh.."$","")
		else
			t,c=t:gsub("^(%b{}"..mark..")","%1"..Sh)
			if c==0 then t=t:gsub(mark,"%1"..Sh,1) end
			t=t:gsub(Sh.."$","")
		end
		t=t:gsub("%b{}",function(b) return b:gsub("_SP_"," ") end)
	end
	if t~=l.text then
		l.text=t
		subs[i]=l
	end
    end
end

function bellshift(subs,sel)
	shapeshifter(subs,sel,"•")
	return sel
end

function waveshift(subs,sel)
	shapeshifter(subs,sel,"~")
	return sel
end

function comment(subs,sel)
    for x,i in ipairs(sel) do
        line=subs[i]
        line.comment=not line.comment
	subs[i]=line
    end
    return sel
end

aegisub.register_macro(script_name,script_description,hydra)
aegisub.register_macro(": HELP : / HYDRA","HYDRA",hydrahelp)
aegisub.register_macro(": Non-GUI macros :/HYDRA: 按设定顺序排序标签","按设定顺序排序标签",sortags)
aegisub.register_macro(": Non-GUI macros :/HYDRA: 移动颜色标签到首块","移动颜色标签到首块",col2first)
aegisub.register_macro(": Non-GUI macros :/HYDRA: clip <-> iclip","clip <-> iclip",i_clip)
aegisub.register_macro(": Non-GUI macros :/HYDRA: shad -> xshad+yshad","shad -> xshad+yshad",shad2xy)
aegisub.register_macro(": Non-GUI macros :/HYDRA: 从clip创建阴影","从 clip 创建阴影",clip2shad)
aegisub.register_macro(": Non-GUI macros :/HYDRA: clip转绘图","clip转绘图",clip2mask)
aegisub.register_macro(": Non-GUI macros :/HYDRA: 绘图转clip","绘图转clip",mask2clip)
aegisub.register_macro(": Non-GUI macros :/HYDRA: 铃铛(Bell)移位器","铃铛(Bell)移位",bellshift)
aegisub.register_macro(": Non-GUI macros :/HYDRA: 波浪(Wave)移位器","波浪(Wave)移位",waveshift)
aegisub.register_macro(": Non-GUI macros :/HYDRA: 箭头(Arrow)移位器","箭头(Arrow)移位",arrowshift)
aegisub.register_macro(": Non-GUI macros :/HYDRA: 注释开关","注释/取消注释行",comment)