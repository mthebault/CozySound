var u=!0,x=null;function C(f,h,d){function e(b,r,k,d,a,e){var l=c();l?("undefined"===typeof e&&(e=u),r&&("undefined"!=typeof l.onload?l.onload=function(){"200"==l.status||"206"==l.status?(l.fileSize=a||l.getResponseHeader("Content-Length"),r(l)):k&&k();l=x}:l.onreadystatechange=function(){4==l.readyState&&("200"==l.status||"206"==l.status?(l.fileSize=a||l.getResponseHeader("Content-Length"),r(l)):k&&k(),l=x)}),l.open("GET",b,e),l.overrideMimeType&&l.overrideMimeType("text/plain; charset=x-user-defined"),d&&l.setRequestHeader("Range",
"bytes="+d[0]+"-"+d[1]),l.setRequestHeader("If-Modified-Since","Sat, 1 Jan 1970 00:00:00 GMT"),l.send(x)):k&&k()}function c(){var b=x;window.XMLHttpRequest?b=new XMLHttpRequest:window.ActiveXObject&&(b=new ActiveXObject("Microsoft.XMLHTTP"));return b}function a(b,r){var k=c();k&&(r&&("undefined"!=typeof k.onload?k.onload=function(){"200"==k.status&&r(this);k=x}:k.onreadystatechange=function(){4==k.readyState&&("200"==k.status&&r(this),k=x)}),k.open("HEAD",b,u),k.send(x))}function b(b,r){var k,a;function c(b){var g=
~~(b[0]/k)-a;b=~~(b[1]/k)+1+a;0>g&&(g=0);b>=blockTotal&&(b=blockTotal-1);return[g,b]}function h(a,c){for(;q[a[0]];)if(a[0]++,a[0]>a[1]){c&&c();return}for(;q[a[1]];)if(a[1]--,a[0]>a[1]){c&&c();return}var v=[a[0]*k,(a[1]+1)*k-1];e(b,function(b){parseInt(b.getResponseHeader("Content-Length"),10)==r&&(a[0]=0,a[1]=blockTotal-1,v[0]=0,v[1]=r-1);b={data:b.W||b.responseText,offset:v[0]};for(var g=a[0];g<=a[1];g++)q[g]=b;f+=v[1]-v[0]+1;c&&c()},d,v,l,!!c)}var l,f=0,m=new D("",0,r),q=[];k=k||2048;a="undefined"===
typeof a?0:a;blockTotal=~~((r-1)/k)+1;for(var n in m)m.hasOwnProperty(n)&&"function"===typeof m[n]&&(this[n]=m[n]);this.a=function(b){var g;h(c([b,b]));g=q[~~(b/k)];if("string"==typeof g.data)return g.data.charCodeAt(b-g.offset)&255;if("unknown"==typeof g.data)return IEBinary_getByteAt(g.data,b-g.offset)};this.N=function(){return f};this.f=function(b,g){h(c(b),g)}}(function(){a(f,function(g){g=parseInt(g.getResponseHeader("Content-Length"),10)||-1;h(new b(f,g))})})()}
function D(f,h,d){var e=f,c=h||0,a=0;this.P=function(){return e};"string"==typeof f?(a=d||e.length,this.a=function(b){return e.charCodeAt(b+c)&255}):"unknown"==typeof f&&(a=d||IEBinary_getLength(e),this.a=function(b){return IEBinary_getByteAt(e,b+c)});this.n=function(b,g){for(var a=Array(g),c=0;c<g;c++)a[c]=this.a(b+c);return a};this.j=function(){return a};this.d=function(b,g){return 0!=(this.a(b)&1<<g)};this.Q=function(b){b=this.a(b);return 127<b?b-256:b};this.r=function(b,g){var a=g?(this.a(b)<<
8)+this.a(b+1):(this.a(b+1)<<8)+this.a(b);0>a&&(a+=65536);return a};this.S=function(b,g){var a=this.r(b,g);return 32767<a?a-65536:a};this.h=function(b,a){var c=this.a(b),k=this.a(b+1),d=this.a(b+2),e=this.a(b+3),c=a?(((c<<8)+k<<8)+d<<8)+e:(((e<<8)+d<<8)+k<<8)+c;0>c&&(c+=4294967296);return c};this.R=function(b,a){var c=this.h(b,a);return 2147483647<c?c-4294967296:c};this.q=function(b){var a=this.a(b),c=this.a(b+1);b=this.a(b+2);a=((a<<8)+c<<8)+b;0>a&&(a+=16777216);return a};this.c=function(b,a){for(var c=
[],k=b,d=0;k<b+a;k++,d++)c[d]=String.fromCharCode(this.a(k));return c.join("")};this.e=function(b,a,c){b=this.n(b,a);switch(c.toLowerCase()){case "utf-16":case "utf-16le":case "utf-16be":a=c;var d,e=0,h=1;c=0;d=Math.min(d||b.length,b.length);254==b[0]&&255==b[1]?(a=u,e=2):255==b[0]&&254==b[1]&&(a=!1,e=2);a&&(h=0,c=1);a=[];for(var f=0;e<d;f++){var l=b[e+h],p=(l<<8)+b[e+c],e=e+2;if(0==p)break;else 216>l||224<=l?a[f]=String.fromCharCode(p):(l=(b[e+h]<<8)+b[e+c],e+=2,a[f]=String.fromCharCode(p,l))}b=
new String(a.join(""));b.g=e;break;case "utf-8":d=0;e=Math.min(e||b.length,b.length);239==b[0]&&(187==b[1]&&191==b[2])&&(d=3);h=[];for(c=0;d<e&&!(a=b[d++],0==a);c++)128>a?h[c]=String.fromCharCode(a):194<=a&&224>a?(f=b[d++],h[c]=String.fromCharCode(((a&31)<<6)+(f&63))):224<=a&&240>a?(f=b[d++],p=b[d++],h[c]=String.fromCharCode(((a&255)<<12)+((f&63)<<6)+(p&63))):240<=a&&245>a&&(f=b[d++],p=b[d++],l=b[d++],a=((a&7)<<18)+((f&63)<<12)+((p&63)<<6)+(l&63)-65536,h[c]=String.fromCharCode((a>>10)+55296,(a&1023)+
56320));b=new String(h.join(""));b.g=d;break;default:e=[];h=h||b.length;for(d=0;d<h;){c=b[d++];if(0==c)break;e[d-1]=String.fromCharCode(c)}b=new String(e.join(""));b.g=d}return b};this.M=function(a){return String.fromCharCode(this.a(a))};this.Z=function(){return window.btoa(e)};this.L=function(a){e=window.atob(a)};this.f=function(a,c){c()}}document.write("<script type='text/vbscript'>\r\nFunction IEBinary_getByteAt(strBinary, iOffset)\r\n\tIEBinary_getByteAt = AscB(MidB(strBinary,iOffset+1,1))\r\nEnd Function\r\nFunction IEBinary_getLength(strBinary)\r\n\tIEBinary_getLength = LenB(strBinary)\r\nEnd Function\r\n\x3c/script>\r\n");(function(f){f.FileAPIReader=function(h){return function(d,e){var c=new FileReader;c.onload=function(a){e(new D(a.target.result))};c.readAsBinaryString(h)}}})(this);(function(f){f.k={i:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",A:function(h){for(var d="",e,c,a,b,g,r,k=0;k<h.length;)e=h[k++],c=h[k++],a=h[k++],b=e>>2,e=(e&3)<<4|c>>4,g=(c&15)<<2|a>>6,r=a&63,isNaN(c)?g=r=64:isNaN(a)&&(r=64),d=d+Base64.i.charAt(b)+Base64.i.charAt(e)+Base64.i.charAt(g)+Base64.i.charAt(r);return d}};f.Base64=f.k;f.k.encodeBytes=f.k.A})(this);(function(f){var h=f.s={},d={},e=[0,7];h.w=function(c){delete d[c]};h.v=function(){d={}};h.D=function(c,a,b){b=b||{};(b.dataReader||C)(c,function(g){g.f(e,function(){var e="ftypM4A"==g.c(4,7)?ID4:"ID3"==g.c(0,3)?ID3v2:ID3v1;e.o(g,function(){var k=b.tags,h=e.p(g,k),k=d[c]||{},f;for(f in h)h.hasOwnProperty(f)&&(k[f]=h[f]);d[c]=k;a&&a()})})})};h.B=function(c){if(!d[c])return x;var a={},b;for(b in d[c])d[c].hasOwnProperty(b)&&(a[b]=d[c][b]);return a};h.C=function(c,a){return!d[c]?x:d[c][a]};f.ID3=f.s;
h.loadTags=h.D;h.getAllTags=h.B;h.getTag=h.C;h.clearTags=h.w;h.clearAll=h.v})(this);(function(f){var h=f.t={},d="Blues;Classic Rock;Country;Dance;Disco;Funk;Grunge;Hip-Hop;Jazz;Metal;New Age;Oldies;Other;Pop;R&B;Rap;Reggae;Rock;Techno;Industrial;Alternative;Ska;Death Metal;Pranks;Soundtrack;Euro-Techno;Ambient;Trip-Hop;Vocal;Jazz+Funk;Fusion;Trance;Classical;Instrumental;Acid;House;Game;Sound Clip;Gospel;Noise;AlternRock;Bass;Soul;Punk;Space;Meditative;Instrumental Pop;Instrumental Rock;Ethnic;Gothic;Darkwave;Techno-Industrial;Electronic;Pop-Folk;Eurodance;Dream;Southern Rock;Comedy;Cult;Gangsta;Top 40;Christian Rap;Pop/Funk;Jungle;Native American;Cabaret;New Wave;Psychadelic;Rave;Showtunes;Trailer;Lo-Fi;Tribal;Acid Punk;Acid Jazz;Polka;Retro;Musical;Rock & Roll;Hard Rock;Folk;Folk-Rock;National Folk;Swing;Fast Fusion;Bebob;Latin;Revival;Celtic;Bluegrass;Avantgarde;Gothic Rock;Progressive Rock;Psychedelic Rock;Symphonic Rock;Slow Rock;Big Band;Chorus;Easy Listening;Acoustic;Humour;Speech;Chanson;Opera;Chamber Music;Sonata;Symphony;Booty Bass;Primus;Porn Groove;Satire;Slow Jam;Club;Tango;Samba;Folklore;Ballad;Power Ballad;Rhythmic Soul;Freestyle;Duet;Punk Rock;Drum Solo;Acapella;Euro-House;Dance Hall".split(";");
h.o=function(d,c){var a=d.j();d.f([a-128-1,a],c)};h.p=function(e){var c=e.j()-128;if("TAG"==e.c(c,3)){var a=e.c(c+3,30).replace(/\0/g,""),b=e.c(c+33,30).replace(/\0/g,""),g=e.c(c+63,30).replace(/\0/g,""),h=e.c(c+93,4).replace(/\0/g,"");if(0==e.a(c+97+28))var k=e.c(c+97,28).replace(/\0/g,""),f=e.a(c+97+29);else k="",f=0;e=e.a(c+97+30);return{version:"1.1",title:a,artist:b,album:g,year:h,comment:k,track:f,genre:255>e?d[e]:""}}return{}};f.ID3v1=f.t})(this);(function(f){function h(a,b){var c=b.a(a),d=b.a(a+1),e=b.a(a+2);return b.a(a+3)&127|(e&127)<<7|(d&127)<<14|(c&127)<<21}var d=f.G={};d.b={};d.frames={BUF:"Recommended buffer size",CNT:"Play counter",COM:"Comments",CRA:"Audio encryption",CRM:"Encrypted meta frame",ETC:"Event timing codes",EQU:"Equalization",GEO:"General encapsulated object",IPL:"Involved people list",LNK:"Linked information",MCI:"Music CD Identifier",MLL:"MPEG location lookup table",PIC:"Attached picture",POP:"Popularimeter",REV:"Reverb",
RVA:"Relative volume adjustment",SLT:"Synchronized lyric/text",STC:"Synced tempo codes",TAL:"Album/Movie/Show title",TBP:"BPM (Beats Per Minute)",TCM:"Composer",TCO:"Content type",TCR:"Copyright message",TDA:"Date",TDY:"Playlist delay",TEN:"Encoded by",TFT:"File type",TIM:"Time",TKE:"Initial key",TLA:"Language(s)",TLE:"Length",TMT:"Media type",TOA:"Original artist(s)/performer(s)",TOF:"Original filename",TOL:"Original Lyricist(s)/text writer(s)",TOR:"Original release year",TOT:"Original album/Movie/Show title",
TP1:"Lead artist(s)/Lead performer(s)/Soloist(s)/Performing group",TP2:"Band/Orchestra/Accompaniment",TP3:"Conductor/Performer refinement",TP4:"Interpreted, remixed, or otherwise modified by",TPA:"Part of a set",TPB:"Publisher",TRC:"ISRC (International Standard Recording Code)",TRD:"Recording dates",TRK:"Track number/Position in set",TSI:"Size",TSS:"Software/hardware and settings used for encoding",TT1:"Content group description",TT2:"Title/Songname/Content description",TT3:"Subtitle/Description refinement",
TXT:"Lyricist/text writer",TXX:"User defined text information frame",TYE:"Year",UFI:"Unique file identifier",ULT:"Unsychronized lyric/text transcription",WAF:"Official audio file webpage",WAR:"Official artist/performer webpage",WAS:"Official audio source webpage",WCM:"Commercial information",WCP:"Copyright/Legal information",WPB:"Publishers official webpage",WXX:"User defined URL link frame",AENC:"Audio encryption",APIC:"Attached picture",COMM:"Comments",COMR:"Commercial frame",ENCR:"Encryption method registration",
EQUA:"Equalization",ETCO:"Event timing codes",GEOB:"General encapsulated object",GRID:"Group identification registration",IPLS:"Involved people list",LINK:"Linked information",MCDI:"Music CD identifier",MLLT:"MPEG location lookup table",OWNE:"Ownership frame",PRIV:"Private frame",PCNT:"Play counter",POPM:"Popularimeter",POSS:"Position synchronisation frame",RBUF:"Recommended buffer size",RVAD:"Relative volume adjustment",RVRB:"Reverb",SYLT:"Synchronized lyric/text",SYTC:"Synchronized tempo codes",
TALB:"Album/Movie/Show title",TBPM:"BPM (beats per minute)",TCOM:"Composer",TCON:"Content type",TCOP:"Copyright message",TDAT:"Date",TDLY:"Playlist delay",TENC:"Encoded by",TEXT:"Lyricist/Text writer",TFLT:"File type",TIME:"Time",TIT1:"Content group description",TIT2:"Title/songname/content description",TIT3:"Subtitle/Description refinement",TKEY:"Initial key",TLAN:"Language(s)",TLEN:"Length",TMED:"Media type",TOAL:"Original album/movie/show title",TOFN:"Original filename",TOLY:"Original lyricist(s)/text writer(s)",
TOPE:"Original artist(s)/performer(s)",TORY:"Original release year",TOWN:"File owner/licensee",TPE1:"Lead performer(s)/Soloist(s)",TPE2:"Band/orchestra/accompaniment",TPE3:"Conductor/performer refinement",TPE4:"Interpreted, remixed, or otherwise modified by",TPOS:"Part of a set",TPUB:"Publisher",TRCK:"Track number/Position in set",TRDA:"Recording dates",TRSN:"Internet radio station name",TRSO:"Internet radio station owner",TSIZ:"Size",TSRC:"ISRC (international standard recording code)",TSSE:"Software/Hardware and settings used for encoding",
TYER:"Year",TXXX:"User defined text information frame",UFID:"Unique file identifier",USER:"Terms of use",USLT:"Unsychronized lyric/text transcription",WCOM:"Commercial information",WCOP:"Copyright/Legal information",WOAF:"Official audio file webpage",WOAR:"Official artist/performer webpage",WOAS:"Official audio source webpage",WORS:"Official internet radio station homepage",WPAY:"Payment",WPUB:"Publishers official webpage",WXXX:"User defined URL link frame"};var e={title:["TIT2","TT2"],artist:["TPE1",
"TP1"],album:["TALB","TAL"],year:["TYER","TYE"],comment:["COMM","COM"],track:["TRCK","TRK"],genre:["TCON","TCO"],picture:["APIC","PIC"],lyrics:["USLT","ULT"]},c=["title","artist","album","track"];d.o=function(a,b){a.f([0,h(6,a)],b)};d.p=function(a,b){var g=0,f=a.a(g+3);if(4<f)return{version:">2.4"};var k=a.a(g+4),v=a.d(g+5,7),s=a.d(g+5,6),w=a.d(g+5,5),l=h(g+6,a),g=g+10;if(s)var p=a.h(g,u),g=g+(p+4);var f={version:"2."+f+"."+k,major:f,revision:k,flags:{unsynchronisation:v,extended_header:s,experimental_indicator:w},
size:l},m;if(v)m={};else{for(var l=l-10,v=a,k=b,s={},w=f.major,p=[],q=0,n;n=(k||c)[q];q++)p=p.concat(e[n]||[n]);for(k=p;g<l;){p=x;q=v;n=g;var z=x;switch(w){case 2:m=q.c(n,3);var t=q.q(n+3),y=6;break;case 3:m=q.c(n,4);t=q.h(n+4,u);y=10;break;case 4:m=q.c(n,4),t=h(n+4,q),y=10}if(""==m)break;g+=y+t;if(!(0>k.indexOf(m))&&(2<w&&(z={message:{Y:q.d(n+8,6),K:q.d(n+8,5),V:q.d(n+8,4)},m:{T:q.d(n+8+1,7),H:q.d(n+8+1,3),J:q.d(n+8+1,2),F:q.d(n+8+1,1),z:q.d(n+8+1,0)}}),n+=y,z&&z.m.z&&(h(n,q),n+=4,t-=4),!z||!z.m.F))m in
d.b?p=d.b[m]:"T"==m[0]&&(p=d.b["T*"]),p=p?p(n,t,q,z):void 0,p={id:m,size:t,description:m in d.frames?d.frames[m]:"Unknown",data:p},m in s?(s[m].id&&(s[m]=[s[m]]),s[m].push(p)):s[m]=p}m=s}for(var A in e)if(e.hasOwnProperty(A)){a:{t=e[A];"string"==typeof t&&(t=[t]);y=0;for(g=void 0;g=t[y];y++)if(g in m){a=m[g].data;break a}a=void 0}a&&(f[A]=a)}for(var B in m)m.hasOwnProperty(B)&&(f[B]=m[B]);return f};f.ID3v2=d})(this);(function(){function f(d){var e;switch(d){case 0:e="iso-8859-1";break;case 1:e="utf-16";break;case 2:e="utf-16be";break;case 3:e="utf-8"}return e}var h="32x32 pixels 'file icon' (PNG only);Other file icon;Cover (front);Cover (back);Leaflet page;Media (e.g. lable side of CD);Lead artist/lead performer/soloist;Artist/performer;Conductor;Band/Orchestra;Composer;Lyricist/text writer;Recording Location;During recording;During performance;Movie/video screen capture;A bright coloured fish;Illustration;Band/artist logotype;Publisher/Studio logotype".split(";");
ID3v2.b.APIC=function(d,e,c,a,b){b=b||"3";a=d;var g=f(c.a(d));switch(b){case "2":var r=c.c(d+1,3);d+=4;break;case "3":case "4":r=c.e(d+1,e-(d-a),g),d+=1+r.g}b=c.a(d,1);b=h[b];g=c.e(d+1,e-(d-a),g);d+=1+g.g;return{format:r.toString(),type:b,description:g.toString(),data:c.n(d,a+e-d)}};ID3v2.b.COMM=function(d,e,c){var a=d,b=f(c.a(d)),g=c.c(d+1,3),h=c.e(d+4,e-4,b);d+=4+h.g;d=c.e(d,a+e-d,b);return{language:g,X:h.toString(),text:d.toString()}};ID3v2.b.COM=ID3v2.b.COMM;ID3v2.b.PIC=function(d,e,c,a){return ID3v2.b.APIC(d,
e,c,a,"2")};ID3v2.b.PCNT=function(d,e,c){return c.O(d)};ID3v2.b.CNT=ID3v2.b.PCNT;ID3v2.b["T*"]=function(d,e,c){var a=f(c.a(d));return c.e(d+1,e-1,a).toString()};ID3v2.b.TCON=function(d,e,c){return ID3v2.b["T*"].apply(this,arguments).replace(/^\(\d+\)/,"")};ID3v2.b.TCO=ID3v2.b.TCON;ID3v2.b.USLT=function(d,e,c){var a=d,b=f(c.a(d)),g=c.c(d+1,3),h=c.e(d+4,e-4,b);d+=4+h.g;d=c.e(d,a+e-d,b);return{language:g,I:h.toString(),U:d.toString()}};ID3v2.b.ULT=ID3v2.b.USLT})();(function(f){function h(c,a,b,d){var f=c.h(a,u);if(0==f)d();else{var k=c.c(a+4,4);-1<["moov","udta","meta","ilst"].indexOf(k)?("meta"==k&&(a+=4),c.f([a+8,a+8+8],function(){h(c,a+8,f-8,d)})):c.f([a+(k in e.l?0:f),a+f+8],function(){h(c,a+f,b,d)})}}function d(c,a,b,g,f){f=void 0===f?"":f+"  ";for(var k=b;k<b+g;){var h=a.h(k,u);if(0==h)break;var s=a.c(k+4,4);if(-1<["moov","udta","meta","ilst"].indexOf(s)){"meta"==s&&(k+=4);d(c,a,k+8,h-8,f);break}if(e.l[s]){var w=a.q(k+16+1),l=e.l[s],w=e.types[w];if("trkn"==
s)c[l[0]]=a.a(k+16+11),c.count=a.a(k+16+13);else{var s=k+16+4+4,p=h-16-4-4;switch(w){case "text":c[l[0]]=a.e(s,p,"UTF-8");break;case "uint8":c[l[0]]=a.r(s);break;case "jpeg":case "png":c[l[0]]={m:"image/"+w,data:a.n(s,p)}}}}k+=h}}var e=f.u={};e.types={"0":"uint8",1:"text",13:"jpeg",14:"png",21:"uint8"};e.l={"\u00a9alb":["album"],"\u00a9art":["artist"],"\u00a9ART":["artist"],aART:["artist"],"\u00a9day":["year"],"\u00a9nam":["title"],"\u00a9gen":["genre"],trkn:["track"],"\u00a9wrt":["composer"],"\u00a9too":["encoder"],
cprt:["copyright"],covr:["picture"],"\u00a9grp":["grouping"],keyw:["keyword"],"\u00a9lyr":["lyrics"],"\u00a9gen":["genre"]};e.o=function(c,a){c.f([0,7],function(){h(c,0,c.j(),a)})};e.p=function(c){var a={};d(a,c,0,c.j());return a};f.ID4=f.u})(this);