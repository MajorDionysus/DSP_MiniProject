classdef MusicScoreApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        
        % 左侧面板 - 乐谱输入
        LeftPanel                       matlab.ui.container.Panel
        ScoreLabel                      matlab.ui.control.Label
        ScoreTextArea                   matlab.ui.control.TextArea
        
        % 参数设置面板
        ParameterPanel                  matlab.ui.container.Panel
        ScaleLabel                      matlab.ui.control.Label
        ScaleDropdown                   matlab.ui.control.DropDown
        InstrumentLabel                 matlab.ui.control.Label
        InstrumentDropdown              matlab.ui.control.DropDown
        FSLabel                         matlab.ui.control.Label
        FSSpinner                       matlab.ui.control.Spinner
        % MODIFIED: 移除 BaseRhythmLabel 和 BaseRhythmSpinner
        % ADDED: 新的节拍设置控件
        BPMLabel                        matlab.ui.control.Label
        BPMSpinner                      matlab.ui.control.Spinner
        TimeSigLabel                    matlab.ui.control.Label
        TimeSigDropdown                 matlab.ui.control.DropDown
        
        % 泛音系数设置
        HarmonicsLabel                  matlab.ui.control.Label
        Harmonic1Label                  matlab.ui.control.Label
        Harmonic1Spinner                matlab.ui.control.Spinner
        Harmonic2Label                  matlab.ui.control.Label
        Harmonic2Spinner                matlab.ui.control.Spinner
        Harmonic3Label                  matlab.ui.control.Label
        Harmonic3Spinner                matlab.ui.control.Spinner
        Harmonic4Label                  matlab.ui.control.Label
        Harmonic4Spinner                matlab.ui.control.Spinner
        
        % 衰减率设置
        DecayRateLabel                  matlab.ui.control.Label
        DecayRateSpinner                matlab.ui.control.Spinner
        
        % AI音乐生成面板
        AIPanel                         matlab.ui.container.Panel
        AILabel                         matlab.ui.control.Label
        AIStyleDropdown                 matlab.ui.control.DropDown
        AILengthLabel                   matlab.ui.control.Label
        AILengthSpinner                 matlab.ui.control.Spinner
        GenerateAIButton                matlab.ui.control.Button
        
        % 按钮面板
        ButtonPanel                     matlab.ui.container.Panel
        GenerateButton                  matlab.ui.control.Button
        PlayButton                      matlab.ui.control.Button
        SaveButton                      matlab.ui.control.Button
        ClearButton                     matlab.ui.control.Button
        
        % 右侧面板 - 图形显示
        RightPanel                      matlab.ui.container.Panel
        WaveformAxes                    matlab.ui.control.UIAxes
        SpectrumAxes                    matlab.ui.control.UIAxes
        
        % 状态栏
        StatusLabel                     matlab.ui.control.Label
        
        % 数据存储
        CurrentMusicWave                double
        CurrentFS                       double
    end

    methods (Access = private)

        function createComponents(app)
            % 创建主窗口 - 移除不存在的图标引用
            app.UIFigure = uifigure('Name', '🎵 数字简谱音乐生成器 (Digital Score Music Generator)', ...
                'NumberTitle', 'off', 'Resize', 'on', 'Position', [100 100 1200 700], ...
                'Color', [0.96 0.96 0.96]);
            
            % 主网格布局
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1.2x', '1x'};
            app.GridLayout.RowHeight = {'1x', 'fit'};
            app.GridLayout.Padding = [15 15 15 15];
            app.GridLayout.ColumnSpacing = 15;
            app.GridLayout.RowSpacing = 15;
            app.GridLayout.BackgroundColor = [0.96 0.96 0.96];

            % ========== 左侧面板 ==========
            app.LeftPanel = uipanel(app.GridLayout, 'Title', '🎼 乐谱输入与参数设置', ...
                'FontSize', 12, 'FontWeight', 'bold', ...
                'BackgroundColor', [1 1 1], ...
                'ForegroundColor', [0.2 0.2 0.5], ...
                'BorderType', 'line', ...
                'HighlightColor', [0.3 0.3 0.7]);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;
            
            leftLayout = uigridlayout(app.LeftPanel);
            leftLayout.ColumnWidth = {'1x'};
            leftLayout.RowHeight = {'fit', '1x', 'fit', 'fit', 'fit', 'fit'};
            leftLayout.Padding = [15 15 15 15];
            leftLayout.RowSpacing = 12;
            leftLayout.BackgroundColor = [1 1 1];

            % 乐谱输入标签和文本框
            app.ScoreLabel = uilabel(leftLayout, ...
                'Text', '📝 简谱输入 (示例: 5. 6. 7. 1'' 7 6 5 4 3 4 5- 或 (135) (246))', ...
                'FontSize', 11, 'FontWeight', 'bold', ...
                'FontColor', [0.2 0.2 0.5]);
            app.ScoreLabel.Layout.Row = 1;
            app.ScoreLabel.Layout.Column = 1;
            
            app.ScoreTextArea = uitextarea(leftLayout, ...
                'BackgroundColor', [0.98 0.98 1], ...
                'FontName', 'Consolas', ...
                'FontSize', 11, ...
                'Placeholder', '输入简谱，每行一段。数字表示音高，.表示低八度，''表示高八度，-表示延长一拍，(135)表示和弦');
            app.ScoreTextArea.Layout.Row = 2;
            app.ScoreTextArea.Layout.Column = 1;
            app.ScoreTextArea.Value = ["% 示例: 小星星"; ...
                                       "1 1 5 5 6 6 5-"; ...
                                       "4 4 3 3 2 2 1-"; ...
                                       "5 5 4 4 3 3 2-"; ...
                                       "5 5 4 4 3 3 2-"; ...
                                       "1 1 5 5 6 6 5-"; ...
                                       "4 4 3 3 2 2 1-"];

            % 参数设置面板
            app.ParameterPanel = uipanel(leftLayout, ...
                'Title', '⚙️ 参数设置', ...
                'FontSize', 11, 'FontWeight', 'bold', ...
                'BackgroundColor', [1 1 1], ...
                'ForegroundColor', [0.2 0.2 0.5]);
            app.ParameterPanel.Layout.Row = 3;
            app.ParameterPanel.Layout.Column = 1;
            
            paramLayout = uigridlayout(app.ParameterPanel);
            paramLayout.ColumnWidth = {'fit', '1x', 'fit', '1x'};
            paramLayout.RowHeight = repmat({'fit'}, 1, 7);
            paramLayout.Padding = [10 10 10 10];
            paramLayout.RowSpacing = 8;
            paramLayout.ColumnSpacing = 12;
            paramLayout.BackgroundColor = [1 1 1];

            % 调号
            app.ScaleLabel = uilabel(paramLayout, ...
                'Text', '🎵 调号 (Scale):', ...
                'FontColor', [0.3 0.3 0.3]);
            app.ScaleLabel.Layout.Row = 1;
            app.ScaleLabel.Layout.Column = 1;
            
            app.ScaleDropdown = uidropdown(paramLayout, ...
                'Items', {'C', 'D', 'E', 'F', 'G', 'A', 'B'}, ...
                'Value', 'C', ...
                'BackgroundColor', [0.98 0.98 1]);
            app.ScaleDropdown.Layout.Row = 1;
            app.ScaleDropdown.Layout.Column = 2;

            % 乐器音色预设
            app.InstrumentLabel = uilabel(paramLayout, ...
                'Text', '🎻 乐器音色:', ...
                'FontColor', [0.3 0.3 0.3]);
            app.InstrumentLabel.Layout.Row = 1;
            app.InstrumentLabel.Layout.Column = 3;
            
            app.InstrumentDropdown = uidropdown(paramLayout, ...
                'Items', {'钢琴', '小提琴', '长笛', '吉他', '风琴', '钟声', '弦乐合奏', '电子音色', '木琴'}, ...
                'Value', '钢琴', ...
                'ValueChangedFcn', createCallbackFcn(app, @InstrumentDropdownValueChanged, true), ...
                'BackgroundColor', [0.98 0.98 1]);
            app.InstrumentDropdown.Layout.Row = 1;
            app.InstrumentDropdown.Layout.Column = 4;

            % 采样频率
            app.FSLabel = uilabel(paramLayout, ...
                'Text', '📊 采样频率 (Hz):', ...
                'FontColor', [0.3 0.3 0.3]);
            app.FSLabel.Layout.Row = 2;
            app.FSLabel.Layout.Column = 1;
            
            app.FSSpinner = uispinner(paramLayout, ...
                'Value', 8192, 'Limits', [4096 48000], 'Step', 1024, ...
                'BackgroundColor', [0.98 0.98 1]);
            app.FSSpinner.Layout.Row = 2;
            app.FSSpinner.Layout.Column = 2;

            % MODIFIED: 原“基础节拍”位置，现替换为“速度(BPM)”
            app.BPMLabel = uilabel(paramLayout, ...
                'Text', '🎶 速度 (BPM):', ...
                'FontColor', [0.3 0.3 0.3]);
            app.BPMLabel.Layout.Row = 2;
            app.BPMLabel.Layout.Column = 3;
            
            app.BPMSpinner = uispinner(paramLayout, ...
                'Value', 120, 'Limits', [40 240], 'Step', 5, ...
                'BackgroundColor', [0.98 0.98 1]);
            app.BPMSpinner.Layout.Row = 2;
            app.BPMSpinner.Layout.Column = 4;

            % ADDED: 拍号设置 (放在原来衰减率的位置，后续控件行号需调整)
            app.TimeSigLabel = uilabel(paramLayout, ...
                'Text', '📝 拍号:', ...
                'FontColor', [0.3 0.3 0.3]);
            app.TimeSigLabel.Layout.Row = 3;
            app.TimeSigLabel.Layout.Column = 3;
            
            app.TimeSigDropdown = uidropdown(paramLayout, ...
                'Items', {'4/4', '3/4', '2/4', '6/8'}, ...
                'Value', '4/4', ...
                'BackgroundColor', [0.98 0.98 1]);
            app.TimeSigDropdown.Layout.Row = 3;
            app.TimeSigDropdown.Layout.Column = 4;

            % 衰减率 (行号从原来的3改为1，因为上面新增了一行)
            app.DecayRateLabel = uilabel(paramLayout, ...
                'Text', '📉 衰减率:', ...
                'FontColor', [0.3 0.3 0.3]);
            app.DecayRateLabel.Layout.Row = 3;
            app.DecayRateLabel.Layout.Column = 1;
            
            app.DecayRateSpinner = uispinner(paramLayout, ...
                'Value', 5, 'Limits', [0.1 20], 'Step', 0.5, ...
                'BackgroundColor', [0.98 0.98 1]);
            app.DecayRateSpinner.Layout.Row = 3;
            app.DecayRateSpinner.Layout.Column = 2;

            % 泛音系数标签 (行号从原来的4改为4，保持不变)
            app.HarmonicsLabel = uilabel(paramLayout, ...
                'Text', '🎻 泛音系数:', ...
                'FontSize', 10, 'FontWeight', 'bold', ...
                'FontColor', [0.2 0.2 0.5]);
            app.HarmonicsLabel.Layout.Row = 4;
            app.HarmonicsLabel.Layout.Column = [1 4];

            % 泛音系数输入 (行号从原来的5,6改为5,6，保持不变)
            app.Harmonic1Label = uilabel(paramLayout, ...
                'Text', '• 基频:', ...
                'FontColor', [0.4 0.4 0.4]);
            app.Harmonic1Label.Layout.Row = 5;
            app.Harmonic1Label.Layout.Column = 1;
            
            app.Harmonic1Spinner = uispinner(paramLayout, ...
                'Value', 1, 'Limits', [0 1], 'Step', 0.05, ...
                'BackgroundColor', [0.98 0.98 1]);
            app.Harmonic1Spinner.Layout.Row = 5;
            app.Harmonic1Spinner.Layout.Column = 2;

            app.Harmonic2Label = uilabel(paramLayout, ...
                'Text', '• 2倍频:', ...
                'FontColor', [0.4 0.4 0.4]);
            app.Harmonic2Label.Layout.Row = 5;
            app.Harmonic2Label.Layout.Column = 3;
            
            app.Harmonic2Spinner = uispinner(paramLayout, ...
                'Value', 0.2, 'Limits', [0 1], 'Step', 0.05, ...
                'BackgroundColor', [0.98 0.98 1]);
            app.Harmonic2Spinner.Layout.Row = 5;
            app.Harmonic2Spinner.Layout.Column = 4;

            app.Harmonic3Label = uilabel(paramLayout, ...
                'Text', '• 3倍频:', ...
                'FontColor', [0.4 0.4 0.4]);
            app.Harmonic3Label.Layout.Row = 6;
            app.Harmonic3Label.Layout.Column = 1;
            
            app.Harmonic3Spinner = uispinner(paramLayout, ...
                'Value', 0.1, 'Limits', [0 1], 'Step', 0.05, ...
                'BackgroundColor', [0.98 0.98 1]);
            app.Harmonic3Spinner.Layout.Row = 6;
            app.Harmonic3Spinner.Layout.Column = 2;

            app.Harmonic4Label = uilabel(paramLayout, ...
                'Text', '• 4倍频:', ...
                'FontColor', [0.4 0.4 0.4]);
            app.Harmonic4Label.Layout.Row = 6;
            app.Harmonic4Label.Layout.Column = 3;
            
            app.Harmonic4Spinner = uispinner(paramLayout, ...
                'Value', 0.05, 'Limits', [0 1], 'Step', 0.05, ...
                'BackgroundColor', [0.98 0.98 1]);
            app.Harmonic4Spinner.Layout.Row = 6;
            app.Harmonic4Spinner.Layout.Column = 4;

            % AI音乐生成面板
            app.AIPanel = uipanel(leftLayout, ...
                'Title', '🤖 随机音乐生成', ...
                'FontSize', 11, 'FontWeight', 'bold', ...
                'BackgroundColor', [1 1 1], ...
                'ForegroundColor', [0.2 0.2 0.5]);
            app.AIPanel.Layout.Row = 5;
            app.AIPanel.Layout.Column = 1;
            
            aiLayout = uigridlayout(app.AIPanel);
            aiLayout.ColumnWidth = {'fit', '1x', 'fit', '1x', 'fit'};
            aiLayout.RowHeight = {'fit'};
            aiLayout.Padding = [10 10 10 10];
            aiLayout.ColumnSpacing = 8;
            aiLayout.BackgroundColor = [1 1 1];
            
            app.AILabel = uilabel(aiLayout, ...
                'Text', '🎵 风格:', ...
                'FontColor', [0.3 0.3 0.3]);
            app.AILabel.Layout.Row = 1;
            app.AILabel.Layout.Column = 1;
            
            app.AIStyleDropdown = uidropdown(aiLayout, ...
                'Items', {'欢快', '悲伤', '放松', '史诗', '随机'}, ...
                'Value', '欢快', ...
                'BackgroundColor', [0.98 0.98 1]);
            app.AIStyleDropdown.Layout.Row = 1;
            app.AIStyleDropdown.Layout.Column = 2;
            
            app.AILengthLabel = uilabel(aiLayout, ...
                'Text', '小节数:', ...
                'FontColor', [0.3 0.3 0.3]);
            app.AILengthLabel.Layout.Row = 1;
            app.AILengthLabel.Layout.Column = 3;
            
            app.AILengthSpinner = uispinner(aiLayout, ...
                'Value', 4, 'Limits', [1 16], 'Step', 1, ...
                'BackgroundColor', [0.98 0.98 1]);
            app.AILengthSpinner.Layout.Row = 1;
            app.AILengthSpinner.Layout.Column = 4;
            
            app.GenerateAIButton = uibutton(aiLayout, 'push', ...
                'Text', '✨ 随机生成', ...
                'BackgroundColor', [0.6 0.2 0.8], ...
                'FontColor', [1 1 1], ...
                'FontWeight', 'bold', ...
                'ButtonPushedFcn', createCallbackFcn(app, @GenerateAIButtonPushed, true));
            app.GenerateAIButton.Layout.Row = 1;
            app.GenerateAIButton.Layout.Column = 5;

            % 按钮面板
            app.ButtonPanel = uipanel(leftLayout, ...
                'Title', '🎛️ 操作控制', ...
                'FontSize', 11, 'FontWeight', 'bold', ...
                'BackgroundColor', [1 1 1], ...
                'ForegroundColor', [0.2 0.2 0.5]);
            app.ButtonPanel.Layout.Row = 6;
            app.ButtonPanel.Layout.Column = 1;
            
            buttonLayout = uigridlayout(app.ButtonPanel);
            buttonLayout.ColumnWidth = repmat({'1x'}, 1, 4);
            buttonLayout.RowHeight = {'fit'};
            buttonLayout.Padding = [10 10 10 10];
            buttonLayout.ColumnSpacing = 8;
            buttonLayout.BackgroundColor = [1 1 1];

            app.GenerateButton = uibutton(buttonLayout, 'push', ...
                'Text', '✨ 生成音乐', ...
                'BackgroundColor', [0.3 0.6 0.9], ...
                'FontColor', [1 1 1], ...
                'FontWeight', 'bold', ...
                'ButtonPushedFcn', createCallbackFcn(app, @GenerateButtonPushed, true));
            app.GenerateButton.Layout.Row = 1;
            app.GenerateButton.Layout.Column = 1;

            app.PlayButton = uibutton(buttonLayout, 'push', ...
                'Text', '▶️ 播放', ...
                'BackgroundColor', [0.2 0.8 0.4], ...
                'FontColor', [1 1 1], ...
                'FontWeight', 'bold', ...
                'ButtonPushedFcn', createCallbackFcn(app, @PlayButtonPushed, true));
            app.PlayButton.Layout.Row = 1;
            app.PlayButton.Layout.Column = 2;

            app.SaveButton = uibutton(buttonLayout, 'push', ...
                'Text', '💾 保存', ...
                'BackgroundColor', [0.9 0.7 0.2], ...
                'FontColor', [1 1 1], ...
                'FontWeight', 'bold', ...
                'ButtonPushedFcn', createCallbackFcn(app, @SaveButtonPushed, true));
            app.SaveButton.Layout.Row = 1;
            app.SaveButton.Layout.Column = 3;

            app.ClearButton = uibutton(buttonLayout, 'push', ...
                'Text', '🗑️ 清空', ...
                'BackgroundColor', [0.9 0.3 0.3], ...
                'FontColor', [1 1 1], ...
                'FontWeight', 'bold', ...
                'ButtonPushedFcn', createCallbackFcn(app, @ClearButtonPushed, true));
            app.ClearButton.Layout.Row = 1;
            app.ClearButton.Layout.Column = 4;

            % ========== 右侧面板 - 图形显示 ==========
            app.RightPanel = uipanel(app.GridLayout, ...
                'Title', '📈 音乐分析图表', ...
                'FontSize', 12, 'FontWeight', 'bold', ...
                'BackgroundColor', [1 1 1], ...
                'ForegroundColor', [0.2 0.2 0.5], ...
                'BorderType', 'line', ...
                'HighlightColor', [0.3 0.3 0.7]);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;
            
            rightLayout = uigridlayout(app.RightPanel);
            rightLayout.ColumnWidth = {'1x'};
            rightLayout.RowHeight = {'1x', '1x'};
            rightLayout.Padding = [15 15 15 15];
            rightLayout.RowSpacing = 15;
            rightLayout.BackgroundColor = [1 1 1];

            % 波形图
            app.WaveformAxes = uiaxes(rightLayout);
            app.WaveformAxes.Layout.Row = 1;
            app.WaveformAxes.Layout.Column = 1;
            app.WaveformAxes.BackgroundColor = [0.97 0.97 0.97];
            app.WaveformAxes.GridColor = [0.85 0.85 0.85];
            app.WaveformAxes.MinorGridColor = [0.9 0.9 0.9];
            app.WaveformAxes.XColor = [0.3 0.3 0.3];
            app.WaveformAxes.YColor = [0.3 0.3 0.3];
            title(app.WaveformAxes, '📊 时域波形图 (Time Domain)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.5]);
            xlabel(app.WaveformAxes, '时间 (秒)', 'FontSize', 10);
            ylabel(app.WaveformAxes, '幅度', 'FontSize', 10);
            grid(app.WaveformAxes, 'on');
            box(app.WaveformAxes, 'on');
            
            % 频谱图
            app.SpectrumAxes = uiaxes(rightLayout);
            app.SpectrumAxes.Layout.Row = 2;
            app.SpectrumAxes.Layout.Column = 1;
            app.SpectrumAxes.BackgroundColor = [0.97 0.97 0.97];
            app.SpectrumAxes.GridColor = [0.85 0.85 0.85];
            app.SpectrumAxes.MinorGridColor = [0.9 0.9 0.9];
            app.SpectrumAxes.XColor = [0.3 0.3 0.3];
            app.SpectrumAxes.YColor = [0.3 0.3 0.3];
            title(app.SpectrumAxes, '📊 频域频谱图 (Frequency Domain)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.5]);
            xlabel(app.SpectrumAxes, '频率 (Hz)', 'FontSize', 10);
            ylabel(app.SpectrumAxes, '幅度 (dB)', 'FontSize', 10);
            grid(app.SpectrumAxes, 'on');
            box(app.SpectrumAxes, 'on');

            % ========== 状态栏 ==========
            app.StatusLabel = uilabel(app.GridLayout, ...
                'Text', '✅ 就绪 - 请输入简谱并点击"生成音乐"', ...
                'FontSize', 10, ...
                'FontColor', [0.4 0.4 0.4], ...
                'BackgroundColor', [0.98 0.98 0.98], ...
                'HorizontalAlignment', 'center');
            app.StatusLabel.Layout.Row = 2;
            app.StatusLabel.Layout.Column = [1 2];

            % 初始化数据
            app.CurrentMusicWave = [];
            app.CurrentFS = 8192;
        end

        function GenerateButtonPushed(app, event)
            try
                % 获取参数
                score_text = app.ScoreTextArea.Value;
                
                % 处理不同类型的输入
                if isstring(score_text)
                    score_text = cellstr(score_text);
                elseif ischar(score_text)
                    score_text = {score_text};
                end
                
                if isempty(score_text) || all(cellfun('isempty', score_text))
                    uialert(app.UIFigure, '请输入乐谱!', '错误', 'Icon', 'error');
                    return;
                end
                
                % 去除注释行
                valid_lines = true(length(score_text), 1);
                for i = 1:length(score_text)
                    line_str = strtrim(score_text{i});
                    if isempty(line_str) || (length(line_str) >= 1 && line_str(1) == '%')
                        valid_lines(i) = false;
                    end
                end
                score_text = score_text(valid_lines);
                
                if isempty(score_text)
                    uialert(app.UIFigure, '请输入有效的乐谱!', '错误', 'Icon', 'error');
                    return;
                end
                
                % 将多行文本合并为单行
                score_string = strjoin(score_text, ' ');
                
                scale = app.ScaleDropdown.Value;
                fs = app.FSSpinner.Value;
                % MODIFIED: 从BPM和拍号控件获取新的节拍参数
                bpm = app.BPMSpinner.Value; % 获取速度 (BPM)
                timeSig = app.TimeSigDropdown.Value; % 获取拍号，例如 '4/4'
                decay_rate = app.DecayRateSpinner.Value;
                
                % MODIFIED: 核心公式 - 将BPM转换为四分音符的时长（秒）
                % base_rhythm = 60 / bpm
                % 例如：BPM=120  =>  base_rhythm = 60/120 = 0.5 秒 (与原默认值一致)
                base_rhythm = 60 / bpm;
                
                % 获取泛音系数
                harmonics_coeffs = [
                    app.Harmonic1Spinner.Value, ...
                    app.Harmonic2Spinner.Value, ...
                    app.Harmonic3Spinner.Value, ...
                    app.Harmonic4Spinner.Value
                ];
                
                % 解析乐谱
                app.StatusLabel.Text = '📝 正在解析乐谱...';
                drawnow;
                
                score_data = parse_score_string(score_string, base_rhythm);
                
                if isempty(score_data)
                    uialert(app.UIFigure, '无法解析乐谱，请检查格式!', '错误', 'Icon', 'error');
                    app.StatusLabel.Text = '❌ 错误: 无法解析乐谱';
                    return;
                end
                
                % 生成音乐
                app.StatusLabel.Text = '🎵 正在生成音乐波形...';
                drawnow;
                
                app.CurrentMusicWave = gen_music(score_data, scale, fs, harmonics_coeffs, decay_rate);
                app.CurrentFS = fs;
                
                % 绘制波形图
                app.StatusLabel.Text = '📊 正在绘制图表...';
                drawnow;
                
                % 计算时间轴
                total_time = length(app.CurrentMusicWave) / fs;
                time_vector = (0:length(app.CurrentMusicWave)-1) / fs;
                
                % 只显示前10秒的波形
                max_time = min(10, total_time);
                max_samples = min(length(app.CurrentMusicWave), fs * max_time);
                
                % 绘制时域波形图
                plot(app.WaveformAxes, time_vector(1:max_samples), app.CurrentMusicWave(1:max_samples), ...
                    'Color', [0.2 0.4 0.8], 'LineWidth', 1.2);
                title(app.WaveformAxes, sprintf('📊 时域波形图 (前 %.1f 秒)', max_time), ...
                    'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.5]);
                xlabel(app.WaveformAxes, '时间 (秒)', 'FontSize', 10);
                ylabel(app.WaveformAxes, '幅度', 'FontSize', 10);
                grid(app.WaveformAxes, 'on');
                xlim(app.WaveformAxes, [0 max_time]);
                
                % 计算并绘制频谱图
                app.StatusLabel.Text = '📊 正在计算频谱...';
                drawnow;
                
                % 使用整个信号计算频谱
                N = length(app.CurrentMusicWave);
                Y = fft(app.CurrentMusicWave);
                P2 = abs(Y/N);
                P1 = P2(1:floor(N/2)+1);
                P1(2:end-1) = 2*P1(2:end-1);
                
                % 计算频率轴
                f = fs*(0:(N/2))/N;
                
                % 转换为dB
                if max(P1) > 0
                    P1_db = 20*log10(P1/max(P1));
                else
                    P1_db = zeros(size(P1));
                end
                
                % 只显示到5000Hz（音乐主要频率范围）
                max_freq = min(5000, fs/2);
                idx = f <= max_freq;
                
                % 绘制频谱图
                plot(app.SpectrumAxes, f(idx), P1_db(idx), ...
                    'Color', [0.8 0.2 0.4], 'LineWidth', 1.2);
                title(app.SpectrumAxes, '📊 频域频谱图 (幅度-频率)', ...
                    'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.5]);
                xlabel(app.SpectrumAxes, '频率 (Hz)', 'FontSize', 10);
                ylabel(app.SpectrumAxes, '幅度 (dB)', 'FontSize', 10);
                grid(app.SpectrumAxes, 'on');
                xlim(app.SpectrumAxes, [0 max_freq]);
                ylim(app.SpectrumAxes, [-80 0]);
                
                % 标记主要频率成分
                [~, peaks] = findpeaks(P1_db(idx), 'MinPeakHeight', -20, 'MinPeakDistance', 200);
                if ~isempty(peaks)
                    hold(app.SpectrumAxes, 'on');
                    plot(app.SpectrumAxes, f(peaks), P1_db(peaks), 'ko', ...
                        'MarkerSize', 2, 'LineWidth', 1.6);
                    hold(app.SpectrumAxes, 'off');
                end
                
                app.StatusLabel.Text = sprintf('✅ 生成成功! 音乐长度: %.2f 秒, 采样率: %d Hz', total_time, fs);
                
            catch ME
                uialert(app.UIFigure, sprintf('错误: %s', ME.message), '生成失败', 'Icon', 'error');
                app.StatusLabel.Text = '❌ 错误: 生成失败';
            end
        end

        function PlayButtonPushed(app, event)
            if isempty(app.CurrentMusicWave)
                uialert(app.UIFigure, '请先生成音乐!', '提示', 'Icon', 'warning');
                return;
            end
            
            app.StatusLabel.Text = '▶️ 正在播放...';
            drawnow;
            
            % 添加播放进度指示
            total_time = length(app.CurrentMusicWave) / app.CurrentFS;
            
            sound(app.CurrentMusicWave, app.CurrentFS);
            
            % 等待播放完成
            pause(total_time + 0.1);
            
            app.StatusLabel.Text = '✅ 播放完成';
        end

        function SaveButtonPushed(app, event)
            if isempty(app.CurrentMusicWave)
                uialert(app.UIFigure, '请先生成音乐!', '提示', 'Icon', 'warning');
                return;
            end
            
            [filename, pathname] = uiputfile({'*.wav', 'WAV音频文件 (*.wav)'; ...
                                             '*.mp3', 'MP3音频文件 (*.mp3)'}, ...
                                             '保存音乐文件', 'my_music.wav');
            if isequal(filename, 0)
                return;
            end
            
            try
                app.StatusLabel.Text = '💾 正在保存...';
                drawnow;
                
                full_path = fullfile(pathname, filename);
                [~, ~, ext] = fileparts(filename);
                
                if strcmpi(ext, '.wav')
                    audiowrite(full_path, app.CurrentMusicWave, app.CurrentFS);
                elseif strcmpi(ext, '.mp3')
                    % 注意: MATLAB需要Audio Toolbox来保存MP3
                    audiowrite(full_path, app.CurrentMusicWave, app.CurrentFS);
                end
                
                app.StatusLabel.Text = sprintf('✅ 已保存: %s', filename);
                uialert(app.UIFigure, sprintf('音乐已保存到:\n%s', full_path), '保存成功', 'Icon', 'success');
                
            catch ME
                uialert(app.UIFigure, sprintf('保存失败: %s', ME.message), '错误', 'Icon', 'error');
                app.StatusLabel.Text = '❌ 保存失败';
            end
        end

        function ClearButtonPushed(app, event)
            % 确认对话框
            selection = uiconfirm(app.UIFigure, ...
                '确定要清空所有内容吗？', '确认清空', ...
                'Icon', 'warning', ...
                'Options', {'确定', '取消'}, ...
                'DefaultOption', 2);
            
            if strcmp(selection, '确定')
                % 修正：将Value设置为字符串数组而不是空元胞数组
                app.ScoreTextArea.Value = "";
                app.CurrentMusicWave = [];
                cla(app.WaveformAxes);
                cla(app.SpectrumAxes);
                
                % 重置图表标题
                title(app.WaveformAxes, '📊 时域波形图 (Time Domain)', ...
                    'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.5]);
                title(app.SpectrumAxes, '📊 频域频谱图 (Frequency Domain)', ...
                    'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.5]);
                
                app.StatusLabel.Text = '✅ 已清空所有内容';
            end
        end
        
        function InstrumentDropdownValueChanged(app, event)
            % 乐器音色预设选择变化
            instrument_name = app.InstrumentDropdown.Value;
            
            % 映射中文名称到英文标识
            instrument_map = containers.Map(...
                {'钢琴', '小提琴', '长笛', '吉他', '风琴', '钟声', '弦乐合奏', '电子音色', '木琴'}, ...
                {'piano', 'violin', 'flute', 'guitar', 'organ', 'bell', 'strings', 'electronic', 'xylophone'});
            
            if isKey(instrument_map, instrument_name)
                [harmonics_coeffs, decay_rate, description] = ...
                    instrument_presets(instrument_map(instrument_name));
                
                % 设置泛音系数
                app.Harmonic1Spinner.Value = harmonics_coeffs(1);
                app.Harmonic2Spinner.Value = harmonics_coeffs(2);
                app.Harmonic3Spinner.Value = harmonics_coeffs(3);
                app.Harmonic4Spinner.Value = harmonics_coeffs(4);
                
                % 如果有更多泛音系数，可以扩展这里
                if length(harmonics_coeffs) > 4
                    % 可以添加更多spinner或提示用户
                end
                
                % 设置衰减率
                app.DecayRateSpinner.Value = decay_rate;
                
                % 显示乐器描述
                app.StatusLabel.Text = sprintf('✅ 已切换到%s音色: %s', instrument_name, description);
            end
        end
        
        function GenerateAIButtonPushed(app, event)
            % AI生成音乐按钮回调
            try
                % 获取AI参数
                style_chinese = app.AIStyleDropdown.Value;
                length_bars = app.AILengthSpinner.Value;
                
                app.StatusLabel.Text = '🤖 正在生成音乐...';
                drawnow;
                
                % 映射中文风格到英文标识
                style_map = {'欢快', 'happy'; '悲伤', 'sad'; '放松', 'relax'; '史诗', 'epic'; '随机', 'random'};
                
                style_english = 'random'; % 默认
                for i = 1:size(style_map, 1)
                    if strcmp(style_chinese, style_map{i, 1})
                        style_english = style_map{i, 2};
                        break;
                    end
                end
                
                % 调用AI音乐生成器
                ai_score = ai_music_generator(style_english, length_bars);
                
                % 将生成的乐谱显示在文本区域
                current_value = app.ScoreTextArea.Value;
                
                % 处理当前值，确保是字符串
                if isempty(current_value)
                    current_text = "";
                elseif isstring(current_value)
                    % 如果是字符串数组，转换为单个字符串
                    if isscalar(current_value)
                        current_text = current_value;
                    else
                        current_text = strjoin(current_value, newline);
                    end
                elseif iscellstr(current_value) || iscell(current_value)
                    % 如果是单元格数组，转换为字符串
                    current_text = strjoin(current_value, newline);
                else
                    current_text = string(current_value);
                end
                
                % 添加AI生成的乐谱
                if isempty(char(current_text)) || all(isspace(char(current_text)))
                    new_text = ai_score;
                else
                    new_text = sprintf('%s\n\n%s', current_text, ai_score);
                end
                
                % 将新文本设置为文本区域的值
                app.ScoreTextArea.Value = new_text;
                
                app.StatusLabel.Text = sprintf('✅ 已生成%s风格的音乐 (%d小节)', style_chinese, length_bars);
                
            catch ME
                uialert(app.UIFigure, sprintf('生成失败: %s\n\n请确保ai_music_generator.m文件存在且功能正常。', ME.message), '错误', 'Icon', 'error');
                app.StatusLabel.Text = '❌ 生成失败';
                disp('错误详情:');
                disp(ME.message);
                disp(ME.stack);
            end
        end
    end

    methods (Access = public)
        function app = MusicScoreApp()
            createComponents(app)
            
            % 初始化乐器音色
            app.InstrumentDropdownValueChanged([]);
        end
    end
end