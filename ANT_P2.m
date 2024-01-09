%BEGIN
tic
clc
clear
%Data

dist_tmp = [0 2451 713 1018 1631 1374 2408 213 2571 875 1420 2145 1972; 
2451 0 1745 1524 831 1240 959 2596 403 1589 1374 357 579; 
713 1745 0 355 920 803 1737 851 1858 262 940 1453 1260; 
1018 1524 355 0 700 862 1395 1123 1584 466 1056 1280 987; 
1631 831 920 700 0 663 1021 1769 949 796 879 586 371; 
1374 1240 803 862 663 0 1681 1551 1765 547 225 887 999; 
2408 959 1737 1395 1021 1681 0 2493 678 1724 1891 1114 701; 
213 2596 851 1123 1769 1551 2493 0 2699 1038 1605 2300 2099; 
2571 403 1858 1584 949 1765 678 2699 0 1744 1645 653 600; 
875 1589 262 466 796 547 1724 1038 1744 0 679 1272 1162; 
1420 1374 940 1056 879 225 1891 1605 1645 679 0 1017 1200; 
2145 357 1453 1280 586 887 1114 2300 653 1272 1017 0 504; 
1972 579 1260 987 371 999 701 2099 600 1162 1200 504 0];

x = [3 2 12 7 10 11 9 2 14 15 16 1 0];
y = [1 4 2  4  6  9 10 1 1 12 12 4 1];
x = transpose(x);
y = transpose(y);
cities = [x y];
%Variables
nodes =  11;               
ants = nodes;               %Number of nodes
a = 1;                    %Control parameters
b = 5;                    
max_N = 15000;             %Number of iterations
ro = 0.7;                 %Pheromone dissipation

%measuring distances between all points on graph
for i=1:nodes
    for j=1:nodes
        distances(i,j) = dist_tmp(i,j);
    end
end

%initial pheromone matrix
D = max(max(distances));
for i=1:nodes
    for j=1:nodes
        tau(i,j) = 1/D;
    end
end

%randomizing initail position for all ants
for i=1:nodes
    positions(i,1) = randi(nodes);
end

%main loop - visiting nodes
for i = 1:max_N
    tour = positions;
    for j = 1:ants
        tau_temp = tau;
        for k = 1:(nodes - 1)
            r = unifrnd(0,1);
            current = tour(j, k);
            tau_temp(: , current) = 0; 
            P = (tau(current, :).^ a).* (tau_temp(current, :).^ b)./ sum((tau(current, :).^ a).* (tau_temp(current, :).^ b));
            temp = 0;
            for l = 1 : nodes 
                temp = temp + P(l);
                if r <= temp
                    tour(j, k + 1) = l;
                    break
                end
            end
        end
    end
    %all tours in this iteration:
    all_tours_n = [tour tour(:,1)];

    %calculating cost
    for j=1:ants
        temp_cost = 0;
        current_tour = tour(j, :);
        for t = 1:nodes-1
            temp_cost = temp_cost + distances(current_tour(1, t), current_tour(1, 1+t));
        end
        tour_cost(j, 1) = temp_cost;
    end

    %finding the lowest cost in this iteration
    [best_tour_cost, best_tour_index] = min(tour_cost);
    best_tours(i, :) = [tour(best_tour_index,:) 0];
    best_tours(i, nodes+1) = best_tour_cost;

    %creating new pheromone matrix
    for j = 1:ants
        for k = 1:nodes
            temp = (1 - ro) * tau(all_tours_n(j, k), all_tours_n(j, k + 1));
            tau(all_tours_n(j, k), all_tours_n(j, k + 1)) =  temp + 1 / tour_cost(j); 
        end
    end
end

%finding best tour
sorted_tours = sortrows(best_tours);
the_best_of = sorted_tours(1,1:nodes);

%printing the result
%fprintf("Best tour cost: %f\nnode order: %i, %i, %i, %i, %i, %i, %i, %i, %i, %i.\n", sorted_tours(1, 11), the_best_of(1:10));

fprintf("Route cost: %d \n", best_tour_cost);

%Plotting
hold on
scatter(cities(:,1), cities(:,2),15,"magenta","filled")
coords = cities(the_best_of(1,1:nodes), :);
plot(coords(:,1), coords(:,2), 'b')
plot([coords(end,1), coords(1,1)], [coords(end, 2), coords(1,2)], 'b');
%END
fprintf("Route order: \n");
disp(the_best_of);
time = toc;
fprintf("Time elapsed = %d \n", time);