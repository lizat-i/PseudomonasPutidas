%% Initialize 
close all
clear all
format

addpath("/home/ivan/dev/Project/cobratoolbox","files/","files/iJN1462/","figures/","tutorials/","functions/","tutorials/websiteTUT/")

%% Execute this part only ones when starting work

%initCobraToolbox(false) % false, as we don't want to update

%change Solver:
      solverName = 'ibm_cplex';
      solverType = 'LP'; 
      changeCobraSolver(solverName, solverType);
      changeCobraSolver ('ibm_cplex', 'QP')
      
%% read original Model

iJN1462_initial    = readCbModel('files/iJN1462/iNogalesEtAl.xml');

% renaming nonUnique metabolites
% checkCobraModelUnique(iJN1462,'acmtsoxin')

%%
%ExchReaSummTab(model,false)

% Modify Boundary Conditions

% choose Medium and adjust BC
   % medium 1 = glucose min Medium M9
   % medium 2 = In silico Luria Broth (LB) medium
   % medium 3 = reseting all reactions to +/- 1000
   

medium = 1;

% Allways first initialization of the Medium
% it is setting all the ExchangeReaction to -/+ 1000 

iJN1462       = iJN1462_initial;
%changeObjective(iJN1462,'BiomassKT2440_Core2');
% iJN1462     = setMediumBoundaries(iJN1462_initial,3);
% iJN1462     = setMediumBoundaries(iJN1462_initial,2);
% iJN1462     = setMediumBoundaries(iJN1462_initial,1);
 

%%
 iJN1462     = setMediumBoundaries(iJN1462_initial,medium);

% negative value means uptake, positive means secretion
[iJN1462_GLC_UR6_3,iJN1462_GLC_UR7_3,iJN1462_GLN_UR5_1,iJN1462_GLC_UR10_9,iJN1462_OCT_UR3_4]  =   deal(iJN1462);

iJN1462_GLC_UR6_3   = changeRxnBounds(iJN1462_GLC_UR6_3,'EX_glc__D_e',-6.3,'l')     ;
iJN1462_GLC_UR7_3   = changeRxnBounds(iJN1462_GLC_UR7_3,'EX_glc__D_e',-7.3,'l')     ;


iJN1462_GLN_UR5_1   = changeRxnBounds(iJN1462_GLN_UR5_1,'EX_glc__D_e',0,'l')        ;
iJN1462_GLN_UR5_1   = changeRxnBounds(iJN1462_GLN_UR5_1,'EX_glc__D_e',999999,'u')   ;
iJN1462_GLN_UR5_1   = changeRxnBounds(iJN1462_GLN_UR5_1,'EX_glcn_e',-5.1,'l')       ;

iJN1462_GLC_UR10_9  = changeRxnBounds(iJN1462_GLC_UR10_9,'EX_glc__D_e',-10.9,'l')   ;
iJN1462_GLC_UR10_9  = changeRxnBounds(iJN1462_GLC_UR10_9,'EX_glcn_e',2.8,'l')       ;
iJN1462_GLC_UR10_9  = changeRxnBounds(iJN1462_GLC_UR10_9,'EX_2dhglcn_e',2.6,'l')    ;

%iJN1462_OCT_UR3_4   = changeRxnBounds(iJN1462_OCT_UR3_4,'EX_glc__D_e',0,'l')        ;
%iJN1462_OCT_UR3_4   = changeRxnBounds(iJN1462_OCT_UR3_4,'EX_glc__D_e',9999,'u')    ;
iJN1462_OCT_UR3_4   = changeRxnBounds(iJN1462_OCT_UR3_4,'EX_octa_e',-3.4,'l')       ;
iJN1462_OCT_UR3_4   = changeRxnBounds(iJN1462_OCT_UR3_4,'EX_nh4_e',-3.1,'l')        ; %Nitrogen uptake constraint 
iJN1462_OCT_UR3_4   = changeRxnBounds(iJN1462_OCT_UR3_4,'EX_o2_e',-13.5,'l')        ; %Oxygen   uptake constraint 



%%
% Solve Problem

S_UR5_1 = optimizeCbModel(iJN1462_GLN_UR5_1)      ;
S_UR6_3 = optimizeCbModel(iJN1462_GLC_UR6_3)      ;
S_UR7_3 = optimizeCbModel(iJN1462_GLC_UR7_3)      ; 
S_UR10_9= optimizeCbModel(iJN1462_GLC_UR10_9)     ;
S_UR3_4 = optimizeCbModel(iJN1462_OCT_UR3_4)      ;

