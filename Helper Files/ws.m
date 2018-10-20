% Copyright (c) 2006, Jeff Dunne
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
%     * Neither the name of the Johns Hopkins Applied Physics Laboratory nor the names
%       of its contributors may be used to endorse or promote products derived
%       from this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.


function [varargout] = ws(varargin)

% ws simulates the existence of multiple workspaces within Matlab.  It is
% akin to having multiple desktops for an operating system.  Each workspace
% has its own set of local and global variables.  While use of this
% function makes the most obvious sense for working in the command window,
% a great deal of flexibility can be had by applying it in functions as
% well (although this should be done with care, is it could be easy to
% overwrite base workspaces thinking that they are limited to functions,
% since there is only a single source of stored workspaces, whether they
% are used in the command window or in functions).  Note:  This function
% only with local and global variables, not function workspaces.
%
% The basic command is 'ws(n)', where n is a positive integer.  This
% changes to workspace number n.  Specifically, it stores the existing
% workspace as it stands, clears the usual workspace, and loads in
% workspace n.  Note that by default, when one leaves a workspace, it is
% put back in storage with its current configuration.
%
% It is possible to change these behaviors with the parameter options
% 'keep', 'abandon', and 'stay'.  These, like all other parameters, can
% also be specified using only thier first letters.  'keep' instructs the
% function to not clear the workspace before loading in the new variablesws
% of the next workspace.  If the two workspaces share variables of the same
% name, the ones from the incoming workspace overwrite the existing ones.
%
% 'abandon' tells the function to not backup the current workspace before
% switching.  If, for example, one executed the following commands from
% workspace 1:
%
%   >> ws 2 abandon
%   >> ws 1
%
% one would return not to the workspace as you left it, but rather to the
% way it was the last time it was backed up (workspace 2, however, would
% have been backed up upon the second command, since the 'abandon' keyword
% was not included; not that it matters, because no changes to the
% workspace were made in the above example).
%
% 'stay' tells the system not to make changes to the current workspace
% directory.  Suppose workspace 1 has 'C:\directory1' as its current
% directory and workspace 2 has 'C:\directory2' as its current directory.
% Normally when you switch workspaces the current directory changes.  If
% you include the 'stay' keyword when switching from 1 to 2, one would then
% have the variables in workspace 2, but be in the directory from workspace
% 1.  Note:  When the 'stay' keyword is used, the current directory is also
% not archived when leaving a workspace.  If you have changed directories
% in a workspace, then want to switch to another workspace while both
% staying in the current directory AND storing the latest directory in the
% original workspace, you should execute a 'ws' command (to archive the
% current workspace) before switching.
%
% To commit the current state of a workspace to storage without changing
% workspaces, simply type 'ws'.  When the 'stay' keyword is used here (i.e.
% 'ws stay'), variables are archived, but the workspace directory is not
% updated.
%
% If you want to retrieve the old state of the workspace (without switching
% as was done above), you can type: 
%
%   >> ws restore
%
% This form also accepts the 'keep' feature, so that one can keep newly 
% created variables, and simply overwrite original values on the old
% ones.  'stay' is valid here as well to remain not restore the workspace
% directory.
%
% Two other ways to change workspaces (that also accept the 'keep',
% 'abandon', and 'keep' parameters) are: 
%
%   >> ws next
%   >> ws previous
% 
% These cycle forwards and backwards, respectively, through the existing 
% workspaces, looping back to the beginning (end) once the end (beginning)
% is reached.
%
% There is no command for creating new workspaces, as they are
% automatically generated by a request to change to it.  For example, if
% workspaces 1 and 2 exist, and you type 'ws 5', workspaces 3, 4, and 5 are
% automatically generated (without any variables in them).
%
% Each workspace can also have a descriptive name associated with it.
% Whenever switching to a new workspace (including the same workspace, such
% as would occur by entering just 'ws'), you can also supply a description
% using the 'description' keyword.  For example,
%
%   >> ws 2 description This is the name of the new workspace
%
% would switch you to workspace 2, and assign the description of workspace
% 2 to be 'This is the name of a the new workspace'.  A workspace's name
% can be cleared by not providing a name, as in:
%
%   >> ws n description
%
% which switches to the next workspace and deletes its description.
% Clearly, the 'description' keyword must be provided after other keywords
% (such as 'keep', 'abandon', 'stay', etc.).
%
% You can also switch to other workspaces using the description.  Typing:
%
%   >> ws myname
%
% would switch to the workspace called 'myname'.  In cases where several
% workspaces have identical names, the searching occurs forward from the
% current workspace (i.e. if 5 workspaces are defined and the current
% workspace is number 3, the search order would be 3, 4, 5, 1, 2).  If an
% exact case sensitive match is not found, precedence is given to case
% insensitive matches, followed by workspace descriptions that begin with
% the supplied description, and ending with any workspace description that
% contains the supplied description.  If no match is found, an error is
% returned.
%
% Note: As with other commands, the 'description' keyword can be
% abbreviated as 'd'.  However, unlike other commands, it has a second
% abbreviation that is recognized: 'desc'.
%
% The command 'ws clear' (or 'ws clear global') clears the current 
% workspace in the archive.  This is not the same as simply typing 'clear',
% which clears the active workspace (not the stored copy of it).  This can
% be surprising if one uses 'ws clear', then switches to another workspace,
% and finally switches back only to find that the variables are still
% present.  This is because the 'ws clear' command only clears the stored
% archive, but by default when you switch workspaces the current workspace
% is archived, so the 'ws clear' command is essentially undone.  On the
% other hand, if one uses 'ws clear myvar' in workspace 1, then 'ws 2
% abandon', and finally 'ws 1', now workspace 1 will no longer contain
% myvar.  See below for more details on what additional arguments can be
% supplied.
%
% Sets of workspaces can be supplied individually or in groups.  For
% example:
%
%   >> ws clear 1 2 3     --  analagous to ws('clear',1,2,3)
%   >> ws clear [4 5 6]   --  analagous to ws('clear',[1 2 3])
%
% These clear the workspaces specified.  One can also use a colon (supplied
% as a string when using the functional form of ws) to clear all workspaces
% (i.e. 'ws clear :'), or a selected subset (e.g. 'ws clear 2:2:6').
% Colons are interpretted in the following way.  If no number appears
% before a colon, assume that it is a 1.  If no number appears after a
% colon, assume that it is the total number of existing workspaces.  Step
% sizes can also be specified with the colon structure (e.g. '3:2:',
% ':3:9', ':2:', ':12', and '22:' are all legal entries when specified as
% strings).
%
% The difference between the above two commands becomes apparent when
% supplying additional arguments to the clear command.  Consider:
%
%   >> ws clear 1 2 3 a* b*
%
% This command will clear all variables from workspaces 1 and 2, but from
% workspace 3 only those variables starting with the letters 'a' or 'b'
% will be cleared.  In contrast, the command:
%
%   >> ws clear [1 2 3] a* b*
%
% will clear only variables starting with 'a' or 'b' from workspaces 1, 2,
% and 3.  Multiple combinations can also be provided.  The following
% example shows several possible specification options
%
%   >> ws clear 1 a* 2 b* c* [3 4] d* : f* 3: g*h :5 *j :2: kat 3:3:13 z
%
% In this example, the following will be cleared: all variables starting
% with 'a' workspace 1; all variables starting with 'b' or 'c' in workspace
% 2; all variables starting with 'd' in workspaces 3 and 4; all variables
% starting with 'f' in all workspaces; all variables starting with 'g' and
% ending with 'h' in workspaces 3 and higher; all variables ending in 'j'
% from workspaces 1 through 5; all variables called 'kat' from all
% odd-numbered workspaces; and all variables called 'z' in workspaces 3, 6,
% 9, and 12.
%
% If no number is provided before the inclusion of variables, such as in:
%
%   >> ws clear a b 2 d e
%
% the current workspace is assumed.  In this example, variables a and b are
% cleared from the current workspace archive, and variables d and e are
% cleared from workspace 2.
%
% A command with similar (but not identical) application is 'ws quit'.  
% Unlike 'ws clear :', which removes all variables from all workspaces but
% leaves the workspaces in existence, 'ws quit' removes the existence of
% all workspaces.  In essence, it removes all evidence of the use of this
% function.  It is the only convenient way to truly free up ALL the memory
% that is being used by the storage of multiple workspaces ('ws clear all'
% frees most of it, but there is still a little used associated with
% knowing of the existence of all the defined workspaces).
%
% Certain information commands are also available:
%
%   >> ws length  -->  Returns the number of existing workspaces
%   >> ws ?       -->  Returns the current workspace id and directory (also
%                      returned when changed or restored per above syntaxes)
%
% For workspaces that contain descriptions, ws('?') will also provide the
% workspace description.  When used in fuctional form, one, two, or three
% outputs can be requested:
%
%   >> [num,desc_cell,pwd_cell] = ws('?');
%   >> [num,desc_cell] = ws('?');
%   >> num = ws('?');
%
% If 'ws ?' is called with additional numeric parameters, such as 'ws ? 1'
% or 'ws ? 2:', several names can be displayed.  In functional form, num
% will be returned as a vector; desc_cell and pwd_cell will return as cell
% arrays of strings.  When these arguments are returned as a result of a
% workspace change or restoration, the latter two are returned as strings.
%
% To get a list of the variables that are in the archived state of the
% current workspace, use:
% 
%   >> ws who
%
% The command
%
%   >> ws whos
%
% will provide more detailed information.  One can also get information
% about what is in other workspaces by indicating them at the end as was
% done for 'ws clear'.  For example:
%
%   >> ws who 1 2 3
%   >> ws whos [1 2 3] a* *b cat
%
% The former will return a list of all variables in workspaces 1, 2, and/or
% 3.  The latter form will provide all variables starting with a or ending
% with b, or that are called cat, whether they show up in workspaces 1, 2, or 3.  
% Variable specification works as described above.
%
% As above, if variable names appear before the first number, it is assumed
% that those variables refer to the current workspace archive.  Also, use a
% colon in place of a number to specify that all workspaces should be
% included.  Note, however, that one must be careful with the functional
% form that the colon be entered as a string, i.e. use: 
%
%   >> ws('whos',1,'a*',':','b*')
%
% Numbers can be put in as strings or numbers (i.e. ws('who',1) and
% ws('who','1') are equivalent).
%
% Obviously both 'who' and 'whos' cannot be abbreviated to 'w'.  'who' is
% abbreviated to 'w', and 'whos' is abbreviated to 'ws'.
%
% Two additional commands are 'ws send' and 'ws import'.  These commands
% are used to duplicate variables into and out of workspaces.  'ws import'
% will retrieve variables from other workspaces into the current one, and
% 'ws send' will copy variables in the current workspace into others.  For
% example,
%
%   >> ws send [1 2] r*
%
% will send all variables in the current workspace starting with an r into
% workspaces 1 and 2.  The command
%
%   >> ws import 1 r* 2 s*
%
% will take any variables from workspace 1 that start with r, and any
% variables from workspace 2 that start with s, and assign those values in
% the current workspace.
%
% When used with 'global', global variables are copied.  Note that when
% using 'send' or 'import', if a variable of the other type exists, it is
% overwritten.  For example, suppose workspace 1 has a global variable 'g'
% with a value of 6, and you are in workspace 2.  You send the local
% variable 'g' with a value of 8 from workspace 2 into workspace 1.
% Changing to workspace 1, you will find that there is a local variable 'g'
% with a value of 8, and the previous global variable (g=6) is now gone.
%
% Written by J.A. Dunne, 10/2/2006
%
% Updated by J.A. Dunne, 10/5/2006 to include workspace descriptions
% Updated by J.A. Dunne, 10/12/2006 to keep current directory info, also
%                        fixed typo in section for sending data to other
%                        workspaces
% Updated by J.A. Dunne, 10/16/2006 to track workspace paths

