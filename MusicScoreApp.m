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
        FSLabel                         matlab.ui.control.Label
        FSSpinner                       matlab.ui.control.Spinner
        BaseRhythmLabel                 matlab.ui.control.Label
        BaseRhythmSpinner               matlab.ui.control.Spinner
        
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
            leftLayout.RowHeight = {'fit', '1x', 'fit', 'fit', 'fit'};
            leftLayout.Padding = [15 15 15 15];
            leftLayout.RowSpacing = 12;
            leftLayout.BackgroundColor = [1 1 1];

            % 乐谱输入标签和文本框 - 修正初始值设置
            app.ScoreLabel = uilabel(leftLayout, ...
                'Text', '📝 简谱输入 (示例: 5. 6. 7. 1'' 7 6 5 4 3 4 5-)', ...
                'FontSize', 11, 'FontWeight', 'bold', ...
                'FontColor', [0.2 0.2 0.5]);
            app.ScoreLabel.Layout.Row = 1;
            app.ScoreLabel.Layout.Column = 1;
            
            app.ScoreTextArea = uitextarea(leftLayout, ...
                'BackgroundColor', [0.98 0.98 1], ...
                'FontName', 'Consolas', ...
                'FontSize', 11, ...
                'Placeholder', '输入简谱，每行一段。格式说明：数字表示音高，.表示低八度，''表示高八度，-表示延长一拍');
            app.ScoreTextArea.Layout.Row = 2;
            app.ScoreTextArea.Layout.Column = 1;
            % 设置初始值作为字符串数组，而不是元胞数组
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
            paramLayout.RowHeight = repmat({'fit'}, 1, 6);
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

            % 采样频率
            app.FSLabel = uilabel(paramLayout, ...
                'Text', '📊 采样频率 (Hz):', ...
                'FontColor', [0.3 0.3 0.3]);
            app.FSLabel.Layout.Row = 1;
            app.FSLabel.Layout.Column = 3;
            
            app.FSSpinner = uispinner(paramLayout, ...
                'Value', 8192, 'Limits', [4096 48000], 'Step', 1024, ...
                'BackgroundColor', [0.98 0.98 1]);
            app.FSSpinner.Layout.Row = 1;
            app.FSSpinner.Layout.Column = 4;

            % 基础节拍
            app.BaseRhythmLabel = uilabel(paramLayout, ...
                'Text', '🎶 基础节拍 (秒):', ...
                'FontColor', [0.3 0.3 0.3]);
            app.BaseRhythmLabel.Layout.Row = 2;
            app.BaseRhythmLabel.Layout.Column = 1;
            
            app.BaseRhythmSpinner = uispinner(paramLayout, ...
                'Value', 0.5, 'Limits', [0.1 2], 'Step', 0.1, ...
                'BackgroundColor', [0.98 0.98 1]);
            app.BaseRhythmSpinner.Layout.Row = 2;
            app.BaseRhythmSpinner.Layout.Column = 2;

            % 衰减率
            app.DecayRateLabel = uilabel(paramLayout, ...
                'Text', '📉 衰减率:', ...
                'FontColor', [0.3 0.3 0.3]);
            app.DecayRateLabel.Layout.Row = 2;
            app.DecayRateLabel.Layout.Column = 3;
            
            app.DecayRateSpinner = uispinner(paramLayout, ...
                'Value', 5, 'Limits', [0.1 20], 'Step', 0.5, ...
                'BackgroundColor', [0.98 0.98 1]);
            app.DecayRateSpinner.Layout.Row = 2;
            app.DecayRateSpinner.Layout.Column = 4;

            % 泛音系数标签
            app.HarmonicsLabel = uilabel(paramLayout, ...
                'Text', '🎻 泛音系数:', ...
                'FontSize', 10, 'FontWeight', 'bold', ...
                'FontColor', [0.2 0.2 0.5]);
            app.HarmonicsLabel.Layout.Row = 3;
            app.HarmonicsLabel.Layout.Column = [1 4];

            % 泛音系数输入
            app.Harmonic1Label = uilabel(paramLayout, ...
                'Text', '• 基频:', ...
                'FontColor', [0.4 0.4 0.4]);
            app.Harmonic1Label.Layout.Row = 4;
            app.Harmonic1Label.Layout.Column = 1;
            
            app.Harmonic1Spinner = uispinner(paramLayout, ...
                'Value', 1, 'Limits', [0 1], 'Step', 0.05, ...
                'BackgroundColor', [0.98 0.98 1]);
            app.Harmonic1Spinner.Layout.Row = 4;
            app.Harmonic1Spinner.Layout.Column = 2;

            app.Harmonic2Label = uilabel(paramLayout, ...
                'Text', '• 2倍频:', ...
                'FontColor', [0.4 0.4 0.4]);
            app.Harmonic2Label.Layout.Row = 4;
            app.Harmonic2Label.Layout.Column = 3;
            
            app.Harmonic2Spinner = uispinner(paramLayout, ...
                'Value', 0.2, 'Limits', [0 1], 'Step', 0.05, ...
                'BackgroundColor', [0.98 0.98 1]);
            app.Harmonic2Spinner.Layout.Row = 4;
            app.Harmonic2Spinner.Layout.Column = 4;

            app.Harmonic3Label = uilabel(paramLayout, ...
                'Text', '• 3倍频:', ...
                'FontColor', [0.4 0.4 0.4]);
            app.Harmonic3Label.Layout.Row = 5;
            app.Harmonic3Label.Layout.Column = 1;
            
            app.Harmonic3Spinner = uispinner(paramLayout, ...
                'Value', 0.1, 'Limits', [0 1], 'Step', 0.05, ...
                'BackgroundColor', [0.98 0.98 1]);
            app.Harmonic3Spinner.Layout.Row = 5;
            app.Harmonic3Spinner.Layout.Column = 2;

            app.Harmonic4Label = uilabel(paramLayout, ...
                'Text', '• 4倍频:', ...
                'FontColor', [0.4 0.4 0.4]);
            app.Harmonic4Label.Layout.Row = 5;
            app.Harmonic4Label.Layout.Column = 3;
            
            app.Harmonic4Spinner = uispinner(paramLayout, ...
                'Value', 0.05, 'Limits', [0 1], 'Step', 0.05, ...
                'BackgroundColor', [0.98 0.98 1]);
            app.Harmonic4Spinner.Layout.Row = 5;
            app.Harmonic4Spinner.Layout.Column = 4;

            % 按钮面板
            app.ButtonPanel = uipanel(leftLayout, ...
                'Title', '🎛️ 操作控制', ...
                'FontSize', 11, 'FontWeight', 'bold', ...
                'BackgroundColor', [1 1 1], ...
                'ForegroundColor', [0.2 0.2 0.5]);
            app.ButtonPanel.Layout.Row = 4;
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
                base_rhythm = app.BaseRhythmSpinner.Value;
                decay_rate = app.DecayRateSpinner.Value;
                
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
    end

    methods (Access = public)
        function app = MusicScoreApp()
            createComponents(app)
        end
    end
end