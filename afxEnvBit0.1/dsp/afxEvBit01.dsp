declare name "afxEnvBit";
declare author "afx";
declare copyright "2024";
declare version "0.1";

import("stdfaust.lib");

depth = hslider("[1]Depth [unit:bit]",16,0,24,.05) : si.smoo;
dither = hslider("[2]Dither",.75,0,1,.05) : si.smoo; 

t_att = hslider("[3]Attack timing [unit: msec]",0,0,80,.5) /(1000) : si.smoo;
t_rel = hslider("[4]Release timing [unit: msec]",2,2,250,1) : /(1000): si.smoo;
env_imp = hslider("[5]Envelope impact [unit:%]",100,0,100,.5) : /(100): si.smoo;
lookahead = hslider("[6]Lookahead [unit: msec]",0,0,20,1) : /(1000);
N = int(ma.SR*lookahead);
drywet = hslider("[7]Dry/wet [unit:%]",100,0,100,.5) : /(100): si.smoo;

afxWetdry(wet,dry,ratio) = (min(1,ratio)*wet) + ((1-ratio)*dry);

afxEffect(in) = afxWetdry(dithered,bitcrushed,dither) : min(1) : max(-1)
  with {
    f = 2^depth/2;
    inScaled = in*f;
    bitcrushed = rint(inScaled)/f;
    inFloor = floor(inScaled)/f;
    inCeil = ceil(inScaled)/f;
    relDiff = (in - inFloor)/(inCeil-inFloor); // scaled between 0 and 1
    decision = (no.noise+1)/2 > relDiff; // 1 -> Floor; 0 -> Ceil
    dithered = decision*inFloor+(1-decision)*inCeil;
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
    out2 = afxWetdry(afxEffect(x2/fac)*fac,x2,drywet),afxWetdry(afxEffect(y2/fac)*fac,y2,drywet);
};

process(x,y) = afxEnv(x,y);
