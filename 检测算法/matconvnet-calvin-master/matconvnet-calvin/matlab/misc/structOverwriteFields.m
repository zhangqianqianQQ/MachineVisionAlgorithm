function[oldStruct] = structOverwriteFields(oldStruct, newStruct)
% [oldStruct] = structOverwriteFields(oldStruct, newStruct)
%
% Copies all fields from newStruct to oldStruct, regardless of whether they
% existed before in oldStruct.
%
% Copyright by Holger Caesar, 2016

fieldsNew = fieldnames(newStruct);

for fieldIdx = 1 : numel(fieldsNew),
    fieldName = fieldsNew{fieldIdx};
    oldStruct.(fieldName) = newStruct.(fieldName);
end;