function [data] = preparujDane(EEG , ALLEEG , CURRENTSET, directoryOut, addName, subjects)
 % zapamiętujemy stan wejściowy zmiennych globalnych eeglaba
       ... 
    
    directoryIn = directoryOut;
    EEG = pop_loadset('filename',['B01', addName,'.set'],'filepath',directoryIn);
    data    = zeros(2, length(subjects), EEG.nbchan, EEG.pnts);       % macierz z danymi o rozmiarze [2(1.Words|2.Pseudo) x subjects x kanaly x probki]
    trialNb = zeros(2, length(subjects));                                         % macierz z informacja o liczbie triali na warunek [2(1.Words|2.Pseudo) x subjects]
    
 
    for subIdx = 1:length(subjects)
 
        %    składamy nazwę pliku
        if subjects(subIdx) < 10
            nameOfSubj = ['B0' num2str(subjects(subIdx))];
        else
            nameOfSubj = ['B' num2str(subjects(subIdx))];
        end
 
        % wczytujemy plik:
        EEG = pop_loadset('filename',[nameOfSubj addName,'.set'],'filepath',directoryIn);
        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG,EEG,0);
        EEG = eeg_checkset( EEG);
 
        % dla danej osoby iterujemy się po trialach
 
        for trial = 1:EEG.trials
%             if ~(EEG.reject.rejconst(1,trial) || EEG.reject.rejthresh(1,trial))   % wybieramy tylko triale bez artefaktow 
                type = strcmp(EEG.epoch(1,trial).eventtype,'Pseudo')+1; % określamy kategorię trialu: 
                                                         % dla triali  Pseudo, strcmp da wartość True, czyli 1 więc w wyniku dostaniemy 2,
                                                         % cała reszta to słowa i dla nich wynik porównania strcmp da fałsz , czyli 0 
                data(type,subIdx,:,:) = squeeze(data(type,subIdx,:,:)) + squeeze(EEG.data(:,:,trial)); % i sumujemy ich 
                                                         % przebiegi dla każdej z dwoch kategorii: Words/Pseudo, żeby wymiary
                                                         % dodawanych macierzy się zgadzały musimy wpierw usunąć wymiary singletowe
                trialNb(type,subIdx) = trialNb(type,subIdx) + 1;
%             end
        end
 
        % dzielimy przebiegi przez zliczenia triali w kategorii aby uzyskac sredni przebieg
        data(1,subIdx,:,:) = data(1,subIdx,:,:)/squeeze(trialNb(1,subIdx));
        data(2,subIdx,:,:) = data(2,subIdx,:,:)/squeeze(trialNb(2,subIdx));
        disp(['preparujDane ----------- dane ' nameOfSubj ' :   GOTOWE ----------------'])
 
    end
    % przywracamy stan wejściowy zmiennych globalnych eeglaba
       ... 
 
end