function[result] = isEqualFuncs(a, b, ignoreFields)
% [result] = isEqualFuncs(a, b, [ignoreFields])
%
% Same as isequal(a, b), but:
%  - function handles are matched as strings.
%  - the order of fields in a struct does not matter.
%
% Copyright by Holger Caesar, 2014

if ~exist('ignoreFields', 'var'),
    ignoreFields = {};
end;

result = true;

% Check size
if any(size(a) ~= size(b)),
    result = false;
    return;
end;

if (isstruct(a) && isstruct(b)) ...
        || (isobject(a) && isobject(b)),
    % Structs and class objects
    
    % Check if field names of a and b are the same
    fieldsA = fieldnames(a);
    fieldsB = fieldnames(b);
    
    % Remove ignoreFields
    fieldsA = setdiff(fieldsA, ignoreFields);
    fieldsB = setdiff(fieldsB, ignoreFields);
    
    % Sort fields
    fieldsA = sort(fieldsA);
    fieldsB = sort(fieldsB);
    
    if ~isequal(fieldsA, fieldsB),
        result = false;
        differElements = setdiff(union(fieldsA, fieldsB), intersect(fieldsA, fieldsB));
        fprintf('Warning: a and b do not have the same fields: %s\n', strjoin(differElements, ', '));
        return;
    end;
    
    fieldCount = numel(fieldsA);
    for fieldIdx = 1 : fieldCount,
        fieldName = fieldsA{fieldIdx};
        
        % Ignore specified fields
        if ismember(fieldName, ignoreFields),
            continue;
        end;
        
        if ~isEqualFuncs({a.(fieldName)}, {b.(fieldName)}, ignoreFields),
            result = false;
            fprintf('Warning: Field %s differs!\n', fieldName);
            return;
        end;
    end;
elseif isa(a, 'function_handle') && isa(b, 'function_handle'),
    % Functions
    result = isequal(func2str(a), func2str(b));
elseif iscell(a) && iscell(b),
    % Cells
    for i = 1 : numel(a),
        if ~isEqualFuncs(a{i}, b{i}, ignoreFields),
            result = false;
            fprintf('Warning: Cell element %d differs!\n', i);
            return;
        end;
    end;
else
    % Everything else
    result = isequal(a, b);
end;