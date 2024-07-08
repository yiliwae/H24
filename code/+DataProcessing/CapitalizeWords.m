function capitalizedStr= CapitalizeWords(str)

words = strsplit(str, ' ');  % Split the string into words
capitalizedWords = cellfun(@(word) [upper(word(1)), lower(word(2:end))], words, 'UniformOutput', false);
capitalizedStr = strjoin(capitalizedWords, ' ');

end