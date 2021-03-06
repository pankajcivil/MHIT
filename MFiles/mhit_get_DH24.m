function [dh24,Opt]=mhit_get_DH24(discharge,wYear,jDay,wYearList,Opt)
%% Validating the inputs 
validateattributes(discharge,{'single','double'},{'column'});
validateattributes(wYear,{'int16','int32','int64','uint16','uint32','uint64','single','double'},{'column'});
validateattributes(jDay,{'int16','int32','int64','uint16','uint32','uint64','single','double'},{'column'});

if (any(size(discharge)~=size(wYear)))
  error('discharge, year, and month must be of the same size.');
end

if (nargin<4 || isempty(wYearList))
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
if (nargin<5 || isempty(Opt))
  Opt.preference='mean';
  Opt.prefFun=mhit_getPrefFun(Opt.preference);
  [~,Opt]=mhit_get_peakThresh(discharge,wYear,jDay,wYearList,[0.4;0.8],Opt);
else
  if (~isfield(Opt,'preference') || isempty(Opt.preference))
    Opt.preference='mean';
  end
  if (~isfield(Opt,'prefFun') || isempty(Opt.prefFun))
    Opt.prefFun=mhit_getPrefFun(Opt.preference);
  end  
  if (   ~isfield(Opt,'peakThreshPrct') || isempty(Opt.peakThreshPrct) ...
      || ~isfield(Opt,'peakThresh') || isempty(Opt.peakThresh))
    [~,Opt]=mhit_get_peakThresh(discharge,wYear,jDay,wYearList,[0.4;0.8],Opt);
  end
end
%% calculating mh14
thresh=Opt.peakThresh(Opt.peakThreshPrct==40);

eventMaskPerYear=arrayfun(@(wy) discharge(wYear==wy)<thresh , wYearList, 'UniformOutput',false);

maxEventDurationByYear=zeros(numel(wYearList),1);
for wyID=1:numel(wYearList)
  eventStart=find(diff([0;eventMaskPerYear{wyID}])>0);
  eventEnd=find(diff([eventMaskPerYear{wyID};0])<0);
  eventsDuration=eventEnd-eventStart+1;
  if (isempty(eventsDuration))
    maxEventDurationByYear(wyID)=0;
  else
    maxEventDurationByYear(wyID)=max(eventsDuration);
  end
end

dh24=Opt.prefFun(maxEventDurationByYear);
end
