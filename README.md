# 1. Personal Meal Planner

When you go to a restaurant, you have to go through many meals in the menu and it is hard to choose which one to pick, especially if you have a special dietary requirement. For this reason, you will design an interface for the user so that given a customer name, the program will list all the meals that the customer would be willing to eat.


# 2. Knowledge Base

In your knowledge base (plannerData.pl), you have a list of predicates, foodGroup, meal and customer. They are defined as follows:

#### 2.1. foodGroup(+GroupName, +FoodList).

foodGroup defines a food group, and for each food group, list of foods belonging to that category are listed, e.g.

    foodGroup(vegetable, [cauliflower, spinach, potato, zucchini, onion, lettuce]).

Keep in mind that egg is categorized as meat, which could be confusing, but it's categorized under the meat and protein group in the food pyramid.

#### 2.2. cannotEatGroup(+EatingType, +CannotEatFoodGroupList, +CalorieLimit).

cannotEatGroup defines the properties of the EatingType (normal, vegetarian, vegan, diabetic, diet, etc.), e.g.

    cannotEatGroup(vegan,[meat, dairy], 0).   
    cannotEatGroup(diet, [], 220).

If CalorieLimit is different than 0, then the group cannot eat meals with Calorie > CalorieLimit, else if CalorieLimit is 0, there is no limit to Calorie intake. CannotEatFoodGroupList consists of the list of foodGroups that the EatingType cannot eat.

#### 2.3. meal(+MealName, +IngredientList, +Calorie, +PrepTime, +Price).

meal defines a meal and it consists of meal name, ingredients list, calorie of the meal in kcal, preparation of the meal in the restaurant (in minutes), and price of the meal in TL, e.g.

    meal(chickenWrap,[chicken,lettuce,corn,tomato,cucumber,yogurt,flour,salt],180,20,15).

#### 2.4. customer(+CustomerName, +AllergyList, +EatingType, +Dislikes, +Likes, +TimeInHand, +MoneyInHand).

customer holds the customer name and preferences, namely their list of allergies (as foodGroup), eating type (normal, vegetarian, vegan, diabetic, diet), dislikes (as FoodList (NOT foodGroup) ), likes (as FoodList), the time they have available to wait for the meal to come (in minutes),and the money they have in hand to pay (in TL).

    customer(nick, [cheese], [diet], [fish, tomato], [chicken, walnut], 15, 20).


# 3. Planner

In the planner section, you are required to write some predicates for this project. InitialList is used to hold the current state of the meal list (starts from total list and might decrease in size as preferences are satised).

#### 3.1. findAllergyMeals(+AllergyList, ?InitialList, -MealList)
This predicate will be used to nd the meals that contains a foodGroup that the customer is allergic to. AllergyList can contain more than one allergy, e.g. [fruit], [nut, cheese], etc.

**Example:**

    findAllergyMeals([nut],[muesli,eggSandwich,saladWithNuts,tomatoSoup,bananaCake],MealList).
    MealList = [muesli, saladWithNuts].

#### 3.2. findLikeMeals(+Likes, ?InitialList, -MealList)
This predicate is to nd the meals that the customer likes/dislikes. Likes is a list of foods, e.g. [tomato, banana, egg, ...].

**Example:**

    findLikeMeals([tomato,banana,egg],[muesli,eggSandwich,saladWithNuts,tomatoSoup,bananaCake],MealList).   
    MealList = [eggSandwich,saladWithNuts,tomatoSoup,bananaCake].

#### 3.3. findNotEatingTypeMeals(+EatingTypeList, ?InitialList, -MealList)
This predicate nds the meals that the customer wouldn't eat. The properties for EatingType is defined by

    cannotEatGroup(EatingType, CannotEatFoodGroupList, CalorieLimit).

EatingTypeList can be a combination of EatingTypes, e.g. [normal], [vegan, diabetic] or [normal, diet, diabetic], etc.

**Example:**

    findNotEatingTypeMeals([diet],[muesli,eggSandwich,saladWithNuts,tomatoSoup,bananaCake,karniyarik,friedZucchini],MealList).    
    MealList = [friedZucchini, karniyarik].

#### 3.4. findMealsForTime(+TimeInHand, ?InitialList, -MealList)
This predicate nds the meals that the customer has time to wait to eat, that is, the customer must have more or same amount of time in hand than the preparation time of the meal.

**Example:**

    findMealsForTime(15,[saladWithNuts,tomatoSoup,ayran,karniyarik,friedZucchini],MealList).    
    MealList = [saladWithNuts, tomatoSoup, ayran].

#### 3.5. findMealsForMoney(+MoneyInHand, ?InitialList, -MealList)
This predicate nds the meals that the customer has the money to pay for, that is, the customer must have more or same amount of money in hand than the price of the meal.

**Example:**

    findMealsForMoney(15,[saladWithNuts,tomatoSoup,ayran,karniyarik,friedZucchini],MealList).   
    MealList = [tomatoSoup,ayran,karniyarik,friedZucchini].

#### 3.6. orderLikedList(+LikeMeals, ?InitialList, -MealList)
This predicate puts the meals that the customer likes to the beginning of the list (LikeMeals list comes from `findLikeMeals(+Likes, ?InitialList, -MealList).` Read the NOTE section below for more explanation on ordering.

**Example:**

    orderLikedList([karniyarik,tomatoSoup,saladWithNuts],[saladWithNuts,tomatoSoup,ayran,karniyarik,friedZucchini],MealList).   
    MealList = [karniyarik, tomatoSoup, saladWithNuts, ayran, friedZucchini].

#### 3.7. listPersonalList(+CustomerName, -PersonalList)
This is the main predicate with which you will extract the personal meal list for a customer. PersonalList found from all available meals in the knowledge base.

NOTE: The PersonalList must be in the same order as in the knowledge base, except if the customer has specific Likes. If the customer has Likes, than their liked meals should appear in the prioritized order but as in the knowledge base list. E.g.

    if    
    Likes = [chocolate, banana].    
    Then    
    MealList = [chocolateBrownie, bananaOatmeal, bananaCake, ...]

... stands for rest of the list in the order as in the knowledge base but not including the first three meals. chocolateBrownie came first, because it has more priority to banana in the Likes list (i.e. it comes first), than bananaOatmeal is and bananaCake is given as in the order in the knowledge base list.
