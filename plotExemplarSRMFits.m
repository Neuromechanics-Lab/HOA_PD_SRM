function plotExemplarSRMFits(data)
% function plotExemplarSRMFits(data)
%
% plot three example cases

exemplarPatients = ["bat206" "bat114" "pdf027"];
pertdir = 270;
side = "L";

% bat206:
% 22F
% MoCA = 26

% bat114:
% 64M
% MoCA = 26

% pdf027:
% 62F
% pd duration 4.9y
% mds-updrs-iii 55/132
% no freezing


flipTA = false;

XL = [0 1];
YL = [0 1];

atime = data.atime(1,:);
lookup = atime>=min(XL)&atime<max(XL);
fig = figure;
for pi = 1:length(exemplarPatients)
    ta = data(data.patient==exemplarPatients(pi)&data.pertdir==pertdir&data.side==side&data.mus=="TA",:);
    mg = data(data.patient==exemplarPatients(pi)&data.pertdir==pertdir&data.side==side&data.mus=="MGAS",:);
    
    if flipTA
        s = subplot(2,3,pi);
        xlim(XL)
        ylim(YL)
        
        plot(atime(lookup),mg.e(lookup),'k','linewidth',0.5,'clipping','off');
        plot(atime(lookup),mg.eRecon(lookup),'g','linewidth',0.5,'clipping','off');
        plot(atime(lookup),mg.eRecon(lookup),'k','linewidth',1,'clipping','off');
        
        s = subplot(2,3,pi+3)
        xlim(XL)
        ylim(sort(-1*YL))
        
        plot(atime(lookup),-ta.e(lookup),'k','linewidth',0.5,'clipping','off');
        plot(atime(lookup),-ta.eRecon(lookup),'g','linewidth',0.5,'clipping','off');
        plot(atime(lookup),-ta.ePrimeRecon(lookup),'r','linewidth',0.5,'clipping','off');
        plot(atime(lookup),-ta.eTotalRecon(lookup),'k','linewidth',1,'clipping','off');
    else
        s = subplot(2,3,pi);
        xlim(XL)
        ylim(YL)
        
        a = area(atime(lookup),mg.eRecon(lookup));
        a.FaceColor = [0 1 0];
        a.EdgeColor = 'none';
        
        plot(atime(lookup),mg.e(lookup),'k','linewidth',0.5,'clipping','off');
        plot(atime(lookup),mg.eRecon(lookup),'k','linewidth',1,'clipping','off');
        
        VAF = rsqr_uncentered(mg.e(lookup)',mg.eRecon(lookup)');
        R2 = rsqr(mg.e(lookup)',mg.eRecon(lookup)');
        VAFstr = "VAF = "+sprintf('%0.2f',VAF);
        R2str = "R2 = "+sprintf('%0.2f',R2);
        txt = text(max(s.XLim),max(s.YLim),[VAFstr;R2str]);
        txt.HorizontalAlignment = 'right';
        txt.VerticalAlignment = 'top';
        
        s = subplot(2,3,pi+3)
        xlim(XL)
        ylim(YL)
        
        a = area(atime(lookup),ta.eRecon(lookup));
        a.FaceColor = [0 1 0];
        a.EdgeColor = 'none';
        a = area(atime(lookup),ta.ePrimeRecon(lookup));
        a.FaceColor = [1 0 0];
        a.EdgeColor = 'none';
        plot(atime(lookup),ta.e(lookup),'k','linewidth',0.5,'clipping','off');
        plot(atime(lookup),ta.eTotalRecon(lookup),'k','linewidth',1,'clipping','off');
        
        VAF = rsqr_uncentered(ta.e(lookup)',ta.eTotalRecon(lookup)');
        R2 = rsqr(ta.e(lookup)',ta.eTotalRecon(lookup)');
        VAFstr = "VAF = "+sprintf('%0.2f',VAF);
        R2str = "R2 = "+sprintf('%0.2f',R2);
        txt = text(max(s.XLim),max(s.YLim),[VAFstr;R2str]);
        txt.HorizontalAlignment = 'right';
        txt.VerticalAlignment = 'top';
        
    end
end

end
