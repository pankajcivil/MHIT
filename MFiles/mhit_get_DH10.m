function [dh10,Opt]=mhit_get_DH10(discharge,wYear,wYearList,Opt)
%% Validating the inputs 
validateattributes(discharge,{'single','double'},{'column'});
validateattributes(wYear,{'int16','int32','int64','uint16','uint32','uint64','single','double'},{'column'});

if (any(size(discharge)~=size(wYear)))
  error('discharge, year, and month must be of the same size.');
end

if (nargin<3 || isempty(wYearList))
  wYearList=unique(wYear);
else
  validateattributes(wYearList,{'int16','int32','int64','uint16','uint32','uint64','single','double'},{'column'});
  tmpWYearList=unique(wYearList);
  if (   (numel(tmpWYearList) ~= numel(wYearList)) ...
      ||  any(tmpWYearList ~= wYearList) )
    error('mhit_get_MA3: wYearList must have unique values.');
  end
end

%% Checking Options
if (nargin<4 || isempty(Opt))
  Opt.rolling90DayMeanByWYear=arrayfun( @(wy) conv(discharge(wYear==wy),ones(90,1)/90,'valid'), wYearList,'UniformOutput',false);
else
	if (~isfield(Opt,'rolling90DayMeanByWYear') || isempty(Opt.rolling90DayMeanByWYear))
    Opt.rolling90DayMeanByWYear=arrayfun( @(wy) conv(discharge(wYear==wy),ones(90,1)/90,'valid'), wYearList,'UniformOutput',false);
  end
end
%% calculating mh14
maxRolling90DayMeanByWYear=arrayfun(@(wyID) max(Opt.rolling90DayMeanByWYear{wyID}),(1:numel(Opt.rolling90DayMeanByWYear))');
dh10=std(maxRolling90DayMeanByWYear)./mean(maxRolling90DayMeanByWYear)*100;
end
