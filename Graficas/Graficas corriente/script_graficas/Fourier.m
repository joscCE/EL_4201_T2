% =========================================================================
% ANÁLISIS ESPECTRAL Y CÁLCULO DE THD - RECTIFICADOR TRIFÁSICO
% =========================================================================
clear; clc; close all;

% Nombres de los archivos CSV
file_30V = 'IL_30V.CSV';
file_60V = 'IL_60V.CSV';


analizar_espectro_blanco(file_30V, 'Punto de Operación: 30 Vrms');
analizar_espectro_blanco(file_60V, 'Punto de Operación: 60 Vrms');


function analizar_espectro_blanco(filename, titulo)
    if ~isfile(filename)
        error('El archivo %s no se encuentra en el directorio actual.', filename);
    end
    
    % 1. LECTURA DE DATOS 
    opts = detectImportOptions(filename);
    datos = readmatrix(filename, opts);
    datos = datos(~any(isnan(datos), 2), :);
    
    t = double(datos(:, 1));    % Tiempo [s]
    i_a = double(datos(:, 2));  % Corriente [A]
    
   
    i_ac = i_a - mean(i_a);
    
    % 2. PARÁMETROS DEL PROCESAMIENTO ESPECTRAL
    N = length(t);                          % Muestras N
    dt = mean(diff(t));                     % Paso de muestreo
    fs = 1 / dt;                            % Frecuencia de muestreo
    delta_T = t(end) - t(1) + dt;           % Ventana temporal
    delta_f = 1 / delta_T;                  % Resolución en frecuencia
    
    % 3. CÁLCULO DE LA FFT Y CONVERSIÓN A RMS
    Y = fft(i_ac);
    P2 = abs(Y / N);
    P1 = P2(1:floor(N/2)+1);
    P1(2:end-1) = 2 * P1(2:end-1);
    
    % Amplitud en Amperios RMS (A_rms = A_pico / sqrt(2))
    I_rms_spectro = P1 / sqrt(2);
    freqs = double(fs * (0:(N/2)) / N); % Vector explícito de frecuencia en Hz
    
    % 4. EXTRACCIÓN DE ARMÓNICOS CARACTERÍSTICOS
    f_fund = 60;
    get_bin_rms = @(h) I_rms_spectro(round(h * f_fund / delta_f) + 1);
    
    I1  = get_bin_rms(1);   % Fundamental (60 Hz)
    I5  = get_bin_rms(5);   % 5to Armónico (300 Hz)
    I7  = get_bin_rms(7);   % 7mo Armónico (420 Hz)
    I11 = get_bin_rms(11);  % 11vo Armónico (660 Hz)
    I13 = get_bin_rms(13);  % 13vo Armónico (780 Hz)
    
    % Cálculo del THD
    THD_dom = (sqrt(I5^2 + I7^2 + I11^2 + I13^2) / I1) * 100;
    I_rms_total = rms(i_ac);
    THD_total = sqrt(max(0, (I_rms_total / I1)^2 - 1)) * 100;
    
    % Imprimir en consola
    fprintf('======================================================\n');
    fprintf('  ANÁLISIS ESPECTRAL: %s\n', upper(titulo));
    fprintf('======================================================\n');
    fprintf('Fundamental I1 (60 Hz)   : %.4f A RMS\n', I1);
    fprintf('5to Armónico I5 (300 Hz)  : %.4f A RMS (%.2f%%)\n', I5, (I5/I1)*100);
    fprintf('7mo Armónico I7 (420 Hz)  : %.4f A RMS (%.2f%%)\n', I7, (I7/I1)*100);
    fprintf('11vo Armónico I11 (660 Hz): %.4f A RMS (%.2f%%)\n', I11, (I11/I1)*100);
    fprintf('13vo Armónico I13 (780 Hz): %.4f A RMS (%.2f%%)\n', I13, (I13/I1)*100);
    fprintf('------------------------------------------------------\n');
    fprintf('THD_I Dominantes (h=5,7,11,13) : %.2f %%\n', THD_dom);
    fprintf('THD_I Espectro Total RMS       : %.2f %%\n\n', THD_total);
    
    
    fig_width = 850;
    fig_height = 420;
    screen_size = get(0, 'ScreenSize'); % [left, bottom, width, height]
    pos_x = (screen_size(3) - fig_width) / 2;
    pos_y = (screen_size(4) - fig_height) / 2;
    

    fig = figure('Name', titulo, 'Color', [1 1 1], ...
                 'Position', [pos_x, pos_y, fig_width, fig_height]);
             
    ax = axes('Parent', fig);
    mask = (freqs <= 1000); % Filtrar hasta 1000 Hz
    
    s = stem(freqs(mask), I_rms_spectro(mask), 'filled');
    s.Color = [0.85 0.325 0.098];          % Color del tallo
    s.MarkerFaceColor = [0.85 0.325 0.098]; % Color del punto
    s.LineWidth = 1.3;
    s.MarkerSize = 4;
    
    title(['Espectro de Frecuencias (FFT) - ', titulo], 'Color', 'k', 'FontSize', 11, 'FontWeight', 'bold');
    xlabel('Frecuencia [Hz]', 'Color', 'k', 'FontSize', 10);
    ylabel('Corriente RMS [A]', 'Color', 'k', 'FontSize', 10);
    grid on;
    
    
    set(ax, 'Color', [1 1 1], 'XColor', 'k', 'YColor', 'k', ...
            'GridColor', [0.8 0.8 0.8], 'GridAlpha', 0.6);
    ax.XAxis.Exponent = 0; 
    xlim([0 1000]);
    xticks(0:100:1000);     
end