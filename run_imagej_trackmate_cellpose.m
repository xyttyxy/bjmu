% NOTE: need to set %PATH% correctly for numpy to work. easiest way 
import java.lang.Integer

import ij.IJ

import fiji.plugin.trackmate.TrackMate
import fiji.plugin.trackmate.Model
import fiji.plugin.trackmate.Settings
import fiji.plugin.trackmate.SelectionModel
import fiji.plugin.trackmate.Logger
import fiji.plugin.trackmate.features.FeatureFilter
import fiji.plugin.trackmate.detection.LogDetectorFactory
import fiji.plugin.trackmate.cellpose.CellposeDetectorFactory
import fiji.plugin.trackmate.tracking.sparselap.SparseLAPTrackerFactory
import fiji.plugin.trackmate.tracking.LAPUtils
import fiji.plugin.trackmate.gui.displaysettings.DisplaySettingsIO
import fiji.plugin.trackmate.gui.displaysettings.DisplaySettings
import fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer
import fiji.plugin.trackmate.action.ExportTracksToXML

% Get images
% imp = ij.ImagePlus('/Users/tinevez/Desktop/Data/FakeTracks.tif');
imp = ij.plugin.FolderOpener.open('D:\Work\tailin\wanghuan\DATA示例\DATA\merged\w1_aligned');
imp.show();
%
%----------------------------
% Create the model object now
%----------------------------
   
% Some of the parameters we configure below need to have
% a reference to the model at creation. So we create an
% empty model now.
model = Model();

% Send all messages to ImageJ log window.
model.setLogger( Logger.IJ_LOGGER );

%------------------------
% Prepare settings object
%------------------------
settings = Settings( imp );

% Configure detector - We use a java map
settings.detectorFactory = CellposeDetectorFactory();
map = java.util.HashMap();
map.put('CELLPOSE_PYTHON_FILEPATH', 'D:\Miniconda\envs\ast240\python.exe');
% import fiji.plugin.trackmate.cellpose.CellposeSettings;
% import fiji.plugin.trackmate.cellpose.CellposeUtils;
% cpUtils = CellposeUtils();
% dummyClass = cpUtils.getClass();
% dummyLoader = dummyClass.getClassLoader();
% pretrainedModelClass = java.lang.Class.forName('fiji.plugin.trackmate.cellpose.CellposeSettings$PretrainedModel', true, dummyLoader);
% cpmodel = pretrainedModelClass();
cpmodel = javaMethod('valueOf', 'fiji.plugin.trackmate.cellpose.CellposeSettings$PretrainedModel', 'CYTO');
% pretrainedModelFields = pretrainedModelClass.getFields();
% cpmodel = pretrainedModelFields(1); 
map.put('CELLPOSE_MODEL', cpmodel);
map.put('LOGGER', Logger.IJ_LOGGER);
map.put('CELLPOSE_MODEL_FILEPATH', ""); % Expected java.lang.String
map.put('TARGET_CHANNEL', Integer.valueOf(0));% Needs to be an integer, otherwise TrackMate complaints.
map.put('OPTIONAL_CHANNEL_2', Integer.valueOf(0)); % Same thing
map.put('CELL_DIAMETER', 0); % Same thing
map.put('SIMPLIFY_CONTOURS', true); 
map.put('USE_GPU', true);
settings.detectorSettings = map;

% check what features cellpose will return. Apparently it does not return
% anything
% filter1 = FeatureFilter('QUALITY', 50., true);
% settings.addSpotFilter(filter1)

% Configure tracker - We want to allow splits and fusions
settings.tstart = 0; % they can be used to control which image to process?
settings.tend = 49; % needed for interval to be set correctly
settings.trackerFactory  = SparseLAPTrackerFactory();
settings.trackerSettings = LAPUtils.getDefaultLAPSettingsMap(); % almost good enough
settings.trackerSettings.put('ALLOW_TRACK_SPLITTING', true);
settings.trackerSettings.put('ALLOW_TRACK_MERGING', true);

% Configure track analyzers - Later on we want to filter out tracks 
% based on their displacement, so we need to state that we want 
% track displacement to be calculated. By default, out of the GUI, 
% not features are calculated. 

% Let's add all analyzers we know of.
settings.addAllAnalyzers()

% Configure track filters - We want to get rid of the two immobile spots at 
% the bottom right of the image. Track displacement must be above 10 pixels.
filter2 = FeatureFilter('TRACK_DISPLACEMENT', 10.0, true);
settings.addTrackFilter(filter2)

%-------------------
% Instantiate plugin
%-------------------

trackmate = TrackMate(model, settings);
import fiji.plugin.trackmate.gui.GuiUtils.userCheckImpDimensions
userCheckImpDimensions(imp);

%--------
% Process
%--------
   
ok = trackmate.checkInput();
if ~ok
    display(trackmate.getErrorMessage())
end

ok = trackmate.process();
if ~ok
    display(trackmate.getErrorMessage())
end
      
%----------------
% Display results
%----------------

% Read the user default display setttings.
ds = DisplaySettingsIO.readUserDefault();

% Big lines.
ds.setLineThickness( 3. )

selectionModel = SelectionModel( model );
displayer = HyperStackDisplayer( model, selectionModel, imp, ds );
displayer.render()
displayer.refresh()
   
% Echo results
display( model.toString() )

outputFilename = 'D:\Work\tailin\wanghuan\DATA示例\DATA\merged\w1_aligned\test.xml';
outFile = java.io.File(outputFilename);
% this only saves a simplified version that does not account for splitting,
% merging, and gaps, and cannot be re-imported. DO NOT USE.
% ExportTracksToXML.export(model, settings, outfile)

import fiji.plugin.trackmate.io.TmXmlWriter
xmlwriter = TmXmlWriter(outfile);
% just missing the log file now
xmlwriter.appendLog(' ');
xmlwriter.appendModel(trackmate.getModel());
xmlwriter.appendSettings(trackmate.getSettings());
xmlwriter.appendDisplaySettings(ds);

% xmlwriter.writeToFile(); % Cannot use, directly save
% string:
str = xmlwriter.toString();
fid = fopen('test.xml', 'w');
fprintf(fid, '%s\n', str);
fclose(fid);
    