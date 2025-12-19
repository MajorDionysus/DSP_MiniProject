% main_script.m - 演示和测试核心功能，并生成《天空之城》波形

% 1. 设置参数
fs = 8192; % 采样频率 (Hz)
scale = 'C'; % 调号
base_rhythm = 0.5; % 基础节拍时长 (四分音符的时长，这里假设为 0.5 秒)

% 泛音系数 (模拟乐器音色)
% 默认: 基频, 2倍频, 3倍频, 4倍频
harmonics_coeffs = [1, 0.2, 0.1, 0.05]; 

% 衰减率 (影响音符的衰减速度，值越大衰减越快)
decay_rate = 5; % 调整此值以改变听感

% 2. 简谱数据 - 《天空之城》 (部分)
% 格式: [tone, noctave, rising, rhythm_multiplier]
% tone: 1-7 (数字音符) 或 0 (休止符)
% noctave: 0 (中音), 1 (高八度), -1 (低八度)
% rising: 1 (升), -1 (降), 0 (无)
% rhythm_multiplier: 节拍乘数 (例如: 1=四分音符, 0.5=八分音符, 2=二分音符)

% 示例: 5. 6. 7. 1' 7 6 5 4 3 4 5 5. 4. 3. 2. 1.
% 假设: 5. (附点四分音符) = 1.5 * base_rhythm
%       5 (四分音符) = 1 * base_rhythm
%       5- (二分音符) = 2 * base_rhythm

% 简化编码: [tone, noctave, rising, duration_in_seconds]
% 5. (中音G, 1.5拍)
% 6. (中音A, 1.5拍)
% 7. (中音B, 1.5拍)
% 1' (高音C, 1拍)
% 7 (中音B, 1拍)
% 6 (中音A, 1拍)
% 5 (中音G, 1拍)
% 4 (中音F, 1拍)
% 3 (中音E, 1拍)
% 4 (中音F, 1拍)
% 5 (中音G, 2拍)
% 5. (中音G, 1.5拍)
% 4. (中音F, 1.5拍)
% 3. (中音E, 1.5拍)
% 2. (中音D, 1.5拍)
% 1. (中音C, 4拍)

score_data = [
    5, 0, 0, 1.5 * base_rhythm;
    6, 0, 0, 1.5 * base_rhythm;
    7, 0, 0, 1.5 * base_rhythm;
    1, 1, 0, 1 * base_rhythm;
    7, 0, 0, 1 * base_rhythm;
    6, 0, 0, 1 * base_rhythm;
    5, 0, 0, 1 * base_rhythm;
    4, 0, 0, 1 * base_rhythm;
    3, 0, 0, 1 * base_rhythm;
    4, 0, 0, 1 * base_rhythm;
    5, 0, 0, 2 * base_rhythm; % 假设这里是二分音符
    5, 0, 0, 1.5 * base_rhythm;
    4, 0, 0, 1.5 * base_rhythm;
    3, 0, 0, 1.5 * base_rhythm;
    2, 0, 0, 1.5 * base_rhythm;
    1, 0, 0, 4 * base_rhythm; % 假设这里是全音符
];

% 3. 生成音乐波形
music_wave = gen_music(score_data, scale, fs, harmonics_coeffs, decay_rate);

% 4. 播放和保存
disp('正在播放音乐...');
sound(music_wave, fs);

% 保存为 WAV 文件
output_filename = 'Castle_in_the_Sky.wav';
audiowrite(output_filename, music_wave, fs);
disp(['音乐已保存到: ', output_filename]);

% 5. 绘制波形图 (取前几秒)
figure;
plot(music_wave(1:min(end, fs * 5))); % 绘制前5秒的波形
title('生成的音乐波形 (前5秒)');
xlabel('采样点');
ylabel('幅度');
grid on;

% 6. 绘制单个音符的衰减效果 (以第一个音符为例)
first_note_wave = gen_wave(tone2freq(score_data(1,1), scale, score_data(1,2), score_data(1,3)), score_data(1,4), fs, harmonics_coeffs, decay_rate / score_data(1,4));
t_note = linspace(0, score_data(1,4), length(first_note_wave));
figure;
plot(t_note, first_note_wave);
title('第一个音符的波形 (含衰减)');
xlabel('时间 (秒)');
ylabel('幅度');
grid on;
