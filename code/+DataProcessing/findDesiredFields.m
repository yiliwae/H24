function findDesiredFields(data_struct, InputFieldnames)

fn=fieldnames(data_struct);
idxFn= contains(fn, InputFieldnames);
disp(fn(idxFn));


end