% Copyright (c) 2012, Damith Senaratne
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
% 
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

classdef ipanel < handle
    % --------------------------------------------------
    % class   : ipanel - controller panel for interactive graphics.
    % date    : 2012/12/19
    % version : 1.0
    % --------------------------------------------------
    % 
    % This class adds a panel containing slider/checkbox/popupmenu
    % controllers to provide a primitive MATHEMATICA-'Manipulate'-like
    % facility.
    %
    % A function handle that accepts aribtrary number of parameters is
    % passed in with respective controller specification. Each parameter
    % gets associated with a controller and becomes a 'controlled
    % parameter'. The controllers can be used to adjust the parameters, and
    % thereby manipulate the function (and the graphics).
    %
    % For details please check:  
    %   >> help ipanel.ipanel
    %
    % Public methods: 
    %   Try 'help ipanel.funcname' for help on each 'funcname'
    %   - ipanel (constructor; adds ipanel and controllers)
    %   - remove (removes ipanel and the controllers from a figure)
    %   - getControllers (provides handles to the ipanel's internals)
    %   - getData (returns the values of controlled parameters)
    %   - display (display current values of the controlled parameters)
    %
    %   See also ipanel.ipanel, ipanel.remove, ipanel.getControllers,
    %   ipanel.getData, ipanel.display
    %
    %   Author        : Damith Senaratne, (http://www.damiths.info)
    %   Released date : 19th December 2012 
    % --------------------------------------------------
    
    properties (Access = private)
        % --------------------
        % properties (private)
        % --------------------        
        fnH % function handle
        controllers % handles to controllers        
        labels % handles to labels (associated with the controllers)        
        hFigure % figure handle
        hPanel % handle to uipanel holding the controllers
        data % current values of the controlled parameters
                
        panelHeight % desired height of the visible portion of the uipanel
        isColapsed % is uipanel visible or not?
        
        % NOTE: following properties can be set using parameter-value pairs passed in to the constructor
        lblWidth = 150; % default width of a label
        minCtrlWidth = 250; % minimum width of a controller
        pading = 10; % padding between/around the controller/labels
        clearance = 0.11; % clearance below the axes (as percentage of figure height) 
    end    
    
    properties(Constant, GetAccess = private)
        % --------------------
        % string literals (private)
        % --------------------
        PanelTitle = 'Interact'; 
                
        InputMismatchTitle = 'Input mismatch';
        InputTitle = 'Input';        
        
        InputOutofRangeMsg = 'Input is not within %s!';
        InputNotNumericMsg = 'Input is not numeric!';        
        ipanelReplacedMsg = 'ipanel: an ipanel was replaced!';
        
        NoCtrlSpecifiedErr = 'ipanel: no control specified!';
        InvalidControlSpecErr = 'ipanel: an invalid control specification!';
        NoFnHSpecifiedErr = 'ipanel: function handle expected!';
        UnspportedCtrlTypeErr = 'ipanel: unsupported control type: %s!';        
        UnspportedOptionErr = 'ipanel: unsupported option: %s!';
              
        ResizeFcnReplacedWarn = 'ipanel: ResizeFcn of the figure was replaced!';
    end
    
    methods        
        % --------------------
        % public methods
        % --------------------
        
        function this = ipanel(varargin)
        % --------------------
        % function: ipanel/ipanel (constructor)          
        %   - attaches ipanel to a figure, creating call controller and labels
        %   - NOTE: clicking the panel toggles its visibility
        %   - usage:
        %       ipanel(hFig, fnH, VARARGIN)
        %       ipanel(fnH, VARARGIN)         
        %       
        %       where 
        %       hFig - (optional) handle to a figure (if not specified, hFig = gcf)
        %       fnH - handle to a function accepting K parameters
        %
        %       VARAGIN comprises:
        %       - K cell arrays, each specifying a controller and
        %       corresponds to a parameter of fnH..
        %       - followed by optional parameter-value pairs
        %           NOTE: these pairs SHOULD trail all others arguments
        %           Supported parameters:
        %           - LabelWidth (default width of the labels, in pixels)
        %           - MinControlWidth (minimum width of controllers, in pixels)
        %           - Pading (padding between/around the controllers, in pixels, 0 < Pading < 0.25)
        %           - Clearance (clearance below the axes as percentage of figure height, 0 < Clearance <0 .25) 
        %       - each cell array is of form {ctrlType, label, values1, values2}
        %           where 
        %           - ctrlType is one of {'slider','checkbox','popupmenu'}
        %           - label identifies the corresponding parameter of fnH (for display purposes)
        %           - acceptable values depend on the ctrlType 
        %
        %           1.) ctrlType == 'slider'
        %               - creates a 'slider' control (drag slider to adjust; click label to set precise value)
        %               - NOTE: clicking the label opens an input dialog; ANY expression evaluating to a numeric value can be input
        %                   e.g.: 2*sin(pi/8)
        %               - values1 = {Min, Max, Default, Step}, Default and Step are optional  
        %               - current value is displayed on the label
        %           2.) ctrlType == 'checkbox'
        %               - creates a 'checkbox' control (click to toggle value)
        %               - values1 = 0 or 1,  values==0 -> unchecked,  values==1 -> checked
        %               - numerical value is displayed on the label
        %           3.) ctrlType == 'popupmenu'
        %               - creates a 'popupmenu' control (click to select value from the dropdown list)
        %               - values1 = {...} cell array of values to select from
        %               - values2 = {...} optional cell array of strings for corresponding names
        %               - NOTE: the first value is the default selection
        %               - selected value is displayed on the label, if excplit names are specified
        %
        %   - e.g. 1,            
        %       >> x = 0:.0001:1; 
        %       >> ipanel(@(f)plot(x,sin(2*pi*f*x)),{'slider','frequency',{0,10,1}})             
        %
        %   - e.g. 2,
        %       >> h = figure; 
        %       >> x = 0:.001:1; 
        %       >> ipanel(h,@(a,b)plot(x,sin(2*pi*a*x)+cos(2*pi*b*x)),{'slider','a',{0,10,1}},{'slider','b',{0,10,5}},'MinControlWidth',250,'LabelWidth',100)
        %
        %   - e.g. 3.
        %       >> ipanel(@(a)aFunctionForComputingAndDisplay(a),{'slider','a',{0,10,1}})
        %
        %   - e.g. 4,
        %       >> global x; x = 0:.01:1; 
        %       >> ipanel(@(a,b,c)eval('global x; subplot(2,1,1); plot(x,sin(2*pi*a*x)); grid on; subplot(2,1,2); plot(x,c+cos(2*pi*b*x),''--''); grid on;'),{'slider','a',{0,10,1}},{'slider','b',{0,10,5}},{'checkbox','c',1},'MinControlWidth',250,'LabelWidth',100)
        %
        %   - e.g. 5,
        %       >> x = 0:.0001:1;
        %       >> ipanel(@(a)plot(x,sin(2*pi*a*x)),{'popupmenu','frequency',{1,2,3},{'normal','double','tripple'}});
        %
        %   - e.g. 6,
        %       >> global x; x = 0:.0001:1;
        %       >> ipanel(@(str,f,th)eval(['global x; plot(x,' str '(2*pi*f*x + th))']),{'popupmenu','function',{'sin','cos'}},{'slider','frequency',{0,10,1}},{'slider','phase',{0,2*pi,pi/8}})
        %
        %   See also ipanel
        %
        % --------------------                      
            if nargin == 0 || ~ishandle(varargin{1})
                this.hFigure = gcf; % assume current figure
            else
                this.hFigure = varargin{1};
                varargin = varargin(2:end);
            end
            
            % remove any ipanel already associated with the figure
            h = findobj(this.hFigure,'Tag','ipanel'); 
            if ~isempty(h)
                obj = get(h,'UserData');
                if isfield(obj,'ipanel') && isa(obj.ipanel,'ipanel')
                    display(this.ipanelReplacedMsg);
                    remove(obj.ipanel);
                end
            end
                        
            this.hPanel = uipanel;  % create a new uipanel          
            obj.ipanel = this;
            set(this.hPanel,'Parent',this.hFigure,'UserData',obj,'Tag','ipanel','ButtonDownFcn',@(src, event)togglePanel(this));
            set(this.hPanel,'Title',this.PanelTitle,'TitlePosition','righttop','Position',[0 0 1 .25]);            
            this.isColapsed = true; 
            this.controllers = [];                 
                        
            % parse arguments
            nvarargin = length(varargin);
            if nvarargin > 0                 
                % first argument MUST be a function handle!
                if ~isa(varargin{1},'function_handle')
                    error(this.NoFnHSpecifiedErr);
                end
                this.fnH = varargin{1}; % extract the handle
                varargin = varargin(2:end); nvarargin = nvarargin - 1;
                                               
                % check if (optional) parameter-value pairs are passed
                % (they SHOULD trail the argument list) 
                pvp = {};
                for k= nvarargin-1:-2:1                        
                    if ischar(varargin{k}) % possible parameter
                        % extract parameter-value pair
                        pvp = [varargin{k}, varargin{k+1}, pvp]; % DEVELOPER NOTE: no preallocation, but not a noteworthy performance issue
                        varargin = varargin(1:k-1); 
                    else
                        % not a parameter! 
                        % 'varargin' can have only controller information left                        
                        break;
                    end
                end                    
                if ~isempty(pvp)
                    this.set(pvp{:}); % set the parameters
                end               
                nvarargin = length(varargin);
                
                if nvarargin == 0
                    error(this.NoCtrlSpecifiedErr);
                end

                % initialize the data store
                this.dataStore(nvarargin);

                for k=1:nvarargin
                    % add controllers, one at a time                                    
                    
                    arg = varargin{k}; 
                    % each argument is of form {ctrlType, label, values1} or {ctrlType, label, values1, values2}
                    if ~iscell(arg) || length(arg)<3 || ~iscellstr(arg(1:2))
                        error(this.InvalidControlSpecErr);
                    end
                    
                    % add supported controlers; set callbacks
                    initVal = [];
                    switch arg{1}
                        case 'slider'
                            initVal = this.addSlider(arg{2}, arg{3}, @(x)this.dataStore(k,x,true));
                        case 'checkbox'
                            initVal = this.addCheckbox(arg{2}, arg{3}, @(x)this.dataStore(k,x,true));
                        case 'popupmenu'
                            if length(arg)==4 && length(arg{3})==length(arg{4}) && iscellstr(arg{4})
                                initVal = this.addPopupmenu(arg{2}, arg{3}, @(x)this.dataStore(k,x,true),arg{4});
                            else
                                initVal = this.addPopupmenu(arg{2}, arg{3}, @(x)this.dataStore(k,x,true));
                            end
                        otherwise
                            error(this.UnspportedCtrlTypeErr, arg{1});
                    end
                    
                    % update data store with the initial values
                    this.dataStore(k, initVal);
                end
                this.dataStore(); % invoke callback (e.g., to obtain the initial display)            
                
                this.togglePanel();             
            else
                error(this.NoFnHSpecifiedErr);
            end
            
            if ~isempty(get(this.hFigure,'ResizeFcn'))                            
                warning(this.ResizeFcnReplacedWarn);
            end
            set(this.hFigure,'ResizeFcn',@(s,e)this.resizeView); % register figure resize callback
        end        
        
        function remove(this)
            % --------------------
            % function: ipanel/remove          
            %   - removes the ipanel
            %   - NOTE: invoke this method to remove the panel without closing the figure
            %       e.g., after interactively fine tuning the controlled parameters
            %   - usage:
            %       remove(obj) 
            %       obj.remove
            %   - e.g.,
            %       >> x = 0:.0001:1; 
            %       >> h = ipanel(@(f)plot(x,sin(2*pi*f*x)),{'slider','frequency',{0,10,1}})
            %       >> remove(h)
            %
            %   See also ipanel
            %
            % --------------------
            set(this.hFigure,'ResizeFcn','');
            this.panelHeight = 1;
            this.resizeView(); % resize objects
            
            % delete all uicontrol objects associated with the ipanel object
            if ishandle(this.hPanel)
                delete(this.hPanel);
            end           
            delete(this.controllers(ishandle(this.controllers)));
            delete(this.labels(ishandle(this.labels)));            
        end
        
        function [hCtrls,hLbls,hPanel] = getControllers(this)
            % --------------------
            % function: ipanel/getControllers          
            %   - provides handles to controllers (associated labels, and the panel containing the controllers)
            %   - CAUTION: modifying certain properties could affect the functionality of 'ipanel'
            %   - usage:
            %       hCtrls = obj.getControllers
            %       [hCtrls,hLbls] = obj.getControllers
            %       [hCtrls,hLbls,hPanel] = obj.getControllers
            %   - e.g.,
            %       >> x = 0:.0001:1; 
            %       >> h = ipanel(@(f,g)plot(x,sin(2*pi*f*x),x,cos(2*pi*g*x)),{'slider','frequency 1',{0,10,1}},{'slider','frequency 2',{0,10,1}})
            %       >> hCtrls = h.getControllers();
            %
            %   See also ipanel
            %
            % --------------------
            hCtrls = this.controllers;
            if nargout > 1
                hLbls = this.labels; 
            end
            if nargout > 2
                hPanel = this.hPanel;
            end            
        end
        
        function data = getData(this)
            % --------------------
            % function: ipanel/getData
            %   - returns the values of controlled parameters
            %
            %   See also ipanel
            %
            % --------------------
            data = this.data;
        end
        
        function display(this)
            % --------------------
            % function: ipanel/display
            %   - displays information about the ipanel object
            %   - invoked when the object is cast to a string
            %
            %   See also ipanel
            %
            % --------------------
            str = 'ipanel object: ';
            for k = 1:length(this.data)
                val = this.data{k};  % DEVELOPER NOTE: 'val' is used by 'evalc'
                str = [str, sprintf('%s = %s; ',get(this.labels(k),'TooltipString'),strtrim(evalc('disp(val)')))]; % DEVELOPER NOTE: no preallocation, but not a noteworthy performance issue
            end
            display(str(1:end-2));
        end
    end
    
    methods (Access = private)
        % --------------------
        % private methods
        % --------------------
        
        function set(this,varargin)
            % --------------------
            % function: ipanel/set            
            %   - parses varargin and extracts the options
            %   - invoked by the constructor
            % --------------------
            for k = 1:2:length(varargin)
                value = varargin{k+1};
                switch varargin{k}
                    case 'LabelWidth'
                        if value>0 
                            this.lblWidth = value;
                        end
                    case 'MinControlWidth'
                        if value>0
                            this.minCtrlWidth = value;
                        end
                    case 'Pading'
                        if value>0 && value<25
                            this.pading = value;
                        end
                    case 'Clearnce'
                        if value>0 && value<0.25  
                            this.clearnce = value;
                        end
                    otherwise
                        error(this.UnspportedOptionErr, varargin{k+1});
                end
            end
        end
        
        function dataOut = dataStore(this, n, dataIn, invoke)
            % --------------------
            % function: ipanel/dataStore            
            %   - updates and retrieves current values of all controlled parameters
            %   - invokes the function handles, when called without explicit arguments
            %     (or if invoke==true)
            % --------------------                                                
            
            if nargin==1 && ~isempty(this.fnH)
                this.fnH(this.data{:}); % invoke function handle with stored data
            elseif nargin==2
                if isempty(this.data)
                    this.data = cell(1,n); % reset data
                elseif nargout == 1
                    dataOut = this.data{n}; % retrieve data
                end 
            else
                this.data{n} = dataIn; % store data
                
                if nargin == 4 && invoke
                    this.fnH(this.data{:}); % invoke function handle with stored data
                end
            end                        
        end
        
        function initVal = addSlider(this, label, values, callback)
            % --------------------
            % function: ipanel/addSlider            
            %   - adds a slider control
            %   - NOTE: values: {Min, Max, Default, Step}, Default and Step are optional
            % --------------------                                    
            if ~iscell(values) || length(values)<2
                error(this.InvalidControlSpecErr);
            end
            
            minVal = values{1};
            maxVal = values{2};
            
            if minVal>=maxVal
                error(this.InvalidControlSpecErr);
            end
            
            % determine default value
            if length(values) < 3 || isempty(values{3})
                defVal = minVal;
            else
                defVal = values{3};
            end
            
            % determine slider step
            if length(values) < 4 || isempty(values{4})
                step = [0.01 0.10];
            else
                step = values{4};
            end
            
            id = this.addControl('Style','slider','Min',minVal,'Max',maxVal,'Value',defVal,'SliderStep',step); % create control
            hLbl = this.createLabel(id, label, 'slider'); % create label
            
            % function handle for indicating value on label
            setLabel = @(x)set(hLbl,'String',sprintf('%s = %g',get(hLbl,'TooltipString'),x));
            
            hCtrl = this.controllers(id);
            setLabel(get(hCtrl,'Value')); % update label
            
            % register callbacks
            set(hCtrl,'Callback',@(s,e)ipanel.callbackDispatcher({callback, setLabel, @(x)this.resizeView},get(s,'Value')));
            
            % initial value
            initVal = get(hCtrl,'Value');
        end
        
        function initVal = addCheckbox(this, label, value, callback)
            % --------------------
            % function: ipanel/addCheckbox            
            %   - adds a checkbox control
            %   - NOTE: value==1 --> checked
            % --------------------            
            if length(value)~=1 || ~isnumeric(value)
                error(this.InvalidControlSpecErr);
            end
            value = (abs(value)>eps); % set value=1 if not zero!
            
            id = this.addControl('Style','checkbox','Value',value); % create control
            hLbl = this.createLabel(id, label); % create label            
            
            % function handle for indicating value on label
            setLabel = @(x)set(hLbl,'String',sprintf('%s = %g',get(hLbl,'TooltipString'),x)); 
            
            hCtrl = this.controllers(id);
            setLabel(get(hCtrl,'Value')); % update label
            
            % register callbacks
            set(hCtrl,'Callback',@(s,e)ipanel.callbackDispatcher({callback, setLabel, @(x)this.resizeView},get(s,'Value')));
            
            % initial value
            initVal = get(hCtrl,'Value');
        end
        
        function initVal = addPopupmenu(this, label, values, callback, names)
            % --------------------
            % function: ipanel/addPopupmenu            
            %   - adds a popupmenu control            
            % -------------------- 
            if ~iscell(values)
                error(this.InvalidControlSpecErr);
            end
            
            N = length(values);
            
            strvals = cell(1,N);
            for k = 1:N
                val = values{k}; % DEVELOPER NOTE: 'val' is used by 'evalc'
                strvals{k} = strtrim(evalc('disp(val)'));                 
            end
            
            if nargin < 5
                names = strvals;
            end
            
            tmp = [names; repmat({'|'},1,N)];
            str = cell2mat(tmp(:)');            
            str = str(1:end-1);
            
            id = this.addControl('Style','popupmenu','String',str); % create control
            hLbl = this.createLabel(id, label); % create label            
                        
            hCtrl = this.controllers(id);            
            
            set(hCtrl,'Value',1);
            if nargin == 5
                % function handle for indicating value on label
                setLabel = @(x)set(hLbl,'String',sprintf('%s = %s',get(hLbl,'TooltipString'),strvals{x})); 
                set(hCtrl,'Callback',@(s,e)ipanel.callbackDispatcher({@(x)callback(values{x}), setLabel, @(x)this.resizeView},get(s,'Value')));
                setLabel(get(hCtrl,'Value')); % update label
            else
                % register callbacks
                set(hCtrl,'Callback',@(s,e)ipanel.callbackDispatcher({@(x)callback(values{x}), @(x)this.resizeView},get(s,'Value')));
            end
            
            % initial value
            initVal = values{get(hCtrl,'Value')};
        end
        
        function id = addControl(this, varargin)
            % --------------------
            % function: ipanel/addControl            
            %   - adds a control to ipanel (above existing controllers, if any)
            %   - control specific options are passed in as 'varargin'
            % --------------------
            if this.isColapsed
                % show panel (if hidden)
                this.togglePanel();
            end
            
            ctrl = uicontrol(this.hPanel, varargin{:}); 
            set(ctrl,'Units','pixels','Tag','ipanelc','Visible','off');
            position = get(ctrl,'Position');
            
            position(1) = this.lblWidth + this.pading; % leave room for label
            
            if isempty(this.controllers)
                position(2) = 0;
            else                
                tmp = get(this.controllers(end),'Position');
                position(2) = tmp(2) + tmp(4); % place above other controllers
            end
            position(2) = position(2) + this.pading;
            
            if position(3) < this.minCtrlWidth
                % ensure minimum width
                position(3) = this.minCtrlWidth;
            end
            
            set(ctrl,'Position',position);
            
            this.controllers = [this.controllers, ctrl]; % register the control
            id = length(this.controllers); % return the control's sequence id
        end
        
        function hLbl = createLabel(this, id, label,usrinpt)
            % --------------------
            % function: ipanel/createLabel
            %   - creates a label associated with a control
            %   - any expression evaluating to a numerical value can be input
            % --------------------
            pos = get(this.controllers(id),'Position');
            pos(1) = this.pading;            
            pos(3) = this.lblWidth;          
            hLbl = uicontrol(this.hPanel,'Style','text','Units','pixels','Tag','ipanelc','TooltipString',label,'HorizontalAlignment','left','String',label,'Position',pos,'Visible','off');
            if nargin == 4 && strcmp(usrinpt,'slider')
                set(hLbl,'HitTest','on','Enable','inactive','ButtonDownFcn',@(s,e)this.setSlider(id));
            end
            this.labels = [this.labels, hLbl]; % register the label            
        end                           
        
        function setSlider(this, id)  
            % --------------------
            % function: ipanel/setSlider
            %   - input a slider value
            %   - any expression evaluating to a numerical value can be input
            % --------------------
            hCtrl = this.controllers(id);                         
            minVal = get(hCtrl,'Min'); maxVal = get(hCtrl,'Max');
            range = sprintf('[%d,%d]',minVal,maxVal);
            label = [get(this.labels(id),'TooltipString') ' \in ' range];
            obj.Interpreter = 'tex';
            answer = inputdlg(label,this.InputTitle,1,{num2str(get(hCtrl,'Value'))},obj);
            if ~isempty(answer) && ~isempty(answer{1})
                value = eval(answer{1}); % evaluate the input               
                if isnumeric(value) 
                    if value>=minVal && value<=maxVal
                        set(hCtrl,'Value',value);     
                        callback = get(hCtrl,'Callback');
                        callback(hCtrl,1); % fake the callback! ;)
                    else
                        warndlg(sprintf(this.InputOutofRangeMsg,range),this.InputMismatchTitle,'modal');
                    end
                else
                    warndlg(this.InputNotNumericMsg,this.InputMismatchTitle,'modal');
                end
            end
        end
        
        function togglePanel(this)       
            % --------------------
            % function: ipanel/togglePanel
            %   - show/hide ipanel
            % --------------------
       
            this.isColapsed = ~this.isColapsed; % toggle visibility            
            
            if this.isColapsed
                % hidden
                for k = 1:length(this.controllers)
                    set(this.controllers(k),'Visible','off');
                    set(this.labels(k),'Visible','off');
                end                
                this.panelHeight = 2*this.pading;
            else
                % visible
                this.panelHeight = 0;
                if ~isempty(this.controllers)
                    % last controllers appears at the top, get its position
                    tmp = get(this.controllers(end),'Position'); 
                    this.panelHeight = tmp(2) + tmp(4);                    
                end
                this.panelHeight = this.panelHeight + 2*this.pading;                
                
                for k = 1:length(this.controllers)
                    set(this.controllers(k),'Visible','on');                    
                    set(this.labels(k),'Visible','on');
                end
            end                        
                                      
            this.resizeView();                        
        end    
        
        function resizeView(this, varargin) 
            % --------------------
            % function: ipanel/resizeView
            %   - resizes the child objects of the figure
            %   - NOTE: 'varargin' is defined only to let 'resizeView' receive callbacks
            % --------------------
            hCh = get(this.hFigure,'Children');
            nCh = length(hCh);
            if nCh == 0 
                return;
            end
                         
            % get figure width & height
            units = get(this.hFigure,'Units'); set(this.hFigure,'Units','pixels');
            position = get(this.hFigure,'Position'); set(this.hFigure,'Units',units);
            width = position(3);
            height = position(4);      
            
            % set ipanel width & height
            units = get(this.hPanel,'Units'); set(this.hPanel,'Units','pixels');            
            position = get(this.hPanel,'Position'); 
            position(3) = width; position(4) = this.panelHeight;
            set(this.hPanel,'Position',position);
            set(this.hPanel,'Units',units);
            gap = position(4) + this.pading; 
            gap = gap + round(this.clearance*(height-gap));  % desired clearance
            
            % retrieve positions of all child elements of the figure
            positions = zeros(nCh,4);
            for k = 1:nCh
                hC = hCh(k);
                if strcmp(get(hC,'Tag'),'ipanel')
                    positions(k,2) = inf;
                    continue;
                end
                units = get(hC,'Units'); set(hC,'Units','pixels');
                positions(k,:) = get(hC,'Position'); set(hC,'Units',units);
            end
             
            % determined required scaling & shifting
            shift = gap - min(positions(:,2));                         
            if abs(shift) > height
                return;
            end
                 
            if shift > 0
                scale = (height-shift)/height;
                positions(:,2) = round(positions(:,2)*scale) + shift;
            else
                scale = height/(height+shift);
                positions(:,2) = round((positions(:,2) + shift)*scale);
            end
            positions(:,4) = round(positions(:,4)*scale);
            
            % resize child objects
            for k = 1:nCh
                hC = hCh(k);
                if strcmp(get(hC,'Tag'),'ipanel')
                    continue;
                end
                units = get(hC,'Units'); set(hC,'Units','pixels');
                set(hC,'Position',positions(k,:)); set(hC,'Units',units);                                               
            end                          
        end
    end    
    
    methods(Static, Access = private)
        % --------------------
        % private static methods
        % --------------------
        
        function callbackDispatcher(callbacks,varargin)
            % --------------------
            % function: ipanel/callbackDispatcher
            %   - triggers multiple callback functions
            % --------------------
            for k=1:length(callbacks)
                fnc = callbacks{k};                
                fnc(varargin{:});
            end
        end                          
    end
end