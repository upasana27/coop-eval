(define (domain overcooked-ai)
    (:requirements :strips :typing)

    (:types player object onion-dispenser dish-dispenser pot counter serving-counter x_coor y_coor)

    (:predicates
        ;; Player and objects' positions
        (at ?p - player ?x - x_coor ?y y_coor)
        (at-object ?o - object ?x - x_coor ?y y_coor)
        (holding ?p - player ?o - object)  ;; Player is holding an object
        (adj_counter ?p - player ?c)

        
        ;; Pot states
        (empty-pot ?pot - pot)            ;; Pot is empty
        (pot-with-onion ?pot - pot)       ;; Pot has onions
        (pot-cooking ?pot - pot)          ;; Soup is cooking
        (pot-ready ?pot - pot)            ;; Soup is ready
        (pot-has-onions ?pot - pot ?n - number)

        ;; Dispenser and counters
        (onion-in-dispenser ?d - onion-dispenser)    ;; Onion available at the dispenser
        (dish-in-dispenser ?d - dish-dispenser)     ;; Dish available at the dish dispenser
        (onion-on-counter ?c - counter)    ;; Onion available at the counter
        (dish-on-counter ?c - counter)     ;; Dish available at the counter
        (soup-on-counter ?c - counter)     ;; Soup available at the counter
        (empty-counter ?c - counter)           ;; Counter is empty

        ;; Points for successful delivery
        (soup-delivered)   ;; Successfully delivered soup
    )
    
    ;; Actions for player movement, one step at a time in each direction
    (:action move-up
        :parameters (?p - player ?l_x - x_coor ?l_y - y_coor)
        :precondition (and (at ?p ?l_x ?l_y) (< ?l_y max_y))  ;; Check if the agent is not at the upper boundary
        :effect (and (not (at ?p ?l_x ?l_y)) (at ?p ?l_x (+ ?l_y 1)))
    )

    (:action move-down
        :parameters (?p - player ?l_x - x_coor ?l_y - y_coor)
        :precondition (and (at ?p ?l_x ?l_y) (> ?l_y min_y))  ;; Check if the agent is not at the lower boundary
        :effect (and (not (at ?p ?l_x ?l_y)) (at ?p ?l_x (- ?l_y 1)))
    )

    (:action move-left
        :parameters (?p - player ?l_x - x_coor ?l_y - y_coor)
        :precondition (and (at ?p ?l_x ?l_y) (> ?l_x min_x))  ;; Check if the agent is not at the left boundary
        :effect (and (not (at ?p ?l_x ?l_y)) (at ?p (- ?l_x 1) ?l_y))
    )

    (:action move-right
        :parameters (?p - player ?l_x - x_coor ?l_y - y_coor)
        :precondition (and (at ?p ?l_x ?l_y) (< ?l_x max_x))  ;; Check if the agent is not at the right boundary
        :effect (and (not (at ?p ?l_x ?l_y)) (at ?p (+ ?l_x 1) ?l_y))
    )


    ;; Actions for interacting with onion
    (:action pick-onion-from-disp
        :parameters (?p - player ?d - dispenser ?l_x - x_coor ?l_y - y_coor)
        :precondition (and (at ?p ?l_x ?l_y) (not (holding ?p ?o - object)))
        :effect (and (holding ?p onion ?))
    )
    ;; Action to pick and place an onion from a counter (if adjacent and counter has onion)
    (:action place-onion-on-counter
        :parameters (?p - player ?c - counter ?p_x - x_coor ?p_y - y_coor ?c_x - x_coor ?c_y - y_coor)
        :precondition (and
            (at ?p ?p_x ?p_y)
            (holding ?p onion)
            (empty-counter ?c)
            ;; Check if the player is adjacent to the counter
            (or (and (= ?p_x ?c_x) (= ?p_y (+ ?c_y 1)))
                (and (= ?p_x ?c_x) (= ?p_y (- ?c_y 1)))
                (and (= ?p_y ?c_y) (= ?p_x (+ ?c_x 1)))
                (and (= ?p_y ?c_y) (= ?p_x (- ?c_x 1)))))
        :effect (and
            (not (holding ?p onion))
            (not (empty-counter ?c))
            (onion-on-counter ?c))
    )
    (:action pick-onion-from-counter
        :parameters (?p - player ?c - counter ?p_x - x_coor ?p_y - y_coor ?c_x - x_coor ?c_y - y_coor)
        :precondition (and
            (at ?p ?p_x ?p_y)
            (onion-on-counter ?c)
            (not (holding ?p ?o - object))
            ;; Check if the player is adjacent to the counter
            (or (and (= ?p_x ?c_x) (= ?p_y (+ ?c_y 1)))
                (and (= ?p_x ?c_x) (= ?p_y (- ?c_y 1)))
                (and (= ?p_y ?c_y) (= ?p_x (+ ?c_x 1)))
                (and (= ?p_y ?c_y) (= ?p_x (- ?c_x 1)))))
        :effect (and
            (holding ?p onion)
            (not (onion-on-counter ?c))
            (empty-counter ?c))
    )
    
    ;; Action to pick and place an dish
    (:action pick-dish-from-disp
        :parameters (?p - player ?d - dispenser ?l_x - x_coor ?l_y - y_coor)
        :precondition (and (at ?p ?l_x ?l_y) (not (holding ?p ?o - object)))
        :effect (and (holding ?p dish))
    )
    (:action place-dish-on-counter
        :parameters (?p - player ?d - dish ?c - counter ?p_x - x_coor ?p_y - y_coor ?c_x - x_coor ?c_y - y_coor)
        :precondition (and
            (at ?p ?p_x ?p_y)
            (holding ?p ?d)
            (empty-counter ?c)
            ;; Check if the player is adjacent to the counter
            (or (and (= ?p_x ?c_x) (= ?p_y (+ ?c_y 1)))
                (and (= ?p_x ?c_x) (= ?p_y (- ?c_y 1)))
                (and (= ?p_y ?c_y) (= ?p_x (+ ?c_x 1)))
                (and (= ?p_y ?c_y) (= ?p_x (- ?c_x 1)))))
        :effect (and
            (not (holding ?p ?d))
            (not (empty-counter ?c))
            (dish-on-counter ?c))
    )
    (:action pick-dish-from-counter
        :parameters (?p - player ?d - dish ?c - counter ?p_x - x_coor ?p_y - y_coor ?c_x - x_coor ?c_y - y_coor)
        :precondition (and
            (at ?p ?p_x ?p_y)
            (dish-on-counter ?c)
            (not (holding ?p ?d)) ;; flag
            ;; Check if the player is adjacent to the counter
            (or (and (= ?p_x ?c_x) (= ?p_y (+ ?c_y 1)))
                (and (= ?p_x ?c_x) (= ?p_y (- ?c_y 1)))
                (and (= ?p_y ?c_y) (= ?p_x (+ ?c_x 1)))
                (and (= ?p_y ?c_y) (= ?p_x (- ?c_x 1)))))
        :effect (and
            (holding ?p ?d)
            (not (dish-on-counter ?c))
            (empty-counter ?c))
    )

    ;; Action to pick and place a soup on counters
    
    (:action place-soup-on-counter
        :parameters (?p - player ?s - soup ?c - counter ?p_x - x_coor ?p_y - y_coor ?c_x - x_coor ?c_y - y_coor)
        :precondition (and
            (at ?p ?p_x ?p_y)
            (holding ?p ?s) 
            (empty-counter ?c)
            ;; Check if the player is adjacent to the counter
            (or (and (= ?p_x ?c_x) (= ?p_y (+ ?c_y 1)))
                (and (= ?p_x ?c_x) (= ?p_y (- ?c_y 1)))
                (and (= ?p_y ?c_y) (= ?p_x (+ ?c_x 1)))
                (and (= ?p_y ?c_y) (= ?p_x (- ?c_x 1)))))
        :effect (and
            (not (holding ?p ?s))
            (not (empty-counter ?c))
            (soup-on-counter ?c))
    )
    (:action pick-soup-from-counter
        :parameters (?p - player ?s - soup ?c - counter ?p_x - x_coor ?p_y - y_coor ?c_x - x_coor ?c_y - y_coor)
        :precondition (and
            (at ?p ?p_x ?p_y)
            (dish-on-counter ?c)
            (not (holding ?p ?d)) ;; flag
            ;; Check if the player is adjacent to the counter
            (or (and (= ?p_x ?c_x) (= ?p_y (+ ?c_y 1)))
                (and (= ?p_x ?c_x) (= ?p_y (- ?c_y 1)))
                (and (= ?p_y ?c_y) (= ?p_x (+ ?c_x 1)))
                (and (= ?p_y ?c_y) (= ?p_x (- ?c_x 1)))))
        :effect (and
            (holding ?p ?s)
            (not (dish-on-counter ?c))
            (empty-counter ?c))
    )

    ;; Actions related to pot
    ;; Action to place onion in a pot (if pot has less than 3 onions)
    (:action place-onion-in-pot
        :parameters (?p - player ?o - onion ?pot - pot ?l_x - x_coor ?l_y - y_coor ?n - number)
        :precondition (and
            (at ?p ?l_x ?l_y)
            (holding ?p ?o)
            (< ?n 3)                       ;; Pot must have less than 3 onions
            (pot-has-onions ?pot ?n))       ;; Pot has `n` onions
        :effect (and
            (not (holding ?p ?o))
            (pot-has-onions ?pot (+ ?n 1))  ;; Increment the onion count in the pot
            ;; If 3 onions are now in the pot, it's ready to cook
            (when (= (+ ?n 1) 3) (pot-ready-to-cook ?pot)))) ;; does the + ?n 1 not update when it happens?
    )

    ;; needs rethinking, do we need actions for start and stop cooking
    (:action start-cooking
        :parameters (?p - player ?pot - pot ?l - location)
        :precondition (and (at ?p ?l) (pot-with-onion ?pot))
        :effect (and (not (pot-with-onion ?pot)) (pot-cooking ?pot))
    )

    (:action finish-cooking
        :parameters (?pot - pot)
        :precondition (and (pot-cooking ?pot))
        :effect (and (not (pot-cooking ?pot)) (pot-ready ?pot))
    )


    (:action serve-soup
        :parameters (?p - player ?pot - pot ?dish-counter - dish-counter ?serving-counter - serving-counter ?l - location)
        :precondition (and (at ?p ?l) (holding ?p dish) (pot-ready ?pot))
        :effect (and (not (holding ?p dish)) (soup-delivered))
    )

    ;; Idle action
    (:action idle
        :parameters (?p - player ?l - location)
        :precondition (at ?p ?l)
        :effect (at ?p ?l)
    )

