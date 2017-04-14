function IsHeroPicked(name) {
	var hero_selection_table = PlayerTables.GetAllTableValues("hero_selection")
	if (hero_selection_table != null) {
		for (var teamKey in hero_selection_table) {
			for (var playerIdInSelection in hero_selection_table[teamKey]) {
				if (hero_selection_table[teamKey][playerIdInSelection].hero == name && hero_selection_table[teamKey][playerIdInSelection].status == "picked") {
					return true
				}
			}
		}
	}
	return false
}

function IsHeroLocked(name) {
	var hero_selection_table = PlayerTables.GetAllTableValues("hero_selection")
	if (hero_selection_table != null) {
		for (var teamKey in hero_selection_table) {
			for (var playerIdInSelection in hero_selection_table[teamKey]) {
				if (hero_selection_table[teamKey][playerIdInSelection].hero == name && hero_selection_table[teamKey][playerIdInSelection].status == "locked") {
					return true
				}
			}
		}
	}
	return false
}

function SearchHero() {
	if ($("#HeroSearchTextEntry") != null) {
		var SearchString = $("#HeroSearchTextEntry").text.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");

		$.GetContextPanel().SetHasClass("InSearch", SearchString.length > 0);
		if (SearchString.length > 0) {
			for (var key in HeroesPanels) {
				var heroName = $.Localize(HeroesPanels[key].id.replace("HeroListPanel_element_", ""))
				HeroesPanels[key].SetHasClass("SearchedPanelDisabled", heroName.search(new RegExp(SearchString, "i")) === -1);
			}
		} else {
			for (var key in HeroesPanels) {
				HeroesPanels[key].RemoveClass("SearchedPanelDisabled");
			}
		}
	}
}

function FillHeroesTable(heroesData, panel, big) {
	for (var herokey in heroesData) {
		var heroData = heroesData[herokey]
		var StatPanel = panel.FindChildTraverse("HeroesByAttributes_" + heroData.attributes.attribute_primary)
		var HeroImagePanel = $.CreatePanel('Image', StatPanel, "HeroListPanel_element_" + heroData.heroKey)
		HeroImagePanel.SetImage(TransformTextureToPath(heroData.heroKey, "portrait"))
		HeroImagePanel.AddClass("HeroListElement")
		var LockedImage = $.CreatePanel('Image', HeroImagePanel, "LockedIcon")
		LockedImage.AddClass("LockedSelectionIcon")
		LockedImage.hittest = false
		if (heroData.border_class) {
			HeroImagePanel.AddClass(heroData.border_class)
		}
		var SelectHeroAction = (function(_heroData, _panel) {
			return function() {
				if (SelectedHeroPanel != _panel) {
					SelectedHeroData = _heroData
					if (SelectedHeroPanel != null) {
						SelectedHeroPanel.RemoveClass("HeroPanelSelected")
					}
					_panel.AddClass("HeroPanelSelected")
					SelectedHeroPanel = _panel
					ChooseHeroPanelHero()
				}
			}
		})(heroData, HeroImagePanel)
		HeroImagePanel.SetPanelEvent('onactivate', SelectHeroAction)
		HeroImagePanel.SelectHeroAction = SelectHeroAction
		HeroesPanels.push(HeroImagePanel)
	}
}

function SelectFirstHeroPanel() {
	var p;
	for (var key in HeroesPanels) {
		var heroName = HeroesPanels[key].id.replace("HeroListPanel_element_", "")
		if (heroName == "npc_dota_hero_abaddon") {
			p = HeroesPanels[key]
		}
	}
	if (p == null) {
		for (var key in HeroesPanels) {
			return HeroesPanels[key].SelectHeroAction();
		}
	}
	return p.SelectHeroAction();
}

function ChooseHeroUpdatePanels() {
	/*var BioPanel = $("#SelectedHeroDescriptionText")
	if (BioPanel != null)
		BioPanel.text = $.Localize("#" + SelectedHeroData.heroKey + "_bio")
	*/
	UpdateSelectionButton();
	var context = $.GetContextPanel();
	$("#SelectedHeroSelectHeroName").text = $.Localize("#" + SelectedHeroData.heroKey);
	context.SetHasClass("HoveredHeroHasLinked", SelectedHeroData.linked_heroes != null);
	if (SelectedHeroData.linked_heroes != null) {
		var linked = [];
		$.Each(SelectedHeroData.linked_heroes, function(hero) {
			linked.push($.Localize(hero));
		});
		$("#SelectedHeroLinkedHero").text = linked.join(", ")
	}
	$("#SelectedHeroAbilitiesPanelInner").RemoveAndDeleteChildren()
	FillAbilitiesUI($("#SelectedHeroAbilitiesPanelInner"), SelectedHeroData.abilities, "SelectedHeroAbility")
	FillAttributeUI($("#HeroListControlsGroup3"), SelectedHeroData)
}

function FillAbilitiesUI(rootPanel, abilities, className) {
	$.Each(abilities, function(abilityName) {
		var abilityPanel = $.CreatePanel('DOTAAbilityImage', rootPanel, "")
		abilityPanel.AddClass(className)
		abilityPanel.abilityname = abilityName
		abilityPanel.SetPanelEvent('onmouseover', function() {
			$.DispatchEvent("DOTAShowAbilityTooltip", abilityPanel, abilityName);
		})
		abilityPanel.SetPanelEvent('onmouseout', function() {
			$.DispatchEvent("DOTAHideAbilityTooltip", abilityPanel);
		})
	})
}

function FillAttributeUI(rootPanel, SelectedHeroData) {
	for (var i = 2; i >= 0; i--) {
		rootPanel.FindChildTraverse("DotaAttributePic_" + (i + 1)).SetHasClass("PrimaryAttribute", SelectedHeroData.attributes.attribute_primary == i)
		rootPanel.FindChildTraverse("HeroAttributes_" + (i + 1)).text = SelectedHeroData.attributes["attribute_base_" + i] + " + " + Number(SelectedHeroData.attributes["attribute_gain_" + i]).toFixed(1)
	}
	rootPanel.FindChildTraverse("HeroAttributes_damage").text = SelectedHeroData.attributes.damage_min + " - " + SelectedHeroData.attributes.damage_max
	rootPanel.FindChildTraverse("HeroAttributes_speed").text = SelectedHeroData.attributes.movespeed
	rootPanel.FindChildTraverse("HeroAttributes_armor").text = SelectedHeroData.attributes.armor
	rootPanel.FindChildTraverse("HeroAttributes_bat").text = Number(SelectedHeroData.attributes.attackrate).toFixed(1)
}

function SwitchTab() {
	SelectHeroTab(SelectedTabIndex == 1 ? 2 : 1)
}

function SelectHeroTab(tabIndex) {
	if (SelectedTabIndex != tabIndex) {
		if (SelectedTabIndex != null) {
			$("#HeroListPanel_tabPanels_" + SelectedTabIndex).visible = false
		}
		$("#HeroListPanel_tabPanels_" + tabIndex).visible = true
		SelectedTabIndex = tabIndex
	}
}