w = get(0,'UserData');
isokay = isstruct(w);
if isokay
    % Confirm format
    names = fieldnames(w);
    if length(names) == 2
        if strcmp(names{1},'ws')
            if strcmp(names{2},'curws')
                % This is a legit structure
            else
                isokay = 0;
            end
        else
            if ~strcmp(names{1},'curws') || ~strcmp(names{2},'ws')
                isokay = 0;
            end
        end
    end
else
    if isempty(w)
        % Create a new one
        isokay = 1;
        clear w
        w.curws = [];
        w.ws.local = [];
        w.ws.global = [];
        w.ws.pwd = '';
    end
end

if ~isokay
    error('Corrupted or missing workspace archive');
end

if nargin<1 || isempty(w.curws)
    % Supposed to archive in current workspace
    if isempty(w.curws)
        w.curws = 1;
    end
    gvars = evalin('caller','who(''global'')');
    lvars = evalin('caller','who');
    lo = [];
    gl = [];
    for i=1:length(lvars)
        found = 0;
        for j=1:length(gvars)
            if strcmp(gvars{j},lvars{i})
                gl.(gvars{j}) = evalin('caller',gvars{j});
                found = 1;
                break;
            end
        end
        if ~found
%             setfield(w.ws(w.curws).local,lvars{i},evalin('caller',lvars{i
%             }));
            lo.(lvars{i}) = evalin('caller',lvars{i});
        end
    end
    w.ws(w.curws).local = lo;
    w.ws(w.curws).global = gl;
    w.ws(w.curws).desc = '';
    w.ws(w.curws).pwd = cd;
    w.ws(w.curws).path = path;
    set(0,'UserData',w);
    if nargout==1
        varargout{1} = w.curws;
    end
    if nargin<1
        return
    end
