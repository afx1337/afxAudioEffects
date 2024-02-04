declare name "afxTransient";
declare author "afx";
declare copyright "2019";
declare version "0.2";

import("stdfaust.lib");

amount_attack = hslider("[1]Attack",0,-1,1,.01) : *(8) : si.smoo;
amount_sustain = hslider("[2]Sustain",0,-1,1,.01) : *(8) : si.smoo;
t_att = hslider("[3]Attack timing [unit: msec]",12,0,80,.5) /(1000) : si.smoo;
t_rel = hslider("[4]Release timing [unit: msec]",100,10,250,1) : /(1000): si.smoo;
lookahead = hslider("[5]Lookahead [unit: msec]",0,0,20,1) : /(1000);
N = int(ma.SR*lookahead);
t_rel_min = 10/1000;


afxTransient(x,y) = out with
{
  // compute mid signal
  m = (x+y)/2;
  // compute envelopes with different attack and release times
  env1 = m : an.amp_follower_ar(0,t_att);
  env2 = m : an.amp_follower_ar(t_att,t_att);
  env3 = m : an.amp_follower_ar(0,max(1.5*t_att,t_rel_min));
  env4 = m : an.amp_follower_ar(0,max(1.5*t_att,t_rel_min)+t_rel);
  // create attack and sustain envelope
  envAtt = ba.linear2db(1+env1-env2);
  envSus = ba.linear2db(1+env4-env3);
  // create final scaling factor f
  f = ba.db2linear(envAtt*amount_attack+envSus*amount_sustain);
  // (optionally delay signal for lookahead effect)
  // then scale signal by factor f
  out = (x: @(N))*f,(y: @(N))*f;
};

process(x,y) = afxTransient(x,y);