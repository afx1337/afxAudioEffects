declare name "afxEnvTanh";
declare author "afx";
declare copyright "2024";
declare version "0.1";

import("stdfaust.lib");

clip = hslider("[1]Clip [unit:dB]",0,-48,0,.01) : ba.db2linear : si.smoo;
makeup = hslider("[2]Makeup [unit:%]",100,0,100,.5) : /(100) : si.smoo;
t_att = hslider("[3]Attack timing [unit: msec]",0,0,80,.5) /(1000) : si.smoo;
t_rel = hslider("[4]Release timing [unit: msec]",2,2,250,1) : /(1000): si.smoo;
env_imp = hslider("[5]Envelope impact [unit:%]",100,0,100,.5) : /(100): si.smoo;
lookahead = hslider("[6]Lookahead [unit: msec]",0,0,20,1) : /(1000);
N = int(ma.SR*lookahead);
drywet = hslider("[7]Dry/wet [unit:%]",100,0,100,.5) : /(100): si.smoo;

afxWetdry(wet,dry,ratio) = (min(1,ratio)*wet) + ((1-ratio)*dry);

afxTanh(in) = out with
{
	x = min(max(-3,in/clip),3);
	xx = x*x;
  	out = x*(27+xx)/(27+9*xx)* (clip*(1-makeup) + makeup);
};

afxEnv(x,y) = out2 with
{
    // compute mid signal
    m = (x+y)/2;
    // compute envelope and factor
    env1 = m : an.amp_follower_ar(t_att,t_rel);
    fac = afxWetdry(max(env1,.0001),1,env_imp);
    // lookahead
    x2 = x : @(N);
    y2 = y : @(N);
    // normalize, tanh, scale
    out2 = afxWetdry(afxTanh(x2/fac)*fac,x2,drywet),afxWetdry(afxTanh(y2/fac)*fac,y2,drywet);
};

process(x,y) = afxEnv(x,y);
