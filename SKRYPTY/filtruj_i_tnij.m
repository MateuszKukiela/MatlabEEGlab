function filtruj_i_tnij(EEG, ALLEEG, CURRENTSET, directoryIn, directoryOut, addName, subjects, LowFreqCut, HighFreqCut, startT, stopT, eegChan, baseline)
 
  % zapamiętujemy stan wejściowy zmiennych globalnych eeglaba
    EEG0 = EEG; 
    ALLEEG0 = ALLEEG; 
    CURRENTSET0 = CURRENTSET;
    events = {'Pseudo','ANeg','ANeu','APos','ONeg','ONeu','OPos','RNeg','RNeu','RPos'};   % typ eventow do wyciecia
 
    for sub = subjects
 
        % tworzymy nazwę setu dla osoby z numerem 'sub'
        if sub < 10
            nameOfSubj = ['B0' num2str(sub)];
        else
            nameOfSubj = ['B' num2str(sub)];
        end
 
        % wczytujemy set z danymi
        EEG = pop_loadset('filename',[nameOfSubj '.set'],'filepath',directoryIn);
 
        % uaktualniamy zestaw danych globalnych dla eeglaba:
       [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        EEG = eeg_checkset( EEG);
 
##        % zostawiamy tylko potrzebne kanaly EEG , te które są wymienione w zmiennej eegChan:
        EEG.data = EEG.data(eegChan,:); % wycianmy dane
        EEG.nbchan = length(eegChan) ; % uaktualniamy liczbę kanałów
        EEG.chanlocs = EEG.chanlocs(1,eegChan);  % obcianamy listę położeń kanałów
## 
##        % referencja - odjecie sredniej ze wszystkich kanalow
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
## 
##        % filtracja danych - zastosujemy filtr Butterwartha  2-go rzędu
        [b1,a1] = butter(2, LowFreqCut/(EEG.srate/2) , 'high');
        [b2,a2] = butter(2, HighFreqCut /(EEG.srate/2), 'low');
        [b3,a3] = butter(2, 2*[49.5 50.5]/EEG.srate, 'stop'); % filtr pasmowozaporowy  "notch" na sieć
        for channel = 1:size(EEG.data,1)
            EEG.data(channel,:) = filtfilt(b1,a1,double(EEG.data(channel,:))); % górnoprzepustowy
            EEG.data(channel,:) = filtfilt(b2,a2,double(EEG.data(channel,:))); % dolno
            EEG.data(channel,:) = filtfilt(b3,a3,double(EEG.data(channel,:))); % notch
        end
        EEG = eeg_checkset( EEG );##        % ekstrakcja epok: 
       % zauważmy, że podajemy w tej funkcji listę eventów wokół których mają być robione wycinki i okresy wycinków
       % przy okazji nadajemy setowi nazwę z dodanym stringiem addName: 
        EEG = pop_epoch( EEG, events, [startT, stopT], 'newname', [nameOfSubj addName], 'epochinfo', 'yes');

        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
        EEG = eeg_checkset( EEG );

       % usuniecie baseline
        EEG = pop_rmbase(EEG, [-200 0]);
        EEG = eeg_checkset( EEG );

       % zapisanie setu
        EEG = pop_saveset( EEG, 'filename',[nameOfSubj addName],'filepath',directoryOut);
        disp(['filtrowanie i cięcie ----------- dane ' nameOfSubj ' :   GOTOWE ----------------'])
 
    end
 
 
    % przywracamy  stan wejściowy zmiennych globalnych eeglaba
    EEG = EEG0; 
    ALLEEG = ALLEEG0; 
    CURRENTSET = CURRENTSET0;
end