function score_data = parse_score_string(score_string, base_rhythm)
% PARSE_SCORE_STRING 将简化的乐谱字符串解析为数据矩阵
%
% 输入:
%   score_string: 简化的乐谱字符串，例如 '5. 6. 7. 1'' 7 6 5 4 3 4 5-'
%   base_rhythm: 基础节拍时长 (秒)，例如四分音符的时长。
%
% 输出:
%   score_data: 简谱数据矩阵。每行: [tone, noctave, rising, rhythm]

    if nargin < 2
        base_rhythm = 0.5; % 默认四分音符 0.5 秒
    end

    % 移除多余空格并按空格分割音符
    notes = strsplit(strtrim(score_string), ' ');
    notes = notes(~cellfun('isempty', notes)); % 移除空字符串

    score_data = [];

    for i = 1:length(notes)
        note_str = notes{i};
        
        % 默认值
        tone = 0;
        noctave = 0;
        rising = 0;
        rhythm = base_rhythm;
        
        % 1. 解析音符数字 (tone)
        tone_match = regexp(note_str, '^[0-7]', 'match', 'once');
        if isempty(tone_match)
            warning('无法解析音符: %s. 跳过.', note_str);
            continue;
        end
        tone = str2double(tone_match);
        
        % 2. 解析升降调 (#/b)
        rising_match = regexp(note_str, '[#b]', 'match', 'once');
        if ~isempty(rising_match)
            if strcmp(rising_match, '#')
                rising = 1;
            elseif strcmp(rising_match, 'b')
                rising = -1;
            end
        end
        
        % 3. 解析八度 ('/,,)
        octave_match = regexp(note_str, '''|,,', 'match');
        if ~isempty(octave_match)
            for j = 1:length(octave_match)
                if strcmp(octave_match{j}, '''')
                    noctave = noctave + 1; % 高八度
                elseif strcmp(octave_match{j}, ',,')
                    noctave = noctave - 2; % 低两个八度 (文档中提到两个点)
                end
            end
            % 简谱中一个点是低八度，两个点是低两个八度。这里假设 ',' 是低八度
            % 考虑到简谱习惯，我们简化为 ' 对应高八度，', 对应低八度
            % 实际实现中，我们只处理 ' (高八度) 和 , (低八度)
            low_octave_match = regexp(note_str, ',', 'match');
            if ~isempty(low_octave_match)
                noctave = noctave - length(low_octave_match);
            end
            high_octave_match = regexp(note_str, '''', 'match');
            if ~isempty(high_octave_match)
                noctave = noctave + length(high_octave_match);
            end
        end
        
        % 4. 解析时值 (. / - / _)
        % 默认四分音符 (1拍)
        
        % 增时线 '-' (二分音符，2拍)
        if contains(note_str, '-')
            rhythm = rhythm * 2;
        end
        
        % 减时线 '_' (八分音符，0.5拍)
        if contains(note_str, '_')
            rhythm = rhythm * 0.5;
        end
        
        % 附点 '.' (延长一半，1.5拍)
        if contains(note_str, '.')
            rhythm = rhythm * 1.5;
        end
        
        % 检查是否有多个时值符号，如果有，则需要更复杂的解析，这里简化处理
        % 例如: 5-- 是全音符，这里只处理一个符号
        
        % 5. 组装数据
        score_data = [score_data; tone, noctave, rising, rhythm];
    end
end
