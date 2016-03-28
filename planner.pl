:-include('plannerData.pl').

% All the predicates was written step by step.
% One can easily understand the predicates by following the numbers.
% e.g. findAllergyMeals -> findAllergyMeals_2 -> findAllergyMeals_3

%%%%%%%% 111111111111111 findAllergyMeals(AllergyList, InitialList, MealList) 11111111111111111111111111 %%%%%%%%

% This predicate will be used to find the meals that contains a foodGroup that the customer is allergic to.

findAllergyMeals(AllergyList, InitialList, MealList) :-
	findall(X, ( member(X, InitialList), findAllergyMeals_2(AllergyList, X) ), MealList).

% splits the Allergylist. Sends the FoodList of each element of AllergyList to searchAllergen/2 predicate.
% thanks to OR(;) operator if it finds an allergen which satisfies the conditions, returns the Meal immediately.
findAllergyMeals_2([H | AllergyTail], Meal) :- 
	foodGroup(H, FoodList),
	( findAllergyMeals_3(FoodList, Meal) ; findAllergyMeals_2(AllergyTail, Meal) ).

% Searchs for allergens in Meal's ingredients.
findAllergyMeals_3([H | FoodTail], Meal) :-
	meal(Meal, Ingredient, _, _, _),
	( member(H, Ingredient) ; findAllergyMeals_3(FoodTail, Meal) ).



%%%%%%%% 2222222222222222222 findLikeMeals(Likes, InitialList, MealList) 2222222222222222222222222222 %%%%%%%%

% This predicate is to find the meals that the customer likes/dislikes.

findLikeMeals([], _, []).

% Splits Likes list and finds all solutions for each member of Likes in order.
% To not ruin the order, we benefit from backtracking. 
% First holds the solutions from the Head of the list and Second holds the solution from the Tail.
% To avoid duplicates in Second from First, we create Third. Then append First and Third to create MealList.
findLikeMeals([H | LikesTail], InitialList, MealList) :-
	findall(X, ( member(X, InitialList), findLikeMeals_2(H, X) ), First),
	findLikeMeals(LikesTail, InitialList, Second),
	findall(X, ( member(X, Second), \+ member(X, First) ), Third),
	append(First, Third, MealList).

% Searches the Food in the ingredients of the Meal.
findLikeMeals_2(Food, Meal) :-
	meal(Meal, Ingredient, _, _, _),
	member(Food, Ingredient).



%%%%%%%% 3333333333333333 findNotEatingTypeMeals(EatingTypeList, InitialList, MealList) 3333333333333333333 %%%%%%%%

% This predicate finds the meals that the customer wouldn't eat.

% findNotEatingTypeMeals -> findNotEatingTypeMeals_2 -> ( findNotEatingTypeMeals_3 ; (findNotEatingTypeMeals_4 -> findNotEatingTypeMeals_5) )

findNotEatingTypeMeals(EatingTypeList, InitialList, MealList) :-
	findall(X, ( member(X, InitialList), findNotEatingTypeMeals_2(EatingTypeList, X) ), MealList).

% Splits EatingTypeList and cmopares the CalorieLimit or look for the CannotEatFoodGroupList of the EatingType with Meal.
findNotEatingTypeMeals_2([H | EatingTypeTail], Meal) :- 
	cannotEatGroup(H, FoodGroupList, CalorieLimit),
	( findNotEatingTypeMeals_3(CalorieLimit, Meal) ; findNotEatingTypeMeals_4(FoodGroupList, Meal) );
	findNotEatingTypeMeals_2(EatingTypeTail, Meal).

% Compares the calorie and CalorieLimit.
findNotEatingTypeMeals_3(CalorieLimit, Meal) :-
	meal(Meal, _, Calorie, _, _),
	(CalorieLimit > 0), (Calorie > CalorieLimit).

