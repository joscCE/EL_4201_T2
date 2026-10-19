clearvars -except DS0001 DS0002 DS0003; clc; close all;
datos   = {DS0001, DS0002, DS0003};
nombres = {'Tensión de entrada','Tensión de salida rectificada','Tensión del diodo'};
ejes_y  = {'Tensión v_{in}(t) [V]', 'Tensión v_o(t) [V]', 'Tensión v_d(t) [V]'};
colores = {[0.3 0.5 1], [1 0 0], [0 0.9 0]};
vent_ms = [0.1 0.2 0.2];              % ventana de suavizado (ms) por señal
mostrar_cruda = [false false false];   

% --- DEFINICIÓN DE INTERVALOS DELTA T PARA CADA GRÁFICA ---
rangos_dt = [ ...
    0.0, 17.29;   % Delta t para la Gráfica 1
    4.34, 7.076;  % Delta t para la Gráfica 2
    7.122, 7.397  % Delta t para la Gráfica 3
    ];

v_max_forzado = [144, NaN, NaN]; % Usar 144 V en la segunda gráfica

% --- CONFIGURACIÓN DE BÚSQUEDA DE MÁXIMOS ---
busqueda_max_desde = [12, 0, 0]; 

for k = 1:3
    t  = (datos{k}(:,1) - datos{k}(1,1))*1e3;   % ms, empezando en 0
    v  = datos{k}(:,2);                         % V
    Ts = mean(diff(t));                         % periodo de muestreo en ms
    n  = max(1, round(vent_ms(k)/Ts));
    vs = movmean(v, n);                         % señal suavizada
    
    figure('Name', nombres{k}, 'Color', 'w', 'Position', [100+30*k 100+30*k 900 450]);
    ax = axes; hold on;
    
    if mostrar_cruda(k)
        plot(t, v, 'Color', 0.35*colores{k}, 'LineWidth', 0.5);
    end
    plot(t, vs, 'Color', colores{k}, 'LineWidth', 1.5);
    
    % --- 1. DETECTAR Y MARCAR EL MÁXIMO DE TENSIÓN ---
    % Filtrar el vector de tiempo según el punto de partida deseado
    indices_permitidos = t >= busqueda_max_desde(k);
    t_filtrado = t(indices_permitidos);
    vs_filtrado = vs(indices_permitidos);
    
    if isnan(v_max_forzado(k))
        [v_max, idx_relativo] = max(vs_filtrado);
        idx_originales = find(indices_permitidos);
        idx_max = idx_originales(idx_relativo);
        t_max = t(idx_max);
    else
        v_max = v_max_forzado(k);
        [~, idx_relativo] = min(abs(vs_filtrado - v_max));
        idx_originales = find(indices_permitidos);
        idx_max = idx_originales(idx_relativo);
        t_max = t(idx_max);
    end
    
    % Punto rojo en el máximo
    plot(t_max, v_max, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6);


    text(t_max, v_max + 22, sprintf('V_{máx} = %.2f V', v_max), ...
        'FontSize', 9, 'FontWeight', 'bold', 'Color', 'k', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'BackgroundColor', 'w');

    % --- 2. DIBUJAR EL DELTA T  ---
    t_inicio_delta = rangos_dt(k, 1);
    t_fin_delta    = rangos_dt(k, 2); 
    dt             = t_fin_delta - t_inicio_delta;
    
    % Líneas verticales de referencia
    xline(t_inicio_delta, '--k', 'Alpha', 0.5);
    xline(t_fin_delta, '--k', 'Alpha', 0.5);
    
    % Altura de la cota
    y_ref = v_max * 0.5; 
    
    
    % Texto con el valor calculado
    text((t_inicio_delta + t_fin_delta)/2, y_ref - 50, sprintf('\\Delta t = %.2f ms', dt), ...
        'FontSize', 9, 'Color', 'k', 'HorizontalAlignment', 'center', 'BackgroundColor', 'w');
    
    % --- CONFIGURACIÓN DE EJES ---
    ax.Color = 'w';
    ax.XColor = 'k';
    ax.YColor = 'k';
    ax.GridColor = 'k';
    ax.GridAlpha = 0.25;
    grid on;
    
    xlim([0 t(end)]);                           % tiempo desde 0
    if k > 1
        ylim([0 180]);                          % voltaje desde 0 V
    else
        ylim([-200 230]);                       % espacio extra para el texto
    end
    
    xlabel('Tiempo (ms)', 'Color', 'k');
    ylabel(ejes_y{k}, 'Color', 'k');
    title(nombres{k}, 'Color', 'k', 'Interpreter', 'none');
end