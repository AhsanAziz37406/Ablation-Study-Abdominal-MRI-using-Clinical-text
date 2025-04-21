%% Step 1: Load BERT model and tokenizer
[net, tokenizer] = bert;

%% Step 2: Load clinical Excel data
opts = detectImportOptions('D:\abdominal xray\_excel\intenranl_ER_AXR_220328_finalnew.xlsx');
data = readtable('D:\abdominal xray\_excel\intenranl_ER_AXR_220328_finalnew.xlsx', opts);

% Optional: Remove unnamed columns if present
data(:, contains(data.Properties.VariableNames, 'Unnamed')) = [];

% Check column names
disp(data.Properties.VariableNames)

%% Step 3: Extract the clinical text column (e.g., 'Consciousness_text')
texts = data.Consciousness_text;  % Change this to exact column name if different
texts = string(texts);

% Handle missing or empty texts
texts(ismissing(texts)) = "";

%% Step 4: Encode text to embeddings using CLS token (768-dim)
embeddings = zeros(length(texts), 768);  % BERT-base CLS embeddings

for i = 1:length(texts)
    try
        % Tokenize the text
        tokens = tokenize(tokenizer, texts(i));

        % Get embeddings: last hidden state
        encoded = bertEncode(tokens, net, 'OutputType', 'last-hidden-state');

        % Use CLS token (first token) as representative vector
        clsEmbedding = encoded(1, :);  % 1x768 vector

        % Save it into embeddings matrix
        embeddings(i, :) = gather(extractdata(clsEmbedding));
    catch ME
        warning("Issue at row %d: %s", i, ME.message);
        % You can also choose to set embeddings(i,:) = NaN(1,768);
    end
end

%% Step 5: Save the embeddings for future fusion use
save('bert_embeddings.mat', 'embeddings');
