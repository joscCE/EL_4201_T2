% =========================================================================
% SIMULACIÓN DE CORRIENTES
% =========================================================================
clear; clc; close all;

%Colocar el nombre los archivos a simular
opts = detectImportOptions('Iload_60V.CSV', 'NumHeaderLines', 25);
datos = readmatrix('Iload_60V.CSV', opts);

t = datos(:, 1);  
i = datos(:, 2);  


I_rms  = sqrt(mean(i.^2));
I_max  = max(i);
I_min  = min(i);
I_mean = mean(i);
I_pp   = I_max - I_min;

fprintf('--- MEDICIONES EXTRAÍDAS DIRECTAMENTE DEL ARCHIVO ---\n');
fprintf('I_rms  : %.2f mA\n', I_rms * 1000);
fprintf('I_max  : %.2f mA\n', I_max * 1000);
fprintf('I_media: %.2f mA\n', I_mean * 1000);
fprintf('I_pp   : %.2f mA\n', I_pp * 1000);

% 3. Gráfica de la señal
fig = figure('Name', 'Señal de Corriente', 'Color', 'w'); 


plot(t * 1000, i * 1000, 'Color', [0.8 0 0], 'LineWidth', 1.2);
grid on;

% Títulos y etiquetas en negro
title('Señal de Corriente', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Tiempo (ms)', 'Color', 'k', 'FontSize', 10);
ylabel('Corriente (mA)', 'Color', 'k', 'FontSize', 10);

% Ajustar ejes, rejilla y fondo de los ejes
ax = gca;
ax.Color = 'w';         
ax.XColor = 'k';         
ax.YColor = 'k';         
ax.GridColor = [0.8 0.8 0.8]; 
ax.GridAlpha = 0.6;      

xlim([0, 50]);
ylim([-500, 500]);