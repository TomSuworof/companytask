/* Beliefs */

ticks_passed(0).

product_price(100). // starting price
product_costs(50). // starting costs

revenue(1000). // starting income
costs(0). // starting expense

curr_tick_profit(0). // profit for the current tick
prev_tick_profit(0.01). // profit for the previous tick

product_price_change_percent(0.05). // price change percentage

ad_campaign_costs(100). // ad campaign cost
ad_campaign_efficiency(0.01). // efficiency of the advertising campaign, % raising the desire to buy the product

buy_willingness(1).

customer_registry([]). // registry for all customers

alive(true).

/* Goals */

!live.

/* Plans */

// When a customer agent registers itself
+register_customer(Agent) : customer_registry(List)
    <- 
    -customer_registry(List);
    +customer_registry([Agent | List]).

// When a customer agent deregisters itself
+deregister_customer(Agent) : customer_registry(List) & .member(Agent, List)
    <-
    -customer_registry(List);
    .delete(Agent, List, NewList);
    +customer_registry(NewList).



+update_willingness(Willingness) : buy_willingness(OldWillingness)
    <- 
    .print("Customer told me the new willingness is ", Willingness);
    +buy_willingness(Willingness).



+!live: alive(true)
    <- 
    !check_bankruptcy;
    !take_actions;
    !check_phases;
    !live.

+live: alive(false)
    <-
    .print("Company is bankrupt").

+!sell(Quantity) : 
                product_price(ProductPrice) &
                product_costs(ProductCosts) &
                curr_tick_profit(OldCurrTickProfit) &
                prev_tick_profit(OldPrevTickProfit) &
                revenue(OldRevenue) &
                costs(OldTotalCosts)
    <- 
    // Calculate revenue and costs for current tick
    CurrTickRevenue = ProductPrice * Quantity;
    CurrTickCosts = ProductCosts * Quantity;

    // Calculate profit for current tick
    CurrTickProfit = CurrTickRevenue - CurrTickCosts;
    
    // Update beliefs for current and previous tick profits
    +prev_tick_profit(OldCurrTickProfit);

    +curr_tick_profit(CurrTickProfit);
    
    // Update beliefs for total revenue and costs
    +revenue(OldRevenue + CurrTickRevenue);
    +costs(OldTotalCosts + CurrTickCosts).


// Do some action to increase profits
+!take_actions : product_price(Price)
    <-  
    !change_prices;
    !start_ad_campaign.

+!change_prices : 
        prev_tick_profit(PrevProfit) & 
        curr_tick_profit(CurrProfit) &
        product_price(Price) &
        product_price_change_percent(Percent)
    <-  
    if(PrevProfit < CurrProfit) {
        .print("rising price");
        NewPrice = Price * (1 + Percent);
        +product_price(NewPrice);

        // Tell customers that price was updated
        ?customer_registry(List);
        for (.member(Customer,List)) {
            .send(Customer, tell, update_price(NewPrice));
        };
    };
    if(PrevProfit > CurrProfit) {
        .print("reducing price");
        NewPrice = Price * (1 - Percent);
        +product_price(NewPrice);

        // Tell customers that price was updated
        ?customer_registry(List);
        for (.member(Customer,List)) {
            .send(Customer, tell, update_price(NewPrice));
        };
    };

    // Update previous profit
    +prev_tick_profit(CurrProfit).

+!start_ad_campaign : 
        revenue(Revenue) &
        costs(Costs) & 
        buy_willingness(Willingness) & 
        ad_campaign_costs(AdCosts) & 
        ad_campaign_efficiency(AdEfficiency)
    <-  
    if(Revenue > (Costs + AdCosts) & Willingness < 0.8) {
        .print("starting ad campaign");
        +buy_willingness(Willingness + AdEfficiency);

        ?customer_registry(List);
        for (.member(Customer,List)) {
            .send(Customer, tell, update_willingness(Willingness + AdEfficiency));
        };

        +costs(Costs + AdCosts);
    }.

+!check_bankruptcy : revenue(Revenue) & costs(Costs) & alive(Alive)
    <- 
    if(Revenue < Costs) {
        .print("company bankruptcy");
        -alive(Alive);
        +alive(false);
    }.

// Plan to check phases
+!check_phases
    <- 
    ?ticks_passed(Ticks);
    +ticks_passed(Ticks + 1);

    ?ticks_passed(TicksPassed);
    if (TicksPassed == 3650) {
        !apply_growth;
    }
    if (TicksPassed == 3650 + 3650) {
        !apply_maturity;
    }
    if (TicksPassed == 3650 + 3650 + 2 * 3650) {
        !apply_blossoming;
    }
    if (TicksPassed == 3650 + 3650 + 2 * 3650 + 3650) {
        !apply_recession;
    }.

// Growth
+!apply_growth
    <- 
    +product_price_change_percent(0.05);
    +ad_campaign_costs(300);
    +ad_campaign_efficiency(0.15);

    ?customer_registry(List);
    for (.member(Customer,List)) {
        .send(Customer, tell, update_willingness_decrease(0.3));
    }.

// Maturity
+!apply_maturity
    <- 
    +product_price_change_percent(0.03);
    +ad_campaign_costs(300);
    +ad_campaign_efficiency(0.08);

    ?customer_registry(List);
    for (.member(Customer,List)) {
        .send(Customer, tell, update_willingness_decrease(0.5));
    }.

// Blossoming
+!apply_blossoming
    <-
    +product_price_change_percent(0.06);
    +ad_campaign_costs(600);
    +ad_campaign_efficiency(0.13);

    ?customer_registry(List);
    for (.member(Customer,List)) {
        .send(Customer, tell, update_willingness_decrease(0.2));
    }.

// Recession
+!apply_recession
    <- 
    +product_price_change_percent(0.01);
    +ad_campaign_costs(200);
    +ad_campaign_efficiency(0.5);

    ?customer_registry(List);
    for (.member(Customer,List)) {
        .send(Customer, tell, update_willingness_decrease(0.7));
    }.