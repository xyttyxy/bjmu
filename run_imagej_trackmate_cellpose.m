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

% Get images
% imp = ij.ImagePlus('/Users/tinevez/Desktop/Data/FakeTracks.tif');
imps = ij.plugin.FolderOpener.open('D:\Work\tailin\wanghuan\DATA示例\DATA\merged\w1_aligned');
imps.show();
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
settings = Settings( imps );

% Configure detector - We use a java map
settings.detectorFactory = CellposeDetectorFactory();
map = java.util.HashMap();
map.put('DO_SUBPIXEL_LOCALIZATION', true);
map.put('RADIUS', 2.5);
map.put('TARGET_CHANNEL', Integer.valueOf(1)); % Needs to be an integer, otherwise TrackMate complaints.
map.put('THRESHOLD', 0);
map.put('DO_MEDIAN_FILTERING', false);
settings.detectorSettings = map;

% check what features cellpose will return. Apparently it does not return
% anything
