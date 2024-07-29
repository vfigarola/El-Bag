%% Victoria Figarola
% This script creates the condition matrix used for
% generating_experimental_trials

function [anech_condition_matrix, reverb_condition_matrix] = creating_condition_matrix()

% first_condition_matrix_v1 = ["anech";"left";"uninter";"same";"female"];
first_condition_matrix_v2 = ["anech";"left";"uninter";"alu"];
% first_condition_matrix_v2 = ["anech";"left";"uninter";"same";"male"];
% first_condition_matrix_v3 = ["anech";"left";"uninter";"diff";"female"];
% first_condition_matrix_v4 = ["anech";"left";"uninter";"diff";"male"];

% second_condition_matrix_v1 = ["anech";"right";"uninter";"same";"female"];
% second_condition_matrix_v2 = ["anech";"right";"uninter";"same";"male"];
second_condition_matrix_v2 = ["anech";"right";"uninter";"aru"];
% second_condition_matrix_v3 = ["anech";"right";"uninter";"diff";"female"];
% second_condition_matrix_v4 = ["anech";"right";"uninter";"diff";"male"];

% third_condition_matrix_v1 = ["anech";"left";"inter";"same";"female"];
third_condition_matrix_v2 = ["anech";"left";"inter";"ali"];
% third_condition_matrix_v2 = ["anech";"left";"inter";"same";"male"];
% third_condition_matrix_v3 = ["anech";"left";"inter";"diff";"female"];
% third_condition_matrix_v4 = ["anech";"left";"inter";"diff";"male"];

% fourth_condition_matrix_v1 = ["anech";"right";"inter";"same";"female"];
fourth_condition_matrix_v2 = ["anech";"right";"inter";"ari"];
% fourth_condition_matrix_v2 = ["anech";"right";"inter";"same";"male"];
% fourth_condition_matrix_v3 = ["anech";"right";"inter";"diff";"female"];
% fourth_condition_matrix_v4 = ["anech";"right";"inter";"diff";"male"];

% fifth_condition_matrix_v1 = ["reverb";"left";"uninter";"same";"female"];
fifth_condition_matrix_v2 = ["reverb";"left";"uninter";"rlu"];
% fifth_condition_matrix_v2 = ["reverb";"left";"uninter";"same";"male"];
% fifth_condition_matrix_v3 = ["reverb";"left";"uninter";"diff";"female"];
% fifth_condition_matrix_v4 = ["reverb";"left";"uninter";"diff";"male"];

% sixth_condition_matrix_v1 = ["reverb";"right";"uninter";"same";"female"];
sixth_condition_matrix_v2 = ["reverb";"right";"uninter";"rru"];
% sixth_condition_matrix_v2 = ["reverb";"right";"uninter";"same";"male"];
% sixth_condition_matrix_v3 = ["reverb";"right";"uninter";"diff";"female"];
% sixth_condition_matrix_v4 = ["reverb";"right";"uninter";"diff";"male"];

% seventh_condition_matrix_v1 = ["reverb";"left";"inter";"same";"female"];
seventh_condition_matrix_v2 = ["reverb";"left";"inter";"rli"];
% seventh_condition_matrix_v2 = ["reverb";"left";"inter";"same";"male"];
% seventh_condition_matrix_v3 = ["reverb";"left";"inter";"diff";"female"];
% seventh_condition_matrix_v4 = ["reverb";"left";"inter";"diff";"male"];

% eigth_condition_matrix_v1 = ["reverb";"right";"inter";"same";"female"];
eigth_condition_matrix_v2 = ["reverb";"right";"inter";"rri"];
% eigth_condition_matrix_v2 = ["reverb";"right";"inter";"same";"male"];
% eigth_condition_matrix_v3 = ["reverb";"right";"inter";"diff";"female"];
% eigth_condition_matrix_v4 = ["reverb";"right";"inter";"diff";"male"];


anech_condition_matrix = [first_condition_matrix_v2, second_condition_matrix_v2, third_condition_matrix_v2, fourth_condition_matrix_v2];
reverb_condition_matrix = [fifth_condition_matrix_v2, sixth_condition_matrix_v2, seventh_condition_matrix_v2,eigth_condition_matrix_v2];




% anech_condition_matrix = [first_condition_matrix_v1 first_condition_matrix_v2 first_condition_matrix_v3 first_condition_matrix_v4 ...
%     second_condition_matrix_v1 second_condition_matrix_v2 second_condition_matrix_v3 second_condition_matrix_v4 ...
%     third_condition_matrix_v1 third_condition_matrix_v2 third_condition_matrix_v3 third_condition_matrix_v4 ...
%     fourth_condition_matrix_v1 fourth_condition_matrix_v2 fourth_condition_matrix_v3 fourth_condition_matrix_v4];
% reverb_condition_matrix = [fifth_condition_matrix_v1 fifth_condition_matrix_v2 fifth_condition_matrix_v3 fifth_condition_matrix_v4 ...
%     sixth_condition_matrix_v1 sixth_condition_matrix_v2 sixth_condition_matrix_v3 sixth_condition_matrix_v4 ...
%     seventh_condition_matrix_v1 seventh_condition_matrix_v2 seventh_condition_matrix_v3 seventh_condition_matrix_v4 ...
%     eigth_condition_matrix_v1 eigth_condition_matrix_v2 eigth_condition_matrix_v3 eigth_condition_matrix_v4];
% 




