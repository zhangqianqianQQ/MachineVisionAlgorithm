function [winMtx_mask, winThreshold,raazul] = winnerPopOut(VR,nonZeros,meth)


if(~exist('nonZeros','var'))
    nonZeros    = 1;
end
if(~exist('meth','var'))
    meth=2;
end

if(nonZeros==0)
    mn = sum(sum(VR))/prod(size(VR));
else
    mn = sum(sum(VR))/(sum(sum(VR>0))+eps);
end

winMtx_mask = [];
winThreshold = 10;
if (meth ==1)
    m_raazul = max(max(VR))/mn;
 
    raazul = 0.5*m_raazul;
    winThreshold = (raazul+1)*mn;
    winMtx_mask = VR>winThreshold;    
else
    if (meth ==2)
      
        stdd=stdDev(VR,mn,nonZeros);
        m_raazul = (max(max(VR)) - mn)/(stdd+eps);
        raazul = 0.4*m_raazul; 
        winThreshold = mn + raazul*stdd;
        winMtx_mask = VR>winThreshold;        
    elseif(meth == 3)
      
        m_raazul = max(max(VR));
        raazul = 0.5*m_raazul;
        winMtx_mask = VR>raazul;
        winThreshold = raazul;
    end
end

function res = stdDev(mtx,mn,nonZeros)
if(nonZeros==0)
    res = sum(sum(abs(mtx-mn).^2)) / max((prod(size(mtx)) - 1),1);
else
    res = sum(sum((abs(mtx-mn).^2).*(mtx>0))) / max((sum(sum(mtx>0)) - 1),1);
end
res = sqrt(res);
