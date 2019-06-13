function Wh = walsh_hadamard(m)
    Wh2=[1 1;1 -1];
    if m==2
        Wh=Wh2;
    end
    if m~=2
        Wh = (kron(Wh2,eye(m/2)))*(kron(eye(2),walsh_hadamard(m/2)));
    end
        
    
end