%% --- 修正版 gen_music ---
function music_wave=gen_music(score_data,scale,fs,harmonics,decay_rate)
if nargin<4, harmonics=[1 0.1 0.05]; end
if nargin<5, decay_rate=1; end

music_wave=[];
i=1; N=size(score_data,1);

while i<=N
    tone=score_data(i,1);
    octave=score_data(i,2);
    rising=score_data(i,3);
    rhythm=score_data(i,4);
    cid=score_data(i,5);

    if cid>0
        idx=i;
        chord_wave=zeros(1,round(fs*rhythm));
        while idx<=N && score_data(idx,5)==cid
            f=tone2freq(score_data(idx,1),scale,score_data(idx,2),score_data(idx,3));
            if f>0
                amp_scale=0.25; % 弱和音默认降低音量
                w=gen_wave(f,rhythm,fs,harmonics,decay_rate/rhythm,amp_scale);
                chord_wave=chord_wave+w(1:length(chord_wave));
            end
            idx=idx+1;
        end
        chord_wave=chord_wave/(max(abs(chord_wave))+eps);
        music_wave=[music_wave, chord_wave];
        i=idx;
    else
        f=tone2freq(tone,scale,octave,rising);
        w=gen_wave(f,rhythm,fs,harmonics,decay_rate/rhythm,1);
        music_wave=[music_wave, w];
        i=i+1;
    end
end

music_wave=music_wave/(max(abs(music_wave))+eps);
end
