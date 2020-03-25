function [] = oznaczArtefakty(EEG , ALLEEG , CURRENTSET, directoryOut, addName, subjects, abnormalValue, abnormalTrend)
 
      % zapamiętujemy stan wejściowy zmiennych globalnych eeglaba
    EEG0 = EEG; 
    ALLEEG0 = ALLEEG; 
    CURRENTSET0 = CURRENTSET;
    for sub = subjects
        % składamy nazwę pliku
        % tworzymy nazwę setu dla osoby z numerem 'sub'
        if sub < 10
            nameOfSubj = ['B0' num2str(sub)];
        else
            nameOfSubj = ['B' num2str(sub)];
        end 
        % wczytujemy plik:
        directoryIn = directoryOut;
        EEG = pop_loadset('filename',[nameOfSubj addName,'.set'],'filepath',directoryIn);
        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG,EEG,0);
        EEG = eeg_checkset( EEG);
 
        % automatyczne oznaczanie artefaktow
 
        EEG = pop_eegthresh(EEG, 1, 1:EEG.nbchan, -abnormalValue, abnormalValue, 0 , 0.800,0,1); % abnormal value
        EEG = eeg_checkset(EEG);
        EEG = pop_rejtrend(EEG,1,1:EEG.nbchan, EEG.pnts,abnormalTrend, 0.3, 0, 1,0 ); % abnormalTrend
        EEG = eeg_checkset(EEG);
        close(gcf)
 
        % zapisanie setu
        EEG = pop_saveset(EEG, 'filename', [nameOfSubj addName], 'filepath', directoryOut);
        disp(['oznaczArtefakt ----------- dane ' nameOfSubj ' :   GOTOWE ----------------'])
 
    end
    % przywracamy stan wejściowy zmiennych globalnych eeglaba
    EEG = EEG0; 
    ALLEEG = ALLEEG0; 
    CURRENTSET = CURRENTSET0;
    end