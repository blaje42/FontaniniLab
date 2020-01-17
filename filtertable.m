function TABLEfiltered = filtertable(TABLE,varargin)
%Filter table based on indicated values for various variables in TABLE
%
% Inputs:
%   TABLE (table) = matlab table
%   varargin (string, various) = table variables to be filtered and
%                               filters. Filters can be string/char, double, cell of string/char, cell
%                               of doubles
%               EXAMPLE: filtertable(TABLE,'Sex','F','Genotype',{'TDP43 Ctrl','TDP43 WT'}, 'age',[-Inf 40])
%               Note - non-string/char cell/array inputs are treated as ranges and must be
%               an array [min max]
%
% Outputs:
%   TABLEfiltered (table) = TABLE containing only rows matching filters

%To Add:
% 1. Date range?
                

nCat = (nargin-1)/2; %Number of variables being used to filter

IDX = [];
IDXall = cell(1,nCat);
for i = 1:nCat
    TableVar = TABLE.(varargin{2*i-1});

                
    if iscellstr(varargin{2*i})
        for j = 1:length(varargin{2*i})
            VarIDX = find(strcmp(TableVar,varargin{2*i}{j}));
            IDX = [IDX; VarIDX];
        end
        IDXall{i} = IDX;
    elseif iscell(varargin{2*i})
        for j = 1:length(varargin{2*i})
            VarIDX = find(TableVar > varargin{2*i}{j}(1) & TableVar < varargin{2*i}{j}(2));
            IDX = [IDX; VarIDX];
        end
        IDXall{i} = IDX;
    else 
        if ischar(varargin{2*i}) | isstring(varargin{2*i})
            VarIDX = find(strcmp(TableVar,varargin{2*i}));
            IDXall{i} = VarIDX;
        else
            VarIDX = find(TableVar > varargin{2*i}(1) & TableVar < varargin{2*i}(2));
            IDXall{i} = VarIDX;
        end
    end
end

uniqueIDX = intersectcell(IDXall);

TABLEfiltered = TABLE(uniqueIDX,:);


function runIntersect = intersectcell(A)
% Find intersect of multiple arrays
%
% Inputs:
%   A (cell) = cell of arrays
%   
% Outputs:
%   runIntersect (array) = array containing intersect of all cells in A

    flag = 0;
    if isempty(A)
        error('No inputs specified.')
    else
        if isequal(A{end},'rows')
            flag = 'rows';
            setArray = A(1:end-1);
        else
            setArray = A;
        end
    end
    runIntersect = setArray{1};

    for w = 2:length(setArray)

        if isequal(flag,'rows')
            runIntersect = intersect(runIntersect,setArray{w},'rows');
        elseif flag == 0
            runIntersect = intersect(runIntersect,setArray{w});
        else 
            error('Flag not set.')
        end

        if isempty(runIntersect)
            return
        end

    end
end

end