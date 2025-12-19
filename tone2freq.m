function freq = tone2freq(tone, scale, noctave, rising)
% TONE2FREQ 计算数字简谱音符的频率
%
% 输入:
%   tone: 数字音符 (1-7)。0表示休止符，返回频率为0。
%   scale: 调号 ('C', 'D', 'E', 'F', 'G', 'A', 'B')。
%   noctave: 八度数。0为中音，正数高八度，负数低八度。
%   rising: 升降调。1为升 (#)，-1为降 (b)，0为无升降调。
%
% 输出:
%   freq: 对应的频率 (Hz)。

    if tone == 0
        freq = 0;
        return;
    end

    % 1. 定义C调中音组的基本频率 (Hz) 和半音间隔
    % 频率数据来自项目文档表2 (C调频率)
    C_freqs = [261.5, 293.5, 329.5, 349, 391.5, 440, 494];
    
    % 12平均律半音比率
    semitone_ratio = 2^(1/12);

    % 2. 确定基准音符 '1' 的频率 (根据调号 scale)
    % C调音符到索引的映射: 'C'->1, 'D'->2, ..., 'B'->7
    scale_map = containers.Map({'C', 'D', 'E', 'F', 'G', 'A', 'B'}, 1:7);
    
    if ~isKey(scale_map, scale)
        error('无效的调号输入。请使用 ''C'', ''D'', ''E'', ''F'', ''G'', ''A'', ''B''。');
    end
    
    % scale_index 是 C 调中作为主音 '1' 的音符的索引
    scale_index = scale_map(scale);
    
    % base_freq_1 是当前调号下，中音组 '1' 的频率
    base_freq_1 = C_freqs(scale_index);

    % 3. 计算当前音符 (tone) 相对于主音 '1' 的半音数
    % C调中，音符1-7相对于1的半音间隔:
    % 1(C): 0, 2(D): 2, 3(E): 4, 4(F): 5, 5(G): 7, 6(A): 9, 7(B): 11
    semitone_intervals = [0, 2, 4, 5, 7, 9, 11];
    
    % tone_index 是当前音符 (1-7) 的索引
    tone_index = tone;
    
    % semitones_from_1 是当前音符相对于中音组 '1' 的半音数
    semitones_from_1 = semitone_intervals(tone_index);

    % 4. 考虑升降调 (rising)
    % rising = 1 升半音, rising = -1 降半音
    total_semitones = semitones_from_1 + rising;

    % 5. 计算最终频率
    % 频率 = 基准音 '1' 的频率 * (半音比率 ^ 总半音数) * (2 ^ 八度数)
    freq = base_freq_1 * (semitone_ratio ^ total_semitones) * (2 ^ noctave);
end
