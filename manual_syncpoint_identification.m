function final_x = manual_syncpoint_identification(time, sig,estimated_toggle_range)
%MANUAL_SYNCPOINT_IDENTIFICATION Summary of this function goes here
%   Detailed explanation goes here
% Sample data
x = time;
y = sig;

% Plot the data
figure('Position', [10 10 900 600]);
hPlot = plot(x, y, '-');
title('Click on a point, or press "Enter" to finish, or "n" for no selection');
xlim(estimated_toggle_range - [1000,-1000])
xlabel('X');
ylabel('Y');
hold on;

% Enable toggle button for switching modes
toggle_mode_button = uicontrol('Style', 'togglebutton', 'String', 'Toggle Mode', ...
    'Position', [20 20 100 30]);
set(toggle_mode_button, 'Callback', @(src, event) disp('Mode Toggled'));

% Initialize mode label
mode_label = uicontrol('Style', 'text', 'Position', [140, 20, 120, 30], ...
    'String', 'Mode: Selection', 'FontSize', 12);

% Initialize variables for final selected point and marker
final_x = NaN;
final_y = NaN;
selected_idx = NaN;
marker = [];

% Loop to allow switching between selection and manipulation modes
manipulation_mode = false;

while true
    % Check if manipulation mode is on
    if manipulation_mode
        % Enable zooming and panning
        zoom on;
        pan on;
        datacursormode on;
        set(mode_label, 'String', 'Mode: Manipulation');  % Update mode label
        disp('Manipulation mode enabled. Use zoom, pan, and data cursor.');

        % Wait for the user to toggle back to selection mode
        waitfor(toggle_mode_button, 'Value', 0);
        
        % Disable interactive features for selection mode
        zoom off;
        pan off;
        datacursormode off;
        manipulation_mode = false;  % Switch back to selection mode
        set(mode_label, 'String', 'Mode: Selection');  % Update mode label
        disp('Switched to selection mode.');
    else
        % Disable zooming and panning to ensure manipulation mode is not active
        zoom off;
        pan off;
        datacursormode off;

        % Wait for user to click or press a key in selection mode
        w = waitforbuttonpress;

        if w == 1  % Key press
            key_pressed = get(gcf, 'CurrentCharacter');

            % Check for "Enter" key (ASCII code 13) to finalize selection
            if strcmp(key_pressed, char(13))
                break;  % Exit loop to finalize the selection
            elseif strcmpi(key_pressed, 'n')
                % If 'n' is pressed, indicate no selection
                final_x = NaN;
                final_y = NaN;
                selected_idx = NaN;
                disp('No selection made.');
                break;
            end
        elseif w == 0  % Mouse click in selection mode
            % Get the clicked coordinates in data units
            click_coords = get(gca, 'CurrentPoint');
            x_click = click_coords(1, 1);
            y_click = click_coords(1, 2);

            % Find the nearest data point
            % Adjust x and y arrays to match the current axis limits
            [~, idx] = min((x - x_click).^2);
            nearest_x = x(idx);
            nearest_y = y(idx);

            % Update the final selected point
            final_x = nearest_x;
            final_y = nearest_y;
            selected_idx = idx;

            % Display the current selection
            disp(['Current selection: X = ', num2str(final_x), ', Y = ', num2str(final_y)]);

            % Update the marker for the new selection
            if ishandle(marker)
                delete(marker);  % Remove the previous marker
            end
            marker = plot(final_x, final_y, 'rx', 'MarkerSize', 10, 'LineWidth', 2);
        end
    end
    
    % Check if the toggle button is pressed to switch modes
    if get(toggle_mode_button, 'Value') == 1 && ~manipulation_mode
        manipulation_mode = true;  % Switch to manipulation mode
    end
end

% Show final selection (if any)
if ~isnan(selected_idx)
    disp(['Final selected point: X = ', num2str(final_x), ', Y = ', num2str(final_y)]);
else
    disp('No point was selected.');
end

% Clean up
hold off;

end

