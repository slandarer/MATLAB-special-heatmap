varechem = readtable('varechem.csv');
varespec = readtable('varespec.csv');
reference = 'Väre, H., Ohtonen, R. and Oksanen, J. (1995) Effects of reindeer grazing on understorey vegetation in dry Pinus sylvestris forests. Journal of Vegetation Science 6, 523–530.'
README = {'The data originate from the vegan package in R and are employed as an example dataset in the MATLAB tool SHeatmap to reproduce the Mantel test demonstration from the R package linkET. Detailed information on the data is provided below.';
    'The varespec data frame has 24 rows and 44 columns. Columns are estimated cover values of 44 species. The variable names are formed from the scientific names, and are self explanatory for anybody familiar with the vegetation type. The varechem data frame has 24 rows and 14 columns, giving the soil characteristics of the very same sites as in the varespec data frame. The chemical measurements have obvious names. Baresoil gives the estimated cover of bare soil, Humdepth the thickness of the humus layer.'}

save lichenData.mat varechem varespec reference README
