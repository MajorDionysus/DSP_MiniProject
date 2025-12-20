%% --- 修正版 gen_wave ---
function waves = gen_wave(freq,rhythm,fs,harmonics_coeffs,decay_rate,amp_scale)
if nargin<4||isempty(harmonics_coeffs), harmonics_coeffs=[1 0.12 0.06 0.03]; end
if nargin<5||isempty(decay_rate), decay_rate=1/rhythm; end
if nargin<6, amp_scale=1; end

N=max(1,round(fs*rhythm));
t=(0:N-1)/fs;
if freq<=0, waves=zeros(1,N); return; end

y=zeros(1,N);
for k=1:length(harmonics_coeffs)
    fk=k*freq;
    freq_decay=exp(-0.002*fk);
    y=y+harmonics_coeffs(k)*freq_decay*sin(2*pi*fk*t);
end

y=y/(max(abs(y))+eps);
env=exp(-(decay_rate+0.003*freq)*t);
waves = y.*env;

attack_len=max(1,round(0.01*fs));
attack=linspace(0,1,attack_len);
waves(1:attack_len)=waves(1:attack_len).*attack;
waves = tanh(0.9*waves);
waves = amp_scale*waves/(max(abs(waves))+eps);
end