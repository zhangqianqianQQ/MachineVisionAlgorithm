function OAPerclass = averagePerclass(OAPerclassCell)
OAPerclass = zeros(numel(OAPerclassCell{1}),1);
for iter = 1:numel(OAPerclassCell)
    OAPerclass = OAPerclass + OAPerclassCell{iter};
end

OAPerclass = OAPerclass / numel(OAPerclassCell);