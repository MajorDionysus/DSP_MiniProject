%% --- 修正版 parse_score_string ---
function score_data = parse_score_string(score_string, base_rhythm)
    if nargin<2, base_rhythm=0.5; end

    lines = strsplit(score_string, {'\n','\r'});
    cleanLines = {};
    for i=1:numel(lines)
        t=strtrim(lines{i});
        if ~isempty(t) && t(1)~='%'
            cleanLines{end+1}=t;
        end
    end
    if isempty(cleanLines), score_data=[]; return; end

    combinedStr = strjoin(cleanLines,' ');
    pattern = '\[[^\]]*\][^\s]*|[^\s]+';
    tokens = regexp(combinedStr, pattern, 'match');

    score_data = [];
    chord_id = 0;

    for i=1:numel(tokens)
        token = tokens{i};
        if any(strcmp(token,{'|','||','|||'})), continue; end

        if startsWith(token,'[')
            chord_id = chord_id+1;
            chordNotes = parseChord(token, base_rhythm);
            if ~isempty(chordNotes)
                chordNotes = [chordNotes, chord_id*ones(size(chordNotes,1),1)];
                score_data = [score_data; chordNotes];
            end
        else
            note = parseSingleNote(token, base_rhythm);
            if ~isempty(note)
                score_data = [score_data; note, 0];
            end
        end
    end
end

function noteData = parseSingleNote(noteStr, baseRhythm)
    noteData=[]; tone=0; octaveShift=0; rising=0;

    if strcmp(noteStr,'0') || startsWith(noteStr,'0')
        suffix = noteStr(2:end);
        rhythm = baseRhythm*parseRhythmSuffix(suffix);
        noteData=[0 0 0 rhythm];
        return;
    end

    pat='([0-7])([#b]?)(['',]*)([-_.]*)';
    m=regexp(noteStr,pat,'tokens','once');
    if isempty(m), return; end

    tone=str2double(m{1});
    if strcmp(m{2},'#'), rising=1; elseif strcmp(m{2},'b'), rising=-1; end
    octaveShift = sum(m{3}=='''') - sum(m{3}==',');
    rhythm = baseRhythm*parseRhythmSuffix(m{4});
    noteData=[tone octaveShift rising rhythm];
end

function chordNotes = parseChord(token, baseRhythm)
    chordNotes=[];
    m=regexp(token,'^\[([^\]]+)\]([,._''-]*)$','tokens','once');
    if isempty(m), return; end
    notesPart=m{1}; suffix=m{2};
    sharedOct = sum(suffix=='''') - sum(suffix==',');
    rhythm = baseRhythm*parseRhythmSuffix(regexprep(suffix,'['',]',''));

    noteTokens=strsplit(notesPart,',');
    for i=1:numel(noteTokens)
        [tone,rising,oct]=parseChordNotePitch(strtrim(noteTokens{i}));
        chordNotes=[chordNotes; tone, sharedOct+oct, rising, rhythm];
    end
end

function [tone,rising,octaveShift]=parseChordNotePitch(noteToken)
    tone=0; rising=0; octaveShift=0;
    m=regexp(noteToken,'([0-7])([#b]?)(['',]*)','tokens','once');
    if isempty(m), return; end
    tone=str2double(m{1});
    if strcmp(m{2},'#'), rising=1;
    elseif strcmp(m{2},'b'), rising=-1; end
    octaveShift = sum(m{3}=='''') - sum(m{3}==',');
end

function mult=parseRhythmSuffix(s)
    mult=1;
    if isempty(s), return; end
    dashCount=sum(s=='-'); mult=mult*2^dashCount; s(s=='-')=[];
    underCount=sum(s=='_'); mult=mult/2^underCount; s(s=='_')=[];
    dotCount=sum(s=='.');
    for k=1:dotCount, mult=mult+mult/(2^k); end
end

