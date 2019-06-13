function t = benchinpoly(xv, yv, ntest)

n=1e5;

if nargin<3
    ntest=100;
end
t=nan(ntest,3);

if isempty(which('inpoly'))
    mplot = 2;
else
    mplot = 3;
end

for k=1:ntest
    
    fprintf('k=%d/%d\n', k, ntest);
    
    x=rand(n,1);
    y=rand(n,1);
    
    tic
    in = inpolygon(x, y, xv, yv);
    t(k,1) = toc;
    
    tic
    in = insidepoly(x, y, xv, yv, 'presortflag', 0);
    t(k,2) = toc;
    
    if strfind(which('inpoly'),'mex')
        tic
        in = inpoly([x y]', [xv yv]');
        t(k,3) = toc;
    elseif ~isempty(which('inpoly'))
        tic
        in = inpoly([x y], [xv yv]);
        t(k,3) = toc;
    end
    
end

figure;
subplot(2,mplot,1:mplot);
h=plot(t);
color=get(h,'Color');
if ~isempty(which('inpoly'))
    legend('Matlab inpolygon','BL''s insidepoly','DE''s inpoly','Location','best');
else
    legend('Matlab inpolygon','BL''s insidepoly','Location','best');
end
ylabel('time [s]');
xlabel('Test #');
title(sprintf('ntest=%d, npnt=%d, poly=%d vertices', ntest, n, length(xv)));

subplot(2,mplot,mplot+1);
hist(t(:,1),16);
set(findobj(gca,'Type','patch'),'FaceColor',color{1});
title('Matlab inpolygon,');
title(sprintf('Matlab inpolygon, mean=%f [s]', mean(t(:,1))));
xlabel('time [s]');
ylabel('count');
legend(sprintf('mean=%f [s]', mean(t(:,1))));

subplot(2,mplot,mplot+2);
hist(t(:,2),16);
set(findobj(gca,'Type','patch'),'FaceColor',color{2});
title('BL''s insidepoly');
xlabel('time [s]');
ylabel('count');
legend(sprintf('mean=%f [s]', mean(t(:,2))));

if ~isempty(which('inpoly'))
    subplot(2,mplot,mplot+3);
    hist(t(:,3),16);
    set(findobj(gca,'Type','patch'),'FaceColor',color{3});
    if strfind(which('inpoly'),'mex')
        title('DE/SP''s inpoly');
    else
        title('DE''s inpoly');
    end
    xlabel('time [s]');
    ylabel('count');
    legend(sprintf('mean=%f [s]', mean(t(:,3))));
end