% Same procedure in findAllergyMeals_2/3 and findAllergyMeals_3/3
findNotEatingTypeMeals_4([H | FoodGroupTail], Meal) :- 
	foodGroup(H, FoodList),
	( findNotEatingTypeMeals_5(FoodList, Meal) ; findNotEatingTypeMeals_4(FoodGroupTail, Meal) ).

findNotEatingTypeMeals_5([H | FoodTail], Meal) :-
	meal(Meal, Ingredient, _, _, _),
	( member(H, Ingredient) ; findNotEatingTypeMeals_5(FoodTail, Meal) ).



%%%%%%%% 444444444444444444 findMealsForTime(TimeInHand, InitialList, MealList) 4444444444444444444444 %%%%%%%%

% This predicate finds the meals that the customer has time to wait to eat, that is, the customer must
% have more or same amount of time in hand than the preparation time of the meal.

findMealsForTime(TimeInHand, InitialList, MealList) :-
	findall(X, ( member(X, InitialList), findMealsForTime_2(TimeInHand, X) ), MealList).

% Compares the preperation time and TimeInHand.
findMealsForTime_2(TimeInHand, Meal) :-
	meal(Meal, _, _, Time, _),
	TimeInHand >= Time.



%%%%%%%% 5555555555555555555 findMealsForMoney(MoneyInHand, InitialList, MealList) 5555555555555555555555 %%%%%%%%

% This predicate finds the meals that the customer has the money to pay for.

findMealsForMoney(MoneyInHand, InitialList, MealList) :-
	findall(X, ( member(X, InitialList), findMealsForMoney_2(MoneyInHand, X) ), MealList).

% Compares the price and MoneyInHand.
findMealsForMoney_2(MoneyInHand, Meal) :-
	meal(Meal, _, _, _, Money),
	MoneyInHand >= Money.



%%%%%%%% 6666666666666666666666 orderLikedList(LikeMeals, InitialList, MealList)  66666666666666666666666 %%%%%%%%

% This predicate puts the meals that the customer likes to the beginning of the list.

% First, put LikeMeals into LikedOnes and put other meals into LessLiked.
% Then concatenate LikedOnes and LessLiked.
orderLikedList(LikeMeals, InitialList, MealList) :-
	findall(X, ( member(X,LikeMeals), member(X,InitialList) ), LikedOnes),
	findall(X, ( member(X,InitialList), \+ member(X,LikeMeals) ), LessLiked),
	append(LikedOnes, LessLiked, MealList).



%%%%%%%% 77777777777777777777777 listPersonalList(CustomerName, PersonalList)  7777777777777777777777777777 %%%%%%%%

% A straightforward predicate which uses above predicates.
% Creates lists according to the customer's demands and creates a MealList.
% Then orders the list with respect to LikeMeals.
listPersonalList(CustomerName, PersonalList) :-
	findall(X, meal(X, _, _, _, _), InitialList),
	customer(CustomerName, AllergyList, _, _, _, _, _),	findAllergyMeals(AllergyList, InitialList, AllergyMeals),
	customer(CustomerName, _, EatingType, _, _, _, _),  findNotEatingTypeMeals(EatingType, InitialList, NotMyType),
	customer(CustomerName, _, _, Dislikes, _, _, _), 	findLikeMeals(Dislikes, InitialList, DislikeMeals),
	customer(CustomerName, _, _, _, Likes, _, _), 		findLikeMeals(Likes, InitialList, LikeMeals),
	customer(CustomerName, _, _, _, _, TimeInHand, _), 	findMealsForTime(TimeInHand, InitialList, TimeyMeal),
	customer(CustomerName, _, _, _, _, _, MoneyInHand), findMealsForMoney(MoneyInHand, InitialList, MoneyMeal),
	findall(X, ( member(X, InitialList), member(X, TimeyMeal), member(X, MoneyMeal), \+ member(X,AllergyMeals), \+ member(X,NotMyType), \+ member(X,DislikeMeals) ),  MealList),
	orderLikedList(LikeMeals, MealList, PersonalList).
