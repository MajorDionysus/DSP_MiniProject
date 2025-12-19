function music_wave = gen_music(score_data, scale, fs, harmonics_coeffs, decay_rate)
% GEN_MUSIC 将简谱数据转换成完整的音乐波形
%
% 输入:
%   score_data: 简谱数据矩阵。每行代表一个音符: [tone, noctave, rising, rhythm]
%               tone: 1-7 (数字音符) 或 0 (休止符)
%               noctave: 0 (中音), 正数 (高八度), 负数 (低八度)
%               rising: 1 (升), -1 (降), 0 (无)
%               rhythm: 持续时长 (秒)
%   scale: 调号 ('C', 'D', 'E', 'F', 'G', 'A', 'B')
%   fs: 采样频率 (Hz)
%   harmonics_coeffs: 泛音系数向量
%   decay_rate: 衰减率

    if nargin < 4
        % 默认泛音系数 (基频, 2倍频, 3倍频, 4倍频)
        harmonics_coeffs = [1, 0.1, 0.05, 0.05];
    end
    
    if nargin < 5
        % 默认衰减率
        decay_rate = 1; % 衰减因子 1/rhythm * decay_rate
    end

    music_wave = [];
    
    num_notes = size(score_data, 1);
    
    for i = 1:num_notes
        % 提取当前音符参数
        tone = score_data(i, 1);
        noctave = score_data(i, 2);
        rising = score_data(i, 3);
        rhythm = score_data(i, 4);
        
        % 1. 计算频率
        freq = tone2freq(tone, scale, noctave, rising);
        
        % 2. 生成波形
        % gen_wave 内部会处理 freq=0 的情况 (休止符)
        note_wave = gen_wave(freq, rhythm, fs, harmonics_coeffs, decay_rate / rhythm);
        
        % 3. 连接波形
        music_wave = [music_wave, note_wave];
    end
    
    % 最终归一化整个音乐波形，防止溢出
    if ~isempty(music_wave)
        music_wave = music_wave / max(abs(music_wave));
    end
end
