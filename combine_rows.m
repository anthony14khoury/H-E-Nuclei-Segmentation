function combined_image = combine_rows(binary_row)
    
    % Combining Initial Couple
    combined_image = cat(2, cell2mat(binary_row(1)), cell2mat(binary_row(2)));
    
    % Combining the rest
    for image = 3:size(binary_row, 2)
        combined_image = cat(2, combined_image, cell2mat(binary_row(image)));
    end

end