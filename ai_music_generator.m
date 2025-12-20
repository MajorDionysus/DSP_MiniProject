function score_string = ai_music_generator(style, length_in_bars)
% AI_MUSIC_GENERATOR 简单的AI音乐生成器
%
% 输入:
%   style: 音乐风格 ('happy', 'sad', 'relax', 'epic', 'random')
%   length_in_bars: 小节数 (默认4)
%
% 输出:
%   score_string: 生成的简谱字符串

    if nargin < 1
        style = 'random';
    end
    
    if nargin < 2
        length_in_bars = 4;
    end
    
    % 音符选择概率根据风格调整
    switch lower(style)
        case 'happy'
            % 欢快的风格 - 大调，较多高音
            note_probs = [0.05, 0.15, 0.05, 0.15, 0.25, 0.15, 0.15, 0.05]; % 1-7 + 休止符
            octave_bias = 0.3; % 偏向高八度
            scale_options = {'C', 'G', 'F'};
            rhythm_options = {'', '.', '_', '- '};
            rhythm_probs = [0.5, 0.2, 0.2, 0.1];
            chord_prob = 0.2; % 和弦概率
            
        case 'sad'
            % 悲伤的风格 - 小调，较多低音
            note_probs = [0.20, 0.10, 0.15, 0.10, 0.15, 0.10, 0.10, 0.10];
            octave_bias = -0.3; % 偏向低八度
            scale_options = {'A', 'D', 'E'};
            rhythm_options = {'- ', '. ', '', '_ '};
            rhythm_probs = [0.3, 0.3, 0.3, 0.1];
            chord_prob = 0.1;
            
        case 'relax'
            % 放松的风格 - 平稳，较多长音
            note_probs = [0.10, 0.15, 0.15, 0.15, 0.15, 0.15, 0.10, 0.05];
            octave_bias = 0;
            scale_options = {'C', 'F', 'G'};
            rhythm_options = {'- ', '. ', '', ''};
            rhythm_probs = [0.4, 0.3, 0.2, 0.1];
            chord_prob = 0.15;
            
        case 'epic'
            % 史诗风格 - 跨度大，动态强
            note_probs = [0.05, 0.10, 0.15, 0.10, 0.20, 0.15, 0.20, 0.05];
            octave_bias = 0;
            scale_options = {'C', 'D', 'G'};
            rhythm_options = {'- ', '', '_ ', '.. '};
            rhythm_probs = [0.3, 0.3, 0.2, 0.2];
            chord_prob = 0.25;
            
        otherwise % 'random' 或其他
            % 随机风格
            note_probs = ones(1, 8) / 8;
            octave_bias = 0;
            scale_options = {'C', 'D', 'E', 'F', 'G', 'A', 'B'};
            rhythm_options = {'', '.', '_', '-', '..', '__'};
            rhythm_probs = ones(1, length(rhythm_options)) / length(rhythm_options);
            chord_prob = 0.15;
    end
    
    % 随机选择调号
    scale_idx = randi(length(scale_options));
    scale = scale_options{scale_idx};
    
    % 生成音乐片段
    notes_per_bar = 4; % 每小节4拍
    total_notes = length_in_bars * notes_per_bar;
    
    score_cells = {};
    current_bar = 1;
    notes_in_current_bar = 0;
    
    % 预分配数组
    note_choices = 0:7;
    
    while length(score_cells) < total_notes
        % 决定是否生成和弦
        if rand() < chord_prob && notes_in_current_bar < notes_per_bar - 1
            % 生成和弦
            chord_size = randi([2, 3]); % 2或3个音的和弦
            
            % 选择和弦根音（使用randsample确保有统计工具箱也能工作）
            rand_idx = randperm(7, 1);
            root_note = rand_idx;
            
            % 构建和弦（简单的大三和弦或小三和弦）
            if rand() > 0.5
                % 大三和弦 1-3-5
                chord_notes = [root_note, mod(root_note+1, 7)+1, mod(root_note+3, 7)+1];
            else
                % 小三和弦 1-b3-5
                chord_notes = [root_note, mod(root_note, 7)+1, mod(root_note+3, 7)+1];
            end
            
            % 如果和弦音符中有0，调整
            chord_notes(chord_notes == 0) = 7;
            
            % 决定八度
            octave = '';
            if octave_bias > 0 && rand() < octave_bias
                octave = '''';
            elseif octave_bias < 0 && rand() < -octave_bias
                octave = ',';
            end
            
            % 决定时值
            rhythm_idx = min(length(rhythm_probs), ceil(rand() * length(rhythm_probs)));
            rhythm = rhythm_options{rhythm_idx};
            
            % 构建和弦字符串
            chord_str = '(';
            for j = 1:length(chord_notes)
                chord_str = [chord_str, num2str(chord_notes(j))];
                if j < length(chord_notes)
                    chord_str = [chord_str, ','];
                end
            end
            chord_str = [chord_str, ')', octave, rhythm];
            
            score_cells{end+1} = chord_str;
            notes_in_current_bar = notes_in_current_bar + 1;
            
        else
            % 生成单音
            % 选择音符（包括休止符0） - 使用概率分布
            rand_val = rand();
            cum_prob = cumsum(note_probs);
            note_idx = find(rand_val <= cum_prob, 1);
            note = note_choices(note_idx);
            
            if note == 0
                % 休止符
                score_cells{end+1} = '0 ';
                notes_in_current_bar = notes_in_current_bar + 1;
            else
                % 决定八度
                octave = '';
                if octave_bias > 0 && rand() < octave_bias
                    octave = '''';
                elseif octave_bias < 0 && rand() < -octave_bias
                    octave = ',';
                end
                
                % 决定时值
                rhythm_idx = min(length(rhythm_probs), ceil(rand() * length(rhythm_probs)));
                rhythm = rhythm_options{rhythm_idx};
                
                % 构建音符字符串
                note_str = [num2str(note), octave, rhythm];
                score_cells{end+1} = note_str;
                notes_in_current_bar = notes_in_current_bar + 1;
            end
        end
        
        % 检查是否完成当前小节
        if notes_in_current_bar >= notes_per_bar
            current_bar = current_bar + 1;
            notes_in_current_bar = 0;
            
            % 添加小节分隔符（可选）
            if current_bar <= length_in_bars
                score_cells{end+1} = '| ';
            end
        end
    end
    
    % 转换为字符串
    score_string = strjoin(score_cells, ' ');
    
    % 添加风格说明注释
    style_names = containers.Map({'happy', 'sad', 'relax', 'epic', 'random'}, ...
                                 {'欢快', '悲伤', '放松', '史诗', '随机'});
    
    if isKey(style_names, lower(style))
        style_chinese = style_names(lower(style));
    else
        style_chinese = '随机';
    end
    
    score_string = sprintf('%% AI生成的%s风格音乐 (调号: %s)\n%s', ...
                          style_chinese, scale, score_string);
end