# Travailler sur un dépôt AgentMaurice

Rédiger en français et conserver les termes techniques en anglais. Une question se traite en lecture seule. Annoncer les tests passés après les avoir exécutés. Consulter le README du dépôt pour ses commandes et ses conventions.

**Délégation.** La session principale traite seule une correction simple. Elle peut confier une exploration indépendante, un patch sur des fichiers attribués ou le rejeu d’un parcours. Le brief donne la question, le périmètre et la preuve attendue. La session principale intègre et vérifie le résultat.

**Avant le patch.** Pour une règle partagée, pars d’un parcours qui applique déjà la règle, remonte jusqu’au code qui prend la décision et repère les autres parcours qui doivent la suivre. Modifie la règle à cet endroit.

**Étude de l’existant.** Avant de proposer un ticket à un agent de développement, confier l’étude de l’existant à un autre agent qui connaît le domaine. Il suit un parcours voisin jusqu’au code qui porte la règle. Dans le contexte technique du ticket, il indique la révision, les chemins et les symboles à réutiliser ou à étendre, les appelants à préserver et le scénario à rejouer. Si une création est nécessaire, il précise où il a cherché, ce qui manque et les questions ouvertes. Le responsable relit la note enregistrée avant la remise. Le développeur part de cette note et la met à jour si le code ou le périmètre a changé.

**Vérification.** Rejouer le comportement observable avec la révision intégrée. Donner le scénario, l’attendu et le résultat obtenu.
