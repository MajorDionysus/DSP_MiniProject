function [harmonics_coeffs, decay_rate, description] = instrument_presets(instrument_name)
% INSTRUMENT_PRESETS 返回预设乐器的音色参数
%
% 输入:
%   instrument_name: 乐器名称 ('piano', 'violin', 'flute', 'guitar', 'organ', 'bell', 'strings')
%
% 输出:
%   harmonics_coeffs: 泛音系数向量
%   decay_rate: 衰减率
%   description: 乐器描述

    if nargin < 1
        instrument_name = 'piano';
    end
    
    switch lower(instrument_name)
        case 'piano'
            % 钢琴 - 丰富的泛音，快速衰减
            harmonics_coeffs = [1.0, 0.3, 0.2, 0.1, 0.05, 0.02];
            decay_rate = 8;
            description = '钢琴 - 丰富的谐波，清脆的音色';
            
        case 'violin'
            % 小提琴 - 较强的二次和三次谐波
            harmonics_coeffs = [1.0, 0.6, 0.4, 0.2, 0.1, 0.05];
            decay_rate = 3;
            description = '小提琴 - 温暖而富有表现力的音色';
            
        case 'flute'
            % 长笛 - 简单的谐波结构，主要是基频
            harmonics_coeffs = [1.0, 0.1, 0.05, 0.02, 0.01, 0.005];
            decay_rate = 2;
            description = '长笛 - 纯净而柔和的音色';
            
        case 'guitar'
            % 吉他 - 特定的谐波模式
            harmonics_coeffs = [1.0, 0.4, 0.3, 0.2, 0.15, 0.1, 0.05];
            decay_rate = 4;
            description = '吉他 - 温暖而共鸣的音色';
            
        case 'organ'
            % 风琴 - 丰富的奇次谐波
            harmonics_coeffs = [1.0, 0.1, 0.8, 0.1, 0.6, 0.05, 0.4];
            decay_rate = 10;
            description = '风琴 - 饱满而持续的音色';
            
        case 'bell'
            % 钟声 - 非谐波泛音
            harmonics_coeffs = [1.0, 0.8, 0.6, 0.9, 0.4, 0.7, 0.3];
            decay_rate = 15;
            description = '钟声 - 明亮而持久的泛音';
            
        case 'strings'
            % 弦乐合奏
            harmonics_coeffs = [1.0, 0.5, 0.3, 0.2, 0.15, 0.1, 0.05];
            decay_rate = 5;
            description = '弦乐合奏 - 饱满而和谐的音色';
            
        case 'electronic'
            % 电子音色
            harmonics_coeffs = [1.0, 0.7, 0.5, 0.9, 0.3, 0.6, 0.2];
            decay_rate = 6;
            description = '电子音色 - 现代合成器效果';
            
        case 'xylophone'
            % 木琴
            harmonics_coeffs = [1.0, 0.9, 0.1, 0.05, 0.02];
            decay_rate = 12;
            description = '木琴 - 明亮而短暂的音色';
            
        otherwise
            % 默认钢琴音色
            harmonics_coeffs = [1.0, 0.3, 0.2, 0.1, 0.05, 0.02];
            decay_rate = 8;
            description = '默认钢琴音色';
    end
    
    % 归一化泛音系数，确保基频最大
    harmonics_coeffs = harmonics_coeffs / max(harmonics_coeffs);
    
    % 确保返回的系数有4个（对应4个spinner）
    if length(harmonics_coeffs) < 4
        harmonics_coeffs = [harmonics_coeffs, zeros(1, 4 - length(harmonics_coeffs))];
    else
        harmonics_coeffs = harmonics_coeffs(1:4);
    end
end