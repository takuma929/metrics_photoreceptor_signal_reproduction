% First developed by ACS, modified by TM.
function data = load_data()
%load_data  Load the consolidated project data store (data/data.mat).
%   data = load_data() returns the struct `data` whose fields hold every input
%   dataset (real-world spectra, display primaries, colour-matching functions,
%   TM-30 static data, Asano observers, etc.). See build_data_mat.m for how the
%   store is assembled and for the full field list.
%
%   The store (~37 MB) is loaded once and cached, so repeated calls in a loop
%   are cheap.
    persistent CACHE
    if ~isempty(CACHE)
        data = CACHE;
        return;
    end
    root = fileparts(fileparts(fileparts(mfilename('fullpath'))));  % src/functions -> src -> root
    S = load(fullfile(root, 'data', 'data.mat'), 'data');
    CACHE = S.data;
    data = CACHE;
end
