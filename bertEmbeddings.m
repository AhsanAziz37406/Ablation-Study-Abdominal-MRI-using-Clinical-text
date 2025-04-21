function features = bertEmbeddings(tokenizer, net, textInput)
    encoded = encode(tokenizer, textInput);  % this gives a struct if tokenizer is correct
    features = bertEmbeddingsFromEncoded(net, encoded);
end
