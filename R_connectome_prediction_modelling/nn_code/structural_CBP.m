%% Loads Data
% load toolboxes and define paths
% ------------------------
clear all
close all
addpath('/home/rr/git_here/oma/matlab_scripts/connectome/')
aloita('/home/rr/Escritorio/conx_matrices/')

% Matrices
load('/home/rr/git_here/oma/matlab_scripts/connectome/bcm.mat')
clear A BC CC D Dim Eglob Eloc K Kden K N O Q L P RPATH S ans degree diameter ecc i isonode kden lambda module n pathtoolbox radius

% Selects those with Neuropsycometry
Pos=[6 11 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 46 47 48 49 51 52 53 55 56 57 58 59 60 61 62 63 64 65 66 67 68];
all_mats=CASES(:,:,Pos);

% Behavioral data
all_behav=[0.20773679  0.48107467  0.93663781  0.48107467  0.02551154  0.75441256  2.02998934  0.02551154 -1.15895262 -1.15895262 -0.79450211 -0.61227686  0.02551154  1.39220095  0.48107467  1.20997569 0.48107467 -0.15671372 -1.25006525 -2.61675466  0.48107467 -1.15895262  1.84776408 -2.07007889 -0.15671372 -0.79450211 -2.07007889 -0.15671372 -0.61227686 -2.61675466 -1.52340313 -1.25006525 -2.61675466 -2.07007889 -3.52788093 -2.89009254 -2.34341678 -2.89009254 -2.61675466 -0.79450211 -0.15671372 -4.43900721 -0.79450211 -1.52340313 -2.61675466 -0.79450211  0.02551154 -0.79450211 0.20773679  0.93663781 -0.15671372 -2.89009254 -0.15671372 -0.61227686 -2.07007889];
all_behav=all_behav';
clear CASES IDs Pos

% threshold for feature selection
thresh = 0.01;

% ---------------------------------------
no_sub = size(all_mats,3);
no_node = size(all_mats,1);

behav_pred_pos = zeros(no_sub,1);
behav_pred_neg = zeros(no_sub,1);

for leftout = 1:no_sub;
	    fprintf('\n Leaving out subj # %6.3f',leftout);

	    %------------------------------------------------    
	    % STEP 2 - TRAINNING & CROSS VALIDATIONS SUB-GROUPS
	    %------------------------------------------------
	    % leave out subject from matrices and behavior
	    
	    train_mats = all_mats;
	    train_mats(:,:,leftout) = [];
	    train_vcts = reshape(train_mats,[],size(train_mats,3));
	    
	    train_behav = all_behav;
	    train_behav(leftout) = [];

	    %------------------------------------------------    
	    % STEP 3 - RELATION OF CONNECTIVITY TO BEHAVIOR
	    %------------------------------------------------
	    % correlate all edges with behavior

	    [r_mat,p_mat] = corr(train_vcts',train_behav);
	    
	    r_mat = reshape(r_mat,no_node,no_node);
	    p_mat = reshape(p_mat,no_node,no_node);
	    
	    %------------------------------------------------
	    % STEP 4 - EDGE SELECTION
	    %------------------------------------------------
	    % set threshold and define masks
        pos_mask = zeros(no_node,no_node);
        neg_mask = zeros(no_node,no_node);
	    
	    pos_edges = find(r_mat > 0 & p_mat < thresh);
	    neg_edges = find(r_mat < 0 & p_mat < thresh);
	    
	    pos_mask(pos_edges) = 1;
	    neg_mask(neg_edges) = 1;
        
        %------------------------------------------------
	    % ALTERNATIVE STEP 4  - EDGE SELECTION
	    %------------------------------------------------
	    % Sigmoidal weighting
%         pos_edges = find(r_mat > 0);
% 	    neg_edges = find(r_mat < 0);
%         % convert p threshold to r threshold
%         T = tinv(thresh/2, no_sub-1-2);
%         R = sqrt(T^2/(no_sub-1-2+T^2));
%         % Weighted mask using a sigmoidal function
%         % weight = 0.05, when correlation = R/3
%         % weight = 0.88, when correlation = R
%         pos_mask(pos_edges) = sigmf(r_mat(pos_edges), [3/R, R/3]);
%         neg_mask(neg_edges) = sigmf(r_mat(neg_edges), [-3/R, R/3]);
	    
	    %------------------------------------------------
	    % STEP 5 -SINGLE SUBJECT SUMMARY VALUES 
	    %------------------------------------------------
	    % get sum of all edges in TRAIN subs (divide by 2 to control for the
	    % fact that matrices are symmetric)
	    
	    train_sumpos = zeros(no_sub-1,1);
	    train_sumneg = zeros(no_sub-1,1);
	    
	    for ss = 1:size(train_sumpos);
		train_sumpos(ss) = sum(sum(train_mats(:,:,ss).*pos_mask))/2;
		train_sumneg(ss) = sum(sum(train_mats(:,:,ss).*neg_mask))/2;
	    end
	    
	    %------------------------------------------------
	    % STEP 6 - MODEL FITTING
	    %------------------------------------------------
	    % build model on TRAIN subs
	    fit_pos = polyfit(train_sumpos, train_behav,1);
	    fit_neg = polyfit(train_sumneg, train_behav,1);
	    

	    % run model on TEST sub
	    test_mat = all_mats(:,:,leftout);
	    test_sumpos = sum(sum(test_mat.*pos_mask))/2;
	    test_sumneg = sum(sum(test_mat.*neg_mask))/2;
	    
	    %------------------------------------------------
		% STEP 7 - PREDICTION IN NOVEL SUBJECTS
		%------------------------------------------------
	    behav_pred_pos(leftout) = fit_pos(1)*test_sumpos + fit_pos(2);
	    behav_pred_neg(leftout) = fit_neg(1)*test_sumneg + fit_neg(2);
    
end


%------------------------------------------------
% STEP 8 - EVALUATION OF THE PREDICTIVE MODEL
%------------------------------------------------
% compare predicted and observed scores
[R_pos, P_pos] = corr(behav_pred_pos,all_behav)
[R_neg, P_neg] = corr(behav_pred_neg,all_behav)

figure(1); plot(behav_pred_pos,all_behav,'r.'); lsline
figure(2); plot(behav_pred_neg,all_behav,'b.'); lsline
