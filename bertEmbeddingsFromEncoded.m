function features = bertEmbeddingsFromEncoded(net, encodedText)

    % Check if encode returned a struct
    if isstruct(encodedText)
        tokenIDs = encodedText.InputIDs;
        attentionMask = encodedText.AttentionMask;
    else
        error("Encoding failed: expected a struct with InputIDs and AttentionMask.");
    end

    % Convert to dlarray
    dlTokenIDs = dlarray(single(tokenIDs), 'CB');
    dlMask = dlarray(single(attentionMask), 'CB');

    % Predict using the BERT network
    bertOutput = predict(net, {dlTokenIDs, dlMask});

    % Extract the CLS token representation
    clsToken = bertOutput{1}(:,1);

    features = clsToken';  % Return as a row vector [1 x 768]
end