end

% There is at least one input argument and one valid workspace
switchto = 0;
nosave = 0;
noclear = 0;
nocd = 0;
arg1 = varargin{1};
if iscell(arg1)
    error('Invalid cell array input argument');
end

switch lower(arg1)
    case {'length', 'l'}
        if nargout > 0
            varargout{1} = length(w.ws);
        else
            disp(['Number of defined workspaces: ' num2str(length(w.ws))]);
        end
        noclear = 1;
        nosave = 1;
        nocd = 1;
    case {'stay'}
        noclear = 1;
        nocd = 1;
    case {'quit', 'q'}
        set(0,'UserData',[]);
        return;
    case {'who','w','whos','ws','send','s','import','i','clear','c','?'}
        noclear = 1;
        nosave = 1;
        isglobal = 0;
        pair.ws = [];
        pair.matches = {};
        if nargin<2
            pair.ws = w.curws;
        else
            if strcmpi(varargin{2},'global')
                isglobal = 1;
            end
            i = 1+isglobal;
            j = 0;
            while i<nargin
                i = i + 1;
                if ischar(varargin{i})
                    arg = strrep(varargin{i},':end',[':' num2str(length(w.ws))]);
                else
                    arg = varargin{i};
                end
                if isnumeric(arg), arg = num2str(arg); end
                if ~iscell(arg) && length(str2num(arg))>0
                    j = j + 1;
                    nums = str2num(arg);
                    if ~isequal(nums,round(real(nums)))
                        error('Workspace indices must be real positive integers');
                    end
                    if max(nums)>length(w.ws) || min(nums)<1
                        error('Workspace index out of range');
                    end
                    pair(j).ws = nums;
                else
                    % Must have been text or cell
                    if iscell(arg)
                        if j<1
                            j = 1;
                            pair(j).ws = w.curws;
                        end
                        pair(j).matches = cat(1,pair(j).matches,arg{:});
                    else
                        wherecolon = strfind(arg,':');
                        if length(wherecolon) > 0
                            if min(wherecolon)==1
                                arg = ['1' arg];
                                wherecolon = strfind(arg,':');
                            end
                            if max(wherecolon)==length(arg)
                                arg = [arg num2str(length(w.ws))];
                            end
                            if length(str2num(arg))>0
                                j = j + 1;
                                nums = str2num(arg);
                                if ~isequal(nums,round(real(nums)))
                                    error('Workspace indices must be real positive integers');
                                end
                                if max(nums)>length(w.ws) || min(nums)<1
                                    error('Workspace index out of range');
                                end
                                pair(j).ws = nums;
                            else
    %                             error('Invalid variable name');
                            end
                        else
                            if j<1
                                j = 1;
                                pair(j).ws = w.curws;
                            end
                            pair(j).matches{end+1} = arg;
                        end
                    end
                end
            end
            if length(pair)<2 && length(pair.ws)<1
                pair.ws = w.curws;
            end
        end
        if strcmpi(arg1,'?')
            wstoshow = [];
            for i=1:length(pair)
                wstoshow = [wstoshow pair(i).ws(:)'];
            end
            wstoshow = unique(wstoshow);
            if nargout > 0
                varargout{1} = wstoshow;
                if nargout>1
                    wsdescs = cell(size(wstoshow));
                    wspwds = wsdescs;
                    wspaths = wsdescs;
                    for i=1:length(wstoshow)
                        wsdescs{i} = w.ws(wstoshow(i)).desc;
                        wspwds{i} = w.ws(wstoshow(i)).pwd;
                        wspaths{i} = w.ws(wstoshow(i)).path;
                    end
                    varargout{2} = wsdescs;
                    if nargout>2
                        varargout{3} = wspwds;
                        if nargout>3
                            varargout{4} = wspaths;
                        end
                    end
                end
            else
                if length(wstoshow)==1 && wstoshow == w.curws
                    if length(w.ws(w.curws).desc)>0
                        disp(['Current workspace: ' num2str(wstoshow) ' (' w.ws(w.curws).desc ')']);
                    else
                        disp(['Current workspace: ' num2str(wstoshow)]);
                    end
                    disp(['        Directory: ' w.ws(w.curws).pwd]);
                else
                    for i=1:length(wstoshow)
                        t = ['Workspace: ' num2str(wstoshow(i)) ' '];
                        if length(w.ws(wstoshow(i)).desc)>1
                            t = [t '(' w.ws(wstoshow(i)).desc ') '];
                        end
                        if wstoshow(i) == w.curws
                            t = [t '(current workspace)'];
                        end
                        disp(t);
                        disp(['        Directory: ' w.ws(wstoshow(i)).pwd]);
                    end
                end
            end
            noclear = 1;
            nosave = 1;
        elseif strcmpi(arg1,'clear') || strcmpi(arg1,'c')
            % This is a clear command
            for i=1:length(pair)
                for j=1:length(pair(i).ws)
                    if length(pair(i).matches)>0
                        if isglobal
                            vars = fieldnames(w.ws(pair(i).ws(j)).global);
                        else
                            vars = fieldnames(w.ws(pair(i).ws(j)).local);
                        end
                        for k=1:length(vars)
                            % matched a condition
                            if length(issame(vars{k},pair(i).matches))>0
                                if isglobal
                                    w.ws(pair(i).ws(j)).global = rmfield(w.ws(pair(i).ws(j)).global,vars{k});
                                else
                                    w.ws(pair(i).ws(j)).local = rmfield(w.ws(pair(i).ws(j)).local,vars{k});
                                end
                            end
                        end
                    else
                        if isglobal
                            w.ws(pair(i).ws(j)).global = [];
                        else
                            w.ws(pair(i).ws(j)).local = [];
                        end
                    end
                end
            end
            set(0,'UserData',w);
        elseif strcmpi(arg1,'send') || strcmpi(arg1,'s')
            for i=1:length(pair)
                for j=1:length(pair(i).ws)
                    if length(pair(i).matches)>0
                        if isglobal
                            vars = evalin('caller','who(''global'')');
                            for k=1:length(vars)
                                if length(issame(vars{k},pair(i).matches))>0
                                    w.ws(pair(i).ws(j)).global.(vars{k}) = evalin('caller',vars{k});
                                    if isfield(w.ws(pair(i).ws(j)).local,vars{k})
                                        w.ws(pair(i).ws(j)).local = rmfield(w.ws(pair(i).ws(j)).local,vars{k});
                                    end
                                end
                            end
                        else
                            vars = evalin('caller','who');
                            for k=1:length(vars)
                                if isempty(evalin('caller',['who(''global'',''' vars{k} ''')']))
                                    if length(issame(vars{k},pair(i).matches))>0
                                        w.ws(pair(i).ws(j)).local.(vars{k}) = evalin('caller',vars{k});
                                        if isfield(w.ws(pair(i).ws(j)).global,vars{k})
                                            w.ws(pair(i).ws(j)).global = rmfield(w.ws(pair(i).ws(j)).global,vars{k});
                                        end
                                    end
                                end
                            end
                        end
                    else
                        if ~isglobal
                            vars = evalin('caller','who');
                            for k=1:length(vars)
                                if isempty(evalin('caller',['who(''global'',''' vars{k} ''')']))
                                    w.ws(pair(i).ws(j)).local.(vars{k}) = evalin('caller',vars{k});
                                    if isfield(w.ws(pair(i).ws(j)).global,vars{k})
                                        w.ws(pair(i).ws(j)).global = rmfield(w.ws(pair(i).ws(j)).global,vars{k});
                                    end
                                end
                            end
                        else
                            vars = evalin('caller','who(''global'')');
                            for k=1:length(vars)
                                w.ws(pair(i).ws(j)).global.(vars{k}) = evalin('caller',vars{k});
                                if isfield(w.ws(pair(i).ws(j)).local,vars{k})
                                    w.ws(pair(i).ws(j)).local = rmfield(w.ws(pair(i).ws(j)).local,vars{k});
                                end
                            end
                        end
                    end
                end
            end
            set(0,'UserData',w);
        elseif strcmpi(arg1,'import') || strcmpi(arg1,'i')
            for i=1:length(pair)
                for j=1:length(pair(i).ws)
                    if length(pair(i).matches)>0
                        vars = {};
                        if isglobal
                            if ~isempty(w.ws(pair(i).ws(j)).global)
                                vars = fieldnames(w.ws(pair(i).ws(j)).global);
                            end
                        else
                            if ~isempty(w.ws(pair(i).ws(j)).local)
                                vars = fieldnames(w.ws(pair(i).ws(j)).local);
                            end
                        end
                        for k=1:length(vars)
                            % matched a condition
                            if length(issame(vars{k},pair(i).matches))>0
                                if isglobal
                                    evalin('caller',['global ' vars{k} ';']);
                                    assignin('caller',vars{k},w.ws(pair(i).ws(j)).global.(vars{k}));
                                else
                                    assignin('caller',vars{k},w.ws(pair(i).ws(j)).local.(vars{k}));
                                end
                            end
                        end
                    else
                        vars = {};
                        if isglobal
                            if ~isempty(w.ws(pair(i).ws(j)).global)
                                vars = fieldnames(w.ws(pair(i).ws(j)).global);
                            end
                            for k=1:length(vars);
                                evalin('caller',['global ' vars{k} ';']);
                                assignin('caller',vars{k},w.ws(pair(i).ws(j)).global.(vars{k}));
                            end
                        else
                            if ~isempty(w.ws(pair(i).ws(j)).local)
                                vars = fieldnames(w.ws(pair(i).ws(j)).local);
                            end
                            for k=1:length(vars);
                                assignin('caller',vars{k},w.ws(pair(i).ws(j)).local.(vars{k}));
                            end
                        end
                    end
                end
            end
        else
            % Must be a who or a whos
            if strcmpi(arg1,'whos') || strcmpi(arg1,'ws')
                % This is a whos
                varlist = {};
                varfrom = [];
                varlocal = [];
                for i=1:length(pair)
                    for j=1:length(pair(i).ws)
                        newones = {};
                        if ~isempty(w.ws(pair(i).ws(j)).global)
                            newones = fieldnames(w.ws(pair(i).ws(j)).global);
                        end
                        gspot = length(newones);
                        if ~isempty(w.ws(pair(i).ws(j)).local) && ~isglobal
                            newones = cat(1,newones,fieldnames(w.ws(pair(i).ws(j)).local));
                        end
                        for k=1:length(newones)
                            if length(pair(i).matches)<1 || length(issame(newones{k},pair(i).matches))>0
                                varlist{end+1} = newones{k};
                                varfrom(end+1) = pair(i).ws(j);
                                varlocal(end+1) = (k>gspot);
                            end
                        end
                    end
                end
                allstuff = unique([varfrom(:) double(char(varlist)) varlocal(:)],'rows');
                varfrom = allstuff(:,1); varlist = cellstr(char(allstuff(:,2:end-1))); varlocal = allstuff(:,end);
                varsin = zeros(length(w.ws),1);
                details.name = '';
                details.workspace = [];
                details.bytes = [];
                details.size = [];
                details.class = [];
                details.sparse = [];
                details.complex = [];
                detail.global = [];
                allbytes = 0;
                maxbytes = 0;
                totalnumel = 0;
                longestname = 0;
                details(length(varfrom)).global = [];
                for i=1:length(varfrom)
                    varsin(varfrom(i)) = varsin(varfrom(i)) + 1;
                    if varlocal(i)
                        temp = w.ws(varfrom(i)).local.(varlist{i});
                    else
                        temp = w.ws(varfrom(i)).global.(varlist{i});
                    end
                    details(i).name = varlist{i};
                    if length(varlist{i})>longestname, longestname = length(varlist{i}); end
                    details(i).workspace = varfrom(i);
                    details(i).sparse = issparse(temp);
                    details(i).complex = 0;
                    if isnumeric(temp)
                        details(i).complex = any(imag(temp(:)));
                    end
                    temp = whos('temp');
                    details(i).bytes = temp.bytes;
                    details(i).size = temp.size;
                    details(i).class = temp.class;
                    details(i).global = ~varlocal(i);
                    allbytes = allbytes + temp.bytes;
                    if temp.bytes>maxbytes, maxbytes = temp.bytes; end
                    if length(temp.size)>0
                        totalnumel = totalnumel + prod(temp.size);
                    end
                end
                if nargout>0
                    varargout{1} = details;
                else
                    % Gotta display it
                    colwrk = char(cat(1,{'Wrksp'},cellstr(num2str(varfrom))));
                    colname = char(cat(1,{'Name'},cellstr(varlist)));
                    colsize = cell(length(details)+1,1);
                    colbytes = colsize;
                    colclass = colsize;
                    colsize{1} = 'Size'; colbytes{1} = 'Bytes'; colclass{1} = 'Class';
                    for i=1:length(details)
                        colsize{i+1} = strrep(num2str(details(i).size),'  ','x');
                        colbytes{i+1} = num2str(details(i).bytes);
                        colclass{i+1} = details(i).class;
                        otherstr = [];
                        if details(i).global, otherstr = [otherstr 'global ']; end
                        if details(i).sparse, otherstr = [otherstr 'sparse ']; end
                        if details(i).complex, otherstr = [otherstr 'complex ']; end
                        if length(otherstr)>0
                            colclass{i+1} = [colclass{i} ' (' otherstr(1:end-1) ')'];
                        end
                    end
                    spacer = char(ones(length(colclass),2)*32);
                    dispstr = [colwrk spacer colname spacer char(colsize) spacer char(colbytes) spacer char(colclass)];
                    disp(dispstr);
                    disp(' ');
                    disp(['Grand total is ' num2str(totalnumel) ' elements using ' num2str(allbytes) ' bytes']);
                    disp(' ');
                end
            else
                % This is a who
                allvarlist = {};
                for i=1:length(pair)
                    varlist = {};
                    for j=1:length(pair(i).ws)
                        if ~isempty(w.ws(pair(i).ws(j)).global)
                            varlist = cat(1,varlist,fieldnames(w.ws(pair(i).ws(j)).global));
                        end
                        if ~isempty(w.ws(pair(i).ws(j)).local) && ~isglobal
                            varlist = cat(1,varlist,fieldnames(w.ws(pair(i).ws(j)).local));
                        end
                    end
                    if length(pair(i).matches)>0
                        for j=1:length(pair(i).matches)
                            % See what values in varlist fit pair(i).matches{j}
                            allvarlist = cat(1,allvarlist,issame(varlist,pair(i).matches{j}));
                        end
                    else
                        allvarlist = cat(1,allvarlist,varlist);
                    end
                end
                if nargout>0
                    varargout{1} = unique(allvarlist);
                elseif size(allvarlist,1)>0
                    allvarlist = char(unique(allvarlist));
                    n = 2 + size(allvarlist,2);
                    disp(' ')
                    disp('Your variables are:')
                    disp(' ')
                    colcnt = floor(100/n);
                    if colcnt<1
                        colcnt = 1;
                    end
                    numrows = ceil(size(allvarlist,1)/colcnt);
                    i = 0;
                    t = char(zeros(numrows,colcnt*n+1)+32);
                    col = 0;
                    while i<size(allvarlist,1)
                        i = i + 1;
                        t(1+mod(i-1,numrows),1+(col*n):(col*n)+size(allvarlist,2)) = allvarlist(i,:);
                        if ~mod(i,numrows)
                            col = col + 1;
                        end
                    end
                    for i=1:numrows
                        disp(t(i,:))
                    end
                    disp(' ')
                end
            end
        end
    otherwise
        % Something is actually happening
        if isnumeric(arg1) || length(str2num(arg1))>0
            if ~isnumeric(arg1), arg1 = str2num(arg1); end
            if length(arg1)>1
                error('Only one workspace can be selected at a time');
            end
            switchto = arg1(1);
            if ~isequal(switchto,round(real(switchto))) || switchto<1
                error('Workspace indices must be real positive integers');
            end
            if nargin>2
                if strcmpi(varargin{2},'description') || strcmpi(varargin{2},'desc') || strcmpi(varargin{2},'d') 
                    w.ws(switchto).desc = catcell(varargin{3:end});
                end
            end
        else
            % Not a number in first
            switch lower(arg1)
                case {'restore','r'}
                    switchto = w.curws;
                    nosave = 1;
                case {'next','n'}
                    switchto = w.curws + 1;
                    if switchto>length(w.ws)
                        switchto = 1;
                    end
                case {'previous','p'}
                    switchto = w.curws - 1;
                    if switchto<1
                        switchto = length(w.ws);
                    end
                case {'description','desc','d'}
                    w.ws(w.curws).desc = '';
                    if nargin>1
                        w.ws(w.curws).desc = catcell(varargin{2:end});
                    end
                    set(0,'UserData',w);
                    return
                otherwise
                    % Look for a workspace having the name provided
                    desc = catcell(varargin{:});
                    casebad = [];
                    startswith = [];
                    containsstr = [];
                    for i=[w.curws:length(w.ws) 1:(w.curws-1)]
                        if strcmp(desc,w.ws(i).desc)
                            switchto = i;
                            break;
                        elseif strcmpi(desc,w.ws(i).desc)
                            casebad = [casebad i];
                        else
                            isthere = strfind(lower(w.ws(i).desc),lower(desc));
                            if length(isthere)>0
                                containsstr = [containsstr i];
                                if isthere(1) == 1
                                    startswith = [startswith i];
                                end
                            end
                        end
                    end
                    if switchto<1
                        if length(casebad)>0
                            switchto = casebad(1);
                        elseif length(startswith)>0
                            switchto = startswith(1);
                        elseif length(containsstr)>0
                            switchto = containsstr(1);
                        end
                    end     
            end
            if switchto<1
                error('Paramter not recognized/description not found');
            end
        end
        for i=2:nargin
            switch lower(varargin{i})
                case {'abandon','a'}
                    nosave = 1;
                case {'keep','k'}
                    noclear = 1;
                case {'stay','s'}
                    nocd = 1;
                case {'description','desc','d'}
                    if switchto>0
                        w.ws(switchto).desc = '';
                        if nargin>i
                            w.ws(switchto).desc = catcell(varargin{i+1:end});
                        end
                        set(0,'UserData',w);
                    end
                    break
                otherwise
                    error('Unrecognized parameter');
            end
        end
end

if ~nosave
    gvars = evalin('caller','who(''global'')');
    lvars = evalin('caller','who');
    lo = [];
    gl = [];
    for i=1:length(lvars)
        found = 0;
        for j=1:length(gvars)
            if strcmp(gvars{j},lvars{i})
                gl.(gvars{j}) = evalin('caller',gvars{j});
                found = 1;
                break;
            end
        end
        if ~found
%             setfield(w.ws(w.curws).local,lvars{i},evalin('caller',lvars{i
%             }));
            lo.(lvars{i}) = evalin('caller',lvars{i});
        end
    end
    w.ws(w.curws).local = lo;
    w.ws(w.curws).global = gl;
    if ~nocd
        w.ws(w.curws).pwd = cd;
    end
    w.ws(w.curws).path = path;
    set(0,'UserData',w);
    if nargout==1
        varargout{1} = w.curws;
    end
end

if ~noclear
    evalin('caller','clear;clear global;');
end

if switchto
    w.curws = switchto;
    if w.curws>length(w.ws) || ~exist(w.ws(w.curws).pwd,'dir')
        w.ws(w.curws).pwd = cd;
        w.ws(w.curws).path = path;
    end
    set(0,'UserData',w);
    if ~isempty(w.ws(w.curws).global)
        gvars = fieldnames(w.ws(w.curws).global);
        for i=1:length(gvars)
            evalin('caller',['global ' gvars{i}]);
            assignin('caller',gvars{i},w.ws(w.curws).global.(gvars{i}));
        end
    end
    if ~isempty(w.ws(w.curws).local)
        lvars = fieldnames(w.ws(w.curws).local);
        for i=1:length(lvars)
            assignin('caller',lvars{i},w.ws(w.curws).local.(lvars{i}));
        end
    end
    if ~nocd
        cd(w.ws(w.curws).pwd);
    end
    path(w.ws(w.curws).path);
    if nargout>0
        varargout{1} = w.curws;
        if nargout>1
            varargout{2} = w.ws(w.curws).desc;
            if nargout>2
                varargout{3} = w.ws(w.curws).pwd;
                if nargout>3
                    varargout{4} = w.ws(w.curws).path;
                end
            end
        end
    end
end


function [out] = catcell(varargin)

out = '';
for i=1:nargin
    out = [out ' ' varargin{i}];
end
if length(out)>1
    out = out(2:end);
end

            

function [out] = issame(vars,varpattern)

varpat = strrep(varpattern,'*','.*');
if ~iscell(varpat)
    varpat = {varpat};
end
if ~iscell(vars)
    vars = {vars};
end
for i=1:length(varpat)
    varpat{i} = ['^' varpat{i} '$'];
end
q = regexp(vars,varpat);

if iscell(vars)
    out = {}; %zeros(length(vars));
    for i=1:length(q)
        if length(q{i})>0
            out{end+1} = vars{i};
%             out(i) = 1;
        end
    end
else
    out = {}; %0;
    if length(q)>0
        out = {vars}; % 1
    end
end

if size(out,2)>1
    out = out';
end
        