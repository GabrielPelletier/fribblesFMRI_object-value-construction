classdef fLocSession
    
    properties
        name      % participant initials or id string
        date      % session date
        trigger   % option to trigger scanner (0 = no, 1 = yes)
        num_runs  % number of runs in experiment
        sequence  % session fLocSequence object
        responses % behavioral response data structure
        real_block_onsets % to record the real block onset times
        parfiles  % paths to vistasoft-compatible parfiles
    end
    
    properties (Hidden)
        stim_set  % stimulus set/s (1 = standard, 2 = alternate, 3 = both)
        task_num  % task number (1 = 1-back, 2 = 2-back, 3 = oddball)
        input     % device number of input used for resonse collection
        keyboard  % device number of native computer keyboard
        hit_cnt   % number of hits per run
        fa_cnt    % number of false alarms per run
        %real_block_onsets % actual recorded onsets of blocks
    end
    
    properties (Constant)
        pre_dur = 5; % pre-experiment countdown (secs)
        stim_size = 768; % size to display images in pixels
    end
    
    properties (Constant, Hidden)
        task_names = {'1back' '2back' 'oddball'};
        exp_dir = fileparts(fileparts(which(mfilename, 'class')));
        fix_color = [255 0 0]; % fixation marker color (RGB)
        text_color = 255;      % instruction text color (grayscale)
        blank_color = 128;     % baseline screen color (grayscale)
        wait_dur = 1.5;          % seconds to wait for response
        postRunDur = 0;
    end
    
    properties (Dependent)
        id        % session-specific id string
        task_name % descriptor for each task number
    end
    
    properties (Dependent, Hidden)
        hit_rate     % proportion of task probes detected in each run
        instructions % task-specific instructions for participant
    end
    
    methods
        
        % class constructor
        function session = fLocSession(name, trigger, stim_set, num_runs, task_num)
            session.name = deblank(name);
            session.trigger = trigger;
            if nargin < 3
                session.stim_set = 3;
            else
                session.stim_set = stim_set;
            end
            if nargin < 4
                session.num_runs = 4;
            else
                session.num_runs = num_runs;
            end
            if nargin < 5
                session.task_num = 3;
            else
                session.task_num = task_num;
            end
            session.date = date;
            session.hit_cnt = zeros(1, session.num_runs);
            session.real_block_onsets = zeros(17,session.num_runs); % Added by GP march 2018
            session.fa_cnt = zeros(1, session.num_runs);
        end
        
        % get session-specific id string
        function id = get.id(session)
            par_str = [session.name '_' session.date];
            exp_str = [session.task_name '_' num2str(session.num_runs) 'runs'];
            id = [par_str '_' exp_str];
        end
        
        % get name of task
        function task_name = get.task_name(session)
            task_name = session.task_names{session.task_num};
        end
        
        % get hit rate for task
        function hit_rate = get.hit_rate(session)
            num_probes = sum(session.sequence.task_probes);
            hit_rate = session.hit_cnt ./ num_probes;
        end
        
        % get instructions for participant given task
        function instructions = get.instructions(session)
            if session.task_num == 1
                instructions = 'Fixate. Press a button when an image repeats on sequential trials.';
            elseif session.task_num == 2
                instructions = 'Fixate. Press a button when an image repeats with one intervening image.';
            else
                instructions = 'Fixate. Press a button when a scrambled image appears.';
            end
        end
        
        % define/load stimulus sequences for this session
        function session = load_seqs(session)
            fname = [session.id '_fLocSequence.mat'];
            fpath = fullfile(session.exp_dir, 'data', session.id, fname);
            % make stimulus sequences if not already defined for session
            if ~exist(fpath, 'file')
                seq = fLocSequence(session.stim_set, session.num_runs, session.task_num);
                seq = make_runs(seq);
                mkdir(fileparts(fpath));
                save(fpath, 'seq', '-v7.3');
            else
                load(fpath);
            end
            session.sequence = seq;
        end
        
        % register input devices
        function session = find_inputs(session)
            laptop_key = get_keyboard_num;
            button_key = get_box_num;
            if session.trigger == 1 && button_key ~= 0
                session.keyboard = laptop_key;
                session.input = button_key;
            else
                session.keyboard = laptop_key;
                session.input = laptop_key;
            end
        end
        
        % execute a run of the experiment
        function session = run_exp(session, run_num, language)
            % get timing information and initialize response containers
            block = 1;
            session = find_inputs(session); k = session.input;
            sdc = session.sequence.stim_duty_cycle;
            stim_dur = session.sequence.stim_dur;
            isi_dur = session.sequence.isi_dur;
            stim_names = session.sequence.stim_names(:, run_num);
            stim_onsets = session.sequence.stim_onsets(:,run_num);
            isifix_onsets = session.sequence.isifix_onsets(:,run_num);
            stim_dir = fullfile(session.exp_dir, 'stimuli');
            tcol = session.text_color; bcol = session.blank_color; fcol = session.fix_color;
            resp_keys = {}; resp_press = zeros(length(stim_names), 1);
            % setup screen and load all stimuli in run
            [window_ptr, center] = do_screen;
            center_x = center(1); center_y = center(2); s = session.stim_size / 2;
            stim_rect = [center_x - s center_y - s center_x + s center_y + s];
            img_ptrs = [];
            for ii = 1:length(stim_names)
                if strcmp(stim_names{ii}, 'baseline')
                    img_ptrs(ii) = 0;
                else
                    cat_dir = stim_names{ii}(1:find(stim_names{ii} == '-') - 1);
                    img = imread(fullfile(stim_dir, cat_dir, stim_names{ii}));
                    img_ptrs(ii) = Screen('MakeTexture', window_ptr, img);
                end
            end
            % start experiment triggering scanner if applicable
            if session.trigger == 0
                %Screen('FillRect', window_ptr, bcol);
                %Screen('Flip', window_ptr);
                DrawFormattedText(window_ptr, [session.instructions, '\n When you are ready, press your Index key to continue to the next run.'], 'center', 'center', tcol); % 'flipHorizontal', 1);
                Screen('Flip', window_ptr);
                get_key('b', session.keyboard);
            elseif session.trigger == 1
                trigImage = imread([pwd,'/stimuli/',language,'/trigger.jpg']);
                instrImage = imread([pwd,'/stimuli/',language,'/localizer.jpg']);
                DisableKeysForKbCheck([]); % re-enable all keys for KbCheck so the trigger can be recorded
                Screen('FillRect', window_ptr, bcol);
                Screen('Flip', window_ptr);
                Screen('PutImage', window_ptr, instrImage);
                %DrawFormattedText(window_ptr, [session.instructions, '\n\n When you are ready, press your Index key to continue to the next run.'], 'center', 'center', tcol); % 'flipHorizontal', 1);
                Screen('Flip', window_ptr);
                get_key('b', -1); % Experimenter has to press g on keyboard
                
                while 1
                % Wait for the scanner TRIGGER
                    Screen('PutImage', window_ptr, trigImage);
                    Screen(window_ptr,'Flip');
