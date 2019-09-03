% Copyright 2015 Xilin Shen and Emily Finn 

% This code is released under the terms of the GNU GPL v2. This code
% is not FDA approved for clinical use; it is provided
% freely for research purposes. If using this in a publication
% please reference this properly as: 

% Finn ES, Shen X, Scheinost D, Rosenberg MD, Huang, Chun MM,
% Papademetris X & Constable RT. (2015). Functional connectome
% fingerprinting: Identifying individuals using patterns of brain
% connectivity. Nature Neuroscience 18, 1664-1671.

% This code provides a framework for implementing functional
% connectivity-based identification of individual subjects across two scan
% sessions, as described in Finn, Shen et al 2015 (see above for full
% reference). It assumes an input of pre-calculated correlation matrices of
% dimension NxN for each subject for each session, where N = number of
% nodes in the chosen brain atlas. Each element (i,j) in these matrices
% represents the correlation between the BOLD timecourses of nodes i and j
% during a single fMRI session. The distance metric used to predict
% identity of the target matrix is Pearson correlation.

% Reference: Finn ES, Shen X, Scheinost D, Rosenberg MD, Huang, Chun MM,
% Papademetris X & Constable RT. (2015). Functional connectome
% fingerprinting: Identifying individuals using patterns of brain
% connectivity. Nature Neuroscience 18, 1664?1671.


clear;
clc;


% load connectivity matrices from all subjects 

% connectivity matrices must first be vectorized to length M (assuming
% matrices are symmetric this can be done using triu or tril and then
% reshape)

% all_se1 is obtained from session 1 
% all_se1 is M by N matrix, M is the number of edges in the selected network, N is the number of subjects 
% all_se2 is M by N matrix, from session 2


count1 = 0;
count2 = 0;

no_sub = size(all_se1, 2);

for i=1: no_sub;
    
    % using session 1 as database 
    
    tt_corr = all_se2(:, i);
    
    tt_to_all = corr(tt_corr, all_se1);
    [~, va_id] = max(tt_to_all);
            
    if( i == va_id)    
        count1 = count1+1;
    end
        
    clear tt_corr tt_to_all va_id
    
    % using session 2 as database  
    
    tt_corr = all_se1(:, i);
    
    tt_to_all = corr(tt_corr, all_se2);
    [~, va_id] = max(tt_to_all);
    
    if( i == va_id)    
        count2 = count2+1;
    end
    
end

 rate1 = count1/no_sub;
 rate2 = count2/no_sub;
