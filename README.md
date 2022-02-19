# ERPsAmpLatency

1.	Export analyzed participant Difference Waves from BrainVision Analyzer in MATLAB format.
2.	Place all of the difference waves in an appropriate folder and ensure an EXACTLY consistent naming convention, each file MUST start with the participant number. Format: P#_EXPERIMENT_Diff._Waves_PARADIGM.mat (See example)
![FileNames](https://github.com/awscoder/ERPsAmpLatency/blob/main/Picture1.png)
3.	On a computer with access to these files and with MATLAB installed launch the app by double-clicking on EPRsAmpLatency_GUI.m
4.	Click the green triangle that says “Run” at the top of the screen  
5.	A window will appear within a few seconds with boxes to be configured to fit the specific study.
![AppWindow](https://github.com/awscoder/ERPsAmpLatency/blob/main/Picture4.jpg)
6.	There are defaults in each box, be sure to fit the formatting exactly

Folder: The file path where you saved the difference waves in step 2.

Paradigms: The conditions of the study as listed in the filenames (used to import the files, so it must be exact or you will get errors). The example here is the paradigms of TargetAnimation-NonTargetAnimation and TargetStill-NonTargetStill (abbreviated TA-NTA and TS-NTS in the filenames. Separate paradigms by a semi-colon, no spaces.

File Identifier: The bit of the filename that comes after the participant number and identifies which study and that these files are difference waves. Again, used to import files so must be exact or you will get errors.

Number of Participants: How many participants are being evaluated. Will look for a file for every participant number and paradigm (e.g. you have 10 participants and 2 paradigms, there should be 20 difference wave files in your Folder).

Stimulus Start Time: The time (in seconds) determined for the study (usually 0.1 or 0.2)

Regions: The electrodes to be used to calculate the amplitudes and latencies. Each Region must be in square brackets, separated by semi-colons. To define the electrodes in the region a) list them out with commas between electrodes, or b) for a continuous numeric sequence of electrodes separate the first and last electrode in the sequence with a colon. (e.g. I want 7, 8 , and 9 so I could put 7,8,9 or 7:9). See example

Region Labels: Provide a name for the region defined in the Regions box. Must be in the same order as the regions as the first label will be applied to the first region, etc. Separate names by a semi-colon, no spaces.

EPRs: Name the ERPs to be analyzed. Must begin with a P or N, (e.g. P300 or N170). Separate by semi-colons, no spaces.

ERP Ranges: Provide a time range (in seconds) for the ERPs defined in the ERPs box. Must be in the same order as the ERPs as the first range will be applied to the first ERP, etc. List a lower bound and upper bound separated by a comma and separate ranges by a semi-colon. (e.g. 0.20,0.70;0.09,0.23)

7.	Once all the configurations are appropriately set, click “Run” at the bottom of the window.

8.	It will take different lengths of time depending on the computer used, the number of participants, paradigms, and regions. But for the example given, it took about 30 seconds to run.

9.	Two Excel files will be exported in the folder where you initially launched the ERPsAmpLatency_GUI.m file from. One will be called Results-BCI-ERPs-Amplitudes-DATE.XSLX and the other Results-BCI-ERPs-Latency-DATE.XLSX
![SheetNames](https://github.com/awscoder/ERPsAmpLatency/blob/main/Picture5.png)

a.	Sheet1 will be blank, and the rest of the sheets break down the amplitude or latency based on the regions and ERPs.

b.	The electrode is on the top row and the paradigms beneath it. Each row below those 2 is a participant so 1 is P1, 2 is P2.

c.	If you go to the far-right columns of a region sheet, there will be averages for each participant and each paradigm. In the example below, the average amplitude of P1’s Parietal-Occipital N170 for the TA-NTA paradigm is -2.50571 and -2.25451 for the TS-NTS paradigm.
![Amplitudes](https://github.com/awscoder/ERPsAmpLatency/blob/main/Picture6.png)
