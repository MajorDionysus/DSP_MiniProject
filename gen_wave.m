function waves = gen_wave(freq, rhythm, fs, harmonics_coeffs, decay_rate)
% GEN_WAVE 生成单个音符的波形数据
%
% 输入:
%   freq: 音符频率 (Hz)。如果为 0，则生成休止符。
%   rhythm: 音符持续时长 (秒)。
%   fs: 采样频率 (Hz)。
%   harmonics_coeffs: 泛音系数向量，例如 [基频系数, 2倍频系数, 3倍频系数, ...]
%   decay_rate: 衰减率。例如 1/rhythm。

    if nargin < 4
        % 默认泛音系数 (基频, 2倍频, 3倍频, 4倍频) - 模仿文档中的例子
        harmonics_coeffs = [1, 0.1, 0.05, 0.05];
    end
    
    if nargin < 5
        % 默认衰减率
        decay_rate = 1 / rhythm;
    end

    % 1. 生成时间向量
    % 确保时间向量的长度是整数，并且包含 rhythm 秒的数据
    t = linspace(0, rhythm, round(fs * rhythm));
    
    % 2. 处理休止符
    if freq == 0
        waves = zeros(size(t));
        return;
    end

    % 3. 生成带泛音的波形
    y = zeros(size(t));
    for k = 1:length(harmonics_coeffs)
        % k 是泛音的倍数 (k=1 是基频)
        y = y + harmonics_coeffs(k) * sin(2 * pi * k * freq * t);
    end
    
    % 归一化波形，使其最大振幅为 1
    y = y / max(abs(y));

    % 4. 应用指数衰减包络
    % waves = y .* exp(-t / (rhythm * decay_rate_factor));
    % 文档中的衰减函数是 waves = y.*exp(-x/rhythm)，这里 x 对应 t
    waves = y .* exp(-t * decay_rate);
    
    % 再次归一化，防止衰减后幅度过小，但保持相对衰减形状
    % 这一步是可选的，但为了确保播放音量，通常会进行归一化
    waves = waves / max(abs(waves));
end
