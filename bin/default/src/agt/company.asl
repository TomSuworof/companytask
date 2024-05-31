/* Beliefs */

product_price(100). // starting price
product_costs(50). // starting costs

revenue(1000). // starting income
costs(0). // starting expense

curr_tick_profit(0). // profit for the current tick
prev_tick_profit(0.01). // profit for the previous tick

/* Plans */

+!sell(Quantity) : true <-
    +curr_tick_revenue(product_price * Quantity);
    +curr_tick_costs(product_costs * Quantity);

    +curr_tick_profit(curr_tick_revenue - curr_tick_costs);

    +revenue(revenue + curr_tick_revenue);
    +costs(costs + curr_tick_costs).
+!sell.