classdef ERPsAmpLatency_GUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        PatientsDisplayUIFigure        matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        LeftPanel                      matlab.ui.container.Panel
        RunButton                      matlab.ui.control.Button
        ERPRangesEditField             matlab.ui.control.EditField
        ERPRangesEditFieldLabel        matlab.ui.control.Label
        FileIdentifierEditField        matlab.ui.control.EditField
        FileIdentifierEditFieldLabel   matlab.ui.control.Label
        ParadigmsFromFilenamesEditField  matlab.ui.control.EditField
        ParadigmsFromFilenamesEditFieldLabel  matlab.ui.control.Label
        ERPsEditField                  matlab.ui.control.EditField
        ERPsEditFieldLabel             matlab.ui.control.Label
        RegionLabelsEditField          matlab.ui.control.EditField
        RegionLabelsEditFieldLabel     matlab.ui.control.Label
        RegionsEditField               matlab.ui.control.EditField
        RegionsEditFieldLabel          matlab.ui.control.Label
        StimulusStartTimeseg01EditField_2  matlab.ui.control.NumericEditField
        StimulusStartTimeseg01Label    matlab.ui.control.Label
        NumberofParticipantsEditField  matlab.ui.control.NumericEditField
        NumberofParticipantsEditFieldLabel  matlab.ui.control.Label
        DataSelectionLabel             matlab.ui.control.Label
        Panel2_4                       matlab.ui.container.Panel
        DatasetDirectoryEditField      matlab.ui.control.EditField
        RightPanel                     matlab.ui.container.Panel
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    % The app displays the data by using the scatter plot, histogram, and table.
    % It makes use of tabs to separate the ploting options output from the table display of the data.
    % There are several graphical elements used such as checkboxes, slider, switch, dropdown, and radiobutton group.
    % The data used in the app is shipped with the product.
    
    properties (Access = public)
        % Declare properties of the PatientsDisplay class.

    end
    
    methods (Access = public)
        
        
        
        
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.PatientsDisplayUIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {400, 400};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {691, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end

        % Button pushed function: RunButton
        function GenerateAmpLatency(app, event)
            %% Dataset (Hard Coded)
            updateAppLayout(app)
            DatasetFold = [app.DatasetDirectoryEditField.Value]; %Location of data
            PtSize = app.NumberofParticipantsEditField.Value; %The Number of Participants in the Dataset
            
              
            %% Regions
            Regions.Chann = app.RegionsEditField.Value;
            ERPs.Regions.Chann = (split(Regions.Chann, ';'));
            for n = 1:length(ERPs.Regions.Chann)
                ERPs.Regions.Chann{n} = (split(ERPs.Regions.Chann{n}, ','));
            end
            RegionDictionary = containers.Map(...
                {'FP1', 'FZ', 'F3', 'F7', 'FT9', 'FC5', 'FC1', 'C3', 'T7', 'TP9', 'CP5', 'CP1', 'PZ',...
                 'P3','P7','O1','OZ','O2','P4','P8','TP10','CP6','CP2','CZ','C4','T8','FT10','FC6','FC2','F4','F8','FP2'},...
                {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13',...
                 '14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32'});
            
            for i = 1:numel(ERPs.Regions.Chann)
                for n = 1:length(ERPs.Regions.Chann{i})
                    ERPs.Regions.Nums{i}{n} = RegionDictionary(ERPs.Regions.Chann{i}{n});
                end
                ERPs.Regions.Nums{i} = cellfun(@str2num,ERPs.Regions.Nums{i},'un',0);
            end


            Regions.Labels = split(app.RegionLabelsEditField.Value, ';');
            
            % 1) a frontal bin, 
            % 2) a central bin, 
            % 3) a parietal-occipital bin
            %% ERP features
            StimulousStart = app.StimulusStartTimeseg01EditField_2.Value; %seconds
            
            ERPs.Ranges = split(app.ERPRangesEditField.Value, ';'); %Splits each ranges into a cell
            ERPs.Ranges = split(ERPs.Ranges, ','); %Splits each cell into an array with the upper and lower value

            for n = 1:length(ERPs.Ranges) %Adds the stiumulus start time to the upper and lower values of the ERP Ranges
                for i = 1:2
                    try
                        ERPs.Ranges{n,i} = str2double(ERPs.Ranges{n,i}) + StimulousStart;
                    catch
                        if n == 2
                            break
                        end
                        ERPs.Ranges = {ERPs.Ranges{1},ERPs.Ranges{2}};
                        ERPs.Ranges{1,2} = str2double(ERPs.Ranges{1,2}) + StimulousStart;
                            break
                    end
                end
            end
           
            
            ERPs.Tags = split(app.ERPsEditField.Value, ';');
            
            Paradigms = app.ParadigmsFromFilenamesEditField.Value; %Target v. NonTarget for Animated and Still conditions
            Paradigms = split(Paradigms,';'); %Splits each paradigm into a cell
            Num_Paradigms = length(Paradigms); %Creates a variable equal to the number of paradigms
            
            ERPsName = '';
            for i = 1:numel(ERPs.Tags)
                ERPsName = [ERPsName , char(ERPs.Tags{i})];
            end
            XLNameAmp = [ERPsName,'-Amplitudes-',datestr(now,'mmmm-dd-yyyy_HH_MM_SS'),'.xlsx'];
            XLNameLat = [ERPsName,'-Latency-',datestr(now,'mmmm-dd-yyyy_HH_MM_SS'),'.xlsx'];
            
            
            %% Reading Samples (Edit which participants to skip here(if applicable))
            
            for o = 1:Num_Paradigms %Iterates through the paradigms (e.g. Grid, RandLoc)
                for pt = 1:PtSize %Iterates through every participant in the dataset
                    
                    tmpfileAdd = [DatasetFold 'P' num2str(pt) app.FileIdentifierEditField.Value Paradigms{o} '.mat'];
                    [PtSegments{pt,o}, Labels, Fs, ChannInfo] = ImportingBCIData(tmpfileAdd);
            
                end
            end
            
            %% ERPs extractions
            
            for f = 1:length(ERPs.Tags)
            
                FeatureMat_DiffTvsNT = [];
                
                tmpHeader = {'Electrode';'Paradigm'};
                for o = 1:Num_Paradigms
                    
                    for pt = 1:PtSize
                        for Elec = 1:32
                            if ERPs.Tags{f}(1) =='P' %Looking at P300 or P600
                                [FeatureMat_DiffTvsNT.Peaks(pt,Num_Paradigms*(Elec-1) + o),Ind] = max(PtSegments{pt,o}(1,Elec,ERPs.Ranges{f,1}*Fs:ERPs.Ranges{f,2}*Fs),[],3);
                            else %Looking at N170 or N400
                                [FeatureMat_DiffTvsNT.Peaks(pt,Num_Paradigms*(Elec-1) + o),Ind] = min(PtSegments{pt,o}(1,Elec,ERPs.Ranges{f,1}*Fs:ERPs.Ranges{f,2}*Fs),[],3);
                            end
                                
                            FeatureMat_DiffTvsNT.Latency(pt,Num_Paradigms*(Elec-1) + o) = ((Ind - 1)/ Fs) + ERPs.Ranges{f}(1) - StimulousStart;
                            tmpHeader{1,Num_Paradigms*(Elec-1) + o + 1} = Labels{Elec};
                            tmpHeader{2,Num_Paradigms*(Elec-1) + o + 1} = Paradigms{o};
                        end
                    end    
                end
                
                XLLine = 1;
                xlswrite(XLNameAmp,tmpHeader,ERPs.Tags{f},['A' num2str(XLLine)]);%Names sheets of Amplitude output file with ERPs.Tags
                xlswrite(XLNameLat,tmpHeader,ERPs.Tags{f},['A' num2str(XLLine)]);%Names sheets of Latency output file with ERPs.Tags
                
                XLLine = XLLine + size(tmpHeader,1);
                xlswrite(XLNameAmp,[[1:PtSize]' , FeatureMat_DiffTvsNT.Peaks ],ERPs.Tags{f},['A' num2str(XLLine)]);
                xlswrite(XLNameLat,[[1:PtSize]' , FeatureMat_DiffTvsNT.Latency ],ERPs.Tags{f},['A' num2str(XLLine)]);
                
                for r = 1:length(ERPs.Regions.Nums) %Makes Regional Sheets
                        XLLine = 1;
                        HeaderInd = [];
                    for i = 1:numel(ERPs.Regions.Nums{r})
                        HeaderInd{i} = (ERPs.Regions.Nums{r}{i} .* ones(Num_Paradigms,1)*Num_Paradigms') - [Num_Paradigms-1:-1:0]';
                    end
                        HeaderInd = cat(2,HeaderInd{:});
                        xlswrite(XLNameAmp,tmpHeader(:,[1,HeaderInd(:)'+1]),[ERPs.Tags{f} '-' Regions.Labels{r}],['A' num2str(XLLine)]);
                        xlswrite(XLNameLat,tmpHeader(:,[1,HeaderInd(:)'+1]),[ERPs.Tags{f} '-' Regions.Labels{r}],['A' num2str(XLLine)]);

                        XLLine = XLLine + size(tmpHeader,1);

                        tmpAverages_Peaks = [mean(FeatureMat_DiffTvsNT.Peaks(:,HeaderInd(1,:)),2)];
                        tmpAverages_Latency = [mean(FeatureMat_DiffTvsNT.Latency(:,HeaderInd(1,:)),2)];
                    
                    for o = 2:Num_Paradigms
                        tmpAverages_Peaks = horzcat(tmpAverages_Peaks,[mean(FeatureMat_DiffTvsNT.Peaks(:,HeaderInd(o,:)),2)]); %generates a column vector containing the mean of each row
                                         
                        tmpAverages_Latency = horzcat(tmpAverages_Latency,[mean(FeatureMat_DiffTvsNT.Latency(:,HeaderInd(o,:)),2)]);
                    end
                    
                    xlswrite(XLNameAmp,[[1:PtSize]' , FeatureMat_DiffTvsNT.Peaks(:,HeaderInd(:)),tmpAverages_Peaks ],[ERPs.Tags{f} '-' Regions.Labels{r}],['A' num2str(XLLine)]);
                    xlswrite(XLNameLat,[[1:PtSize]' , FeatureMat_DiffTvsNT.Latency(:,HeaderInd(:)),tmpAverages_Latency ],[ERPs.Tags{f} '-' Regions.Labels{r}],['A' num2str(XLLine)]);
                end
                
                tmpHeader = {'Electrode';'Paradigm'};
                
                FeatureMat_DiffTvsNT_Regions = [];
                Paradigm_Num_Array = [1:Num_Paradigms];
                
                for r = 1:length(ERPs.Regions.Nums)
                    ElecPara_Indx = [];
                    for i = 1:numel(ERPs.Regions.Nums{r})
                        ElecPara_Indx{i} = (ERPs.Regions.Nums{r}{i} .* ones(Num_Paradigms,1)*Num_Paradigms') - [Num_Paradigms-1:-1:0]';
                    end
                    ElecPara_Indx = cat(2,ElecPara_Indx{:});
%                     ElecPara_Indx = Num_Paradigms*(ERPs.Regions.Nums{r}{i}-1)+Paradigm_Num_Array';
                    
                    for o = 1:Num_Paradigms
            
                        FeatureMat_DiffTvsNT_Regions.Peaks(:,Num_Paradigms*(r-1)+o) = mean(FeatureMat_DiffTvsNT.Peaks(:,ElecPara_Indx(o,:)),2);
                        FeatureMat_DiffTvsNT_Regions.Latency(:,Num_Paradigms*(r-1)+o) = mean(FeatureMat_DiffTvsNT.Latency(:,ElecPara_Indx(o,:)),2);
                        tmpHeader{1,Num_Paradigms*(r-1) + o + 1} = Regions.Labels{r};
                        tmpHeader{2,Num_Paradigms*(r-1) + o + 1} = Paradigms{o};
                    end
                        
                end
                
                XLLine = 1;
                xlswrite(XLNameAmp,tmpHeader,[ERPs.Tags{f} '-Regions'],['A' num2str(XLLine)]);
                xlswrite(XLNameLat,tmpHeader,[ERPs.Tags{f} '-Regions'],['A' num2str(XLLine)]);
                
                XLLine = XLLine + size(tmpHeader,1);
                xlswrite(XLNameAmp,[[1:PtSize]' , FeatureMat_DiffTvsNT_Regions.Peaks ],[ERPs.Tags{f} '-Regions'],['A' num2str(XLLine)]);
                xlswrite(XLNameLat,[[1:PtSize]' , FeatureMat_DiffTvsNT_Regions.Latency ],[ERPs.Tags{f} '-Regions'],['A' num2str(XLLine)]);
                
                
                
            end
               
            
            %% Done        
            disp('---------DONE--------');
            
            %% Functions

            %Changing Structure BCI raw structure:
            function [Segments, Labels, Fs, ChannInfo] = ImportingBCIData(Filename)
                LoadedFile = load(Filename);
                Fs = LoadedFile.SampleRate;
                Channels = LoadedFile.Channels;
                SegmentCount = LoadedFile.SegmentCount;
                ChannelCount = LoadedFile.ChannelCount;
                ChannelNames = {};
%                 for n = 1:ChannelCount
%                     ChannelNames{end+1} = Channels(n).Name;
%                 end
                t = LoadedFile.t;
                Segments = zeros(SegmentCount,ChannelCount,length(t));
                Labels = cell(ChannelCount,1);
                
                for ch = 1:ChannelCount
                    for Seg = 1:SegmentCount
                        Segments(Seg,ch,:) = LoadedFile.(Channels(ch).Name);
                    end
                    Labels{ch} = Channels(ch).Name;
                end
                ChannInfo = Channels;
                Segments(:,33:end,:) = [];
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create PatientsDisplayUIFigure and hide until all components are created
            app.PatientsDisplayUIFigure = uifigure('Visible', 'off');
            app.PatientsDisplayUIFigure.AutoResizeChildren = 'off';
            app.PatientsDisplayUIFigure.Position = [100 100 703 400];
            app.PatientsDisplayUIFigure.Name = 'Amplitude and Latency by ERP';
            app.PatientsDisplayUIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.PatientsDisplayUIFigure);
            app.GridLayout.ColumnWidth = {691, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;
            app.LeftPanel.Scrollable = 'on';

            % Create Panel2_4
            app.Panel2_4 = uipanel(app.LeftPanel);
            app.Panel2_4.AutoResizeChildren = 'off';
            app.Panel2_4.Title = 'Folder';
            app.Panel2_4.Position = [7 322 673 44];

            % Create DatasetDirectoryEditField
            app.DatasetDirectoryEditField = uieditfield(app.Panel2_4, 'text');
            app.DatasetDirectoryEditField.Position = [42 1 631 22];
            app.DatasetDirectoryEditField.Value = '\\secd.unl.edu\pittLab\VSD_EEG_motion\Data\Participant_EEG_data\P12 DiffWaves\';

            % Create DataSelectionLabel
            app.DataSelectionLabel = uilabel(app.LeftPanel);
            app.DataSelectionLabel.HorizontalAlignment = 'center';
            app.DataSelectionLabel.FontSize = 15;
            app.DataSelectionLabel.FontWeight = 'bold';
            app.DataSelectionLabel.Position = [211 365 267 22];
            app.DataSelectionLabel.Text = 'Data Selection';

            % Create NumberofParticipantsEditFieldLabel
            app.NumberofParticipantsEditFieldLabel = uilabel(app.LeftPanel);
            app.NumberofParticipantsEditFieldLabel.HorizontalAlignment = 'right';
            app.NumberofParticipantsEditFieldLabel.Position = [101 243 126 22];
            app.NumberofParticipantsEditFieldLabel.Text = 'Number of Participants';

            % Create NumberofParticipantsEditField
            app.NumberofParticipantsEditField = uieditfield(app.LeftPanel, 'numeric');
            app.NumberofParticipantsEditField.Limits = [0 Inf];
            app.NumberofParticipantsEditField.Position = [243 243 42 22];
            app.NumberofParticipantsEditField.Value = 12;

            % Create StimulusStartTimeseg01Label
            app.StimulusStartTimeseg01Label = uilabel(app.LeftPanel);
            app.StimulusStartTimeseg01Label.HorizontalAlignment = 'right';
            app.StimulusStartTimeseg01Label.Position = [344 243 170 22];
            app.StimulusStartTimeseg01Label.Text = 'Baseline Duration (s) e.g. 0.2';

            % Create StimulusStartTimeseg01EditField_2
            app.StimulusStartTimeseg01EditField_2 = uieditfield(app.LeftPanel, 'numeric');
            app.StimulusStartTimeseg01EditField_2.Position = [529 243 100 22];
            app.StimulusStartTimeseg01EditField_2.Value = 0.2;

            % Create RegionsEditFieldLabel
            app.RegionsEditFieldLabel = uilabel(app.LeftPanel);
            app.RegionsEditFieldLabel.HorizontalAlignment = 'right';
            app.RegionsEditFieldLabel.Position = [39 196 50 22];
            app.RegionsEditFieldLabel.Text = 'Regions';

            % Create RegionsEditField
            app.RegionsEditField = uieditfield(app.LeftPanel, 'text');
            app.RegionsEditField.Position = [104 196 576 22];
            app.RegionsEditField.Value = 'CP6,CP2;OZ,O1,O2,P7,P4,P8,P3';

            % Create RegionLabelsEditFieldLabel
            app.RegionLabelsEditFieldLabel = uilabel(app.LeftPanel);
            app.RegionLabelsEditFieldLabel.HorizontalAlignment = 'right';
            app.RegionLabelsEditFieldLabel.Position = [39 144 82 22];
            app.RegionLabelsEditFieldLabel.Text = 'Region Labels';

            % Create RegionLabelsEditField
            app.RegionLabelsEditField = uieditfield(app.LeftPanel, 'text');
            app.RegionLabelsEditField.Position = [136 144 544 22];
            app.RegionLabelsEditField.Value = 'Central;Parietal-Occipital';

            % Create ERPsEditFieldLabel
            app.ERPsEditFieldLabel = uilabel(app.LeftPanel);
            app.ERPsEditFieldLabel.HorizontalAlignment = 'right';
            app.ERPsEditFieldLabel.Position = [40 92 36 22];
            app.ERPsEditFieldLabel.Text = 'ERPs';

            % Create ERPsEditField
            app.ERPsEditField = uieditfield(app.LeftPanel, 'text');
            app.ERPsEditField.Position = [91 92 208 22];
            app.ERPsEditField.Value = 'P100';

            % Create ParadigmsFromFilenamesEditFieldLabel
            app.ParadigmsFromFilenamesEditFieldLabel = uilabel(app.LeftPanel);
            app.ParadigmsFromFilenamesEditFieldLabel.HorizontalAlignment = 'right';
            app.ParadigmsFromFilenamesEditFieldLabel.Position = [9 285 161 22];
            app.ParadigmsFromFilenamesEditFieldLabel.Text = 'Paradigms (From Filenames)';

            % Create ParadigmsFromFilenamesEditField
            app.ParadigmsFromFilenamesEditField = uieditfield(app.LeftPanel, 'text');
            app.ParadigmsFromFilenamesEditField.Position = [176 285 177 22];
            app.ParadigmsFromFilenamesEditField.Value = 'TA-NTA;TS-NTS';

            % Create FileIdentifierEditFieldLabel
            app.FileIdentifierEditFieldLabel = uilabel(app.LeftPanel);
            app.FileIdentifierEditFieldLabel.HorizontalAlignment = 'right';
            app.FileIdentifierEditFieldLabel.Position = [362 285 74 22];
            app.FileIdentifierEditFieldLabel.Text = 'File Identifier';

            % Create FileIdentifierEditField
            app.FileIdentifierEditField = uieditfield(app.LeftPanel, 'text');
            app.FileIdentifierEditField.Position = [439 285 242 22];
            app.FileIdentifierEditField.Value = '_gridmotion_Diff._Waves_';

            % Create ERPRangesEditFieldLabel
            app.ERPRangesEditFieldLabel = uilabel(app.LeftPanel);
            app.ERPRangesEditFieldLabel.HorizontalAlignment = 'right';
            app.ERPRangesEditFieldLabel.Position = [318 92 75 22];
            app.ERPRangesEditFieldLabel.Text = 'ERP Ranges';

            % Create ERPRangesEditField
            app.ERPRangesEditField = uieditfield(app.LeftPanel, 'text');
            app.ERPRangesEditField.Position = [408 92 273 22];
            app.ERPRangesEditField.Value = '0.070,0.205';

            % Create RunButton
            app.RunButton = uibutton(app.LeftPanel, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateAmpLatency, true);
            app.RunButton.BusyAction = 'cancel';
            app.RunButton.Position = [303 26 100 22];
            app.RunButton.Text = 'Run';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;
            app.RightPanel.Scrollable = 'on';

            % Show the figure after all components are created
            app.PatientsDisplayUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ERPsAmpLatency_GUI

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.PatientsDisplayUIFigure)
            else

                % Focus the running singleton app
                figure(runningApp.PatientsDisplayUIFigure)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.PatientsDisplayUIFigure)
        end
    end
end