%                     DrawFormattedText(window_ptr,'Waiting for trigger...GET READY....', 'center', 'center', tcol);
%                     Screen(window_ptr,'Flip');  
                    escapeKey = KbName('t');
%     Trigger    %     Trigger    %     Trigger
                        [keyIsDown,~,keyCode] = KbCheck(-1);
                        if keyIsDown && keyCode(escapeKey)
                            break;
                        end
                end
                % Only allow the response box keys for subsequent kbChecks
                DisableKeysForKbCheck(KbName('t'));
            end
            
            start_time = GetSecs; % Reference time
            
            % Pre-run fixation
            Screen('FillRect', window_ptr, bcol);
            draw_fixation(window_ptr, center, fcol);
            Screen('Flip', window_ptr); 
            
            % main display loop
            tic
            for ii = 1:length(stim_names)
                % display blank screen if baseline and image if stimulus
                if strcmp(stim_names{ii}, 'baseline')
                    Screen('FillRect', window_ptr, bcol);
                    draw_fixation(window_ptr, center, fcol);
                else
                    Screen('DrawTexture', window_ptr, img_ptrs(ii), [], stim_rect);
                    draw_fixation(window_ptr, center, fcol);
                end
                [VBL, StimOnsetT] = Screen('Flip', window_ptr, (start_time + stim_onsets(ii))); % Modified so the image is prenseted at PRE-defined timings: stim_onsets matrix. %%% GP Jan2018
                % collect responses
                ii_press = []; ii_keys = [];
                [keys, ie] = record_keys((start_time + stim_onsets(ii)), stim_dur, -1);
                ii_keys = [ii_keys keys]; ii_press = [ii_press ie];
                % display ISI      %%% Modified, GP Jan2018
                if isi_dur > 0
                    Screen('FillRect', window_ptr, bcol);
                    draw_fixation(window_ptr, center, fcol);
                    Screen('Flip', window_ptr, (start_time + isifix_onsets(ii)));
                    [keys, ie] = record_keys((start_time + isifix_onsets(ii)), isi_dur, -1);
                    ii_keys = [ii_keys keys]; ii_press = [ii_press ie];
                end
                resp_keys{ii} = ii_keys;
                %resp_press(ii) = min(ii_press); % This makes it so that every answer is computed as 0 (no answer), which is non-sense.
                resp_press(ii) = max(ii_press);             %%%% GP Jan2018
                
                % If it is the start of a block then get the real onset time
                if mod(ii,session.sequence.stim_per_block) == 1
                    session.real_block_onsets(block,run_num) = (StimOnsetT - start_time);
                    block = block + 1;
                end
                    
            end
            
            % Buffer at the end of run?
            Screen('FillRect', window_ptr, bcol);
            draw_fixation(window_ptr, center, fcol);
            WaitSecs(session.postRunDur);
            disp(['Run duration is:', num2str(toc)]);
            
            % store responses
            session.responses(run_num).keys = resp_keys;
            session.responses(run_num).press = resp_press;
            fname = [session.id '_backup_run' num2str(run_num) '.mat'];
            fpath = fullfile(session.exp_dir, 'data', session.id, fname);
            save(fpath, 'resp_keys', 'resp_press', '-v7.3');
            % analyze response data and display performance
            session = score_task(session, run_num);
            num_probes = num2str(sum(session.sequence.task_probes(:, run_num)));
            hit_cnt = num2str(session.hit_cnt(run_num));
            fa_cnt = num2str(session.fa_cnt(run_num));
            hit_rate = num2str(session.hit_rate(run_num) * 100);
            hit_str = ['Hits: ' hit_cnt '/' num_probes ' (' hit_rate '%)'];
            fa_str = ['False alarms: ' fa_cnt];
            Screen('FillRect', window_ptr, bcol);
            Screen('Flip', window_ptr);
            score_str = [hit_str '\n' fa_str];
            DrawFormattedText(window_ptr, score_str, 'center', 'center', tcol);
            Screen('Flip', window_ptr);
            get_key('q', -1);
            ShowCursor;
            %Screen('CloseAll');
        end
        
        % quantify performance in stimulus task
        function session = score_task(session, run_num)
            sdc = session.sequence.stim_duty_cycle;
            fpw = session.wait_dur / sdc;
            % get response time windows for task probes
            resp_presses = session.responses(run_num).press;
            resp_correct = session.sequence.task_probes(:, run_num);
            probe_idxs = find(resp_correct);
            hit_windows = zeros(size(resp_correct));
            for ww = 1:ceil(fpw)
                hit_windows(probe_idxs + ww - 1) = 1;
            end
            hit_resp_windows = resp_presses(hit_windows == 1);
            fa_resp_windows = resp_presses(hit_windows == 0);
            % count hits and false alarms
            session.hit_cnt(run_num) = sum(max(reshape(hit_resp_windows, fpw, [])));
            session.fa_cnt(run_num) = sum(fa_resp_windows);
        end
        
        % write vistasoft-compatible parfile for each run
        function session = write_parfiles(session)
            session.parfiles = cell(1, session.num_runs);
            % list of conditions and plotting colors
            conds = ['Baseline' session.sequence.stim_conds];
            %cols = {[1 1 1] [0 0 1] [0 0 0] [1 0 0] [.8 .8 0] [0 1 0]};
            cols = {[0 0 0 0] [1 0 0 0] [0 1 0 0] [0 0 1 0] [0 0 0 1]};
            % write information about each block on a separate line
            for rr = 1:session.num_runs
                actual_block_onsets = session.real_block_onsets(:,rr);
                planned_block_onsets = session.sequence.block_onsets(:, rr);
                block_conds = session.sequence.block_conds(:, rr);
                cond_names = conds(block_conds + 1);
                cond_cols = cols(block_conds + 1);
                fname = [session.id '_fLoc_run' num2str(rr) '.par'];
                fpath = fullfile(session.exp_dir, 'data', session.id, fname);
                fid = fopen(fpath, 'w');
                for bb = 1:length(actual_block_onsets)
                    fprintf(fid, '%d \t %d \t', actual_block_onsets(bb), block_conds(bb));
                    fprintf(fid, '%s \t', cond_names{bb});
                    fprintf(fid, '%i %i %i %i \n', cond_cols{bb});
                end
                fclose(fid);
                session.parfiles{rr} = fpath;
            end
        end
        
    end
    
end

