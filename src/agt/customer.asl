/* Beliefs */

product_price(100).

balance(10000).
buy_willingness(1).
buy_willingness_decrease_after_buying(0.1).

salary(200). // salary amount
work_countdown(30). // starting work countdown

alive(true).

/* Goals */

!register_self.
!live.

/* Plans */

+!register_self
    <- 
    .my_name(Name);
    .send(company, tell, register_customer(Name)).

+!deregister_self
    <- 
    .my_name(Name);
    .send(company, tell, deregister_customer(Name)).



+update_price(Price)
    <- 
    .print("Company told me the new price is ", Price);
    +product_price(Price).

+update_willingness(Willingness)
    <- 
    .print("Company told me the new willingness is ", Willingness);
    +buy_willingness(Willingness).

+update_willingness_decrease(WillingnessDecrease)
    <-
    .print("Company told me the new willingness decrease is ", WillingnessDecrease);
    +buy_willingness_decrease_after_buying(WillingnessDecrease).


+!live: alive(true)
    <- 
    !work;
    !buy;
    !check_death;

    ?buy_willingness(Willingness);
    .send(company, tell, update_willingness(Willingness));

    !live.

+!live: alive(false)
    <-
    !deregister_self.

// Customer can work and increase the balance sheet
+!work : balance(Balance) & salary(Salary) & work_countdown(Countdown)
    <- 
    if(Countdown == 0) {
        +balance(Balance + Salary);
        +work_countdown(30);
    } else {
        +work_countdown(Countdown - 1);
    }.

// If the customer has gone into deficit, he is broke
// If the customer no longer wants to buy, he leaves the market for that product
+!check_death : balance(Balance) & buy_willingness(Willingness) & alive(Alive)
    <- 
    if(Balance < 0) {
        .print("customer died due to negative balance");
        +alive(false);
    }
    if(Willingness > 1) {
        +buy_willingness(1);
    }
    if(Willingness <= 0) {
        .print("customer does not want to buy anymore");
        +alive(false);
    }.

// A customer buys a product if
// 1) there is a desire to buy
// 2) there is money on the account
+!buy : product_price(Price) & balance(Balance) & buy_willingness(Willingness) & buy_willingness_decrease_after_buying(Decrease)
    <- 
    // Calculate possible quantity and total price
    PossibleQ = 200 - Price;
    TotalPrice = PossibleQ * Price;

    .random(RandomNumber);

    if(PossibleQ > 0 & Balance > TotalPrice & RandomNumber < Willingness) {
        .send(company, tell, sell(PossibleQ));
        +balance(Balance - TotalPrice);
        .print("Willingness: ", Willingness, ", Bought ", PossibleQ, ". New balance: ", (Balance - TotalPrice));
        
        if (Willingness - Decrease > 0) {
            +buy_willingness(Willingness - Decrease);
        } else {
            +buy_willingness(0);
        };
    }.
