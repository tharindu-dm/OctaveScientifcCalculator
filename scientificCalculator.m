%% Scientific Calculator GUI

function scientificCalculator()
    % Main figure for the calculator
    MainFrm = figure(...
        'position', [100, 100, 800, 800], ... % Increased width
        'name', 'Scientific Calculator', ...
        'numbertitle', 'off', ...
        'resize', 'off', ...
        'color', [0.2, 0.2, 0.2]); % Dark background

    % Left panel for matrix, graphs, and stats
    leftPanel = uipanel(MainFrm, ...
        'position', [0, 0, 0.5, 1], ... % Increased width of left side panel
        'backgroundcolor', [0.3, 0.3, 0.3]);

    % Right panel for calculator buttons
    rightPanel = uipanel(MainFrm, ...
        'position', [0.5, 0, 0.5, 1], ... % Adjusted right side panel width
        'backgroundcolor', [0.2, 0.2, 0.2]);

    % Display screen
    Screen = uicontrol(rightPanel, ...
        'style', 'edit', ...
        'string', '', ...
        'fontsize', 14, ...
        'horizontalalignment', 'right', ...
        'backgroundcolor', [0.9, 0.9, 0.9], ...
        'units', 'normalized', ...
        'position', [0.05, 0.85, 0.9, 0.1]);

    % Initialize memory and mode
    memory = 0;
    mode = 'degrees'; % Default mode
    setappdata(MainFrm, 'memory', memory);
    setappdata(MainFrm, 'lastAnswer', 0);
    setappdata(MainFrm, 'mode', mode);
    setappdata(MainFrm, 'expectingNumber', true);

    % Button layout
    buttonLabels = {
                'C', 'MC', 'MR', 'MS', 'M+', 'M-';
                '(', ')', 'MODE', 'Ans', 'π', 'e';
                'sin', 'cos', 'tan', '√', '^', '!';
                'asin', 'acos', 'atan', '7', '8', '9';
                'ln', 'log', 'exp', '4', '5', '6';
                '<x', 'Ceil', 'Floor', '1', '2', '3';
                '+', '-', '*', '/', '0', '.';
                };

    % Color scheme for different button types
    function color = getButtonColor(label)

        switch label
            case {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.'}
                color = [0.2, 0.6, 1.0]; % Blue numbers
            case {'+', '-', '*', '/', '=', 'C', 'MC', 'MR', 'MS', 'M+', 'M-'}
                color = [1.0, 0.5, 0.0]; % Orange basic ops
            case {'(', ')'}
                color = [0.6, 0.6, 0.6];
            case {'π', 'e'}
                color = [0.4, 0.8, 0.4]; % Green for constants
            case {'sin', 'cos', 'tan', 'asin', 'acos', 'atan', '√', '^', '!', 'ln', 'log', 'exp'}
                color = [0.4, 0.8, 0.4]; % Green for sci func
            case {'<x'}
                color = [1.0, 0.4, 0.4]; % Red
            case {'Ceil', 'Floor'}
                color = [0.5, 0, 0.5]; % Purple mat operations
            otherwise
                color = [0.6, 0.6, 0.6]; % Gray for other buttons
        end

    end

    % Create buttons with new layout and colors
    numRows = size(buttonLabels, 1);
    numCols = size(buttonLabels, 2);
    buttonWidth = 0.15;
    buttonHeight = 0.09;
    startY = 0.75;

    for i = 1:numRows

        for j = 1:numCols
            label = buttonLabels{i, j};
            buttonColor = getButtonColor(label);

            % Create button with visuals
            uicontrol(rightPanel, ...
                'style', 'pushbutton', ...
                'string', label, ...
                'fontsize', 10, ...
                'fontweight', 'bold', ...
                'units', 'normalized', ...
                'position', [(j - 1) * buttonWidth + 0.05, startY - (i * buttonHeight + 0.01), buttonWidth - 0.01, buttonHeight - 0.02], ...
                'callback', {@buttonCallback, Screen, label, MainFrm}, ...
                'backgroundcolor', buttonColor, ...
                'foregroundcolor', [1, 1, 1], ... % White text
                'enable', 'on');
        end

    end

    % Add equals button separately (larger size)
    uicontrol(rightPanel, ...
        'style', 'pushbutton', ...
        'string', '=', ...
        'fontsize', 12, ...
        'fontweight', 'bold', ...
        'units', 'normalized', ...
        'position', [0.05, startY - (numRows + 1) * buttonHeight, 0.9, buttonHeight - 0.01], ...
        'callback', {@buttonCallback, Screen, '=', MainFrm}, ...
        'backgroundcolor', [1.0, 0.5, 0.0], ... % Orange
        'foregroundcolor', [1, 1, 1]); % White text

    % Memory display
    memoryDisplay = uicontrol(rightPanel, ...
        'style', 'text', ...
        'string', 'Memory: 0', ...
        'fontsize', 10, ...
        'horizontalalignment', 'right', ...
        'units', 'normalized', ...
        'position', [0.05, 0.73, 0.9, 0.1]);
    setappdata(MainFrm, 'memoryDisplay', memoryDisplay); % Store it

    % Display screen for statistics
    ScreenStat = uicontrol(leftPanel, ...
        'style', 'edit', ...
        'string', '', ...
        'fontsize', 14, ...
        'horizontalalignment', 'right', ...
        'backgroundcolor', [0.9, 0.9, 0.9], ...
        'units', 'normalized', ...
        'position', [0.05, 0.35, 0.9, 0.1]);

    % Statistical functions
    statisticalFunctions = {
                        'Mean', 'Median', 'Variance', 'StdDev.', 'Range', 'Qtile'
                        };

    % Create statistical function buttons
    for i = 1:length(statisticalFunctions)
        label = statisticalFunctions{i};
        uicontrol(leftPanel, ...
            'style', 'pushbutton', ...
            'string', label, ...
            'fontsize', 10, ...
            'fontweight', 'bold', ...
            'units', 'normalized', ...
            'position', [0.05 + (i - 1) * 0.15, 0.28, 0.14, 0.05], ... % Horizontal arrangement
            'backgroundcolor', [1, 1, 0], ... % Yellow background
            'foregroundcolor', [0, 0, 0], ... % Black text
            'callback', @(src, event) statisticalFunctionCallback(label, ScreenStat, Screen)); % Set callback
    end

    function statisticalFunctionCallback(label, ScreenStat, Screen)
        inputData = str2num(get(ScreenStat, 'string'));

        % Initialize output variable
        result = '';
        displayText = '';

        % handle different statistical functions
        switch label
            case 'Mean'
                result = mean(inputData);
                displayText = sprintf('Mean is: %.2f', result);
            case 'Median'
                result = median(inputData);
                displayText = sprintf('Median is: %.2f', result);
            case 'Variance'
                result = var(inputData);
                displayText = sprintf('Variance is: %.2f', result);
            case 'StdDev.'
                result = std(inputData);
                displayText = sprintf('Standard Deviation is: %.2f', result);
            case 'Range'
                result = range(inputData);
                displayText = sprintf('Range is: %.2f', result);
            case 'Qtile'
                result = prctile(inputData, [25, 50, 75]); % 25th, 50th, and 75th percentiles
                displayText = sprintf('Qtls (25-50-75): [%.2f, %.2f, %.2f]', result(1), result(2), result(3));
            otherwise
                displayText = 'Invalid selection';
        end

        % Display the result in the main screen
        set(Screen, 'string', displayText);
    end

    % Initialize matrices A and B
    matrixA = [];
    matrixB = [];

    % Matrix display
    matrixDisplay = uicontrol(leftPanel, ...
        'style', 'text', ...
        'string', '', ...
        'fontsize', 10, ...
        'horizontalalignment', 'center', ...
        'units', 'normalized', ...
        'position', [0.05, 0.80, 0.9, 0.15]);

    % Callback function for matrix input
    function matrixInputCallback(~, ~, matrixDisplay, matrixNum)
        prompt = sprintf('Enter Matrix %s in the format [1,2;3,4]:', matrixNum);
        currentText = inputdlg(prompt, 'Matrix Input', [1 50]);

        if isempty(currentText)
            return; % User canceled the input
        end

        try
            matrix = eval(currentText{1});

            % Check if the result is a matrix
            if ismatrix(matrix)

                if strcmp(matrixNum, 'A')
                    matrixA = matrix; % Save matrix A
                else
                    matrixB = matrix; % Save matrix B
                end

                updateDisplay();
            else
                error('Input is not a matrix.');
            end

        catch ME
            % Display the error message for debugging
            set(matrixDisplay, 'string', 'Error: Invalid input');
            disp(ME.message); % Print the error message to the console for debugging
        end

    end

    % Update display function
    function updateDisplay()
        displayText = sprintf('Matrix A:\n%s\n\nMatrix B:\n%s', mat2str(matrixA), mat2str(matrixB));
        set(matrixDisplay, 'string', displayText);
    end

    % Add Matrix A input button
    uicontrol(leftPanel, ...
        'style', 'pushbutton', ...
        'string', 'Matrix A', ...
        'fontsize', 10, ...
        'fontweight', 'bold', ...
        'units', 'normalized', ...
        'position', [0.05, 0.70, 0.4, 0.05], ...
        'backgroundcolor', [0.5, 0, 0.5], ... % Purple color
        'foregroundcolor', [1, 1, 1], ... % White text
        'callback', {@matrixInputCallback, matrixDisplay, 'A'});

    % Add Matrix B input button
    uicontrol(leftPanel, ...
        'style', 'pushbutton', ...
        'string', 'Matrix B', ...
        'fontsize', 10, ...
        'fontweight', 'bold', ...
        'units', 'normalized', ...
        'position', [0.55, 0.70, 0.4, 0.05], ...
        'backgroundcolor', [0.5, 0, 0.5], ... % Purple color
        'foregroundcolor', [1, 1, 1], ... % White text
        'callback', {@matrixInputCallback, matrixDisplay, 'B'});

    % Add transpose A button
    uicontrol(leftPanel, ...
        'style', 'pushbutton', ...
        'string', 'Transp A', ...
        'fontsize', 10, ...
        'fontweight', 'bold', ...
        'units', 'normalized', ...
        'position', [0.05, 0.64, 0.30, 0.05], ...
        'callback', @(~, ~) transposeMatrix('A'));

    % Add transpose B button
    uicontrol(leftPanel, ...
        'style', 'pushbutton', ...
        'string', 'Transp B', ...
        'fontsize', 10, ...
        'fontweight', 'bold', ...
        'units', 'normalized', ...
        'position', [0.36, 0.64, 0.30, 0.05], ...
        'callback', @(~, ~) transposeMatrix('B'));

    % Add buttons for matrix operations
    uicontrol(leftPanel, ...
        'style', 'pushbutton', ...
        'string', 'Switch A B', ...
        'fontsize', 10, ...
        'fontweight', 'bold', ...
        'units', 'normalized', ...
        'position', [0.67, 0.64, 0.30, 0.05], ...
        'callback', @(~, ~) switchMatrices());

    uicontrol(leftPanel, ...
        'style', 'pushbutton', ...
        'string', 'A + B', ...
        'fontsize', 10, ...
        'fontweight', 'bold', ...
        'units', 'normalized', ...
        'position', [0.05, 0.57, 0.30, 0.05], ...
        'callback', @(~, ~) performOperation('add'));

    uicontrol(leftPanel, ...
        'style', 'pushbutton', ...
        'string', 'A - B', ...
        'fontsize', 10, ...
        'fontweight', 'bold', ...
        'units', 'normalized', ...
        'position', [0.36, 0.57, 0.30, 0.05], ...
        'callback', @(~, ~) performOperation('subtract'));

    uicontrol(leftPanel, ...
        'style', 'pushbutton', ...
        'string', 'A * B', ...
        'fontsize', 10, ...
        'fontweight', 'bold', ...
        'units', 'normalized', ...
        'position', [0.67, 0.57, 0.30, 0.05], ...
        'callback', @(~, ~) performOperation('multiply'));

    % Button to calculate determinant of A
    uicontrol(leftPanel, ...
        'style', 'pushbutton', ...
        'string', 'Determinant of A', ...
        'fontsize', 10, ...
        'fontweight', 'bold', ...
        'units', 'normalized', ...
        'position', [0.05, 0.50, 0.30, 0.05], ...
        'callback', @(~, ~) calculateDeterminant());

    % Small text box for identity matrix size
    identitySizeInput = uicontrol(leftPanel, ...
        'style', 'edit', ...
        'string', '', ...
        'fontsize', 10, ...
        'horizontalalignment', 'right', ...
        'backgroundcolor', [0.9, 0.9, 0.9], ...
        'units', 'normalized', ...
        'position', [0.36, 0.50, 0.30, 0.05]);

    % Button to generate identity matrix
    uicontrol(leftPanel, ...
        'style', 'pushbutton', ...
        'string', 'Identity Matrix A', ...
        'fontsize', 10, ...
        'fontweight', 'bold', ...
        'units', 'normalized', ...
        'position', [0.67, 0.50, 0.30, 0.05], ...
        'backgroundcolor', [0.5, 0.75, 0.5], ... % Purple color
        'callback', @(~, ~) generateIdentityMatrix());

    % Transpose matrix function
    function transposeMatrix(matrixNum)

        if strcmp(matrixNum, 'A')
            matrixA = matrixA'; % Transpose matrix A
        else
            matrixB = matrixB'; % Transpose matrix B
        end

        updateDisplay(); % Update the display with the new matrices
    end

    % Function to perform matrix operations
    function performOperation(operation)

        switch operation
            case 'add'

                if isempty(matrixA) || isempty(matrixB)
                    set(matrixDisplay, 'string', 'Error: One or both matrices are empty.');
                    return;
                end

                result = matrixA + matrixB;
                set(matrixDisplay, 'string', sprintf('Result of A + B:\n%s', mat2str(result)));
            case 'subtract'

                if isempty(matrixA) || isempty(matrixB)
                    set(matrixDisplay, 'string', 'Error: One or both matrices are empty.');
                    return;
                end

                result = matrixA - matrixB;
                set(matrixDisplay, 'string', sprintf('Result of A - B:\n%s', mat2str(result)));
            case 'multiply'

                if isempty(matrixA) || isempty(matrixB)
                    set(matrixDisplay, 'string', 'Error: One or both matrices are empty.');
                    return;
                end

                result = matrixA * matrixB;
                set(matrixDisplay, 'string', sprintf('Result of A * B:\n%s', mat2str(result)));
        end

    end

    % Function to switch matrices A and B
    function switchMatrices()
        temp = matrixA;
        matrixA = matrixB;
        matrixB = temp;
        updateDisplay();
    end

    % Function to generate identity matrix
    function generateIdentityMatrix()
        sizeStr = get(identitySizeInput, 'string');
        sizeNum = str2double(sizeStr);

        if isnan(sizeNum) || sizeNum <= 0
            set(matrixDisplay, 'string', 'Error: Invalid size for identity matrix.');
            return;
        end

        matrixA = eye(sizeNum);
        updateDisplay();
    end

    % Function to calculate the determinant of matrix A
    function calculateDeterminant()

        if isempty(matrixA)
            set(matrixDisplay, 'string', 'Error: Matrix A is empty.');
            return;
        end

        detA = det(matrixA);
        set(matrixDisplay, 'string', sprintf('Determinant of A: %f', detA));
    end

    % Differential and integral options
    differentialIntegralLabels = {
                            'Differential', 'Integral'
                            };

    % Create differential/integral function buttons
    for i = 1:length(differentialIntegralLabels)
        label = differentialIntegralLabels{i};
        buttonColor = getButtonColor(label);

        % Create button with enhanced visual style
        uicontrol(leftPanel, ...
            'style', 'pushbutton', ...
            'string', label, ...
            'fontsize', 10, ...
            'fontweight', 'bold', ...
            'units', 'normalized', ...
            'position', [0.05, 0.08, 0.9, 0.1], ...
            'callback', {@differentialIntegralCallback, Screen, label, MainFrm}, ...
            'backgroundcolor', buttonColor, ...
            'foregroundcolor', [1, 1, 1]);
    end

end

function buttonCallback(~, ~, Screen, label, MainFrm)
    currentText = get(Screen, 'string');
    memory = getappdata(MainFrm, 'memory');
    lastAnswer = getappdata(MainFrm, 'lastAnswer');
    mode = getappdata(MainFrm, 'mode');
    expectingNumber = getappdata(MainFrm, 'expectingNumber');

    % Helper function to check if a string is a number
    function result = isNumber(str)
        result =~isempty(str) &&~isnan(str2double(str));
    end

    % Helper function to check if the last character is an operator
    function result = lastCharIsOperator(str)

        if isempty(str)
            result = false;
        else
            operators = {'+', '-', '*', '/', '^', ' '};
            result = any(strcmp(str(end), operators));
        end

    end

    % Helper function to check if a string has a decimal point
    function result = hasDecimal(str)
        result =~isempty(strfind(str, '.'));
    end

    % Helper function to sanitize input before eval
    function sanitized = sanitizeExpression(expr)
        % Allow only numbers, operators, parentheses, and predefined symbols
        sanitized = regexprep(expr, '[^\d\.\+\-\*\/\^\(\)π√a-zA-Z]', '');
    end

    switch label
        case '='

            try
                % Replace trigonometric function names with their proper calls
                expression = currentText;

                if strcmp(mode, 'degrees')
                    expression = strrep(expression, 'sin(', 'sin(pi/180*');
                    expression = strrep(expression, 'cos(', 'cos(pi/180*');
                    expression = strrep(expression, 'tan(', 'tan(pi/180*');
                end

                % Replace π and other symbols
                expression = strrep(expression, 'π', 'pi');
                expression = strrep(expression, '√', 'sqrt');

                % Replace factorial symbol '!' with appropriate factorial function
                expression = strrep(expression, '!', '.factorial()'); % Make sure the factorial function is applied to a number

                % Sanitize input before eval
                expression = sanitizeExpression(expression);

                % Evaluate the expression
                result = eval(expression);
                setappdata(MainFrm, 'lastAnswer', result);
                set(Screen, 'string', num2str(result));
                setappdata(MainFrm, 'expectingNumber', true);
            catch
                set(Screen, 'string', 'Error');
            end

        case 'MODE'
            % Toggle between degrees and radians
            if strcmp(mode, 'degrees')
                mode = 'radians';
            else
                mode = 'degrees';
            end

            setappdata(MainFrm, 'mode', mode);
            set(Screen, 'string', ['Mode: ' mode]);
            pause(1);
            set(Screen, 'string', currentText);

        case 'C'
            set(Screen, 'string', '');
            setappdata(MainFrm, 'expectingNumber', true);

        case {'+', '-', '*', '/', '^'}
            % Only add operator if there's a number before it
            if ~isempty(currentText) &&~lastCharIsOperator(currentText)

                if currentText(end) == ' '
                    % Replace last operator
                    currentText = currentText(1:end - 3);
                end

                set(Screen, 'string', [currentText ' ' label ' ']);
            elseif isempty(currentText) && label == '-'
                % Allow negative numbers
                set(Screen, 'string', '-');
            end

        case {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.'}
            % number input handling
            if isempty(currentText) || lastCharIsOperator(currentText)
                % Start new number
                if label == '.' && (isempty(currentText) || currentText(end) == ' ')
                    set(Screen, 'string', [currentText '0.']);
                else
                    set(Screen, 'string', [currentText label]);
                end

            else
                % Continue building number
                lastNumber = strtok(fliplr(currentText), ' ');
                lastNumber = fliplr(lastNumber);

                % Check for decimal point
                if label == '.' && hasDecimal(lastNumber)
                    return; % Don't allow multiple decimal points
                end

                set(Screen, 'string', [currentText label]);
            end

        case {'sin', 'cos', 'tan', 'asin', 'acos', 'atan'}
            set(Screen, 'string', [currentText label '(']);

        case {'(', ')'}
            set(Screen, 'string', [currentText label]);

        case 'Ans'

            if isempty(currentText) || lastCharIsOperator(currentText)
                set(Screen, 'string', [currentText num2str(lastAnswer)]);
            end

        case 'π'

            if isempty(currentText) || lastCharIsOperator(currentText)
                set(Screen, 'string', [currentText 'π']);
            end

        case {'MC', 'MR', 'MS', 'M+', 'M-'}
            % Memory operations
            memoryDisplay = getappdata(MainFrm, 'memoryDisplay'); % Retrieve it

            switch label
                case 'MC'
                    setappdata(MainFrm, 'memory', 0);
                    set(memoryDisplay, 'string', 'Memory: 0'); % Update display
                case 'MR'

                    if isempty(currentText) || lastCharIsOperator(currentText)
                        set(Screen, 'string', [currentText num2str(memory)]);
                    end

                case 'MS'

                    try
                        newMemory = eval(sanitizeExpression(currentText));
                        setappdata(MainFrm, 'memory', newMemory);
                        set(memoryDisplay, 'string', ['Memory: ' num2str(newMemory)]); % Update display
                    catch
                        set(memoryDisplay, 'string', 'Error');
                    end

                case 'M+'

                    try
                        newMemory = memory + eval(sanitizeExpression(currentText));
                        setappdata(MainFrm, 'memory', newMemory);
                        set(memoryDisplay, 'string', ['Memory: ' num2str(newMemory)]); % Update display
                    catch
                        set(memoryDisplay, 'string', 'Error');
                    end

                case 'M-'

                    try
                        newMemory = memory - eval(sanitizeExpression(currentText));
                        setappdata(MainFrm, 'memory', newMemory);
                        set(memoryDisplay, 'string', ['Memory: ' num2str(newMemory)]); % Update display
                    catch
                        set(memoryDisplay, 'string', 'Error');
                    end

            end

        case {'√'}
            % Square root function
            if ~isempty(currentText) &&~lastCharIsOperator(currentText)
                % Check if there's a number before it
                set(Screen, 'string', [currentText ' ' label ' ']);
            elseif isempty(currentText)
                % Handle empty input case
                set(Screen, 'string', '√(');
            end

        case {'!'}
            % Factorial function
            if ~isempty(currentText) &&~lastCharIsOperator(currentText)
                % If there’s a number before it, evaluate the factorial
                num = str2double(currentText);

                if ~isnan(num)% Ensure that the currentText is a number
                    result = factorial(num);
                    set(Screen, 'string', num2str(result));
                else
                    % If currentText is not a valid number, show an error or the number with '!'
                    set(Screen, 'string', [currentText ' ' label ' ']);
                end

            elseif isempty(currentText)
                % Handle empty input case
                set(Screen, 'string', '!');
            end

        case '<x'
            %backspace
            if ~isempty(currentText)
                set(Screen, 'string', currentText(1:end - 1));
            end

        case 'Ceil'
            set(Screen, 'string', [currentText label 'ceil(']);

        case 'Floor'
            set(Screen, 'string', [currentText label 'floor(']);

        otherwise
            set(Screen, 'string', [currentText label]);
    end

end

function differentialIntegralCallback(~, ~, Screen, label, MainFrm)
    currentText = get(Screen, 'string');
    lastAnswer = getappdata(MainFrm, 'lastAnswer');

    if strcmp(label, 'Differential')

        if isempty(currentText) || currentText(end) ~= ' '
            set(Screen, 'string', 'Enter function and press space for differential');
            return;
        end

        % Replace trigonometric function names with their proper calls
        expression = currentText;

        if strcmp(getappdata(MainFrm, 'mode'), 'degrees')
            expression = strrep(expression, 'sin(', 'sin(pi/180*');
            expression = strrep(expression, 'cos(', 'cos(pi/180*');
            expression = strrep(expression, 'tan(', 'tan(pi/180*');
            expression = strrep(expression, 'asin(', 'asin(');
            expression = strrep(expression, 'acos(', 'acos(');
            expression = strrep(expression, 'atan(', 'atan(');
        end

        % Replace π and other symbols
        expression = strrep(expression, 'π', 'pi');
        expression = strrep(expression, '√', 'sqrt');

        % Add dx to the expression
        expression = [expression, ' dx'];

        try
            result = eval(expression);
            setappdata(MainFrm, 'lastAnswer', result);
            set(Screen, 'string', num2str(result));
        catch
            set(Screen, 'string', 'Error');
        end

    elseif strcmp(label, 'Integral')

        if isempty(currentText)
            set(Screen, 'string', 'Enter function and press space for integral');
            return;
        end

        % Replace trigonometric function names with their proper calls
        expression = currentText;

        if strcmp(getappdata(MainFrm, 'mode'), 'degrees')
            expression = strrep(expression, 'sin(', 'sin(pi/180*');
            expression = strrep(expression, 'cos(', 'cos(pi/180*');
            expression = strrep(expression, 'tan(', 'tan(pi/180*');
            expression = strrep(expression, 'asin(', 'asin(arcsin(');
            expression = strrep(expression, 'acos(', 'acos(arccos(');
            expression = strrep(expression, 'atan(', 'atan(arctan(');
        end

        % Replace π and other symbols
        expression = strrep(expression, 'π', 'pi');
        expression = strrep(expression, '√', 'sqrt');

        % Add dx to the expression
        expression = [expression, ' dx'];

        try
            result = int(eval(expression));
            setappdata(MainFrm, 'lastAnswer', result);
            set(Screen, 'string', num2str(result));
        catch
            set(Screen, 'string', 'Error');
        end

    end

end
