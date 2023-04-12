function combined_image = combine_columns(total_image)
    
    % Combining Initial Couple
    combined_image = cat(1, cell2mat(total_image(1)), cell2mat(total_image(2)));
    
    % Combining the rest
    for image = 3:size(total_image, 2)
        combined_image = cat(1, combined_image, cell2mat(total_image(image)));
    end

end