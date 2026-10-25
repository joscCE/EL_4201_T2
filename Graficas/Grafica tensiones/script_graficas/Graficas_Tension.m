clearvars; clc; close all;

% --- 1. ARCHIVOS CSV Y NOMBRES DE VENTANA / TÍTULOS ---
archivos        = {'VLL_30V.csv', 'Vout_30V.csv'}; 
nombres_pestana = {'Tensión de línea', 'Tensión de salida'};
ejes_y          = {'Tensión v_{in}(t) [V]', 'Tensión v_o(t) [V]'};
colores         = {[0 0.45 0.74], [0.85 0.32 0.1]}; % Azul y rojo profesionales

% --- 2. BUCLE DE LECTURA DIRECTA Y GRAFICADO LIMPIO ---
for k = 1:length(archivos)
    nombre_archivo = archivos{k};
    

    try
        opts = detectImportOptions(nombre_archivo, 'NumHeaderLines', 25);
        datos = readmatrix(nombre_archivo, opts);
    catch
        datos = readmatrix(nombre_archivo);
    end
    

    t = (datos(:,1) - datos(1,1)) * 1e3;   
    v = datos(:,2);                         
    
    % --- CÁLCULO DE PARÁMETROS DIRECTAMENTE DEL CSV ---
    v_rms   = sqrt(mean(v.^2));
    v_media = mean(v);
    v_max   = max(v);
    v_min   = min(v);
    v_pp    = v_max - v_min;
    
    % Imprimir resultados limpios en la Command Window
    fprintf('=================================================\n');
    fprintf('  ARCHIVO: %s\n', nombre_archivo);
    fprintf('=================================================\n');
    fprintf('  V_rms   : %.2f V\n', v_rms);
    fprintf('  V_media : %.2f V\n', v_media);
    fprintf('  V_pp    : %.2f V\n', v_pp);
    fprintf('  V_max   : %.2f V\n', v_max);
    fprintf('  V_min   : %.2f V\n\n', v_min);
    
    % --- FIGURA Y GRÁFICA LIMPIA  ---
    figure('Name', nombres_pestana{k}, 'NumberTitle', 'off', 'Color', 'w', 'Position', [100+40*k 100+40*k 850 420]);
    plot(t, v, 'Color', colores{k}, 'LineWidth', 1.2);
    grid on;
    
    % Etiquetas y títulos
    xlabel('Tiempo (ms)', 'Color', 'k', 'FontSize', 10);
    ylabel(ejes_y{k}, 'Color', 'k', 'FontSize', 10);
    title(nombres_pestana{k}, 'Color', 'k', 'FontSize', 11, 'FontWeight', 'bold');
    
    % Estilo visual de ejes
    ax = gca;
    ax.Color     = 'w';
    ax.XColor    = 'k';
    ax.YColor    = 'k';
    ax.GridColor = [0.8 0.8 0.8];
    ax.GridAlpha = 0.6;
    xlim([0 t(end)]);
    
  
    str_info = {sprintf('V_{pp} = %.2f V', v_pp), ...
                sprintf('V_{RMS} = %.2f V', v_rms), ...
                sprintf('V_{max} = %.2f V', v_max)};
            
    text(0.97, 0.93, str_info, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', ...
        'FontSize', 10, ...
        'FontWeight', 'bold', ...
        'Color', 'k', ...                  
        'BackgroundColor', [1 1 1], ...    
        'EdgeColor', colores{k}, ...
        'LineWidth', 1);
end