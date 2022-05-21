function plot_G(G)
figure; 
hp = plot(G, 'layout', 'layered');
set(hp, 'YData', G.Nodes.FRAME);
set(gca, 'YDir', 'reverse', 'XColor', 'none');
ylabel('Time point');
end