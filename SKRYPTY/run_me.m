%% USTAWIENIA:
directoryIn  = '../DANE/';                       % lokalizacja folderu z surowymi danymi
directoryOut = '../DANE/';                       % lokalizacja do zapisu przygotowanych danych
addName      = '_epoch';                        % dodatek do nazwy pliku przy zapisywaniu przygotowanych danych
subjects     = [1:6,8:11 ,15:24,26:37];         % lista badanych do wczytania (z poprawnymi danymi)
LowFreqCut   = 0.1;                             % granica odciecia filtru gornoprzepustowego Hz
HighFreqCut  = 30;                              % granica odciecia filtru dolnoprzepustowego Hz
startT       = -0.3;                            % start do wyciecia epok [s]
stopT        = 1.0;                             % stop do wyciecia epok [s]
eegChan      = 1:19;                            % numery kanalow EEG
baseline     = [-200, 0];                       % baseline [od,do] [ms] do odjecia
 
 
%% FILTROWANIE i CIECIE
 
 
eeglab
%filtruj_i_tnij(EEG , ALLEEG , CURRENTSET, directoryIn, directoryOut, addName, subjects, LowFreqCut, HighFreqCut, startT, stopT, eegChan, baseline)

%% Automatyczne usowanie artefaktow
EEG = pop_loadset('filename', 'B01_epoch.set', 'filepath', directoryIn); % wczytujemy przykładowy  set z danymi, aby struktury EEG miały sensowne wartości
abnormalValue = 35                            % wartosc [uV] powyzej/ponizej(na minusie) ktorej oznaczane sa artefakty
abnormalTrend = 50                     % [max slope [uV/epoch], R squared limit (0-1)]
% oznaczArtefakty(EEG , ALLEEG , CURRENTSET, directoryOut, addName, subjects, abnormalValue, abnormalTrend)

%% przygotowanie danych
 
% data = preparujDane(EEG , ALLEEG , CURRENTSET, directoryOut, addName, subjects);

%% GFP1
 
timeMarks = [100,300,380,720]; %wpiszmy tu czasy z artykułu
plotGFP(data,startT,stopT,EEG.srate,timeMarks,EEG.chanlocs) 
 
%% GFP2 - ewentualnie można  powyższe czasy można poprawić

%% ANOVA
% O1 O2 T5 P3 Pz P4 T6 T3 C3 Cz C4 T4 F7 F3 Fz F4 F8 Fp1 Fp2
% 1   2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17  18  19
ROI.channels = [[18,13];[15,10];[19,17];[9,4];[11,6]];
ROI.labels   = {'LF','CF','RF','LP','RP'};
N_win = length(timeMarks)-1;
 
dataANOVA = preparujDaneDlaANOVA(data,timeMarks,ROI,startT,stopT,EEG.srate);
% dataANOVA - [5 okien czasowych x obserwacje x |1.srednia amplituda 2. subject 3.slowo(0)/pseudo(1) 4.ROI|] 
 
 
for window = 1:N_win
    dANOVA = squeeze(dataANOVA(window,:,:));
    stats  = rm_anova2(dANOVA(:,1),dANOVA(:,2),dANOVA(:,3),dANOVA(:,4),{'type','ROI'});
    stats2 = PostHocStats(stats, dANOVA, ROI, N_win);
 
    disp(['------------- Time window: ' num2str(timeMarks(window)) '-' num2str(timeMarks(window+1)) '-------------'])
    disp(stats)
    disp(stats2)
end