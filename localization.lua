local addonName, A = ...

local L = setmetatable({}, {
	__index = function(self, key)
		return tostring(key)
	end,
})
A.L = L

L["Enchant a scroll (%d)"] = "Enchant a scroll (%d)"
L["Enchant a scroll (0)"] = "Enchant a scroll (0)"
L["Recipe link not found for %s"] = "Recipe link not found for %s"
L["The recipe to make the reagent seems to be hidden, it is not makable. Try to remove the filters on the recipes."] = "The recipe to make the reagent seems to be hidden, it is not makable. Try to remove the filters on the recipes."
L["The recipe to make this reagent is in another tradeskill. Currently ReagentMaker can not manage such a case, sorry."] = "The recipe to make this reagent is in another tradeskill. Currently ReagentMaker can not manage such a case, sorry."
L["You do not have enough [%s] to craft [%s]"] = "You do not have enough [%s] to craft [%s]"
L["You do not have enough reagents to craft [%s]"] = "You do not have enough reagents to craft [%s]"


local locale = GetLocale()
if locale == 'frFR' then

L["Enchant a scroll (%d)"] = "Enchanter un vélin (%d)"
L["Enchant a scroll (0)"] = "Enchanter un vélin (0)"
L["Recipe link not found for %s"] = "Le lien de la recette %s n'a pas été trouvé"
L["The recipe to make the reagent seems to be hidden, it is not makable. Try to remove the filters on the recipes."] = "La recette qui permet de créer cet objet semble cachée, il n'est donc pas fabricable. Essayez d'enlever les filtres sur les recettes."
L["The recipe to make this reagent is in another tradeskill. Currently ReagentMaker can not manage such a case, sorry."] = "La recette permettant de créer cette compo vient d'un autre métier. Actuellement ReagentMaker ne peut pas gérer ce genre de situations, désolé."
L["You do not have enough [%s] to craft [%s]"] = "Vous n'avez pas assez de [%s] pour fabriquer [%s]"
L["You do not have enough reagents to craft [%s]"] = "Vous n'avez pas assez de compos pour fabriquer [%s]"

elseif locale == 'deDE' then

L["Enchant a scroll (%d)"] = "Rolle verzaubern (%d)"
L["Enchant a scroll (0)"] = "Rolle verzaubern (0)"
L["Recipe link not found for %s"] = "Rezeptlink für %s wurde nicht gefunden"
L["The recipe to make the reagent seems to be hidden, it is not makable. Try to remove the filters on the recipes."] = "Das Rezept zum Erstellen des Materials scheint ausgeblendet und ist nicht automatisch herstellbar. Versuche, ausgewählte Filter zu entfernen."
L["The recipe to make this reagent is in another tradeskill. Currently ReagentMaker can not manage such a case, sorry."] = "Das Rezept um dieses Material zu erstellen ist in einem anderen Beruf. ReagentMager kann mit dieser Situation noch nicht umgehen, tut mir Leid!"
L["You do not have enough [%s] to craft [%s]"] = "Du hast nicht genügend [%s] um [%s] herzustellen."
L["You do not have enough reagents to craft [%s]"] = "Du hast nicht alle benötigten Materialien für [%s]"

end