% make Printable  Table with Solutions 

[T_row1] = createRelevantOutput(iJN1462_GLN_UR5_1,S_UR5_1,"Gluconate")	;
[T_row2] = createRelevantOutput(iJN1462_GLC_UR6_3,S_UR6_3,"Glucose")	;
[T_row3] = createRelevantOutput(iJN1462_GLC_UR7_3,S_UR7_3,"Glucose")	;   
[T_row4] = createRelevantOutput(iJN1462_GLC_UR10_9,S_UR10_9,"Glucose")	;
[T_row5] = createRelevantOutput(iJN1462_OCT_UR3_4,S_UR3_4,"Octanoate")	;
 
T = [T_row1;T_row2;T_row3;T_row4;T_row5];

disp(T)

%% Try FVA
[selExc, selUpt]    =   findExcRxns(model)      ;
uptakes             =    model.rxns(selUpt)     ; 




%% Check Values of ExhangeReactions and use Boundaries
surfNetExchR(iJN1462_OCT_UR3_4,S_UR3_4)


%surfNet(model, object, metNameFlag, flux, nonzeroFluxFlag, showMets, printFields, charPerLine, similarity)
 
%% Code Snippets for Later Use
% Print C60 : C80 aliphatic phynylic acetylthio PHA's
%T = createMetabolitOutput(iJN1462_OCT_UR3_4,S_UR3_4);
%disp(T)
%% IMPORTANT BEFEHLE!!%%

%   surfNet(model, 'pyr[c]', [], solution.x)
%   fluxMatrix = [s.x, sFru.x];  % put two flux vectors in a matrix
%   reactions with different fluxes
%   rxnDiff = abs(fluxMatrix(:, 1) - fluxMatrix(:, 2)) > 1e-6;  
%   surfNet(iJO1366, iJO1366.rxns(rxnDiff), [], fluxMatrix, [], 0)
 
%  printUptakeBound(iJN1462_OCT_UR3_4);
%  printUptakeBound(iJN1462);
%  printUptakeBound(iJN1462_OCT_UR3_4);
%  printConstraints(model)  all Reactions
%  printUptakeBound(model)  aufnahmeRaten der anzeigen
%  surfNet(iJN1462_initial) nice Zusammenfassung !
%  printFluxVector(iJN1462_OCT_UR3_4,S_UR3_4.v)


% initialize Cobratoolbox:
%       initCobraToolbox() % false, as we don't want to update
% change Solver:
%       solverName = 'ibm_cplex';
%       solverType = 'LP'; 
%       changeCobraSolver(solverName, solverType);
 
% find ReactionIndex and get reactionEQ lb ub and rxns :
%       [GlucoseURIndex,~] = getIDPositions(iJN1462,'EX_glcn_e','rxns')
%                               printRxnFormula(iJN1462, 'EX_glcn_e')
%       GlucoseUR          = iJN1462.rxns(GlucoseURIndex)   
%       GlucoseUR          = iJN1462.lb(GlucoseURIndex)                     
%       GlucoseUR          = iJN1462.ub(GlucoseURIndex)   

%  find ExtchangeReaction and get reactionEQ lb ub and rxns :
% iJN1462_GLC_UR10_9.rxns(findExcRxns(iJN1462_GLC_UR10_9,0))
 
% EX_glc__D_e	        -6.300	      1000.000 ... is glucose uptake

%objFunctionrxns = checkObjective(iJN1462)                ;
%getIDPositions(iJN1462,'BiomassKT2440_WT3','rxns')
% printRxnFormula(iJN1462,'BiomassKT2440_WT3')
% Objective Function Correlates to the Biomass Composition found through
% analysis
    

%T_EXch = ExchReaSummTab(iJN1462,true)
%disp(T_EXch)
 

%printRxnFormula(iJN1462,PHAC6Search.rxns.id)

% find ExchangeReaction 
% iJN1462.rxnNames(find(findExcRxns(iJN1462)))

% [GlucoseURIndex,~] = getIDPositions(iJN1462_GLC_UR10_9,'EX_glcn__e','rxns') ;
%  GlucoseUR     = model.lb(GlucoseURIndex)                       
 

% S_UR5_1 = solveCobraCPLEX(iJN1462_GLN_UR5_1)    ;
 
